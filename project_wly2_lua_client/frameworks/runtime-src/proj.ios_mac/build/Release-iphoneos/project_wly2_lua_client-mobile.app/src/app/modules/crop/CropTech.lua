local CropTech = class('CropTech', require("app.modules.common.BaseViewWithHead"))

CropTech.RESOURCE_FILENAME = "crop/CropTech.csb"
CropTech.RESOURCE_BINDING = {
    ["Image_1"]                         = {["varname"] = "_imgBg"},
    ["Text_name"]                       = {["varname"] = "_txtName"},
    ["Text_cur_level_progress"]         = {["varname"] = "_txtLevelProgress"},
    ["Text_total_level"]                = {["varname"] = "_txtTotalLevel"},
    ["Text_level"]                      = {["varname"] = "_txtLevel"},
    ["Text_cur_level"]                  = {["varname"] = "_txtCurLevel"},
    ["Text_next_level"]                 = {["varname"] = "_txtNextLevel"},
    ["Text_donate_progress"]            = {["varname"] = "_txtProgress"},
    ["LoadingBar_donate"]               = {["varname"] = "_loadPogress"},
    ["Text_title_effct"]                = {["varname"] = "_txtEffectDesc"},
    ["Text_cur_effct"]                  = {["varname"] = "_txtCurEffect"},
    ["Text_next_effect"]                = {["varname"] = "_txtNextEffect"},
    ["Text_reward_progress"]            = {["varname"] = "_txtRewardProgress"},
    ["Text_reward_donation"]            = {["varname"] = "_txtRewardDonation"},
    ["text_silver"]                     = {["varname"] = "_txtSilver"},
    ["text_gold"]                       = {["varname"] = "_txtGold"},
    ["silver_cost"]                     = {["varname"] = "_txtSilverCost"},
    ["gold_cost"]                       = {["varname"] = "_txtGoldCost"},
    ["Sprite_icon"]                     = {["varname"] = "_spriteIcon"},
    ["button_silver"]                   = {["varname"] = "_btnSilver",["events"] = {{["event"] = "touch",["method"] = "onSilver"}}},
    ["button_gold"]                     = {["varname"] = "_btnGold",["events"] = {{["event"] = "touch",["method"] = "onGold"}}},
    ["Node_1"]                          = {["varname"] = "_nodeRight"},
    ["Node_2"]                          = {["varname"] = "_nodeLeft"},
    ["sprite_silver"]                   = {["varname"] = "_spriteSilver"},
    ["sprite_gold"]                     = {["varname"] = "_spriteGold"},
    ["Panel_table_view"]                = {["varname"] = "_panelTableView"},
}

function CropTech:init()
    local coin_types = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.GESTE,
    }
    self:addShowCoinGroup(coin_types)
    self:centerView()
    self:parseView()
    self:adaptBgSize(self._imgBg)
    self:setTitle(uq.config.constant.MODULE_ID.CROP_TECH)
    self:initTechsTableView()

    network:addEventListener(Protocol.S_2_C_LOAD_TECHNOLOGY, handler(self, self.onLoadTechnology), 'onLoadTechnology')
    network:addEventListener(Protocol.S_2_C_CROP_CONTRIBUTE, handler(self, self.onCropContribute), 'onCropContribute')
    network:sendPacket(Protocol.C_2_S_LOAD_TECHNOLOGY)
end

function CropTech:onCreate()
    CropTech.super.onCreate(self)

    self._itemList = {}
    self._selectedIndex = 1

    self._nodeLeft:setPosition(cc.p(-display.width / 2, display.height))
    self._nodeLeft:stopAllActions()
    self._nodeLeft:setOpacity(0)
    self._nodeLeft:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveBy:create(0.2, cc.p(display.width / 2, 0))))

    self._nodeRight:setPosition(display.right_top)
    self._nodeRight:stopAllActions()
    self._nodeRight:setOpacity(0)
    self._nodeRight:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveBy:create(0.2, cc.p(-display.width / 2, 0))))
end

function CropTech:initTechsTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width, size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setDelegate()
    self._tableView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
    self._panelTableView:addChild(self._tableView)
end

function CropTech:tableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByTag(1000)
    if item == nil then
        return
    end
    local pos = item:convertToNodeSpace(touch_point)
    local rect = cc.rect(-item:getContentSize().width / 2, -item:getContentSize().height / 2, item:getContentSize().width, item:getContentSize().height)
    if cc.rectContainsPoint(rect, pos) then
        if self._selectedIndex == index then
            return
        end
        if item:getOpend() then
            self:itemSelect(index)
        end
    end
end

function CropTech:cellSizeForTableContent(view, idx)
    return 460, 100
end

function CropTech:numberOfCellsInTableViewContent(view)
    return #StaticData['legion_tech']
end

function CropTech:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local tech_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        local width = 0
        local height = 0
        tech_item = uq.createPanelOnly("crop.CropTechItem")
        width = tech_item:getContentSize().width
        height = tech_item:getContentSize().height
        tech_item:setPosition(cc.p(width / 2, height / 2))
        tech_item:setData(index,self)
        tech_item:setSelected(self._selectedIndex == index)
        tech_item:setVisible(index > 0)
        cell:addChild(tech_item, 1)
        table.insert(self._itemList, tech_item)
    else
        tech_item = cell:getChildByTag(1000)
        if not tech_item then
            return cell
        end
        tech_item:setData(index,self)
        tech_item:setSelected(self._selectedIndex == index)
        tech_item:setVisible(index > 0)
    end

    tech_item:setTag(1000)

    return cell
end

function CropTech:itemSelect(index)
    for k, item in ipairs(self._itemList) do
        item:setSelected(k == index)
    end
    self._selectedIndex = index
    self:refreshRightPage(index)
    self._nodeRight:setPosition(display.left_top)
    self._nodeRight:stopAllActions()
    self._nodeRight:setOpacity(0)
    self._nodeRight:runAction(cc.Spawn:create(cc.FadeIn:create(0.4), cc.MoveBy:create(0.2, cc.p(display.width / 2, 0))))
end

function CropTech:refreshRightPage(index)
    local xml_data = StaticData['legion_tech'][index]

    local tech_level = 0
    local progress = 0
    local silver_time = 0
    local gold_time = 0
    if self._techData then
        tech_level = self._techData.techs[index].lvl
        progress = self._techData.techs[index].exp
        silver_time = self._techData.num1
        gold_time = self._techData.num2
    end

    self._txtLevel:setString(tostring(tech_level))
    local tech_data = xml_data.Effect[tech_level]
    self._txtName:setString(xml_data.name)

    local max_level = self._selectedIndex == 1 and #xml_data.Effect or tech_data.LegionLevel
    self._txtLevelProgress:setHTMLText(string.format("%s <font color='#FFFFFF'> %d</font>/%d", StaticData['local_text']['crop.tech.curlevel'], tech_level, max_level))
    self._txtCurLevel:setString(tostring(tech_level))
    local next_level = (tech_level + 1) > max_level and max_level or (tech_level + 1)
    self._txtNextLevel:setString(tostring(next_level))

    self._txtProgress:setHTMLText(string.format("<font color='#FFFFFF'> %d</font>/%d", progress, tonumber(tech_data.exp)))
    self._loadPogress:setPercent(progress / tonumber(tech_data.exp) * 100)



    local effect_desc = xml_data.desc
    self._txtEffectDesc:setString(effect_desc)
    local cur_effect_txt = "+" .. tostring(tech_data.value)
    local next_effect_txt = "+" .. tostring(xml_data.Effect[tech_level].value)
    if xml_data.Effect[tech_level + 1] then
        next_effect_txt = "+" .. tostring(xml_data.Effect[tech_level + 1].value)
    end
    if index ~= 1 then
        cur_effect_txt = cur_effect_txt .. "%"
        next_effect_txt = next_effect_txt .. "%"
    end
    self._txtCurEffect:setString(cur_effect_txt)
    self._txtNextEffect:setString(next_effect_txt)

    self._txtRewardProgress:setString(string.format("+" .. tonumber(tech_data.each)))
    self._txtRewardDonation:setString(string.format("+" .. tonumber(tech_data.each)))

    local silver_config = string.split(tech_data.cost1, ';')
    local gold_config = string.split(tech_data.cost2, ';')

    self:refreshButtonState(silver_config, self._btnSilver, self._txtSilver, self._spriteSilver, silver_time == xml_data.limit1)
    self:refreshButtonState(gold_config, self._btnGold, self._txtGold, self._spriteGold, gold_time == xml_data.limit2)

    self._txtSilverCost:setString(StaticData['local_text']['crop.tech.today.num'] .. string.format(' %d/%d', silver_time, xml_data.limit1))
    self._txtGoldCost:setString(StaticData['local_text']['crop.tech.today.num'] .. string.format(' %d/%d', gold_time, xml_data.limit2))
    self._spriteIcon:setTexture('img/crop/' .. xml_data.icon)
end

function CropTech:refreshButtonState(config, button, text, sprite, blimit)
    button:setEnabled(true)
    uq.ShaderEffect:setRemoveGrayAndChild(sprite)
    if #config == 3 then
        text:setString(config[2])
        if not uq.cache.role:checkRes(tonumber(config[1]), tonumber(config[2])) then
            button:setEnabled(false)
            uq.ShaderEffect:addGrayButton(button)
            uq.ShaderEffect:setGrayAndChild(sprite)
        end
    else
        button:setEnabled(false)
        uq.ShaderEffect:addGrayButton(button)
        uq.ShaderEffect:setGrayAndChild(sprite)
    end

    if blimit then
        button:setEnabled(false)
        uq.ShaderEffect:addGrayButton(button)
    end
end

function CropTech:onExit()
    network:removeEventListenerByTag('onLoadTechnology')
    network:removeEventListenerByTag('onCropContribute')

    CropTech.super:onExit()
end

function CropTech:onLoadTechnology(msg)
    self._techData = msg.data
    for k, item in ipairs(self._itemList) do
        item:refreshPage()
    end
    self:refreshRightPage(self._selectedIndex)
    local total_level = 0
    for k, v in pairs(self._techData.techs) do
        total_level = total_level + v.lvl
    end
    self._txtTotalLevel:setString(tostring(total_level))
end

function CropTech:getTechData()
    return self._techData
end

function CropTech:onSilver(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_CONTRIBUTE, {contribute_type = 1, tech_id = self._selectedIndex})
    end
end

function CropTech:onGold(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_CONTRIBUTE, {contribute_type = 2, tech_id = self._selectedIndex})
    end
end

function CropTech:onCropContribute(msg)
    if msg.data.contribute_type == 1 then
        self._techData.num1 = msg.data.num
    else
        self._techData.num2 = msg.data.num
    end
    self._techData.techs[msg.data.tech_id].lvl = msg.data.level
    self._techData.techs[msg.data.tech_id].exp = msg.data.exp
    self._itemList[msg.data.tech_id]:refreshPage()
    self:refreshRightPage(self._selectedIndex)
    local total_level = 0
    for k, v in pairs(self._techData.techs) do
        total_level = total_level + v.lvl
    end
    self._txtTotalLevel:setString(tostring(total_level))
    uq.fadeInfo(StaticData['local_text']['crop.tech.levelup'])
    if uq.config.constant.CROP_TECH.CROP_LEVEL == msg.data.tech_id then
        uq.cache.crop:setCropLevel(msg.data.level)
    end
end

return CropTech
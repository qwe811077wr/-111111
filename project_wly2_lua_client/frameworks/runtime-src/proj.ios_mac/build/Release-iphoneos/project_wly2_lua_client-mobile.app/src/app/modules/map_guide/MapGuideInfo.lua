local MapGuideInfo = class("MapGuideInfo", require("app.base.PopupBase"))
local MapGuideInfoItem = require("app.modules.map_guide.MapGuideInfoItem")
local EquipItem = require("app.modules.common.EquipItem")

MapGuideInfo.RESOURCE_FILENAME = "map_guide/MapGuideInfo1.csb"

MapGuideInfo.RESOURCE_BINDING  = {
    ["Panel_1/Panel_head"]                              ={["varname"] = "_panelTableView"},
    ["Panel_1/Node_11/Panel_role"]                      ={["varname"] = "_panelRole"},
    ["Panel_1/Button_3/label_cur_level"]                ={["varname"] = "_titleLabel"},
    ["Panel_1/Panel_select"]                            ={["varname"] = "_panelSelect"},
    ["Panel_1/Panel_select/Panel_6/label_des"]          ={["varname"] = "_selectDesLabel"},
    ["Panel_1/Panel_select/Panel_6/Image_type"]         ={["varname"] = "_selectTypeImg"},
    ["Panel_1/Panel_select/Image_32"]                   ={["varname"] = "_selectBgImg"},
    ["Panel_1/label_cur_percent"]                       ={["varname"] = "_percentLabel"},
    ["Panel_1/Image_18"]                                ={["varname"] = "_imgPerssBg"},
    ["Panel_1/Image_25"]                                ={["varname"] = "_imgPointShow"},
    ["Panel_1/label_type"]                              ={["varname"] = "_typeLabel"},
    ["Panel_1/Image_type"]                              ={["varname"] = "_imgType"},
    ["Panel_1/Image_general"]                           ={["varname"] = "_imgGeneralShow"},
    ["Panel_1/Node_11"]                                 ={["varname"] = "_nodeShowData"},
    ["Panel_1/Node_11/lade_generals_des"]               ={["varname"] = "_generalDesLabel"},
    ["Panel_1/Node_11/Node_attr1"]                      ={["varname"] = "_nodeAttr1"},
    ["Panel_1/Node_11/Node_attr2"]                      ={["varname"] = "_nodeAttr2"},
    ["Panel_1/Node_11/Node_attr3"]                      ={["varname"] = "_nodeAttr3"},
    ["Panel_1/Node_11/Node_attr4"]                      ={["varname"] = "_nodeAttr4"},
    ["Panel_1/Node_11/Panel_reward"]                    ={["varname"] = "_panelReward"},
    ["Panel_1/Node_11/Image_reward_state"]              ={["varname"] = "_imgRewardState"},
    ["Panel_1/Node_11/Panel_mash"]                      ={["varname"] = "_panelMash"},
    ["Panel_1/Node_11/Node_1/Image_3"]                  ={["varname"] = "_imgGeneralType"},
    ["Panel_1/Node_11/Node_1/txt_name"]                 ={["varname"] = "_generalNameLabel"},
    ["Panel_1/btn_close"]                               = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Panel_1/Button_3"]                                = {["varname"] = "_btnDetail", ["events"] = {{["event"] = "touch",["method"] = "_onBtnDetail"}}},
    ["Panel_1/Image_select"]                            = {["varname"] = "_imgSelect"},
    ["Panel_1/Image_attr"]                              = {["varname"] = "_imgAttr"},
}

MapGuideInfo.STATE_TYPE = {
    ACTIVATED = 0,                  --已经激活
    NOT_ACTIVE_LEVEL = 1,           --不可激活外加人物等级不足
    ACTIVE_LEVEL = 2,               --可激活但是人物等级不足
    NOT_ACTIVE_STATE = 3,           --不可激活
    CAN_REWARD = 4,                 --可领奖
    CAN_ACTIVE = 5,                 --可激活
}

function MapGuideInfo:ctor(name, args)
    MapGuideInfo.super.ctor(self, name, args)
    self._curSelectArray = {}   --默认是全部
    self._curQualitySelect = 0     --0是全部
    self._totalData = {}
    self._curTabArray = {}
    self._curTabInfo = nil
    self._itemArray = {}
    self._typeSelectArray = {}
    self._curMaxExp = 0
    self._curTotalExp = 0
    self._attrArray = {self._nodeAttr2, self._nodeAttr3, self._nodeAttr4}
    self._panelSelect:setVisible(false)
end

function MapGuideInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initDialog()
    self:initTableView()
    self:initProtocolData()
end

function MapGuideInfo:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_LOAD, handler(self, self._onIllustrationLoad), '_onIllustrationLoadByMapGuide')
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_RED, handler(self, self._onIllustrationRed), '_onIllustrationRedByMapGuide')
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_ACTIVE, handler(self, self._onIllustrationActive), '_onIllustrationActiveByMapGuide')
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_ACTIVE_GROWTH, handler(self, self._onIllustrationActiveGrowth), '_onIllustrationActiveGrowthByMapGuide')
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_DRAW, handler(self, self._onIllustrationDraw), '_onIllustrationDrawByMapGuide')
    if uq.cache.illustration.illustration_info == nil then
        network:sendPacket(Protocol.C_2_S_ILLUSTRATION_LOAD, {})
    else
        self:_onIllustrationLoad()
    end
end

function MapGuideInfo:removeProtocolData()
    services:removeEventListenersByTag("_onIllustrationLoadByMapGuide")
    services:removeEventListenersByTag("_onIllustrationActiveByMapGuide")
    services:removeEventListenersByTag("_onIllustrationRedByMapGuide")
    services:removeEventListenersByTag("_onIllustrationActiveGrowthByMapGuide")
    services:removeEventListenersByTag("_onIllustrationDrawByMapGuide")
end

function MapGuideInfo:_onIllustrationDraw()
    local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
    local state = self:getIllustrationState(illustration_info)
    self:updateItemState(self._curTabInfo.ident, state)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._curTabInfo.reward})
    self:updateReward(illustration_info)
end

function MapGuideInfo:_onIllustrationActiveGrowth(msg)
    local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
    local state = self:getIllustrationState(illustration_info)
    self:updateItemState(self._curTabInfo.ident, state)
    self:updateAttrState(illustration_info)
    for k, v in ipairs(self._curTabInfo.Growth) do
        if v.ident == msg.id then
            self:showAttr(v.increaseAttribute)
            break
        end
    end
end

function MapGuideInfo:updateItemState(id, state)
    self._totalData[id].state = state
    for k, v in ipairs(self._curTabArray) do
        if v.ident == id then
            v.state = state
            break
        end
    end
    for k, v in ipairs(self._itemArray) do
        local info = v:getInfo()
        if info.ident == id then
            info.state = state
            v:setInfo(info)
            break
        end
    end
end

function MapGuideInfo:_onIllustrationRed()
    self._btnDetail:getChildByName("img_red"):setVisible(uq.cache.illustration.isActive)
end

function MapGuideInfo:_onIllustrationActive(msg)
    self:updateDataByActive(msg.data)
    self:showAttr(self._curTabInfo.attribute)
end

function MapGuideInfo:showAttr(attr)
    local attr = string.split(self._curTabInfo.attribute, ",")
    local type_xml = StaticData['types'].Effect[1].Type[tonumber(attr[1])]
    local str = type_xml.name .. ' +' .. uq.cache.generals:getNumByEffectType(tonumber(attr[1]), tonumber(attr[2]))
    uq.fadeAttr(str, 667, 444)
end

function MapGuideInfo:_onIllustrationLoad()
    self:updateData()
end

function MapGuideInfo:getIllustrationState(info)
    for k, v in pairs(info.growth) do
        if v.growth_state == 1 then
            return self.STATE_TYPE.CAN_ACTIVE
        end
    end
    if info.draw == 0 and info.state >= 1 then
        return self.STATE_TYPE.CAN_REWARD
    end
    local illustration_info = StaticData['Illustration'].Illustration[info.id]
    if info.state == 1 then --可激活
        if illustration_info.level > uq.cache.role:level() then
            return self.STATE_TYPE.ACTIVE_LEVEL
        else
            return self.STATE_TYPE.CAN_ACTIVE
        end
    elseif info.state == 0 then
        if illustration_info.level > uq.cache.role:level() then
            return self.STATE_TYPE.NOT_ACTIVE_LEVEL
        else
            return self.STATE_TYPE.NOT_ACTIVE_STATE
        end
    end
    return self.STATE_TYPE.ACTIVATED
end

function MapGuideInfo:updateData()
    self._totalData = {}
    local data = uq.cache.illustration.illustration_info
    self._curTotalExp = data.total_exp
    self._curMaxExp = 0
    for k2, v2 in ipairs(data.items) do
        local info = StaticData['Illustration'].Illustration[v2.id]
        if info ~= nil and (info.camp == 0 or info.camp == uq.cache.role.country_id) then
            info.state = self:getIllustrationState(v2)
            self._curMaxExp = self._curMaxExp + 1
            local general_info = StaticData['general'][info.generalId * 10 + 1]
            info.grade = general_info.grade
            self._totalData[v2.id] = info
        end
    end
    self:updateStageInfoByTotalExp()
    self:updateDialog()
    self:updateSelectDialog()
end

function MapGuideInfo:updateDialog()
    self._percentLabel:setString(string.format(StaticData["local_text"]["map.guide.des19"], self._curTotalExp, self._curMaxExp))
end

function MapGuideInfo:updateSelectItem(array)
    self._curSelectArray = array
    self._curTabArray = {}
    for k, v in pairs(self._totalData) do
        if v.grade == self._curQualitySelect or self._curQualitySelect == 0 then
            local attr_array = string.split(v.attribute, ";")
            for k2, v2 in ipairs(attr_array) do
                local attr = string.split(v2, ",")
                if self._curSelectArray[tonumber(attr[1])] then
                    table.insert(self._curTabArray, v)
                    break
                end
            end
        end
    end
    if #self._curTabArray > 1 then
        table.sort(self._curTabArray,function(a,b)
            if a.state == b.state then
                return a.grade > b.grade
            end
            return a.state > b.state
        end)
    end
    self._curTabInfo = self._curTabArray[1]
    self._nodeShowData:setVisible(#self._curTabArray > 0)
    self._imgGeneralShow:setVisible(#self._curTabArray == 0)
    self._tableView:reloadData()
    self:updateGeneralInfo()
end

function MapGuideInfo:updateGeneralInfo()
    if not self._curTabInfo then
        return
    end
    local generals_xml = StaticData['general'][self._curTabInfo.generalId * 10 + 1]
    self._generalDesLabel:setString(generals_xml.desc)
    self._generalDesLabel:getVirtualRenderer():setLineSpacing(12)
    local generals_grade = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
    if not generals_grade then
        uq.log("error  MapGuideInfo updateGeneralInfo  ",generals_xml)
        return
    end
    self._imgGeneralType:loadTexture("img/generals/" .. generals_grade.image)
    self._generalNameLabel:setString(generals_xml.name)
    self._panelRole:removeAllChildren()
    local pre_path = "animation/spine/" .. generals_xml.imageId .. '/' .. generals_xml.imageId
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        self._panelRole:addChild(anim)
        anim:setScale(generals_xml.imageRatio)
        anim:setPosition(cc.p(generals_xml.imageX + display.width - CC_DESIGN_RESOLUTION.width, generals_xml.imageY + self._panelRole:getContentSize().height * 0.33))
        anim:setAnimation(0, 'idle', true)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelRole:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        local size = self._panelRole:getContentSize()
        img:setScale(generals_xml.imageRatio)
        img:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX, size.height + generals_xml.imageY))
    end

    local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
    self:updateAttrState(illustration_info)
    self:updateReward(illustration_info)
end

function MapGuideInfo:updateReward(illustration_info)
    self._panelReward:removeAllChildren()
    local pos_x = 35
    local pos_y = 10
    self._panelMash:setVisible(illustration_info.draw == 1)
    self._imgRewardState:setVisible(illustration_info.draw == 0)
    if illustration_info.draw == 0 then
        pos_x = 55
        if illustration_info.state >= 1 then
            self._imgRewardState:loadTexture("img/map_guide/s03_00128.png")
            self._imgRewardState:getChildByName("reward_des"):setString(StaticData["local_text"]["map.guide.des22"])
            uq:addEffectByNode(self._panelReward, 900052, -1, true)
        else
            self._imgRewardState:loadTexture("img/map_guide/s03_00127.png")
            self._imgRewardState:getChildByName("reward_des"):setString(StaticData["local_text"]["map.guide.des20"])
        end
    end
    local reward_list = uq.RewardType.parseRewards(self._curTabInfo.reward)
    for i, v in ipairs(reward_list) do
        local equip_item = EquipItem:create({info = v:toEquipWidget()})
        self._panelReward:addChild(equip_item)
        equip_item:setScale(0.75)
        equip_item:setAnchorPoint(cc.p(0, 0))
        local size = equip_item:getBgContentSize()
        equip_item:setPosition(cc.p(pos_x, pos_y))
        if illustration_info.state >= 1 then
            equip_item:setTouchEnabled(false)
            if illustration_info.draw == 0 then
                uq:addEffectByNode(self._panelReward, 900053, -1, true, cc.p(pos_x + size.width * 0.39, pos_y + size.height * 0.39))
            end
        else
            equip_item:setTouchEnabled(true)
        end
        equip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        pos_x = pos_x + 100
    end
end

function MapGuideInfo:updateAttrState(illustration_info)
    local attr = string.split(self._curTabInfo.attribute, ",")
    local type_xml = StaticData['types'].Effect[1].Type[tonumber(attr[1])]
    self._nodeAttr1:getChildByName("label_des"):setString(string.format(StaticData["local_text"]["map.guide.des"], type_xml.name))
    self._nodeAttr1:getChildByName("label_value"):setString("+" .. uq.cache.generals:getNumByEffectType(tonumber(attr[1]), tonumber(attr[2])))
    if illustration_info == nil then
        return
    end
    self:updateStateLabel(self._nodeAttr1, illustration_info.state, StaticData["local_text"]["map.guide.des9"])
    for k, v in ipairs(illustration_info.growth) do
        local xml_info = self._curTabInfo.Growth[k]
        local node = self._attrArray[k]
        self:updateStateLabel(node, v.growth_state, xml_info.desc)
        if v.growth_state == 0 then
            node:getChildByName("label_state"):setString(xml_info.desc)
        end
        local attr = string.split(xml_info.increaseAttribute, ",")
        local type_xml = StaticData['types'].Effect[1].Type[tonumber(attr[1])]
        node:getChildByName("label_des"):setString(string.format(StaticData["local_text"]["map.guide.des"], type_xml.name))
        node:getChildByName("label_value"):setString("+" .. uq.cache.generals:getNumByEffectType(tonumber(attr[1]), tonumber(attr[2])))
    end
end

function MapGuideInfo:updateStateLabel(node, state, desc)
    node:getChildByName("Image_state"):setVisible(state ~= 2)
    node:getChildByName("Image_state"):removeAllChildren()
    if state == 2 then
        node:getChildByName("label_state"):setFontSize(22)
        node:getChildByName("label_state"):setString(StaticData["local_text"]["map.guide.des8"])
        node:getChildByName("label_state"):setTextColor(uq.parseColor("#FF5353"))
    else
        node:getChildByName("label_state"):setTextColor(uq.parseColor("#FFFFFF"))
        node:getChildByName("label_state"):setFontSize(18)
        if state == 1 then
            local size = node:getChildByName("Image_state"):getContentSize()
            local pos_x = size.width * 0.5
            local pos_y = size.height * 0.5 + 5
            uq:addEffectByNode(node:getChildByName("Image_state"), 900051, -1, true, cc.p(pos_x, pos_y))
            node:getChildByName("label_state"):setString(StaticData["local_text"]["map.guide.des12"])
            node:getChildByName("Image_state"):loadTexture("img/map_guide/s02_00055.png")
        else
            node:getChildByName("label_state"):setString(desc)
            node:getChildByName("Image_state"):loadTexture("img/common/ui/s02_00054.png")
        end
    end
end

function MapGuideInfo:updateStageInfoByTotalExp()
    local data = uq.cache.illustration.illustration_info
    local exp = data.total_exp
    local stage_info = nil
    local stage_info_Array = {}
    for k, v in pairs(StaticData['Illustration'].Stage) do
        table.insert(stage_info_Array, v)
    end
    table.sort(stage_info_Array, function(a, b)
        return a.ident < b.ident
    end)
    for k, v in ipairs(stage_info_Array) do
        if v.exp > exp  then
            stage_info = v
            break
        end
        exp = exp - v.exp
    end
    if stage_info == nil then
        stage_info = stage_info_Array[#stage_info_Array]
    end
    self._titleLabel:setString(stage_info.name)
end

function MapGuideInfo:updateDataByActive(id)
    local illustration_info = uq.cache.illustration:getIllustrationInfoById(id)
    local state = self:getIllustrationState(illustration_info)
    self:updateItemState(id, state)
    self._curTotalExp = self._curTotalExp + StaticData['Illustration'].Illustration[id].exp
    self:updateStageInfoByTotalExp()
    self:updateDialog()
    self:updateAttrState(illustration_info)
end

function MapGuideInfo:updateSelectDialog()
    self._typeLabel:setVisible(self._curQualitySelect == 0)
    self._imgType:setVisible(self._curQualitySelect ~= 0)
    local generals_grade = StaticData['types'].GeneralGrade[1].Type[self._curQualitySelect]
    if generals_grade then
        self._imgType:loadTexture("img/generals/" .. generals_grade.image)
    end
    self:updateSelectItem(self._curSelectArray)
end

function MapGuideInfo:_onBtnDetail(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.MAP_GUIDE_SKILL,{})
end

function MapGuideInfo:showSelectType()
    self._panelSelect:setVisible(true)
    self._imgPointShow:setRotation(0)
    self._selectDesLabel:setVisible(self._curQualitySelect ~= 0)
    self._selectTypeImg:setVisible(self._curQualitySelect == 0)
    self:updateSelectType()
end

function MapGuideInfo:updateSelectType()
    local select_tag = self._curQualitySelect
    for k, v in ipairs(self._typeSelectArray) do
        v:getChildByName("Panel_press"):setVisible(false)
        local tag = k
        if k == select_tag then
            tag = tag + 1
            select_tag = select_tag + 1
            if tag > 6 then
                tag = 0
            end
        end
        v:setTag(tag)
        local generals_grade = StaticData['types'].GeneralGrade[1].Type[tag]
        if generals_grade then
            v:getChildByName("Image_type"):loadTexture("img/generals/" .. generals_grade.image)
        end
    end
end

function MapGuideInfo:initDialog()
    local select_array = string.split(StaticData['Illustration'].Info[1].selectAttributeType, ",")
    for k, v in ipairs(select_array) do
        self._curSelectArray[tonumber(v)] = true
    end
    self:_onIllustrationRed()
    self._imgPerssBg:setTouchEnabled(true)
    self._imgPerssBg:addClickEventListener(function(sender)
        self:showSelectType()
    end)
    self._panelSelect:setTouchEnabled(true)
    self._panelSelect:addClickEventListener(function(sender)
        self._panelSelect:setVisible(false)
        self._imgPointShow:setRotation(180)
    end)
    self._typeSelectArray = {}
    for i = 1, 6, 1 do
        local panel = self._panelSelect:getChildByName("Panel_" .. i)
        table.insert(self._typeSelectArray, panel)
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = self._selectBgImg:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._selectBgImg)

    self._imgAttr:setTouchEnabled(true)
    self._imgAttr:addClickEventListener(function(sender)
        local is_active = false
        local data = uq.cache.illustration.illustration_info
        for k2, v2 in ipairs(data.items) do
            if v2.state == 2 then --已激活
                is_active = true
                break
            end
        end
        if not is_active then
            uq.fadeInfo(StaticData["local_text"]["map.guide.des10"])
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.MAP_GUIDE_ATTR, {})
    end)
    self._panelReward:setTouchEnabled(true)
    self._panelReward:addClickEventListener(function(sender)
        local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
        if illustration_info.draw == 0 and illustration_info.state > 0 then
            network:sendPacket(Protocol.C_2_S_ILLUSTRATION_DRAW, {ill_id = self._curTabInfo.ident})
        end
    end)
    self._imgSelect:setTouchEnabled(true)
    self._imgSelect:addClickEventListener(function(sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.MAP_GUIDE_SCREEN, {array = self._curSelectArray})
    end)
    self._nodeAttr1:getChildByName("Image_state"):setTouchEnabled(true)
    self._nodeAttr1:getChildByName("Image_state"):addClickEventListener(function(sender)
        local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
        if illustration_info.state == 1 then
            network:sendPacket(Protocol.C_2_S_ILLUSTRATION_ACTIVE, {id = self._curTabInfo.ident})
        end
    end)
    for k, v in ipairs(self._attrArray) do
        v:getChildByName("Image_state"):setTag(k)
        v:getChildByName("Image_state"):setTouchEnabled(true)
        v:getChildByName("Image_state"):addClickEventListener(function(sender)
            local tag = sender:getTag()
            local illustration_info = uq.cache.illustration:getIllustrationInfoById(self._curTabInfo.ident)
            if illustration_info.growth[tag].growth_state == 1 then
                network:sendPacket(Protocol.C_2_S_ILLUSTRATION_ACTIVE_GROWTH, {ill_id = self._curTabInfo.ident, growth_id = tag})
            end
        end)
    end
end

function MapGuideInfo:_onTouchBegin(evt)
    if not self._panelSelect:isVisible() then
        return false
    end
    local touch_point = evt:getLocation()
    local size = self._selectBgImg:getContentSize()
    local pos = self._selectBgImg:convertToNodeSpace(touch_point)
    local rect=cc.rect(0, 0, size.width, size.height)
    if cc.rectContainsPoint(rect, pos) then
        for k, v in ipairs(self._typeSelectArray) do
            local size = v:getContentSize()
            local pos = v:convertToNodeSpace(touch_point)
            local rect=cc.rect(0, 0, size.width, size.height)
            if cc.rectContainsPoint(rect, pos) then
                self._curQualitySelect = v:getTag()
                v:getChildByName("Panel_press"):setVisible(true)
            end
        end
        return true
    end
    return false
end

function MapGuideInfo:_onTouchEnd(evt)
    self._panelSelect:setVisible(false)
    self._imgPointShow:setRotation(180)
    self:updateSelectDialog()
end

function MapGuideInfo:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)
    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched2), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable2), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView2), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function MapGuideInfo:cellSizeForTable2(view, idx)
    return 108, 142
end

function MapGuideInfo:numberOfCellsInTableView2(view)
    return #self._curTabArray
end

function MapGuideInfo:tableCellTouched2(view, cell, touch)
    local index = cell:getIdx() + 1
    self._curTabInfo = self._curTabArray[index]
    for k, v in ipairs(self._itemArray) do
        v:showSelect(v:getInfo().ident == self._curTabInfo.ident)
    end
    self:updateGeneralInfo()
end

function MapGuideInfo:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local euqip_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        euqip_item = MapGuideInfoItem:create()
        cell:addChild(euqip_item)
        euqip_item:setName("euqip_item")
        table.insert(self._itemArray, euqip_item)
    else
        euqip_item = cell:getChildByName("euqip_item")
    end
    local info = self._curTabArray[index]
    euqip_item:setVisible(info ~= nil)
    euqip_item:setInfo(info)
    euqip_item:showSelect(self._curTabInfo.ident == info.ident)
    return cell
end

function MapGuideInfo:dispose()
    self:removeProtocolData()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RELOAD_COLLECT_VIEW})
    MapGuideInfo.super.dispose(self)
end

return MapGuideInfo

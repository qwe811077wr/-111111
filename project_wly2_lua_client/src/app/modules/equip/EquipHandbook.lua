local EquipHandbook = class("EquipHandbook", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

EquipHandbook.RESOURCE_FILENAME = "equip/EquipHandbook.csb"
EquipHandbook.RESOURCE_BINDING  = {
    ["Text_equip_count_have"]                                               ={["varname"] = "_txtEquipHaveCount"},
    ["Text_equip_count_max"]                                                ={["varname"] = "_txtEquipMaxCount"},
    ["Button_screen"]                                                       ={["varname"] = "_btnScreen",["events"] = {{["event"] = "touch",["method"] = "_onBtnScreen",["sound_id"] = 0}}},
    ["Button_close"]                                                        ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnClose",["sound_id"] = 0}}},
    ["Button_channel"]                                                      ={["varname"] = "_btnFrom",["events"] = {{["event"] = "touch",["method"] = "_onBtnFrom",["sound_id"] = 0}}},
    ["Button_suit"]                                                         ={["varname"] = "_btnCheck2",["events"] = {{["event"] = "touch",["method"] = "_onBtnChange",["sound_id"] = 0}}},
    ["Button_attribute"]                                                    ={["varname"] = "_btnCheck1",["events"] = {{["event"] = "touch",["method"] = "_onBtnChange",["sound_id"] = 0}}},
    ["Text_screen_type"]                                                    ={["varname"] = "_txtScreenType"},
    ["Text_equip_name"]                                                     ={["varname"] = "_txtEquipName"},
    ["Text_suit_name"]                                                      ={["varname"] = "_txtSuitName"},
    ["Sprite_quality"]                                                      ={["varname"] = "_spriteEquipQuality"},
    ["Sprite_equip"]                                                        ={["varname"] = "_spriteEquipIcon"},
    ["Text_base"]                                                           ={["varname"] = "_txtAttributeBase"},
    ["Text_base_num"]                                                       ={["varname"] = "_txtAttributeBaseNum"},
    ["Text_quality"]                                                        ={["varname"] = "_txtEquipQuality"},
    ["Panel_tableview"]                                                     ={["varname"] = "_panelTableView"},
    ["Panel_attribute"]                                                     ={["varname"] = "_panelCheck1"},
    ["Panel_suit"]                                                          ={["varname"] = "_panelCheck2"},
    ["ScrollView_4"]                                                        ={["varname"] = "_scrollView"},
    ["Node_filter_panel"]                                                   ={["varname"] = "_nodeFilterPanel"},
}
function EquipHandbook:ctor(name, args)
    EquipHandbook.super.ctor(self, name, args)
    self._curTableViewIndex = 1
    self._curRightPageSelected = 1
    self._cellArray = {}
    self._screenResultEquipInfo = {}
    self._screenResultCondition = 1
    self._screenResultKind = 0

    EquipHandbook._RIGHT_PAGE_SELECT_TYPE = {
        ATTRIBUTE_TYPE = 1,
        SUIT_TYPE = 2,
    }

    EquipHandbook._FILTER_SELECT_CONDITION_TYPE = {
        PART_TYPE = 1,
        SUIT_TYPE = 2,
        QUALITY_TYPE = 3,
    }
    self._eventEquipLoadLog = '_onEquipLoadLog' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_LOAD_LOG_EQUIPMENT, handler(self, self._onEquipLoadLog), self._eventEquipLoadLog)
    self:setCallBack(handler(self, self._removeNetwork))
end

function EquipHandbook:init()
    self:setLayerColor()
    self:parseView()
    self:centerView()
    self:initData()
    self:updateScreenData()
    self:initTableView()
    self:updateRightPage()
    self._spriteEquipIcon:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(1, cc.p(0, 40)) , 2),
            cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, -40)) , 2)
        )
    ))
end

function EquipHandbook:initData()
    self._allQualityInfo = StaticData['types']['ItemQuality'][1]['Type']
    self._allEquipInfo = {}
    for k, v in pairs(StaticData['items']) do
        local data = {}
        data.type = uq.config.constant.COST_RES_TYPE.EQUIP
        data.id = v.ident
        data.xml = v
        table.insert(self._allEquipInfo, data)
    end
end

function EquipHandbook:insertDataToFilterEquipInfo(src_data)
    if src_data == nil then
        return
    end
    local data = {}
    data.type = src_data.type
    data.id = src_data.id
    data.xml = src_data.xml
    local cmp_data = src_data.xml.type
    if self._screenResultCondition == self._FILTER_SELECT_CONDITION_TYPE.SUIT_TYPE then
        cmp_data = src_data.xml.suitId
    elseif self._screenResultCondition == self._FILTER_SELECT_CONDITION_TYPE.QUALITY_TYPE then
        cmp_data = src_data.xml.qualityType
    end

    if cmp_data ~= nil and (cmp_data == self._screenResultKind or self._screenResultKind == 0) then
        table.insert(self._filterEquipInfo, data)
    end
end

function EquipHandbook:sortFilterEquipDataByType(a, b)
    if self._screenResultCondition == self._FILTER_SELECT_CONDITION_TYPE.PART_TYPE then
        if a.xml.type ~= b.xml.type then
            return tonumber(a.xml.type) > tonumber(b.xml.type)
        elseif a.xml.qualityType ~= b.xml.qualityType then
            return tonumber(a.xml.qualityType) > tonumber(b.xml.qualityType)
        end
    elseif self._screenResultCondition == self._FILTER_SELECT_CONDITION_TYPE.SUIT_TYPE then
        if StaticData['item_suit'][a.xml.suitId].qualityType ~= StaticData['item_suit'][b.xml.suitId].qualityType then
            return tonumber(StaticData['item_suit'][a.xml.suitId].qualityType) > tonumber(StaticData['item_suit'][b.xml.suitId].qualityType)
        elseif a.xml.type ~= b.xml.type then
            return tonumber(a.xml.type) > tonumber(b.xml.type)
        end
    elseif self._screenResultCondition == self._FILTER_SELECT_CONDITION_TYPE.QUALITY_TYPE then
        if a.xml.qualityType ~= b.xml.qualityType then
            return tonumber(a.xml.qualityType) > tonumber(b.xml.qualityType)
        elseif a.xml.type ~= b.xml.type then
            return tonumber(a.xml.type) > tonumber(b.xml.type)
        end
    end
    return tonumber(a.xml.ident) > tonumber(b.xml.ident)
end

function EquipHandbook:updateLogCount()
    local temp_table = {}
    for k, v in pairs(self._filterEquipInfo) do
        temp_table[v.id] = temp_table[v.id] == nil and 1 or temp_table[v.id] + 1
    end

    self._overlapIDArray = {}

    if self._equipIDArray == nil then
        return
    end

    for k, v in pairs(self._equipIDArray) do
        if temp_table[v.id] ~= nil and temp_table[v.id] >= 1 then
            local data = {}
            data.id = v.id
            table.insert(self._overlapIDArray, data)
        end
    end
end

function EquipHandbook:updateScreenData()
    self._filterEquipInfo = {}
    for k, v in pairs(self._allEquipInfo) do
        self:insertDataToFilterEquipInfo(v)
    end
    table.sort(self._filterEquipInfo,handler(self, self.sortFilterEquipDataByType))

    self:updateLogCount()
    self._txtEquipHaveCount:setString(tostring(#self._overlapIDArray))
    self._txtEquipMaxCount:setString(tostring(#self._filterEquipInfo))

    if self._tableView ~= nil then
        self._tableView:reloadData()
    end
end

function EquipHandbook:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
    self._panelTableView:addChild(self._tableView)
end

function EquipHandbook:cellSizeForTable(view, idx)
    return 540, 125
end

function EquipHandbook:numberOfCellsInTableView(view)
    return math.floor((#self._filterEquipInfo + 3) / 4)
end

function EquipHandbook:tableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 4 + 1
    for i = 0, 3, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local rect = cc.rect(0,0,item:getContentSize().width,item:getContentSize().height)
        if cc.rectContainsPoint(rect, pos) then
            if self._curTableViewIndex == index then
                return
            end
            if not self._filterEquipInfo[index] then
                return
            end
            if self._filterEquipInfo[index].type < 0 then
                return
            end
            for _,v in ipairs(self._cellArray) do
                v:setSelectImgVisible(false)
            end
            self._curTableViewIndex = index
            item:setSelectImgVisible(true)
            self:updateRightPage()
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            break
        end
        index = index + 1
    end
end

function EquipHandbook:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 3, 1 do
            local info = self._filterEquipInfo[index]
            local width = 0
            local height = 0
            local euqip_item = EquipItem:create()
            width = euqip_item:getContentSize().width
            height = euqip_item:getContentSize().height
            euqip_item:setScale(0.8)
            euqip_item:setPosition(cc.p((width * 0.5 + 20) * 0.8 + (width + 15) * 0.8 * i, 60))
            cell:addChild(euqip_item, 1)
            euqip_item:setName("item" .. i)
            euqip_item:setVisible(info ~= nil)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setImageGrayVisible(not self:isInPackage(info.id))
                if self._filterEquipInfo and info.id and self._filterEquipInfo[self._curTableViewIndex].id == info.id then
                    euqip_item:setSelectImgVisible(true)
                end
            end
            table.insert(self._cellArray, euqip_item)
            index = index + 1
        end
    else
        for i = 0, 3, 1 do
            local info = self._filterEquipInfo[index]
            local euqip_item = cell:getChildByName("item" .. i)
            if euqip_item == nil then
                return cell
            end
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setImageGrayVisible(not self:isInPackage(info.id))
                if self._filterEquipInfo and info.id and self._filterEquipInfo[self._curTableViewIndex].id == info.id then
                    euqip_item:setSelectImgVisible(true)
                end
            end
            euqip_item:setVisible(info ~= nil)
            index = index + 1
        end
    end
    return cell
end

function EquipHandbook:isInPackage(id)
    if self._overlapIDArray == nil then
        return false
    end
    for _,v in pairs(self._overlapIDArray) do
        if v.id == id then
            return true
        end
    end
    return false
end

function EquipHandbook:updateRightPage()
    local equip_info = self._filterEquipInfo[self._curTableViewIndex]
    if equip_info == nil then
        return
    end
    self._txtEquipName:setString(equip_info.xml.name)
    self._spriteEquipIcon:setTexture("img/common/item/" .. equip_info.xml.icon)
    local item_quality_info = self._allQualityInfo[equip_info.xml.qualityType]
    if item_quality_info then
        self._txtEquipName:setTextColor(uq.parseColor(item_quality_info.color))
        self._spriteEquipQuality:setTexture("img/equip/" .. item_quality_info.itemStamp)
        self._txtEquipQuality:setString(string.format(StaticData['local_text']['equip.item.quality'], item_quality_info.name, item_quality_info.ident))
        self._txtEquipQuality:setTextColor(uq.parseColor(item_quality_info.color))
    end
    local effect_info = StaticData['types'].Effect[1].Type[equip_info.xml.effectType]
    if effect_info and effect_info.name then
        self._txtAttributeBase:setString(effect_info.name)
    end
    self._txtAttributeBaseNum:setString("+" .. equip_info.xml.effectValue)
    if equip_info.xml.suitId then
        self._txtSuitName:setString(StaticData['item_suit'][equip_info.xml.suitId].name)
        self._txtSuitName:setTextColor(uq.parseColor(self._allQualityInfo[StaticData['item_suit'][equip_info.xml.suitId].qualityType].color))
    end
    self:updateScroll()
    self:showRightPanelByType(self._curRightPageSelected)
end

function EquipHandbook:updateScroll()
    self._scrollView:removeAllChildren()
    local equip_info = self._filterEquipInfo[self._curTableViewIndex]
    if equip_info.xml.suitId then
        local suit_data = StaticData['item_suit'][equip_info.xml.suitId]
        local arr_suit = string.split(suit_data.suitEffect, '|')
        local height = #arr_suit * 30 + 22
        local size = self._scrollView:getContentSize()
        if size.height < height then
            self._scrollView:setInnerContainerSize(cc.size(size.width, height))
        end
        local pos_y = math.ceil(size.height, height)
        for k, v in ipairs(arr_suit) do
            local str_info = string.split(v, ',')
            local text = self:getLabel(20)
            text:setString(string.format(StaticData['local_text']['equip.suit.cur.num'], str_info[1]))
            text:setPosition(cc.p(10, pos_y))
            self._scrollView:addChild(text)

            local type_info = StaticData['types'].Effect[1].Type[tonumber(str_info[2])]
            local text = self:getLabel(20)
            local value = uq.cache.generals:getNumByEffectType(tonumber(str_info[2]), tonumber(str_info[3]))
            text:setString(type_info.name .. "  +" ..value)
            text:setPosition(cc.p(90, pos_y))
            self._scrollView:addChild(text)
            pos_y = pos_y - 30
        end
    end
end

function EquipHandbook:getLabel(size, color, font)
    size = size or 26
    font = font or "font/hwkt.ttf"
    color = color or "#ffffff"
    local lbl_desc = ccui.Text:create()
    lbl_desc:setFontSize(size)
    lbl_desc:setFontName(font)
    lbl_desc:setTextColor(uq.parseColor(color))
    lbl_desc:setAnchorPoint(cc.p(0, 0.5))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    return lbl_desc
end

function EquipHandbook:_onBtnChange(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    if event.target == self["_btnCheck" .. self._curRightPageSelected] then
        return
    end
    for i = 1, 2 do
        if event.target == self["_btnCheck" .. i] then
            self._curRightPageSelected = i
            break
        end
    end
    self:showRightPanelByType(self._curRightPageSelected)
end

function EquipHandbook:_onBtnClose(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
    self:runCloseAction()
end

function EquipHandbook:_onBtnFrom(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, self._filterEquipInfo[self._curTableViewIndex])
end

function EquipHandbook:_onBtnScreen(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._nodeFilterPanel:removeAllChildren()
    local filter_panel = uq.createPanelOnly("equip.EquipHandbookFilterPanel")
    filter_panel:setData(self, self._screenResultCondition, self._screenResultKind)
    self._nodeFilterPanel:addChild(filter_panel)
end

function EquipHandbook:_onEquipLoadLog(msg)
    local data = msg.data
    if data.logs and next(data.logs) ~= nil then
        self._equipIDArray = {}
        for _,v in pairs(data.logs) do
            local data = {}
            data.id = v.eqid
            table.insert(self._equipIDArray, data)
        end
        self:updateScreenData()
        self:updateRightPage()
    end
end

function EquipHandbook:_removeNetwork()
    network:removeEventListenerByTag(self._eventEquipLoadLog)
end

function EquipHandbook:showRightPanelByType(type)
    for i = 1 , 2 do
        local is_show = type == i
        self["_btnCheck" .. i]:setEnabled(is_show == false)
        local text_color = uq.parseColor(is_show == false and "#8FC8DB" or "#FFFFFF")
        self["_btnCheck" .. i]:setTitleColor(text_color)
        self["_panelCheck" .. i]:setVisible(is_show)
    end
end

function EquipHandbook:setFilterResult(condition_result, kind_result, name)
    self._screenResultCondition = condition_result
    self._screenResultKind = kind_result
    name = name or StaticData["local_text"]["map.guide.des1"]
    self._txtScreenType:setString(name)
    self._curTableViewIndex = 1
    self:updateScreenData()
    self:updateRightPage()
end

return EquipHandbook

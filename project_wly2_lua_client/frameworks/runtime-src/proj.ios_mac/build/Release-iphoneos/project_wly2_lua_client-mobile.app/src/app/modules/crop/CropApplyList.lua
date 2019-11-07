local CropApplyList = class("CropApplyList", require('app.base.PopupBase'))

CropApplyList.RESOURCE_FILENAME = "crop/CropApplyList.csb"
CropApplyList.RESOURCE_BINDING = {
    ["Panel_1"]      = {["varname"] = "_panelList"},
    ["CheckBox_1"]   = {["varname"] = "_checkBoxYes"},
    ["CheckBox_1_0"] = {["varname"] = "_checkBoxNo"},
    ["Image_3"]      = {["varname"] = "_imgEdit"},
    ["Button_2"]     = {["varname"] = "_btnClose"},
    ["Button_1"]     = {["varname"] = "_btnAdd",["events"] = {{["event"] = "touch",["method"] = "onAdd"}}},
    ["Button_1_0"]   = {["varname"] = "_btnSub",["events"] = {{["event"] = "touch",["method"] = "onSub"}}},
}

function CropApplyList:onCreate()
    CropApplyList.super.onCreate(self)
    self._allApplyListData = {}
    self:centerView()
    self:setLayerColor()
    self:parseView()
    self:initLayer()
    self._maxLvl = 260
    local tab_build = StaticData['buildings'].CastleMap[0]
    if tab_build and tab_build.maxLevel then
        self._maxLvl = tab_build.maxLevel
    end
    self._curCropInfo = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._autoJoin = self._curCropInfo.auto_join
    self._curLevelLimit = self._curCropInfo.limit_value
    self._editBox:setText(tostring(self._curLevelLimit))

    self._checkBoxYes:addEventListener(handler(self, self.onCheckEventYes))
    self._checkBoxNo:addEventListener(handler(self, self.onCheckEventNo))

    if self._autoJoin > 0 then
        self._checkBoxNo:setSelected(false)
        self._checkBoxYes:setSelected(true)
    else
        self._checkBoxNo:setSelected(true)
        self._checkBoxYes:setSelected(false)
    end
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)

    network:sendPacket(Protocol.C_2_S_LOAD_ALL_APPLY_MEMBER)

    self._eventRefreshTag = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY_LIST .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY_LIST, handler(self, self._onApplyRefresh), self._eventRefreshTag)
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_END, handler(self, self._onAllApplyMemberEnd), '_onAllApplyMemberEnd')
end

function CropApplyList:onExit()
    services:removeEventListenersByTag(self._eventRefreshTag)
    network:removeEventListenerByTag('_onAllApplyMemberEnd')
    CropApplyList.super:onExit()
end

function CropApplyList:_onApplyRefresh()
    self:refreshData()
end

function CropApplyList:_onAllApplyMemberEnd(msg)
    self:refreshData()
end

function CropApplyList:onCheckEventYes(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        self._checkBoxNo:setSelected(false)
        self._autoJoin = 1
        self:sendLimit()
    elseif eventType == ccui.CheckBoxEventType.unselected then
        self._checkBoxNo:setSelected(true)
        self._autoJoin = 0
        self:sendLimit()
    end
end

function CropApplyList:onCheckEventNo(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        self._checkBoxYes:setSelected(false)
        self._autoJoin = 0
        self:sendLimit()
    elseif eventType == ccui.CheckBoxEventType.unselected then
        self._checkBoxYes:setSelected(true)
        self._autoJoin = 1
        self:sendLimit()
    end
end

function CropApplyList:refreshData()
    self._allApplyListData = uq.cache.crop._allApplyInfo
    self._listView:reloadData()
end

function CropApplyList:initLayer()
    local viewSize = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelList:addChild(self._listView)

    local size = self._imgEdit:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width - 5, size.height), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("font/hwkt.ttf")
    self._editBox:setFontSize(22)
    self._editBox:setMaxLength(3)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._editBox:setPlaceholderFontName("Arial")
    self._editBox:setPlaceholderFontSize(22)
    self._editBox:setPosition(cc.p(size.width / 2 + 5, size.height / 2))
    self._imgEdit:addChild(self._editBox)
end

function CropApplyList:editboxHandle(event, sender)
    if event == "changed" then
        local str = self._editBox:getText()
        if str ~= "" and str ~= nil then
            local str_str = self:dealChar(str)
            self._editBox:setText(str_str)
            self._curLevelLimit = tonumber(str_str)
        end
    elseif event == "ended" then
        local str = self._editBox:getText()
        if str == "" or str == nil then
            self._editBox:setText("0")
            self._curLevelLimit = 0
        else
            local str_str = self:dealChar(str)
            local str_num = math.min(self._maxLvl, tonumber(str_str))
            if str_num < 15 then
                str_num = 0
            end
            self._editBox:setText(tostring(str_num))
            self._curLevelLimit = str_num
        end
        self:sendLimit()
    end
end

function CropApplyList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CropApplyList:cellSizeForTable(view, idx)
    return 840, 75
end

function CropApplyList:numberOfCellsInTableView(view)
    return #self._allApplyListData
end

function CropApplyList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("crop.CropApplyListCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(self._allApplyListData[index], index)

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))
    --cellItem:setData(self._dataList[index])

    return cell
end

function CropApplyList:onAdd(event)
    if event.name == "ended" then
        self._curLevelLimit = math.min(math.max(self._curLevelLimit + 1, 15), self._maxLvl)
        self._editBox:setText(tostring(self._curLevelLimit))
        self:sendLimit()
    end
end

function CropApplyList:onSub(event)
    if event.name == "ended" then
        self._curLevelLimit = self._curLevelLimit - 1
        if self._curLevelLimit < 15 then
            self._curLevelLimit = 0
        end
        self._editBox:setText(tostring(self._curLevelLimit))
        self:sendLimit()
    end
end

function CropApplyList:dealChar(str)
    local len = #str
    local str_str = ""
    for i = 1, len do
        local cur_byte = string.byte(str, i)
        if cur_byte >= 48 and cur_byte <= 59 then
            str_str = str_str .. string.sub(str, i, i)
        end
    end
    if str_str == "" then
        return "0"
    end
    return str_str
end

function CropApplyList:sendLimit(str)
    local data = {
        auto_join = self._autoJoin,
        limit_type = Protocol.CROP_JOIN_LIMIT.LEVEL,
        limit_value = self._curLevelLimit
    }
    network:sendPacket(Protocol.C_2_S_JOIN_SETTING, data)
end

return CropApplyList
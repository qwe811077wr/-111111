local RetainerAdd = class("RetainerAdd", require("app.base.TableViewBase"))

RetainerAdd.RESOURCE_FILENAME = "retainer/RetainerAdd.csb"
RetainerAdd.RESOURCE_BINDING  = {
    ["Node_1/Panel_2"]              = {["varname"] = "_pnlList"},
    ["Node_1/Image_2"]              = {["varname"] = "_imgBg"},
    ["Node_1/Button_1"]             = {["varname"] = "_btnSearch"},
    ["Node_1/Button_2"]             = {["varname"] = "_btnNext"},
}

function RetainerAdd:ctor(name, args)
    RetainerAdd.super.ctor(self)
end

function RetainerAdd:init()
    self:parseView()
    self._listData = {}
    self._retainerType = {
        [3] = "courtier",
        [4] = "suzerain",
    }
    self._msgType = {
        [0] = "suzerain",
        [1] = "courtier",
    }
    self._strType ={
        suzerain = uq.config.constant.RETAINER_LIST.SUZERAIN_ADD,
        courtier = uq.config.constant.RETAINER_LIST.COURTIER_ADD,
    }
    self._strlayer = self._retainerType[3]
    if self._strKey then
        self._strlayer = self._retainerType[self._strKey]
    end
    self._listType = self._strType[self._strlayer]
    self._listData = self:dealData()
    self:initLayer()
    self._eventZongList = services.EVENT_NAMES.ON_ZONG_LOAD_LIST .. tostring(self)
    self._eventZongApply = services.EVENT_NAMES.ON_ZONG_APPLY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_LOAD_LIST, handler(self, self._onZongLoadList), self._eventZongList)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_APPLY, handler(self, self._onZongApply), self._eventZongApply)
    if next(self._listData) == nil then
        network:sendPacket(Protocol.C_2_S_ZONG_LOAD_LIST, {list_type = self._listType})
    end
end

function RetainerAdd:setStrLayer(idx)
    self._strKey = idx
end

function RetainerAdd:initLayer()
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(-15, 0))
    self._listView:setAnchorPoint(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)

    local size = self._imgBg:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("Arial")
    self._editBox:setFontSize(20)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBox:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBox:setPlaceholderFontName("Arial")
    self._editBox:setPlaceholderFontSize(20)
    self._editBox:setMaxLength(7)
    self._editBox:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._imgBg:addChild(self._editBox)
    if self._strlayer == "courtier" then
        self._editBox:setPlaceHolder(StaticData['local_text']['retainer.please.put'])
    else
        self._editBox:setPlaceHolder(StaticData['local_text']['retainer.please.put.name'])
    end

    self._btnSearch:addClickEventListenerWithSound(function ()
        local str = self._editBox:getText()
        if uq.isLimiteName(str) then
            uq.fadeInfo(StaticData["local_text"]["retainer.please.name"])
            return
        end
        if uq.hasKeyWord(str) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        --send
    end)
    self._btnNext:addClickEventListenerWithSound(function ()
        local time = uq.cache.retainer:getListRefreshTime(self._listType)
        if time > 0 then
            uq.fadeInfo(string.format(StaticData["local_text"]["retainer.time.refresh"], time))
            return
        end
        local refresh_type = 0
        if self._strlayer == "courtier" then
            refresh_type = 1
        end
        network:sendPacket(Protocol.C_2_S_ZONG_REFRESH, {refresh_type = refresh_type})
    end)
end

function RetainerAdd:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RetainerAdd:cellSizeForTable(view, idx)
    return 1100, 130
end

function RetainerAdd:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("retainer.AddItems")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setTag(1000)
    cell_item:setData(self._listData[index], true, self._strlayer == "suzerain")
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function RetainerAdd:numberOfCellsInTableView(view)
    if self._listData then
        return #self._listData
    else
        return 0
    end
end

function RetainerAdd:_onZongLoadList(evt)
    local data = evt.data
    if data.list_type == self._listType then
        self._listData = self:dealData()
        self._listView:reloadData()
    end
end

function RetainerAdd:_onZongApply(evt)
    local data = evt.data
    if self._msgType[data.apply_type] == self._strlayer then
        uq.fadeInfo(StaticData["local_text"]["retainer.succeed.add"])
    end
end

function RetainerAdd:dealData()
    local type_list = self._strType[self._strlayer]
    local tab = uq.cache.retainer:getListDataByType(type_list)
    if tab and tab.roles then
        return tab.roles
    end
    return {}
end

function RetainerAdd:onExit()
    services:removeEventListenersByTag(self._eventZongList)
    services:removeEventListenersByTag(self._eventZongApply)
    RetainerAdd.super:onExit()
end

return RetainerAdd
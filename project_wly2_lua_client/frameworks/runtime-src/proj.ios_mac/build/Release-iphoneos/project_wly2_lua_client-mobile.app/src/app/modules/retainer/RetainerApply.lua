local RetainerApply = class("RetainerApply", require("app.base.TableViewBase"))

RetainerApply.RESOURCE_FILENAME = "retainer/RetainerList.csb"
RetainerApply.RESOURCE_BINDING  = {
    ["Node_1"]                      = {["varname"] = "_nodeBg"},
    ["Panel_1"]                     = {["varname"] = "_pnlList"},
    ["Panel_2"]                     = {["varname"] = "_pnlApply"},
    ["Panel_2/Button_1"]            = {["varname"] = "_btn1"},
    ["Panel_2/Button_2"]            = {["varname"] = "_btn2"},
    ["Panel_2/Image_1"]             = {["varname"] = "_img1"},
    ["Panel_2/Image_1_0"]           = {["varname"] = "_img2"},
}

function RetainerApply:ctor(name, args)
    RetainerApply.super.ctor(self)
end

function RetainerApply:init()
    self._typeList = {
        [1] = "suzerain",
        [2] = "courtier",
    }
    self._typeConstant = {
        suzerain = uq.config.constant.RETAINER_LIST.SUZERAIN_APPLY,
        courtier = uq.config.constant.RETAINER_LIST.COURTIER_APPLY,
    }
    self._selectBtn = 1
    self._listData = self:dealData()
    self._nodeBg:setVisible(false)
    self._pnlApply:setVisible(true)
    self:parseView()
    self:initLayer()
    self:refreshLayer()
    self._eventZongList = services.EVENT_NAMES.ON_ZONG_LOAD_LIST .. tostring(self)
    self._eventZongHandle = services.EVENT_NAMES.ON_ZONG_HANDLE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_LOAD_LIST, handler(self, self._onZongLoadList), self._eventZongList)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_HANDLE, handler(self, self._onZongHandle), self._eventZongHandle)
    if next(self._listData) == nil then
        network:sendPacket(Protocol.C_2_S_ZONG_LOAD_LIST, {list_type = self._typeConstant.suzerain})
        network:sendPacket(Protocol.C_2_S_ZONG_LOAD_LIST, {list_type = self._typeConstant.courtier})
    end
end

function RetainerApply:initLayer()
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setAnchorPoint(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)
    for i = 1, 2 do
        self["_btn" .. i]:addClickEventListenerWithSound(function ()
            if self._selectBtn == i then
                return
            end
            self._selectBtn = i
            self:refreshLayer()
        end)
    end
end

function RetainerApply:refreshLayer()
    for i = 1, 2 do
        self["_btn" .. i]:setEnabled(self._selectBtn ~= i)
        self["_img" .. i]:getChildByName('Image_6'):setVisible(self._selectBtn == i)
        self["_img" .. i]:getChildByName('Image_6_0'):setVisible(self._selectBtn ~= i)
    end
    --赋值
    self._listData = self:dealData()
    self._listView:reloadData()
end

function RetainerApply:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RetainerApply:cellSizeForTable(view, idx)
    return 1100, 130
end

function RetainerApply:tableCellAtIndex(view, idx)
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
    cell_item:setData(self._listData[index], false, self._typeList[self._selectBtn] == "suzerain")
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function RetainerApply:numberOfCellsInTableView(view)
    if self._listData then
        return #self._listData
    else
        return 0
    end
end

function RetainerApply:dealData()
    local type_list = self._typeList[self._selectBtn]
    local type_constant = self._typeConstant[type_list]
    local tab = uq.cache.retainer:getListDataByType(type_constant)
    if tab and tab.roles then
        return tab.roles
    end
    return {}
end

function RetainerApply:_onZongLoadList(evt)
    local data = evt.data
    local type_list = self._typeList[self._selectBtn]
    if data.list_type == self._typeConstant[type_list] then
        self._listData = self:dealData()
        self._listView:reloadData()
    end
end

function RetainerApply:_onZongHandle(evt)
    local type_list = self._typeList[self._selectBtn]
    if evt.data == self._typeConstant[type_list] then
        self._listData = self:dealData()
        self._listView:reloadData()
    end
end

function RetainerApply:onExit()
    services:removeEventListenersByTag(self._eventZongList)
    services:removeEventListenersByTag(self._eventZongHandle)
    RetainerApply.super:onExit()
end


return RetainerApply
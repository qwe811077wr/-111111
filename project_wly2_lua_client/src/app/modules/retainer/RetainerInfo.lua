local RetainerInfo = class("RetainerInfo", require("app.base.TableViewBase"))

RetainerInfo.RESOURCE_FILENAME = "retainer/RetainerInfo.csb"
RetainerInfo.RESOURCE_BINDING  = {
    ["Node_1/left_pnl"]              = {["varname"] = "_pnlLeft"},
    ["Node_1/right_pnl"]             = {["varname"] = "_pnlRight"},
    ["Node_1/Button_1"]              = {["varname"] = "_btn1"},
    ["Node_1/Button_1_0"]            = {["varname"] = "_btn2"},
    ["Node_1/Button_1_1"]            = {["varname"] = "_btn3"},
    ["Node_1/Panel_3"]               = {["varname"] = "_pnlBtn1"},
    ["Node_1/Panel_3_0"]             = {["varname"] = "_pnlBtn2"},
    ["Node_1/Panel_3_1"]             = {["varname"] = "_pnlBtn3"},
    ["Node_1/Image_3"]               = {["varname"] = "_imgIconBg"},
    ["Node_1/Image_4"]               = {["varname"] = "_imgIcon"},
    ["Node_1/Button_4"]              = {["varname"] = "_btnDel"},
    ["Node_1/like_pnl/Button_1"]     = {["varname"] = "_btnLike"},
    ["Node_1/Text_7"]                = {["varname"] = "_txtName"},
    ["Node_1/like_pnl"]              = {["varname"] = "_pnlLike"},
    ["Node_1/like_pnl/Text_7_0"]     = {["varname"] = "_txtLike"},
}

function RetainerInfo:ctor(name, args)
    RetainerInfo.super.ctor(self)
end

function RetainerInfo:init()
    self._leftData = {}
    self._infoSelect = {}
    self._rightData = {}
    self._rightListData = {}
    self._selectBtn = 1
    self._delectCost = 100
    self._typeList = {
        [1] = "friend",
        [2] = "retainer",
        [3] = "black",
    }
    self:parseView()
    self:initLayer()
    self:refreshLeftyLayer()
    self._eventZongChange = services.EVENT_NAMES.ON_ZONG_RETAINER_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_RETAINER_CHANGE, handler(self, self._onZongRetainerChange), self._eventZongChange)
end

function RetainerInfo:initLayer()
    local view_size = self._pnlLeft:getContentSize()
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
    self._pnlLeft:addChild(self._listView)

    local view_size = self._pnlRight:getContentSize()
    self._listViewRight = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listViewRight:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listViewRight:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listViewRight:setPosition(cc.p(0, 0))
    self._listViewRight:setAnchorPoint(cc.p(0, 0))
    self._listViewRight:setDelegate()
    self._listViewRight:registerScriptHandler(handler(self, self.tableCellTouchedRight), cc.TABLECELL_TOUCHED)
    self._listViewRight:registerScriptHandler(handler(self, self.cellSizeForTableRight), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listViewRight:registerScriptHandler(handler(self, self.tableCellAtIndexRight), cc.TABLECELL_SIZE_AT_INDEX)
    self._listViewRight:registerScriptHandler(handler(self, self.numberOfCellsInTableViewRight), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listViewRight:reloadData()
    self._pnlRight:addChild(self._listViewRight)
    for i = 1, 3 do
        self["_btn" .. i]:addClickEventListenerWithSound(function ()
            if self._selectBtn == i then
                return
            end
            self._selectBtn = i
            self:refreshLeftyLayer()
        end)
    end
    self._btnDel:addClickEventListenerWithSound(function ()
        local str = StaticData["local_text"]["retainer.courtier"]
        local dispart_type = 1
        if uq.cache.retainer:isOwnSuzerain(self._rightData.id) then
            str = StaticData["local_text"]["retainer.king"]
            dispart_type = 0
        end
        local data = {}
        local time = self._rightData.offline_time or 0
        if time > 259200 then
            data = {
                content = string.format(StaticData["local_text"]["retainer.relive"], str),
                confirm_callback = function()
                    self:sendMsgDispart(dispart_type, self._rightData.id)
                end
            }
        else
            data = {
                content = string.format(StaticData["local_text"]["retainer.relive.cost"], str, '<img img/common/ui/03_0003.png>', tostring(self._delectCost)),
                confirm_callback = function()
                    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._delectCost) then
                        uq.fadeInfo(string.format(StaticData["local_text"]["retainer.not.gold"], tostring(self._delectCost)))
                        return
                    end
                    self:sendMsgDispart(dispart_type, self._rightData.id)
                end
            }
        end
        uq.addConfirmBox(data)
    end)
    self._btnLike:addClickEventListenerWithSound(function ()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.RETAINER_LIKE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, info = self._infoSelect})
    end)
end

function RetainerInfo:sendMsgDispart(dispart_type, role_id)
    local data = {
        dispart_type = dispart_type, -- 0 zong 1 s
        role_id = role_id,
    }
    network:sendPacket(Protocol.C_2_S_ZONG_DISPART, data)
end

function RetainerInfo:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    self:refreshRightLayer(index)
end

function RetainerInfo:cellSizeForTable(view, idx)
    return 530, 110
end

function RetainerInfo:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("retainer.InfoLeftItems")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setName("itemup" .. index)
    cell_item:setTag(1000)
    cell_item:setData(self._leftData[index])
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function RetainerInfo:numberOfCellsInTableView(view)
    if self._leftData then
        return #self._leftData
    else
        return 0
    end
end

function RetainerInfo:tableCellTouchedRight(view, cell)
    local index = cell:getIdx() + 1
end

function RetainerInfo:cellSizeForTableRight(view, idx)
    return 560, 130
end

function RetainerInfo:tableCellAtIndexRight(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("retainer.InfoRightItems")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setTag(1000)
    cell_item:setData(self._rightListData[index])
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function RetainerInfo:numberOfCellsInTableViewRight(view)
    if self._rightListData then
        return #self._rightListData
    else
        return 0
    end
end

function RetainerInfo:_onZongRetainerChange()
    if self._typeList[self._selectBtn] == "retainer" then
        self:refreshLeftyLayer()
    end
end

function RetainerInfo:refreshBtnShow()
    for i = 1, 3 do
        self["_btn" .. i]:setEnabled(self._selectBtn ~= i)
        self["_pnlBtn" .. i]:getChildByName("Image_2"):setVisible(self._selectBtn ~= i)
        self["_pnlBtn" .. i]:getChildByName("Image_2_0"):setVisible(self._selectBtn == i)
    end
end

function RetainerInfo:refreshLeftyLayer()
    self._leftData = self:getTypeDataByIndex()
    self:refreshBtnShow()
    self._listView:reloadData()
    self:refreshRightLayer()
end

function RetainerInfo:refreshRightLayer(index)
    local idx = index or 1
    self._infoSelect = self._leftData[idx] or {}
    self._rightData = {}
    self._rightListData = {}
    if self._infoSelect then
        if self._infoSelect.info then
            self._rightData = self._infoSelect.info[1]
        end
        if self._infoSelect.events then
        --    self._rightListData = self._infoSelect.events
        end
    end
    self._imgIconBg:setVisible(next(self._rightData) ~= nil)
    self._imgIcon:setVisible(next(self._rightData) ~= nil)
    self._btnDel:setVisible(next(self._rightData) ~= nil)
    self._txtName:setVisible(next(self._rightData) ~= nil)
    self._pnlLike:setVisible(next(self._rightData) ~= nil)
    if next(self._rightData) ~= nil then
        self._txtName:setString(self._rightData.name)
        local intimacy = 0
        if self._infoSelect and self._infoSelect.intimacy then
            intimacy = self._infoSelect.intimacy
        end
        self._txtLike:setString(tostring(intimacy))
    end
    self._listViewRight:reloadData()
end

function RetainerInfo:getTypeDataByIndex()
    if self._typeList[self._selectBtn] == "retainer" then
        return uq.cache.retainer:getAllRetainerInfo()
    end
    return {}
end

function RetainerInfo:onExit()
    services:removeEventListenersByTag(self._eventZongChange)
    RetainerInfo.super:onExit()
end

return RetainerInfo
local FriendList = class("FriendList", require('app.base.PopupBase'))

FriendList.RESOURCE_FILENAME = "chat/FriendList.csb"
FriendList.RESOURCE_BINDING = {
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Panel_1"]  = {["varname"] = "_panelList"},
}

function FriendList:ctor(name, params)
    FriendList.super.ctor(self, name, params)
end

function FriendList:init()
    self._chatData = nil

    self:parseView()
    self:setLayerColor(0.4)
    self:centerView()
    self:initChatList()
end


function FriendList:initChatList()
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
end

function FriendList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function FriendList:cellSizeForTable(view, idx)
    if idx then
        return 919, 94
    end
end

function FriendList:numberOfCellsInTableView(view)
    return 10
end

function FriendList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("chat.FriendListCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))
    cellItem:setTag(1000)
    --cellItem:setData(self._chatData[index])
    return cell
end


function FriendList:setData(data)
end

function FriendList:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function FriendList:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return FriendList
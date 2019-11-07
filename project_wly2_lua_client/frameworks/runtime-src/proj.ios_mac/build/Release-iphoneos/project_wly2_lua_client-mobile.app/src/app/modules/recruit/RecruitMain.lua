local RecruitMain = class("RecruitMain", require('app.modules.common.BaseViewWithHead'))

RecruitMain.RESOURCE_FILENAME = "recruit/RecruitMain.csb"
RecruitMain.RESOURCE_BINDING = {
    ["surplus_txt"]                     = {["varname"] = "_txtSurplus"},
    ["Node_7"]                          = {["varname"] = "_nodeBtn"},
    ["refresh_btn"]                     = {["varname"] = "_btnRefresh"},
    ["cion_txt"]                        = {["varname"] = "_txtCion"},
    ["Panel_14"]                        = {["varname"] = "_pnlList"},
    ["cion_node"]                       = {["varname"] = "_nodeCion"},
}

function RecruitMain:init()
    self:centerView()
    self:parseView()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.TAVERN_VIEW)
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.RECRUIT)
    self._costNum = 200
    self.listData = uq.cache.recruit:getRecruitListData()
    self._allUi = {}
    self:initLayer()
    self:refreshDownLayer()
    self._eventTagRefresh = services.EVENT_NAMES.ON_RECRUIT_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_RECRUIT_REFRESH, handler(self, self.refreshLayer), self._eventTagRefresh)
    self._eventTagNew = services.EVENT_NAMES.ON_RECRUIT_GENERALS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_RECRUIT_GENERALS, handler(self, self.newGeneralsShow), self._eventTagNew)
    self._timerDec = "refreshTime" .. tostring(self)
    uq.TimerProxy:removeTimer(self._timerDec)
    uq.TimerProxy:addTimer(self._timerDec, handler(self, self.refreshTime), 0.5, -1)
    self:adaptBgSize()
end

function RecruitMain:onCreate()
    RecruitMain.super.onCreate(self)
end

function RecruitMain:initLayer()
    self._txtCion:setString(tostring(self._costNum))
    local viewSize = self._pnlList:getContentSize()
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
    self._pnlList:addChild(self._listView)
    self._btnRefresh:addClickEventListenerWithSound(function()
        if uq.cache.recruit:getSurplusTimes() <= 0 then
            uq.fadeInfo(StaticData["local_text"]["recruit.not.times"])
            return
        end
        if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._costNum) then
            uq.fadeInfo(StaticData["local_text"]["label.no.enough.res"])
            return
        end
        network:sendPacket(Protocol.C_2_S_JIUGUAN_REFRESH, {})
    end)
end

function RecruitMain:refreshLayer()
    self.listData = uq.cache.recruit:getRecruitListData()
    self._listView:reloadData()
    self:refreshDownLayer()
end

function RecruitMain:newGeneralsShow(msg)
    uq.cache.recruit:showNewRecruitGenerals()
end

function RecruitMain:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RecruitMain:cellSizeForTable(view, idx)
    return 1334, 85
end

function RecruitMain:numberOfCellsInTableView(view)
    return #self.listData
end

function RecruitMain:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil
    if not cell then
        cell = cc.TableViewCell:new()
        cellItem = uq.createPanelOnly("recruit.RecruitItems")
        cell:addChild(cellItem)
        table.insert(self._allUi, cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end
    cellItem:setTag(1000)

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))
    cellItem:setData(self.listData[index], index)
    return cell
end

function RecruitMain:ShowNewGenerals()
    uq.cache.recruit:showNewRecruitGenerals()
    self:refreshBoxs()
    self:refreshDownLayer()
end

function RecruitMain:refreshBoxs()
    for i, v in ipairs(self._allUi) do
        v:refreshBoxs()
    end
end

function RecruitMain:refreshDownLayer()
    local surplus = uq.cache.recruit:getSurplusTimes()
    self._txtSurplus:setString(tostring(surplus))
    local color = surplus > 0 and "#F9FA87" or "#FF5353"
    self._txtSurplus:setTextColor(uq.parseColor(color))
end

function RecruitMain:refreshTime()
    for i, v in ipairs(self._allUi) do
        v:refreshTimes()
    end
end

function RecruitMain:dispose()
    uq.TimerProxy:removeTimer(self._timerDec)
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventTagNew)
    RecruitMain.super.dispose(self)
end

return RecruitMain
local LegionCampaignInfo = class("LegionCampaignInfo", require('app.modules.common.BaseViewWithHead'))

LegionCampaignInfo.RESOURCE_FILENAME = "crop/LegionCampaignInfo.csb"
LegionCampaignInfo.RESOURCE_BINDING = {
    ["Panel_5"]      = {["varname"] = "_panelList"},
    ["Panel_11"]     = {["varname"] = "_panel"},
    ["img_bg_adapt"] = {["varname"] = "_imgBg"},
    ["Button_4"]     = {["varname"] = "_btnLeft", ["events"] = {{["event"] = "touch",["method"] = "onLeft"}}},
    ["Button_5"]     = {["varname"] = "_btnRight", ["events"] = {{["event"] = "touch",["method"] = "onRight"}}},
}
function LegionCampaignInfo:ctor(name, params)
    LegionCampaignInfo.super.ctor(self, name, params)

    self._func = params.func
    self._curCampaign = {}
    self._bossData = {}
    self._allLegionCampaign = uq.cache.crop._allLegionCampaign

    self:refreshData()
    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
end

function LegionCampaignInfo:init()
    self:centerView()

    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.GESTE, uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setCloseBack(handler(self, self.onClose))

    self:parseView()
    self:initTableView()
    self:adaptBgSize()
end

function LegionCampaignInfo:onCreate()
    LegionCampaignInfo.super.onCreate(self)

    self._eventTag1 = services.EVENT_NAMES.ON_CUR_LEGION_CAMPAIGN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CUR_LEGION_CAMPAIGN, handler(self, self.getCurCampaign), self._eventTag1)

    self._eventTag2 = services.EVENT_NAMES.ON_REFRESH_BOSS_STATE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_BOSS_STATE, handler(self, self.onRefreshBossState), self._eventTag2)
end

function LegionCampaignInfo:dispose()
    if self._func then
        self._func()
    end
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventTag2)

    LegionCampaignInfo.super.dispose(self)
end

function LegionCampaignInfo:initTableView()
    local viewSize = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelList:addChild(self._listView)
end

function LegionCampaignInfo:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local cell_item = cell:getChildByTag(1000)
    if cell_item._curBossState == uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.NOT_KILL then
        uq.fadeInfo(StaticData['local_text']['legion.campaign.boss.no.killed'])
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.LEGION_CAMPAIGN_BOSS, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    local data = self._curCampaign[index]
    panel:setData(data, index)
end

function LegionCampaignInfo:cellSizeForTable(view, idx)
    return 372, 570
end

function LegionCampaignInfo:numberOfCellsInTableView(view)
    return 6
end

function LegionCampaignInfo:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("crop.LegionCampaignInfoCell")
        cell_item:setScale(0.9)
        --cell_item:setOpacity(50)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)

    cell_item:setData(self._curCampaign[index], index)
    cell_item:showState(self._bossData, index)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2 + 10, height / 2))

    return cell
end

function LegionCampaignInfo:onLeft(event)
    if event.name ~= "ended" then
        return
    end

end

function LegionCampaignInfo:onRight(event)
    if event.name ~= "ended" then
        return
    end

end

function LegionCampaignInfo:onClose(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_CROP_BOSS_CLOSE, {})
    self:disposeSelf()
end

function LegionCampaignInfo:getCurCampaign(msg)
    local campaign = StaticData['legion_campaign'][msg.data]
    local title = campaign['name']
    self._curCampaign = campaign['Troop']

    self._listView:reloadData()
end

function LegionCampaignInfo:refreshData()
    self._bossData = {
        boss_ids    = self._allLegionCampaign.boss_ids,
        cur_boss_id = self._allLegionCampaign.cur_boss_id,
        max_hp      = self._allLegionCampaign.max_hp,
        cur_hp      = self._allLegionCampaign.cur_hp
    }
end

function LegionCampaignInfo:onRefreshBossState()
    self:refreshData()
    self._listView:reloadData()
end

return LegionCampaignInfo
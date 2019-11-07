local TrialslTowerRankView = class("TrialslTowerRankView", require('app.base.PopupBase'))

TrialslTowerRankView.RESOURCE_FILENAME = "test_tower/TowerRankView.csb"
TrialslTowerRankView.RESOURCE_BINDING = {
    ["Button_1_3"]          = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Panel_tabview"]       = {["varname"] = "_panelTabView"},
    ["rank_img"]            = {["varname"] = "_rankImg"},
    ["rank_label"]          = {["varname"] = "_rankLabel"},
    ["txt_force"]           = {["varname"] = "_powerLabel"},
    ["contry_bg"]           = {["varname"] = "_countryImg"},
    ["crop_name"]           = {["varname"] = "_nameLabel"},
    ["txt_value"]           = {["varname"] = "_valueLabel"},
    ["panel_head"]          = {["varname"] = "_panelHead"},
    ["node_crop"]           = {["varname"] = "_nodeSelf"},
}

function TrialslTowerRankView:init()
    self._rankList = {}
    self:centerView()
    self:parseView()
    self:createList()
end

function TrialslTowerRankView:onCreate()
    TrialslTowerRankView.super.onCreate(self)
    self._nodeSelf:setVisible(false)
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_RANK_LOAD, handler(self, self._onRankInfo), 'onTrialTowerRankLoad')
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_RANK_LOAD)
end

function TrialslTowerRankView:onExit()
    network:removeEventListenerByTag('onTrialTowerRankLoad')

    TrialslTowerRankView.super:onExit()
end

function TrialslTowerRankView:_onRankInfo(msg)
    self._rankList = {}
    local rank_icon = {'xsj03_0196.png', 'xsj03_0197.png', 'xsj03_0198.png'}
    local is_visible = (msg.data.my_rank > 0 and msg.data.my_rank < 4)
    self._rankImg:setVisible(is_visible)
    self._rankLabel:setVisible(not is_visible)
    if msg.data.my_rank == 0 then
        self._rankLabel:setString(StaticData["local_text"]["tower.rank.des1"])
    elseif msg.data.my_rank < 4 then
        self._rankImg:setTexture('img/common/ui/' .. rank_icon[msg.data.my_rank])
    else
        self._rankLabel:setString(msg.data.my_rank)
    end
    local country_img ={"s03_00033.png", "s03_00034.png", "s03_00035.png"}
    self._countryImg:loadTexture("img/common/ui/" .. country_img[uq.cache.role.country_id])
    self._nameLabel:setString(uq.cache.role.name)
    self._valueLabel:setString(string.format(StaticData["local_text"]["tower.rank.des2"], msg.data.my_value))
    self._nodeSelf:setVisible(true)
    self._panelHead:removeAllChildren()
    local all_formation_data = uq.cache.formation:getAllFormation()
    local formation_data = uq.cache.formation:getFormationData(all_formation_data.default_id)
    local power = 0
    for k, v in ipairs(formation_data.general_loc) do
        local tab = {}
        local generals_info = uq.cache.generals:getGeneralDataByID(v.general_id)
        power = generals_info.power + power
        table.insert(tab, generals_info.temp_id)
        table.insert(tab, generals_info.lvl)
        table.insert(tab, generals_info.rtemp_id)
        local item = uq.createPanelOnly("instance.NpcGuideListItem")
        item:setPosition(cc.p((k - 1) * 110, 50))
        item:setData(tab)
        item:setScale(1.3)
        self._panelHead:addChild(item)
    end
    self._powerLabel:setString(power)
    self._rankList = msg.data.ranks
    self._listView:reloadData()
end

function TrialslTowerRankView:createList()
    local viewSize = self._panelTabView:getContentSize()
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
    self._panelTabView:addChild(self._listView)
end

function TrialslTowerRankView:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local data = {
        id = self._rankList[index].role_id
    }
    network:sendPacket(Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID, data)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
end

function TrialslTowerRankView:cellSizeForTable(view, idx)
    return 1040, 110
end

function TrialslTowerRankView:numberOfCellsInTableView(view)
    return #self._rankList
end

function TrialslTowerRankView:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("trials_tower.TrialslTowerRankItem")
        cell_item:setName("item")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end
    cell_item:setData(self._rankList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

return TrialslTowerRankView
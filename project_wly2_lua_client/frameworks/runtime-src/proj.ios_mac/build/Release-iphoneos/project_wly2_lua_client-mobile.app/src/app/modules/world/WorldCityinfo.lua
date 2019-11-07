local WorldCityInfo = class('WorldCityInfo', require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

WorldCityInfo.RESOURCE_FILENAME = "world/WorldCityInfo.csb"
WorldCityInfo.RESOURCE_BINDING = {
    ["Node_1/Button_1"]                 = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Node_1/label_item_des"]           = {["varname"] = "_desLabel"},
    ["Node_1/des_title"]                = {["varname"] = "_desTitleLabel"},
    ["Node_1/Panel_tab1"]               = {["varname"] = "_panelTab1"},
    ["Node_1/Panel_tab2"]               = {["varname"] = "_panelTab2"},
    ["Node_1/Panel_tabview"]            = {["varname"] = "_panelTabView"},
    ["Node_1/Button_box"]               = {["varname"] = "_btnBox",["events"] = {{["event"] = "touch",["method"] = "onBtnBox"}}},
}

function WorldCityInfo:ctor(name, args)
    WorldCityInfo.super.ctor(self, name, args)
    self._info = args.info
    self._panelTabArray = {self._panelTab1, self._panelTab2}
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_LOAD_FIRSTRANK, {city_id = self._info.city_id})
end

function WorldCityInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._rankType = 1
    self:initDialog()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_LOAD_FIRST_RANK, handler(self, self.onBattleLoadFirstRank), "onBattleLoadFirstRank")
end

function WorldCityInfo:initDialog()
    self._desTitleLabel:setHTMLText(string.format(StaticData["local_text"]["world.develop.des5"], StaticData["local_text"]["world.develop.des6"]))
    self:initItemTabView()
    for k, v in ipairs(self._panelTabArray) do
        v:setTouchEnabled(true)
        v:setTag(k)
        v:addClickEventListenerWithSound(function (sender)
            if self._rankType == sender:getTag() then
                return
            end
            self._rankType = sender:getTag()
            self:updateLeftBtn()
        end)
    end
    self:updateLeftBtn()
end

function WorldCityInfo:updateLeftBtn()
    for k, v in ipairs(self._panelTabArray) do
        v:getChildByName("img_select"):setVisible(k == self._rankType)
    end
    self:onBattleLoadFirstRank()
end

function WorldCityInfo:onBattleLoadFirstRank()
    if uq.cache.world_war.first_rank == nil then
        return
    end
    if self._rankType == 1 then
        self._desLabel:setString(StaticData["local_text"]["world.develop.des7"])
        self._curDataArray = uq.cache.world_war.first_rank.score_rank
    elseif self._rankType == 2 then
        self._desLabel:setString(StaticData["local_text"]["world.develop.des8"])
        self._curDataArray = uq.cache.world_war.first_rank.dechp_rank
    end
    if self._curDataArray == nil then
        self._curDataArray = {}
    end
    self._itemTableView:reloadData()
end

function WorldCityInfo:initItemTabView()
    local size = self._panelTabView:getContentSize()
    self._itemTableView = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView:setPosition(cc.p(0, 0))
    self._itemTableView:setAnchorPoint(cc.p(0,0))
    self._itemTableView:setDelegate()
    self._panelTabView:addChild(self._itemTableView)

    self._itemTableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._itemTableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function WorldCityInfo:cellSizeForTable(view, idx)
    return 888, 120
end

function WorldCityInfo:numberOfCellsInTableView(view)
    return #self._curDataArray
end

function WorldCityInfo:tableCellTouched(view, cell,touch)

end

function WorldCityInfo:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldCityInfoItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._curDataArray[index]
    info.rank = index
    info.data_type = self._rankType
    cell_item:setData(info)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function WorldCityInfo:onExit()
    services:removeEventListenersByTag('onBattleLoadFirstRank')
    WorldCityInfo.super:onExit()
end

function WorldCityInfo:onBtnBox(event)
    if event.name ~= "ended" then
        return
    end
    local city_info = StaticData['world_city'][self._info.city_id]
    local reward = StaticData['world_type'][city_info.type].Reward
    local str_reward = ""
    local reward_array = {}
    for k, v in ipairs(reward) do
        if v.type == 3 then
            str_reward = v.rankReward
            break
        end
    end
    if str_reward == "" then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_REWARD_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setRewardInfo(str_reward, 2)
end

return WorldCityInfo
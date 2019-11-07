local WorldTrendsModule = class("WorldTrendsModule", require("app.base.PopupTabView"))

WorldTrendsModule.RESOURCE_FILENAME = "world/WorldTrendsMain.csb"

WorldTrendsModule.RESOURCE_BINDING  = {
    ["Panel_46/Node_tab/Image_10"]              ={["varname"] = "_imgReward"},
    ["Panel_46/Node_tab"]                       ={["varname"] = "_nodeMenu"},
    ["Panel_46/Node_tab/bmf_season"]            ={["varname"] = "_bmfSeason"},
}
function WorldTrendsModule:ctor(name, args)
    WorldTrendsModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    self._subIndex = args._sub_index or 1
    WorldTrendsModule._subModules = {
        {path = "app.modules.world.WorldTrendsHeroes"}, --群雄并起
        {path = "app.modules.world.WorldTrendsReward"}, --赛季奖励
    }

    WorldTrendsModule._tabTxt = {
        StaticData['local_text']["world.trends.des1"],
    }
end

function WorldTrendsModule:onCreate()
    WorldTrendsModule.super.onCreate(self)
end

function WorldTrendsModule:init()
    self._tabModuleArray = {}
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY,  true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN,  true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.WORLD_TREND)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:setupView()
    self:initProtocolData()
    self:adaptBgSize()
end

function WorldTrendsModule:setupView()
    self:initDialog()
end

function WorldTrendsModule:onBtnReward(sender)
    local tag = sender:getTag()
    for k, v in ipairs(self._tabModuleArray) do
        v:getChildByName("img_select"):setVisible(false)
        v:getChildByName("img_normal"):setVisible(true)
    end
    local path = self._subModules[tag].path
    self:addSub(path, nil, nil, tag, nil)
end

function WorldTrendsModule:onTabChanged(sender)
    local tag = sender:getTag()
    for k, v in ipairs(self._tabModuleArray) do
        v:getChildByName("img_select"):setVisible(false)
        v:getChildByName("img_normal"):setVisible(true)
    end
    sender:getChildByName("img_select"):setVisible(true)
    sender:getChildByName("img_normal"):setVisible(false)
    local path = self._subModules[tag].path
    self:addSub(path, nil, nil, tag, nil)
end

function WorldTrendsModule:initProtocolData()

end

function WorldTrendsModule:removeProtocolData()

end

function WorldTrendsModule:initDialog()
    self._bmfSeason:setString(uq.cache.world_war.world_enter_info.season_id)
    local tab_index = {1}
    local tab_item = self._nodeMenu:getChildByName("Panel_1")
    local posx, posy = tab_item:getPosition()
    tab_item:removeSelf()
    local select_item = nil
    for k, v in ipairs(tab_index) do
        local item = tab_item:clone()
        self._nodeMenu:addChild(item)
        item:getChildByName("name"):setString(self._tabTxt[k])
        item:setTag(v)
        item:setPosition(posx, posy)
        item:setTouchEnabled(true)
        item:addClickEventListenerWithSound(handler(self, self.onTabChanged))
        if v == self._tabIndex then
            select_item = item
        end
        posy = posy - item:getContentSize().height - 5
        table.insert(self._tabModuleArray, item)
    end
    self._imgReward:setTag(#tab_index + 1)
    self._imgReward:setTouchEnabled(true)
    self._imgReward:addClickEventListenerWithSound(handler(self, self.onBtnReward))
    if #tab_index + 1 == self._tabIndex then
        self:onBtnReward(self._imgReward)
    else
        self:onTabChanged(select_item)
    end
end

function WorldTrendsModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    self:removeProtocolData()
    WorldTrendsModule.super.dispose(self)
end

return WorldTrendsModule

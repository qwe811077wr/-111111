local WorldCityDevelop = class("WorldCityDevelop", require("app.base.PopupBase"))

WorldCityDevelop.RESOURCE_FILENAME = "world/WorldCityDevelop.csb"

WorldCityDevelop.RESOURCE_BINDING  = {
    ["label_name"]              ={["varname"] = "_nameLabel"},
    ["Panel_item1"]             ={["varname"] = "_panelItem1"},
    ["Panel_item2"]             ={["varname"] = "_panelItem2"},
    ["Panel_item3"]             ={["varname"] = "_panelItem3"},
    ["Button_1"]                = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
}
function WorldCityDevelop:ctor(name, args)
    WorldCityDevelop.super.ctor(self,name,args)
    self._curInfo = args.info or nil
    self._panelArray = {self._panelItem1, self._panelItem2, self._panelItem3}
    self._itemArray = {}
end

function WorldCityDevelop:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    if self._curInfo == nil then
        return
    end
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_DEVELOP, handler(self, self._onBattleDevelop), "onWorldDevelopByDialog")
end

function WorldCityDevelop:_onBattleDevelop(msg)
    uq.fadeInfo(StaticData["local_text"]["world.city.info.des3"])
    self:updateInfo()
end

function WorldCityDevelop:initUi()
    local city_info = StaticData['world_city'][self._curInfo.city_id]
    self._nameLabel:setString(city_info.name)
    for k, v in ipairs(self._panelArray) do
        local item = uq.createPanelOnly("world.WorldCityDevelopItem")
        v:addChild(item)
        v:setTouchEnabled(true)
        v:setTag(k)
        v:addClickEventListener(handler(self, self.onItemPress))
        self._itemArray[k] = item
    end
    self:updateInfo()
end

function WorldCityDevelop:onItemPress(sender)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.SHOW)
    local tag = sender:getTag()
    for k, v in ipairs(self._itemArray) do
        if k == tag then
            v:selectPanel(true)
        else
            v:selectPanel(false)
        end
    end
end

function WorldCityDevelop:updateInfo()
    for k, v in ipairs(self._curInfo.develop) do
        local item = self._itemArray[k]
        if not item then
            return
        end
        v.city_id = self._curInfo.city_id
        item:setData(v)
    end
end

function WorldCityDevelop:dispose()
    services:removeEventListenersByTag('onWorldDevelopByDialog')
    for k, v in ipairs(self._itemArray) do
        v:dispose()
    end
    WorldCityDevelop.super.dispose(self)
end

return WorldCityDevelop
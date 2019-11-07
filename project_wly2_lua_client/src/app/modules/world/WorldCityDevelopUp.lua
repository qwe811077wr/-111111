local WorldCityDevelopUp = class("WorldCityDevelopUp", require("app.base.PopupBase"))

WorldCityDevelopUp.RESOURCE_FILENAME = "world/WorldCityDevelopUp.csb"

WorldCityDevelopUp.RESOURCE_BINDING  = {
    ["Node_1/Sprite_cost"]            ={["varname"] = "_costSprite1"},
    ["Node_1/moneyBtn"]               = {["varname"] = "_moneyBtn1",["events"] = {{["event"] = "touch",["method"] = "onDevelop"}}},
    ["Node_1/add"]                    ={["varname"] = "_addLabel1"},
    ["Node_1/cost_label"]             ={["varname"] = "_costLabel1"},
    ["Node_2/Sprite_cost"]            ={["varname"] = "_costSprite2"},
    ["Node_2/moneyBtn"]               = {["varname"] = "_moneyBtn2",["events"] = {{["event"] = "touch",["method"] = "onDevelop"}}},
    ["Node_2/add"]                    ={["varname"] = "_addLabel2"},
    ["Node_2/cost_label"]             ={["varname"] = "_costLabel2"},
}
function WorldCityDevelopUp:ctor(name, args)
    WorldCityDevelopUp.super.ctor(self,name,args)
    self._info = args.info or nil
    self._cityId = args.city_id or 0
end

function WorldCityDevelopUp:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    if self._info == nil then
        return
    end
    self:initUi()
end

function WorldCityDevelopUp:initUi()
    self._moneyBtn1:setPressedActionEnabled(true)
    self._moneyBtn2:setPressedActionEnabled(true)
    self:updateInfo()
end

function WorldCityDevelopUp:updateInfo()
    local develop_info = StaticData['world_develop'][self._info.id]
    local effect_info = develop_info.Effect[self._info.level]
    self._addLabel1:setString(effect_info.each1)
    self._addLabel2:setString(effect_info.each2)
    local reward1 = uq.RewardType.new(effect_info.cost1)
    self._costSprite1:setTexture("img/common/ui/" .. reward1:miniIcon())
    self._costLabel1:setString(reward1:num())
    local reward2 = uq.RewardType.new(effect_info.cost2)
    self._costSprite2:setTexture("img/common/ui/" .. reward2:miniIcon())
    self._costLabel2:setString(reward2:num())
end

function WorldCityDevelopUp:onDevelop(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_DEVELOP, {city_id = self._cityId, choice = self._info.id, option = event.target:getTag()})
    self:disposeSelf()
end

function WorldCityDevelopUp:dispose()
    WorldCityDevelopUp.super.dispose(self)
end

return WorldCityDevelopUp
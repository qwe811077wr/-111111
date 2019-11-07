local WorldBattleWin = class("WorldBattleWin", require("app.base.PopupBase"))

WorldBattleWin.RESOURCE_FILENAME = "world/WorldBattleWin.csb"

WorldBattleWin.RESOURCE_BINDING  = {
    ["label_crop"]                    ={["varname"] = "_cropNameLabel"},
    ["label_city"]                    ={["varname"] = "_cityNameLabel"},
    ["label_role_name"]               ={["varname"] = "_roleNameLabe"},
    ["label_des"]                     ={["varname"] = "_desLabel"},
    ["Node_effect"]                   ={["varname"] = "_nodeEffect"},
}
function WorldBattleWin:ctor(name, args)
    WorldBattleWin.super.ctor(self, name, args)
    self._info = args.data or nil
    uq.AnimationManager:getInstance():getEffect('txf_4_20', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('txf_4_21', nil, nil, true)
end

function WorldBattleWin:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._effectState = false
    self:initUi()
end

function WorldBattleWin:initUi()
    uq:addEffectByNode(self._nodeEffect, 900153, 1, true, nil, function()
        uq:addEffectByNode(self._nodeEffect, 900154, -1, true)
    end)
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._cropNameLabel:setString(crop_data.name)
    self._roleNameLabe:setString(crop_data.leader_name)
    local city_info = StaticData['world_city'][self._info.city_id]
    self._cityNameLabel:setString(city_info.name)
    if self._info.atk_crop_id == uq.cache.role.cropsId then
        self._desLabel:setString(StaticData["local_text"]["world.battle.win.des1"])
    else
        self._desLabel:setString(StaticData["local_text"]["world.battle.win.des2"])
    end
end

function WorldBattleWin:dispose()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_END_BATTLE})
    WorldBattleWin.super.dispose(self)
end

return WorldBattleWin
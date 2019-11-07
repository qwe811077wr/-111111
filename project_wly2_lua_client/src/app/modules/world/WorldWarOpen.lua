local WorldWarOpen = class("WorldWarOpen", require("app.base.PopupBase"))

WorldWarOpen.RESOURCE_FILENAME = "world/WorldWarOpen.csb"

WorldWarOpen.RESOURCE_BINDING  = {
    ["Node_1/Button_1"]               = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["Node_1/Button_1_0"]             = {["varname"] = "_btnCancel",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
    ["Node_effect"]                   ={["varname"] = "_nodeEffect"},
    ["Image_1"]                       ={["varname"] = "_imgTitle"},
    ["Image_3_0"]                     ={["varname"] = "_imgBg"},
}
function WorldWarOpen:ctor(name, args)
    args._isStopAction = true
    WorldWarOpen.super.ctor(self, name, args)
    self._info = args.data or nil
    uq.AnimationManager:getInstance():getEffect('txf_4_11', nil, nil, true)
end

function WorldWarOpen:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function WorldWarOpen:initUi()
    local delta = 1 / 12
    self._btnOk:setOpacity(0)
    self._btnCancel:setOpacity(0)
    self._imgTitle:setOpacity(0)
    self._imgTitle:setScale(1.2)
    self._imgBg:setOpacity(0)
    uq.playSoundByID(106)
    uq:addEffectByNode(self._nodeEffect, 900151, 1, false, nil, nil, 2)
    self._imgBg:runAction(cc.Sequence:create(cc.DelayTime:create(2 * delta), cc.CallFunc:create(function()
        self._imgTitle:setOpacity(255)
        self._imgBg:setOpacity(255)
        self._imgTitle:runAction(cc.ScaleTo:create(3 * delta, 1))
    end)))
    self._btnOk:runAction(cc.Sequence:create(cc.DelayTime:create(3 * delta), cc.CallFunc:create(function()
        self._btnOk:setOpacity(255)
        self._btnCancel:setOpacity(255)
    end)))
    self._btnCancel:runAction(cc.Sequence:create(cc.DelayTime:create(4 * delta), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeEffect, 900152, -1, true)
    end)))
    local city_info = StaticData['world_city'][self._info.city_id]
    self._btnOk:setTitleText(StaticData["local_text"]["world.battle.open"] .. city_info.name)
end

function WorldWarOpen:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    --判断自己是否是军团长
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    if next(crop_data) == nil then
        uq.fadeInfo(StaticData["local_text"]["world.war.power.des5"])
        return
    end
    if crop_data.power_id == 0 then
        if uq.cache.crop:getMyCropLeaderId() ~= uq.cache.role.id then
            uq.fadeInfo(StaticData["local_text"]["world.war.power.des6"])
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CREATE_POWER_MODULE)
        return
    end
    uq.cache.world_war.move_city_id = self._info.city_id
    uq.jumpToModule(4)
end

function WorldWarOpen:dispose()
    WorldWarOpen.super.dispose(self)
end

return WorldWarOpen
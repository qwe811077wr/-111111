local FlyNailModule = class("FlyNailModule", require("app.base.ModuleBase"))
local FlyNailItem = require("app.modules.fly_nail.FlyNailItem")

FlyNailModule.RESOURCE_FILENAME = "fly_nail/FlyNailMain.csb"

FlyNailModule.RESOURCE_BINDING  = {
    ["Node_1"]                                      = {["varname"] = "_nodeBase"},
    ["Panel_1/Panel_item"]                          ={["varname"] = "_panelItem"},
    ["Panel_1/Node_1/Node_effect"]                  ={["varname"] = "_nodeEffect"},
    ["Panel_1/Node_1/Image_big_bg"]                 ={["varname"] = "_imgBigBg"},
    ["Panel_1/Node_1/Image_star"]                   ={["varname"] = "_imgStar"},
    ["Panel_1/Node_1/Image_min_bg"]                 ={["varname"] = "_imgSmallBg"},
    ["Panel_1/btn_door"]                            ={["varname"] = "_btnDoor", ["events"] = {{["event"] = "touch",["method"] = "_onBtnDoor",["sound_id"] = 0}}},
}

function FlyNailModule:ctor(name, args)
    FlyNailModule.super.ctor(self, name, args)
    self._itemArray = {}
    self._dataArray = {}
    self._effectArray = {}
end

function FlyNailModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.FLY_NAIL_MODULE)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self._lastMusic = uq.getLastMusic()
    uq.playSoundByID(1106)

    self:parseView()
    self:centerView()
    self:adaptBgSize()
    self:initDialog()
    self:initProtocolData()
    self:showAction()
end

function FlyNailModule:_onBtnDoor(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.STRANGE_DOOR)
end

function FlyNailModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_LOAD, handler(self, self._onFlyNailLoad), '_onFlyNailLoadByModule')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_HANGUP, handler(self, self._onFlyNailHangup), '_onFlyNailHangupByModule')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_DRAW_REWARD, handler(self, self._onFlyNailDrawReward), '_onFlyNailDrawRewardByModule')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_LEVEL_UP, handler(self, self._onFlyNailLevelUp), '_onFlyNailLevelUpByModule')
    network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_LOAD, {})
end

function FlyNailModule:removeProtocolData()
    services:removeEventListenersByTag("_onFlyNailLoadByModule")
    services:removeEventListenersByTag("_onFlyNailHangupByModule")
    services:removeEventListenersByTag("_onFlyNailLevelUpByModule")
    services:removeEventListenersByTag("_onFlyNailDrawRewardByModule")
end

function FlyNailModule:_onFlyNailLevelUp(msg)
    local item = self._itemArray[msg.data.id]
    if item then
        item:setInfo(self._dataArray[msg.data.id])
    end
    self:updateEffect(self._dataArray[msg.data.id])
end

function FlyNailModule:_onFlyNailDrawReward(msg)
    local item = self._itemArray[msg.data.id]
    if item then
        item:setInfo(self._dataArray[msg.data.id])
    end
    self:updateEffect(self._dataArray[msg.data.id])
end

function FlyNailModule:_onFlyNailHangup(msg)
    local item = self._itemArray[msg.data.id]
    if item then
        item:setInfo(self._dataArray[msg.data.id])
    end
    self:updateEffect(self._dataArray[msg.data.id])
end

function FlyNailModule:_onFlyNailLoad()
    local info = uq.cache.fly_nail.flyNailInfo
    for k, v in pairs(info.items) do
        local data_info = self._dataArray[v.id]
        data_info.data = v
    end
    self:updateInfo()
end

function FlyNailModule:updateInfo()
    for k, v in ipairs(self._dataArray) do
        local item = self._itemArray[k]
        item:setVisible(true)
        item:setInfo(v)
        self:updateEffect(v)
    end
end

function FlyNailModule:updateEffect(info)
    local sprite = self._effectArray[info.xml.ident]
    if sprite == nil then --先隐藏掉特效
        return
    end
    if info.data == nil or info.data.general_id1 == 0 or info.data.general_id2 == 0 or (info.data.left_time - os.time()) > 0 then
        sprite:stopAllActions()
        sprite:setVisible(false)
    else
        sprite:stopAllActions()
        sprite:setVisible(true)
        local action = cc.Sequence:create(cc.FadeOut:create(1.3), cc.FadeIn:create(1.3))
        sprite:runAction(cc.RepeatForever:create(action))
    end
end

function FlyNailModule:initDialog()
    self._btnDoor:setPressedActionEnabled(true)
    for i = 1, 8 do
        local panel = self._panelItem:getChildByName("Panel_" .. i)
        local item = FlyNailItem:create()
        item:setVisible(false)
        panel:addChild(item)
        item:setPosition(cc.p( panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5 ))
        item:setTouchEnabled(true)
        item:addClickEventListener(function(sender)
            local info = sender:getInfo()
            if info.unlock == false then --没解锁提示
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
                uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.module.des4'], info.xml.level))
                return
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            uq.ModuleManager:getInstance():show(uq.ModuleManager.FLY_NAIL_BATTLE, {info = info})
        end)
        table.insert(self._itemArray, item)
    end
    local level = uq.cache.role:level()
    for i = 1, 8 do
        local info = {}
        info.xml = StaticData['eight_diagrams'].EightDiagram[i]
        info.data = nil
        if info.xml.level <= level then
            info.unlock = true
        else
            info.unlock = false
        end
        table.insert(self._dataArray, info)
    end
end

function FlyNailModule:showAction()
    uq.intoAction(self._nodeBase)
    for i, v in ipairs(self._itemArray) do
        v:showAction()
    end
    local delta = 1 / 12
    uq:addEffectByNode(self._nodeEffect, 900164, -1, true)
    self._imgBigBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(20 * delta, 20)))
    self._imgSmallBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(20 * delta, -15)))
    self._imgStar:setOpacity(255 * 0.5)
    self._imgStar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(20 * delta, 255), cc.FadeTo:create(20 * delta, 255 * 0.5))))
end

function FlyNailModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    for k, v in pairs(self._itemArray) do
        v:dispose()
    end
    self:removeProtocolData()
    uq.playBackGroundMusic(self._lastMusic)
    FlyNailModule.super.dispose(self)
end

return FlyNailModule

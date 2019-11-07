local RandomMapItem = class("RandomMapItem", require('app.base.ChildViewBase'))

function RandomMapItem:onCreate()
    self._timerFlag = 'timer_flag' .. tostring(self)
    RandomMapItem.super.onCreate(self)
    self._existTime = 1800
end

function RandomMapItem:onExit()
    if self._action then
        uq.AnimationManager:getInstance():dispose(self._fileName, self._action)
    end
    uq.TimerProxy:removeTimer(self._timerFlag)
    RandomMapItem.super.onExit(self)
end

function RandomMapItem:setData(random_type, random_id, callback, map_size)
    self._randomType = random_type
    self._randomId = random_id
    self._callback = callback
    self._randomData = uq.cache.random_event:getRandomDataItem(random_type, random_id)

    if self._randomData.time > 0 and self._randomData.time + self._existTime <= uq.curServerSecond() then
        self:remove()
        return
    end

    if random_type == uq.cache.random_event.RANDOM_EVENT_TYPE.EGG then
        self._randomXml = StaticData['random_event'].Egg[random_id]

        local troop_data = StaticData['soldier'][94]
        self._action = troop_data.idleAction
        self._fileName = 'idle'
        self._animationGroup = uq.AnimationManager:getInstance():getAction(self._fileName, self._action)
        self._animation = require('app/modules/battle/ObjectAnimation'):create(self, self._animationGroup, false)
        self._animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)

        self._uiTip = ccui.ImageView:create('img/main_city/s03_000358.png')
        self._uiTip:setPosition(cc.p(5, 120))
        self._uiTip:setTouchEnabled(true)
        self._uiTip:onTouch(handler(self, self.onUITouch))
        self:addChild(self._uiTip)
    else
        self._randomXml = StaticData['random_event'].Box[random_id]
        self._cdTime = 2

        local troop_data = StaticData['soldier'][16]
        self._action = troop_data.idleAction
        self._fileName = 'idle'
        self._animationGroup = uq.AnimationManager:getInstance():getAction(self._fileName, self._action)
        self._animation = require('app/modules/battle/ObjectAnimation'):create(self, self._animationGroup, false)
        self._animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)

        if not self._uiTip then
            self._uiTip = ccui.ImageView:create('img/main_city/s03_000357.png')
            self._uiTip:setPosition(cc.p(5, 120))
            self._uiTip:setTouchEnabled(true)
            self._uiTip:onTouch(handler(self, self.onUITouch))
            self:addChild(self._uiTip, 1)
        end

        if not self._uiLoad then
            self._uiLoad = cc.CSLoader:createNode('random_event/RandBox.csb')
            local size = self._uiLoad:getContentSize()
            self._uiLoad:setPosition(cc.p(-size.width / 2, 100))
            self._uiLoad:setVisible(false)
            self:addChild(self._uiLoad, 2)
        end
    end
    local px = self._randomXml.pos_x - map_size.width / 2
    local py = -self._randomXml.pos_y + map_size.height / 2
    self:setPosition(cc.p(px, py))
    self:refreshData()
end

function RandomMapItem:remove()
    if self._callback then
        self._callback(self:getRandomID())
    end
    uq.cache.random_event:removeRandomData(self._randomType, self._randomId)
    self:removeSelf()
end

function RandomMapItem:refreshData()
    uq.TimerProxy:removeTimer(self._timerFlag)
    self._randomData = uq.cache.random_event:getRandomDataItem(self._randomType, self._randomId)

    if self._randomData.time > 0 then --已经答题
        uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.checkEggExit), 10, -1)
        self._uiTip:setVisible(false)
    else
        self._uiTip:setVisible(true)
    end
end

function RandomMapItem:containPoint(point)
    local size = self._animation:getSprite():getContentSize()
    local sprite = self._animation:getSprite()

    local x, y = self:getPosition()
    local rect = cc.rect(x - size.width / 2, y - size.height / 2, size.width, size.height)
    if cc.rectContainsPoint(rect, point) then
        local pt_world = self:getParent():convertToWorldSpace(point)
        if sprite then
            return uq.alphaTouchCheck(sprite, sprite:convertToNodeSpace(pt_world))
        else
            return true
        end
    end

    return false
end

function RandomMapItem:onUITouch(event)
    if event.name == "ended" then
        self:onClick()
    end
end

function RandomMapItem:onClick()
    if self._randomType == uq.cache.random_event.RANDOM_EVENT_TYPE.EGG then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RANDOM_EGG, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._randomType, self._randomId)
        end
    else
        --已经领取
        if self._randomData.time > 0 then
            uq.fadeInfo(StaticData['local_text']['activity.finish.reward'])
        else
            self:openBox()
        end
    end
end

function RandomMapItem:openBox()
    if self._openTime then
        uq.fadeInfo(StaticData['local_text']['label.random.collect'])
        return
    end
    self._openTime = os.clock()
    self:updateBoxCD()
    uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.updateBoxCD), 0.1, -1)
    self._uiTip:setVisible(false)
    self._uiLoad:setVisible(true)
end

function RandomMapItem:updateBoxCD()
    local rate = (os.clock() - self._openTime) / self._cdTime * 100
    self._uiLoad:getChildByName('LoadingBar_2'):setPercent(rate)

    if self._cdTime <= os.clock() - self._openTime then
        network:sendPacket(Protocol.C_2_S_RANDOM_EVENT_DRAW_BOX, {id = self._randomId})
        self._uiLoad:setVisible(false)
        uq.TimerProxy:removeTimer(self._timerFlag)
    end
end

function RandomMapItem:checkEggExit()
    if self._randomData.time + self._existTime <= uq.curServerSecond() then
        self:remove()
    end
end

function RandomMapItem:getRandomID()
    return self._randomType .. '_' .. self._randomId
end

return RandomMapItem
local FlyNailItem = class("FlyNailItem", function()
    return ccui.Layout:create()
end)

function FlyNailItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function FlyNailItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("fly_nail/FlyNailItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0, 0))
    self._imgLock = self._view:getChildByName("img_lock");
    self._nameImg = self._view:getChildByName("Image_1");
    self._levelLabel = self._view:getChildByName("lbl_level");
    self._desLabel = self._view:getChildByName("lbl_des");
    self._nodeEffect = self._view:getChildByName("Node_effect");
    self:initInfo()
end

function FlyNailItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function FlyNailItem:initInfo()
    self._nodeEffect:removeAllChildren()
    if not self._info then
        return
    end
    self._nameImg:loadTexture("img/fly_nail/" .. self._info.xml.image)
    self._imgLock:setVisible(not self._info.unlock)
    if not self._info.unlock then
        self._desLabel:setString(string.format(StaticData['local_text']['fly.nail.module.des2'], self._info.xml.level))
    else
        self._desLabel:setString(StaticData['local_text']['fly.nail.item.des1'])
    end

    if self._info.data == nil then
        return
    end
    local left_time = self._info.data.left_time - os.time()
    if left_time <= 0 then
        if self._info.data.general_id1 == 0 and self._info.data.general_id2 == 0 then
            self._desLabel:setString(StaticData['local_text']['fly.nail.module.des3'])
        else
            uq:addEffectByNode(self._nodeEffect, 900163, -1, true)
            self._desLabel:setString(StaticData['local_text']['fly.nail.general.des9'])
        end
    else
        if self._cdTimer then
            self._cdTimer:setTime(left_time)
        else
            self._cdTimer = uq.ui.TimerField:create(self._desLabel, left_time, handler(self, self._cdTimeOver))
        end
    end
end

function FlyNailItem:_cdTimeOver()
    uq:addEffectByNode(self._nodeEffect, 900163, -1, true)
    self._desLabel:setString(StaticData['local_text']['fly.nail.general.des9'])
    uq.cache.fly_nail:updateRed()
end

function FlyNailItem:getInfo()
    return self._info
end

function FlyNailItem:showAction()
    uq.intoAction(self._view)
end

function FlyNailItem:dispose()
    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end
end

return FlyNailItem
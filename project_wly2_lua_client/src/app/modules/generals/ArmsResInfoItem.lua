local ArmsResInfoItem = class("ArmsResInfoItem",function()
    return ccui.Layout:create()
end)

function ArmsResInfoItem:ctor(args)
    self._view = nil
    self._selectCallBack = nil
    self._bgCallBack = nil
    self._soldierId = args and args.info
    self:init()
end

function ArmsResInfoItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("generals/ArmsResInfoItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(self._view:getContentSize().width * 0.5, self._view:getContentSize().height * 0.5))
    self._bgImg = self._view:getChildByName("Image_12");
    self._typeImg = self._view:getChildByName("img_type1");
    self._levelLabel = self._view:getChildByName("label_level1");
    self._effNode = self._view:getChildByName("Panel_eff");
    self._nameLabel = self._view:getChildByName("label_name1");
    self._panelTip = self._view:getChildByName("Panel_7");
    self:_initDialog()
end

function ArmsResInfoItem:setInfo(info)
    if self._soldierId and  self._soldierId == info then
        return
    end
    self._soldierId = info
    self:_initDialog()
end

function ArmsResInfoItem:_initDialog()
    if self._soldierId == nil then
        return
    end
    local soldier_xml1 = StaticData['soldier'][self._soldierId]
    if soldier_xml1 == nil then
        uq.log("error ArmsResInfoItem updateBaseInfo  soldier_xml1")
        return
    end
    self._effNode:removeAllChildren()
    self._action = soldier_xml1.idleAction
    self._animationGroup = uq.AnimationManager:getInstance():getAction('idle', self._action)
    self._animation = require('app/modules/battle/ObjectAnimation'):create(self._effNode, self._animationGroup)
    self._animation:setPosition(cc.p(self._effNode:getContentSize().width * 0.5, self._effNode:getContentSize().height * 0.5))
    self._animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
    local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
    local type_solider_level1 = StaticData['types'].Soldierlevel[1].Type[soldier_xml1.level]
    self._typeImg:loadTexture("img/generals/" .. type_solider1.miniIcon2)
    self._nameLabel:setString(soldier_xml1.name)
    self._levelLabel:setString(type_solider_level1.name)
    self._levelLabel:setTextColor(uq.parseColor(type_solider_level1.color))
end

function ArmsResInfoItem:addClickEvent(func)
    self._view:setTouchEnabled(true)
    self._view:onTouch(function(event)
        if event.name == "began" then
            func(true, self._soldierId)
        elseif event.name == "moved" then
            local pos = self._view:getTouchMovePosition()
            local pos_start = self._view:getTouchBeganPosition()
            if (pos.x - pos_start.x) * (pos.x - pos_start.x) + (pos.y - pos_start.y) * (pos.y - pos_start.y) < 100 then
                return
            end
            func(false)
        elseif event.name == "ended" then
            func(false)
        end
    end)
end

function ArmsResInfoItem:dispose()
    uq.AnimationManager:getInstance():dispose('idle', self._action)
end

function ArmsResInfoItem:playAttackAction(is_play)
    if not is_play then
        return
    end
    self._animation:setVisible(true)
    self._animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_ATTACK, false, 1, handler(self, self.actionFinished))
end

function ArmsResInfoItem:actionFinished()
    self._animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
end

return ArmsResInfoItem

local EffectNode = class('EffectNode')

function EffectNode:ctor(pnode, id, name, pos, loop, part, delay)
	self.node = cc.Sprite:create()
	self.pnode = pnode
	local effect = uq.AnimationManager:getInstance():getEffect(id, name, part)
	if not effect then
		return
	end
	local action = nil
	if loop then
		action = cc.RepeatForever:create(cc.Animate:create(effect))
	else
		if delay and delay > 0 then
			action = cc.Sequence:create(cc.DelayTime:create(delay), cc.Animate:create(effect), cc.CallFunc:create(handler(self, self.dispose)), nil)
		else
			action = cc.Sequence:create(cc.Animate:create(effect), cc.CallFunc:create(handler(self, self.dispose)), nil)
		end
	end
	pnode:addChild(self.node,100,101)
	self.node:runAction(action)

	if pos ~= nil then
		self.node:setPosition(pos)
	else
		self.node:setPosition(display.center)
	end
end

function EffectNode:dispose()
	if not self.node then
		return
	end
	self.pnode:removeChild(self.node)
	self.node = nil
end
uq.EffectNode = EffectNode
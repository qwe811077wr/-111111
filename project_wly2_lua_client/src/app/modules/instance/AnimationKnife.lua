local AnimationKnife = class("AnimationKnife", require('app.base.ChildViewBase'))

AnimationKnife.RESOURCE_FILENAME = "instance/AnimationKnife.csb"
AnimationKnife.RESOURCE_BINDING = {
}

function AnimationKnife:onCreate()
    AnimationKnife.super.onCreate(self)

    uq:addEffectByNode(self, 900133, -1, false, cc.p(0, 0))
    uq:addEffectByNode(self, 900134, -1, false, cc.p(0, 0))
end

return AnimationKnife
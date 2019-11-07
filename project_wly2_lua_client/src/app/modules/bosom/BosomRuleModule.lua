local BosomRuleModule = class('BosomRuleModule', require('app.base.PopupBase'))

BosomRuleModule.RESOURCE_FILENAME = 'bosom/BosomRule.csb'

function BosomRuleModule:ctor(name, params)
    BosomRuleModule.super.ctor(self, name, params)
end

function BosomRuleModule:init()
    self:parseView()
    self:centerView()

    self._view:getChildByName('xf_rule_txt'):setString(StaticData['rule'][201]['Text'][1]['description'])
    self._view:getChildByName('nt_rule_txt'):setString(StaticData['rule'][201]['Text'][2]['description'])
end

function BosomRuleModule:dispose()
    BosomRuleModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return BosomRuleModule
local BosomRuleAdvanceAutoModule = class('BosomRuleAdvanceAutoModule', require('app.base.PopupBase'))

BosomRuleAdvanceAutoModule.RESOURCE_FILENAME = 'bosom/BosomOneKeyRule.csb'

function BosomRuleAdvanceAutoModule:ctor(name, params)
    BosomRuleAdvanceAutoModule.super.ctor(self, name, params)
end

function BosomRuleAdvanceAutoModule:init()
    self:parseView()
    self:centerView()

    self._view:getChildByName('advance_xf_rule_txt'):setString(StaticData['rule'][202]['Text'][1]['description'])
end

function BosomRuleAdvanceAutoModule:dispose()
    BosomRuleAdvanceAutoModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return BosomRuleAdvanceAutoModule
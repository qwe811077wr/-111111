local BosomMarryModule = class("BosomMarryModule", require('app.base.ModuleBase'))

function BosomMarryModule:ctor(name, params)
    BosomMarryModule.super.ctor(self, name, params)

    self._id = params.id
    self._template = StaticData['bosom']['women'][self._id]
    self._marquee = nil
end

function BosomMarryModule:init()
    self:setView(cc.CSLoader:createNode("bosom/MarryView.csb"))
    self:parseView()
    self:adaptBgSize()

    self:_showTalkPanel()

    local btn = self._view:getChildByName('img_bg_adapt')
    btn:addClickEventListenerWithSound(handler(self, self._onClickTalk))
end

function BosomMarryModule:_onClickTalk()
    if not self._marquee then
        return
    end
    if not self._marquee:finished() then
        self._marquee:showAll()
        return
    end
    self._marquee:dispose()
    self._marquee = nil
    self:disposeSelf()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
end

function BosomMarryModule:_showTalkPanel()
    local dt = 0.2
    local container = self._view:getChildByName('talk_words_container')
    local panel = container:getChildByName('talk_words_panel')
    panel:getChildByName('words'):setString('')
    panel:setPosition(cc.p(panel:getPositionX(), -panel:getContentSize().height))
    local action = cc.MoveTo:create(dt, cc.p(panel:getPositionX(), 25))
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._beginText)))
    panel:runAction(action)
end

function BosomMarryModule:_beginText()
    local container = self._view:getChildByName('talk_words_container')
    local panel = container:getChildByName('talk_words_panel')
    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end
    local season = StaticData['local_text']['season.' .. uq.cache.server.season]
    local text = string.format(StaticData['local_text']['bosom.notice.marry.succ'], uq.cache.server.year, season, self._template.name)
    local clazz = require('app/modules/bosom/WordMarquee')
    self._marquee = clazz:create(panel:getChildByName('words'), text, handler(self, self._generateFlowers))
end

function BosomMarryModule:_generateFlowers()
    for i = 1, 20 do
        self:_randFlower()
    end
end

function BosomMarryModule:_randFlower()
    local flower_pathes = {'res/img/bosom/g05_0026.png', 'res/img/bosom/g05_0027.png',
                         'res/img/bosom/g05_0028.png', 'res/img/bosom/g05_0029.png'}
    local img = ccui.ImageView:create(flower_pathes[math.random(#flower_pathes)], ccui.TextureResType.localType)
    local x = math.random(-display.width / 2, display.width / 2)
    local y = math.random(display.height / 2, display.height / 2 + 50)
    img:setPosition(cc.p(x, y))
    local scale = math.random() * 0.5 + 0.2
    img:setScaleX(scale)
    img:setScaleY(scale)
    self._view:addChild(img)
    local action = cc.MoveTo:create(10 * (0.5 + math.random() * 0.5), cc.p(x, -display.height / 2 - 50))
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(img, function(pic)
        pic:stopAllActions()
        pic:removeSelf()
        end)), cc.CallFunc:create(handler(self, self._randFlower)))

    local rate = math.random(5)
    if rate == 1 then
        local act1 = cc.ScaleTo:create(0.8, 1, -1)
        local act2 = cc.ScaleTo:create(0.8, 1, 1)
        local act = cc.Repeat:create(cc.Sequence:create(act1, act2), 10)
        action = cc.Spawn:create(act, action)
    elseif rate == 2 then
        local dt = 1
        local distance = math.random(80, 120)
        local act1 = cc.MoveBy:create(dt, cc.p(-distance / 2, 0))
        local act2 = cc.MoveBy:create(dt * 2, cc.p(distance, 0))
        local act3 = cc.MoveBy:create(dt, cc.p(-distance / 2, 0))
        local act = cc.Sequence:create(act1, act2, act3)
        action = cc.Spawn:create(cc.Repeat:create(act, 10), action)
    elseif rate == 3 then
        local dt = 1
        local distance = math.random(50, 100)

        local act1 = cc.ScaleTo:create(1, 1, -1)
        local act2 = cc.ScaleTo:create(1, 1, 1)
        local scale_act = cc.Repeat:create(cc.Sequence:create(act1, act2), 10)

        act1 = cc.MoveBy:create(dt, cc.p(-distance / 2, 0))
        act2 = cc.MoveBy:create(dt * 2, cc.p(distance, 0))
        local act3 = cc.MoveBy:create(dt, cc.p(-distance / 2, 0))
        local swing_act = cc.Repeat:create(cc.Sequence:create(act1, act2, act3), 10)
        action = cc.Spawn:create(cc.Spawn:create(scale_act, swing_act), action)
    end
    img:runAction(action)
end

function BosomMarryModule:dispose()
    BosomMarryModule.super.dispose(self)

    display.removeUnusedSpriteFrames()
end

return BosomMarryModule
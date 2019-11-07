local BosomNormalTalkModule = class("BosomNormalTalkModule", require('app.base.ModuleBase'))

BosomNormalTalkModule.RESOURCE_FILENAME = "bosom/NormalPersonTalk.csb"
BosomNormalTalkModule.RESOURCE_BINDING = {
    ["body"]                        = {["varname"] = "_bodyImg"},
    ["name"]                        = {["varname"] = "_nameTxt"},
    ["img_bg_adapt"]                = {["varname"] = "_bgImg"},
    ["talk_words_panel/Image_1"]    = {["varname"] = "_goldImg"},
    ["talk_words_panel/Text_2"]     = {["varname"] = "_addTxt"},
    ["talk_words_panel/Text_2_0_0"] = {["varname"] = "_itemTxt"},
}

function BosomNormalTalkModule:ctor(name, params)
    BosomNormalTalkModule.super.ctor(self, name, params)

    self._id = params.id
    self._words = params.words
    self._waveTimer = nil
    self._autoTalk = params.auto_talk
    self._autoTalkTimerTag = '_onAutoTalkTimer' .. tostring(self)
    self._autoTalkTimer = false
    self._template = StaticData['bosom']['women'][self._id]
    self._clickNum = 0
end

function BosomNormalTalkModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()

    local img_path = string.format('res/img/common/general_head/%s', self._template.cardIcon)
    self._bodyImg:loadTexture(img_path, ccui.TextureResType.localType)
    self._nameTxt:setString(self._template.name)
    self._bgImg:addClickEventListenerWithSound(handler(self, self._onClick))

    local panel = self._view:getChildByName('talk_words_panel')
    local clazz = require('app/modules/bosom/WordMarquee')
    self._marquee = clazz:create(panel:getChildByName('words'), self._words, handler(self, self._onWordCB))

    if self._autoTalk then
        local panel = self._view:getChildByName('auto_searching')
        panel:setVisible(true)
        self._waveTimer = require('app/modules/bosom/WordWave'):create(panel, StaticData['local_text']['label.bosom.auto.searching'])
    end
    self:refreshReward()
end

function BosomNormalTalkModule:refreshReward()
    self._itemTxt:setVisible(false)
    self._goldImg:setVisible(false)
    local tab_str = string.split(self._template.reward,";")
    if tab_str and next(tab_str) ~= nil then
        local coin_type = tonumber(tab_str[1])
        local coin_id = tonumber(tab_str[3])
        if coin_type < uq.config.constant.COST_RES_TYPE.MATERIAL then
            local info = StaticData['types'].Cost[1].Type[coin_type]
            if info and info.miniIcon then
                self._goldImg:setVisible(true)
                self._goldImg:loadTexture("img/common/ui/" .. info.miniIcon)
            end
        else
            local info = StaticData.getCostInfo(coin_type,coin_id)
            if info and info.name then
                self._itemTxt:setVisible(true)
                self._itemTxt:setString(info.name)
                if info.qualityType then
                    local color_type = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
                    if color_type and color_type.color then
                        self._itemTxt:setTextColor(uq.parseColor(color_type.color))
                    end
                end
            end
        end
        self._addTxt:setString("+" .. tab_str[2])
    end
end

function BosomNormalTalkModule:_onClick(btn)
    self._clickNum = self._clickNum + 1
    if self._marquee and self._marquee:finished() then
        self:disposeSelf()
    elseif self._clickNum == 1 then
        if self._marquee then
            self._marquee:showAll()
            self._marquee:dispose()
            self._marquee = nil
        end
    elseif self._clickNum == 2 then
        self:disposeSelf()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
    end
end

function BosomNormalTalkModule:_onWordCB()
    if not self._autoTalk then
        return
    end

    uq.TimerProxy:addTimer(self._autoTalkTimerTag, handler(self, self._finishCB), 0.5, 1)
    self._autoTalkTimer = true
end

function BosomNormalTalkModule:_finishCB()
    self._autoTalkTimer = false
    self:disposeSelf()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
end

function BosomNormalTalkModule:dispose()
    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end

    if self._waveTimer then
        self._waveTimer:dispose()
        self._waveTimer = nil
    end
    if self._autoTalkTimer then
        uq.TimerProxy:removeTimer(self._autoTalkTimerTag)
        self._autoTalkTimer = false
    end
    BosomNormalTalkModule.super.dispose(self)

    display.removeUnusedSpriteFrames()

end

return BosomNormalTalkModule
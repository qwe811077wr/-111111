local BattlePopText = class("BattlePopText", require('app.base.ChildViewBase'))

BattlePopText.RESOURCE_FILENAME = "battle/BattlePopText.csb"
BattlePopText.RESOURCE_BINDING = {
    ["moral"] = {["varname"] = "_nodeMoral"},
    ["hit"]   = {["varname"] = "_nodeHit"},
    ["blood"] = {["varname"] = "_nodeBlood"},
}

function BattlePopText:onCreate()
    BattlePopText.super.onCreate(self)
    self:setScale(0.8)

    self._aniAction = cc.CSLoader:createTimeline("battle/BattlePopText.csb")
    self:runAction(self._aniAction)
    self._aniAction:setFrameEventCallFunc(function(frame)
        self:animationEvent(frame)
    end)
end

function BattlePopText:animationEvent(frame)
    local str = frame:getEvent()
    if str == 'end' then
        self:removeSelf()
    end
end

function BattlePopText:popText(text_type, num)
    if num and num == 0 then
        self:removeSelf()
        return
    end

    local text_num = tostring(num)
    if num and num > 0 then
        text_num = '+' .. text_num
    end
    if text_type == uq.BattleRule.POP_TEXT.blood then
        local fnt = self._nodeBlood:getChildByName('txt_num')
        if num > 0 then
            fnt:setFntFile('font/hp.fnt')
        else
            fnt:setFntFile('font/hp_dec.fnt')
        end
        fnt:setString(text_num)
        self._aniAction:play('blood', false)
    elseif text_type == uq.BattleRule.POP_TEXT.moral then
        local fnt = self._nodeMoral:getChildByName('txt_num')
        local img_dec = self._nodeMoral:getChildByName('txt_desc')
        if num > 0 then
            fnt:setFntFile('font/moral.fnt')
            img_dec:loadTexture('img/battle/g04_000174.png')
        else
            fnt:setFntFile('font/moral_dec.fnt')
            img_dec:loadTexture('img/battle/j04_0000087.png')
        end
        fnt:setString(text_num)
        self._aniAction:play('moral', false)
    elseif text_type == uq.BattleRule.POP_TEXT.hit then
        self._aniAction:play('hit', false)
        self._nodeHit:getChildByName('txt_desc'):loadTexture('img/battle/s04_00231.png')
    elseif text_type == uq.BattleRule.POP_TEXT.against then
        self._aniAction:play('hit', false)
        self._nodeHit:getChildByName('txt_desc'):loadTexture('img/battle/s04_00232.png')
    elseif text_type == uq.BattleRule.POP_TEXT.restrain then
        self._aniAction:play('hit', false)
        self._nodeHit:getChildByName('txt_desc'):loadTexture('img/battle/s04_00233.png')
    end
end

return BattlePopText
local GuidePlot = class("GuidePlot", require("app.base.PopupBase"))
local WordMarquee = require('app/utils/WordMarquee')

GuidePlot.RESOURCE_FILENAME = "guide/GuidePlot.csb"
GuidePlot.RESOURCE_BINDING  = {
    ["Panel_1"]                          = {["varname"] = "_pnlClick"},
    ["center_node"]                      = {["varname"] = "_nodeCenter"},
    ["center_node/Node_1"]               = {["varname"] = "_nodeSpr1"},
    ["center_node/Node_2"]               = {["varname"] = "_nodeSpr2"},
    ["center_node/Node_1/Node_3"]        = {["varname"] = "_nodeSpine1"},
    ["center_node/Node_2/Node_4"]        = {["varname"] = "_nodeSpine2"},
    ["center_node/black_1_node"]         = {["varname"] = "_nodeSpr3"},
    ["center_node/black_2_node"]         = {["varname"] = "_nodeSpr4"},
    ["center_node/black_1_node/Node_3"]  = {["varname"] = "_nodeSpine3"},
    ["center_node/black_2_node/Node_4"]  = {["varname"] = "_nodeSpine4"},
    ["down_node"]                        = {["varname"] = "_nodeDown"},
    ["down_node/left_name"]              = {["varname"] = "_txtName1"},
    ["down_node/right_name"]             = {["varname"] = "_txtName2"},
    ["down_node/left_dec"]               = {["varname"] = "_txtDec1"},
    ["Button_1"]                         = {["varname"] = "_btnSkip"},
    ["center_node/img_bg_adapt"]         = {["varname"] = "_imgBg"},
    ["Image_1"]                          = {["varname"] = "_imgName1"},
    ["Image_1_0"]                        = {["varname"] = "_imgName2"},
    ["dec_node"]                         = {["varname"] = "_nodeDec"},
    ["dec_txt"]                          = {["varname"] = "_txtDec"},
    ["bg_pnl"]                           = {["varname"] = "_pnlBg"},
    ["Node_5"]                           = {["varname"] = "_nodeChapter"},
    ["Image_18"]                         = {["varname"] = "_imgChapter"},
    ["Image_16"]                         = {["varname"] = "_imgChapterTitle"},
    ["Image_17"]                         = {["varname"] = "_imgBgName"},
    ["Node_11"]                          = {["varname"] = "_nodeAction1"},
    ["Node_12"]                          = {["varname"] = "_nodeAction2"},
    ["action_node"]                      = {["varname"] = "_nodeAction"},
}

function GuidePlot:ctor(name, args)
    GuidePlot.super.ctor(self, name, args)
    self._args = args or {}
    self._data = self._args.data or {}
    self._xmlData = self._data.data or {}
    self._guideType = self._data.guide_type or uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE
    self._xml = {}
    self._id = self._xmlData.ident or 0
    self._endTime = os.time()
end

function GuidePlot:init()
    self:parseView()
    self:centerView()
    self._pnlClick:setContentSize(display.size)
    self:setLayerColor(0.5)
    self._countryId = uq.cache.role.country_id
    self._marquee = nil
    self._spineStr1 = ""
    self._spineStr2 = ""
    self:adaptBgSize()
    self:adaptBgSize(self._pnlBg)
    self:adaptBgSize(self._pnlClick)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = self._pnlClick:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._pnlClick)
    self._btnSkip:addClickEventListenerWithSound(function()
        local id = uq.cache.guide:getGuideSkipId(self._id)
        if id > 0 then
            self:dealNextGuideByTab(id)
        elseif id == 0 then
            local id = self._id
            local guide_type = self._guideType
            self:disposeSelf()
            if guide_type == uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE then
                uq.cache.guide:closeGuideById(id)
            elseif guide_type == uq.config.constant.GUIDE_BRANCH.TRIGGER_GUIDE then
                uq.cache.guide:closeTriggerGuideById(id)
            end
        else
            uq.fadeInfo(StaticData["local_text"]["guide.not.jump"])
        end
    end)
    self:refreshLayer()
end

function GuidePlot:refreshLayer()
    local tab = uq.cache.guide:getGuideInfoById(self._id)
    self._xml = tab or {}
    if not tab or next(tab) == nil then
        return
    end
    local is_hide = tab.generals and tab.generals ~= ""
    local is_talk = tab.type == uq.config.constant.GUIDE_TYPE.TALK
    local is_dec = tab.type == uq.config.constant.GUIDE_TYPE.DEC
    local is_chapter = tab.type == uq.config.constant.GUIDE_TYPE.CHAPTER_OPNE
    local is_show = is_talk and not is_hide
    self._nodeCenter:setVisible(is_show)
    self._nodeDown:setVisible(is_show)
    self._btnSkip:setVisible(is_show)
    self._nodeDec:setVisible(is_dec and not is_hide)
    self._nodeChapter:setVisible(is_chapter and not is_hide)
    if is_hide then
        self:showGeneralsById(tonumber(tab.generals))
        return
    end
    if is_talk then
        self:refreshLayerTalk(tab)
    elseif is_chapter then
        self:refreshLayerChapter(tab)
    else
        self:refreshLayerDec(tab)
    end
    self._endTime = os.time()
end

function GuidePlot:showGeneralsById(id)
    local info = {info = id, is_new = true, func = handler(self, self.nextGuideFromNewGenerals)}
    uq.cache.generals:clearNewGenerals()
    uq.showNewGenerals(info, false)
    uq.refreshNextNewGeneralsShow()
end

function GuidePlot:nextGuideFromNewGenerals()
    self:dealNextGuideByTab(uq.cache.guide:getGuideNextId(self._id))
end

function GuidePlot:refreshLayerDec(data)
    local tab = data or {}
    local str = tab["dec" .. uq.cache.role.country_id] or ""
    self._txtDec:setTextAreaSize(cc.size(320, 0))
    self._txtDec:setString(str)
end

function GuidePlot:refreshLayerChapter(data)
    uq.delayAction(self._nodeChapter, 1.5, function ()
        self:dealNextGuideByTab(uq.cache.guide:getGuideNextId(self._id))
    end)
    self._imgChapter:setVisible(false)
    self._imgChapter:loadTexture("img/guide/" .. data.animation_picture)
    uq.delayAction(self._imgChapter, 0.5, function ()
        self._imgChapter:setVisible(true)
    end)
    uq.playSoundByID(109)
    uq:addEffectByNode(self._nodeAction, 900171, 1, true, cc.p(0, 20))
    self._nodeAction1:setScaleX(0)
    self._imgChapterTitle:setVisible(false)
    self._nodeAction1:runAction(cc.ScaleTo:create(0.2, 1))
    uq.delayAction(self._imgChapterTitle, 0.2, function ()
        self._imgChapterTitle:setVisible(true)
    end)
    self._imgBgName:setScaleY(0)
    self._imgBgName:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.ScaleTo:create(0.1, 1)))
    uq.delayAction(self._nodeAction, 0.3, function ()
        uq:addEffectByNode(self._nodeAction, 900172, 1, true, cc.p(0, -20))
    end)
end

function GuidePlot:refreshLayerTalk(data)
    local tab = data or {}
    local path = "img/common/general_body/"
    local is_left = tab.pos == 1
    self._txtName1:setString(tab["name" .. self._countryId])
    self._txtName2:setString(tab["name" .. self._countryId])
    self._txtDec1:setString("")
    self._txtDec1:setVisible(true)
    self._imgBg:setVisible(false)
    self._txtName1:setVisible(is_left)
    self._txtName2:setVisible(not is_left)
    self._imgName1:setVisible(is_left)
    self._imgName2:setVisible(not is_left)
    for i = 1, 4 do
        local ii = i <= 2 and i or i - 2
        local node_spine = self["_nodeSpine" .. i]
        local body = tab["body" .. ii .. "_" .. self._countryId]
        local opacity = ii == tab.pos and 255 or 220
        local scale = tab["body" .. ii .."_scale" .. self._countryId] or 1
        node_spine:setOpacity(opacity)
        node_spine:setPositionY(tab["body" .. ii .. "oy_" .. self._countryId] - 150)
        node_spine:setScale(scale)
        node_spine:setVisible((i <= 2 and ii == tab.pos) or (i > 2 and ii ~= tab.pos))
        if body and body ~= "" and  body ~= self["_spineStr" .. i] then
            node_spine:removeAllChildren()
            local pre_path = "animation/spine/" .. body .. '/' .. body
            local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
            node_spine:addChild(anim)
            anim:setAnimation(0, 'idle', true)
            if self["_spineStr" .. i] ~= "" then
                self:addSpriteRunAction(i, self["_nodeSpr" .. i])
            end
            self["_spineStr" .. i] = body
        end
    end
    if tab.bg_icon and tab.bg_icon ~= "" then
        self._imgBg:setVisible(true)
        self._imgBg:loadTexture("img/bg/" .. tab.bg_icon)
    end
    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end
    self._marquee = WordMarquee:create(self._txtDec1, tab["dec" .. uq.cache.role.country_id], nil, 0.02)
    self._btnSkip:setVisible(uq.cache.guide:getGuideSkipId(self._id) >= 0)
end

function GuidePlot:addSpriteRunAction(idx, node)
    node:stopAllActions()
    local idx = idx <= 2 and idx or idx - 2
    local off_x = idx == 1 and -150 or 150
    local move1 = cc.MoveTo:create(0, cc.p(off_x, 0))
    local move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
    local fade = cc.FadeIn:create(0.5)
    node:setOpacity(0)
    node:runAction(cc.Sequence:create(move1, cc.Spawn:create(move2, fade)))
end

function GuidePlot:_onTouchBegin(touch, event)
    return true
end

function GuidePlot:_onTouchEnd(touch, event)
    if self._xml.type == uq.config.constant.GUIDE_TYPE.CHAPTER_OPNE then
        return true
    end
    if self._marquee and not self._marquee:finished() then
        self._marquee:showAll()
        self._marquee:dispose()
        self._marquee = nil
        return true
    end
    if self._endTime + 0.1 > os.time() then
        return true
    end
    self:dealNextGuideByTab(uq.cache.guide:getGuideNextId(self._id))
    return true
end

function GuidePlot:dealNextGuideByTab(next_id)
    if self._xml and self._xml.chapter and self._xml.chapter ~= 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN, data = self._xml.chapter})
    end
    local info = uq.cache.guide:getGuideInfoById(next_id)
    if not info or next(info) == nil then
        local guide_type = self._guideType
        if guide_type == uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE then
            uq.cache.guide:closeGuideById(self._id)
        elseif guide_type == uq.config.constant.GUIDE_BRANCH.TRIGGER_GUIDE then
            uq.cache.guide:closeTriggerGuideById(self._id)
        end
        self:disposeSelf()
        return
    end
    if info.type == uq.config.constant.GUIDE_TYPE.TALK or info.type == uq.config.constant.GUIDE_TYPE.DEC or info.type == uq.config.constant.GUIDE_TYPE.CHAPTER_OPNE then
        if self._guideType == uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE then
            uq.cache.guide:refreshNextGuideId(self._id, info.ident)
        end
        self._id = info.ident
        self:refreshLayer()
    elseif info.type == uq.config.constant.GUIDE_TYPE.FORCE then
        if self._guideType == uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE then
            uq.cache.guide:openGuide(info.ident)
        end
        self:disposeSelf()
    end
end

function GuidePlot:dispose()
    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end
    GuidePlot.super.dispose(self)
end

return GuidePlot
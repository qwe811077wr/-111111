local AchievementChapterOpen = class("AchievementChapterOpen", require('app.base.ModuleBase'))

AchievementChapterOpen.RESOURCE_FILENAME = "achievement/AchievementChapterOpen.csb"
AchievementChapterOpen.RESOURCE_BINDING = {
    ["Image_bg"]          = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["click_pnl"]         = {["varname"] = "_pnlClick",["events"] = {{["event"] = "touch",["method"] = "onCloseChapter"}}},
    ["Image_35"]          = {["varname"] = "_imgPrologue"},
    ["Node_2"]            = {["varname"] = "_nodePrologueName"},
    ["Node_7"]            = {["varname"] = "_nodePrologueNamePos"},
    ["Panel_11"]          = {["varname"] = "_panelPrologueContent"},
    ["Node_3"]            = {["varname"] = "_nodePrologueContent"},
    ["Text_10"]           = {["varname"] = "_txtName"},
    ["Text_12"]           = {["varname"] = "_txtContent"},
    ["open_node"]         = {["varname"] = "_nodeOpen"},
    ["end_node"]          = {["varname"] = "_nodeEnd"},
    ["bg_end_img"]        = {["varname"] = "_imgBgEnd"},
    ["txt_pnl"]           = {["varname"] = "_pnlTxt"},
    ["txt_node"]          = {["varname"] = "_nodeTxt"}
}

function AchievementChapterOpen:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize(self._imgBg)
    self:adaptBgSize(self._imgBgEnd)
    self._imgBg:setSwallowTouches(true)

    self._panelPrologueContent:setPosition(cc.p(-1000, -105))
    self._nodePrologueContent:setPosition(cc.p(2000, 190))
    self._chapterId = 0
    self._canOpen = false
end

function AchievementChapterOpen:onCreate()
    AchievementChapterOpen.super.onCreate(self)
end

function AchievementChapterOpen:onExit()
    AchievementChapterOpen.super:onExit()
end

function AchievementChapterOpen:onClose(event)
    if event.name ~= "ended" or not self._canOpen then
        return
    end
    if self._chapterId ~= 0 then
        uq.cache.guide:openTriggerGuide(uq.config.constant.GUIDE_TRIGGER.CHAPTER_START, self._chapterId)
    end
    self:disposeSelf()
end

function AchievementChapterOpen:onCloseChapter(event)
    if event.name ~= "ended" then
        return
    end
    self:showOpenChapter(self._chapterId)
end

function AchievementChapterOpen:_showPrologue()
    self._imgPrologue:setOpacity(0)
    self._nodePrologueName:setVisible(false)
    uq:addEffectByNode(self._imgBg, 900102, 1, true, nil, nil, 2)

    local fade_in = cc.FadeIn:create(0.8)
    local call_func = cc.CallFunc:create(handler(self, self._showPrologueName))
    local func_next = cc.CallFunc:create(handler(self, self._showPrologueContent))
    local move_interval = cc.MoveBy:create(1, cc.p(0, 0))
    local sequence = cc.Sequence:create(fade_in, call_func, move_interval, func_next, nil)
    self._imgPrologue:runAction(sequence)
end

function AchievementChapterOpen:_showPrologueName()
    self._nodePrologueName:setVisible(true)

    for i = 6, 9 do
        local node = self._nodePrologueName:getChildByName(string.format("Image_3%d", i))
        node:setVisible(false)
    end
    self:_showPrologueNameCell()
end

function AchievementChapterOpen:_showPrologueNameCell()
    self._index = 6
    local move_interval = cc.MoveBy:create(0.1, cc.p(0, 0))
    local call_func_one = cc.CallFunc:create(handler(self, self._runPrologueNameCellAction))
    local call_func_two = cc.CallFunc:create(handler(self, self._runPrologueNameCellAction))
    local call_func_three = cc.CallFunc:create(handler(self, self._runPrologueNameCellAction))
    local call_func_four = cc.CallFunc:create(handler(self, self._runPrologueNameCellAction))
    local spawn = cc.Spawn:create(call_func_one, call_func_two, call_func_three, call_func_four)
    local sequence = cc.Sequence:create(move_interval, spawn, nil)
    self._nodePrologueName:runAction(sequence)
end

function AchievementChapterOpen:_runPrologueNameCellAction()
    local node = self._nodePrologueName:getChildByName(string.format("Image_3%d", self._index))
    local pos_node = self._nodePrologueNamePos:getChildByName(string.format("Node_3%d", self._index))
    local x, y = pos_node:getPosition()
    node:setScale(2.3)

    local scale_to = cc.ScaleTo:create(0.05, 1)
    local move = cc.MoveTo:create(0.05, cc.p(x, y))
    local spawn = cc.Spawn:create(move, scale_to)
    node:setVisible(true)

    local move_interval = cc.MoveBy:create(0.1, cc.p(0, 0))
    local sequence = cc.Sequence:create(move_interval, spawn, nil)
    node:runAction(sequence)

    self._index = self._index + 1
end

function AchievementChapterOpen:_showPrologueContent()
    local bg_move = cc.MoveTo:create(0.7, cc.p(0, -105))
    local content_move = cc.MoveTo:create(0.7, cc.p(1000, 190))
    local call_func_one = cc.CallFunc:create(function ()
        self._canOpen = true
    end)
    self._panelPrologueContent:runAction(cc.Sequence:create(bg_move, call_func_one))
    self._nodePrologueContent:runAction(content_move)
end

function AchievementChapterOpen:setData(id)
    local func_open = function()
        self:showOpenChapter(id)
    end
    local xml = StaticData['end_achievements'] or {}
    if id <= 1 or not xml[id - 1] or not xml[id - 1].video then
        func_open()
        return
    end
    local back_function = function()
        self:showOpenChapter(id)
        uq.resumeBackGroundMusic()
    end
    local args = {
        name = "cg/" .. xml[id - 1].video,
        call_back = back_function
    }
    local video = uq.VideoPlayer.getVideoPlayer(args)
    if not video then
        func_open()
        return
    end
    uq.ModuleManager:getInstance():getCurScene():addChild(video)
    local attr = {
        title = StaticData['local_text']['label.skip.btn.des'],
        color = "#FFFFFF",
        font_size = 20,
        pos_x = 0.86,
        pos_y = 0.82
    }
    uq.pauseBackGroundMusic()
    video:playVideo(true)
    video:setSkipBtnAttr(attr)
end

function AchievementChapterOpen:showOpenChapter(id)
    local xml_data = StaticData['achievements'][id]
    if not xml_data then
        self._canOpen = true
        self:onClose({name = "ended"})
        return
    end
    self._txtName:setString(xml_data.des)
    self._chapterId = id
    if string.utfLen(xml_data.des2) > 25 then
        self._txtContent:setTextAreaSize(cc.size(800, 0))
        self._txtContent:setFontSize(26)
        self._txtContent:getVirtualRenderer():setLineHeight(50)
    end
    self._txtContent:setString(xml_data.des2)
    self._nodeOpen:setVisible(true)
    self._nodeEnd:setVisible(false)
    self:_showPrologue()
    uq:addEffectByNode(self._imgPrologue, 900103, -1, true)
end

function AchievementChapterOpen:showEndChapter(id)
    self._nodeOpen:setVisible(false)
    self._nodeEnd:setVisible(true)
    self._chapterId = id
    local xml = StaticData['end_achievements'][id - 1] or {}
    local tab_dec = string.split(xml.dec, ";")
    for i, v in ipairs(tab_dec) do
        self:addOneDecAction(i, v)
    end
    self._imgBgEnd:loadTexture("img/bg/zj/" .. xml.namePic)
end

function AchievementChapterOpen:addOneDecAction(idx, str)
    local pnl = self._pnlTxt:clone()
    self._nodeTxt:addChild(pnl)
    pnl:setVisible(true)
    pnl:getChildByName("Text_1"):setString(str)
    pnl:setOpacity(0)
    local move = cc.MoveBy:create(5, cc.p(0, 100))
    local fade = cc.FadeIn:create(0.2)
    local spwn = cc.Spawn:create(move, fade)
    local delay = cc.DelayTime:create(idx * 1.6)
    local func = cc.CallFunc:create(function ()
        pnl:removeFromParent()
        end)
    local seq = cc.Sequence:create(delay, spwn, func)
    pnl:runAction(seq)
end

return AchievementChapterOpen
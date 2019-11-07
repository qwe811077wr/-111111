local VideoPlayer = class('VideoPlayer', function()
    return ccui.Layout:create()
end)

function VideoPlayer:ctor(args)
    self._fileName = args.name
    self._callBack = args.call_back
    self._videoPlayer = nil
    self:init()
end

function VideoPlayer:init()
    self:setContentSize(display.size)
end

function VideoPlayer:playVideo(is_show_Skip)
    local function onVideoEventCallback(sener, eventType)
        if eventType == ccexp.VideoPlayerEvent.COMPLETED then
            uq.log("ccexp.VideoPlayerEvent.COMPLETED")
            if self._callBack then
                self._callBack()
            end
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                self:removeSelf()
            end)))
        end
     end
     self._videoPlayer = ccexp.VideoPlayer:create()
     if self._videoPlayer == nil then
        return
     end
     self._videoPlayer:setAnchorPoint(cc.p(0, 0))
     self._videoPlayer:setContentSize(display.size)
     self._videoPlayer:addEventListener(onVideoEventCallback)
     self._videoPlayer:setPosition(cc.p(0, 0))
     self:addChild(self._videoPlayer, 1)
     local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename(self._fileName)
    self._videoPlayer:setFileName(videoFullPath)
    self._videoPlayer:play()
    if not is_show_Skip then
        return
    end
    self._videoPlayer:addSkipButton()
end

function VideoPlayer:setSkipBtnAttr(attr)
    if self._videoPlayer then
        local str = json.encode(attr)
        self._videoPlayer:setSkipButtonAttr(str)
    end
end

function VideoPlayer.getVideoPlayer(args)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        return uq.VideoPlayer.new(args)
    else
        return nil
    end
end

uq.VideoPlayer = VideoPlayer
local TipsModule = class("TipsModule", require("app.base.ModuleBase"))

function TipsModule:ctor(name, args)
	TipsModule.super.ctor(self, name, args)
	self._args = args or {}
end

function TipsModule:init()
	local view = ccui.Layout:create()
	view:setTouchEnabled(true)
	view:setSwallowTouches(true)
 	view:ignoreContentAdaptWithSize(false)
	view:setContentSize( cc.size(display.width, display.height) )
	view:setBackGroundColorType(1)
	view:setBackGroundColorOpacity(0)
	view:setBackGroundColor(cc.c3b(0, 0, 0))
    self:setView(view)
	local listener = cc.EventListenerTouchOneByOne:create()
	--注册触屏开始事件
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self._view:getEventDispatcher()
    --事件派发器 注册一个node事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._view)

    self.root = ccui.ImageView:create("img/new_common/frame_view_4.png")
    self.root:setScale9Enabled(true)
    self.root:setCapInsets(cc.rect(10, 10, 351, 590))
    -- self.root:setAnchorPoint(cc.p(0, 1))
    self.root:ignoreContentAdaptWithSize(false)
    self._view:addChild(self.root)
    if self._args.pos then
    	self.root:setPosition(self._args.pos)
    else
    	self.root:setPosition(cc.p(display.width/2, display.height/2))
    end

    local d = self._args

    local w = d.w or 300

	local _fontName = d.fontName or "font/fzzzhjt.ttf" -- "font/hkchuyuan.ttf"
	local _fontSize = d.fontSize or 24

	local label = ccui.Text:create()
	label:ignoreContentAdaptWithSize(false)
	label:setFontSize(_fontSize)
	label:setFontName(_fontName)
	label:setTextAreaSize(cc.size(w, 100))
	label:enableOutline(cc.c3b(0x06, 0x0c, 0x11), 1)
	if d.color then
		label:setString(d.msg or "")
	else
		local msg = d.msg or ""
		label:setHTMLText(msg, nil, true)
	end
	label:setTextHorizontalAlignment(0)
	label:setTextVerticalAlignment(0)
	label:setTouchScaleChangeEnabled(false)
	label:setTouchEnabled(false)
	label:setAnchorPoint(0.5, 0.5)
	if d.color then
		label:setColor(d.color or cc.c3b(255, 255, 255))
	end
	label:setCascadeColorEnabled(true)
	label:setCascadeOpacityEnabled(true)
	self.root:setCascadeOpacityEnabled(true)
	self.root:addChild(label)

	local size = label:getContentSize()
	local news = cc.size(size.width+50, size.height+50)
	-- local news = cc.size(360, 360)
	self.root:setContentSize(news)

	label:setPosition(cc.p(news.width/2, news.height/2))

	local anchorX = 0
	if self._args.pos.x + news.width > display.width then
		anchorX = 1
	end
	local anchorY = 0
	if self._args.pos.y + news.height > display.height then
		anchorY = 1
	end
	self.root:setAnchorPoint(cc.p(anchorX, anchorY))
end

function TipsModule:_onTouchBegin(touch, event)
	local location = touch:getLocationInView()
	local point = self._view:convertToNodeSpace(location)
	local rect = self.root:getBoundingBox()
	if not cc.rectContainsPoint(rect, point) then
		uq.ModuleManager:getInstance():dispose(self:name())
	end
end

return TipsModule
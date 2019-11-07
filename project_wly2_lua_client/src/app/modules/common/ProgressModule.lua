local ProgressModule = class("ProgressModule", require("app.base.PopupBase"))

function ProgressModule:ctor(name, args)
	ProgressModule.super.ctor(self, name, args)
	self._args = args or {}
end

function ProgressModule:init()
	self._view = ccui.Layout:create()
	-- self._view:retain()
	self._view:setTouchEnabled(true)
	self._view:setSwallowTouches(true)
 	self._view:ignoreContentAdaptWithSize(false)
	self._view:setContentSize( cc.size(display.width, display.height) )
	self._view:setBackGroundColorType(1)
	self._view:setBackGroundColorOpacity(100)
	self._view:setBackGroundColor(cc.c3b(0, 0, 0))
	local function onTouch(event)
		return false
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	--注册触屏开始事件
    listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_BEGAN)
    --注册触屏移动事件
    listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_MOVED)
    --注册触屏结束事件
    listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_ENDED)
    --注册触屏结束事件
    listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self._view:getEventDispatcher()
    --事件派发器 注册一个node事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._view)


	local w = 150
	local rect = cc.rect(display.cx-w/2, display.cy+w/2, w, w)
	local node = self:drawNodeRoundRect(rect, 4, 10, cc.c4b(0, 0, 0, 1), cc.c4b(0, 0, 0, 1))
	node:setOpacity(150)
	self._view:addChild(node)

	-- loading04.png
	self.img = ccui.ImageView:create("img/a/loading04.png")
	self._view:addChild(self.img)
	self.img:setPosition(cc.p(display.cx, display.cy+15))
	self.img:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 180)))

    local label = ccui.Text:create()
	label:setFontSize(24)
	label:setFontName(uq.config.TTF_FONT)
	label:enableOutline(cc.c3b(0x06, 0x0c, 0x11), 1)	
	label:setTextHorizontalAlignment(1)
	label:setTextVerticalAlignment(1)
	label:setTouchScaleChangeEnabled(false)
	label:setTouchEnabled(false)
	label:setAnchorPoint(0.5, 0.5)
	label:setColor(cc.c3b(255, 255, 255))
	label:setCascadeColorEnabled(true)
	self._view:addChild(label)
	label:setPosition(display.cx, display.cy-w/2+30)
	if self._args.msg then
		label:setString(self._args.msg)
	else
		label:setString(uq.Language.text[136])
	end
end

function ProgressModule:dispose()
	ProgressModule.super.dispose(self)
end

-- 传入DrawNode对象，画圆角矩形
function ProgressModule:drawNodeRoundRect(rect, borderWidth, radius, color, fillColor)
	local drawNode = cc.DrawNode:create()
	-- segments表示圆角的精细度，值越大越精细
	local segments    = 200
	local origin      = cc.p(rect.x, rect.y)
	local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
	local points      = {}

	-- 算出1/4圆
	local coef     = math.pi / 2 / segments
	local vertices = {}

	for i=0, segments do
		local rads = (segments - i) * coef
		local x    = radius * math.sin(rads)
		local y    = radius * math.cos(rads)
		table.insert(vertices, cc.p(x, y))
	end

	local tagCenter      = cc.p(0, 0)
	local minX           = math.min(origin.x, destination.x)
	local maxX           = math.max(origin.x, destination.x)
	local minY           = math.min(origin.y, destination.y)
	local maxY           = math.max(origin.y, destination.y)
	local dwPolygonPtMax = (segments + 1) * 4
	local pPolygonPtArr  = {}

	-- 左上角
	tagCenter.x = minX + radius;
	tagCenter.y = maxY - radius;

	for i=0, segments do
		local x = tagCenter.x - vertices[i + 1].x
		local y = tagCenter.y + vertices[i + 1].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	-- 右上角
	tagCenter.x = maxX - radius;
	tagCenter.y = maxY - radius;

	for i=0, segments do
		local x = tagCenter.x + vertices[#vertices - i].x
		local y = tagCenter.y + vertices[#vertices - i].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	-- 右下角
	tagCenter.x = maxX - radius;
	tagCenter.y = minY + radius;

	for i=0, segments do
		local x = tagCenter.x + vertices[i + 1].x
		local y = tagCenter.y - vertices[i + 1].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	-- 左下角
	tagCenter.x = minX + radius;
	tagCenter.y = minY + radius;

	for i=0, segments do
		local x = tagCenter.x - vertices[#vertices - i].x
		local y = tagCenter.y - vertices[#vertices - i].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	if fillColor == nil then
		fillColor = cc.c4f(0, 0, 0, 0)
	end
	drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
	return drawNode
end

return ProgressModule
local Queue = require("app.utils.Queue")
local NotificationCenter = class("NotificationCenter")
local instance = nil

--------------
---------------
local function getNotifyCenterNode(  )
	-- body
	local notifyCenterNode = cc.Director:getInstance():getNotificationNode()
	if not notifyCenterNode then
		notifyCenterNode = cc.Node:create()
		cc.Director:getInstance():setNotificationNode(notifyCenterNode)
	end
	return notifyCenterNode
end

--------------
---------------
local NotifyNormalWidget = class("QNotifyNormalWidget")
function NotifyNormalWidget:ctor( param )
	-- body
	self._view ,self._action= uq.csLoaderNodeAndTimeline("ui/notify/NotifyWidget.csb")
	self._action:setFrameEventCallFunc(handler(self, self._onFrameEvent))
	local node = self._view:getChildByName("node")
	local parent = node:getChildByName("parent")
	self._icon = parent:getChildByName("icon")
	self._desc = parent:getChildByName("desc")
	self:loadData(param)
end

function NotifyNormalWidget:_onFrameEvent( frame )
	-- body
	if nil == frame then
	    return
	end
	local str = frame:getEvent()
	if str == "actionDisappearEnd" then
		if self._disAppearCallback then
			self._disAppearCallback()
		end
	end
end

function NotifyNormalWidget:loadData(param)
	-- body
	self._icon:loadTexture(param.icon)
	self._desc:setString(param.desc)
end

function NotifyNormalWidget:appear()
	-- body
	self._action:gotoFrameAndPlay(0,20,false)

end

function NotifyNormalWidget:disappear( callback )
	-- body
	self._action:gotoFrameAndPlay(21,40,false)
	self._disAppearCallback = callback;
end

function NotifyNormalWidget:getView(  )
	-- body
	return self._view
end

--------------
---------------
function NotificationCenter:ctor( )
	-- body
	
	self._queue = Queue.new(3)

	self._notifyWidget = nil
	self._notifyWidgetType = nil
end

-- param 参数说明 
-- tp 类型 0 
-- icon 图片路径
-- desc 描述 
-- time 显示时间

function NotificationCenter:push( params )
	-- body
	if not params then
		return
	end
	self._queue:push(params)

	if not self._notifyWidget then
		self:_appear()
	end
end


function NotificationCenter:_createNotifyWidget( params )
	-- body
	if params.tp  == 0 then
		if params.icon and params.desc then
			local node = NotifyNormalWidget.new(params)
			getNotifyCenterNode():addChild(node:getView())
			node:getView():setPosition(cc.p(display.width, display.height - 60 ))
			return node
		end
	end
end


function NotificationCenter:_appear( )
	-- body
	local data = self._queue:pop()
	if data then
		if self._notifyWidget then
			if self._notifyWidgetType == data.tp then
				self._notifyWidget:reload(data)
			else
				getNotifyCenterNode():removeAllChildren()
				self._notifyWidget = self:_createNotifyWidget(data)
			end
		else
			self._notifyWidget = self:_createNotifyWidget(data)
		end

		if not self._notifyWidget then
			self:_appear()
		else
			self._notifyWidget:appear()
		end

		if not data.time then
			data.time = 3
		end
		scheduler.performWithDelayGlobal(handler(self, self._disappear), data.time)
	else
		getNotifyCenterNode():removeAllChildren()
		self._notifyWidget = nil
	end
end


function NotificationCenter:_disappear()
	-- body
	if self._notifyWidget then
		self._notifyWidget:disappear(handler(self, self._appear))
	end
end

instance = NotificationCenter.new()
uq.NotificationCenter = instance

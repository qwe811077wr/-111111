--[[
	定时器Proxy,用于处理游戏中需要定时操作的逻辑
	提供了添加和移除定时器的接口
--]]
local uq = cc.exports.uq or {}
local TimerProxy = class("TimerProxy")

local TAG = "<TimerProxy | "

local _scheduler = cc.Director:getInstance():getScheduler()


local TIMER_STATUS = {
	INIT = "timer_init";
	DELAY = "timer_delay";
	RUNNING = "timer_running";
	FINISH = "timer_finished";
}


function TimerProxy:ctor()
	self._timers = {}
	self._platform = cc.Application:getInstance():getTargetPlatform()

	local timer_init, timer_delay, timer_running,timer_trace;
	timer_trace = function(msg)
		print("----------------------------------------")
		print("LUA TIMERPROXY ERROR: " .. tostring(msg) .. "\n")
		print(debug.traceback())
		print("---------------------------------------")
	end

	timer_init = function (timer, dt)
		if timer.delay then
			timer._status = TIMER_STATUS.DELAY
			timer._elapseDelay = timer.delay
			return timer_delay(timer, dt)
		end

		timer._status = TIMER_STATUS.RUNNING
		timer._elapse = timer.interval
		return timer_running(timer, dt)
	end

	timer_delay = function (timer, dt)
		timer._elapseDelay = timer._elapseDelay - dt
		if timer._elapseDelay > 0.0 then
			return
		end

		timer._status = TIMER_STATUS.RUNNING
		timer._elapse = timer.interval
	end

	timer_running = function (timer, dt)
		timer._elapse = timer._elapse - dt
		if timer._elapse > 0.0 then
			return
		end

		timer._elapse = timer.interval
		timer._usedTimes = timer._usedTimes + 1

		if timer.callback then
			xpcall(timer.callback, timer_trace, timer.tag, dt);
		end

		if timer._usedTimes >= timer.times then
			timer._status = TIMER_STATUS.FINISH
		end
	end

	local function _timer_validate()
		for k, v in pairs(self._timers) do
			if v._status == TIMER_STATUS.FINISH then
				self._timers[k] = nil
			end
		end
	end

	local function _timer_update(timer, dt)
		if timer._status == TIMER_STATUS.INIT then
			return timer_init(timer, dt)
		end

		if timer._status == TIMER_STATUS.DELAY then
			return timer_delay(timer, dt)
		end

		if timer._status == TIMER_STATUS.RUNNING then
			return timer_running(timer, dt)
		end

		if timer._status == TIMER_STATUS.FINISH then
			return
		end
		uq.log(TAG .. "_timer_update - timer status error.")
	end

	local function _scheduleUpdate(dt)
		local t = uq.curFloatSecond() - self._lastTime;
		self._lastTime = uq.curFloatSecond()
		for _, v in pairs(self._timers) do
			_timer_update(v, t)
		end

		_timer_validate()
	end
	self._lastTime = uq.curFloatSecond()
	self._schedulerEntry = _scheduler:scheduleScriptFunc(_scheduleUpdate, 0.0, false)
end

--[[
	添加定时器
	@timer_tag - 定时器标识，建议使用字符串进行标识
	@dt - 定时器回调函数
	@interval - 定时器间隔时间，默认(不填时)为0.0的间隔，即一帧执行一次
	@times - 定时器重复定数，0次为无效定时器，负数次则为无限重复定时器，默认(不填时)为1次
	@delay - 延时多长时间开始定时，默认(不填时)为立即开始
--]]
function TimerProxy:addTimer(timer_tag, callback, interval, times, delay)
	-- body
	assert(timer_tag, "timer_tag is error.")
	assert(type(callback) == "function", "Timer callback error.")

	if self._timers[timer_tag] then
		uq.log(TAG .. "addTimer - timer_tag is existed.", timer_tag)
		return false
	end

	interval = interval or 0.0
	interval = tonumber(interval)
	if interval < 0.0 then
		interval = 0.0
	end

	times = times or 1
	times = math.ceil(tonumber(times))
	if times == 0 then
		uq.log(TAG .. "addTimer - times error with 0")
		return
	end

	if times < 0 then
		times = math.huge
	end

	delay = delay or false
	if delay ~= false then
		delay = tonumber(delay)
		if delay < 0.0 then
			delay = false
		end
	end

	self._timers[timer_tag] = {
		tag = timer_tag;

		interval = interval;
		times = times;
		callback = callback;
		delay = delay;

		_status = TIMER_STATUS.INIT;
		_elapse = 0;
		_usedTimes = 0;
		_elapseDelay = 0;
	}
	return true
end

--[[
	移除指定的定时器
	@timer_tag - 调用addTimer时传入的timerTag值
--]]
function TimerProxy:removeTimer(timer_tag)
	if self._timers[timer_tag] then
		self._timers[timer_tag] = nil
	end
end

--[[
	查询指定的定时器是否有效
	@timer_tag - 调用addTimer时传入的timerTag值
--]]
function TimerProxy:hasTimer(timer_tag)
	if self._timers[timer_tag] then
		return true
	end

	return false
end

function TimerProxy:cleanAllTimer()
    self._timers = {}
end

function TimerProxy:dispose()
	_scheduler:unscheduleScriptEntry(self._schedulerEntry)
end

uq.TimerProxy = uq.TimerProxy or TimerProxy:create()
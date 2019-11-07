local Preloader = class("Preloader")

Preloader._INSTANCE = nil

function Preloader:ctor()
	self._queue = {}
	self._cfg_res = {}
	self._httpDownloader = uq.HttpDownload:create()
	local listener = cc.EventListenerCustom:create(self._httpDownloader:eventName(), handler(self, self._onHttpEvent))
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
	self._lastLoadResTime = os.clock()
	self._scheduled = false
end

function Preloader:getInstance()
	if not Preloader._INSTANCE then
		Preloader._INSTANCE = Preloader:create()
		Preloader._INSTANCE:init()
	end
	return Preloader._INSTANCE
end

function Preloader:init()	
	self:_loadRes()
end

function Preloader:load(path, cb)
	table.insert(self._queue, {['path'] = path, ['cb'] = cb})
	if #self._queue == 1 then
		self:_scheduleLoading()
	end
end

function Preloader:_scheduleLoading()	
	while #self._queue > 0 do
		local item = self._queue[1]		
		if not cc.FileUtils:getInstance():isFileExist(item.path) then
			local path = uq.config.live_download_path .. item.path
			cc.FileUtils:getInstance():createDirectory(self:_filePath(path))
			self._httpDownloader:downloadFile(uq.config.res_addr .. '/res/' .. item.path, path, item.path)
			break
		else			
			if item.cb then
				pcall(function()
					item.cb(item.path)
				end)
			end
			table.remove(self._queue, 1)
		end
	end
	if #self._queue == 0 then
		self:_loadRes()
	end
end

function Preloader:_loadRes()
	while #self._cfg_res > 0 do
		local path = self._cfg_res[1]
		if cc.FileUtils:getInstance():isFileExist(path) then
			table.remove(self._cfg_res, 1)
		else
			if os.clock() >= self._lastLoadResTime + 0.5 then
				self._lastLoadResTime = os.clock()
				print(os.clock() .. " load " .. path)
				self:load(path, handler(self, self._resLoaded))
			elseif not self._scheduled then
				self._scheduled = true
				scheduler.performWithDelayGlobal(function()
					self._scheduled = false
					self:_loadRes()
				end, 0.5)
			end
			break
		end
	end
end

function Preloader:_resLoaded(path, evt)
	if not evt or evt:getEventCode() ~= 1 then
		table.remove(self._cfg_res, 1)
		if #self._queue == 0 then
			self:_loadRes()
		end
	end
end

function Preloader:_onHttpEvent(evt)
	local item = self._queue[1]
	if item.cb then
		pcall(function()
			item.cb(item.path, evt)
		end)		
	end
	if evt:getEventCode() ~= 1 then
		--print(os.time() .. " item~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" .. item.path)
		table.remove(self._queue, 1)
		self:_scheduleLoading()
	end
end

--根据文件位置取出文件路径
function Preloader:_filePath(path)
	return string.match(path, ".+/")
end

uq.Preloader = Preloader
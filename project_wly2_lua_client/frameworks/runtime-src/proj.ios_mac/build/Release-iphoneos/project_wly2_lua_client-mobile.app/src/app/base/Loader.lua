local Loader = class('Loader')

Loader._INSTANCE = nil

function Loader:ctor()
    self._queue = {}
end

function Loader:getInstance()
    if not Loader._INSTANCE then
        Loader._INSTANCE = Loader:create()
    end
    return Loader._INSTANCE
end

function Loader:addImageAsync(path, cb)
    table.insert(self._queue, {['path'] = path, ['cb'] = cb})
end

function Loader:adddPlistAsync(plist, path, cb)
    table.insert(self._queue, {['plist'] = plist, ['path'] = path, ['cb'] = cb})
end

function Loader:startLoad()
    if #self._queue >= 1 then
        self:_scheduleLoading()
    end
end

function Loader:_scheduleLoading()
    if #self._queue == 0 then
        return
    end
    local item = self._queue[1]
    --uq.log('Loader:_scheduleLoading', item, cc.FileUtils:getInstance():isFileExist(item.path))
    if cc.FileUtils:getInstance():isFileExist(item.path) then
        display.loadImage(item.path, handler(self, self._loaded))
    else
        uq.Preloader:getInstance():load(item.path, handler(self, self._onHttpEvent))
    end
end

function Loader:_loaded(texture)
    local item = self._queue[1]
    if item and item.plist then
        local _texture = display.getImage(item.path)
        --assert(_texture, string.format("The texture %s, %s is unavailable.", item.plist, item.path))
        if _texture then
            display.loadSpriteFrames(item.plist, item.path)
        else
            local fileUtils = cc.FileUtils:getInstance()
            local fullPath = fileUtils:fullPathForFilename(item.path)
            fileUtils:removeFile(fullPath)
        end
    end
    if item and item.cb then
        pcall(function()
            item.cb(texture, item.path)
        end)
    end
    table.remove(self._queue, 1)
    self:_scheduleLoading()
end

function Loader:_onHttpEvent(path, event)
    local item = self._queue[1]
    if not event or event:getEventCode() ~= 1 then
        display.loadImage(item.path, handler(self, self._loaded))
    end
end

uq.Loader = Loader
local ANIMATION_PATTERN = 'animation/%s/%s/%s'
local ANIMATION_PATH_PATTERN = 'animation/%s/%s'
local ANIMATION_DESC_PATH = 'animation/%s/animation.txt'

local FRAME_TIME_INTERVAL = 1 / 12

local AnimationManager = {
    _cache = {},
    _effect = {},
}

function AnimationManager:getInstance()
    return self
end

function AnimationManager:getAction(part, name)
    local prefix = string.format(ANIMATION_PATH_PATTERN, part, name)
    if self._cache[part] then
        if self._cache[part][name] then
            self._cache[part][name].ref = self._cache[part][name].ref + 1
            return self._cache[part][name].ani
        end
    else
        self._cache[part] = {}
    end
    self._cache[part][name] = {}
    self._cache[part][name].ani = self:_loadAnimation(part, name)
    self._cache[part][name].ref = 1
    return self._cache[part][name].ani
end

function AnimationManager:getEffect(id, action, part, async)
    if not action then
        action = 'default'
    end
    if not part then
        part = 'effect'
    end
    local prefix = string.format(ANIMATION_PATH_PATTERN, part, tostring(id))
    local name = prefix .. '-' .. action

    if self._effect[name] then
        return self._effect[name]
    else
        if async then
            self:loadEffectAsync(id, nil, part)
        else
            self:_loadEffect(id, part)
        end
        return self._effect[name]
    end
end

--特效加载，异步加载与即时加载
function AnimationManager:loadEffectAsync(id, callback, part, add_cache)
    part = part or 'effect'

    local prefix = string.format(ANIMATION_PATH_PATTERN, part, tostring(id))
    local plist = prefix .. '.plist'
    local png = prefix .. '.png'
    if not cc.FileUtils:getInstance():isFileExist(plist) then
        return
    end
    local plist_file = cc.FileUtils:getInstance():getValueMapFromFile(plist)
    local frame_map = {}
    for k, v in pairs(plist_file.frames) do
        local parts = string.split(k, '/')
        local filename = parts[#parts]
        parts = string.split(filename, '.')
        local name_part = string.split(parts[1], '_')
        frame_map[tonumber(name_part[#name_part])] = k
    end

    local animation = nil

    local function loadEnd()
        local spriteFrameCache = cc.SpriteFrameCache:getInstance()

        local frames = {}
        for _, v in pairs(frame_map) do
            table.insert(frames, spriteFrameCache:getSpriteFrame(v))
        end

        animation = display.newAnimation(frames, FRAME_TIME_INTERVAL)
        if add_cache then
            display.setAnimationCache(prefix .. '-default', animation)
        end
        self._effect[prefix .. "-default"] = animation
        if callback then
            callback(animation)
        end
    end

    if callback then
        display.loadSpriteFrames(plist, png, loadEnd)
    else
        display.loadSpriteFrames(plist, png)
        loadEnd()
        return animation
    end
end

function AnimationManager:_loadEffect(id, part)
    if not part then
        part = 'effect'
    end
    local prefix = string.format(ANIMATION_PATH_PATTERN, part, tostring(id))
    local plist = prefix .. '.plist'
    local png = prefix .. '.png'
    if not cc.FileUtils:getInstance():isFileExist(plist) then
        return
    end
    local plist_file = cc.FileUtils:getInstance():getValueMapFromFile(plist)
    local frame_map = {}
    for k, v in pairs(plist_file.frames) do
        local parts = string.split(k, '/')
        local filename = parts[#parts]
        parts = string.split(filename, '.')
        local name_part = string.split(parts[1], '_')
        frame_map[tonumber(name_part[#name_part])] = k
    end
    display.loadSpriteFrames(plist, png)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local descFile = prefix .. '.txt'
    if cc.FileUtils:getInstance():isFileExist(descFile) then
        local rows = string.split(cc.FileUtils:getInstance():getStringFromFile(descFile), '\n')
        for _, v in pairs(rows) do
            v = string.gsub(v, '\r', '')
            if #v > 0 and string.sub(v, 1, 1) ~= '#' then
                local fields = string.split(v, ',')
                local parts = string.split(fields[2], '-')
                local frames = {}
                for i = tonumber(parts[1]), tonumber(parts[2]) do
                    table.insert(frames, spriteFrameCache:getSpriteFrame(frame_map[i]))
                end
                local animation = display.newAnimation(frames, fields[#fields] / #frames / 1000)
                display.setAnimationCache(prefix .. '-' .. fields[1], animation)
                self._effect[prefix .. '-' .. fields[1]] = animation
            end
        end
    else
        local frames = {}
        for _, v in pairs(frame_map) do
            table.insert(frames, spriteFrameCache:getSpriteFrame(v))
        end
        local animation = display.newAnimation(frames, FRAME_TIME_INTERVAL)
        display.setAnimationCache(prefix .. '-' .. 'default', animation)
        self._effect[prefix .. '-' .. 'default'] = animation
    end
end

function AnimationManager:_loadAnimation(part, name)
    local dir_str = {'NW', 'N', 'NE', 'W', 'E', 'SW', 'S', 'SE'}
    local ret = {}
    local prefix = string.format(ANIMATION_PATH_PATTERN, part, name)
    local plist = prefix .. '.plist'
    local png = prefix .. '.png'
    local descFile = prefix .. '.txt'
    if not cc.FileUtils:getInstance():isFileExist(descFile) then
        descFile = string.format(ANIMATION_DESC_PATH, part)
    end
    if not cc.FileUtils:getInstance():isFileExist(plist) then
        return ret
    end
    local plist_file = cc.FileUtils:getInstance():getValueMapFromFile(plist)
    local frame_map = {}
    for k, v in pairs(plist_file.frames) do
        local parts = string.split(k, '/')
        local filename = parts[#parts]
        parts = string.split(filename, '.')
        frame_map[parts[1]] = k
    end
    display.loadSpriteFrames(plist, png)
    local plist2 = prefix .. '_2.plist'
    if cc.FileUtils:getInstance():isFileExist(plist2) then
        local png2 = prefix .. '_2.png'
        local plist_file = cc.FileUtils:getInstance():getValueMapFromFile(plist2)
        for k, v in pairs(plist_file.frames) do
            local parts = string.split(k, '/')
            local filename = parts[#parts]
            parts = string.split(filename, '.')
            frame_map[parts[1]] = k
        end
        display.loadSpriteFrames(plist2, png2)
    end

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local rows = string.split(cc.FileUtils:getInstance():getStringFromFile(descFile), '\n')
    for _, v in pairs(rows) do
        v = string.gsub(v, '\r', '')
        if #v > 0 and string.sub(v, 1, 1) ~= '#' then
            local fields = string.split(v, ':')
            local action_name = fields[1]
            fields = string.split(fields[2], ';')
            local time = tonumber(fields[2])
            fields = string.split(fields[1], ',')

            local full_name = string.format(ANIMATION_PATTERN, part, name, action_name)
            local name_row = string.split(action_name, '_')
            if #name_row > 1 then
                --多方向动作
                for k, dir in ipairs(dir_str) do
                    local frames = {}
                    for idx = 1, #fields do
                        local frame_name = string.format('%s_%s_%s%d', name, name_row[1], dir, idx - 1)
                        table.insert(frames, spriteFrameCache:getSpriteFrame(frame_map[frame_name]))
                    end
                    local animation = display.newAnimation(frames, time / #frames)
                    animation.total_time = time
                    display.setAnimationCache(full_name .. k, animation)
                    ret[action_name .. k] = animation
                end
            else
                local frames = {}
                for idx = 1, #fields do
                    table.insert(frames, spriteFrameCache:getSpriteFrame(frame_map[name .. '_' .. fields[idx]]))
                end
                local animation = display.newAnimation(frames, time / #frames)
                animation.total_time = time
                display.setAnimationCache(full_name, animation)
                ret[action_name] = animation
            end
        end
    end
    return ret
end

function AnimationManager:dispose(part, name)
    if not self._cache[part] then
        return
    end

    if not self._cache[part][name] then
        return
    end
    if self._cache[part][name].ref then
        self._cache[part][name].ref = self._cache[part][name].ref - 1
        if self._cache[part][name].ref > 0 then
            return
        end
    end

    for k, v in pairs(self._cache[part][name].ani) do
        display.removeAnimationCache(string.format(ANIMATION_PATTERN, part, name, k))
    end
    self._cache[part][name] = nil
end

function AnimationManager:releaseResource()
    for _, part in pairs(self._cache) do
        for name, item in pairs(part) do
            for k, v in pairs(item.ani) do
                display.removeAnimationCache(string.format(ANIMATION_PATTERN, part, name, k))
            end
        end
    end
    self._cache = {}

    for path, item in pairs(self._effect) do
        display.removeAnimationCache(path)
    end
    self._effect = {}
end

function AnimationManager:releaseEffect(id, action, part)
    if not id then
        return
    end

    if not action then
        action = 'default'
    end
    if not part then
        part = 'effect'
    end
    local prefix = string.format(ANIMATION_PATH_PATTERN, part, tostring(id))
    local name = prefix .. '-' .. action
    if self._effect[name] then
        display.removeAnimationCache(name)
        self._effect[name] = nil
    end
end

function AnimationManager:getAnimation(part, action)
    if self._cache[part] and self._cache[part][action] then
        return self._cache[part][action].ani
    end
    return nil
end

uq.AnimationManager = AnimationManager
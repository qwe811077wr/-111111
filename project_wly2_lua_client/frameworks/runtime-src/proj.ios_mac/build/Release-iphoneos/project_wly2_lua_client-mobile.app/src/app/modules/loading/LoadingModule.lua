local LoadingModule = class("LoadingModule", require("app.base.ModuleBase"))

LoadingModule.RESOURCE_FILENAME = "load/LoadingModule.csb"
LoadingModule.RESOURCE_BINDING = {
    ["load_1_img"]           = {["varname"] = "_imgload1"},
    ["load_2_img"]           = {["varname"] = "_imgload2"},
    ["load_3_img"]           = {["varname"] = "_imgload3"},
    ["Button_1"]             = {["varname"] = "_btnLeft"},
    ["Button_2"]             = {["varname"] = "_btnRight"},
    ["Text_2"]               = {["varname"] = "_txtDec"},
    ["img_bg_adapt"]         = {["varname"] = "_sprBg"},
}

function LoadingModule:ctor(name, args)
    LoadingModule.super.ctor(self, name, args)
    self._args = args
    self._timeId = nil
    self._res = {}
    if args.imgs then
        for i, v in ipairs(args.imgs) do
            table.insert(self._res, v)
        end
    end
    self._plist = {}
    if args.plist then
        local png_format = "%s.png"
        local plist_format = "%s.plist"
        for i, v in ipairs(args.plist) do
            local png = string.format(png_format, v)
            local plist = string.format(plist_format, v)
            table.insert(self._plist, {png = png, plist = plist})
        end
    end
    self._cb = args.cb
    self._count = 0
    self._params = args.params
end

function LoadingModule:init()
    self._num = 0
    self:centerView()
    self:adaptBgSize()
    self:_loadRes()
    self._txtDec:setString(self:getRandomDec())
    local img = self:getRandomBg()
    if img ~= "" then
        self._sprBg:setTexture(img)
    end
    self._timerDec = "_loading" .. tostring(self)
    uq.TimerProxy:removeTimer(self._timerDec)
    uq.TimerProxy:addTimer(self._timerDec, handler(self, self.changeTxtTips), 5, -1)
end

function LoadingModule:dispose()
    uq.TimerProxy:removeTimer(self._timerDec)
    self._res = {}
    self._plist = {}
    self._count = 0
    LoadingModule.super.dispose(self)
end

function LoadingModule:getRandomDec()
    local tab_tips = StaticData['loading_tips'] or {}
    if not tab_tips or next(tab_tips) == nil then
        return ""
    end
    local rand_idx = math.random(1, #tab_tips)
    if tab_tips[rand_idx] and tab_tips[rand_idx].des then
        return tab_tips[rand_idx].des
    end
    return ""
end

function LoadingModule:getRandomBg()
    local tab_tips = StaticData['loading_pictures'] or {}
    if not tab_tips or next(tab_tips) == nil then
        return ""
    end
    local rand_idx = math.random(1, #tab_tips)
    if tab_tips[rand_idx] and tab_tips[rand_idx].name then
        return "img/bg/" .. tab_tips[rand_idx].name
    end
    return ""
end

function LoadingModule:timerDec()
    self._num = self._num + 1
    if self._num > 3 then
        self._num = 0
    end
    for i = 1, 3 do
        self["_imgload" .. i]:setVisible(i <= self._num)
    end
end

function LoadingModule:changeTxtTips()
    self._txtDec:setString(self:getRandomDec())
end

function LoadingModule:_fileLoaded(texture, path)
    self._count = self._count + 1
    local max = #self._res + #self._plist
    local now = self._count * 100 / max
    if now >= 100 and not self._delay then
        uq.delayAction(self, 0.01, handler(self, self._finish))
    end
end

function LoadingModule:_loadRes()
    for i,v in ipairs(self._plist) do
        uq.Loader:getInstance():adddPlistAsync(v.plist, v.png, handler(self, self._fileLoaded))
    end

    for i,v in ipairs(self._res) do
        uq.Loader:getInstance():addImageAsync(v, handler(self, self._fileLoaded))
    end

    uq.Loader:getInstance():startLoad()

    if #self._plist == 0 and #self._res == 0 then
        self._delay = true
        uq.delayAction(self, 0.01, handler(self, self._finish))
    end
end

function LoadingModule:_finish()
    local cb = self._cb
    local params = self._params
    self:disposeSelf()

    if cb then
        uq.runCmd(cb, {unpack(checktable(params))})
    end
end

function LoadingModule:onCleanup()
end

return LoadingModule
local Recruit = class('Recruit')

function Recruit:ctor()
    self._recruitInfo = {}
    self._times = 0
    self._maxTimes = 2
    self._showRecruitGenerals = {}
    network:addEventListener(Protocol.S_2_C_JIUGUAN_LOAD, handler(self, self._onJiuGuanLoad))
    network:addEventListener(Protocol.S_2_C_JIUGUAN_REFRESH, handler(self, self._onJiuGuanRefresh))
    network:addEventListener(Protocol.S_2_C_JIUGUAN_RECRUIT, handler(self, self._onJiuGuanRecrult))
    network:addEventListener(Protocol.S_2_C_JIUGUAN_RECRUIT_END, handler(self, self._onJiuGuanRecrultEnd))
    network:addEventListener(Protocol.S_2_C_GENEERAL_DELETE, handler(self, self._onJiuGuanGeneralsDelete))
end

function Recruit:_onJiuGuanLoad(msg)
    self:dealDataRecruit(msg)
end

function Recruit:dealDataRecruit(msg)
    local data = msg.data.data
    self._recruitInfo = data[1] or {}
    if self._recruitInfo and self._recruitInfo.refresh_times then
        self._times = self._recruitInfo.refresh_times
    end
end

function Recruit:_onJiuGuanRecrultEnd(msg)
    local data = msg.data
    local name = ""
    if data.general_index ~= -1 and self._recruitInfo.generals and next(self._recruitInfo.generals) ~= nil then
        for k, v in pairs(self._recruitInfo.generals) do
            if v.index == data.general_index then
                local left_num = data.succeed == 1 and -1 or -2
                v.left_time = left_num
                name = v.name
            end
        end
    end
    self._recruitInfo.hasbegin = 0
    if data.succeed == 0 then
        data.info[1] = {name = name}
    else
        uq.cache.generals:_refreshGeneralInfo(data.info[1])
    end
    table.insert(self._showRecruitGenerals, {info = data})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RECRUIT_REFRESH})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RECRUIT_GENERALS})
end

function Recruit:_onJiuGuanGeneralsDelete(msg)
    local data = msg.data
    if data.general_id then
        uq.cache.generals:deleteGeneralsById(data.general_id)
    end
end

function Recruit:_onJiuGuanRecrult(msg)
    local data = msg.data
    for k, v in pairs(self._recruitInfo.generals) do
        if v.index == data.general_index then
            v.rate = math.min(self:getCostUpById() * 1000 + v.rate, 1000)
            v.left_time = data.left_time
            self._recruitInfo.hasbegin = 1
        end
    end
    uq.fadeInfo(StaticData["local_text"]["recruit.gift.start"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RECRUIT_REFRESH})
end

function Recruit:getCostUpById(id)
    local xml = StaticData['jiu_guan'].Cost or {}
    if xml and xml[1] and xml[1].getProbUp then
        return xml[1].getProbUp
    end
    return 0
end

function Recruit:showNewRecruitGenerals()
    if not self._showRecruitGenerals or next(self._showRecruitGenerals) == nil then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_UNLOCKED_VIEW)
    if panel then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.RECRUIT_SUCCESS)
    if panel then
        return
    end
    local tab = table.remove(self._showRecruitGenerals, 1)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.RECRUIT_SUCCESS, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 20, moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE , close_open_action = true, data = tab})
end

function Recruit:getSurplusTimes()
    return math.max(self._maxTimes - self._times, 0)
end

function Recruit:_onJiuGuanRefresh(msg)
    self:dealDataRecruit(msg)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RECRUIT_REFRESH})
end

function Recruit:isRecruitGenerals()
    return self._recruitInfo.hasbegin == 1
end

function Recruit:getRecruitGenerals()
    return self._recruitInfo.begin_general or {}
end

function Recruit:getRecruitListData()
    return self._recruitInfo.generals or {}
end

return Recruit
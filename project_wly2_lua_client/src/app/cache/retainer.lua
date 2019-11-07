local Retainer = class("Retainer")

function Retainer:ctor()
    self._suzerain = {}
    self._courtier = {}
    self._allList  = {}
    self._refreshTime = {}
    self._suzerainLimitLv = 110
    self._courtierLimitLv = 50
    self._courtierMaxNum = 3
    self._suzerainIntimacy = 0
    self._suzerainEvents = {}
    network:addEventListener(Protocol.S_2_C_ZONG_LOAD_INFO, handler(self, self._onZongLoadInfo))
    network:addEventListener(Protocol.S_2_C_ZONG_DISPART, handler(self, self._onZongDispapt))
    network:addEventListener(Protocol.S_2_C_ZONG_LOAD_LIST, handler(self, self._onZongLoadList))
    network:addEventListener(Protocol.S_2_C_ZONG_HANDLE_APPLY, handler(self, self._onZongHandleApply))
    network:addEventListener(Protocol.S_2_C_ZONG_APPLY, handler(self, self._onZongApply))
    network:addEventListener(Protocol.S_2_C_ZONG_NOTIFY, handler(self, self._onZongNotify))
    network:addEventListener(Protocol.S_2_C_ZONG_DISPART_NOTIFY, handler(self, self._onZongDispartNotify))
    network:addEventListener(Protocol.S_2_C_ZONG_DRAW_EVENT, handler(self, self._onDrawEvent))
end

function Retainer:_onZongLoadInfo(evt)
    local data = evt.data
    self._suzerain = data.zong_info
    self._suzerainIntimacy = data.intimacy
    self._suzerainEvents = data.events
    self._courtier = data.apprentices
end

function Retainer:_onZongDispapt(evt)
    if evt.data.ret == 0 then
        self:dealDispart(evt, 0)
    end
end

function Retainer:_onZongDispartNotify(evt)
    self:dealDispart(evt, 1)
end

function Retainer:dealDispart(evt, dispart_type)
    local role_id = evt.data.role_id or 0
    if evt.data.dispart_type == dispart_type then
        self._suzerain = {}
        self._suzerainIntimacy = 0
    else
        for k, v in pairs(self._courtier) do
            if v.info and v.info[1] and v.info[1].id == role_id then
                table.remove(self._courtier, k)
                break
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_RETAINER_CHANGE})
end

function Retainer:_onZongLoadList(evt)
    local data = evt.data
    if not self._allList[data.list_type] then
        self._allList[data.list_type] = {}
    end
    self._allList[data.list_type] = data
    self._refreshTime[data.list_type] = data.cd_time + os.time()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_LOAD_LIST, data = data})
end

function Retainer:_onZongHandleApply(evt)
    local data = evt.data
    if data.ret ~= 0 then
        uq.fadeInfo(StaticData["local_text"]["retainer.fail.add"])
        return
    end
    local type_apply = uq.config.constant.RETAINER_LIST.COURTIER_APPLY
    if data.apply_list == 0 then
        type_apply = uq.config.constant.RETAINER_LIST.SUZERAIN_APPLY
    end
    if data.op_type == 0 then
        network:sendPacket(Protocol.C_2_S_ZONG_LOAD_INFO, {})
    end
    local tab = self:getListDataByType(type_apply)
    if tab and tab.roles then
        for k, v in pairs(tab.roles) do
            if v.id == data.role_id then
                table.remove(tab.roles, k)
                services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_HANDLE, data = type_apply})
                return
            end
        end
    end
end

function Retainer:_onZongApply(evt)
    local data = evt.data
    if data.ret ~= 0 then
        uq.fadeInfo(StaticData["local_text"]["retainer.fail.add"])
        return
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_APPLY, data = evt.data})
end

function Retainer:_onZongNotify(evt)
    local data = evt.data
    if data.notify_type == 0 then
        self._suzerain = data.info
    else
        table.insert(self._courtier, data.info)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_RETAINER_CHANGE})
end

function Retainer:_onDrawEvent(evt)
    if evt.ret ~= 0 then
        return
    end
    local data = evt.data
    if data.apprentice_id == uq.cache.role.id then
        for k, v in pairs(self._suzerainEvents) do
            if v.id == data.id then
                v.state = 2
                break
            end
        end
    else
        for _, v in pairs(self._courtier) do
            if v.info and v.info[1] and v.info[1].id == data.apprentice_id then
                for _, vv in pairs(v.events) do
                    if vv.id == data.id then
                        vv.state = 2
                    end
                end
                break
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ZONG_EVENTS})
end

function Retainer:getListDataByType(list_type)
    if not self._allList[list_type] then
        self._allList[list_type] = {}
    end
    return self._allList[list_type]
end

function Retainer:getOwnSuzerain()
    if self._suzerain[1] and self._suzerain[1].id then
        return self._suzerain[1].id
    end
    return 0
end

function Retainer:isOwnSuzerain(id)
    if id == 0 then
        return false
    end
    return self._suzerain[1] and self._suzerain[1].id == id
end

function Retainer:isAlrealyExist(id)
    if id == 0 or uq.cache.role.id == id then
        return false
    end
    for k, v in pairs(self._courtier) do
        if v.info and v.info[1] and v.info[1].id == id then
            return true
        end
    end
    for k, v in pairs(self._suzerain) do
        if v.id == id then
            return true
        end
    end
    return false
end

function Retainer:isMaxCourtierNum()
    local num = 0
    for k, v in pairs(self._courtier) do
        if v.info and v.info[1] and v.info[1].id ~= 0 then
            num = num + 1
        end
    end
    return num >= self._courtierMaxNum
end

function Retainer:isMaxSuzerainNum()
    for k, v in pairs(self._suzerain) do
        if v.id ~= 0 then
            return true
        end
    end
    return false
end

function Retainer:isLimitBecomeSuzerain()
    return uq.cache.role:level() < self._suzerainLimitLv
end

function Retainer:isLimitBecomeCourtier()
    return uq.cache.role:level() < self._courtierLimitLv
end

function Retainer:getSuzerainEventStatus(id)
    for k, v in pairs(self._suzerainEvents) do
        if v.id == id then
            return v.state
        end
    end
    return 3 --未知状态
end

function Retainer:getSuzerainEventTab(id)
    for k, v in pairs(self._suzerainEvents) do
        if v.id == id then
            return v
        end
    end
    return {}
end

function Retainer:getListRefreshTime(list_type)
    if self._refreshTime[list_type] then
        return self._refreshTime[list_type] - os.time()
    end
    return 0
end

function Retainer:getAllRetainerInfo()
    local tab = {}
    for k, v in pairs(self._courtier) do
        table.insert(tab, v)
    end
    table.sort(tab, function (a, b)
        if a.info[1].is_online == b.info[1].is_online then
            return a.info[1].offline_time > b.info[1].offline_time
        end
        return a.info[1].is_online > b.info[1].is_online
    end)
    if self:getOwnSuzerain() ~= 0 then
        for k, v in pairs(self._suzerain) do
            local info = {}
            table.insert(info, v)
            table.insert(tab, 1, {info = info, intimacy = self._suzerainIntimacy, events = self._suzerainEvents})
        end
    end
    return tab
end

return Retainer
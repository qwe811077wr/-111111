local Bosom = class('Bosom')
local bit = require("bit")

function Bosom:ctor()
    self.bosoms = {}--0、1、2 普通 知己 老婆
    self.talk_list = {}
    self.famous = {}
    self.npcs = {}
    self.talk_num = 0
    self.search_num = 0
    self.advance_search_num = 0 --高级搜索次数
    self.place_id = 0
    self.cd_time = 0
    self.wife_id = 0
    self._freeTalk = 10
    self.auto_talk_num = 0
    self.auto_talk_ids = {}
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_INFO, handler(self, self._onFriendInfo))
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_MARRY, handler(self, self._onMarry))
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_TALK, handler(self, self._onFriendTalk))
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_DIVORCE, handler(self, self._onDivorceRet))
end

function Bosom:decAutoTalkNum()
    self.auto_talk_num = self.auto_talk_num - 1
    if self.auto_talk_num < 0 then
        self.auto_talk_num = 0
    end
end

function Bosom:_onMarry(evt)
    local data = evt.data
    if data and data.ret == 1 then
        self.wife_id = data.npc_id
        if self.bosoms[self.wife_id] then
            self.bosoms[self.wife_id].type = uq.config.constant.BOSOM_TYPE.WIFE
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BOSOM_WIFE_CHANGE, {}})
    end
end
function Bosom:_onFriendInfo(evt)
    local data = evt.data
    self.talk_list = data.npc
    self.bosoms = {}
    for _, v in pairs(data.bosoms) do
        self.bosoms[v.id] = v
    end
    self.cd_time = 0
    if data.cd_time ~= 0 then
        self.cd_time = os.time() + bit.band(data.cd_time, 0x7FFFFFFF)
    end
    self.place_id = data.place_id
    self.talk_num = data.talk_num
    self.advance_search_num = data.search_num
end

function Bosom:_onFriendTalk(evt)
    self.talk_num = self.talk_num + 1
end

function Bosom:_onDivorceRet(evt)
    local data = evt.data
    if data.ret == 0 then
        local tab = self.bosoms[self.wife_id]
        if tab and tab.type then
            tab.type = uq.config.constant.BOSOM_TYPE.BEAUTY
            if data.use_gold == 0 then
                tab.lvl = math.max(tab.lvl - 5, 0)
                tab.happy_lvl = math.min(tab.happy_lvl, tab.lvl)
            end
        end
        self.wife_id = 0
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BOSOM_WIFE_CHANGE, {}})
    end
end

function Bosom:getSearchCost(time)
    local search_num = time or self.advance_search_num
    return StaticData['constant'].getCost(5, search_num + 1)
end

function Bosom:getTalkCost()
    local num = self.talk_num - self._freeTalk
    if num < 0 then
        return 0
    end
    return StaticData['constant'].getCost(6, num + 1)
end

function Bosom:getNextSearchCostByTime(time)
    local num = self.advance_search_num + 1
    local end_num = self.advance_search_num + time
    local cost = 0
    for i = num, end_num, 1 do
        cost = cost + StaticData['constant'].getCost(5, i)
    end
    return cost
end

function Bosom:inTalkList(id)
    for _, v in pairs(self.talk_list) do
        if v == id then
            return true
        end
    end
    return false
end

function Bosom:removeTalkId(id)
    for i = 1, #self.talk_list do
        if self.talk_list[i] == id then
            table.remove(self.talk_list, i)
            return true
        end
    end
    return false
end

function Bosom:getNPC(id)
    return self.npcs[id]
end

function Bosom:addNPC(npc)
    self.npcs[npc.id] = npc
end

function Bosom:getCDTime()
    local now = os.time()
    if self.cd_time > now then
        return self.cd_time - now
    end
    return 0
end

function Bosom:talkHaveWomen()
    for k, v in pairs(self.talk_list) do
        local tab_xml = StaticData['bosom']['women'][v]
        if tab_xml and tab_xml.type == 1 then
            return true
        end
    end
    return false
end

function Bosom:getFamousRes()
    local tab = uq.cache.role.materials_res[uq.config.constant.COST_RES_TYPE.MATERIAL] or {}
    if next(tab) == nil then
        return tab
    end
    local tab_bosom = {}
    for k,v in pairs(tab) do
        local tab_info = StaticData['material'][k]
        if tab_info and tab_info.type == 2 then
            tab_bosom[k] = v
        end
    end
    return tab_bosom
end

function Bosom:getFamousNum()
    local num = 0
    local tab_bosom = self:getFamousRes()
    for k,v in pairs(tab_bosom) do
        num = num + 1
    end
    return num
end

function Bosom:getBosomsNum()
    local num = 0
    for k,v in pairs(self.bosoms) do
        if v.type == uq.config.constant.BOSOM_TYPE.BOSOM then
            num = num + 1
        end
    end
    return num
end

function Bosom:getAllBosomsInfo(is_ipairs)
    local tab = {}
    for k,v in pairs(self.bosoms) do
        if v.type == uq.config.constant.BOSOM_TYPE.BOSOM then
            local tab_v = clone(v)
            local tab_xml = StaticData['bosom']['women'][v.id]
            if tab_xml and next(tab_xml) ~= nil then
                tab_v.info = tab_xml
            else
                tab_v.info = {}
            end
            if is_ipairs then
                table.insert(tab, tab_v)
            else
                tab[k] = tab_v
            end
        end
    end
    table.sort(tab, function (a, b)
        if a.lvl ~= b.lvl then
            return a.lvl > b.lvl
        end
        if a.exp ~= b.exp then
            return a.exp > b.exp
        end
        return a.info.qualityType > b.info.qualityType
    end)
    return tab
end

return Bosom
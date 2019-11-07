local ArenaTopFightItem = class("ArenaTopFightItem", require('app.base.ChildViewBase'))
local HeadItem = require('app.modules.arena.AreanHeadItem')

ArenaTopFightItem.RESOURCE_FILENAME = "arena/ArenaTopFightItem.csb"
ArenaTopFightItem.RESOURCE_BINDING = {
    ["Panel_3"]        = {["varname"]="_panelDef"},
    ["Text_2_0_0_1"]   = {["varname"]="_txtAtkName"},
    ["Image_lvl"]      = {["varname"]="_imgAtkRank"},
    ["Image_city"]     = {["varname"]="_imgAtkCity"},
    ["Text_29"]        = {["varname"]="_txtAtkRank"},
    ["Text_2_0"]       = {["varname"]="_txtAtkPower"},
    ["Text_2_0_0_0"]   = {["varname"]="_txtTime"},
    ["Panel_4"]        = {["varname"]="_panelAtk"},
    ["Text_2_0_0_1_0"] = {["varname"]="_txtDefName"},
    ["Text_2_0_1"]     = {["varname"]="_txtDefPower"},
    ["Text_29_0"]      = {["varname"]="_txtDefRank"},
    ["Image_lvl_0"]    = {["varname"]="_imgDefRank"},
    ["Image_city_0"]   = {["varname"]="_imgDefCity"},
    ["Panel_1"]        = {["varname"]="_panelClick"}
}

function ArenaTopFightItem:onCreate()
    ArenaTopFightItem.super.onCreate(self)

    self._roleItem1 = HeadItem:create()
    self._panelClick:setTouchEnabled(true)
    self._panelClick:setSwallowTouches(false)
    local size = self._panelAtk:getContentSize()
    self._roleItem1:setPosition(cc.p(size.width / 2, size.height / 2))
    self._panelAtk:addChild(self._roleItem1)

    self._roleItem2 = HeadItem:create()
    self._roleItem2:setPosition(cc.p(size.width / 2, size.height / 2))
    self._panelDef:addChild(self._roleItem2)
end

function ArenaTopFightItem:onClickItem()
    uq.BattleReport:getInstance():showBattleReport(self._data.report_id, handler(self, self._onPlayReportEnd))
end

function ArenaTopFightItem:_onPlayReportEnd()
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
end

function ArenaTopFightItem:setData(data)
    self._data = data
    local arr_win = {name = data.atk_name, power = data.atk_power, rank = data.atk_rank, city = data.atk_country}
    local arr_lose = {name = data.def_name, power = data.def_power, rank = data.def_rank, city = data.def_country}
    if data.battle_ret <= 0 then
        arr_win = {name = data.def_name, power = data.def_power, rank = data.def_rank, city = data.def_country}
        arr_lose = {name = data.atk_name, power = data.atk_power, rank = data.atk_rank, city = data.atk_country}
    end

    self._txtAtkName:setString(arr_win.name)
    self._txtAtkPower:setString(arr_win.power)
    self._txtAtkRank:setString(arr_win.rank)
    self._txtAtkRank:setVisible(arr_win.rank > 3 or arr_win.rank < 0)
    self:setRankImg(self._imgAtkRank, arr_win.rank)
    local atk_img = uq.cache.role:getCountryImg(arr_win.city)
    self._imgAtkCity:loadTexture(atk_img)

    local desc = ''
    local time = os.time() - data.time
    if time / 3600 / 24 > 1 then
        desc = string.format(StaticData['local_text']['time.day.before'], math.floor(time / 3600 / 24))
    elseif time / 3600 > 1 then
        desc = string.format(StaticData['local_text']['time.hour.before'], math.floor(time / 3600))
    elseif time > 60 then
        desc = string.format(StaticData['local_text']['time.minute.before'], math.floor(time / 60))
    else
        desc = string.format(StaticData['local_text']['time.second.before'], time)
    end
    self._txtTime:setString(desc)

    self._txtDefName:setString(arr_lose.name)
    self._txtDefPower:setString(arr_lose.power)
    self._txtDefRank:setString(arr_lose.rank)
    self:setRankImg(self._imgDefRank, arr_lose.rank)
    self._txtDefRank:setVisible(arr_lose.rank > 3 or arr_lose.rank < 0)
    local def_img = uq.cache.role:getCountryImg(arr_lose.city)
    self._imgDefCity:loadTexture(def_img)
end

function ArenaTopFightItem:setRankImg(node, rank)
    node:setVisible(rank <= 3 and rank > 0)
    if rank == 1 then
        node:loadTexture('img/rank/xsj03_0196.png')
    elseif rank == 2 then
        node:loadTexture('img/rank/xsj03_0197.png')
    elseif rank == 3 then
        node:loadTexture('img/rank/xsj03_0198.png')
    end
end

return ArenaTopFightItem
local BattleReportItem = class("BattleReportItem", require('app.base.ChildViewBase'))

BattleReportItem.RESOURCE_FILENAME = "world/BattleReportItem.csb"
BattleReportItem.RESOURCE_BINDING = {
    ["Image_bg"]                = {["varname"] = "_bgImg"},
    ["Text_point"]              = {["varname"] = "_pointLabel"},
    ["Text_city"]               = {["varname"] = "_cityLabel"},
    ["army_label"]              = {["varname"] = "_armyLabel"},
    ["Text_times"]              = {["varname"] = "_timeLabel"},
    ["img_result"]              = {["varname"] = "_resultImg"},
    ["Node_6"]                  = {["varname"] = "_btnNode"},
    ["Node_1/crop_name"]        = {["varname"] = "_cropNameLabel1"},
    ["Node_1/player_name"]      = {["varname"] = "_playerNameLabel1"},
    ["Node_1/Image_13"]         = {["varname"] = "_headImg1"},
    ["Node_1/bmfont_power"]     = {["varname"] = "_powerBmFont1"},
    ["Node_2/crop_name"]        = {["varname"] = "_cropNameLabel2"},
    ["Node_2/player_name"]      = {["varname"] = "_playerNameLabel2"},
    ["Node_2/Image_13"]         = {["varname"] = "_headImg2"},
    ["Node_2/bmfont_power"]     = {["varname"] = "_powerBmFont2"},
    ["btn_share"]               = {["varname"] = "_btnShare",["events"] = {{["event"] = "touch",["method"] = "onBtnShare"}}},
    ["btn_playback"]            = {["varname"] = "_btnPlayBack",["events"] = {{["event"] = "touch",["method"] = "onBtnPlayBack"}}},
}

function BattleReportItem:onCreate()
    BattleReportItem.super.onCreate(self)
    self._btnShare:setPressedActionEnabled(true)
    self._btnPlayBack:setPressedActionEnabled(true)
    self._btnNode:setVisible(false)
end

function BattleReportItem:setData(data)
    self._data = data
    if not self._data then
        return
    end
    self._bgImg:loadTexture(self:getBgImg(data.is_atk, data.result))
    local title = "img/world/j04_0000123.png"
    if (data.is_atk == 1 and data.result > 0) or (data.is_atk == 0 and data.result <= 0) then
        title = "img/world/j04_0000122.png"
    end
    self._resultImg:loadTexture(title)
    self._armyLabel:setString(StaticData["local_text"]["world.war.formation.des" .. data.owned[1].army_id])
    local city_info = StaticData['world_city'][data.city_id]
    self._cityLabel:setString(city_info.name)
    local war_info = StaticData['world_war_city'][city_info.type]
    local cur_city = war_info.war[data.point_id]
    self._pointLabel:setString(cur_city.name)
    --自己信息
    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._cropNameLabel1:setString(crop_info.name)
    self._playerNameLabel1:setString(uq.cache.role.name)
    local res_head1 = uq.getHeadRes(uq.cache.role:getImgId(), uq.cache.role:getImgType())
    self._headImg1:loadTexture(res_head1)
    self._powerBmFont1:setString(data.owned[1].power)
    --对手信息
    self._cropNameLabel2:setString(data.enemy[1].crop_name)
    self._playerNameLabel2:setString(data.enemy[1].player_name)
    local res_head2 = uq.getHeadRes(data.enemy[1].img_id, data.enemy[1].img_type)
    self._headImg2:loadTexture(res_head2)
    self._powerBmFont2:setString(data.enemy[1].power)
    local times = uq.cache.server_data:getServerTime() - data.time
    local days = times / 3600 / 24
    if days > 3 then
        self._timeLabel:setString(string.format(StaticData["local_text"]["world.report.des2"], math.floor(days)))
    else
        local cur_date = os.date("*t", data.time)
        self._timeLabel:setString(string.format(StaticData["local_text"]["world.report.des1"], cur_date.year, cur_date.month, cur_date.day,
            cur_date.hour,cur_date.min, cur_date.sec))
    end
end

function BattleReportItem:getBgImg(is_atk, is_win)
    if is_atk == 1 then
        if is_win > 0 then
            return "img/world/j03_00009687.png"
        else
            return "img/world/j03_00009686.png"
        end
    else
        if is_win > 0 then
            return "img/world/j03_00009688.png"
        else
            return "img/world/j03_00009689.png"
        end
    end
end

function BattleReportItem:getData()
    return self._data
end

function BattleReportItem:onBtnShare(event)
    if event.name ~= "ended" then
        return
    end
    local cell_parent = self._btnShare:getParent()
    local pos = cell_parent:convertToWorldSpace(cc.p(self._btnShare:getPosition()))
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_REPORT_SHARE_BTN, data = {pos = pos, info = self._data}})
end

function BattleReportItem:onBtnPlayBack(event)
    if event.name ~= "ended" then
        return
    end
    uq.BattleReport:getInstance():showBattleReport(self._data.report_id, handler(self, self._onPlayReportEnd))
end

function BattleReportItem:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

function BattleReportItem:setSelectState(is_show)
    self._btnNode:setVisible(is_show)
end

return BattleReportItem
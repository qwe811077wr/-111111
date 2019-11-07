local CropSignBattleReportItem = class("CropSignBattleReportItem", require('app.base.ChildViewBase'))

CropSignBattleReportItem.RESOURCE_FILENAME = "crop_sign/CropSignBattleReportItem.csb"
CropSignBattleReportItem.RESOURCE_BINDING = {
    ["text_name"]     = {["varname"] = "_txtName"},
    ["txt_time"]      = {["varname"] = "_txtTime"},
    ["Button_report"] = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["Image_2"]       = {["varname"] = "_imgResult"},
    ["Text_2_0"]      = {["varname"] = "_txtPower"},
    ["Image_78"]      = {["varname"] = "_imgHead"},
    ["txt_enemy"]     = {["varname"] = "_txtEnemy"},
    ["Button_1"]      = {["varname"] = "_btnShare",["events"] = {{["event"] = "touch",["method"] = "onShare"}}},
}

function CropSignBattleReportItem:onCreate()
    CropSignBattleReportItem.super.onCreate(self)
end

function CropSignBattleReportItem:setData(data)
    self._data = data
    self._txtName:setString(data.name)

    local time_off = uq.cache.server_data:getServerTime() - data.time
    self._txtTime:setString(uq.getTime2(time_off) .. StaticData['local_text']['label.common.before'])
    self._txtPower:setString(data.power)

    if data.battle_ret > 0 then
        self._imgResult:loadTexture('img/arena/s04_00120.png')
    else
        self._imgResult:loadTexture('img/arena/s04_00109.png')
    end

    local res_head = uq.getHeadRes(data.img_id, data.img_type)
    self._imgHead:loadTexture(res_head)

    self._troopData = StaticData['war_sign'].WarTroop[data.troop_id]
    self._txtEnemy:setString(self._troopData.name)

    self._btnShare:setVisible(data.role_id == uq.cache.role.id)
end

function CropSignBattleReportItem:onReport(event)
    if event.name == "ended" then
        local reward = StaticData['war_sign'].WarSign[self._data.legion_level + 1].Stage[self._data.mode_id].reward
        uq.BattleReport:showBattleReport(self._data.report_id, handler(self, self._onPlayReportEnd), reward)
    end
end

function CropSignBattleReportItem:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:showBattleResult(report)
end

function CropSignBattleReportItem:onShare(event)
    if event.name ~= "ended" then
        return
    end
    local enemy = {
        player_name = self._troopData.name,
        img_type    = uq.config.constant.HEAD_TYPE.GENERAL,
        img_id      = self._troopData.icon,
    }
    local ower = {
        player_name = self._data.name,
        img_type    = self._data.img_type,
        img_id      = self._data.img_id,
    }
    local info = {
        is_atk = 1,
        result = self._data.battle_ret,
        report_id = self._data.report_id,
        enemy = enemy,
        ower = ower,
    }
    local content = json.encode(info)
    local data = {
        channel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD,
        content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE,
        content = content
    }
    uq.sendShareMsg(data)
end

return CropSignBattleReportItem
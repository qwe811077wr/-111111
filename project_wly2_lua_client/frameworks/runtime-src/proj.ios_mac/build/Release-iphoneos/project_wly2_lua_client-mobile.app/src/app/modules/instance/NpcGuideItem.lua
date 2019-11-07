local NpcGuideItem = class("NpcGuideItem", require('app.base.ChildViewBase'))

NpcGuideItem.RESOURCE_FILENAME = "instance/GuideViewItem.csb"
NpcGuideItem.RESOURCE_BINDING = {
    ["Node_1"]              = {["varname"] = "_nodeHeadList"},
    ["sprite_country"]      = {["varname"] = "_sprFlot"},
    ["Text_7"]              = {["varname"] = "_txtName"},
    ["Button_1"]            = {["varname"] = "_btnGo"},
    ["BitmapFontLabel_1"]   = {["varname"] = "_bfl"},
    ["power_bg"]            = {["varname"] = "_powerBgImg"},
}

function NpcGuideItem:onCreate()
    NpcGuideItem.super.onCreate(self)

end

function NpcGuideItem:setData(data)
    if not data or next(data) == nil then
        return
    end
    self._iconFlag ={"s03_00033.png", "s03_00034.png", "s03_00035.png"}
    self._txtName:setString(data.role_name)
    self._sprFlot:setTexture("img/common/ui/" .. self._iconFlag[data.country_id])
    self._bfl:setString(tostring(data.force_value))
    self._btnGo:addClickEventListenerWithSound(function()
        uq.BattleReport:getInstance():showBattleReport(data.report_id, handler(self, self._onPlayReportEnd))
    end)
    self._nodeHeadList:removeAllChildren()
    if data.general_str and data.general_str ~= "" then
        local split_tab = string.split(data.general_str, ";")
        for i, v in ipairs(split_tab) do
            local str_tab = string.split(v, ",")
            local item = uq.createPanelOnly("instance.NpcGuideListItem")
            item:setPosition(cc.p((i - 1) * 80 + 100, 0))
            item:setData(str_tab)
            self._nodeHeadList:addChild(item)
        end
    end
    self._powerBgImg:setVisible(data.type == 1)
end

function NpcGuideItem:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

return NpcGuideItem
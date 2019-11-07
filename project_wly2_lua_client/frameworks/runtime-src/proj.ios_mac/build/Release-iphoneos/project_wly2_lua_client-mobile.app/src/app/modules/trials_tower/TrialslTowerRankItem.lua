local TrialslTowerRankItem = class("TrialslTowerRankItem", require('app.base.ChildViewBase'))

TrialslTowerRankItem.RESOURCE_FILENAME = "test_tower/TowerRankItem.csb"
TrialslTowerRankItem.RESOURCE_BINDING = {
    ["rank_label"]      = {["varname"]="_rankLabel"},
    ["rank_img"]        = {["varname"]="_rankImg"},
    ["contry_bg"]       = {["varname"]="_countryImg"},
    ["crop_name"]       = {["varname"]="_roleName"},
    ["txt_value"]       = {["varname"]="_valueLabel"},
    ["panel_head"]      = {["varname"]="_panelHead"},
    ["txt_force"]       = {["varname"]="_powerLabel"},
    ["Image_powerbg"]   = {["varname"]="_powerImgBg"},
}

function TrialslTowerRankItem:onCreate()
    TrialslTowerRankItem.super.onCreate(self)
end

function TrialslTowerRankItem:setData(data)
    local rank_icon = {'xsj03_0196.png', 'xsj03_0197.png', 'xsj03_0198.png'}
    local rank_bg = {'xsj03_0191.png', 'xsj03_0192.png', 'xsj03_0190.png'}
    local country_img ={"s03_00033.png", "s03_00034.png", "s03_00035.png"}
    self._countryImg:loadTexture("img/common/ui/" .. country_img[data.country_id])
    self._powerImgBg:setVisible(data.rank <= 3)
    self._rankImg:setVisible(data.rank <= 3)
    self._rankLabel:setVisible(data.rank > 3)
    if data.rank <= 3 then
        self._rankImg:setTexture('img/common/ui/' .. rank_icon[data.rank])
        self._powerImgBg:loadTexture('img/common/ui/' .. rank_bg[data.rank])
    else
        self._rankLabel:setString(data.rank)
    end
    self._roleName:setString(data.player_name)
    self._powerLabel:setString(data.power)
    self._valueLabel:setString(string.format(StaticData["local_text"]["tower.rank.des2"], data.layer))
    self._panelHead:removeAllChildren()
    if data.general_str and data.general_str ~= "" then
        local split_tab = string.split(data.general_str, ";")
        for i, v in ipairs(split_tab) do
            local str_tab = string.split(v, ",")
            local item = uq.createPanelOnly("instance.NpcGuideListItem")
            item:setPosition(cc.p((i - 1) * 110, 50))
            item:setData(str_tab)
            item:setScale(1.3)
            self._panelHead:addChild(item)
        end
    end
end

return TrialslTowerRankItem
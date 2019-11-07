local WorldCityRankItem2 = class("WorldCityRankItem2", require('app.base.ChildViewBase'))

WorldCityRankItem2.RESOURCE_FILENAME = "world/WorldCityRankItem2.csb"
WorldCityRankItem2.RESOURCE_BINDING = {
    ["text_name"]         = {["varname"] = "_cropNameLabel"},
    ["role_name"]         = {["varname"] = "_roleNameLabel"},
    ["text_status"]       = {["varname"] = "_scoreLabel"},
    ["img_rank"]          = {["varname"] = "_rankImg"},
    ["Text_rank"]         = {["varname"] = "_rankLabel"},
    ["Image_1"]           = {["varname"] = "_fengeImg"},
    ["Image_7"]           = {["varname"] = "_imgHead"},
    ["sprite_crop"]       = {["varname"] = "_spriteCountry"},
    ["Image_2"]           = {["varname"] = "_rankBgImg"},
}

function WorldCityRankItem2:onCreate()
    WorldCityRankItem2.super.onCreate(self)
end

WorldCityRankItem2._RANK_BG_PATH = {
    "img/common/ui/xsj03_0191.png",
    "img/common/ui/xsj03_0192.png",
    "img/common/ui/xsj03_0190.png",
}

WorldCityRankItem2._RANK_PATH = {
    "img/common/ui/xsj03_0196.png",
    "img/common/ui/xsj03_0197.png",
    "img/common/ui/xsj03_0198.png",
}

function WorldCityRankItem2:setData(data)
    self._info = data
    if not self._info then
        return
    end
    local res_head = uq.getHeadRes(self._info.main_general_id, uq.config.constant.HEAD_TYPE.GENERAL)
    self._imgHead:loadTexture(res_head)
    local country_img ={"s03_00033.png", "s03_00034.png", "s03_00035.png"}
    self._spriteCountry:setTexture("img/common/ui/" .. country_img[self._info.country_id])
    self._cropNameLabel:setString(self._info.crop_name)
    self._roleNameLabel:setString(self._info.role_name)
    self._scoreLabel:setString(self._info.value)
    self._rankBgImg:setVisible(self._info.rank < 3 and self._info.rank > 0)
    if self._info.rank == 0 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(StaticData["local_text"]["world.rank.des"])
    elseif self._info.rank > 3 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(self._info.rank)
    else
        self._rankImg:setVisible(true)
        self._rankImg:setTexture(self._RANK_PATH[self._info.rank])
        self._rankBgImg:loadTexture(self._RANK_BG_PATH[self._info.rank])
        self._rankLabel:setString("")
    end
end

function WorldCityRankItem2:updateState(is_show)
    self._fengeImg:setVisible(is_show)
end

return WorldCityRankItem2
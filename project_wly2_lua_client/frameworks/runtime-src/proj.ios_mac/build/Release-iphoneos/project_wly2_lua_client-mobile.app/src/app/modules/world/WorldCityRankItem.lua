local WorldCityRankItem = class("WorldCityRankItem", require('app.base.ChildViewBase'))

WorldCityRankItem.RESOURCE_FILENAME = "world/WorldCityRankItem.csb"
WorldCityRankItem.RESOURCE_BINDING = {
    ["text_name"]         = {["varname"] = "_nameLabel"},
    ["text_num"]          = {["varname"] = "_scoreLabel"},
    ["img_rank"]          = {["varname"] = "_rankImg"},
    ["Text_rank"]         = {["varname"] = "_rankLabel"},
    ["Image_1"]           = {["varname"] = "_fengeImg"},
    ["text_status"]       = {["varname"] = "_stateLabel"},
    ["crop"]              = {["varname"] = "_cropNameLabel"},
    ["sprite_crop"]       = {["varname"] = "_spriteColorImg"},
}

function WorldCityRankItem:onCreate()
    WorldCityRankItem.super.onCreate(self)
end

WorldCityRankItem._RANK_PATH = {
    "img/world/s04_00001.png",
    "img/world/s04_00002.png",
    "img/world/s04_00003.png",
}

function WorldCityRankItem:setData(data)
    self._info = data
    if not self._info then
        return
    end
    self._nameLabel:setString(self._info.name)
    self._scoreLabel:setString(self._info.value)
    if self._info.rank == 0 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(StaticData["local_text"]["world.rank.des"])
    elseif self._info.rank > 3 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(self._info.rank)
    else
        self._rankImg:setVisible(true)
        self._rankImg:setTexture(self._RANK_PATH[self._info.rank])
        self._rankLabel:setString("")
    end
    local crop_data = uq.cache.crop:getCropDataById(self._info.crop_id)
    if next(crop_data) ~= nil then
        local flag_info = StaticData['world_flag'][crop_data.color_id]
        if flag_info then
            self._spriteColorImg:setTexture("img/create_power/" .. flag_info.color)
            self._cropNameLabel:setString(crop_data.power_name)
        end
    end
    local des = "world.rank.status.des" .. self._info.is_atk
    self._stateLabel:setString(StaticData["local_text"][des])
end

function WorldCityRankItem:updateState(is_show)
    self._fengeImg:setVisible(is_show)
end

return WorldCityRankItem
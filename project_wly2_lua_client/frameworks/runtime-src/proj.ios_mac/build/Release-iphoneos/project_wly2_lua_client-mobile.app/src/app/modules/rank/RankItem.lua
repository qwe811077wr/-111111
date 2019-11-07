local RankItem = class("RankItem", require('app.base.ChildViewBase'))

RankItem.RESOURCE_FILENAME = "rank/RankItem.csb"
RankItem.RESOURCE_BINDING = {
    ["Node_1"]   = {["varname"]="_nodeRank"},
    ["Node_1_0"] = {["varname"]="_nodeCrop"},
}

function RankItem:onCreate()
    RankItem.super.onCreate(self)

end

function RankItem:setData(data, channel)
    self._curChannel = channel
    self._nodeCrop:setVisible(self._curChannel == uq.config.constant.RANK_TYPE.CROP)
    self._nodeRank:setVisible(self._curChannel ~= uq.config.constant.RANK_TYPE.CROP)

    local rank_icon = {'xsj03_0196.png', 'xsj03_0197.png', 'xsj03_0198.png'}
    local rank_bg = {'xsj03_0191.png', 'xsj03_0192.png', 'xsj03_0190.png'}
    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        self._nodeCrop:getChildByName('sprite_rank'):setVisible(self._index <= 3)
        self._nodeCrop:getChildByName('rank_bg'):setVisible(self._index <= 3)
        self._nodeCrop:getChildByName('txt_rank'):setVisible(self._index > 3)
        if self._index <= 3 then
            self._nodeCrop:getChildByName('sprite_rank'):setTexture('img/rank/' .. rank_icon[self._index])
            self._nodeCrop:getChildByName('rank_bg'):loadTexture('img/rank/' .. rank_bg[self._index])
        else
            self._nodeCrop:getChildByName('txt_rank'):setString(self._index)
        end
        self._nodeCrop:getChildByName('crop_name'):setString(data.crop_name)

        local icon_bg, head_icon = uq.cache.crop:getCropIcon(data.crop_icon)
        self._nodeCrop:getChildByName('crop_head'):setTexture(head_icon)
        self._nodeCrop:getChildByName('sprite_country_bg'):setTexture(uq.cache.role:getCountryBg(data.country_id))
        self._nodeCrop:getChildByName('txt_country'):setString(uq.cache.role:getCountryShortName(data.country_id))
        self._nodeCrop:getChildByName('txt_power'):setString(data.value)
        self._nodeCrop:getChildByName('txt_crop'):setString(data.player_name)
    else
        self._nodeRank:getChildByName('sprite_rank'):setVisible(self._index <= 3)
        self._nodeRank:getChildByName('rank_bg'):setVisible(self._index <= 3)
        self._nodeRank:getChildByName('txt_rank'):setVisible(self._index > 3)
        if self._index <= 3 then
            self._nodeRank:getChildByName('sprite_rank'):setTexture('img/rank/' .. rank_icon[self._index])
            self._nodeRank:getChildByName('rank_bg'):loadTexture('img/rank/' .. rank_bg[self._index])
        else
            self._nodeRank:getChildByName('txt_rank'):setString(self._index)
        end
        local res_head = uq.getHeadRes(data.img_id, data.img_type)
        self._nodeRank:getChildByName('panel_head'):getChildByName('img_head'):loadTexture(res_head)
        self._nodeRank:getChildByName('txt_name'):setString(data.playerName)
        self._nodeRank:getChildByName('txt_power'):setString(data.attackValue)
        if data.crop_name ~= '' then
            self._nodeRank:getChildByName('txt_crop'):setString(data.crop_name)
        else
            self._nodeRank:getChildByName('txt_crop'):setString('无')
        end
        local icon_bg, head_icon = uq.cache.crop:getCropIcon(data.crop_icon)
        self._nodeRank:getChildByName('crop_head'):setTexture(head_icon)
    end
end

function RankItem:setIndex(index)
    self._index = index
end

return RankItem
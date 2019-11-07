local ArenaRankItem = class("ArenaRankItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")
local HeadItem = require("app.modules.equip.DraftGeneralHeadItem")

ArenaRankItem.RESOURCE_FILENAME = "arena/ArenaRankItem.csb"
ArenaRankItem.RESOURCE_BINDING = {
    ["g03_0209_6"]     = {["varname"] = "_spriteIndex"},
    ["Image_city"]     = {["varname"] = "_imgCity"},
    ["Text_9"]         = {["varname"] = "_txtIndex"},
    ["Text_9_0_0"]     = {["varname"] = "_txtName"},
    ["Text_9_0_0_1_0"] = {["varname"] = "_txtPower"},
    ["Node_1"]         = {["varname"] = "_nodeGeneral"},
    ["Image_8"]        = {["varname"] = "_imgIndex"},
    ["Panel_3"]        = {["varname"] = "_panelReward1"},
    ["Panel_4"]        = {["varname"] = "_panelReward2"},
}

function ArenaRankItem:onCreate()
    ArenaRankItem.super.onCreate(self)
    self._itemArray = {self._panelReward1, self._panelReward2}
end

function ArenaRankItem:setData(data)
    self._txtName:setString(data.name)
    self._txtPower:setString(data.power)
    self._imgCity:loadTexture(uq.cache.role:getCountryImg(data.country))
    local reward_config = uq.cache.arena:getRankConfig(data.rank)
    if reward_config then
        local reward_items = uq.RewardType.parseRewards(reward_config.Reward)
        for k, v in ipairs(reward_items) do
            local item = self._itemArray[k]:getChildByName("item")
            if not item then
                item = EquipItem:create({info = v:toEquipWidget()})
                local size = item:getContentSize()
                item:setScale(0.6)
                item:setName("item")
                item:setPosition(cc.p(size.width * 0.3, size.height * 0.3))
                self._itemArray[k]:addChild(item)
            else
                item:setInfo(v:toEquipWidget())
            end
        end
    end

    self._nodeGeneral:removeAllChildren()
    local item = HeadItem:create()
    local scale = 0.8
    local size = item:getContentSize()
    local delta = -(size.width * scale * (data.count - 1)) / 2

    for i = 1, data.count do
        local info = data.generals[i]
        local item = HeadItem:create({info = {general_info = info}})
        item:setScale(scale)
        item:setPositionX(delta)
        delta = delta + size.width * scale
        self._nodeGeneral:addChild(item)
    end

    self:setIndex(data.rank)
end

function ArenaRankItem:setIndex(index)
    self._spriteIndex:setVisible(true)
    self._txtIndex:setVisible(false)
    self._imgIndex:setVisible(true)

    if index == 1 then
        self._spriteIndex:setTexture('img/rank/xsj03_0196.png')
        self._imgIndex:loadTexture("img/rank/xsj03_0191.png")
    elseif index == 2 then
        self._spriteIndex:setTexture('img/rank/xsj03_0197.png')
        self._imgIndex:loadTexture("img/rank/xsj03_0192.png")
    elseif index == 3 then
        self._spriteIndex:setTexture('img/rank/xsj03_0198.png')
        self._imgIndex:loadTexture("img/rank/xsj03_0190.png")
    else
        self._spriteIndex:setVisible(false)
        self._imgIndex:setVisible(false)
        self._txtIndex:setVisible(true)
        index = index == 0 and StaticData['local_text']['arena.out'] or index
        self._txtIndex:setString(index)
    end
end

function ArenaRankItem:setOwnerTextSize(size)
    self._txtIndex:setFontSize(size)
end

return ArenaRankItem
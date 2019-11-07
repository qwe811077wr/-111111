local EmbattleFormationItem = class("EmbattleFormationItem", require('app.base.ChildViewBase'))

EmbattleFormationItem.RESOURCE_FILENAME = "embattle/EmbattleItem.csb"
EmbattleFormationItem.RESOURCE_BINDING = {
    ["Sprite_4"]    ={["varname"]="_spriteBg1"},
    ["Sprite_3"]    ={["varname"]="_spriteBg2"},
    ["Sprite_2"]    ={["varname"]="_spriteBg3"},
    ["Node_15"]     ={["varname"]="_nodeSoldier"},
    ["Node_4"]      ={["varname"]="_nodeCanUp"},
    ["Node_2"]      ={["varname"]="_nodeClosed"},
    ["Node_3"]      ={["varname"]="_nodeDown"},
    ["Text_1"]      ={["varname"]="_txtLevel"},
    ["Node_17"]     ={["varname"]="_nodeBosomInfo"},
    ["Image_2"]     ={["varname"]="_bosomHead"},
    ["Image_3"]     ={["varname"]="_bosomHeadBg"},
    ["Text_2"]      ={["varname"]="_txtName"},
    -- ["Image_type"]  ={["varname"]="_imgType"},
}

function EmbattleFormationItem:ctor()
    EmbattleFormationItem.super.ctor(self)
    --
    self._index = 0
    self._soldiers = {}
end

function EmbattleFormationItem:dispose()
end

function EmbattleFormationItem:initItem(general_name, soldier_img)
    -- self._imgType:setVisible(false)
    self._spriteBg3:setVisible(true)
    self._txtName:setString(general_name)
    self:loadSoldier(soldier_img)
end

function EmbattleFormationItem:loadSoldier(soldier_img)
    for i=1, 9 do
        local soldier = cc.Sprite:create(string.format("img/common/soldier/%s", soldier_img))
        if soldier then
            local x = -20 + (i - 1 ) % 3 * 40 - 10 * math.ceil(i / 3)
            local y = 60 - math.floor((i - 1) / 3) * 35
            soldier:setPosition(cc.p(x, y))
            soldier:setScale(0.5)
            self._nodeSoldier:addChild(soldier)
            table.insert(self._soldiers, soldier)
        end
    end
end

function EmbattleFormationItem:setIndex(index)
    self._index = index
end

return EmbattleFormationItem
local EmbattlePos = class("EmbattlePos", require('app.base.ChildViewBase'))

EmbattlePos.RESOURCE_FILENAME = "embattle/EmbattlePos.csb"
EmbattlePos.RESOURCE_BINDING = {
    ["g06_0011_2"] = {["varname"]="_imageNum1"},
    ["g06_0011_3"] = {["varname"]="_imageNum2"},
    ["g06_0011_4"] = {["varname"]="_imageNum3"},
    ["g06_0011_5"] = {["varname"]="_imageNum4"},
    ["g06_0011_6"] = {["varname"]="_imageNum5"},
    ["g06_0011_7"] = {["varname"]="_imageNum6"},
    ["g06_0011_8"] = {["varname"]="_imageNum7"},
    ["g06_0011_9"] = {["varname"]="_imageNum8"},
    ["g06_0011_10"] = {["varname"]="_imageNum9"},
}

function EmbattlePos:onCreate()
    self:init()
end

function EmbattlePos:init()
    self:initPage()
end

function EmbattlePos:initPage()
    for i = 1, 9 do
        self["_imageNum" .. i]:setVisible(false)
    end
end

function EmbattlePos:setData(formationIndex)
    self:initPage()
    local content = StaticData['formation'][formationIndex].AtkOrder[1].AtkOrder
    local order = string.split(content, ',')
    for index,v in ipairs(order) do
        self["_imageNum"..v]:setVisible(true)
        self["_imageNum"..v]:setTexture("img/embattle/g06_001" .. index .. ".png")
    end
end

return EmbattlePos
local WorldSoldierItem = class("WorldSoldierItem", require('app.base.ChildViewBase'))
WorldSoldierItem.RESOURCE_FILENAME = "world/SoldierItem.csb"
WorldSoldierItem.RESOURCE_BINDING = {
    ["Node_1/Node_soldier"]                     = {["varname"] = "_nodeSoldier"},
    ["Node_1/time"]                             = {["varname"] = "_timeLabel"},
    ["Node_1/Image_government"]                 = {["varname"] = "_governmentImg"},
    ["Node_1/Image_government/government"]      = {["varname"] = "_governLabel"},
    ["Node_1/Image_percent"]                    = {["varname"] = "_soldierImg"},
    ["Node_1/Image_9"]                          = {["varname"] = "_percentBg"},
    ["Node_1/Image_type"]                       = {["varname"] = "_imgType"},
    ["Node_1/Image_selfbg"]                     = {["varname"] = "_imgSelfBg"},
}

function WorldSoldierItem:onCreate()
    WorldSoldierItem.super.onCreate(self)
    self._totalTime = 1
    self._soldierImgSize = cc.size(self._percentBg:getContentSize().width - 4, self._soldierImg:getContentSize().height)
    self._soldierArray = {}
    self._nodeSoldier:removeAllChildren()
    self._soldierItem = uq.createPanelOnly('battle.BattleSoldier')
    self._soldierItem:setData({soldier_id = 11}, 3, false)
    self._soldierItem:setName('soldier')
    self._soldierItem:playIdle()
    self._soldierItem:setPosition(cc.p(-45, 40))
    self._nodeSoldier:addChild(self._soldierItem)
    self._curPosArray = {}
    for i = 0, 8 do
        local x = -30 + (i % 3) * 30
        local y = 21 - math.floor(i / 3) * 21
        if i ~= 4 then
            table.insert(self._curPosArray, cc.p(x, y))
        end
        local soldier = uq.createPanelOnly('battle.BattleSoldier')
        soldier:setData({soldier_id = 16}, 3, false)
        soldier:setName('soldier')
        soldier:playIdle()
        soldier:setPosition(cc.p(x, y))
        self._nodeSoldier:addChild(soldier)
        table.insert(self._soldierArray, soldier)
    end
end

function WorldSoldierItem:onExit()
    WorldSoldierItem.super.onExit(self)
end

function WorldSoldierItem:updateDialog()
    if self._info.role_id == uq.cache.role.id then
        -- self._soldierImg:loadTexture("img/main_city/j03_00009534.png")
    else
        -- self._soldierImg:loadTexture("img/main_city/j03_00009534.png")
    end
    self._imgSelfBg:setVisible(self._info.role_id == uq.cache.role.id)
    if self._info.crop_id == uq.cache.role.cropsId then
        if self._info.role_id == uq.cache.role.id then
            self._imgType:loadTexture("img/world/s03_000672.png")
        else
            self._imgType:loadTexture("img/world/s03_000671.png")
        end
    else
        self._imgType:loadTexture("img/world/s03_000673.png")
    end
    local info = uq.cache.crop:getMemberInfoById(self._info.role_id)
    if info and info.pos < uq.config.constant.GOVERNMENT_POS.MEMBER then
        self._governmentImg:setVisible(true)
        local info = StaticData['war_season'].WarGrade[1].grade[info.pos]
        self._governLabel:setString(info.name)
    else
        self._governmentImg:setVisible(false)
    end
end

function WorldSoldierItem:setInfo(info)
    self._info = info
    self._totalTime = self._info.move_cd
    self._soldierImg:setContentSize(self._soldierImgSize)
    self:updateDialog()
end

function WorldSoldierItem:setAngle(cur_pos, dest_pos)
    local p = {}
    p.x = dest_pos.x - cur_pos.x
    p.y = dest_pos.y - cur_pos.y
    local r = math.atan2(p.y, p.x) * 180 / math.pi
    for k, soldier in ipairs(self._soldierArray) do
        soldier:playActionByAngle(r)
    end
    self._soldierItem:playActionByAngle(r)
    self._soldierItem:setPosition(self:getPosByAngle(r))
end

function WorldSoldierItem:getPosByAngle(angle)
    if angle > -22.5 and angle <= 22.5 then
        return cc.p(self._curPosArray[5].x + 35, self._curPosArray[5].y)
    elseif angle > 22.5 and angle <= 67.5 then
        return cc.p(self._curPosArray[3].x + 35, self._curPosArray[3].y + 35)
    elseif angle > 67.5 and angle <= 112.5 then
        return cc.p(self._curPosArray[2].x, self._curPosArray[2].y + 35)
    elseif angle > 112.5 and angle <= 157.5 then
        return cc.p(self._curPosArray[1].x - 35, self._curPosArray[1].y + 35)
    elseif angle <= -22.5 and angle > -67.5 then
        return cc.p(self._curPosArray[8].x + 35, self._curPosArray[8].y - 35)
    elseif angle <= -67.5 and angle > -112.5 then
        return cc.p(self._curPosArray[7].x, self._curPosArray[7].y - 35)
    elseif angle <= -112.5 and angle > -157.5 then
        return cc.p(self._curPosArray[6].x - 35, self._curPosArray[6].y - 35)
    else
        return cc.p(self._curPosArray[4].x - 35, self._curPosArray[4].y)
    end
end

function WorldSoldierItem:timer(dt)
    if self._info.move_cd <= 0 then
        return
    end
    self._info.move_cd = self._info.move_cd - dt
    if self._info.move_cd < 0 then
        self._info.move_cd = 0
    end
    self._soldierImg:setContentSize(cc.size(self._soldierImgSize.width * self._info.move_cd / self._totalTime, self._soldierImgSize.height))
    self._timeLabel:setString(uq.getTime(self._info.move_cd, uq.config.constant.TIME_TYPE.HHMMSS))
end

return WorldSoldierItem
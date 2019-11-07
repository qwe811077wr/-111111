local WorldSoldier = class("WorldSoldier", require('app.base.ChildViewBase'))

function WorldSoldier:onCreate()
    WorldSoldier.super.onCreate(self)

    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.ROLE)
    self._info = nil
    self._canMove = false
    self._path = {}
    self._linePath = {}
    self._fromCity = 0
    self._toCity = 0
    self._line = nil
    self._soliderNode = uq.createPanelOnly('world.WorldSoldierItem')
    self:addChild(self._soliderNode)
    self:setLocalZOrder(102)
end

function WorldSoldier:onExit()
    WorldSoldier.super.onExit(self)
end

function WorldSoldier:updateCityPath()
    self._fromCity = self._info.from_city
    self._toCity = self._info.to_city
    return math.floor(self:updatePath() - self._info.move_cd)
end

function WorldSoldier:updateLinePath()
    for i = 1, #self._info.path_ids - 1, 1 do
        local cur_city = self._info.path_ids[i]
        local to_city = self._info.path_ids[i + 1]
        local info = StaticData['world_road'][cur_city]
        if not info then
            break
        end
        local rold = info.Road[to_city]
        if not rold then
            break
        end
        local rold_array = string.split(rold.path, ";")
        for k, v in ipairs(rold_array) do
            local path = string.split(v, ",")
            local pos = {
                x = tonumber(path[1]) - self._mapSize.width / 2,
                y = -tonumber(path[2]) + self._mapSize.height / 2
            }
            table.insert(self._linePath, pos)
        end
    end
    self:createLine(self._linePath)
end

function WorldSoldier:setInfo(info, size)
    self._info = info
    self._mapSize = size
    local data = {
        role_id = self._info.role_id,
        army_id = self._info.army_id,
        move_cd = self._info.move_cd,
        crop_id = self._info.crop_id
    }
    self._soliderNode:setInfo(data)
    local left_time = self:updateCityPath()
    local from_info = StaticData['world_city'][self._fromCity]
    local pos = {
        x = from_info.pos_x - self._mapSize.width / 2,
        y = -from_info.pos_y + self._mapSize.height / 2
    }
    table.insert(self._path, 1, pos)
    table.insert(self._linePath, 1, pos)
    self:updateLinePath()
    local to_info = StaticData['world_city'][self._toCity]
    local index = 0
    for i = 1, #self._path - 1, 1 do
        local cur_pos = self._path[i]
        local dest_pos = self._path[i + 1]
        local distance = cc.pGetDistance(cur_pos, dest_pos)
        left_time = left_time - distance / to_info.speed
        if left_time < 0 then
            left_time = left_time + distance / to_info.speed
            self._normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
            self._soliderNode:setAngle(cur_pos, dest_pos)
            self._speed = to_info.speed
            local off = cc.pAdd(cur_pos, cc.pMul(self._normal, self._speed * math.floor(left_time)))
            self:setPosition(off)
            break
        end
        index = index + 1
    end
    while index > 0 do
        table.remove(self._path, 1)
        index = index -1
    end
    self._canMove = true
end

function WorldSoldier:updatePath(is_update_city)
    self._canMove = false
    if is_update_city then
        for i = 1, #self._info.path_ids - 1, 1 do
            if self._info.path_ids[i] == self._fromCity then
                self._fromCity = self._info.path_ids[i + 1]
                if self._fromCity == self._info.path_ids[#self._info.path_ids] then
                    --已经到最后城池
                    return 0
                else
                    self._toCity = self._info.path_ids[i + 2]
                end
                break
            end
        end
    elseif self._fromCity == 0 then --没有数据
        return 0
    end
    self._path = {}
    local info = StaticData['world_road'][self._fromCity]
    if not info then
        return 0
    end
    local rold = info.Road[self._toCity]
    if not rold then
        return 0
    end
    local to_info = StaticData['world_city'][self._toCity]
    if not to_info then
        return 0
    end
    self._speed = to_info.speed
    local rold_array = string.split(rold.path, ";")
    for k, v in ipairs(rold_array) do
        local path = string.split(v, ",")
        local pos = {
            x = tonumber(path[1]) - self._mapSize.width / 2,
            y = -tonumber(path[2]) + self._mapSize.height / 2
        }
        table.insert(self._path, pos)
    end
    if #self._path > 0 then
        --确定当前模型所在坐标
        local from_info = StaticData['world_city'][self._fromCity]
        if from_info == nil then
            return 0
        end
        local pos = {
            x = from_info.pos_x - self._mapSize.width / 2,
            y = -from_info.pos_y + self._mapSize.height / 2
        }
        table.insert(self._path, 1, pos)
        table.remove(self._path, 1)
        self._canMove = true
        return rold.distance / to_info.speed
    end
    return 0
end

function WorldSoldier:endPath()
    self._canMove = false
    self._line:removeSelf()
    self:removeSelf()
end

function WorldSoldier:timer(dt)
    if not self._canMove then
        return
    end
    self._soliderNode:timer(dt)
    local x, y = self:getPosition()
    local cur_pos = cc.p(x, y)

    if #self._path == 0 then
        self._normal = nil
        local time = self:updatePath(true)
        if time > 0 then
            local data = {
                role_id = self._info.role_id,
                army_id = self._info.army_id,
                crop_id = self._info.crop_id,
                move_cd = time,
            }
            self._soliderNode:setInfo(data)
        end
        return
    end

    local dest_pos = self._path[1]

    if not self._normal then
        self._normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
        self._soliderNode:setAngle(cur_pos, dest_pos)
    end

    if cc.pGetDistance(cur_pos, dest_pos) == 0 then
        self._normal = nil
        table.remove(self._path, 1)
        return
    end
    local deth = self._speed * dt
    local off = cc.pMul(self._normal, deth)
    if cc.pGetDistance(cur_pos, dest_pos) <= cc.pGetDistance(cc.p(0, 0), off) * 5 then
        self:setPosition(dest_pos)
        self._normal = nil
        table.remove(self._path, 1)
        return
    else
        self:setPosition(cc.pAdd(cur_pos, off))
    end
end

function WorldSoldier:getInfo()
    return self._info
end

function WorldSoldier:createLine(path)
    if self._line then
        self._line:removeSelf()
    end
    self._line = uq.createPanelOnly('world.SoldierLine')

    self._line:initData(path, uq.cache.world_war:getRoadPath(self._info.role_id, self._info.crop_id))
    self:getParent():addChild(self._line)
end

function WorldSoldier:setSpeed(speed)
    self._speed = speed
end

return WorldSoldier
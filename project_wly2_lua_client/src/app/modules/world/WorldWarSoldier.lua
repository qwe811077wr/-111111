local WorldWarSoldier = class("WorldWarSoldier", require('app.base.ChildViewBase'))

function WorldWarSoldier:onCreate()
    WorldWarSoldier.super.onCreate(self)

    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.ROLE)
    self._canMove = false
    self._path = {}
    self._line = nil
    self._soliderNode = uq.createPanelOnly('world.WorldSoldierItem')
    self:addChild(self._soliderNode)
    self:setLocalZOrder(102)
end

function WorldWarSoldier:onExit()
    WorldWarSoldier.super.onExit(self)
end

function WorldWarSoldier:getInfo()
    return self._info
end

function WorldWarSoldier:setInfo(info)
    self._info = info.data
    self._path = info.path_ids
    self._moveCd = info.data.move_cd
    local data = {
        role_id = self._info.id,
        army_id = self._info.army_id,
        move_cd = self._info.move_cd,
        crop_id = self._info.crop_id
    }
    self._soliderNode:setInfo(data)
    self:createLine(self._path)
    --确定当前模型所在坐标
    local cur_pos = self._path[1]
    local dest_pos = self._path[2]
    local distance = cc.pGetDistance(cur_pos, dest_pos)
    self._normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
    self._soliderNode:setAngle(cur_pos, dest_pos)
    self:setPosition(cur_pos)
    local time = distance / self._speed
    if time > self._moveCd then
        local off = cc.pAdd(cur_pos, cc.pMul(self._normal, self._speed * math.floor(time - self._moveCd)))
        self:setPosition(off)
    end
    table.remove(self._path, 1)
    self._canMove = true
end

function WorldWarSoldier:endPath()
    self._canMove = false
    self._line:removeSelf()
    self:removeSelf()
end

function WorldWarSoldier:timer(dt)
    if not self._canMove then
        return
    end
    self._soliderNode:timer(dt)
    local x, y = self:getPosition()
    local cur_pos = cc.p(x, y)

    if #self._path == 0 then
        self._normal = nil
        self._canMove = false
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

function WorldWarSoldier:createLine(path)
    if self._line then
        self._line:removeSelf()
    end
    self._line = uq.createPanelOnly('world.SoldierLine')
    self._line:initData(path)
    self:getParent():addChild(self._line)
end

function WorldWarSoldier:setSpeed(speed)
    self._speed = speed
end

return WorldWarSoldier
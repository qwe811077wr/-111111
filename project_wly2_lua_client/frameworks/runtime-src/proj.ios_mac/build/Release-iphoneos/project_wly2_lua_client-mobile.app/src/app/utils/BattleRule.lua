local BattleRule = class("BattleRule")

BattleRule.SKILL_TARGET_TYPE = {
    HORIZON_FIRST_ENEMY = 1,
    HORIZON_ALL_ENEMY = 2,
    ALL_ENEMY = 3,
    HORIZON_VERTICAL_ENEMY = 4,
    HORIZON_LAST_ENEMY = 5,
    SELF_OWN = 6,
    ALL_SELF_OWN = 7,
    ALL_EXCEPT_SELF_OWN = 8,
    RANDOM_OWN = 9,
    ALL_OWN_ENEMY = 10,
    ALL_OWN_ENEMY_EXC_SELF = 11,
    HORIZON_FIRST_SELF = 12,
    MIN_PERCENT_SOLDIER_ENEMY = 13,
    MAX_MORAL_ENEMY = 14,
    MIN_PERCENT_SOLDIER_SELF = 15,
    MAX_MORAL_SELF = 16,
    RANDOM_ENEMY = 17,
    MAX_SOLDIER_ENEMY = 18,
    RANDOM_HORIZOL_ENEMY = 19,
}

BattleRule.POP_TEXT = {
    blood    = 1,
    moral    = 3,
    hit      = 5,
    against  = 6,
    restrain = 7,
}

function BattleRule:ctor()

end

function BattleRule:getSkillTarget(cur_soldier_group, target_type, cells)
    local targets = {}
    local side_self = cells[cur_soldier_group:side()]
    local side_enemy = cells[3 - cur_soldier_group:side()]
    local pos_self = cur_soldier_group:pos()
    local line_self = math.floor((pos_self - 1) / 3) + 1
    local vertical_self = (pos_self - 1) % 3 + 1
    local skill_target_type = self.SKILL_TARGET_TYPE

    if target_type == skill_target_type.HORIZON_FIRST_ENEMY then
        local cells_target = self:getHorizol(line_self, side_enemy)
        if #cells_target > 0 then
            table.insert(targets, cells_target[1])
        end
    elseif target_type == skill_target_type.HORIZON_ALL_ENEMY then
        local cells_target = self:getHorizol(line_self, side_enemy)
        return cells_target
    elseif target_type == skill_target_type.ALL_ENEMY then
        return self:getAllCells(side_enemy)
    elseif target_type == skill_target_type.HORIZON_VERTICAL_ENEMY then
        local cells_target = self:getHorizol(line_self, side_enemy)
        if #cells_target > 0 then
            local vertical = (cells_target[1]:pos() - 1) % 3 + 1
            return self:getVertical(vertical, side_enemy)
        end
    elseif target_type == skill_target_type.HORIZON_LAST_ENEMY then
        local cells_target = self:getHorizol(line_self, side_enemy)
        if #cells_target > 0 then
            table.insert(targets, cells_target[#cells_target])
        end
    elseif target_type == skill_target_type.SELF_OWN then
        table.insert(targets, cur_soldier_group)
    elseif target_type == skill_target_type.ALL_SELF_OWN then
        return self:getAllCells(side_self)
    elseif target_type == skill_target_type.ALL_EXCEPT_SELF_OWN then
        for k, item in pairs(side_self) do
            if item ~= cur_soldier_group then
                table.insert(item, targets)
            end
        end
    elseif target_type == skill_target_type.RANDOM_OWN then
        local cells_target = {}
        for k, item in pairs(side_self) do
            if item ~= cur_soldier_group then
                table.insert(item, cells_target)
            end
        end
        table.insert(targets, cells_target[math.random(1, #cells_target)])
    elseif target_type == skill_target_type.ALL_OWN_ENEMY then
        for k, item in pairs(side_self) do
            table.insert(item, targets)
        end
        for k, item in pairs(side_enemy) do
            table.insert(item, targets)
        end
    elseif target_type == skill_target_type.ALL_OWN_ENEMY_EXC_SELF then
        for k, item in pairs(side_self) do
            if item ~= cur_soldier_group then
                table.insert(item, targets)
            end
        end
        for k, item in pairs(side_enemy) do
            table.insert(item, targets)
        end
    elseif target_type == skill_target_type.HORIZON_FIRST_SELF then
        local cells_target = self:getHorizol(line_self, side_enemy)
        if #cells_target > 0 then
            table.insert(targets, cells_target[1])
        end
        table.insert(targets, cur_soldier_group)
    elseif target_type == skill_target_type.MIN_PERCENT_SOLDIER_ENEMY then
        local target = self:getMinSoldierNum(side_enemy)
        if target then
            table.insert(targets, target)
        end
    elseif target_type == skill_target_type.MAX_MORAL_ENEMY then
        local target = self:getMaxMoral(side_enemy)
        if target then
            table.insert(targets, target)
        end
    elseif target_type == skill_target_type.MIN_PERCENT_SOLDIER_SELF then
        local target = self:getMinSoldierNum(side_self)
        if target then
            table.insert(targets, target)
        end
    elseif target_type == skill_target_type.MAX_MORAL_SELF then
        local target = self:getMaxMoral(side_self)
        if target then
            table.insert(targets, target)
        end
    elseif target_type == skill_target_type.RANDOM_ENEMY then
        local cells_target = {}
        for k, item in pairs(side_enemy) do
            table.insert(item, cells_target)
        end
        table.insert(targets, cells_target[math.random(1, #cells_target)])
    elseif target_type == skill_target_type.MAX_SOLDIER_ENEMY then
        local target = self:getMaxSoldierNum(side_enemy)
        if target then
            table.insert(targets, target)
        end
    elseif target_type == skill_target_type.RANDOM_HORIZOL_ENEMY then
        local cells_target = self:getHorizol(line_self, side_enemy)
        if #cells_target > 0 then
            table.insert(targets, cells_target[math.random(1, #cells_target)])
        end
    end
    return targets
end

function BattleRule:getMinSoldierNum(cells_all)
    if #cells_all == 0 then
        return
    end

    local cur_cell = cells_all[1]
    for k, item in pairs(cells_all) do
        if cur_cell:getSoldierPercent() < item:getSoldierPercent() then
            cur_cell = item
        end
    end
    return cur_cell
end

function BattleRule:getMaxSoldierNum(cells_all)
    if #cells_all == 0 then
        return
    end

    local cur_cell = cells_all[1]
    for k, item in pairs(cells_all) do
        if cur_cell:getSoldierPercent() > item:getSoldierPercent() then
            cur_cell = item
        end
    end
    return cur_cell
end

function BattleRule:getMinMoral(cells_all)
    if #cells_all == 0 then
        return
    end

    local cur_cell = cells_all[1]
    for k, item in pairs(cells_all) do
        if cur_cell:getMoral() < item:getMoral() then
            cur_cell = item
        end
    end
    return cur_cell
end

function BattleRule:getMaxMoral(cells_all)
    if #cells_all == 0 then
        return
    end

    local cur_cell = cells_all[1]
    for k, item in pairs(cells_all) do
        if cur_cell:getMoral() > item:getMoral() then
            cur_cell = item
        end
    end
    return cur_cell
end

function BattleRule:getAllCells(cells_all)
    local cells = {}
    for i = 1, 9 do
        if cells_all[i] then
            table.insert(cells, cells_all[i])
        end
    end
    return cells
end

function BattleRule:getHorizol(line, cells_all)
    local cells = {}
    local side = 1
    for i = 1, 3 do
        if cells_all[(line - 1) * 3 + i] then
            side = cells_all[(line - 1) * 3 + i]:side()
            break
        end
    end
    if side == 1 then --左边
        for i = 3, 1, -1 do
            if cells_all[(line - 1) * 3 + i] then
                table.insert(cells, cells_all[(line - 1) * 3 + i])
            end
        end
    else --右边
        for i = 1, 3 do
            if cells_all[(line - 1) * 3 + i] then
                table.insert(cells, cells_all[(line - 1) * 3 + i])
            end
        end
    end
    return cells
end

function BattleRule:getVertical(vertical, cells_all)
    local cells = {}
    for i = 1, 3 do
        if cells_all[(i - 1) * 3 + vertical] then
            table.insert(cells, cells_all[(i - 1) * 3 + vertical])
        end
    end
    return cells
end

function BattleRule:popText(parent_node, text_type, num)
    local pop_node = uq.createPanelOnly('battle.BattlePopText')
    parent_node:addChild(pop_node)
    pop_node:popText(text_type, num)
end

uq.BattleRule = BattleRule
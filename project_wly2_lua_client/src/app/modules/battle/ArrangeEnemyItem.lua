local ArrangeEnemyItem = class("ArrangeEnemyItem", require('app.base.ChildViewBase'))

ArrangeEnemyItem.RESOURCE_FILENAME = "battle/ArrangeItem.csb"
ArrangeEnemyItem.RESOURCE_BINDING = {
    ["Sprite_3"]    ={["varname"]="_spriteBg2"},
    ["Sprite_2"]    ={["varname"]="_spiritBgNotOpen"},
    ["Panel_name"]  ={["varname"]="_spriteBg3"},
    ["Node_4"]      ={["varname"]="_nodeLock"},
    ["lock_label"]  ={["varname"]="_txtLocked"},
    ["panel_touch"] ={["varname"]="_btnBg",["events"]={{["event"]="touch",["method"]="onBg",["sound_id"] = 3}}},
    ["Text_2"]      ={["varname"]="_txtName"},
    ["Text_6"]      ={["varname"]="_txtSoldierName"},
    ["Sprite_1"]    ={["varname"]="_spriteNormal"},
    ["soldiers"]    ={["varname"]="_nodeSoldier"},
    ["Node_23"]     ={["varname"]="_nodeHead"},
    ["Text_1"]      ={["varname"]="_txtPrecent"},
    ["hp"]          ={["varname"]="_loadingBar"},
}

function ArrangeEnemyItem:onCreate()
    ArrangeEnemyItem.super.onCreate(self)
    self:parseView()
    self._soldiers = {}
    self._index = 0
    self._soldierNum = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    self._fillPos = {7, 5, 9, 2, 1, 4, 6, 3, 8}
end

function ArrangeEnemyItem:setData(index, data, injure_state)
    self._roleDatas = data
    self._btnBg:setVisible(data ~= nil)
    self._spriteNormal:setVisible(data ~= nil)
    self._nodeSoldier:setVisible(data ~= nil)
    self._spriteBg3:setVisible(data ~= nil)
    if not data then
        return
    end
    self._index = index
    self._soldierId = data.soldierId or data.soldier_id

    local soldier_data = StaticData['soldier'][self._soldierId]
    if soldier_data.fillType == 2 then
        self._soldierNum = {2, 4, 6, 7, 8, 9}
    elseif soldier_data.fillType == 3 then
        self._soldierNum = {6, 7, 8, 9}
    end

    for i = 1, 9 do
        local node_pos = self._nodeSoldier:getChildByName(i)
        if node_pos:getChildByName('img') then
            node_pos:getChildByName('img'):setVisible(false)
        end
    end

    for k, item in ipairs(self._soldierNum) do
        local node_pos = self._nodeSoldier:getChildByName(item)
        if node_pos:getChildByName('img') then
            node_pos:getChildByName('img'):setVisible(true)
        end
    end

    self:formation()
    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._index - 1) / 3) + 1
    self._txtName:setString(data.name)
    local general_id = data.generalId or data.general_id
    local general_config = StaticData['general'][general_id]
    local image = ccui.ImageView:create('img/common/general_head/' .. general_config.icon)
    image:setScale(0.27)
    self._nodeHead:removeAllChildren()
    uq.cache.formation:clipHead(image, self._nodeHead, cc.p(0, -12))
    local soldier_config = StaticData['soldier'][self._soldierId]
    if soldier_config then
        local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_config.type]
        self._txtSoldierName:setString(type_solider1.shortName)
        self._txtSoldierName:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
            self._soldiers = {}
            for i = 1, #self._soldierNum do
                local node_pos = self._nodeSoldier:getChildByName(self._soldierNum[i])
                local horizon_num = math.floor((node_pos.pos_index - 1) / 3) + 1
                local line = horizon_num + (cell_line - 1) * 3
                line = 9 - line + 1
                local soldier = uq.createPanelOnly('battle.BattleSoldier')
                soldier:setData({soldier_id = self._soldierId}, 2, false, self._soldierNum[i], node_pos.pos_index)
                node_pos:removeAllChildren()
                node_pos:addChild(soldier)
                soldier:setScale(xml_data[line].scale)
                soldier:setName('soldier')
                soldier:playIdle()
                table.insert(self._soldiers, soldier)
            end
        end)))
    end

    if data.cur_soldier_num and data.max_soldier_num then
        local cur_soldier_num = injure_state and data.cur_soldier_num or data.max_soldier_num
        self._txtPrecent:setString(cur_soldier_num .. '/' .. data.max_soldier_num)
        self._loadingBar:setPercent(cur_soldier_num / data.max_soldier_num * 100)
    else
        local npc_info = uq.cache.generals:getNpcDataByLevel(data.level)
        if not npc_info then
            return
        end
        self._txtPrecent:setString(npc_info.soldierNum .. '/' .. npc_info.soldierNum)
        self._loadingBar:setPercent(100)
    end
end

function ArrangeEnemyItem:formation()
    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._index - 1) / 3) + 1
    local soldier_data = StaticData['soldier'][self._soldierId]
    local offx = {0, 30, 60}
    self._spacex = 30

    for i = 1, 9 do
        local index = math.floor((i - 1) / 3) + 1
        local line = index + (cell_line - 1) * 3
        line = 9 - line + 1
        local off = offx[index]
        local x = (i - 1) % 3 * self._spacex + off
        local y = 0 - math.floor((i - 1) / 3) * 15 + (i - 1) % 3 * 15
        local node_pos = self._nodeSoldier:getChildByName(self._fillPos[i])
        node_pos:setPosition(cc.p(x, y))
        node_pos.pos_index = i
    end

    if next(self._soldiers) ~= nil then
        return
    end
    local soldier_data = StaticData['soldier'][self._soldierId]
    for i = 1, #self._soldierNum do
        local node = self._nodeSoldier:getChildByName(self._soldierNum[i]):getChildByName("img")
        node:loadTexture("img/soldier/" .. soldier_data.action .. "_" .. 2 .. ".png")
    end
end

function ArrangeEnemyItem:onBg(event)
    if not self._roleDatas or not self._onIconTouchCallback then
        return
    end
    local node_base = self:getChildByName("Node")
    local pos = self:convertToWorldSpace(cc.p(node_base:getPosition()))
    local data = nil
    if self._roleDatas.skill_id then
        data = {
            battle_soldier_id = self._roleDatas.soldier_id,
            skill_id          = self._roleDatas.skill_id,
        }
    else
        local info = uq.cache.generals:getGeneralDataXML(self._roleDatas.generalId)
        data = {
            battle_soldier_id = self._roleDatas.soldierId,
            skill_id          = info.skillId,
        }
    end
    self._onIconTouchCallback({data}, self._index, event, cc.p(pos.x + 150, pos.y - 200))
end

function ArrangeEnemyItem:setIconTouchCallback(callback)
    self._onIconTouchCallback = callback
end

function ArrangeEnemyItem:playAttack()
    for k, item in ipairs(self._soldiers) do
        item:playAttack(function()
            item:playIdle()
        end)
    end
end

return ArrangeEnemyItem







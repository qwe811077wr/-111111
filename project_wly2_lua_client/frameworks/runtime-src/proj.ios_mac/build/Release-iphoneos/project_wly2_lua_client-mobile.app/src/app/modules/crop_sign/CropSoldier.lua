local CropSoldier = class("CropSoldier", require('app.base.ChildViewBase'))

CropSoldier.RESOURCE_FILENAME = "crop_sign/CropSignSoldier.csb"
CropSoldier.RESOURCE_BINDING = {
    ["Text_1"]     = {["varname"] = "_txtName"},
    ["Node_24"]    = {["varname"] = "_nodeSoldier"},
    ["Image_7"]    = {["varname"] = "_imgFinish"},
    ["Text_1_0_0"] = {["varname"] = "_txtWin"},
    ["Image_8"]    = {["varname"] = "_imgWinBg"},
    ["Text_1_0"]   = {["varname"] = "_txtWinNum"},
    ["Image_3"]    = {["varname"] = "_imgWinNumBg"},
    ["Panel_1"]    = {["varname"] = "_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onPanelTouch"}}},
}

function CropSoldier:onCreate()
    CropSoldier.super.onCreate(self)
end

function CropSoldier:setData(xml_data, stage_level, index)
    self._curLevel = stage_level
    local strs = string.split(xml_data.Stage[stage_level].troop, ';')
    local troops = string.split(strs[index], ',')
    if tonumber(troops[1]) ~= self._troopId then
        self._troopId = tonumber(troops[1])
        self._totalStar = tonumber(troops[2])
        self._xmlTroop = StaticData['war_sign'].WarTroop[self._troopId]
        self._txtName:setString(self._xmlTroop.name)
        self._nodeSoldier:removeAllChildren()

        local soldier_data = StaticData['soldier'][self._xmlTroop.Icon]
        local panel = uq.createPanelOnly('instance.InstanceSoldier')
        panel:setData(nil, nil, soldier_data.idleAction, false, 'idle')
        panel:playIdle()
        self._nodeSoldier:addChild(panel)
        self:setPosition(cc.p(xml_data['x' .. index] - display.width / 2, xml_data['y' .. index] - display.height / 2))
    end
end

function CropSoldier:refreshData(stars, cur_troop_id, times)
    self._curTroopId = cur_troop_id
    self._times = times
    local passed = cur_troop_id == self._troopId and times > 0
    local star = stars[self._troopId] or 0
    self._imgFinish:setVisible(passed)
    self._txtWin:setVisible(star == self._totalStar)
    self._imgWinBg:setVisible(star == self._totalStar)
    self._txtWinNum:setVisible(star < self._totalStar)
    self._imgWinNumBg:setVisible(star < self._totalStar)
    self._txtWinNum:setString(StaticData['local_text']['label.win'] .. string.format(' %d/%d', star, self._totalStar))

    if passed then
        if self._knife then
            self._knife:removeSelf()
            self._knife = nil
        end
    else
        if cur_troop_id == self._troopId then
            if not self._knife then
                self._knife = uq.createPanelOnly('instance.AnimationKnife')
                self:addChild(self._knife)
                self._knife:setPositionY(100)
            end
        else
            if self._knife then
                self._knife:removeSelf()
                self._knife = nil
            end
        end
    end
end

function CropSoldier:onPanelTouch(event)
    if event.name ~= 'ended' then
        return
    end

    if self._times > 0 then
        uq.fadeInfo(StaticData['local_text']['label.finish'])
        return
    end

    if self._curTroopId > 0 and self._curTroopId ~= self._troopId then
        uq.fadeInfo(StaticData['local_text']['label.attack.cur'])
        return
    end

    local info = uq.cache.crop:getFormationInfo()
    local army_data = {
        ids    = {info.formation_id},
        array  = {'army_1'},
        army_1 = info.general_loc
    }

    local enemy_data = StaticData['war_sign'].WarTroop[self._troopId].Army
    local data = {
        enemy_data = enemy_data,
        army_data = {army_data},
        embattle_type = uq.config.constant.TYPE_EMBATTLE.CROP_SIGN,
        confirm_callback = function()
            network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_BATTLE, {id = self._curLevel, troop_id = self._troopId})
        end
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

return CropSoldier
local BuildSpeedUpItem = class("BuildSpeedUpItem", require('app.base.ChildViewBase'))

BuildSpeedUpItem.RESOURCE_FILENAME = "main_city/BuilderSpeedUpItem.csb"
BuildSpeedUpItem.RESOURCE_BINDING = {
    ["Image_3"]    = {["varname"] = "_imgIcon"},
    ["Text_1"]     = {["varname"] = "_txtName"},
    ["Text_1_0_0"] = {["varname"] = "_txtNum"},
    ["Text_1_0_1"] = {["varname"] = "_txtDesc"},
    ["Button_1"]   = {["varname"] = "_btnMulti",["events"] = {{["event"] = "touch",["method"] = "onMulti",["sound_id"] = 0}}},
    ["Button_1_0"] = {["varname"] = "_btnSingle",["events"] = {{["event"] = "touch",["method"] = "onSingle",["sound_id"] = 0}}},
}

function BuildSpeedUpItem:onCreate()
    BuildSpeedUpItem.super.onCreate(self)

end

function BuildSpeedUpItem:setData(data, build_id, is_strategy)
    self._data = data
    self._isStrategy = is_strategy
    self._buildID = build_id
    self._imgIcon:loadTexture('img/common/item/' .. data.icon)
    self._txtName:setString(data.name)

    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, data.ident)
    self._txtNum:setString(uq.formatResource(num, true))
    self._txtDesc:setString(data.desc)
end

function BuildSpeedUpItem:onMulti(event)
    if event.name ~= "ended" then
        return
    end
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, self._data.ident)
    if num < 1 then
        uq.fadeInfo(StaticData['local_text']["strategy.less.prop"])
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(23)
    local cost_num = num == 1 and 1 or 2
    if not self._isStrategy then
        local data = {
            build_id = self._buildID,
            material_id = self._data.ident,
            material_num = cost_num
        }
        network:sendPacket(Protocol.C_2_S_BUILD_SPEED_UP, data)
        return
    end
    local data = {
        id          = self._buildID,
        material_id = self._data.ident,
        material_num = cost_num
    }
    network:sendPacket(Protocol.C_2_S_TECHNOLOGY_SPEED_UP, data)
end

function BuildSpeedUpItem:onSingle(event)
    if event.name ~= "ended" then
        return
    end
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, self._data.ident)
    if num < 1 then
        uq.fadeInfo(StaticData['local_text']["strategy.less.prop"])
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(23)
    if not self._isStrategy then
        local data = {
            build_id = self._buildID,
            material_id = self._data.ident,
            material_num = 1
        }
        network:sendPacket(Protocol.C_2_S_BUILD_SPEED_UP, data)
        return
    end
    local data = {
        id          = self._buildID,
        material_id = self._data.ident,
        material_num = 1
    }
    network:sendPacket(Protocol.C_2_S_TECHNOLOGY_SPEED_UP, data)
end

return BuildSpeedUpItem
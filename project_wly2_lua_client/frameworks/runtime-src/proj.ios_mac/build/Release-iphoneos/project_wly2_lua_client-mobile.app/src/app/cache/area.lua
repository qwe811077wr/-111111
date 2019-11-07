local Area = class("Area")

function Area:ctor()
    self._maxAreaNum = 0
    self._curCityInfo = {}
    self._faceGet = {} --已经获得皮肤

    network:addEventListener(Protocol.S_2_C_AREA_PARTINFO, handler(self, self._onAreaPartInfo))
    network:addEventListener(Protocol.S_2_C_AREA_MAXSEQNO, handler(self, self._onMaxAreaNum))
    network:addEventListener(Protocol.S_2_C_AREA_ZONE_INFO, handler(self, self._onAreaZoneInfo))
    network:addEventListener(Protocol.S_2_C_CITY_SKIN_INFO, handler(self, self._onSkinInfoRet))
    network:addEventListener(Protocol.S_2_C_CITY_SKIN_SELECT, handler(self, self._onSkinSelectRet))
    network:addEventListener(Protocol.S_2_C_AREA_ZONE_ADD, handler(self, self._areaZoneAdd))
end

function Area:_onWorldAeraInfo(msg)
    uq.log('Area:_onWorldAeraInfo', msg)
end

function Area:_onMaxAreaNum(msg)
    self._maxAreaNum = msg.data.city_seq_no
end

function Area:_onAreaPartInfo(msg)
    uq.log('Area:_onAreaPartInfo', msg)

    self._curCityInfo = msg.data.city

    local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_MODULE)
    if area_view then
        area_view:loadCity()
    end

    local face_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_CITY_FACE)
    if face_view then
        face_view:refreshCurPage()
    end

    local info_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_CITY_INFO)
    if info_view then
        info_view:refreshCurPage()
    end
end

function Area:getCityInfo()
    return self._curCityInfo
end

function Area:attackTitle(attack_val)
    local config = StaticData['types'].AttackCount[1].Type
    for k,item in ipairs(config) do
        if attack_val <= item.maxAttackCount then
            return item
        end
    end
    return StaticData['types'].AttackCount[1].Type[9]
end

function Area:_onAreaZoneInfo(msg)
    local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_CITY_INFO)
    if area_view then
        area_view:setMaster(msg.data)
    end

    local follower_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_FOLLOWER)
    if follower_view then
        follower_view:refreshPage(msg.data)
    end
end

function Area:_onSkinInfoRet(msg)
    self._faceGet = {}

    if msg.data.citySkinInfo == '' then
        return
    end

    local items = string.split(msg.data.citySkinInfo, ',')
    for k,item in ipairs(items) do
        local group = string.split(item, ';')
        self._faceGet[group[1]] = group[2]
    end

    local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_CITY_FACE)
    if area_view then
        area_view:setFace()
    end
end

function Area:_onSkinSelectRet(msg)
    local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_MODULE)
    if area_view then
        area_view:refreshCurPage()
    end
end

function Area:_areaZoneAdd(msg)
    local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_MODULE)
    if area_view then
        area_view:refreshCurPage()
    end
end

return Area
local BuildPopInfo = class("BuildPopInfo", require('app.base.ChildViewBase'))

BuildPopInfo.RESOURCE_FILENAME = "main_city/PopInfo.csb"
BuildPopInfo.RESOURCE_BINDING = {
    ["Image_6"]  = {["varname"] = "_imgCrop",["events"] = {{["event"] = "touch",["method"] = "onCropHelp",["sound_id"] = 0}}},
    ["Image_1"]  = {["varname"] = "_imgRes",["events"] = {{["event"] = "touch",["method"] = "onCropHelp",["sound_id"] = 0}}},
    ["Sprite_3"] = {["varname"] = "_spriteIcon"},
    ["Node_1"]   = {["varname"] = "_nodeRes"},
}

function BuildPopInfo:onCreate()
    BuildPopInfo.super.onCreate(self)

    local action1 = cc.MoveBy:create(1, cc.p(0, 10))
    local action2 = cc.MoveBy:create(1, cc.p(0, -10))
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
end

function BuildPopInfo:setData(build_data, show_type)
    self._buildData = build_data
    self._showType = show_type
    self._nodeRes:setVisible(self._showType == uq.config.constant.POP_SHOW_TYPE.RES or self._showType == uq.config.constant.POP_SHOW_TYPE.RT_DECREE)
    self._imgCrop:setVisible(self._showType == uq.config.constant.POP_SHOW_TYPE.CROP or self._showType == uq.config.constant.POP_SHOW_TYPE.RELATION)

    if self._showType == uq.config.constant.POP_SHOW_TYPE.RES then
        local office_xml = StaticData['officer_build_map'][uq.cache.role:getBuildType(build_data.build_id)]
        if office_xml and office_xml.reward ~= "" then
            local reward = uq.RewardType.new(office_xml.reward)
            self._spriteIcon:setTexture('img/common/ui/' .. reward:miniIcon())
        end
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.CROP then
        self._imgCrop:loadTexture('img/main_city/s03_000360.png')
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.RELATION then
        self._imgCrop:loadTexture('img/main_city/s03_000359.png')
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.RT_DECREE then
        self._spriteIcon:setTexture('img/common/ui/03_0011.png')
    end
end

function BuildPopInfo:onCropHelp(event)
    if event.name ~= "ended" then
        return
    end

    if self._showType == uq.config.constant.POP_SHOW_TYPE.CROP then
        uq.playSoundByID(37)
        network:sendPacket(Protocol.C_2_S_CROP_APPLY_HELP, {build_id = self._buildData.build_id})
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.RES then
        local info = StaticData['buildings']['CastleMap'][self._buildData.build_id]
        if info.type == uq.config.constant.BUILD_TYPE.HOUSE then
            uq.playSoundByID(42)
            network:sendPacket(Protocol.C_2_S_COLLECTION_MONEY)
        elseif info.type == uq.config.constant.BUILD_TYPE.FARM_LAND then
            uq.playSoundByID(39)
            network:sendPacket(Protocol.C_2_S_FRAM_HARVEST)
        elseif info.type == uq.config.constant.BUILD_TYPE.IRON then
            uq.playSoundByID(41)
            network:sendPacket(Protocol.C_2_S_COLLECTION_IRON)
        elseif info.type == uq.config.constant.BUILD_TYPE.SOLDIER then
            uq.playSoundByID(40)
            network:sendPacket(Protocol.C_2_S_COLLECTION_REDIF)
        else
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            network:sendPacket(Protocol.C_2_S_BUILD_GET_RESOURCE, {build_id = self._buildData.build_id})
        end
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.RELATION then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RELATION_SHIP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(self._buildData.build_id)
    elseif self._showType == uq.config.constant.POP_SHOW_TYPE.RT_DECREE then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.jumpToModule(uq.config.constant.MODULE_ID.RT_DECREE)
    end
end

return BuildPopInfo
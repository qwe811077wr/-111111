local NpcListItem = class("NpcListItem", require('app.base.ChildViewBase'))

NpcListItem.RESOURCE_FILENAME = "instance/NpcListItem.csb"
NpcListItem.RESOURCE_BINDING = {
    ["Sprite_3"] = {["varname"] = "_spriteHead"},
    ["Text_1"]   = {["varname"] = "_txtName"},
    ["star_1"]   = {["varname"] = "_spriteStar1"},
    ["star_2"]   = {["varname"] = "_spriteStar2"},
    ["star_3"]   = {["varname"] = "_spriteStar3"},
    ["Button_1"] = {["varname"] = "_btnAttack",["events"] = {{["event"] = "touch",["method"] = "onAttack"}}},
}

function NpcListItem:onCreate()
    NpcListItem.super.onCreate(self)

end

function NpcListItem:setData(data, callback)
    self._config = data.config
    self._instanceId = data.instance_id
    self._callback = callback

    self._spriteHead:setTexture(string.format('img/common/half_body/%s', self._config.headIcon))
    self._txtName:setString(self._config.Name)

    self._spriteStar1:setVisible(false)
    self._spriteStar2:setVisible(false)
    self._spriteStar3:setVisible(false)

    local npc_info = uq.cache.instance:getNPC(self._instanceId, self._config.ident)
    if npc_info.star then
        for i = 1, npc_info.star do
            self['_spriteStar' .. i]:setVisible(true)
        end
    end
end

function NpcListItem:onAttack(event)
    if event.name == "ended" then
        local pre_id = self._config.premiseObjectId
        if pre_id > 0 then
            local npc = uq.cache.instance:getNPC(self._instanceId, pre_id)
            if not npc or not npc.star or npc.star <= 0 then
                uq.fadeInfo(StaticData['local_text']['instance.pass.pre.first'])
                return
            end
        end

        local packet = {instance_id = self._instanceId, npc_id = self._config.ident}
        network:sendPacket(Protocol.C_2_S_INSTANCE_BATTLE, packet)

        if self._callback then
            self._callback()
        end
    end
end

return NpcListItem
local LikeItems = class("LikeItems", require('app.base.ChildViewBase'))

LikeItems.RESOURCE_FILENAME = "retainer/LikeItems.csb"
LikeItems.RESOURCE_BINDING = {
    ["Text_9_0"]                = {["varname"] = "_txtLike"},
    ["Node_1"]                  = {["varname"] = "_itemsNode"},
    ["Button_2"]                = {["varname"] = "_btnOk"},
}

function LikeItems:onCreate()
    LikeItems.super.onCreate(self)
end

function LikeItems:setData(data, is_suzerain, intimacy, id)
    self:parseView()
    local data = data or {}
    self._txtLike:setString(tostring(data.name))
    self._itemsNode:removeAllChildren()
    local reward = data.reward
    if is_suzerain then
        reward = data.reward1
    end
    local tab_award = self:dealAward(reward)
    local num = math.min(4, #tab_award)
    for i = 1, num do
        local euqip_item = uq.createPanelOnly("retainer.PropItems")
        euqip_item:setPosition(cc.p(i * 80 - 40, -8))
        euqip_item:setScale(0.6)
        euqip_item:setData(tab_award[i])
        self._itemsNode:addChild(euqip_item)
    end
    self._btnOk:addClickEventListenerWithSound(function ()
        if uq.cache.retainer:getSuzerainEventStatus(data.ident) ~= 0 then
            uq.fadeInfo(StaticData["local_text"]["label.reward.is.get"])
            return
        end
        if intimacy < data. num then
            uq.fadeInfo(StaticData["local_text"]["retainer.not.enough"])
            return
        end
        local apprentice_id = id
        if is_suzerain then
            apprentice_id = uq.cache.role.id
        end
        if apprentice_id == 0 then
            return
        end
        --领取消息
        local data = {
            id = data.ident,
            apprentice_id = apprentice_id
        }
        network:sendPacket(Protocol.C_2_S_ZONG_DRAW_EVENT,data)
    end)
end

function LikeItems:dealAward(str)
    local tab = {}
    local str = str or ""
    local attr_array = string.split(str,"|")
    for k, v in ipairs(attr_array) do
        local attr = string.split(v, ";")
        table.insert(tab, {type = tonumber(attr[1]), id = tonumber(attr[3]), num = tonumber(attr[2])})
    end
    return tab
end

return LikeItems
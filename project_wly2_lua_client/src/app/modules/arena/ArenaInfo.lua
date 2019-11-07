local ArenaInfo = class("ArenaInfo", require('app.modules.common.BaseViewWithHead'))

ArenaInfo.RESOURCE_FILENAME = "arena/ArenaInfo.csb"
ArenaInfo.RESOURCE_BINDING = {
    ["Text_3_0"]       = {["varname"] = "_txtName"},
    ["Text_3_0_0_0"]   = {["varname"] = "_txtRank"},
    ["Text_3_0_0_1"]   = {["varname"] = "_txtLevel"},
    ["Text_3_0_0_1_1"] = {["varname"] = "_txtPower"},
    -- ["Text_35"]        = {["varname"] = "_txtArea"},
    ["node_formation"] = {["varname"] = "_nodeFormation"},
    ["Button_1_0"]     = {["varname"] = "_btnChat", ["events"] = {{["event"] = "touch", ["method"] = "_onChat"}}},
    ["Button_1"]       = {["varname"] = "_btnFriend", ["events"] = {{["event"] = "touch", ["method"] = "_onFriend"}}},
}

function ArenaInfo:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    --
    self._uiFormation = nil
    self._playerInfo = nil

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
end

function ArenaInfo:onCreate()
    ArenaInfo.super.onCreate(self)

    network:addEventListener(Protocol.S_2_C_ATHLETICS_VIEW_FORMATION, handler(self, self._onViewFormation), '_onViewFormation')
end

function ArenaInfo:onExit()
    network:removeEventListenerByTag('_onViewFormation')

    ArenaInfo.super:onExit()
end

function ArenaInfo:dispose()
    if self._uiFormation then
        self._uiFormation:dispose()
    end
    --
    ArenaInfo.super.dispose(self)
end

function ArenaInfo:setData(data)
    self._playerInfo = data
    self._txtName:setString(data.name)
    self._txtRank:setString(data.rank)
    -- self._txtArea:setString(string.format(StaticData['local_text']['arena.name.server'], 111))
    self._txtLevel:setString(data.level)
    self._txtPower:setString(data.power)
    self._btnChat:setVisible(data.type ~= 2)
    --
    self:getViewFormation(data.rank)
end

-- 请求玩家阵容信息
function ArenaInfo:getViewFormation(rank)
    network:sendPacket(Protocol.C_2_S_ATHLETICS_VIEW_FORMATION, {pos = tonumber(rank)})
end

-- 服务器返回玩家阵容信息
function ArenaInfo:_onViewFormation(evt)
    self._uiFormation = uq.createPanelOnly("embattle.EmbattleFormation")
    self._uiFormation:setParent(self._nodeFormation)
    self._uiFormation:initFormation(evt.data)
end

function ArenaInfo:_onChat(event)
    if event.name == "ended" then
        local data = {}
        data.sender_id = self._playerInfo.id
        data.role_name = self._playerInfo.name
        data.img_id = self._playerInfo.img_id
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ARENA_INFO)
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ARENA_VIEW)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CHAT_MAIN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, chatChannel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION})
        uq.cache.chat:createConversation(data, true)
    end
end

function ArenaInfo:_onFriend(event)
    if event.name == "ended" then
        uq.fadeInfo(StaticData['local_text']["label.common.module.des"])
    end
end

return ArenaInfo
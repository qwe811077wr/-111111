local Rank = class("Rank")

function Rank:ctor()
    network:addEventListener(Protocol.S_2_C_LOAD_ROLE_INFO_BY_ID, handler(self, self._onRoleInfo))
end

function Rank:_onRoleInfo(msg)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RANK_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    if panel then
        panel:setData(msg.data)
    end
end

return Rank
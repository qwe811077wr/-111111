local BosomModule = class("BosomModule", require('app.base.ModuleBase'))

BosomModule.RESOURCE_FILENAME = "bosom/EntranceView.csb"
BosomModule.RESOURCE_BINDING = {
    ["return_btn"]                   = {["varname"] = "_btnReturn"},
    ["container"]                    = {["varname"] = "_pnlContainer"},
    ["container/nt_btn"]             = {["varname"] = "_btnNt"},
    ["container/nt_btn/name"]        = {["varname"] = "_txtNtName"},
    ["container/xf_btn"]             = {["varname"] = "_btnXf"},
    ["container/xf_btn/name"]        = {["varname"] = "_txtXfName"},
    ["container/zj_btn"]             = {["varname"] = "_btnZj"},
    ["container/zj_btn/name"]        = {["varname"] = "_txtZjName"},
    ["container/addup_btn"]          = {["varname"] = "_btnAddUp"},
    ["container/help_btn"]           = {["varname"] = "_btnHelp"},
}

function BosomModule:ctor(name, params)
    BosomModule.super.ctor(self, name, params)
end

function BosomModule:init()
    self:centerView()
    self:parseView()
    local ShaderEffect = uq.ShaderEffect
    self._shaderEffect = ShaderEffect
    local role_lvl = uq.cache.role:level()
    local temp_xf = StaticData['mansion_map'][1]
    local showTips_xf = false
    if not temp_xf or (tonumber(temp_xf.level) > 0 and tonumber(temp_xf.level) > role_lvl) then
        ShaderEffect:setGrayAndChild(self._btnXf)
        self._txtXfName:setString(StaticData['local_text']['label.bosom.module.not.open'])
        showTips_xf = true
    end
    local showTips_zj = false
    local temp_zj = StaticData['mansion_map'][5]
    if not temp_zj or (tonumber(temp_zj.level) > 0 and tonumber(temp_zj.level) > role_lvl) then
        ShaderEffect:setGrayAndChild(self._btnZj)
        self._txtZjName:setString(StaticData['local_text']['label.bosom.module.not.open'])
        showTips_zj = true
    end
    self._btnXf:addClickEventListenerWithSound(function()
        if showTips_xf and temp_xf and temp_xf.level then
            uq.fadeInfo(string.format(StaticData["local_text"]["label.open.lv"],temp_xf.level) )
        else
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
        end
    end)
    self._btnZj:addClickEventListenerWithSound(function()
        if showTips_zj and temp_zj and temp_zj.level then
            uq.fadeInfo(string.format(StaticData["local_text"]["label.open.lv"],temp_zj.level) )
        else
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_LIST_MODULE)
        end
    end)
    self._btnNt:addClickEventListenerWithSound(function()
        if uq.cache.role.bosom.wife_id <= 0 then
            uq.fadeInfo(StaticData["local_text"]["bosom.notice.no.wife"])
        else
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_INFO_MODULE, {id = uq.cache.role.bosom.wife_id})
        end
    end)

    self._btnAddUp:addClickEventListenerWithSound(function()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_ALL_ATTR_MODULE)
        end)
    self._btnHelp:addClickEventListenerWithSound(function()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_RULE)
        end)
    self._btnReturn:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
    self:_onResChange()
    self._eventNtTag = services.EVENT_NAMES.ON_CRROP_REFRESH_MAIN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BOSOM_WIFE_CHANGE, handler(self, self._onResChange), self._eventNtTag)
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_SYS_INFO, handler(self, self._onSysInfo), '_onBosomSysInfo')
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_SYS_INFO, {})
end

function BosomModule:_onSysInfo(evt)
    local data = evt.data
    uq.cache.role.bosom.wife_id = data.wife_id
    self:_onResChange()
end

function BosomModule:_onResChange()
    if uq.cache.role.bosom.wife_id <= 0 then
        self._shaderEffect:setGrayAndChild(self._btnNt)
        self._txtNtName:setString(StaticData['local_text']['label.bosom.module.not.open'])
    else
        self._shaderEffect:setRemoveGrayAndChild(self._btnNt)
        self._txtNtName:setString(StaticData['local_text']['label.bosom.nt.value'])
    end
end

function BosomModule:dispose()
    services:removeEventListenersByTag(self._eventNtTag)
    network:removeEventListenerByTag('_onBosomSysInfo')
    BosomModule.super.dispose(self)
end

return BosomModule
local VipModule = class("VipModule", require("app.base.PopupTabView"))

VipModule.RESOURCE_FILENAME = "Vip/VipMain.csb"

VipModule.RESOURCE_BINDING  = {
    ["Panel_1/Panel_tap/img_vip1"]                          ={["varname"] = "_imgVip1"},
    ["Panel_1/Panel_tap/img_vip2"]                          ={["varname"] = "_imgVip2"},
    ["Panel_1/Panel_tap/bmp_vip1"]                          ={["varname"] = "_bmpVip1"},
    ["Panel_1/Panel_tap/bmp_vip2"]                          ={["varname"] = "_bmpVip2"},
    ["Panel_1/Panel_tap/img_vip_percent"]                   ={["varname"] = "_imgVipPercent"},
    ["Panel_1/Panel_tap/Panel_cost"]                        ={["varname"] = "_panelCost"},
    ["Panel_1/Panel_tap/Panel_cost/label_des"]              ={["varname"] = "_desLabel"},
    ["Panel_1/Panel_tap/label_percent"]                     ={["varname"] = "_percentLabel"},
    ["Panel_1/Panel_tap/btn_charge"]                        ={["varname"] = "_btnCharge",["events"] = {{["event"] = "touch",["method"] = "_onBtnCharge"}}},
    ["Panel_1/Panel_tap/btn_charge/label_name_0"]           ={["varname"] = "_btnNameLabel"},
}

function VipModule:ctor(name, args)
    VipModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    VipModule._tabTxt = {
        StaticData['local_text']["label.common.recharge2"],
        StaticData['local_text']["label.common.vip.privilege"],
    }
    VipModule._titleTxt = {
        StaticData['local_text']["vip.title"],
        StaticData['local_text']["label.common.recharge"],
    }
    VipModule._subModules = {
        {path = "app.modules.vip.VipRecharge"}, --特权
        {path = "app.modules.vip.VipPrivilege"}, --充值
    }
end

function VipModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN,  true))
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self._contentSize = self._imgVipPercent:getContentSize()
    self:parseView()
    self:centerView()
    self:updateDialog()
    self:initProtocolData()
    self._btnCharge:setPressedActionEnabled(true)
    self:adaptBgSize()
end

function VipModule:_onBtnCharge(event)
    if event.name ~= "ended" then
        return
    end
    self._tabIndex = self._tabIndex % 2 + 1
    self:updateDialog()
end

function VipModule:updateDialog()
    self._btnNameLabel:setString(self._tabTxt[self._tabIndex])
    local vip_cfg = StaticData['vip'][uq.cache.role.vip_level]
    local next_vip_cfg = StaticData['vip'][uq.cache.role.vip_level + 1]
    self._bmpVip1:setString(uq.cache.role.vip_level)
    if not next_vip_cfg then
        self._panelCost:setVisible(false)
        self._imgVipPercent:setContentSize(self._contentSize.width, self._contentSize.height)
        self._imgVipPercent:setVisible(true)
        self._bmpVip2:setString(uq.cache.role.vip_level)
        self._percentLabel:setString(vip_cfg.vipExp.. "/" ..vip_cfg.vipExp)
    else
        self._panelCost:setVisible(true)
        local left_exp = math.floor(next_vip_cfg.vipExp - uq.cache.role.vip_exp)
        self._desLabel:setString(string.format(StaticData['local_text']['vip.des1'], left_exp))
        self._percentLabel:setString((uq.cache.role.vip_exp).. "/" ..next_vip_cfg.vipExp)
        if uq.cache.role.vip_exp == 0 then
            self._imgVipPercent:setVisible(false)
        else
            self._imgVipPercent:setVisible(true)
            self._imgVipPercent:setContentSize(math.floor(uq.cache.role.vip_exp / next_vip_cfg.vipExp * self._contentSize.width),self._contentSize.height)
        end
        self._bmpVip2:setString(uq.cache.role.vip_level + 1)
    end
    local path = self._subModules[self._tabIndex].path
    self:addSub(path, nil, nil, self._tabIndex, nil)
end

function VipModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_VIP_EXP_CHANGES, handler(self, self.updateDialog), '_onVipExpByStrategy')
end

function VipModule:removeProtocolData()
    services:removeEventListenersByTag("_onVipExpByStrategy")
end

function VipModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self:removeProtocolData()
    VipModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return VipModule

local RecruitGift = class("RecruitGift", require('app.base.PopupBase'))

RecruitGift.RESOURCE_FILENAME = "recruit/RecruitGift.csb"
RecruitGift.RESOURCE_BINDING = {
    ["Node_1"]                           = {["varname"] = "_nodeBase"},
    ["title_txt"]                        = {["varname"] = "_txtTitle"},
    ["close_btn"]                        = {["varname"] = "_btnClose"},
    ["ok_btn"]                           = {["varname"] = "_btnOk"},
}

function RecruitGift:ctor(name, params)
    RecruitGift.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)
    self._selectId = 1
    self._xmlCost = StaticData['jiu_guan'].Cost or {}
    self._cost = 0
    self._data = params.data or {}
    self:initLayer()
    for i = 1, 3 do
        self:setNodeData(self._nodeBase:getChildByName("gift_" .. i .. "_node"), i)
    end
end

function RecruitGift:initLayer()
    self._btnOk:addClickEventListenerWithSound(function()
        if uq.cache.recruit:isRecruitGenerals() then
             uq.fadeInfo(StaticData["local_text"]["recruit.ogoing.recruit"])
            return
        end
        if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._cost) then
            uq.fadeInfo(StaticData["local_text"]["label.no.enough.res"])
            return
        end
        network:sendPacket(Protocol.C_2_S_JIUGUAN_RECRUIT, {general_index = self._data.index, rate_index = self._selectId})
        self:disposeSelf()
    end)
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
    end)
end

function RecruitGift:setNodeData(node, idx)
    local data = self._xmlCost[idx] or {}
    if not data or next(data) == nil then
        return
    end
    local cost = data.cost or 0
    node:getChildByName("sel_img"):setVisible(self._selectId == idx)
    node:getChildByName("cion_txt"):setString(tostring(data.cost))
    node:getChildByName("chance_txt"):setString("+" .. data.getProbUp * 100 .. "%")
    if self._selectId == idx then
        self._cost = cost
    end
    node:getChildByName("click_img"):addClickEventListenerWithSound(function()
        self._selectId = idx
        self._cost = cost
        self:refreshSelect()
    end)
end

function RecruitGift:refreshSelect()
    for i = 1, 3 do
        local node = self._nodeBase:getChildByName("gift_" .. i .. "_node")
        node:getChildByName("sel_img"):setVisible(self._selectId == i)
    end
end

return RecruitGift
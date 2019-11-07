local PassCheckLimitStoreCell = class("PassCheckLimitStoreCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckLimitStoreCell.RESOURCE_FILENAME = "pass_check/PassCheckLimitStoreCell.csb"
PassCheckLimitStoreCell.RESOURCE_BINDING = {
    ["Node_3"]              = {["varname"] = "_nodeBase"},
    ["discount_txt"]        = {["varname"] = "_txtDiscount"},
    ["name_txt"]            = {["varname"] = "_txtName"},
    ["num_txt"]             = {["varname"] = "_txtNum"},
    ["Node_1"]              = {["varname"] = "_nodeItems"},
    ["cost_txt"]            = {["varname"] = "_txtCost"},
    ["cost_img"]            = {["varname"] = "_imgCost"},
    ["buy_btn"]             = {["varname"] = "_btnBuy"},
    ["finish_img"]          = {["varname"] = "_imgFinish"},
    ["lock_txt"]            = {["varname"] = "_txtLock"},
    ["times_node"]          = {["varname"] = "_nodeTimes"},
    ["no_time_node"]        = {["varname"] = "_nodeNotLimit"},
    ["Image_10"]            = {["varname"] = "_imgDiscount"},
}

function PassCheckLimitStoreCell:ctor(name, params)
    PassCheckLimitStoreCell.super.ctor(self, name, params)
    self:parseView()
    self._data = {}
end

function PassCheckLimitStoreCell:onCreate()
    PassCheckLimitStoreCell.super.onCreate(self)
end

function PassCheckLimitStoreCell:setData(data)
    local data = data or {}
    self._data = data
    if not data or next(data) == nil then
        return
    end
    self._btnBuy:setVisible(false)
    self._imgFinish:setVisible(false)
    self._txtLock:setVisible(false)
    local item = uq.RewardType:create(data.buy)
    local equip_item = EquipItem:create({info = item:toEquipWidget()})
    equip_item:setTouchEnabled(true)
    equip_item:setScale(0.8)
    equip_item:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    self._nodeItems:removeAllChildren()
    self._nodeItems:addChild(equip_item)
    local xml = StaticData['items'][item:id()]
    if xml and next(xml) ~= nil then
        self._txtName:setString(xml.name)
        local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(xml.qualityType)]
        if quality_info and quality_info.color then
            self._txtName:setTextColor(uq.parseColor("#" .. quality_info.color))
        end
    end
    local buy = uq.RewardType:create(data.cost)
    local price = math.ceil(data.discount * buy:num())
    self._txtCost:setString(tostring(price))
    self._imgCost:loadTexture("img/common/ui/" .. buy:miniIcon())
    local is_limit_num = data.times ~= 0
    local buy_num = self:getNumBuy(data.ident)
    local surplus_num = data.times - buy_num
    self._nodeNotLimit:setVisible(not is_limit_num)
    self._nodeTimes:setVisible(is_limit_num)
    if is_limit_num then
        self._txtNum:setString(surplus_num .. "/" .. data.times)
    end
    if uq.cache.pass_check._passCardInfo.level < data.condition then
        self._txtLock:setVisible(true)
        self._txtLock:setString(string.format(StaticData["local_text"]["pass.need.lv.buy"], data.condition))
    elseif is_limit_num and surplus_num <= 0 then
        self._imgFinish:setVisible(true)
    else
        self._btnBuy:setVisible(true)
    end
    self._txtDiscount:setString(tostring(data.discount * 10))
    self._imgDiscount:setVisible(data.discount ~= 1)
    self._btnBuy:addClickEventListenerWithSound(function()
        self:openBuyLayer()
    end)
end

function PassCheckLimitStoreCell:refreshData()
    self:setData(self._data)
end

function PassCheckLimitStoreCell:getNumBuy(id)
    for i, v in ipairs(uq.cache.pass_check._passShop) do
        if v.id == id then
            return v.num
        end
    end
    return 0
end

function PassCheckLimitStoreCell:openBuyLayer()
    if not self._data and next(self._data) == nil then
        return
    end
    local num = self._data.times == 0 and 99 or self._data.times - self:getNumBuy()
    if num <= 0 then
        uq.fadeInfo(StaticData['local_text']['pass.store.item.sold'])
    elseif num == 1 then
        local cost = uq.RewardType:create(self._data.cost)
        if not uq.cache.role:checkRes(cost:type() , cost:num(), cost:id()) then
            uq.fadeInfo(StaticData['local_text']['label.no.enough.res'])
            return
        end
        network:sendPacket(Protocol.C_2_S_PASSCARD_STONE_BUY, {["id"] = self._data.ident, ["num"] = num})
    else
        local info = {["xml"] = self._data, ["num"] = num, ["discount"] = self._data.discount, ["type"] = 8, ["id"] = self._data.ident}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_NUM_BUY_ITEM, {info = info})
    end
end

function PassCheckLimitStoreCell:showAction()
    uq.intoAction(self._nodeBase)
end

function PassCheckLimitStoreCell:onExit()
    PassCheckLimitStoreCell.super.onExit(self)
end

return PassCheckLimitStoreCell
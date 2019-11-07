local VipRechargeItem = class("VipRechargeItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

VipRechargeItem.RESOURCE_FILENAME = "Vip/VipRechargeItem.csb"
VipRechargeItem.RESOURCE_BINDING = {
    ["label_title1"]                ={["varname"] = "_titleLabel1"},
    ["label_title2"]                ={["varname"] = "_titleLabel2"},
    ["ScrollView_1"]                ={["varname"] = "_scrollView"},
    ["ScrollView_2"]                ={["varname"] = "_scrollView2"},
    ["label_cost1"]                 ={["varname"] = "_costLabel1"},
    ["label_cost2"]                 ={["varname"] = "_costLabel2"},
    ["Panel_segment"]               ={["varname"] = "_panelLine"},
    ["img_buy"]                     ={["varname"] = "_imgBuy"},
    ["btn_daily"]                   ={["varname"] = "_btnLiBao",["events"] = {{["event"] = "touch",["method"] = "_onBtnLiBao"}}},
    ["btn_buy"]                     ={["varname"] = "_btnBuy",["events"] = {{["event"] = "touch",["method"] = "_onBtnBuy"}}},
}

function VipRechargeItem:onCreate()
    self:parseView()
    self._vipLevel = 0
    self._btnLiBao:setPressedActionEnabled(true)
    self._btnBuy:setPressedActionEnabled(true)
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView2:setScrollBarEnabled(false)
    self._imgBuy:setVisible(false)
    self._panelLine:removeAllChildren()
    local from = cc.p(0, self._panelLine:getContentSize().height * 0.5)
    local to = cc.p(self._panelLine:getContentSize().width, self._panelLine:getContentSize().height * 0.5)
    local draw_node = cc.DrawNode:create()
    draw_node:drawSegment(from,to,1,cc.c4b(1,0,0,1))
    self._panelLine:addChild(draw_node)
end

function VipRechargeItem:updateData(vip_level)
    self._vipLevel = vip_level
    self:updateDialog()
end

function VipRechargeItem:updateDialog()
    local vip_cfg = StaticData['vip'][self._vipLevel]
    self._titleLabel1:setString(string.format(StaticData['local_text']['vip.des2'],self._vipLevel))
    local cur_level = self._vipLevel
    if cur_level == 0 then
        cur_level = 1
    end
    self._titleLabel2:setString(string.format(StaticData['local_text']['vip.des3'],cur_level))
    local num = 2^(cur_level)
    if bit.band(uq.cache.role.vip_reward_info, num) > 0 then
        self._btnBuy:setVisible(false)
        self._imgBuy:setVisible(true)
    else
        self._btnBuy:setVisible(true)
        self._imgBuy:setVisible(false)
    end
    if uq.cache.role.vip_reward_lvl <= 0 then
        self._btnLiBao:setVisible(true)
    else
        self._btnLiBao:setVisible(false)
    end
    self:updateDesScroll()
    self:updateRewardScroll()
end

function VipRechargeItem:getLabel()
    local lbl_desc = ccui.Text:create()
    lbl_desc:setFontSize(24)
    lbl_desc:setFontName("font/fzlthjt.ttf")
    lbl_desc:setAnchorPoint(cc.p(0, 0.5))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    return lbl_desc
end

function VipRechargeItem:updateDesScroll()
    local vip_cfg = StaticData['vip'][self._vipLevel]
    self._scrollView:removeAllChildren()
    local scroll_size = self._scrollView:getContentSize()
    local pos_x = 0
    local height = #vip_cfg.Item * 45
    height = height + 30
    if height > scroll_size.height then
        self._scrollView:setScrollBarEnabled(false)
        self._scrollView:setTouchEnabled(true)
    else
        self._scrollView:setTouchEnabled(false)
        self._scrollView:setScrollBarEnabled(false)
        height = scroll_size.height
    end
    self._scrollView:setInnerContainerSize(cc.size(scroll_size.width,height))
    height = height - 30
    for k,v in ipairs(vip_cfg.Item) do
        local img = ccui.ImageView:create()
        img:loadTexture("img/vip/g03_0194.png")
        img:setAnchorPoint(cc.p(0,0.5))
        img:setPosition(cc.p(pos_x,height))
        self._scrollView:addChild(img)
        local lbl_desc = self:getLabel()
        lbl_desc:setPosition(cc.p(pos_x + 40, height))
        lbl_desc:setString(v.Item)
        self._scrollView:addChild(lbl_desc)
        height = height - 45
    end
end

function VipRechargeItem:updateRewardScroll()
    local cur_level = self._vipLevel
    if cur_level == 0 then
        cur_level = 1
    end
    local vip_shop_info = StaticData['vip_shop_gift'][cur_level]
    self._costLabel1:setString(vip_shop_info.originalCost)
    self._costLabel2:setString(vip_shop_info.nowCost)
    self._scrollView2:removeAllChildren()
    local reward_info = uq.RewardType.parseRewards(vip_shop_info.Reward)
    local scroll_size = self._scrollView2:getContentSize()
    local height = math.floor(#reward_info / 4) * 135
    if height > scroll_size.height then
        self._scrollView2:setScrollBarEnabled(false)
        self._scrollView2:setTouchEnabled(true)
    else
        self._scrollView2:setTouchEnabled(false)
        self._scrollView2:setScrollBarEnabled(false)
        height = scroll_size.height
    end
    self._scrollView2:setInnerContainerSize(cc.size(scroll_size.width,height))
    local index = 1
    local line = 1
    height = height - 67.5
    for k,v in ipairs(reward_info) do
        local euqip_item = EquipItem:create({info = v:toEquipWidget()})
        local width = euqip_item:getContentSize().width
        euqip_item:setPosition(cc.p((width * 0.5) + (width + 10) * (index - 1),height - 135 * (line - 1)))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView2:addChild(euqip_item)
        index = index + 1
        if index % 4 == 1 then
            line = line + 1
            index = 1
        end
    end
end

function VipRechargeItem:_onBtnBuy(event)
    if event.name ~= "ended" then
        return
    end
    if self._vipLevel > uq.cache.role.vip_level or uq.cache.role.vip_level == 0 then
        uq.fadeInfo(StaticData["local_text"]["vip.libao.des1"])
        return
    end
    local vip_shop_info = StaticData['vip_shop_gift'][self._vipLevel]
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN,vip_shop_info.nowCost) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"],StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    local function confirm()
        network:sendPacket(Protocol.C_2_S_BUY_VIP_REWARD, {vipLevel = self._vipLevel})
    end
    local des = string.format(StaticData['local_text']['vip.libao.buy.des3'],vip_shop_info.nowCost)
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function VipRechargeItem:_onBtnLiBao(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_DRAW_VIP_REWARD)
end

function VipRechargeItem:dispose()
    VipRechargeItem.super.dispose(self)
end

return VipRechargeItem
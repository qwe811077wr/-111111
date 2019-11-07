local VipRecharge = class("VipRecharge", require("app.base.TableViewBase"))
local VipRechargeItem = require("app.modules.vip.VipRechargeItem")

VipRecharge.RESOURCE_FILENAME = "Vip/VipRecharge.csb"

VipRecharge.RESOURCE_BINDING  = {
    ["PageView_2"]                  ={["varname"] = "_pageView"},
    ["btn_left"]                    ={["varname"] = "_btnLeft",["events"] = {{["event"] = "touch",["method"] = "_onBtnLeft"}}},
    ["btn_right"]                   ={["varname"] = "_btnRgiht",["events"] = {{["event"] = "touch",["method"] = "_onBtnRight"}}},
}
function VipRecharge:ctor(name, args)
    VipRecharge.super.ctor(self)
    self._curVipLevel = uq.cache.role.vip_level
    self._curTotalPageNum = 0
    self._curPageIndex = uq.cache.role.vip_level
    self._curPagePreIndex = 0 --当前页面前一个页面的索引
    self._curPageNextIndex = 0 --当前页面后一个页面的索引
    self._curPageNum = 0
end

function VipRecharge:init()
    self:parseView()
    self:initUi()
    self:initProtocal()
end

function VipRecharge:initUi()
    self._btnLeft:setPressedActionEnabled(true)
    self._btnRgiht:setPressedActionEnabled(true)
    self._curTotalPageNum = #StaticData['vip'] + 1
    self._curPagePreIndex = self._curPageIndex - 1
    if self._curPagePreIndex < 0 then
        self._curPagePreIndex = 0
    end
    self._curPageNextIndex = self._curPageIndex + 1
    if self._curPageNextIndex >= self._curTotalPageNum then
        self._curPageNextIndex = self._curTotalPageNum - 1
    end
    self:initBagBox()
end

function VipRecharge:updatePageView(pageindex, page)
    local index_num = self._curPageNextIndex
    local width = self._pageView:getContentSize().width
    local height = self._pageView:getContentSize().height
    local bag_panel = self:getLayout(width,height)
    bag_panel.pageindex = pageindex
    self._pageView:insertPage(bag_panel,page)  --page 往前加就是0，往后加就是当前页面总数
    if page == 0 then
        self._pageView:scrollToPage(1)
    end
    self:initBagPanel(bag_panel,pageindex)
    self._curPageNum = self._curPageNum + 1
end

function VipRecharge:initBagBox()
    self._pageView:removeAllPages()
    self._pageView:setCustomScrollThreshold(20.0)
    self._pageView:setTouchEnabled(true)
    self._pageView:setClippingEnabled(true)
    self._pageView:addEventListener(handler(self, self.scrollEvent))

    local width = self._pageView:getContentSize().width
    local height = self._pageView:getContentSize().height
    for i = self._curPagePreIndex, self._curPageNextIndex do
        local bag_panel = self:getLayout(width,height)
        bag_panel.pageindex = i
        self._curPageNum = self._curPageNum + 1
        self._pageView:addPage(bag_panel)
        self:initBagPanel(bag_panel,i)
    end
    if self._curPageIndex > 0 then
        self._pageView:scrollToPage(1)
    end
end

function VipRecharge:getLayout(width, height)
    local layer = ccui.Layout:create()
    layer:setTouchEnabled(false)
    layer:setContentSize( cc.size(width, height) )
    layer:setBackGroundColorType(0)
    local bag_panel = VipRechargeItem:create()
    layer:addChild(bag_panel)
    bag_panel:setName("item")
    bag_panel:setPosition(cc.p(width * 0.5,height * 0.5))
    return layer
end

function VipRecharge:scrollEvent()
    local index = self._pageView:getCurPageIndex()
    local cell = self._pageView:getPage(index)
    if cell and cell.pageindex == self._curPageIndex then
        self:initBagPanel(cell,self._curPageIndex)
        return
    end

    self._curPageIndex = cell.pageindex
    if self._curPageIndex == self._curPageNextIndex and self._curPageNextIndex < self._curTotalPageNum - 1 then
        --加入页面
        self._curPageNextIndex = self._curPageNextIndex + 1
        self:updatePageView(self._curPageNextIndex,self._curPageNum)
    elseif self._curPageIndex == self._curPagePreIndex and self._curPagePreIndex > 0 then
        --加入页面
        scheduler.performWithDelayGlobal(function()
            self._curPagePreIndex = self._curPagePreIndex - 1
            self:updatePageView(self._curPagePreIndex,0)
        end, 0.01)
    end
end

function VipRecharge:initBagPanel(panel, curPage)
    if curPage < self._curTotalPageNum then
        local item = panel:getChildByName("item")
        item:updateData(curPage)
    end
end

function VipRecharge:_onBtnLeft(event)
    if event.name ~= "ended" then
        return
    end
    if self._curPageIndex == 0 then
        return
    end
    local index = self._pageView:getCurPageIndex()
    self._pageView:scrollToPage(index - 1)
end

function VipRecharge:_onBtnRight(event)
    if event.name ~= "ended" then
        return
    end
    if self._curPageIndex == self._curTotalPageNum then
        return
    end
    local index = self._pageView:getCurPageIndex()
    self._pageView:scrollToPage(index + 1)
end

function VipRecharge:initProtocal()
    network:addEventListener(Protocol.S_2_C_DRAW_VIP_REWARD,handler(self,self._drawVipReward),"_drawVipReward")
    network:addEventListener(Protocol.S_2_C_BUY_VIP_REWARD_INFO,handler(self,self._onBuyVipRewardInfo),"_onBuyVipRewardInfo")
end

function VipRecharge:_onBuyVipRewardInfo(evt)
    uq.cache.role.vip_reward_info = evt.data.rewardInfo
    local index = self._pageView:getCurPageIndex()
    local cell = self._pageView:getPage(index)
    if cell then
        self:initBagPanel(cell,self._curPageIndex)
        return
    end
end

function VipRecharge:_drawVipReward(evt)
    uq.cache.role.vip_reward_lvl = evt.data.vipLv
    local info = StaticData['vip_gift'][evt.data.vipLv]
    if info then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = info.Reward})
    end
    local index = self._pageView:getCurPageIndex()
    local cell = self._pageView:getPage(index)
    if cell then
        self:initBagPanel(cell,self._curPageIndex)
        return
    end
end

function VipRecharge:update(param)
    local index = self._pageView:getCurPageIndex()
    local cell = self._pageView:getPage(index)
    if cell then
        self:initBagPanel(cell,self._curPageIndex)
    end
end

function VipRecharge:dispose()
    network:removeEventListenerByTag("_drawVipReward")
    network:removeEventListenerByTag('_onBuyVipRewardInfo')
    VipRecharge.super.dispose(self)
end

return VipRecharge
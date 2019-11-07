local MailInfo = class("MailInfo", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

MailInfo.RESOURCE_FILENAME = "mail/MailInfo.csb"
MailInfo.RESOURCE_BINDING = {
    ["Text_1_0_1"]   = {["varname"] = "_txtRewardTitle"},
    ["Text_5_0_0"]   = {["varname"] = "_txtRewardContent"},
    ["Text_1_0_0_0"] = {["varname"] = "_txtRewardTime"},
    ["Image_4_0"]    = {["varname"] = "_imgContentBg"},
    ["ScrollView_1"] = {["varname"] = "_scrollViewContent"},
    ["ScrollView_2"] = {["varname"] = "_scrollViewItem"},
    ["Button_1"]     = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
    ["Button_3_0"]   = {["varname"] = "_btnGetReward",["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Node_8"]       = {["varname"] = "_nodeRewardPanel"},
    ["Text_1_0"]     = {["varname"] = "_btnText"},
    ["label__1_0"]   = {["varname"] = "_txtHead"},
}


function MailInfo:ctor(name, params)
    MailInfo.super.ctor(self, name, params)
end

function MailInfo:init()
    self:centerView()
    self:setLayerColor(0)
    self:parseView()
    self._refreshTag = '_onRefreshTag' .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_REWARD_GET_REFRESH, handler(self, self.refreshLayer), self._refreshTag)
end

function MailInfo:setData(mail_data)
    self._mailData = mail_data

    if mail_data.state == uq.config.constant.TYPE_MAIL_CELL_STATE.NEW then
        mail_data.state = uq.config.constant.TYPE_MAIL_CELL_STATE.READ
        network:sendPacket(Protocol.C_2_S_MAIL_READ, {mail_id = self._mailData.id})
    end
    self._btnGetReward:setEnabled(true)

    local bg_size = self._imgContentBg:getContentSize()
    self._txtRewardContent:setTextAreaSize(cc.size(bg_size.width - 50, 0))

    self._txtRewardTitle:setString(self._mailData.title)
    self._txtRewardContent:setString(self._mailData.content)
    local str = os.date("%Y-%m-%d", self._mailData.create_time)
    self._txtRewardTime:setString(str)

    local text_size = self._txtRewardContent:getContentSize()
    local scroll_size = self._scrollViewContent:getContentSize()

    local item_list = uq.RewardType.parseRewards(self._mailData.reward)
    if next(item_list) == nil then
        self._nodeRewardPanel:setVisible(false)
        self._btnText:setString(StaticData['local_text']['label.common.confirm'])
        return
    end

    self._scrollViewContent:setScrollBarEnabled(false)
    self._scrollViewContent:setContentSize(cc.size(scroll_size.width, scroll_size.height - 50))
    self._scrollViewContent:setInnerContainerSize(cc.size(scroll_size.width, text_size.height + 20))
    scroll_size = self._scrollViewContent:getContentSize()
    if text_size.height > scroll_size.height - 40 then
        self._txtRewardContent:setPositionY(scroll_size.height + 90)
        self._scrollViewContent:setTouchEnabled(true)
        self._imgContentBg:setContentSize(cc.size(bg_size.width, scroll_size.height))
    else
        self._txtRewardContent:setPositionY(scroll_size.height - 20)
        self._scrollViewContent:setTouchEnabled(false)
        self._imgContentBg:setContentSize(cc.size(bg_size.width, text_size.height + 40))
        bg_size = self._imgContentBg:getContentSize()
        local pos_y = self._imgContentBg:getPositionY()
        self._nodeRewardPanel:setPositionY(pos_y - bg_size.height)
    end

    self._nodeRewardPanel:setVisible(true)
    self._scrollViewItem:removeAllChildren()
    local item_size = self._scrollViewItem:getContentSize()
    local index = #item_list
    local inner_width = index * 100
    self._scrollViewItem:setInnerContainerSize(cc.size(inner_width, item_size.height))
    self._scrollViewItem:setScrollBarEnabled(false)
    self._scrollViewItem:setTouchEnabled(inner_width >= item_size.width)
    local max_num = math.ceil(item_size.width / 120)
    local item_posX = index < max_num and (max_num - index) * 60 + 55 or 55
    for _, t in ipairs(item_list) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX, item_size.height * 0.5))
        euqip_item:setScale(0.9)
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollViewItem:addChild(euqip_item)
        item_posX = item_posX + 120
    end
    self:refreshLayer()
end

function MailInfo:refreshLayer()
    if self._mailData.state == uq.config.constant.TYPE_MAIL_CELL_STATE.READ then
        self._btnText:setString(StaticData['local_text']['label.receive'])
        return
    elseif self._mailData.state == uq.config.constant.TYPE_MAIL_CELL_STATE.GOT_REWARD then
        self._btnText:setString(StaticData['local_text']['activity.finish.get'])
        self._btnGetReward:setEnabled(false)
    end
end

function MailInfo:onGetReward(event)
    if event.name ~= "ended" then
        return
    end
    if self._mailData.reward == '' then
        self:runCloseAction()
    elseif self._mailData.state == uq.config.constant.TYPE_MAIL_CELL_STATE.READ then
        network:sendPacket(Protocol.C_2_S_MAIL_REWARD, {mail_id = self._mailData.id})
    end
end

function MailInfo:dispose()
    services:removeEventListenersByTag(self._refreshTag)
    MailInfo.super.dispose(self)
end

return MailInfo
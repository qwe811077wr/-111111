local AchievementChapterCell = class("AchievementChapterCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

AchievementChapterCell.RESOURCE_FILENAME = "achievement/AchievementChapterCell.csb"
AchievementChapterCell.RESOURCE_BINDING = {
    ["Text_name"]           = {["varname"] = "_txtName"},
    ["Text_content"]        = {["varname"] = "_txtContent"},
    ["Panel_2"]             = {["varname"] = "_panelReward"},
    ["Image_4"]             = {["varname"] = "_imgCompleted"},
    ["Text_19"]             = {["varname"] = "_txtNum"},
    ["Text_5"]              = {["varname"] = "_txtBtn1"},
    ["lbl_des"]             = {["varname"] = "_txtBtn2"},
    ["Sprite_1"]            = {["varname"] = "_spriteReward"},
    ["Text_1_0"]            = {["varname"] = "_txtReward"},
    ["Button_1"]            = {["varname"] = "_btnRunCmd", ["events"] = {{["event"] = "touch",["method"] = "onRunCmd"}}},
    ["Panel_item1"]         = {["varname"] = "_pnl1"},
    ["Panel_item2"]         = {["varname"] = "_pnl2"},
    ["Panel_item3"]         = {["varname"] = "_pnl3"},
}

function AchievementChapterCell:ctor(name, params)
    AchievementChapterCell.super.ctor(self, name, params)
end

function AchievementChapterCell:onCreate()
    AchievementChapterCell.super.onCreate(self)
    self:parseView()
end

function AchievementChapterCell:initCell()
    self._imgCompleted:setVisible(false)
    self._btnRunCmd:setVisible(true)
    self._spriteReward:setVisible(false)
    if self._xmlData.module == -1 and self._cacheData.state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self._btnRunCmd:setVisible(false)
        self._txtNum:setVisible(false)
    end
end

function AchievementChapterCell:setData(xml_data, state_data)
    self._xmlData = xml_data
    self._cacheData = state_data

    self:initCell()
    self._txtName:setString(xml_data.des1)
    self._txtContent:setHTMLText(xml_data.des)
    self._txtNum:setString(state_data.value .. '/' .. xml_data.num)

    self._rewards = xml_data.reward
    self:refreshReward(xml_data.reward)

    self._state = state_data.state
    if xml_data.module ~= -1 or state_data.state ~= uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self:refreshBtnState(state_data.state)
    end
end

function AchievementChapterCell:refreshReward(reward)
    self._panelReward:removeAllChildren()
    local item_list = uq.RewardType.parseRewards(reward)
    for i, v in ipairs(item_list) do
        if i > 3 then
            break
        end
        local equip_item = EquipItem:create({info = v:toEquipWidget()})
        self["_pnl" .. i]:addChild(equip_item)
        equip_item:setScale(0.85)
        equip_item:setPosition(cc.p(self["_pnl" .. i]:getContentSize().width * 0.5 - 5, self["_pnl" .. i]:getContentSize().height * 0.5 - 5))
        equip_item:setTouchEnabled(true)
        equip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        equip_item:setSwallowTouches(false)
    end
end

function AchievementChapterCell:refreshBtnState(state)
    self._btnRunCmd:setVisible(true)
    self._txtBtn1:setVisible(false)
    self._txtBtn2:setVisible(false)
    self._imgCompleted:setVisible(false)
    self._txtNum:setTextColor(uq.parseColor("#FFFFFF"))

    if state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self._btnRunCmd:loadTextures("img/common/ui/j02_0000048.png", "img/common/ui/j02_0000048.png")
        self._txtBtn2:setVisible(true)
    elseif state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        self._btnRunCmd:loadTextures("img/common/ui/j02_0000047.png", "img/common/ui/j02_0000047.png")
        self._txtBtn1:setVisible(true)
        self._txtNum:setTextColor(uq.parseColor("#00FC05"))
    elseif state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
        self._btnRunCmd:setVisible(false)
        self._imgCompleted:setVisible(true)
        self._txtNum:setVisible(false)
    end

    if state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        return
    end

    if self._xmlData.module == -1 or StaticData['module'][self._xmlData.module]['jumpType'] == 2 then
        self._btnRunCmd:setVisible(false)
    end
end

function AchievementChapterCell:onRunCmd(event)
    if event.name ~= "ended" then
        return
    end

    if self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        --前往
        local data = StaticData['module'][self._xmlData.module]
        if data['jumpObject'] ~= "" then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, build_id = tonumber(data.jumpObject)})
            uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ACHIEVEMENT_MAIN)
            return
        end

        if data['jumpType'] == 1 then
            uq.jumpToModule(self._xmlData.module)
            return
        end

        uq.jumpToInstanceChapter(self._xmlData.param)
    elseif self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        --领取奖励
        local data = {
            id = self._xmlData.ident,
            chapter_id = self._cacheData.chapter_id,
            rwd_type = uq.config.constant.TYPE_ACHIEVEMENT_REWARD.TASK
        }
        network:sendPacket(Protocol.C_2_S_ACHIEVEMENT_DRAW, data)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._rewards})

        self._cacheData.state = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
    end
end

return AchievementChapterCell
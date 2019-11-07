local TaskItem = class("TaskItem", function()
    return ccui.Layout:create()
end)

local EquipItem = require("app.modules.common.EquipItem")

function TaskItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self._itemArray = {}
    self._starArray = {}
    self:init()
end

function TaskItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("task/TaskItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(20 ,0))
    self._imgIsOver = self._view:getChildByName("img_isover")
    self._actveLabel = self._view:getChildByName("lbl_huoyuedu")
    self._nameLabel = self._view:getChildByName("lbl_name")
    self._desLabel = self._view:getChildByName("lbl_des")
    self._numLabel = self._view:getChildByName("lbl_num")
    self._loadingBar = self._view:getChildByName("LoadingBar_1")
    self._imgLocked = self._view:getChildByName("img_locked")
    self._panelBtn = self._view:getChildByName("Panel_btn");
    self._txtTip = self._imgLocked:getChildByName("Text_14")
    self._isOver = self._view:getChildByName("img_isover")
    self._nanduDesLabel = self._panelBtn:getChildByName("lbl_nandu")
    self._nanduDesLabel:setString(StaticData['local_text']['task.item.des1'])
    self._imgLocked:setVisible(false)
    for i = 1, 2 do
        local item = self._view:getChildByName("Panel_item" .. i)
        table.insert(self._itemArray, item)
        local star = self._panelBtn:getChildByName("img_star" .. i)
        star:setVisible(false)
        table.insert(self._starArray, star)
    end
    self._btnGetReward = self._panelBtn:getChildByName("btn_getreward");
    self._isOver:setString(StaticData['local_text']['activity.finish.get'])
    self._btnGetReward:getChildByName("lbl_des"):setString(StaticData['local_text']['label.receive.reward'])
    self._btnGetReward:setPressedActionEnabled(true)
    self._btnGetReward:addClickEventListenerWithSound(function()
        network:sendPacket(Protocol.C_2_S_LIVENESS_DRAW_REWARD, {ident = self._info.ident})
    end)
    self._btnGoTo = self._panelBtn:getChildByName("btn_goto")
    self._btnGoTo:setPressedActionEnabled(true)
    self._btnGoTo:getChildByName("lbl_des"):setString(StaticData['local_text']['achieve.label.goto'])
    self._btnGoTo:addClickEventListenerWithSound(function()
        uq.jumpToModule(self._info.forward)
    end)
    self:initInfo()
end

function TaskItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function TaskItem:initInfo()
    if not self._info then
        return
    end
    self._imgIsOver:setVisible(false)
    self._nanduDesLabel:setVisible(false)
    self._nameLabel:setString(self._info.name)
    self._actveLabel:setVisible(true)
    self._actveLabel:setString(string.format(StaticData['local_text']['task.item.des2'], self._info.credit))
    self._loadingBar:setPercent(self._info.curIndex / self._info.value * 100)
    self._desLabel:setString(self._info.detail)
    self._numLabel:setString(self._info.curIndex .. "/" .. self._info.value)

    if self._info.state == 1 then
        self._btnGoTo:setVisible(false)
        self._btnGetReward:setVisible(true)
    elseif self._info.state == 2 then
        self._btnGoTo:setVisible(false)
        self._btnGetReward:setVisible(false)
        self._imgIsOver:setVisible(true)
        self._desLabel:setString(self._info.detail)
        self._numLabel:setString("")
    else
        self._btnGoTo:setVisible(true)
        self._btnGetReward:setVisible(false)
    end
    local rewards = string.split(self._info.rewards, "|")
    if rewards[#rewards] == "" then
        table.remove(rewards, #rewards)
    end

    local index = 1
    for _,t in ipairs(rewards) do
        local str = string.split(t, ";")
        local info = {}
        info.type = tonumber(str[1])
        info.id = tonumber(str[3])
        info.num = tonumber(str[2])
        local panel = self._itemArray[index]
        if not panel then
            return
        end
        local euqip_item = EquipItem:create({info = info})
        euqip_item:setScale(0.7)
        euqip_item:setPosition(cc.p(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:setSwallowTouches(false)
        euqip_item:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setNameFontSize(20 / 0.7)
        panel:addChild(euqip_item)
        index = index + 1
    end
    local btn_show_state = true
    if self._info.needlevel and self._info.needlevel ~= '' then
        if uq.cache.role:level() < self._info.needlevel then
            btn_show_state = false
            self._txtTip:setString(string.format(StaticData['local_text']['fly.nail.module.des4'], self._info.needlevel))
        end
    elseif self._info.needMission and self._info.needMission ~= '' then
        if not uq.cache.instance:isNpcPassed(tonumber(self._info.needMission)) then
            local instance_id = math.floor(tonumber(self._info.needMission) / 100)
            local chapter_id = instance_id - 100
            local npc_id = self._info.needMission % 100
            btn_show_state = false
            self._txtTip:setString(string.format(StaticData['local_text']['label.instance.unlock'], chapter_id, npc_id))
        end
    end

    self._imgLocked:setVisible(not btn_show_state)
    if not btn_show_state then
        self._btnGoTo:setVisible(false)
        self._btnGetReward:setVisible(false)
        return
    end
end

function TaskItem:showAction()
    uq.intoAction(self._view)
end

function TaskItem:getInfo()
    return self._info
end

function TaskItem:onExit()

end

return TaskItem
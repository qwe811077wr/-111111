local PassCheckTaskExam = class("PassCheckTaskExam", require('app.base.ChildViewBase'))

PassCheckTaskExam.RESOURCE_FILENAME = "pass_check/PassCheckTaskExam.csb"
PassCheckTaskExam.RESOURCE_BINDING = {
    ["Panel_1"]          = {["varname"] = "_panel"},
    ["num_today_txt"]    = {["varname"] = "_txtActive"},
    ["Panel_box"]        = {["varname"] = "_panelBox"},
    ["Image_pre_bg"]     = {["varname"] = "_imgProBg"},
    ["Img_percent"]      = {["varname"] = "_imgPro"},
    ["Node_1"]           = {["varname"] = "_nodeReward"},
    ["Node_3"]           = {["varname"] = "_nodeTaskDesc"},
    ["Node_3_0"]         = {["varname"] = "_nodeTaskAccept"},
    ["Text_1"]           = {["varname"] = "_txtTaskDesc"},
    ["name_txt"]         = {["varname"] = "_txtTaskName"},
    ["dec_txt"]          = {["varname"] = "_txtDesc"},
    ["num_task_txt"]     = {["varname"] = "_txtProgress"},
    ["branch_txt"]       = {["varname"] = "_txtScore"},
    ["right_items_node"] = {["varname"] = "_nodeRightItem"},
    ["pick_btn"]         = {["varname"] = "_btnPick", ["events"] = {{["event"] = "touch",["method"] = "onAccept"}}},
    ["Text_13"]          = {["varname"] = "_txtPick"},
    ["Button_3"]         = {["varname"] = "_btnRefresh", ["events"] = {{["event"] = "touch",["method"] = "onRefresh",["sound_id"] = 0}}},
    ["num_finish_txt"]   = {["varname"] = "_txtTaskNum"},
    ["Text_1_0"]         = {["varname"] = "_txtTaskTip"},
    ["Text_2"]           = {["varname"] = "_txtRefreshGold"},
    ["Node_4"]           = {["varname"] = "_nodeBase"},
    ["dec_node"]         = {["varname"] = "_nodeDec"},
    ["Button_2"]         = {["varname"] = "_btnRule", ["events"] = {{["event"] = "touch",["method"] = "onRule",["sound_id"] = 0}}},
}

function PassCheckTaskExam:ctor(name, params)
    PassCheckTaskExam.super.ctor(self, name, params)
end

function PassCheckTaskExam:onCreate()
    PassCheckTaskExam.super.onCreate(self)
    self:parseView()

    self._totalTaskNum = 10
    local data = StaticData['pass']['Info'][uq.cache.pass_check._passCardInfo.season_id]
    self._xmlData = data['Task']
    self._totalReward = data['Total']
    self._boxPos = self:initUIBox()
    self._allUi = {}
    self._taskIdMapIndex = {}

    self:initTaskList()
    self:refreshUIBox()
    self._nodeDec:setVisible(false)
    self._eventTag = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE, handler(self, self.onTaskUpdate), self._eventTag)

    self._eventInitTag = services.EVENT_NAMES.ON_INIT_PASS_CARD_TASK .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INIT_PASS_CARD_TASK, handler(self, self.onTaskInit), self._eventInitTag)
end

function PassCheckTaskExam:getTaskActive()
    return uq.cache.pass_check._passCardInfo.liveness
end

function PassCheckTaskExam:onTaskUpdate()
    self:refreshUIBox()

    self:refreshTaskState()
end

function PassCheckTaskExam:refreshTaskState()
    for i = 1, 8 do
        local panel = self._panel:getChildByName('item' .. i)
        panel:refreshState()
    end
end

function PassCheckTaskExam:onTaskInit()
    self:initTaskList()
    self:onTaskUpdate()
end

function PassCheckTaskExam:initTaskList()
    self._allUi = {}
    self._taskIdMapIndex = {}
    local index = 1
    for k, item in pairs(uq.cache.pass_check._passTask) do
        local panel = self._panel:getChildByName('item' .. index)
        if panel then
            panel:removeSelf()
        end
        panel = uq.createPanelOnly("pass_check.PassCheckTaskExamCell")
        panel:setPosition(cc.p(((index - 1) % 4 + 1) * 170 - 75, 528 - math.ceil(index / 4) * 205))
        panel:setName('item' .. index)
        self._panel:addChild(panel)
        table.insert(self._allUi, panel)
        panel:setData(self._xmlData[item.id], index, handler(self, self.selectTaskByIdx))
        self._taskIdMapIndex[item.id] = index
        index = index + 1
    end
end

function PassCheckTaskExam:selectTaskByIdx(idx)
    local info = self._xmlData[idx] or {}
    if not info or next(info) == nil then
        return
    end

    for i = 1, 8 do
        local item = self._panel:getChildByName('item' .. i)
        item:setSelectVis(false)
    end

    local cur_item = self._panel:getChildByName('item' .. idx)
    cur_item:setSelectVis(true)

    self._curSelectIndex = idx
    self._curSelectTaskID = self:getCurTaskId()
    self:refreshCurSelect()
end

function PassCheckTaskExam:getCurTaskId()
    return self._panel:getChildByName('item' .. self._curSelectIndex):getTaskID()
end

function PassCheckTaskExam:refreshCurSelect()
    local task_data = uq.cache.pass_check._passTask[self:getCurTaskId()]
    self._txtTaskTip:setString(StaticData['local_text']['label.passcard.get.other.task'])
    if task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_DRAWD then
        self._nodeTaskDesc:setVisible(true)
        self._nodeTaskAccept:setVisible(false)
        self._txtTaskDesc:setString(StaticData['local_text']['pass.task.is.finish'])
        return
    elseif task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ABANDON then
        self._nodeTaskDesc:setVisible(true)
        self._nodeTaskAccept:setVisible(false)
        self._txtTaskDesc:setString(StaticData['local_text']['label.passcard.task.giveup'])
        return
    elseif task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_INIT then
        if uq.cache.pass_check:isTaskExist() then
            self._nodeTaskDesc:setVisible(true)
            self._nodeTaskAccept:setVisible(false)
            self._txtTaskDesc:setString(StaticData['local_text']['label.passcard.task.exist'])
            self._txtTaskTip:setString(StaticData['local_text']['label.passcard.task.finish.other'])
        else
            --可接取
            self._nodeTaskDesc:setVisible(false)
            self._nodeTaskAccept:setVisible(true)
            self:refreshAccept()
        end
    else
        self._nodeTaskDesc:setVisible(false)
        self._nodeTaskAccept:setVisible(true)
        self:refreshAccept()
    end
end

function PassCheckTaskExam:refreshAccept()
    local task_data = uq.cache.pass_check._passTask[self:getCurTaskId()]
    local xml_data = self._xmlData[self:getCurTaskId()]

    self._nodeRightItem:removeChildByName('reward')
    local item_data = uq.RewardType.new(xml_data.reward)
    self._equiItem = require("app.modules.common.EquipItem"):create({info = item_data:toEquipWidget()})
    self._equiItem:setScale(0.8)
    self._nodeRightItem:addChild(self._equiItem)
    self._equiItem:enableEvent()
    self._equiItem:setSwallow(false)
    self._equiItem:setName('reward')
    self._txtTaskName:setString(xml_data.title)

    self._txtDesc:setHTMLText(xml_data.desc)
    self._txtProgress:setHTMLText(string.format("<font color='#29e51f'>%d</font>/%d", task_data.num, xml_data.nums))
    self._txtScore:setString(xml_data.progress)

    self._btnPick:loadTextureNormal('img/common/ui/s02_00008.png')
    self._btnPick:loadTextureDisabled('img/common/ui/s02_00008.png')
    if task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_INIT then
        self._txtPick:setString(StaticData['local_text']['label.passcard.task.accept'])
    elseif task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ACCEPT then
        self._txtPick:setString(StaticData['local_text']['label.passcard.task.giveup1'])
        self._btnPick:loadTextureNormal('img/common/ui/s02_00069.png')
        self._btnPick:loadTextureDisabled('img/common/ui/s02_00069.png')
    elseif task_data.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_FINISHED then
        self._txtPick:setString(StaticData['local_text']['label.passcard.task.get'])
    end
    --已满
    if uq.cache.pass_check._passCardInfo.task_num == self._totalTaskNum then
        self._btnPick:setEnabled(false)
        uq.ShaderEffect:addGrayButton(self._btnPick)
    else
        self._btnPick:setEnabled(true)
    end
end

function PassCheckTaskExam:onAccept(event)
    if event.name ~= 'ended' then
        return
    end

    if uq.cache.pass_check._passCardInfo.task_num == self._totalTaskNum then
        uq.fadeInfo(StaticData['local_text']['label.passcard.task.limit'])
    end

    if self._txtPick:getString() == StaticData['local_text']['label.passcard.task.accept'] then
        network:sendPacket(Protocol.C_2_S_PASSCARD_ACCEPT_TASK, {id = self:getCurTaskId()})
    elseif self._txtPick:getString() == StaticData['local_text']['label.passcard.task.giveup1'] then
        network:sendPacket(Protocol.C_2_S_PASSCARD_ABANDON_TASK, {id = self:getCurTaskId()})
    elseif self._txtPick:getString() == StaticData['local_text']['label.passcard.task.get'] then
        network:sendPacket(Protocol.C_2_S_PASSCARDTASK_DRAW_REWARD, {id = self:getCurTaskId()})
    end
end

function PassCheckTaskExam:initUIBox()
    local box_pos = {}
    self._panelBox:setVisible(false)
    local width = self._panelBox:getContentSize().width
    for i = 1, 4 do
        local box = self._panelBox:clone()
        box:setVisible(true)
        local pos_x, pos_y = self._panelBox:getPosition()
        box:setPosition(pos_x + (i - 1) * 135, pos_y)
        box:setName(string.format("Box_%d", i))
        box:getChildByName("Image_2"):setVisible(false)
        box:getChildByName("Image_6"):setVisible(false)
        self._nodeReward:addChild(box)

        local item = uq.RewardType.new(self._totalReward[i].reward)
        local equip_item = require("app.modules.common.EquipItem"):create({info = item:toEquipWidget()})
        equip_item:setScale(0.5)
        equip_item:setPosition(cc.p(32, 28))
        box:getChildByName("Panel_item"):addChild(equip_item)

        box:setTouchEnabled(true)
        box:getChildByName("Panel_2"):addClickEventListener(function(sender)
            local box_reward = self._totalReward[i]
            if box:getChildByName('Text_6'):getString() == StaticData['local_text']['arena.reward.click'] then
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
                network:sendPacket(Protocol.C_2_S_PASSCARDTASK_LIVENESS_DRAW_REWARD, {id = box_reward.ident})
            end
        end)

        local box_x = box:getPositionX()
        local data = {
            id = i,
            x = box_x + width / 2,
        }
        table.insert(box_pos, data)
    end
    return box_pos
end

function PassCheckTaskExam:refreshUIBox()
    self._txtTaskNum:setHTMLText(string.format("<font color='#29e51f'>%d</font>/%d", uq.cache.pass_check._passCardInfo.task_num, self._totalTaskNum))
    --选中当前任务
    if not self._curSelectIndex then
        local exist, id = uq.cache.pass_check:isTaskExist()
        if exist then
            self._curSelectIndex = self._taskIdMapIndex[id]
        else
            self._curSelectIndex = 1
        end
    end
    self._txtActive:setString(self:getTaskActive())
    self:selectTaskByIdx(self._curSelectIndex)
    self:refreshReward()
    self._txtRefreshGold:setString(uq.cache.pass_check:getTaskRefreshCost())
end

function PassCheckTaskExam:refreshReward()
    --宝箱最开始的时候
    for i = 1, 4 do
        local node_item = self._nodeReward:getChildByName(string.format('Box_%d', i))
        node_item:getChildByName('Image_2'):setVisible(false)
        node_item:getChildByName('Text_6'):setString(self._totalReward[i].nums)
    end

    local percent = 0
    local range = self:getTaskDayRange()

    local is_completed = true
    for k, v in ipairs(range) do
        if self:getTaskActive() < v.nums then
            self:countTaskPercentCount(k - 1, k)
            self:showTaskCompleteNotReceviedState(k - 1)
            is_completed = false
            break
        end
    end

    if is_completed then
        self._imgPro:setContentSize(cc.size(487, 12))
        self:showTaskCompleteNotReceviedState(4)
    end

    for k, id in ipairs(uq.cache.pass_check._passCardInfo.liviness_gift) do
        local node_item = self._nodeReward:getChildByName(string.format('Box_%d', id))
        node_item:getChildByName('Image_2'):setVisible(true)
        node_item:getChildByName("Image_6"):setVisible(true)
        node_item:getChildByName('Text_6'):setString(self._totalReward[id].nums)
    end
end

function PassCheckTaskExam:showTaskCompleteNotReceviedState(num)
    for i = 1, 4 do
        if num >= i then
            local node_item = self._nodeReward:getChildByName(string.format('Box_%d', i))
            node_item:getChildByName('Image_2'):setVisible(false)
            node_item:getChildByName('Text_6'):setString(StaticData['local_text']['arena.reward.click'])
        end
    end
end

function PassCheckTaskExam:countTaskPercentCount(index1, index2)
    --计算百分比:由于不是均匀分布的所以计算每一段的百分比
    local range = self:getTaskDayRange()
    local percent = 0
    if index1 == 0 then
        percent = self:getTaskActive() / range[index2].nums
    else
        percent = (self:getTaskActive() - range[index1].nums) / (range[index2].nums - range[index1].nums)
    end
    self:setTaskProPos(percent, index2)
end

function PassCheckTaskExam:getTaskDayRange()
    local range = {}
    for k, v in pairs(self._totalReward) do
        table.insert(range, v)
    end

    table.sort(range, function(item1, item2)
        return item1.nums < item2.nums
    end)

    return range
end

function PassCheckTaskExam:setTaskProPos(percent, section)
    local pro_x = 0
    local pos_x = self._imgPro:getPositionX()
    if section == 1 then
        pro_x = self:getTaskProPos(self._boxPos[1].x, pos_x, percent)
    elseif section <= 4 then
        pro_x = self:getTaskProPos(self._boxPos[section].x, self._boxPos[section - 1].x, percent)
    end

    local width = pro_x - pos_x
    width = width > 487 and 487 or width
    self._imgPro:setContentSize(cc.size(width, 12))
    self._imgPro:setVisible(false)
    if width ~= 0 then
        self._imgPro:setVisible(true)
    end
end

function PassCheckTaskExam:getTaskProPos(pos_x, pos_x1, percent)
    local section_width = pos_x - pos_x1
    local pro_x = section_width * percent + pos_x1
    return pro_x
end

function PassCheckTaskExam:onExit()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventInitTag)
    PassCheckTaskExam.super.onExit(self)
end

function PassCheckTaskExam:onRule(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._nodeDec:setVisible(true)
    if self._func then
        self._func()
    end
end

function PassCheckTaskExam:setRuleState(func)
    self._func = func
end

function PassCheckTaskExam:closeRule()
    self._nodeDec:setVisible(false)
end

function PassCheckTaskExam:onRefresh(event)
    if event.name ~= "ended" then
        return
    end

    if uq.cache.pass_check:isTaskExist() then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['label.passcard.finish.cur'])
        return
    end

    local gold = uq.cache.pass_check:getTaskRefreshCost()
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, gold) then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
        return
    end

    local function confirm()
        self._curSelectIndex = nil
        network:sendPacket(Protocol.C_2_S_PASSCARD_REFRESH_TASK)
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local str = string.format(StaticData['local_text']['label.passcard.refresh'], '<img img/common/ui/03_0003.png>', gold)
    local data = {
        content = str,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.PASS_CHECK_REFRESH)
end

function PassCheckTaskExam:showAction()
    uq.intoAction(self._nodeBase)
    for i, v in ipairs(self._allUi) do
        v:showAction()
    end
end

return PassCheckTaskExam
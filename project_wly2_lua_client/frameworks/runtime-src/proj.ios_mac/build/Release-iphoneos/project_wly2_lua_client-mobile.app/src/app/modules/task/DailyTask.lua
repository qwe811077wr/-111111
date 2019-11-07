local DailyTask = class("DailyTask", require("app.modules.common.BaseViewWithHead"))
local TaskItem = require("app.modules.task.TaskItem")
local EquipItem = require("app.modules.common.EquipItem")

DailyTask.RESOURCE_FILENAME = "task/DailyTask.csb"
DailyTask.RESOURCE_BINDING  = {
    ["panel_1/Panel_tabView"]                        ={["varname"] = "_panelTableView"},
    ["Panel_3/Panel_4/img_percent"]                  ={["varname"] = "_imgPercent"},
    ["Panel_3/Panel_4/Image_12"]                     ={["varname"] = "_imgPreBg"},
    ["Panel_3/Text_12"]                              ={["varname"] = "_txtPre"},
    ["Panel_3/Panel_4"]                              ={["varname"] = "_panelHide"},
    ["Panel_3/Node_1"]                               ={["varname"] = "_nodeItem"},
    ["panel_1"]                                      ={["varname"] = "_panel"},
    ["panel_1/label_time"]                           ={["varname"] = "_timeLabel"},
    ["Panel_3"]                                      ={["varname"] = "_pnlBox"},
}

function DailyTask:ctor(name, args)
    DailyTask.super.ctor(self, name, args)
    self._boxArray = {}
    self._curDailyInfo = {}
    self._curTotalInfo = {}
    self._curTabInfo = {}
    self._curBoxInfo = {}
    self._isShow = false
    self._allUi = {}
    local data = StaticData['livenesses'].Liveness
    self._totalBoxNum = #data
    self._curMaxCredit = data[self._totalBoxNum].credit
    self._curFirstBoxIndex = 1
    self._showBoxNum = 5
end

function DailyTask:init()
    self:parseView()
    self:centerView()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.DAILY_TASK)
    self:initUi()
    self:initTableView()
    self:initProtocal()
    self:initTimer()
    self:adaptBgSize()
    uq.intoAction(self._pnlBox)
end

function DailyTask:initTimer()
    uq.TimerProxy:addTimer("daily_time",function()
        if self._curDailyInfo.resetTime == nil or self._curDailyInfo.resetTime <= 0 then
            return
        end
        local time = self._curDailyInfo.resetTime - os.time()
        if time <= 0 then
            self._curDailyInfo.resetTime = -1
            time = 0
        end
        local cur_time_string = uq.getTime(time,uq.config.constant.TIME_TYPE.HHMMSS)
        self._timeLabel:setHTMLText(string.format(StaticData['local_text']['task.daily.des1'],cur_time_string))
    end,1,-1)
end

function DailyTask:initUi()
    self._imgPercent:setVisible(false)
    self._contentSize = self._imgPercent:getContentSize()
    local pos_x, pos_y = self._imgPercent:getPosition()
    local pos = self._panelHide:convertToWorldSpace(cc.p(pos_x, pos_y))
    local img_pos = self._nodeItem:convertToNodeSpace(pos)
    for i = 1, self._showBoxNum do
        local box = self._nodeItem:getChildByName("panel_" .. i)
        local info = StaticData['livenesses'].Liveness[i]
        local data = uq.RewardType.new(info.rewards)
        local item = EquipItem:create({info = data:toEquipWidget()})
        item:setNameFontSize(32)
        local size = box:getContentSize()
        item:setScale(0.5)
        item:setPosition(cc.p(size.width / 2, size.height / 2))
        box:addChild(item, -1)
        box:setTag(i)
        box["userData"] = 0

        local delta = (info.credit / self._curMaxCredit) * self._contentSize.width
        box:setPositionX(img_pos.x + delta)

        box:getChildByName("Text"):setString(info.credit)
        box:getChildByName("black_bg"):setVisible(false)
        local check_box = box:getChildByName("CheckBox")
        check_box:setSelected(false)
        check_box:setTouchEnabled(false)

        box:setTouchEnabled(true)
        box:addClickEventListenerWithSound(handler(data:toEquipWidget(), function(data, sender)
            local tag = sender:getTag()
            local status = sender["userData"]
            local info = StaticData['livenesses'].Liveness[tag]
            if status == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
                network:sendPacket(Protocol.C_2_S_LIVENESS_DRAW_CREDIT, {ident = box:getTag()})
            else
                uq.ModuleManager:getInstance():show(uq.ModuleManager.TOOL_TIPS_MODULE,{info = data})
            end
        end))
        table.insert(self._boxArray,box)
    end
    for k,v in pairs(StaticData['livenesses'].LivenessTask) do
        v.curIndex = 0
        v.sortIndex = 1
        v.state = 0
        local level_fit = not (v.needlevel and v.needlevel ~= '' and uq.cache.role:level() < v.needlevel)
        local instance_fit = not (v.needMission and not uq.cache.instance:isNpcPassed(tonumber(v.needMission)))
        v.fit = level_fit and instance_fit
        self._curTotalInfo[v.ident] = v
    end
    self._txtPre:setString(0)
end

function DailyTask:initProtocal()
    network:addEventListener(Protocol.S_2_C_LIVENESS_LOAD,handler(self,self._onLoadVitalityInfo),"_onLoadVitalityInfoByDailyTask")
    network:addEventListener(Protocol.S_2_C_LIVENESS_DRAW_REWARD,handler(self,self._onTaskVitalityReward),"_onTaskVitalityRewardByDailyTask")
    network:addEventListener(Protocol.S_2_C_LIVENESS_DRAW_CREDIT,handler(self,self._onTakeVitalityReward),"_onTakeVitalityRewardByDailyTask")
    network:addEventListener(Protocol.S_2_C_LIVENESS_LIST,handler(self, self._onLoadVitalityList), "_onLoadVitalityList")
    network:sendPacket(Protocol.C_2_S_LIVENESS_LOAD, {})
end

function DailyTask:_onTaskVitalityReward(evt)
    local data = evt.data
    if evt.ret == 1 or not self._curTotalInfo[evt.data.ident] then
        return
    end
    self._curTotalInfo[evt.data.ident].state = 2
    self._curTotalInfo[evt.data.ident].sortIndex = 0
    self._curDailyInfo.credit = self._curDailyInfo.credit + self._curTotalInfo[evt.data.ident].credit
    self._txtPre:setString(self._curDailyInfo.credit)
    self._imgPercent:setVisible(true)
    self._imgPercent:setContentSize(math.floor(self._curDailyInfo.credit / self._curMaxCredit * self._contentSize.width),self._contentSize.height)
    self._curTabInfo = {}
    for k,v in pairs(self._curTotalInfo) do
        table.insert(self._curTabInfo, v)
    end
    self:sortTask()
    local offset = self._tableView:getContentOffset();
    self._tableView:reloadData()
    self:showAction()
    self._tableView:setContentOffset(offset);
    self:updateBox()
    local info = StaticData['livenesses'].LivenessTask[evt.data.ident]
    if not info then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = info.rewards})
end

function DailyTask:_onTakeVitalityReward(evt)
    local info = StaticData['livenesses'].Liveness[evt.data.ident]
    if not info or evt.data.ret == 1 then
        return
    end
    self._curDailyInfo.numbers[evt.data.ident] = evt.data.ident
    self:updateBox()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = info.rewards})
end

function DailyTask:_onLoadVitalityInfo(evt)
    local info = evt.data
    self._curDailyInfo.credit = evt.data.credit
    self._curDailyInfo.count = evt.data.count
    local numbers = {}
    for k, v in pairs(evt.data.numbers) do
        numbers[v] = v
    end
    self._curDailyInfo.numbers = numbers
    self._txtPre:setString(info.credit)
    self._imgPercent:setVisible(true)
    if info.credit == 0 then
        self._imgPercent:setVisible(false)
    else
        self._imgPercent:setContentSize(math.floor(info.credit / self._curMaxCredit * self._contentSize.width), self._contentSize.height)
    end
    for i = self._curFirstBoxIndex + 1, self._totalBoxNum - self._showBoxNum + 1 do
        if not self._curDailyInfo.numbers[i] then
            break
        else
            self._curFirstBoxIndex = i
        end
    end
    self:updateBox()
end

function DailyTask:_onLoadVitalityList(evt)
    for k,v in ipairs(evt.data.items) do
        if self._curTotalInfo[v.id] then
            self._curTotalInfo[v.id].curIndex = v.number
            self._curTotalInfo[v.id].state = v.state
            if v.state == 2 then
                self._curTotalInfo[v.id].sortIndex = 0
            elseif v.state == 1 then
                self._curTotalInfo[v.id].sortIndex = 2
            end
        end
    end

    self._curTabInfo = {}
    for k,v in pairs(self._curTotalInfo) do
        table.insert(self._curTabInfo,v)
    end
    self:sortTask()
    self._tableView:reloadData()
    self:showAction()
end

function DailyTask:updateBox(index, new_tag)
    for k, v in ipairs(self._boxArray) do
        local info = StaticData['livenesses'].Liveness[k]
        if not info then
            return
        end
        local state = info.credit <= self._curDailyInfo.credit
        local task_state = self._curDailyInfo.numbers[k] ~= nil
        local node_effect = v:getChildByName("Node_1")
        v:getChildByName("CheckBox"):setSelected(state)
        v:getChildByName("black_bg"):setVisible(task_state)
        node_effect:removeAllChildren()
        if task_state then
            self._boxArray[k]["userData"] = uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED
        elseif state then
            self._boxArray[k]["userData"] = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
            uq:addEffectByNode(node_effect, 900053, -1, true, nil, nil, 0.7)
        else
            self._boxArray[k]["userData"] = uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT
        end
    end
end

function DailyTask:sortTask()
    if self._curTabInfo == nil or #self._curTabInfo < 2 then
        return self._curTabInfo
    end
    table.sort(self._curTabInfo,function(a,b)
        if a.fit ~= b.fit then
            return a.fit
        elseif a.sortIndex == b.sortIndex then
            return a.ident < b.ident
        else
            return a.sortIndex > b.sortIndex
        end
    end)
end

function DailyTask:update(param)
    network:sendPacket(Protocol.C_2_S_LIVENESS_LOAD, {})
end

function DailyTask:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function DailyTask:cellSizeForTable(view, idx)
    return 1080, 170
end

function DailyTask:numberOfCellsInTableView(view)
    return #self._curTabInfo
end

function DailyTask:tableCellTouched(view, cell,touch)

end

function DailyTask:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curTabInfo[index]
        local euqip_item = nil
        if info ~= nil then
            euqip_item = TaskItem:create({info = info, type = 1})
            euqip_item:setPosition(cc.p(0, 80))
            cell:addChild(euqip_item)
            table.insert(self._allUi, euqip_item)
            euqip_item:setName("item")
        end
    else
        local info = self._curTabInfo[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
            euqip_item:setVisible(true)
        end
    end
    return cell
end

function DailyTask:showAction()
    if self._isShow then
        return
    end
    for k, v in pairs(self._allUi) do
        v:showAction()
    end
    self._isShow = true
end

function DailyTask:dispose()
    uq.TimerProxy:removeTimer("daily_time")
    uq.TimerProxy:removeTimer("move_daily_credit_reward_box")
    network:removeEventListenerByTag('_onLoadVitalityInfoByDailyTask')
    network:removeEventListenerByTag('_onTaskVitalityRewardByDailyTask')
    network:removeEventListenerByTag('_onTakeVitalityRewardByDailyTask')
    network:removeEventListenerByTag('_onLoadVitalityList')
    DailyTask.super.dispose(self)
end

return DailyTask
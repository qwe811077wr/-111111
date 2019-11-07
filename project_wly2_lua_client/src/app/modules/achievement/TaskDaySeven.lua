local TaskDaySeven = class("TaskDaySeven", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

TaskDaySeven.RESOURCE_FILENAME = "achievement/TaskDaySeven.csb"
TaskDaySeven.RESOURCE_BINDING = {
    ["Image_buy"]               = {["varname"] = "_imgBuy"},
    ["Image_57"]                = {["varname"] = "_imgTotal"},
    ["Node_1"]                  = {["varname"] = "_node"},
    ["Panel_box"]               = {["varname"] = "_panelBox"},
    ["Panel_1"]                 = {["varname"] = "_panelContent"},
    ["Button_welfare"]          = {["varname"] = "_btnList1",["events"] = {{["event"] = "touch",["method"] = "_onChooseTasks"}}},
    ["Button_task_two"]         = {["varname"] = "_btnList2",["events"] = {{["event"] = "touch",["method"] = "_onChooseTasks"}}},
    ["Button_task_three"]       = {["varname"] = "_btnList3",["events"] = {{["event"] = "touch",["method"] = "_onChooseTasks"}}},
    ["Button_half_price_buy"]   = {["varname"] = "_btnList4",["events"] = {{["event"] = "touch",["method"] = "_onChooseTasks"}}},
    ["Text_50"]                 = {["varname"] = "_txtItemName"},
    ["surplus_num_txt"]         = {["varname"] = "_txtItemNumLeft"},
    ["Panel_14"]                = {["varname"] = "_panelItem"},
    ["Text_price"]              = {["varname"] = "_txtNowPrice"},
    ["Text_original_price"]     = {["varname"] = "_txtOriginalPrice"},
    ["Button_buy"]              = {["varname"] = "_btnBuy",["events"] = {{["event"] = "touch",["method"] = "_onGoodsBuy"}}},
    ["Text_58"]                 = {["varname"] = "_txtBuy"},
    ["Button_1"]                = {["varname"] = "_btnHelp",["events"] = {{["event"] = "touch",["method"] = "_onTaskHelp"}}},
    ["close_btn"]               = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onClose"}}},
    ["num_fnt_txt"]             = {["varname"] = "_txtTotalNum"},
    ["Text_reward_time"]        = {["varname"] = "_txtRewardTime"},
    ["Text_task_time"]          = {["varname"] = "_txtTaskTime"},
    ["Node_day"]                = {["varname"] = "_nodeDay"},
    ["Node_2"]                  = {["varname"] = "_nodeContentEffect"},
    ["Image_17"]                = {["varname"] = "_imgContentBg"},
    ["left_1_pnl"]              = {["varname"] = "_pnlLeft1"},
    ["discount_txt"]            = {["varname"] = "_txtDiscount"},
    ["item_finish_img"]         = {["varname"] = "_imgFinishItem"},
    ["box_node"]                = {["varname"] = "_nodeBox"},
    ["LoadingBar_1"]            = {["varname"] = "_lbr"},
}

function TaskDaySeven:ctor(name, params)
    TaskDaySeven.super.ctor(self, name, params)
end

function TaskDaySeven:init()
    self:centerView()
    self:parseView()
    self:setLayerColor(0.6)
    self._allBox= {}
    self._allListData = {}
    self._curCacheTasks = {}
    self._cacheTaskDay = uq.cache.achievement._taskDaySevenInfo
    self._cacheTaskItems = uq.cache.achievement._taskDaySevenItems
    self._taskDay = StaticData['seven_task']
    self._totalReward = self._taskDay.TotalReward
    self._maxNumBoxs = #self._totalReward
    self._sevenTask = self._taskDay.SevenTask
    self._finishedNum = self._cacheTaskDay.finished_num
    self:initUIBox()
    self._dayIndex = math.min(self._cacheTaskDay.create_days, 7)
    self._selectedDay = self._dayIndex
    self._chooseTag = 1

    self._txtTotalNum:setString(self._finishedNum)

    self:initLeftBtn()
    self:getCurCacheTasks()
    self:refreshListData(self._chooseTag)
    self:initTaskDayList()
    self:refreshUIBox()
    self:refreshChooseTasks(self._chooseTag)
    self:refreshBtnRed()
    self._cdTime = uq.cache.achievement:getSevenSurplusTime()
    self._eventRefresh = '_eventRefresh' .. tostring(self)
    uq.TimerProxy:addTimer(self._eventRefresh, handler(self, self.refreshTime), 1, -1)
    self:refreshTime()
end

function TaskDaySeven:_onTaskDayTimeRefresh(msg)
    self._txtTaskTime:setString(msg.data.task_left_time)
    self._txtRewardTime:setString(msg.data.reward_left_time)
end

function TaskDaySeven:onCreate()
    TaskDaySeven.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_TASK_DAY_BUY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TASK_DAY_BUY_REFRESH, handler(self, self._onTaskDayBuyRefresh), self._eventTag)

    self._eventTag1 = services.EVENT_NAMES.ON_TASK_DAY_ITEM_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TASK_DAY_ITEM_REFRESH, handler(self, self._onTaskDayItemRefresh), self._eventTag1)

    self._eventTag2 = services.EVENT_NAMES.ON_TASK_DAY_TOTAL_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TASK_DAY_TOTAL_REFRESH, handler(self, self._onTaskDayTotalRefresh), self._eventTag2)

    self._eventTag3 = services.EVENT_NAMES.ON_TASK_DAY_TIME_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TASK_DAY_TIME_REFRESH, handler(self, self._onTaskDayTimeRefresh), self._eventTag3)

    self._eventTagRed = services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED, handler(self, self.refreshBtnRed), self._eventTagRed)
end

function TaskDaySeven:refreshTime()
    if self._cdTime >= 0 then
        self._txtTaskTime:setString(self:getTimeDayHourMinutes(self._cdTime))
        self._cdTime = self._cdTime - 1
        return
    end
    self._txtTaskTime:setString(StaticData["local_text"]["activity.end"])
    uq.TimerProxy:removeTimer(self._eventRefresh)
end

function TaskDaySeven:getTimeDayHourMinutes(time)
    local time = time or 0
    local day = math.floor(time / 86400)
    local hour = math.floor((time - day * 86400) / 3600)
    local minutes = math.floor((time - day * 86400 - hour * 3600) / 60) + 1
    return string.format(StaticData["local_text"]["activity.sign.surplus.time"], day, hour, minutes)
end

function TaskDaySeven:onExit()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventTag2)
    services:removeEventListenersByTag(self._eventTag3)
    services:removeEventListenersByTag(self._eventTagRed)
    uq.TimerProxy:removeTimer(self._eventRefresh)
    TaskDaySeven.super:onExit()
end

function TaskDaySeven:initLeftBtn()
    for i = 1, 7 do
        local is_one = i == 1
        local pnl = is_one and self._pnlLeft1 or self._pnlLeft1:clone()
        if not is_one then
            self._nodeDay:addChild(pnl)
            self["_pnlLeft" .. i] = pnl
            pnl:setPosition(0, - (i - 1) * 60)
        end
        pnl:getChildByName("Text_2"):setString(string.format(StaticData['local_text']['activity.day.num'], StaticData['local_text']['label.common.num' .. i]))
        pnl:getChildByName("left_btn"):addClickEventListener(function(sender)
            if i > self._dayIndex then
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
                uq.fadeInfo(StaticData['local_text']['label.common.module.des'])
                return
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            self._selectedDay = i
            self:getCurCacheTasks()
            self:refreshListData(1)
            self:refreshChooseTasks(1)
            self:refreshHalfPriceBuy(false, true)
            self._listViewContent:reloadData()
            self:refreshBtnRed()
            self:refreshLeftBtn()
        end)
    end
    self:refreshLeftBtn()
end

function TaskDaySeven:refreshLeftBtn()
    for i = 1, 7 do
        local pnl = self["_pnlLeft" .. i]
        local is_sel = self._selectedDay == i
        pnl:getChildByName("down_img"):setVisible(not is_sel)
        pnl:getChildByName("up_img"):setVisible(is_sel)
        local color = is_sel and "#935e18" or "#212426"
        pnl:getChildByName("Text_2"):setTextColor(uq.parseColor(color))
        pnl:getChildByName("lock_img"):setVisible(i > self._dayIndex)
    end
end

function TaskDaySeven:initTaskDayList()
    local viewSize = self._panelContent:getContentSize()
    self._listViewContent = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listViewContent:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listViewContent:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listViewContent:setPosition(cc.p(0, 0))
    self._listViewContent:setDelegate()
    self._listViewContent:registerScriptHandler(handler(self, self.tableCellTouchedContent), cc.TABLECELL_TOUCHED)
    self._listViewContent:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listViewContent:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._listViewContent:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listViewContent:reloadData()
    self._panelContent:addChild(self._listViewContent)
end

function TaskDaySeven:tableCellTouchedContent(view, cell)
    local index = cell:getIdx() + 1
end

function TaskDaySeven:cellSizeForTableContent(view, idx)
    return 780, 140
end

function TaskDaySeven:numberOfCellsInTableViewContent(view)
    return #self._curCacheTasks
end

function TaskDaySeven:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("achievement.TaskDaySevenCell")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setTag(1000)
    local cache_data = self._curCacheTasks[index]
    local xml_data = self:getXmlData(cache_data.id)
    if cache_data ~= nil then
        cell_item:setData(xml_data, cache_data)
    end
    return cell
end

function TaskDaySeven:getCurCacheTasks()
    self._allListData = {}
    local xml_data = self._sevenTask[self._selectedDay]['Task']
    for i, v in ipairs(self._cacheTaskItems[self._selectedDay]) do
        for _, iv in pairs(xml_data) do
            if v.id == iv.ident then
                if not self._allListData[iv.catalogId] then
                    self._allListData[iv.catalogId] = {}
                end
                table.insert(self._allListData[iv.catalogId], v)
                break
            end
        end
    end
end

function TaskDaySeven:refreshListData(idx)
    self._curCacheTasks = self._allListData[idx] or {}
    local sort_table = {2, 3, 1}
    table.sort(self._curCacheTasks, function(a, b)
        if a.state == b.state then
            return a.id < b.id
        end
        return sort_table[a.state + 1] > sort_table[b.state + 1]
    end)
end

function TaskDaySeven:getXmlData(id)
    local xml_data = self._sevenTask[self._selectedDay]['Task']
    for k, v in pairs(xml_data) do
        if v.ident == id then
            return v
        end
    end
    return {}
end

function TaskDaySeven:refreshChooseTasks(index)
    local data = self._sevenTask[self._selectedDay]['Catalog']
    for i = 1, 4 do
        self["_btnList" .. i]:setEnabled(index ~= i)
        self["_btnList" .. i]:getChildByName("Text_8"):setString(data[i].name)
    end
    self._chooseTag = index
    if self._chooseTag == 4 then
        uq.cache.achievement:addOpenRedSeven(self._selectedDay)
        self:refreshHalfPriceBuy(true, false)
        self:initHalfPriceBuyData()
        self:refreshBtnBuy()
        return
    end
    self:refreshHalfPriceBuy(false, true)
    self:refreshListData(self._chooseTag)
    self._listViewContent:reloadData()
end

function TaskDaySeven:_onChooseTasks(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    self:refreshChooseTasks(event.target:getTag() - 600)
end

function TaskDaySeven:_onTaskDayBuyRefresh()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = self._curGood})
    self:initHalfPriceBuyData()
    self:refreshBtnBuy()
end

function TaskDaySeven:_onTaskDayItemRefresh()
    if self._chooseTag == 4 then
        return
    end
    self._finishedNum = self._cacheTaskDay.finished_num
    self:refreshListData(self._chooseTag)
    self._txtTotalNum:setString(self._finishedNum)
    self:refreshUIBox()
    self._listViewContent:reloadData()
end

function TaskDaySeven:_onTaskDayTotalRefresh(msg)
    for k,v in pairs(self._totalReward) do
        if v.ident == msg.id then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = v.reward})
            break
        end
    end
    self:refreshUIBox()
end

function TaskDaySeven:refreshHalfPriceBuy(buy_flag, other_flag)
    self._imgBuy:setVisible(buy_flag)
    self._panelContent:setVisible(other_flag)
end

function TaskDaySeven:initHalfPriceBuyData()
    local index = self._selectedDay * 1000 + 401
    local data = self._sevenTask[self._selectedDay]['Discount'][index]
    self._goodsId = data.ident
    self._curGood = data.goods
    local goods = uq.RewardType:create(data.goods)
    local info = StaticData.getCostInfo(goods:type(), goods:id())
    self._txtItemName:setString(info.name)
    self._num = self:getStoreNum(data.times, data.ident)
    self._txtItemNumLeft:setHTMLText(string.format(StaticData['local_text']['activity.surplus.num.lv'], self._num))
    self._cost = uq.RewardType:create(data.cost)
    self._txtNowPrice:setString(self._cost:num())
    local price = uq.RewardType:create(data.price)
    self._txtOriginalPrice:setString(price:num())
    self._txtDiscount:setString(tostring(self._cost:num() / price:num() * 10))
    self._panelItem:removeAllChildren()
    local euqip_item = EquipItem:create({info = goods:toEquipWidget()})
    self._panelItem:addChild(euqip_item)
    euqip_item:setTouchEnabled(true)
    euqip_item:setScale(0.8)
    euqip_item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
end

function TaskDaySeven:getStoreNum(num, id)
    for k, v in pairs(self._cacheTaskDay.store_nums) do
        if v.id == id then
            return num - v.num
        end
    end
    return num
end

function TaskDaySeven:initUIBox()
    for i = 1, self._maxNumBoxs do
        local pnl = self._panelBox:clone()
        self._nodeBox:addChild(pnl)
        pnl:setVisible(true)
        pnl:setPosition(cc.p(self._totalReward[i].nums / self._totalReward[self._maxNumBoxs].nums * 618, 0))
        pnl:getChildByName("Text_num"):setString(self._totalReward[i].nums .. "个")
        pnl:getChildByName("items_box_node"):removeAllChildren()
        uq:addEffectByNode(pnl:getChildByName("action_pnl"), 900053, -1, true, cc.p(0, 0), nil, 0.8)
        local euqip_item = EquipItem:create({info = uq.RewardType:create(self._totalReward[i].reward):toEquipWidget()})
        pnl:getChildByName("items_box_node"):addChild(euqip_item)
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.6)
        euqip_item:addClickEventListenerWithSound(function(sender)
            if self:isFinishReward(i) then
                return
            end
            if self._finishedNum < self._totalReward[i].nums then
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
                return
            end
            network:sendPacket(Protocol.C_2_S_TASK_DAY7_DRAW_TOTAL, {id = self._totalReward[i].ident})
        end)
        table.insert(self._allBox, pnl)
    end
end

function TaskDaySeven:isFinishReward(id)
    if not self._cacheTaskDay.total_reward_ids or next(self._cacheTaskDay.total_reward_ids) == nil then
        return false
    end
    for k, v in pairs(self._cacheTaskDay.total_reward_ids) do
        if v == id then
            return true
        end
    end
    return false
end

function TaskDaySeven:refreshUIBox()
    self:refreshLbr()
    for i, v in ipairs(self._allBox) do
        v:getChildByName("box_finish_img"):setVisible(self:isFinishReward(i))
        v:getChildByName("action_pnl"):setVisible(self._finishedNum >= self._totalReward[i].nums and not self:isFinishReward(i))
    end
end

function TaskDaySeven:refreshLbr()
    self._lbr:setPercent(math.min(self._finishedNum / self._totalReward[self._maxNumBoxs].nums * 100, 100))
end

function TaskDaySeven:getTaskDayRange()
    local range = {}
    for k, v in pairs(self._totalReward) do
        table.insert(range, v)
    end

    table.sort(range, function(item1, item2)
        return item1.nums < item2.nums
    end)

    return range
end

function TaskDaySeven:refreshBtnBuy()
    local ShaderEffect = uq.ShaderEffect
    local is_show = self._num > 0
    self._btnBuy:setVisible(is_show)
    self._imgFinishItem:setVisible(not is_show)
end

function TaskDaySeven:_onGoodsBuy(event)
    if event.name ~= "ended" then
        return
    end
    if self._cdTime <= 0 then
        uq.fadeInfo(StaticData["local_text"]["activity.end.time"])
        return
    end

    if uq.cache.role:checkRes(self._cost:type(), self._cost:num(), self._cost:id()) then
        local data = {
            id = self._goodsId
        }
        network:sendPacket(Protocol.C_2_S_TASK_DAY7_STORE_BUY, data)
        return
    end

    local function confirm()
        uq.jumpToModule(StaticData['module'][46].ident)
    end
    local des = "<img img/common/ui/03_0003.png >" .. StaticData['local_text']['achieve.task.day.goto.buy']
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function TaskDaySeven:_onTaskHelp(event)
    if event.name ~= "ended" then
        return
    end

    uq.ModuleManager:getInstance():show(uq.ModuleManager.TASK_DAY_SEVEN_HELP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function TaskDaySeven:_onClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function TaskDaySeven:refreshBtnRed()
    for i = 1, 7 do
        local is_red = uq.cache.achievement:isSevenRedDay(i)
        uq.showRedStatus(self["_pnlLeft" .. i], is_red, 95, 28)
        if i <= 4 then
            local is_btn_red = false
            if i == 4 then
                is_btn_red = uq.cache.achievement:isSevenDiscountRed(self._selectedDay)
            else
                is_btn_red =self:isCanFinishTask(i)
            end
            local size = self["_btnList" .. i]:getContentSize()
            uq.showRedStatus(self["_btnList" .. i], is_btn_red, size.width / 2 - 5, size.height / 2 - 5)
        end
    end
end

function TaskDaySeven:isCanFinishTask(idx)
    if self._allListData[idx] and next(self._allListData[idx]) ~= nil then
        for k, v in pairs(self._allListData[idx]) do
            if v.state == 1 then
                return true
            end
        end
    end
    return false
end


return TaskDaySeven
local AchievementMain = class("AchievementMain", require('app.base.ModuleBase'))
local EquipItem = require("app.modules.common.EquipItem")

AchievementMain.RESOURCE_FILENAME = "achievement/AchievementMain.csb"
AchievementMain.RESOURCE_BINDING = {
    ["Image_bg"]                = {["varname"] = "_imgBg"},
    ["Text_chapter_num"]        = {["varname"] = "_txtChapterNum"},
    ["Text_6"]                  = {["varname"] = "_txtChapterName"},
    ["Panel_2"]                 = {["varname"] = "_panelContent"},
    ["Image_pre_bg"]            = {["varname"] = "_imgProBg"},
    ["Panel_precent"]           = {["varname"] = "_panelPro"},
    ["Img_percent"]             = {["varname"] = "_imgPro"},
    ["Img_per"]                 = {["varname"] = "_imgProHead"},
    ["Panel_box"]               = {["varname"] = "_panelBox"},
    ["Image_14"]                = {["varname"] = "_imgAchieveBg"},
    ["Node_1"]                  = {["varname"] = "_nodePro"},
    ["Node_3"]                  = {["varname"] = "_node"},
    ["Text_12"]                 = {["varname"] = "_txtCompletedNum"},
    ["Text_13"]                 = {["varname"] = "_txtAllCompletedNum"},
    ["Text_43"]                 = {["varname"] = "_txtBranch"},
    ["Image_15"]                = {["varname"] = "_imgTask"},
    ["Button_1"]                = {["varname"] = "_panelMainTask",["events"] = {{["event"] = "touch",["method"] = "_onShowTask"}}},
    ["Button_2"]                = {["varname"] = "_panelChapterTask",["events"] = {{["event"] = "touch",["method"] = "_onShowTask"}}},
    ["Button_3"]                = {["varname"] = "_panelDailyTask",["events"] = {{["event"] = "touch",["method"] = "_onShowTask"}}},
    ["Node_daily_task"]         = {["varname"] = "_nodeDailyTask"},
    ["Node_task"]               = {["varname"] = "_nodeTask"},
    ["Image_branch_pre"]        = {["varname"] = "_imgBranchPre"},
}
function AchievementMain:ctor(name, params)
    AchievementMain.super.ctor(self, name, params)

    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
end

function AchievementMain:init()
    self:centerView()

    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE))
    top_ui:setTitle(uq.config.constant.MODULE_ID.ACHIEVEMENT)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self:parseView()
    self:initDailyTask()
    self:adaptBgSize(self._imgBg)

    self._achievement = StaticData['achievements']
    self._chapters = uq.cache.achievement._chapters
    self._mainTask = uq.cache.achievement._mainTask
    self._taskSearch = uq.cache.achievement._taskSearch

    self._box = {}
    self._boxPos = self:initUIBox()

    self._panelMainTask.task_type = uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN
    self._panelChapterTask.task_type = uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.BRANCH
    self._panelDailyTask.task_type = uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.DAILY
    self._curTaskType = self._panelMainTask.task_type

    self:initAchievementList()
    self:showFirstTaskContent()

    local prefix = self:getAchieveBoxIdPrefix()
    self._endId = self._achieve[prefix + 1]['ident']

    self:setBoxTag()
    self:refreshUIBox()
end

function AchievementMain:initDailyTask()
    self._nodeDaily = uq.createPanelOnly("task.DailyTask")
    self._nodeDaily:setPosition(cc.p(80, -100))
    self._nodeDaily:init()
    self._nodeDailyTask:addChild(self._nodeDaily)
end

function AchievementMain:showFirstTaskContent()
    if self._mainTask.id ~= nil then
        self:showFirstMainTask()
        return
    end

    if #self._chapters ~= 0 then
        self:showFirstBranchTask()
        return
    end

    self:hideAchieve()
end

function AchievementMain:showFirstMainTask()
    self._curChapter = self._mainTask
    self:initTask()
end

function AchievementMain:showFirstBranchTask()
    self._curChapter = self._chapters[1]
    self:initTask()
    self:clearAchieveRewarded()
    self._listViewContent:reloadData()
end

function AchievementMain:_onShowTask(event)
    if event.name ~= "ended" then
        return
    end

    self._curTaskType = event.target.task_type
    self._nodeDailyTask:setVisible(false)
    self._nodeTask:setVisible(true)

    self:refreshBoxTag()
    self:refreshTask()
    self:refreshBtn(self._curTaskType)
end

function AchievementMain:refreshBoxTag()
    if self._curTaskType == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
        self._curChapter = self._mainTask
    elseif self._curTaskType == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.BRANCH then
        self._curChapter = self._chapters[1]
    end

    if not self._curChapter then
        return
    end

    self._curAchievement = self:getChapterData(self._curChapter.id)
    self._achieve = self._curAchievement['Achieve']
    self:setBoxTag()
    self._endId = self._boxId
end

function AchievementMain:refreshTask()
    if self._curTaskType == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
        self._imgBranchPre:setVisible(false)
        self:showTaskName(false)
        self:showFirstMainTask()
        self:refreshUIBox()
        self._imgTask:loadTexture('img/achievement/j03_000005_1.png')
    elseif self._curTaskType == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.BRANCH then
        self._txtBranch:setString(StaticData['local_text']['achieve.branch'])
        self._imgBranchPre:setVisible(true)
        self:showTaskName(true)
        self:showFirstBranchTask()
        self._imgTask:loadTexture('img/achievement/g04_000133.png')

        if not self._curChapter then
            return
        end
        self:refreshUIBox()
    elseif self._curTaskType == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.DAILY then
        self._txtBranch:setString(StaticData['local_text']['task.tab.des1'])
        self:showTaskName(true)
        self._nodeTask:setVisible(false)
        self._nodeDailyTask:setVisible(true)
    end
end

function AchievementMain:showTaskName(flag)
    local is_main = not flag
    self._txtBranch:setVisible(flag)
    self._txtChapterNum:setVisible(is_main)
    self._txtChapterName:setVisible(is_main)
end

function AchievementMain:refreshBtn(index)
    for i = 1, 3 do
        local btn_name = string.format("Button_%d", i)
        local btn = self._view:getChildByName(btn_name)
        local normal_img = string.format("img/achievement/j02_0000013%d.png", i + 1)
        local select_img = string.format("img/achievement/j02_0000013%d.png", i + 4)
        btn:loadTextures(normal_img, normal_img)

        if index == i then
            btn:loadTextures(select_img, select_img)
        end
    end
end

function AchievementMain:initTask()
    if not self._curChapter then
        self:hideAchieve()
        return
    end
    self:showAchieve()

    self._curAchievement = self:getChapterData(self._curChapter.id)
    self._achieve = self._curAchievement['Achieve']
    self._allCurTask = self._curChapter.tasks
    self:getMeetConditionsData()

    self._txtChapterNum:setString(self._curAchievement.des)
    self._txtChapterName:setString(self._curAchievement.des1)

    self._imgAchieveBg:setVisible(true)
    self._panelPro:setVisible(true)

    self:showTaskRed()
    self:sortCurTask()
    self._listViewContent:reloadData()
end

function AchievementMain:getMeetConditionsData()
    self._curTask = {}
    for k, v in pairs(self._allCurTask) do
        local info = self._curAchievement['Task'][v.id]
        local data = 0
        if info then
            data = info['preTask']
        end
        if data == 0 then
            table.insert(self._curTask, v)
        else
            if self._taskSearch[data].state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
                table.insert(self._curTask, v)
            end
        end
    end
end

function AchievementMain:clearAchieveRewarded()
    for i = #self._curTask, 1, -1 do
        if self._curTask[i].state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
            table.remove(self._curTask, i)
        end
    end
end

function AchievementMain:onCreate()
    AchievementMain.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_ACHIEVEMENT_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_REFRESH, handler(self, self._onAchievementRefresh), self._eventTag)

    self._eventTag1 = services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH, handler(self, self.refreshBoundary), self._eventTag)

    self._eventTag2 = services.EVENT_NAMES.ON_ACHIEVEMENT_BOX_SHOW_REWARD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_BOX_SHOW_REWARD, handler(self, self._onAchievementBoxShowReward), self._eventTag2)

    self._eventTag3 = services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN, handler(self, self._onAchievementOpen), self._eventTag3)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH, handler(self, self.showTaskRed), '_onRedStateChanged' .. tostring(self))
end

function AchievementMain:dispose()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventTag2)
    services:removeEventListenersByTag(self._eventTag3)
    services:removeEventListenersByTag('_onRedStateChanged' .. tostring(self))

    self._nodeDaily:dispose()
    AchievementMain.super.dispose(self)
end

function AchievementMain:initAchievementList()
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
    self._panelContent:addChild(self._listViewContent)
end

function AchievementMain:_onAchievementRefresh()
    self._chapters = uq.cache.achievement._chapters
    self._mainTask = uq.cache.achievement._mainTask

    self:showFirstTaskContent()

    local prefix = self:getAchieveBoxIdPrefix()
    self._endId = self._achieve[prefix + 1]['ident']

    self:setBoxTag()
    self:refreshUIBox()
end

function AchievementMain:showAchieve()
    self._imgAchieveBg:setVisible(true)
    self._panelPro:setVisible(true)
    self._panelContent:setVisible(true)
    self._node:setVisible(true)
    self._txtCompletedNum:setVisible(true)
    self._txtAllCompletedNum:setVisible(true)
end

function AchievementMain:hideAchieve()
    self._imgAchieveBg:setVisible(false)
    self._panelPro:setVisible(false)
    self._panelContent:setVisible(false)
    self._node:setVisible(false)
    self._txtCompletedNum:setVisible(false)
    self._txtAllCompletedNum:setVisible(false)
end

function AchievementMain:getChapterData(id)
    local chapter = self._achievement[id]
    return chapter
end

function AchievementMain:tableCellTouchedContent(view, cell)
    local index = cell:getIdx() + 1
end

function AchievementMain:cellSizeForTableContent(view, idx)
    return 1080, 152
end

function AchievementMain:numberOfCellsInTableViewContent(view)
    return self:getTaskLen()
end

function AchievementMain:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("achievement.AchievementChapterCell")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)

    local xml_data = self:getXmlData(self._curTask[index].id)
    local cache_data = self:getCacheData(self._curTask[index].id)
    if xml_data ~= nil and cache_data ~= nil then
        cell_item:setData(xml_data, cache_data)
    end

    return cell
end

function AchievementMain:getCacheData(id)
    local tasks = uq.cache.achievement._tasks
    for k,v in pairs(tasks) do
        if v.id == id then
            return v
        end
    end
    return
end

function AchievementMain:getXmlData(id)
    local xml_data = self._curAchievement['Task'][id]
    return xml_data
end

function AchievementMain:refreshBoundary()
    self:refreshTask()
end

function AchievementMain:sortCurTask()
    local sort_table = {2, 3, 1}
    table.sort(self._curTask, function(a, b)
        if a.state == b.state then
            return a.id < b.id
        end
        return sort_table[a.state + 1] > sort_table[b.state + 1]
    end)
end

function AchievementMain:getTaskLen()
    local count = 0
    for k, v in pairs(self._curTask) do
        count = count + 1
    end
    return count
end

function AchievementMain:initUIBox()
    local box_pos = {}
    local width = self._panelBox:getContentSize().width

    for i = 1, 5 do
        local box = self._panelBox:clone()
        local pos_x, pos_y = self._panelBox:getPosition()
        box:setPosition(pos_x + (i - 1) * 240, pos_y)
        self._box[i] = box
        self._node:addChild(box)

        box["userData"] = uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT
        box:getChildByName("Node_state"):setVisible(false)
        box:setTouchEnabled(true)
        box:addClickEventListenerWithSound(function(sender)
            local index = sender:getTag()
            local achieve = self._achieve[index]
            local status = sender["userData"]

            if status == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
                local data = {
                    id = achieve.ident,
                    chapter_id = self._curAchievement['ident'],
                    rwd_type = uq.config.constant.TYPE_ACHIEVEMENT_REWARD.BOX
                }
                network:sendPacket(Protocol.C_2_S_ACHIEVEMENT_DRAW, data)
            else
                uq.ModuleManager:getInstance():show(uq.ModuleManager.REWARD_PREVIEW_MODULE,{rewards = achieve.reward})
            end
        end)

        local box_x = box:getPositionX()
        local add_width = 0
        if i ~= 1 then
            add_width = width / 2
        end
        local data = {
            id = i,
            x = box_x + add_width,
        }
        table.insert(box_pos, data)
    end
    self._panelBox:removeFromParent()

    return box_pos
end

function AchievementMain:refreshBox()
    -- 宝箱刷新，宝箱移动，宝箱重复
    local end_id = self:getContinuityEndId()

    self._multiple = end_id - self._endId

    -- 进度条背景增加
    local size = self._imgProBg:getContentSize()
    local add_width = self._boxPos[5].x - self._boxPos[4].x
    self._imgProBg:setContentSize(cc.size(size.width + add_width * self._multiple, size.height))

    self:refreshUIBox()
    self:runNodeMove()
end

function AchievementMain:runNodeMove()
    local end_id = self:getContinuityEndId()
    if self._endId == end_id then
        return
    end

    self._endId = end_id
    local func1 = cc.CallFunc:create(handler(self, self.move))
    local func2 = cc.CallFunc:create(handler(self, self.testBox))
    self._nodePro:runAction(cc.Sequence:create(func1,cc.MoveBy:create(0.6 * self._multiple, cc.p(0, 0)) , func2, nil))
end

function AchievementMain:getContinuityEndId()
    -- 得到第一个宝箱的id
    local ids = self._curChapter.ids
    local prefix = self:getAchieveBoxIdPrefix()
    local end_id = self._achieve[prefix + 1].ident

    table.sort(ids, function(a, b)
        return a < b
    end)

    --没有已领取的宝箱或第一个宝箱未领取
    if #ids < 1 or ids[1] ~= end_id then
        return  end_id
    end

    for i = 2, #ids do
        --处于最后三个宝箱
        if not self._achieve[ids[i] + 2] then
            return end_id
        end

        --宝箱未连续，返回前一个宝箱id
        if ids[i] ~= ids[i - 1] + 1 then
            return end_id
        end

        end_id = ids[i]
    end
    return end_id
end

function AchievementMain:getRefreshBoxNum()
    -- 需要刷新宝箱的数量
    local prefix = self:getAchieveBoxIdPrefix()

    local count = 0
    for k, v in pairs(self._achieve) do
        count = count + 1
    end
    self._maxValue = self._achieve[prefix + count].value

    local num = count - (self._boxId - prefix)
    if num > 4 then
        num = 4
    end

    return num
end

function AchievementMain:refreshBoxMove()
    -- 添加宝箱
    local first_bos = self._box[1]
    table.remove(self._box, 1)
    table.insert(self._box, first_bos)
    self._box[5]:setPositionX(self._boxPos[5].x)
end

function AchievementMain:testBox()
    for i = 1, self._multiple do
        self:refreshBoxMove()
    end
    self:setBoxTag()
    self:refreshUIBox()
end

function AchievementMain:move()
    local dis = self._boxPos[5].x - self._boxPos[4].x
    self._nodePro:runAction(cc.MoveBy:create(0.6 * self._multiple, cc.p(-dis * self._multiple, 0)))
    for k, v in pairs(self._box) do
        v:runAction(cc.MoveBy:create(0.6 * self._multiple, cc.p(-dis * self._multiple, 0)))
    end
end

function AchievementMain:_onAchievementBoxShowReward(msg)
    for k,v in pairs(self._achieve) do
        if v.ident == msg.data then
            self:refreshBox()
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = v.reward})
            break
        end
    end
end

function AchievementMain:getAchieveBoxIdPrefix()
    local chapter_type = self._curAchievement['type']
    local achieve_id_prefix = 0
    if chapter_type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
        achieve_id_prefix = 10000 + self._curAchievement.ident * 100
    elseif chapter_type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.BRANCH then
        achieve_id_prefix = 20000 + (self._curAchievement.ident - 100) * 100
    end
    return achieve_id_prefix
end

function AchievementMain:getAchieveRange()
    local range = {}
    local num = self:getRefreshBoxNum() + 1
    for i = 1, num do
        range[i] = self._achieve[self._boxId + (i - 1)]
    end
    return range
end

function AchievementMain:setBoxTag()
    self._boxId = self:getContinuityEndId()

    for k, v in pairs(self._box) do
        v:setTag(self._boxId + (k - 1))
    end
end

function AchievementMain:refreshUIBox()
    --未达成
    self:initAchievedBoxFirst()
    --达成未领取
    self:achieveCompleteNotReceived()
    --已领取
    self:achieveBoxReceived()
end

function AchievementMain:handleAchieveBoxState(index, img, light_flag, state)
    local node = self._node:getChildByTag(index)
    node["userData"] = state
    node:setVisible(true)

    local box = node:getChildByName("Img_box")
    box:loadTexture(img)

    local light_node = node:getChildByName("Node_state")
    light_node:setVisible(light_flag)
    light_node:removeAllChildren()
    if light_flag then
        uq:addEffectByNode(light_node, 900098, -1, true)
    end

    local num = node:getChildByName("Text_num")
    local prefix = self:getAchieveBoxIdPrefix()
    local label_num = self._curAchievement['Achieve'][index].value
    num:setString(label_num)
end

function AchievementMain:initAchievedBoxFirst()
    --宝箱最开始的时候
    local num = self:getRefreshBoxNum()
    for i = self._boxId, self._boxId + num do
        local img = "img/common/ui/g03_0000845.png"
        self:handleAchieveBoxState(i, img, false, uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT)
    end
end

function AchievementMain:achieveBoxReceived()
    --已领取宝箱状态
    local ids = self:getIds()
    local prefix = self:getAchieveBoxIdPrefix()

    for k, v in pairs(ids) do
        local tag = v
        local img = "img/common/ui/g03_0000844.png"
        self:handleAchieveBoxState(tag, img, false, uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD)
    end
end

function AchievementMain:getIds()
    local prefix = self:getAchieveBoxIdPrefix()
    local start_index = self._boxId - prefix
    local num = self:getRefreshBoxNum()
    local ids = {}
    for i = start_index, start_index + num do
        if next(self._curChapter) and not self._curChapter.ids[i] then
            return ids
        end
        table.insert(ids, self._curChapter.ids[i])
    end
    return ids
end

function AchievementMain:achieveCompleteNotReceived()
    --达成未领取
    local percent = 0
    local range = self:getAchieveRange()
    local complete_num = self:getCompleteTaskNum()

    local is_completed = true
    for k, v in ipairs(range) do
        if complete_num < v.value then
            self:countAchievePercentCount(k - 1, k)
            self:showAchieveCompleteNotReceviedState(k - 1)
            is_completed = false
            break
        end
    end

    if is_completed then
        local size = self._imgProBg:getContentSize()
        local x = self._node:getPositionX()
        self._imgPro:setContentSize(cc.size(-x + self._boxPos[3].x, size.height))
        local pro_x = self._imgPro:getContentSize().width
        self._imgProHead:setPositionX(pro_x)
        self:showAchieveCompleteNotReceviedState(3)
    end

    self._txtCompletedNum:setString(complete_num)
    self._txtAllCompletedNum:setString(string.format(StaticData['local_text']['crop.campaign.boss.num'], self._maxValue))
end

function AchievementMain:showAchieveCompleteNotReceviedState(num)
    local index = self:getRefreshBoxNum()
    for i = 1, index + 1 do
        if num >= i then
            local img = "img/common/ui/g03_0000843.png"
            self:handleAchieveBoxState(self._boxId + (i - 1), img, true, uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED)
        end
    end
end

function AchievementMain:countAchievePercentCount(index1, index2)
    --计算百分比:由于不是均匀分布的所以计算每一段的百分比
    local range = self:getAchieveRange()
    local complete_num = self:getCompleteTaskNum()
    local percent = 0
    if index1 == 0 then
        percent = complete_num / range[index2].value
    else
        percent = (complete_num - range[index1].value) / (range[index2].value - range[index1].value)
    end

    self:setAchieveProPos(percent, index2)
end

function AchievementMain:setAchieveProPos(percent, section)
    local pro_x = 0
    local pos_x = self._imgPro:getPositionX()
    local node_x = self._nodePro:getPositionX()
    if section == 1 then
        pro_x = self:getAchieveProPos(self._boxPos[1].x, pos_x, percent)
    elseif section <= 5 then
        pro_x = self:getAchieveProPos(self._boxPos[section].x, self._boxPos[section - 1].x, percent)
    end

    local size = self._imgProBg:getContentSize()
    local width = pro_x - pos_x - node_x
    self._imgPro:setContentSize(cc.size(width, size.height))

    self._imgProHead:setVisible(false)
    self._imgPro:setVisible(false)
    if width > 0 then
        local x = self._imgPro:getContentSize().width
        self._imgProHead:setPositionX(x)
        self._imgProHead:setVisible(true)
        self._imgPro:setVisible(true)
    end
end

function AchievementMain:getAchieveProPos(pos_x, pos_x1, percent)
    local section_width = pos_x - pos_x1
    local pro_x = section_width * percent + pos_x1
    return pro_x
end

function AchievementMain:getCompleteTaskNum()
    local tasks = uq.cache.achievement._tasks
    local count = 0
    for k, v in pairs(tasks) do
        if v.chapter_id == self._curChapter.id then
            if v.state > uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
                count = count + 1
            end
        end
    end
    return count
end

function AchievementMain:showTaskRed()
    local size = self._panelMainTask:getContentSize()
    uq.showRedStatus(self._panelMainTask, self._mainTask.exist_reward, size.width / 2 - 20, size.height / 2 - 12)
    uq.showRedStatus(self._panelDailyTask, uq.cache.task._isExistTaskReward, size.width / 2 - 20, size.height / 2 - 12)

    if not self._chapters[1] then
        return
    end
    uq.showRedStatus(self._panelChapterTask, self._chapters[1].exist_reward, size.width / 2 - 20, size.height / 2 - 12)
end

function AchievementMain:_onAchievementOpen(msg)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.ACHIEVEMENT_CHAPTER_OPEN, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 10, moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(msg.data)
end

return AchievementMain
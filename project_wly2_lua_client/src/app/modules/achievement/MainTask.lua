local MainTask = class("MainTask", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

MainTask.RESOURCE_FILENAME = "achievement/MainTask.csb"
MainTask.RESOURCE_BINDING = {
    ["Image_bg"]                = {["varname"] = "_imgBg"},
    ["Panel_1"]                 = {["varname"] = "_panelContent"},
    ["Text_1"]                  = {["varname"] = "_txtChapterNum"},
    ["Image_5"]                 = {["varname"] = "_imgChapterName"},
    ["Panel_reward"]            = {["varname"] = "_panelReward"},
    ["Sprite_4"]                = {["varname"] = "_spriteReward"},
    ["Button_exit"]             = {["varname"] = "_btnExit",["events"] = {{["event"] = "touch",["method"] = "onClose",["sound_id"] = 0}}},
    ["Button_reward"]           = {["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
}
function MainTask:ctor(name, params)
    MainTask.super.ctor(self, name, params)

    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
    self:setTouchClose(false)
end

function MainTask:onCreate()
    MainTask.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_ACHIEVEMENT_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_REFRESH, handler(self, self.refreshTask), self._eventTag)

    self._eventTag1 = services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH, handler(self, self.refreshBoundary), self._eventTag)

    self._eventTag2 = services.EVENT_NAMES.ON_ACHIEVEMENT_BOX_SHOW_REWARD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_BOX_SHOW_REWARD, handler(self, self._onAchievementBoxShowReward), self._eventTag2)
end

function MainTask:init()
    self:setLayerColor()
    self:centerView()
    self:parseView()

    local ShaderEffect = uq.ShaderEffect
    ShaderEffect:addGrayNode(self._spriteReward)

    self._achievement = StaticData['achievements']
    self._taskSearch = uq.cache.achievement._taskSearch

    self:initTaskContentList()
    self:refreshTask()
end

function MainTask:refreshTask()
    self._mainTask = uq.cache.achievement._mainTask
    self._curAchievement = self:getChapterData(self._mainTask.id)
    if not self._curAchievement then
        uq.log("not_find_acheivement", self._mainTask)
        return
    end
    self._achieve = self._curAchievement['Achieve']
    self._allCurTask = self._mainTask.tasks
    self:getMeetConditionsData()

    self._txtChapterNum:setString(self._curAchievement.des)

    self:refreshChapter()
    self:refreshBoundary()
end

function MainTask:refreshChapter()
    local reward_id = 10000 + self._curAchievement.ident * 100 + 1
    local reward = self._achieve[reward_id]['reward']
    self._panelReward:removeAllChildren()
    local item_list = uq.checkRewardsByCountry(reward)
    for i, v in ipairs(item_list) do
        local equip_item = EquipItem:create({info = v})
        self._panelReward:addChild(equip_item)
        equip_item:setScale(0.7)
        local size = equip_item:getBgContentSize()
        equip_item:setPosition(cc.p((size.width - 10) * (i - 1) + size.width / 2, size.height / 2 - 5))
        equip_item:setTouchEnabled(true)
        equip_item:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        equip_item:setSwallowTouches(false)
    end
end

function MainTask:refreshBoundary()
    self:sortCurTask()
    self:refreshChapterReward()
    self._listViewContent:reloadData()
end

function MainTask:sortCurTask()
    local sort_table = {2, 3, 1}
    table.sort(self._curTask, function(a, b)
        if a.state == b.state then
            return a.id < b.id
        end
        return sort_table[a.state + 1] > sort_table[b.state + 1]
    end)
end

function MainTask:refreshChapterReward()
    local count, finished_num = self:getTaskLen()
    self._spriteReward:setVisible(true)
    self._btnReward:setVisible(false)
    if count <= finished_num and self:getHaveMainTask() == true then
        self._spriteReward:setVisible(false)
        self._btnReward:setVisible(true)
    end
end

function MainTask:_onAchievementBoxShowReward(msg)
    for k,v in pairs(self._achieve) do
        if v.ident == msg.data then
            local rewards = uq.checkRewardsByCountry(v.reward)
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = rewards})
            break
        end
    end
end

function MainTask:onGetReward(event)
    if event.name ~= "ended" then
        return
    end
    local reward_id = 10000 + self._curAchievement.ident * 100 + 1
    local data = {
        id = reward_id,
        chapter_id = self._curAchievement['ident'],
        rwd_type = uq.config.constant.TYPE_ACHIEVEMENT_REWARD.BOX
    }
    network:sendPacket(Protocol.C_2_S_ACHIEVEMENT_DRAW, data)
end

function MainTask:getChapterData(id)
    return self._achievement[id]
end

function MainTask:getMeetConditionsData()
    self._curTask = {}
    for k, v in pairs(self._allCurTask) do
        local info = self._curAchievement['Task'][v.id]
        local data = 0
        if info then
            data = info['preTask']
        end
        if data == 0 then
            table.insert(self._curTask, v)
        elseif self._taskSearch[data].state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
            table.insert(self._curTask, v)
        end
    end
end

function MainTask:initTaskContentList()
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

function MainTask:tableCellTouchedContent(view, cell)
    local index = cell:getIdx() + 1
end

function MainTask:cellSizeForTableContent(view, idx)
    return 696, 80
end

function MainTask:numberOfCellsInTableViewContent(view)
    local num = self:getTaskLen()
    return num
end

function MainTask:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("achievement.TaskCell")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setPosition(cc.p(25, 55))

    local xml_data = self:getXmlData(self._curTask[index].id)
    local cache_data = self:getCacheData(self._curTask[index].id)
    if xml_data ~= nil and cache_data ~= nil then
        cell_item:setData(xml_data, cache_data)
    end

    return cell
end

function MainTask:getTaskLen()
    local count = 0
    local finished_num = 0
    for k, v in pairs(self._curTask) do
        count = count + 1
        if v.state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
            finished_num = finished_num + 1
        end
    end
    return count, finished_num
end

function MainTask:getHaveMainTask()
    local tasks = uq.cache.achievement._tasks
    for k,v in pairs(tasks) do
        if self._achievement[v.chapter_id].type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
            return true
        end
    end
    return false
end

function MainTask:getCacheData(id)
    local tasks = uq.cache.achievement._tasks
    for k,v in pairs(tasks) do
        if v.id == id then
            return v
        end
    end

    for k,v in pairs(self._curTask) do
        if v.id == id then
            return v
        end
    end
    return
end

function MainTask:getXmlData(id)
    return self._curAchievement['Task'][id]
end

function MainTask:onClose(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
    self:disposeSelf()
end

function MainTask:dispose()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventTag2)

    MainTask.super.dispose(self)
end

return MainTask
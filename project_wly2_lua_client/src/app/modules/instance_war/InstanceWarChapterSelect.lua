local InstanceWarChapterSelect = class("InstanceWarChapterSelect", require('app.base.ModuleBase'))

InstanceWarChapterSelect.RESOURCE_FILENAME = "instance_war/ChapterSelect.csb"
InstanceWarChapterSelect.RESOURCE_BINDING = {
    ["Button_3"]       = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Text_2"]         = {["varname"] = "_txtDesc"},
    ["Panel_1"]        = {["varname"] = "_panelBg"},
    ["Node_1"]         = {["varname"] = "_nodeCity"},
    ["Node_2"]         = {["varname"] = "_nodeRightTop"},
    ["Text_1"]         = {["varname"] = "_txtTitle"},
    ["drop_item_list"] = {["varname"] = "_dropList"},
    ["Button_15"]      = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function InstanceWarChapterSelect:init()
    self:centerView()
    self:parseView()
    self:adaptNode()

    self._curInstanceId = 101
    self._itemNum = table.nums(StaticData['instance_war'])
    self._txtDesc:getVirtualRenderer():setLineSpacing(5)
    self:createList()
    self:refreshInstanceSelect()
end

function InstanceWarChapterSelect:refreshInstanceSelect()
    self._curInstanceData = StaticData['instance_war'][self._curInstanceId]
    self._curMapData = StaticData.load('campaigns/' .. self._curInstanceData.fileId).Map[self._curInstanceId]

    self._txtTitle:setString(self._curInstanceData.name)

    for k, item in pairs(self._curMapData.Object) do
        local img_bg = self._nodeCity:getChildByName('b' .. item.city)
        local img_select = self._nodeCity:getChildByName('s' .. item.city)
        if img_bg then
            if item.power == 1 then
                img_select:setVisible(true)
            else
                img_select:setVisible(false)
            end
            img_bg:setVisible(true)
            img_bg:setOpacity(127.5)
            img_bg:setColor(uq.parseColor(StaticData['instance_power'][item.power].color))
        end
    end
    self._txtDesc:setString(self._curMapData.desc)

    local reward_result = {}
    local instance_data = StaticData['instance_war'][self._curInstanceId]
    local map_data = StaticData.load('campaigns/' .. instance_data.fileId).Map[self._curInstanceId]
    if uq.cache.instance_war:isInstancePassed(self._curInstanceId) then
        reward_result = string.split(map_data.firstReward, '|')
    else
        reward_result = string.split(map_data.Reward, '|')
    end

    self._dropList:setScrollBarEnabled(false)
    for k, item_str in ipairs(reward_result) do
        local panel = uq.createPanelOnly('instance.DropItem')
        panel:setData(item_str)
        panel:setSwallow(false)
        local size = panel:getContentSize()
        panel:setPosition(cc.p(size.width / 2 + 10, size.height / 2 - 8))
        panel:setGameMode(uq.config.constant.GAME_MODE.INSTANCE_WAR)
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(size.width + 20, size.height))
        widget:addChild(panel)
        widget:setTouchEnabled(true)
        self._dropList:pushBackCustomItem(widget)
    end
end

function InstanceWarChapterSelect:onCreate()
    InstanceWarChapterSelect.super.onCreate(self)
end

function InstanceWarChapterSelect:onExit()
    InstanceWarChapterSelect.super.onExit(self)
end

function InstanceWarChapterSelect:createList()
    local viewSize = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBg:addChild(self._listView)
end

function InstanceWarChapterSelect:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    self._curInstanceId = index + 100
    self:refreshInstanceSelect()
end

function InstanceWarChapterSelect:cellSizeForTable(view, idx)
    return 173, 163
end

function InstanceWarChapterSelect:numberOfCellsInTableView(view)
    return self._itemNum
end

function InstanceWarChapterSelect:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance_war.InstanceWarChapterSelectItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    -- cell_item:setIndex(index)
    cell_item:setData(index)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function InstanceWarChapterSelect:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarChapterSelect:onConfirm(event)
    if event.name ~= 'ended' then
        return
    end

    local can_click = false
    local instance_data = StaticData['instance_war'][self._curInstanceId]
    if uq.cache.instance_war:isInstancePassed(self._curInstanceId) then
        can_click = true
    elseif not instance_data.parent or uq.cache.instance_war:isInstancePassed(instance_data.parent.ident) then
        can_click = true
    else
        can_click = false
    end

    if not can_click then
        uq.fadeInfo('章节未开启')
    else
        local function confirm()
            local map_data = StaticData.load('campaigns/' .. instance_data.fileId).Map[self._curInstanceId]
            local cost = string.split(map_data.cost, ';')
            if not uq.cache.role:checkRes(tonumber(cost[1]), tonumber(cost[2])) then
                uq.fadeInfo('军令不足')
                return
            end
            network:sendPacket(Protocol.C_2_S_CAMPAIGN_CHALLENGE, {campaign_id = self._curInstanceId})
        end

        local str = '挑战当前章节消耗20军令，是否挑战当前章节？'
        local data = {
            content = str,
            confirm_callback = confirm,
        }
        uq.addConfirmBox(data)
    end
end

return InstanceWarChapterSelect
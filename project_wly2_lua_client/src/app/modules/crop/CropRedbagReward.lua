local CropRedbagReward = class("CropRedbagReward", require('app.base.PopupBase'))

CropRedbagReward.RESOURCE_FILENAME = "crop/CropRedbagReward.csb"
CropRedbagReward.RESOURCE_BINDING = {
    ["Text_3"]       = {["varname"] = "_txtDescribe"},
    ["Panel_1"]      = {["varname"] = "_panelReward"},
    ["Button_2"]     = {["varname"] = "_btnReset",["events"] = {{["event"] = "touch",["method"] = "onReset"}}},
}

function CropRedbagReward:ctor(name, params)
    CropRedbagReward.super.ctor(self, name, params)
end

function CropRedbagReward:init()
    self._rewardData = StaticData['legion_envelopes']

    self:centerView()
    self:parseView()
    self:createRichText()
    self:initRewardList()
end

function CropRedbagReward:createRichText()
    local size = self._txtDescribe:getContentSize()
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0, 1))
    self._richText:setDefaultFont("font/hwkt.ttf")
    self._richText:setFontSize(24)
    self._richText:setContentSize(cc.size(size.width, size.height))
    self._richText:setMultiLineMode(true)
    self._richText:setTextColor(uq.parseColor("#FEFDDD"))
    self._richText:ignoreContentAdaptWithSize(false)
    self._richText:setPosition(cc.p(-150, 185))
    self._richText:setText(StaticData['material'][7]['desc'])
    self._txtDescribe:addChild(self._richText)
end

function CropRedbagReward:initRewardList()
    local viewSize = self._panelReward:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelReward:addChild(self._listView)
end

function CropRedbagReward:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CropRedbagReward:cellSizeForTable(view, idx)
    return 410, 110
end

function CropRedbagReward:numberOfCellsInTableView(view)
    return 8
end

function CropRedbagReward:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("crop.CropRedbagRewardCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(self:getRewardData(index))

    return cell
end

function CropRedbagReward:getRewardData(index)
    local rewards = {}
    local start_index = (index - 1) * 4 + 1
    local end_index = start_index + 3
    if end_index > 30 then
        end_index = 30
    end

    for i = start_index, end_index do
        table.insert(rewards, self._rewardData[i])
    end

    return rewards
end

function CropRedbagReward:onReset(event)
    if event.name ~= "ended" then
        return
    end

    self:disposeSelf()
end

return CropRedbagReward
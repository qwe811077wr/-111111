local EquipItem = require("app.modules.common.EquipItem")
local AncientCitySweepItem = class("AncientCitySweepItem", function()
    return ccui.Layout:create()
end)

function AncientCitySweepItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self._name = args and args.name or ""
    self:init()
end

function AncientCitySweepItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCitySweepItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._desLabel = self._view:getChildByName("lbl_des");
    self._panelTableView = self._view:getChildByName("Panel_tabview");
    self:initTableView()
    self:initInfo()
end

function AncientCitySweepItem:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView1 = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView1:setPosition(cc.p(0, 0))
    self._tableView1:setAnchorPoint(cc.p(0,0))
    self._tableView1:setDelegate()
    self._panelTableView:addChild(self._tableView1)

    self._tableView1:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView1:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function AncientCitySweepItem:cellSizeForTable(view, idx)
    return 100, 100
end

function AncientCitySweepItem:numberOfCellsInTableView(view)
    return #self._curRewardInfo
end

function AncientCitySweepItem:tableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local info = self._curRewardInfo[index]
    uq.showItemTips(info)
end

function AncientCitySweepItem:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curRewardInfo[index]
        local euqip_item = nil
        if info ~= nil then
            euqip_item = EquipItem:create({info = info})
            euqip_item:setScale(0.7)
            local width = euqip_item:getContentSize().width * 0.7
            euqip_item:setPosition(cc.p(width * 0.5,45))
            cell:addChild(euqip_item,1)
            euqip_item:setName("item")
        end
    else
        local info = self._curRewardInfo[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
        end
    end
    return cell
end

function AncientCitySweepItem:setInfo(info, name)
    self._info = info
    self._name = name or ""
    self:initInfo()
end

function AncientCitySweepItem:initInfo()
    self._curRewardInfo = uq.RewardType:tabMergeReward(self._info.rewards)
    local str = string.format(StaticData['local_text']['ancient.name.card'], self._name,self._info.ident)
    if self._info.ident == 7 then
        str = StaticData['local_text']['ancient.secret.title']
    end
    self._desLabel:setHTMLText(str)
    self._tableView1:reloadData()
end

function AncientCitySweepItem:getInfo()
    return self._info
end

return AncientCitySweepItem
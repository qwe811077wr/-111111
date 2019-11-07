local RoleHead = class("RoleHead", require('app.base.PopupBase'))

RoleHead.RESOURCE_FILENAME = "role/RoleHead.csb"
RoleHead.RESOURCE_BINDING = {
    ["Panel_4"] = {["varname"] = "_pnlDown"},
    ["Text_4"]  = {["varname"] = "_txtDesc"},
}

function RoleHead:onCreate()
    RoleHead.super.onCreate(self)

    self._cellNum = 4
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    self._heroList = self:getHeroTab()
    self:createList()
    self._txtDesc:setHTMLText(StaticData['local_text']['label.role.desc'])
end

function RoleHead:createList()
    local view_size = self._pnlDown:getContentSize()
    self._listViewDown = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listViewDown:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listViewDown:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listViewDown:setPosition(cc.p(0, 0))
    self._listViewDown:setAnchorPoint(cc.p(0,0))
    self._listViewDown:setDelegate()
    self._listViewDown:registerScriptHandler(handler(self, self.tableCellTouchedDown), cc.TABLECELL_TOUCHED)
    self._listViewDown:registerScriptHandler(handler(self, self.cellSizeForTableDown), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listViewDown:registerScriptHandler(handler(self, self.tableCellAtIndexDown), cc.TABLECELL_SIZE_AT_INDEX)
    self._listViewDown:registerScriptHandler(handler(self, self.numberOfCellsInTableViewDown), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listViewDown:reloadData()
    self._pnlDown:addChild(self._listViewDown)
end

function RoleHead:tableCellTouchedDown(view, cell, touch)
end

function RoleHead:cellSizeForTableDown(view, idx)
    return 622, 130
end

function RoleHead:tableCellAtIndexDown(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 1, self._cellNum do
            local euqip_item = uq.createPanelOnly("role.HeadItem")
            euqip_item:setAnchorPoint(cc.p(0, 0))

            local width  = euqip_item:getContentSize().width
            euqip_item:setPosition(cc.p(width * 0.5 + (width + 22) * (i - 1) + 40, 55))
            euqip_item:setName("item" .. i)
            cell:addChild(euqip_item)
            euqip_item:setVisible(false)
        end
    end

    local index = idx * self._cellNum + 1
    for i = 1, self._cellNum do
        local info = self._heroList[index]
        local euqip_item = cell:getChildByName("item" .. i)
        if info then
            euqip_item:setData(info, handler(self, self.touchCall))
            euqip_item:setVisible(true)
        else
            euqip_item:setVisible(false)
        end
        index = index + 1
    end
    return cell
end

function RoleHead:touchCall()
    self:disposeSelf()
end

function RoleHead:numberOfCellsInTableViewDown(view)
    if self._heroList then
        return math.ceil(#self._heroList / self._cellNum)
    else
        return 0
    end
end

function RoleHead:getHeroTab()
    local tab = {}

    for k, v in pairs(StaticData['majesty_heads']) do
        table.insert(tab, {temp_id = v.type, head_id = v.ident, head_type = uq.config.constant.HEAD_TYPE.NORMAL})
    end

    local tab_genera = uq.cache.generals:getAllGeneralData()
    for k, v in pairs(tab_genera) do
        if v.temp_id ~= StaticData['majesty_heads'][1].type then
            local xml_data = uq.cache.generals:getGeneralDataXML(v.temp_id)
            if xml_data.isWujiang == 1 and xml_data.isJiuguan == 0 then
                table.insert(tab, {temp_id = v.temp_id, head_id = v.temp_id, head_type = uq.config.constant.HEAD_TYPE.GENERAL})
            end
        end
    end

    local scoceAll = function (data)
        local score = 0
        if uq.cache.role:isMyHeadEqual(data.head_id, data.head_type) then
            score = score + 10000
        end
        local xml = StaticData['general'][data.temp_id]
        if data.head_type == uq.config.constant.HEAD_TYPE.NORMAL then
            score = score + 1000
        elseif data.head_type == uq.config.constant.HEAD_TYPE.GENERAL and xml.qualityType >= 2 then
            score = score + 5000
        end
        return score
    end

    table.sort(tab, function(a, b)
        return scoceAll(a) > scoceAll(b)
    end)

    return tab
end
return RoleHead
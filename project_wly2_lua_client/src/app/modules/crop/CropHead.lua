local CropHead = class("CropHead", require('app.base.PopupBase'))

CropHead.RESOURCE_FILENAME = "crop/CropHead.csb"
CropHead.RESOURCE_BINDING = {
    ["icon_spr"]                    = {["varname"] = "_sprIcon"},
    ["Panel_1"]                     = {["varname"] = "_pnlList"},
    ["Button_1"]                    = {["varname"] = "_btnOk"},
    ["bg_spr"]                      = {["varname"] = "_sprBg"},
    ["Button_2"]                    = {["varname"] = "_btnClose"},
}

function CropHead:ctor(name, params)
    CropHead.super.ctor(self, name, params)
    self._iconId = params and params.icon_id or 1
    self._func = params and params.func
    self._isCreate = params and params.is_create
end

function CropHead:init()
    self:centerView()
    self:setLayerColor()
    self:parseView()
    self._listDate = self:dealData()
    self._rowNum = 5
    self._allUiList = {}
    self:initLayer()
end

function CropHead:initLayer()
    self:refreshIcon()
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, -20))
    self._listView:setAnchorPoint(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)
    self._btnOk:addClickEventListenerWithSound(function()
        if uq.cache.role.cropsId ~= 0 then
            uq.cache.crop._cropIconId = self._iconId
            self:sendMsgChangeHead()
        end
        if self._func then
            self._func(self._iconId)
        end
        self:disposeSelf()
    end)
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
end

function CropHead:refreshIcon()
    local icon_bg, icon_icon = uq.cache.crop:getCropIcon(self._iconId)
    if icon_bg ~= "" then
        self._sprIcon:setTexture(icon_icon)
        self._sprBg:setTexture(icon_bg)
    end
end

function CropHead:refreshBoxs()
    for k, v in pairs(self._allUiList) do
        v:refreshSelected(self._iconId)
    end
end

function CropHead:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    if not self._listDate[index] then
        return
    end
    if self._listDate[index].level > uq.cache.crop:getCropLevel() and not self._isCreate then
        uq.fadeInfo(string.format(StaticData["local_text"]["crop.level.open"], self._listDate[index].level))
        return
    end
    self._iconId = index
    self:refreshIcon()
    self:refreshBoxs()
end

function CropHead:cellSizeForTable(view, idx)
    return 120, 100
end

function CropHead:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = uq.createPanelOnly("crop.CropHeadIcon")
        cell:addChild(cell_item)
        cell_item:setTag(1000)
        table.insert(self._allUiList, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setData(self._listDate[index], self._iconId)
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function CropHead:numberOfCellsInTableView(view)
    return #self._listDate
end

function CropHead:dealData()
    if not self._isCreate then
        return StaticData['legion_heads'] or {}
    end
    local tab = {}
    for i, v in ipairs(StaticData['legion_heads']) do
        if v.level == 0 then
            table.insert(tab, v)
        end
    end
    return tab
end

function CropHead:sendMsgChangeHead()
    network:sendPacket(Protocol.C_2_S_CROP_UPDATE_HEAD_ID, {head_id = self._iconId})
end

return CropHead
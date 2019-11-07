local GeneralAttributeModule = class("GeneralAttributeModule", require('app.base.PopupBase'))

GeneralAttributeModule.RESOURCE_FILENAME = "generals/GeneralsAttributeModule.csb"
GeneralAttributeModule.RESOURCE_BINDING = {
    ["Panel_5"]                         = {["varname"] = "_panelTableView"},
    ["Node_4"]                          = {["varname"] = "_nodeItems"},
    ["Image_22"]                        = {["varname"] = "_nodeItemBg"},
    ["Text_24"]                         = {["varname"] = "_txtTitle"},
    ["Text_25"]                         = {["varname"] = "_txtBase"},
    ["Panel_3"]                         = {["varname"] = "_panelDes1"},
    ["Panel_4"]                         = {["varname"] = "_panelDes2"},
    ["Text_27"]                         = {["varname"] = "_txtDes1"},
    ["Text_28"]                         = {["varname"] = "_txtDes2"},
}

function GeneralAttributeModule:ctor(name, params)
    self._generalId = params.id
    GeneralAttributeModule.super.ctor(self, name, params)
end

function GeneralAttributeModule:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initData()
    self._nodeItems:setVisible(false)
    services:addEventListener(services.EVENT_NAMES.ON_GET_GENERAL_ATTR, handler(self, self.initData), 'ON_GET_GENERAL_INFO' .. tostring(self))
end

function GeneralAttributeModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(handler(self,self.scrollScriptScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
end

function GeneralAttributeModule:initData()
    local data = uq.cache.generals:getGeneralAttrById(self._generalId)
    if not data then
        return
    end
    self._allXmlData = StaticData['general_effect']
    for i = 1, #self._allXmlData - 1 do
        for k, v in ipairs(self._allXmlData[i].List) do
            local value = data[v.effectType] or 0
            v.value = value
        end
    end
    self._tableView:reloadData()
end

function GeneralAttributeModule:scrollScriptScroll()
    if self._nodeItems:isVisible() then
        self._nodeItems:setVisible(false)
    end
end

function GeneralAttributeModule:cellSizeForTable(view, idx)
    local index = idx + 1
    local num = #self._allXmlData[index].List
    return 430, 50 + 43 * num
end

function GeneralAttributeModule:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly('generals.GeneralAttributeItem')
        item:setCallBack(handler(self, self.showRightLayer))
        item:setName("item")
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
    end
    local size_x, size_y = self:cellSizeForTable(view, idx)
    item:setPositionY(size_y)
    item:setInfo(self._allXmlData[index])
    return cell
end

function GeneralAttributeModule:numberOfCellsInTableView()
    return #self._allXmlData - 1
end

function GeneralAttributeModule:showRightLayer(info)
    local pos = self:convertToNodeSpace(info.pos)
    self._nodeItems:setPositionY(pos.y)
    self._nodeItems:setVisible(true)
    self._txtDes1:setContentSize(cc.size(293, 40))
    self._txtDes2:setContentSize(cc.size(293, 40))
    self._txtTitle:setString(info.name)
    self._txtDes1:setHTMLText(info.desc, nil, nil, nil, true)
    local des_size1 = self._txtDes1:getContentSize()
    local size = self._panelDes1:getContentSize()
    self._panelDes1:setContentSize(cc.size(size.width, des_size1.height + 20))
    self._txtDes1:setPositionY(des_size1.height + 10)
    local pos_y = self._panelDes1:getPositionY()

    self._txtDes2:setHTMLText(info.way)
    local des_size2 = self._txtDes2:getContentSize()
    self._panelDes2:setContentSize(cc.size(size.width, des_size2.height + 20))
    self._txtDes2:setPositionY(des_size2.height + 10)
    self._panelDes2:setPositionY(pos_y - des_size1.height - 25)
    local pos_y1 = self._panelDes2:getPositionY()

    local bg_size = self._nodeItemBg:getContentSize()
    self._nodeItemBg:setContentSize(cc.size(bg_size.width, -pos_y1 + des_size2.height + 40))

    local value = uq.cache.generals:getNumByEffectType(info.effectType, info.value)
    self._txtBase:setString(value)
end

function GeneralAttributeModule:dispose()
    services:removeEventListenersByTag('ON_GET_GENERAL_INFO' .. tostring(self))
    GeneralAttributeModule.super.dispose(self)
end

return GeneralAttributeModule
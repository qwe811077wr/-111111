local GMView = class("GMView", require('app.base.PopupBase'))
local GMViewItem = require("app.modules.gm.GMViewItem")

GMView.RESOURCE_FILENAME = "gm/GMView.csb"
GMView.RESOURCE_BINDING = {
    ["Panel_soldier"]                   = {["varname"] = "_panelTabView"},
    ["Node_data"]                       = {["varname"] = "_nodeData"},
    ["ScrollView_1"]                    = {["varname"] = "_scrollView"},
    ["Button_btn1"]                     = {["varname"] = "_btnDes1"},
    ["Panel_type"]                      = {["varname"] = "_panelData"},
    ["Panel_3"]                         = {["varname"] = "_panelOk"},
    ["Panel_2"]                         = {["varname"] = "_panelSelect"},
    ["Button_cancel"]                   = {["varname"] = "_btnCancel",["events"] = {{["event"] = "touch",["method"] = "_onBtnCancel"}}},
    ["Button_select"]                   = {["varname"] = "_btnSelect",["events"] = {{["event"] = "touch",["method"] = "_onBtnSelect"}}},
    ["Button_ok"]                       = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["Button_all"]                      = {["varname"] = "_btnAll",["events"] = {{["event"] = "touch",["method"] = "onBtnAll"}}},
    ["btn_close"]                       = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
}

function GMView:ctor(name, params)
    GMView.super.ctor(self, name, params)
    self:centerView()
    self._dataArray = {}
    self._allDataArray = {}
    self._itemArray = {}
    self._searchIdent = -2   --全选是-1, 都不选是-2
    self._curInfo = nil
    self._urlArray = {
        "http://" .. uq.cache.server.address .. ":9231/rest/admin/build?accid=" .. uq.cache.role.id,
        "http://" .. uq.cache.server.address .. ":9231/rest/admin/role?accid=" .. uq.cache.role.id,
        "http://" .. uq.cache.server.address .. ":9231/rest/admin/role?accid=" .. uq.cache.role.id,
    }
end

function GMView:init()
    self:initDialog()
end

function GMView:_onBtnCancel(event)
    if event.name ~= "ended" then
        return
    end
    self._panelData:setVisible(false)
    self._nodeData:setVisible(true)
end

function GMView:_onBtnSelect(event)
    if event.name ~= "ended" then
        return
    end
    local search = self._editBoxSearch:getText()
    if search and search ~= "" then
        self._searchIdent = tonumber(search)
    end
    self._editBoxSearch:setText("")
    self:updateData()
end

function GMView:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    local num_str = self._editBoxNum:getText()
    if num_str == nil or num_str == "" then
        num_str = "1"
    end
    self._editBoxNum:setText("")
    for k, v in ipairs(self._dataArray) do
        if v.state then
            local url = self._urlArray[self._curInfo.type]
            if self._curInfo.type == 1 then
                url = url .. string.format("&op=update&id=%s&level=%s", v.ident, num_str)
            elseif self._curInfo.type == 2 then
                url = url .. string.format("&op=update&res_str=%s%s%s%s%s", v.type, "%3B", num_str, "%3B", v.ident)
            end
            uq.http_request('GET', url, nil, nil)
        end
    end
end

function GMView:onBtnAll(event)
    if event.name ~= "ended" then
        return
    end
    if self._searchIdent == -1 then
        self._searchIdent = -2
    else
        self._searchIdent = -1
    end
    self:updateData()
end

function GMView:initDialog()
    self._panelData:setVisible(false)
    self._btnDes1:removeSelf()
    local btn_size = self._btnDes1:getContentSize()
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #StaticData['gm_instruction']
    local inner_height = index * (btn_size.height +  5)
    if inner_height < item_size.height then
        inner_height = item_size.height
    end
    self._scrollView:setInnerContainerSize(cc.size(item_size.width, inner_height))

    local pos_y = inner_height - btn_size.height * 0.5
    for k, v in ipairs(StaticData['gm_instruction']) do
        local btn = self._btnDes1:clone()
        btn:setTouchEnabled(true)
        btn['info'] = v
        self._scrollView:addChild(btn)
        btn:setPosition(cc.p(btn_size.width * 0.5 + 28 , pos_y))
        pos_y = pos_y - self._btnDes1:getContentSize().height - 5
        btn:getChildByName("Text_des"):setString(v.name)
        btn:addClickEventListener(function(sender)
            self._nodeData:setVisible(false)
            self._panelData:setVisible(true)
            self._curInfo = sender['info']
            self._allDataArray = self._curInfo.Object
            self:updateData()
        end)
    end
    local size = self._panelSelect:getContentSize()
    self._editBoxSearch = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxSearch:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxSearch:setFontName("font/hwkt.ttf")
    self._editBoxSearch:setFontSize(30)
    self._editBoxSearch:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxSearch:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxSearch:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self._editBoxSearch:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxSearch:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxSearch:setPlaceholderFontSize(30)
    self._editBoxSearch:setMaxLength(20)
    self._editBoxSearch:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._editBoxSearch:setPlaceHolder(StaticData["local_text"]["gm.search.des1"])
    self._editBoxSearch:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._panelSelect:addChild(self._editBoxSearch)

    local size = self._panelOk:getContentSize()
    self._editBoxNum = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxNum:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxNum:setFontName("font/hwkt.ttf")
    self._editBoxNum:setFontSize(30)
    self._editBoxNum:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxNum:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxNum:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self._editBoxNum:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxNum:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxNum:setPlaceholderFontSize(30)
    self._editBoxNum:setMaxLength(20)
    self._editBoxNum:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._editBoxNum:setPlaceHolder(StaticData["local_text"]["gm.search.des2"])
    self._editBoxNum:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._panelOk:addChild(self._editBoxNum)
    self:initTableView()
end

function GMView:editboxHandle(event, sender)
    if event == 'changed' or event == 'ended' or event == 'return' then
        local str = sender:getText()
        local astr = string.match(str, "%d+")
        sender:setText(astr)
    end
end

function GMView:updateData()
    self._dataArray = {}
    if self._searchIdent == -2 then
        for k, v in pairs(self._allDataArray) do
            v.state = false
            table.insert(self._dataArray, v)
        end
    elseif self._searchIdent == -1 then
        for k, v in pairs(self._allDataArray) do
            v.state = true
            table.insert(self._dataArray, v)
        end
    else
        for k, v in pairs(self._allDataArray) do
            v.state = false
            if v.ident == self._searchIdent then
                v.state = true
                table.insert(self._dataArray, v)
            end
        end
    end
    self._tableView:reloadData()
end

function GMView:initTableView()
    local size = self._panelTabView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelTabView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GMView:cellSizeForTable(view, idx)
    return 515, 40
end

function GMView:numberOfCellsInTableView(view)
    return #self._dataArray
end

function GMView:tableCellTouched(view, cell, touch)
end

function GMView:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = GMViewItem:create()
        cell_item:setName("item")
        cell:addChild(cell_item)
        local width = cell_item:getContentSize().width
        table.insert(self._itemArray, cell_item)
    else
        cell_item = cell:getChildByName("item")
    end
    local info = self._dataArray[index]
    if cell_item then
        cell_item:setInfo(info)
    end
    return cell
end

function GMView:dispose()
    GMView.super.dispose(self)
end

return GMView
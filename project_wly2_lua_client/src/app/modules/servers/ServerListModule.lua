local ServerListModule = class("ServerListModule", require('app.modules.common.BaseViewWithHead'))

function ServerListModule:ctor(name, params)
    ServerListModule.super.ctor(self, name, params)
    self._oftenServer = params.often_server or {}
end

function ServerListModule:init()
    self:setView(cc.CSLoader:createNode("server_list/ServerList.csb"))
    self:parseView()
    self._pnlList = self._view:getChildByName('Panel_2')
    self._pnlTop = self._view:getChildByName('Panel_3')

    self._pnlLeft = self._pnlList:getChildByName('left_pnl')
    self._pnlLeft:addEventListener(handler(self, self._itemSelectLeft))
    self._pnlRight = self._pnlList:getChildByName('right_pnl')
    self._pnlTableView = self._pnlList:getChildByName('right_pnl1')

    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:setTitle(uq.config.constant.MODULE_ID.SERVER_LIST)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self._serverType = 1
    self._uiLeft = {}
    self._serverData = {}
    self._allServerInfo = {}
    self._sid = uq.cache.server.sid
    self._typeServer = StaticData['types'].ServerList[1].Type

    self:dealServerData()
    self:initLeftLayer()
    self:initRightLayer()
    self:selectServerType(self._serverType)
    self:refreshRightList()
    self:adaptBgSize()
end

function ServerListModule:_sendFinishMsg(data)
    uq.cache.server = data
    services:dispatchEvent({name = "OnServerChanged", data = {} })
    --为了解决事件传递问题暂时使用的方法(待修改)
    self._pnlList:runAction(cc.CallFunc:create(function() self:disposeSelf() end))
end
--left
function ServerListModule:_itemSelectLeft(list, evt)
    if evt ~= 1 then
        return
    end
    local list = self._pnlLeft
    local server = self._typeServer
    local idx = list:getCurSelectedIndex()
    if idx < 0 then
        return
    end
    if not server[idx + 1] then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    self:selectServerType(idx + 1)
end

function ServerListModule:selectServerType(serverType)
    for k, v in pairs(self._uiLeft) do
        v:getChildByName('Image_9'):setVisible(k == serverType)
        v:getChildByName('Image_8'):setVisible(k ~= serverType)
    end
    self._serverType = serverType
    if serverType ~= 1 then
        self._listView:reloadData()
    end
    self._pnlTableView:setVisible(serverType ~= 1)
    self._pnlRight:setVisible(serverType == 1)
end

function ServerListModule:initLeftLayer()
    local list = self._pnlLeft
    list:removeAllItems()
    list:setScrollBarEnabled(false)
    for i = 1, #self._typeServer, 1 do
        local v = self._typeServer[i]
        local item_temp = cc.CSLoader:createNode('server_list/ListItem.csb')
        local item = item_temp:getChildByName('list_pnl')
        item:removeFromParent()
        local img_bg = item:getChildByName('Image_8')
        local img_show = item:getChildByName('Image_9')
        img_bg:getChildByName('name_txt'):setString(v.name)
        img_show:getChildByName('name_txt'):setString(v.name)
        list:pushBackCustomItem(item)
        self._uiLeft[i] = item
    end
    list:setVisible(true)
end
--right
function ServerListModule:initRightLayer()
    local view_size = self._pnlTableView:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setAnchorPoint(cc.p(0,0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlTableView:addChild(self._listView)
end

function ServerListModule:refreshRightList()
    local list = self._pnlRight
    list:removeAllItems()
    list:setScrollBarEnabled(false)
    local str = StaticData["local_text"]["login.last"] or ""
    self:addTitleItems(str)
    local tab_last = self:getLastServerTab()
    if next(tab_last) ~= nil then
        self:addListItems(tab_last, nil)
    end
    local str_title = StaticData["local_text"]["login.own.server"] or ""
    self:addTitleItems(str_title)
    local tab_own = self:getOwnServerTab()
    if next(tab_own) ~= nil then
        for i = 1, #tab_own, 2 do
            self:addListItems(tab_own[i], tab_own[i + 1])
        end
    end
    list:setVisible(true)
end

function ServerListModule:addTitleItems(str)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(720, 50))
    local item_temp = cc.CSLoader:createNode('server_list/ListRightTitle.csb')
    layout:addChild(item_temp)
    item_temp:setPosition(cc.p(0, 10))
    item_temp:getChildByName("Text_1"):setString(str)
    self._pnlRight:pushBackCustomItem(layout)
end

function ServerListModule:addListItems(tab1, tab2)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(720, 80))
    for i = 1, 2 do
        local tab = tab1
        if i == 2 then
            tab = tab2
        end
        if not tab then
            break
        end
        local pos_y = 0
        if i ~= 1 then
            pos_y = 440
        end
        local item_temp = cc.CSLoader:createNode('server_list/ListRight.csb')
        local item = item_temp:getChildByName('Panel_1')
        local item_bg = item:getChildByName("Image_1")
        local item_bg_select = item:getChildByName("Image_2")
        local item_pnl = item:getChildByName("Panel_1_0")
        local item_area = item_pnl:getChildByName("Text_1")
        local item_name = item_pnl:getChildByName("Text_1_0")
        local item_lv = item_pnl:getChildByName("Text_5")
        local item_lv_txt = item_pnl:getChildByName("Text_6")
        local item_select = item_pnl:getChildByName("select_head")
        local item_not_select = item_pnl:getChildByName("select_head_not")
        item:removeFromParent()
        item_area:setString(tostring(tab.sid))
        item_lv_txt:setString(StaticData["local_text"]["label.level2"])
        item_name:setString(tab.name)
        item:setPosition(cc.p(pos_y, 10))
        item:addClickEventListenerWithSound(function()
            uq.cache.server = tab
            services:dispatchEvent({name = "OnServerChanged", data = {} })
            self:disposeSelf()
        end)
        item_select:setVisible(self._sid == tab.sid)
        item_not_select:setVisible(self._sid ~= tab.sid)
        item_bg_select:setVisible(self._sid == tab.sid)
        item_bg:setVisible(self._sid ~= tab.sid)
        if self._sid == tab.sid then
            local color = uq.parseColor("#ffffff")
            item_area:setTextColor(color)
            item_name:setTextColor(color)
            item_lv_txt:setTextColor(color)
            item_lv:setTextColor(color)
        end
        layout:addChild(item)
    end
    self._pnlRight:pushBackCustomItem(layout)
end

function ServerListModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 2 + 1
    local server_info = self._allServerInfo[self._serverType]
    for i = 0, 1, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local rect = cc.rect(-173, -41.5, 346, 83)
        if cc.rectContainsPoint(rect, pos) then
            if not server_info[index] then
                return
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            self:_sendFinishMsg(server_info[index])
            break
        end
        index = index + 1
    end
end

function ServerListModule:cellSizeForTable(view, idx)
    return 720, 90
end

function ServerListModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 2 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 1, 1 do
            local info = self._allServerInfo[self._serverType][index]
            local euqip_item = uq.createPanelOnly("servers.ListBoxs")
            euqip_item:setAnchorPoint(cc.p(0,0))
            local width = euqip_item:getContentSize().width or 0
            euqip_item:setPosition(cc.p(width * 0.5 + (width + 10) * i, 34))
            cell:addChild(euqip_item)
            euqip_item:setName("item" .. i)
            if info ~= nil then
                euqip_item:setData(info, self._sid)
            else
                euqip_item:setLayerVisible(false)
            end
            index = index + 1
        end
    else
        for i = 0, 1, 1 do
            local info = self._allServerInfo[self._serverType][index]
            local euqip_item = cell:getChildByName("item" .. i)
            if euqip_item then
                if info ~= nil then
                    euqip_item:setData(info, self._sid)
                end
                euqip_item:setLayerVisible(info ~= nil)
            end
            index = index + 1
        end
    end
    return cell
end

function ServerListModule:numberOfCellsInTableView(view)
    if self._allServerInfo[self._serverType] then
        return math.ceil(#self._allServerInfo[self._serverType] / 2)
    else
        return 0
    end
end

function ServerListModule:dealServerData()
    for k, v in pairs(uq.config.servers) do
        if v.group then
            local ident = self:getIdentType(v.group)
            if ident ~= 0 then
                if not self._allServerInfo[ident] then
                    self._allServerInfo[ident] = {}
                end
                table.insert(self._allServerInfo[ident], v)
            end
        end
    end
    for i, v in ipairs(self._allServerInfo) do
        table.sort(v,function (a, b)
            return a.sid < b.sid
        end)
    end
    self._allServerInfo[1] = self._oftenServer
end

function ServerListModule:getIdentType(group)
    for i, v in ipairs(self._typeServer) do
        if v.group == group then
            return v.ident
        end
    end
    return 0
end

function ServerListModule:getLastServerTab()
    return self._oftenServer[1] or {}
end

function ServerListModule:getOwnServerTab()
    local tab = {}
    for i, v in ipairs(self._oftenServer) do
        if i ~= 1 then
            table.insert(tab, v)
        end
    end
    return tab
end

function ServerListModule:dispose()
    ServerListModule.super.dispose(self)
end

return ServerListModule
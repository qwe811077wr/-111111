local GovernmentMain = class("GovernmentMain", require("app.base.ModuleBase"))

GovernmentMain.RESOURCE_FILENAME = "government/GovernmentMain.csb"

GovernmentMain.RESOURCE_BINDING  = {
    ["Panel_1/Node_peerage"]                                    ={["varname"] = "_peerageNode"},
    ["Panel_1/Node_peerage/ScrollView_1"]                       ={["varname"] = "_reerageScrollView"},
    ["Panel_1/Node_peerage/Panel_bottom"]                       ={["varname"] = "_panelBottom"},
    ["Panel_1/Node_government"]                                 ={["varname"] = "_governmentNode"},
    ["Panel_1/Node_government/Panel_tableView"]                 ={["varname"] = "_panelTableView"},
    ["Panel_1/Node_government/Node_commander1"]                 ={["varname"] = "_commander2"},
    ["Panel_1/Node_government/Node_commander2"]                 ={["varname"] = "_commander3"},
    ["Panel_1/Node_government/Node_commander/Image_country"]    ={["varname"] = "_imgCountry"},
    ["Panel_1/Node_government/Node_commander"]                  ={["varname"] = "_commander1"},
    ["Panel_1/Node_government/Node_left/label_city_num"]        ={["varname"] = "_cityNumLabel"},
    ["Panel_1/Node_government/Node_left/Node_add"]              ={["varname"] = "_cityAddAttr"},
    ["Panel_1/Node_government/Node_left/btn_attr"]              ={["varname"] = "_btnAttr",["events"] = {{["event"] = "touch",["method"] = "_onBtnAttr"}}},
    ["Panel_1/btn_government"]                                  ={["varname"] = "_btnGovernment",["events"] = {{["event"] = "touch",["method"] = "_onBtnGovernment"}}},
    ["Panel_1/btn_tech"]                                        ={["varname"] = "_btnTech",["events"] = {{["event"] = "touch",["method"] = "_onBtnTech"}}},
    ["Panel_1/btn_award"]                                       ={["varname"] = "_btnAward",["events"] = {{["event"] = "touch",["method"] = "_onBtnAward"}}},
    ["Panel_1/btn_rank"]                                        ={["varname"] = "_btnRank",["events"] = {{["event"] = "touch",["method"] = "_onBtnRank"}}},
    ["Panel_1/Node_Top_UI"]                                     ={["varname"] = "_nodeTopUI"},
}

function GovernmentMain:ctor(name, args)
    GovernmentMain.super.ctor(self, name, args)
    self._viewType = 0 --官职界面，，1爵位界面
    self._topsItemArray = {self._commander1, self._commander2, self._commander3}
    self._governmentData = {}
    self._cropData = {}
    self._topsData = {}
end

GovernmentMain._COUNTRY_PATH = {
    "img/instance/g04_000068.png",
    "img/instance/g04_000070.png",
    "img/instance/g04_000069.png",
}

function GovernmentMain:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    local top_ui = uq.ui.CommonHeaderUI:create()
    self._topUI = top_ui
    self._topUI:setTitle(uq.config.constant.MODULE_ID.NATIONAL_POLICY)
    self._nodeTopUI:addChild(top_ui:getNode())
    self:initDialog()
    self:initProtocolData()
end

function GovernmentMain:initDialog()
    self._btnAttr:setPressedActionEnabled(true)
    self._btnGovernment:setPressedActionEnabled(true)
    self._btnTech:setPressedActionEnabled(true)
    self._btnAward:setPressedActionEnabled(true)
    self._btnRank:setPressedActionEnabled(true)
    self._panelBottom:setTouchEnabled(true)
    self._panelBottom:addClickEventListenerWithSound(function()
        self._reerageScrollView:jumpToBottom()
    end)
    for k, v in ipairs(self._topsItemArray) do
        v:getChildByName("Image_64"):setTouchEnabled(true)
        v:getChildByName("Image_64")['index'] = k - 1
        v:getChildByName("Image_64"):addClickEventListener(function(sender)
            local index = sender['index']
            uq.ModuleManager:getInstance():show(uq.ModuleManager.GOVERNMENT_INFO, {info = self._topsData[index], pos = index})
        end)
    end
    self:updateDialog()
end

function GovernmentMain:updateDialog()
    self._peerageNode:setVisible(self._viewType == 1)
    self._governmentNode:setVisible(self._viewType == 0)
    if self._viewType == 0 then
        self._imgCountry:loadTexture(self._COUNTRY_PATH[uq.cache.role.country])
        self:initTableView()
        self:updateGovernment()
    else
        self:updatePeerage()
    end
end

function GovernmentMain:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GovernmentMain:cellSizeForTable(view, idx)
    return 180, 240
end

function GovernmentMain:numberOfCellsInTableView(view)
    return #self._governmentData
end

function GovernmentMain:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._governmentData[index]
    local crop_info = self:getCropDataByCity(info.city_id)
    if info.is_last then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GOVERNMENT_INFO, {info = crop_info, pos = uq.config.constant.GOVERNMENT_POS.TATRAP, city_id = info.city_id})
end

function GovernmentMain:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local info = self._governmentData[index]
    local govern_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        if info ~= nil then
            govern_item = uq.createPanelOnly("government.GovernmentItem")
            local width = govern_item:getContentSize().width
            cell:addChild(govern_item)
            govern_item:setName("item")
        end
    else
        govern_item = cell:getChildByName("item")
    end
    if govern_item then
        local crop_info = self:getCropDataByCity(info.city_id)
        if info.is_last then
            crop_info = {is_last = true}
        end
        govern_item:setInfo(crop_info, info.city_id)
    end
    return cell
end

function GovernmentMain:updateGovernment()
    self._btnGovernment:getChildByName("label_name"):setString(StaticData["local_text"]["crop.government.des2"])
    local crop_info = uq.cache.crop._allMemberInfo
    self._cropData = {}
    self._topsData = {}  --存放前三个
    for k, v in ipairs(crop_info) do
        if v.pos > 2 then
            self._cropData[v.pos_cityid] = v
        else
            self._topsData[v.pos] = v
        end
    end
    self:updateGovernmentTopDialog()
    self._governmentData = {}
    local world_city_info = uq.cache.world_war.world_city_info
    for k, v in pairs(world_city_info) do
        if v.crop_id == uq.cache.role.cropsId and StaticData['world_city'][v.city_id].type == 3 then
            table.insert(self._governmentData, v)
        end
    end
    table.insert(self._governmentData, {is_last = true, city_id = 0})
    self._tableView:reloadData()
end

function GovernmentMain:getCropDataByCity(city_id)
    return self._cropData[city_id]
end

function GovernmentMain:updateGovernmentTopDialog()
    for k, v in ipairs(self._topsItemArray) do
        local info = self._topsData[k - 1]
        v:getChildByName("Node_2"):setVisible(info == nil)
        v:getChildByName("Node_1"):setVisible(info ~= nil)
        if info then
            local node_show =  v:getChildByName("Node_1")
            node_show:getChildByName("label_name"):setString(info.name)
            local res_head = uq.getHeadRes(info.img_id, info.img_type)
            node_show:getChildByName("Panel_2"):getChildByName("Image_7"):loadTexture(res_head)
        end
    end
end

function GovernmentMain:updatePeerage()
    self._btnGovernment:getChildByName("label_name"):setString(StaticData["local_text"]["crop.government.des1"])
    self._reerageScrollView:removeAllChildren()
    local pos_x = 0
    local pos_y = 1080
    self._reerageScrollView:setInnerContainerSize(cc.size(self._reerageScrollView:getContentSize().width, pos_y))
    local per_rank = 0
    for k, v in ipairs(StaticData['world_nation']) do
        local data = uq.cache.world_war.battle_title_info[v.ident]
        v.data = data
        local item = self:getItemByRank(v.rank)
        item:setInfo(v)
        self._reerageScrollView:addChild(item)
        if v.rank == per_rank then
            pos_x = pos_x + item:getContentSize().width + v.off_x
        else
            pos_x = v.pos_x
            per_rank = v.rank
            pos_y = pos_y - item:getContentSize().height
        end
        item:setAnchorPoint(cc.p(0, 0))
        item:setPosition(cc.p(pos_x, pos_y))
    end
end

function GovernmentMain:getItemByRank(rank)
    if rank == 1 then
        return uq.createPanelOnly("government.PeerageItem1")
    else
        return uq.createPanelOnly("government.PeerageItem2")
    end
end

function GovernmentMain:_onBtnAttr(event)
    if event.name ~= "ended" then
        return
    end
end

function GovernmentMain:_onBtnGovernment(event)
    if event.name ~= "ended" then
        return
    end
    self._viewType = (self._viewType + 1) % 2
    self:updateDialog()
end

function GovernmentMain:_onBtnTech(event)
    if event.name ~= "ended" then
        return
    end
end

function GovernmentMain:_onBtnAward(event)
    if event.name ~= "ended" then
        return
    end
end

function GovernmentMain:_onBtnRank(event)
    if event.name ~= "ended" then
        return
    end
end

function GovernmentMain:_onCropRefreshMy()
    if self._viewType == 0 then
        self:updateGovernment()
    end
end

function GovernmentMain:_onUpdatePeerage()
    if self._viewType == 1 then
        self:updatePeerage()
    end
end

function GovernmentMain:initProtocolData()
    self._eventRefreshTag = services.EVENT_NAMES.ON_CRROP_REFRESH_MY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_REFRESH_MY, handler(self, self._onCropRefreshMy), self._eventRefreshTag)
    self._cropAppointNotify = services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY, handler(self, self._onCropRefreshMy), self._cropAppointNotify)
    self._battleTitleNotify = services.EVENT_NAMES.ON_BATTLE_TITLE_NOTIFY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_TITLE_NOTIFY, handler(self, self._onUpdatePeerage), self._battleTitleNotify)
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_MEMBER, {crop_id = uq.cache.role.cropsId})
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_LOAD_TITLE)
end

function GovernmentMain:removeProtocolData()
    services:removeEventListenersByTag(self._battleTitleNotify)
    services:removeEventListenersByTag(self._cropAppointNotify)
    services:removeEventListenersByTag(self._eventRefreshTag)
end

function GovernmentMain:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    self:removeProtocolData()
    GovernmentMain.super.dispose(self)
end

return GovernmentMain

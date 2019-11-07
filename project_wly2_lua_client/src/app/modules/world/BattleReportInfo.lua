local BattleReportInfo = class("BattleReportInfo", require("app.base.PopupBase"))

BattleReportInfo.RESOURCE_FILENAME = "world/BattleReport.csb"

BattleReportInfo.RESOURCE_BINDING  = {
    ["Panel_2/Panel_tabview"]               ={["varname"] = "_panelTabView"},
    ["Panel_2/Panel_press"]                 ={["varname"] = "_panelPress"},
    ["Panel_2/Panel_press/Node_share"]      ={["varname"] = "_shareNode"},
    ["btn_world"]                           = {["varname"] = "_btnWorld",["events"] = {{["event"] = "touch",["method"] = "onBtnShare"}}},
    ["btn_country"]                         = {["varname"] = "_btnCountry",["events"] = {{["event"] = "touch",["method"] = "onBtnShare"}}},
    ["btn_crop"]                            = {["varname"] = "_btnCrop",["events"] = {{["event"] = "touch",["method"] = "onBtnShare"}}},
    ["Panel_2/Node_tab"]                    ={["varname"] = "_tabPanel"},
}

BattleReportInfo._TAB_NORMAL = {
    "img/world/j02_00000255.png",
    "img/world/j02_00000257.png"
}

BattleReportInfo._TAB_SELECT = {
    "img/world/j02_00000254.png",
    "img/world/j02_00000256.png"
}

function BattleReportInfo:ctor(name, args)
    BattleReportInfo.super.ctor(self,name,args)
    self._tabIndex = args.tab_index or 1
    self._tabArray = {}
    self._reportArray = {}
    self._itemArray = {}
    self._itemData = nil
end

function BattleReportInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_REPORT_LOAD, handler(self, self._onBattleReportLoad), "onBattleReportNotifyByRank")
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_REPORT_NOTIFY, handler(self, self._onBattleReportLoad), "onBattleReportLoadByRank")
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_REPORT_SHARE_BTN, handler(self, self._onBattleReportShareBtn), "onBattleReportShareBtnByRank")
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_REPORT_LOAD)
end

function BattleReportInfo:_onBattleReportShareBtn(msg)
    self._panelPress:setVisible(true)
    self._shareNode:setPosition(cc.p(msg.data.pos))
    self._itemData = msg.data.info
end

function BattleReportInfo:_onBattleReportLoad()
    self._reportArray = uq.cache.world_war.battle_report_info
    if #self._reportArray > 1 then
        table.sort(self._reportArray, function(a, b)
            return a.time > b.time
        end)
    end
    self._itemTableView:reloadData()
end

function BattleReportInfo:initUi()
    self._btnCountry:setPressedActionEnabled(true)
    self._btnCountry:setTag(uq.config.constant.TYPE_CHAT_CHANNEL.CC_COUNTRY)
    self._btnCrop:setPressedActionEnabled(true)
    self._btnCrop:setTag(uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM)
    self._btnWorld:setPressedActionEnabled(true)
    self._btnWorld:setTag(uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD)
    self._panelPress:setVisible(false)
    for i = 1, 2 do
        local item = self._tabPanel:getChildByName("Panel_" .. i)
        table.insert(self._tabArray, item)
    end
    local select_item = nil
    for k, v in ipairs(self._tabArray) do
        v:setTag(k)
        v:getChildByName("img_normal"):setVisible(false)
        v:getChildByName("img_select"):loadTexture(self._TAB_NORMAL[k])
        v:setTouchEnabled(true)
        v:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            self:onTabChanged(sender)
        end)

        if k == self._tabIndex then
            select_item = v
            v:getChildByName("img_select"):loadTexture(self._TAB_SELECT[k])
            v:getChildByName("img_normal"):setVisible(true)
        end
    end
    self._panelPress:setTouchEnabled(true)
    self._panelPress:addClickEventListenerWithSound(function(sender)
        self._panelPress:setVisible(false)
    end)
    self:initItemTabView()
    self:onTabChanged(select_item)
end

function BattleReportInfo:onTabChanged(sender)
    local tag = sender:getTag()
    if self._tabIndex == tag then
        return
    end
    for k, v in ipairs(self._tabArray) do
        v:getChildByName("img_select"):loadTexture(self._TAB_NORMAL[k])
        v:getChildByName("img_normal"):setVisible(false)
    end
    sender:getChildByName("img_select"):loadTexture(self._TAB_SELECT[tag])
    sender:getChildByName("img_normal"):setVisible(true)
    self._tabIndex =  tag
    self:updateInfo()
end

function BattleReportInfo:updateInfo()
    self._itemTableView:reloadData()
end

function BattleReportInfo:initItemTabView()
    local size = self._panelTabView:getContentSize()
    self._itemTableView = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView:setPosition(cc.p(0, 0))
    self._itemTableView:setAnchorPoint(cc.p(0,0))
    self._itemTableView:setDelegate()
    self._panelTabView:addChild(self._itemTableView)

    self._itemTableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._itemTableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function BattleReportInfo:cellSizeForTable(view, idx)
    return 1120, 204
end

function BattleReportInfo:numberOfCellsInTableView(view)
    return #self._reportArray
end

function BattleReportInfo:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._reportArray[index]
    for k, v in ipairs(self._itemArray) do
        v:setSelectState(v:getData().report_id == info.report_id)
    end
end

function BattleReportInfo:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.BattleReportItem")
        cell:addChild(cell_item)
        table.insert(self._itemArray, cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._reportArray[index]
    cell_item:setData(info)
    return cell
end

function BattleReportInfo:onBtnShare(event)
    if event.name ~= "ended" then
        return
    end
    local enemy = {
        player_name = self._itemData.enemy[1].player_name,
        img_type = self._itemData.enemy[1].img_type,
        img_id = self._itemData.enemy[1].img_id,
    }
    local ower = {
        player_name = uq.cache.role.name,
        img_type = uq.cache.role:getImgId(),
        img_id = uq.cache.role:getImgType(),
    }
    local info = {
        is_atk = self._itemData.is_atk,
        result = self._itemData.result,
        report_id = self._itemData.report_id,
        enemy = enemy,
        ower = ower,
    }
    local content = json.encode(info)
    local data = {
        channel = event.target:getTag(),
        content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE,
        content = content
    }
    uq.sendShareMsg(data)
    self._panelPress:setVisible(false)
end

function BattleReportInfo:dispose()
    services:removeEventListenersByTag('onBattleReportNotifyByRank')
    services:removeEventListenersByTag('onBattleReportLoadByRank')
    services:removeEventListenersByTag('onBattleReportShareBtnByRank')
    BattleReportInfo.super.dispose(self)
end

return BattleReportInfo
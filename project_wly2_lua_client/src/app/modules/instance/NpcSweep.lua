local NpcSweep = class("NpcSweep", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

NpcSweep.RESOURCE_FILENAME = 'instance/NpcSweep.csb'
NpcSweep.RESOURCE_BINDING = {
    ["sweep_btn_0"]        = {["varname"] = "_btnSweepOne",["events"] = {{["event"] = "touch",["method"] = "onSweep"}}},
    ["sweep_btn"]          = {["varname"] = "_btnSweepFive",["events"] = {{["event"] = "touch",["method"] = "onSweep"}}},
    ["Button_1"]           = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "closePanel"}}},
    ["Button_1_0"]         = {["varname"] = "_btnAddMillitory",["events"] = {{["event"] = "touch",["method"] = "onAddMillitory"}}},
    ["cost_order_txt_atk"] = {["varname"] = "_txtCostOrderAtk"},
    ["Panel_3"]            = {["varname"] = "_panelList"},
    ["name_txt"]           = {["varname"] = "_txtName"},
    ["num_txt"]            = {["varname"] = "_txtNum"},
    ["img_icon"]           = {["varname"] = "_imgIcon"},
    ["spr_icon"]           = {["varname"] = "_sprIcon"},
    ["Node_1"]             = {["varname"] = "_nodeItems"},
    ["label_name_0"]       = {["varname"] = "_txtHead"},
    ["panel_icon"]         = {["varname"] = "_iconPanel"},
}

function NpcSweep:ctor(name, params)
    NpcSweep.super.ctor(self, name, params)
    self._instanceId = params.instance_id
    self._dataList = params.items
    self._npcId = params.npc_id
    self._sweepCount = params.sweep_count
    self._curInfo = params.info_items
end

function NpcSweep:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()

    self._xmlData = uq.cache.instance:getNPCXml(self._instanceId, self._npcId)
    self:createList()

    local cost_config = string.split(self._xmlData.cost, ';')
    self._costType = tonumber(cost_config[1])
    self._eventName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. self._costType
    self._eventTag = self._eventName .. tostring(self)
    services:addEventListener(self._eventName, handler(self, self.refreshMillitory), self._eventTag)

    self._eventBuy = services.EVENT_NAMES.BUY_MILITORY_ORDER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.BUY_MILITORY_ORDER, handler(self, self.refreshMillitory), self._eventBuy)
    self:refreshItems()
    self:refreshMillitory()
end

function NpcSweep:onSweep(event)
    if event.name == "ended" then
        self._sweepCount = event.target:getTag()
        local npc_data = uq.cache.instance:getNPC(self._instanceId, self._npcId)

        local cost_config = string.split(self._xmlData.cost, ';')
        local cost_num = tonumber(cost_config[2]) * self._sweepCount
        local cost_type = tonumber(cost_config[1])
        local info = StaticData.getCostInfo(cost_type)
        if not uq.cache.role:checkRes(cost_type, cost_num) then
            uq.fadeInfo(string.format(StaticData['local_text']['label.res.tips.less'], info.name))
            return
        end

        if self._xmlData.qtyLimit ~= 0 and npc_data.atk_num >= self._xmlData.qtyLimit then
            uq.fadeInfo(StaticData['local_text']['crop.redbag.send.num.not'])
            return
        end

        local packet = {instance_id = self._instanceId, npc_id = self._npcId, count = self._sweepCount}
        network:sendPacket(Protocol.C_2_S_INSTANCE_SWEEP, packet)
        self:disposeSelf()
    end
end

function NpcSweep:refreshItems()
    self._nodeItems:setVisible(false)
    if not self._curInfo or next(self._curInfo) == nil then
        return
    end
    local info_data = StaticData.getCostInfo(self._curInfo.type, self._curInfo.id)
    if info_data == nil then
        return
    end
    self._nodeItems:setVisible(true)
    if self._curInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        self:initEquipItem()
    elseif self._curInfo.type == uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL then
        self:initSpecialItem()
    else
        self:initUi()
    end
end

function NpcSweep:initEquipItem()
    local data = StaticData['items'][self._curInfo.id]
    self._txtName:setString(data.name)
    self:setNameLabelQuality(data.qualityType)
    local type_xml  = StaticData['types'].Effect[1].Type[data.effectType]
    if type_xml then
        self._txtHead:setString(StaticData['local_text']['label.state.init'] .. type_xml.name)
    end
    self._txtNum:setString('+' .. data.effectValue)
    self:addItem(self._curInfo)
end

function NpcSweep:initSpecialItem()
    local info = StaticData['advance_data'][self._curInfo.id] or {}
    if not info or next(info) == nil then
        return
    end
    if info.icon then
        self._sprIcon:setTexture("img/common/item/" .. info.icon)
        self._sprIcon:setVisible(true)
    end
    if info.qualityType then
        local tab = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
        if tab and tab.qualityIcon then
            self._imgIcon:loadTexture("img/common/ui/" .. tab.qualityIcon)
            self._imgIcon:setVisible(true)
        end
        self._txtName:setTextColor(uq.parseColor("#" .. tab.color))
    end
    self._txtName:setString(info.name)
    local pos_x = self._txtNum:getPositionX()
    self._txtNum:setPositionX(pos_x - 60)
    local num = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id)
    self._txtNum:setString(num)
    if not self._curInfo.totalNum then
        return
    end
    self._txtNum:setString(num .. "/" .. self._curInfo.totalNum)
    if num >= self._curInfo.totalNum then
        self._txtNum:setTextColor(uq.parseColor("#00FF12"))
    else
        self._txtNum:setTextColor(uq.parseColor("#FFFFFF"))
    end
end

function NpcSweep:initUi()
    if self._curInfo.curNum == nil then
        self._curInfo.curNum = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id) or 0
    end
    self._iconPanel:removeAllChildren()
    local xml_data = StaticData['types'].Cost[1].Type[self._curInfo.type]
    if not xml_data then
        return
    end
    local info_data = StaticData.getCostInfo(self._curInfo.type, self._curInfo.id)
    if info_data == nil then
        return
    end
    local name = info_data.name
    local quality_type = self._curInfo.qualityType
    if self._curInfo.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        local general_xml = uq.cache.generals:getGeneralDataXML(tonumber(self._curInfo.id .. 1))
        name = name .. StaticData["local_text"]["general.piece"]
        local generals_grade = StaticData['types'].GeneralGrade[1].Type[general_xml.grade]
        quality_type = generals_grade.qualityType
    end
    self._nameLabel:setString(name)
    self:setNameLabelQuality(tonumber(quality_type))

    local pos_x = self._numLabel:getPositionX()
    self._numLabel:setPositionX(pos_x - 60)
    self._numLabel:setString(self._curInfo.curNum)
    local info = {id = self._curInfo.id, type = self._curInfo.type}
    self:addItem(info)
end

function NpcSweep:setNameLabelQuality(quality_type)
    local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(quality_type)]
    if not quality_info then
        return
    end
    self._txtName:setTextColor(uq.parseColor("#" .. quality_info.color))
end

function NpcSweep:addItem(info)
    local item = EquipItem:create({info = info})
    item:setScale(0.9)
    item:setPosition(self._iconPanel:getContentSize().width * scale * 0.5, self._iconPanel:getContentSize().height * scale * 0.5)
    item:addTo(self._iconPanel)
end

function NpcSweep:refreshItemsNum()
    if not self._curInfo or next(self._curInfo) == nil or not self._curInfo.totalNum then
        return
    end
    local num = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id)
    self._txtNum:setString(num .. "/" .. self._curInfo.totalNum)
    if num >= self._curInfo.totalNum then
        self._txtName:setTextColor(uq.parseColor("#00FF12"))
    else
        self._txtName:setTextColor(uq.parseColor("#FFFFFF"))
    end
end

function NpcSweep:closePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function NpcSweep:dispose()
    NpcSweep.super.dispose(self)
end

function NpcSweep:onAddMillitory(event)
    if event.name == "ended" then
        uq.jumpToModule(uq.config.constant.MODULE_ID.BUY_MILITORY_ORDER)
    end
end

function NpcSweep:refreshMillitory()
    local num = uq.cache.role:getResNum(self._costType)
    local cost_config = string.split(self._xmlData.cost, ';')
    local color = tonumber(cost_config[2]) <= num and '56FF49' or 'F30B0B'
    self._txtCostOrderAtk:setHTMLText(string.format("<font color='#%s'>%d</font> / %d", color, tonumber(cost_config[2]), num))
end

function NpcSweep:onExit()
    services:removeEventListenersByTag(self._eventBuy)
    services:removeEventListenersByTag(self._eventTag)

    NpcSweep.super.onExit(self)
end

function NpcSweep:createList()
    local view_size = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelList:addChild(self._listView)
end

function NpcSweep:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function NpcSweep:cellSizeForTable(view, idx)
    return 1033, 122
end

function NpcSweep:numberOfCellsInTableView(view)
    return #self._dataList
end

function NpcSweep:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance.NpcSweepItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataList[index], index)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return NpcSweep
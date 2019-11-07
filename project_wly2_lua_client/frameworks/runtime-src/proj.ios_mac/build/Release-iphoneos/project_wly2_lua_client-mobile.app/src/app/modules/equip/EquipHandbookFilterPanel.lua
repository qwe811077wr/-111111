local EquipHandbookFilterPanel = class("EquipHandbookFilterPanel", require('app.base.PopupBase'))

EquipHandbookFilterPanel.RESOURCE_FILENAME = "equip/FilterBox.csb"
EquipHandbookFilterPanel.RESOURCE_BINDING = {
    ["Panel_condition"]                 = {["varname"] = "_panelCondition"},
    ["Panel_kind"]                      = {["varname"] = "_panelKind"},
    ["Panel_1"]                         = {["varname"] = "_panelBg"},
}

function EquipHandbookFilterPanel:onCreate()
    EquipHandbookFilterPanel.super.onCreate(self)
    self._curConditionSelected = 1
    self._curKindSelected = 0
    self._conditionCellArray = {}
    self._kindCellArray = {}

    self._conditionDataName = {
        StaticData["local_text"]["equip.position"],                 --部位
        StaticData["local_text"]["equip.suit"],                     --套装
        StaticData["local_text"]["decompose.rarity"],               --稀有度（品质）
    }

    self._conditionDataSource = {
        StaticData['types']['Item'][1]['Type'],                     --部位
        StaticData['item_suit'],                                    --套装
        StaticData['types']['ItemQuality'][1]['Type'],              --稀有度（品质）
    }

    self:initConditionTableView()
    self:initKindTableView()
end

function EquipHandbookFilterPanel:setData(parent, condition_index, kind_index)
    self._parent = parent
    self._curConditionSelected = condition_index
    self._curKindSelected = kind_index
    if self._tableViewCondition then
        self._tableViewCondition:reloadData()
    end
    if self._tableViewKind then
        self:resizeKindPanel()
        self._tableViewKind:reloadData()
    end
end

function EquipHandbookFilterPanel:initConditionTableView()
    local size = self._panelCondition:getContentSize()
    self._tableViewCondition = cc.TableView:create(cc.size(size.width,size.height))
    self._tableViewCondition:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableViewCondition:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableViewCondition:setPosition(cc.p(0, 0))
    self._tableViewCondition:setAnchorPoint(cc.p(0,0))
    self._tableViewCondition:setDelegate()

    self._tableViewCondition:registerScriptHandler(handler(self,self.conditionTableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableViewCondition:registerScriptHandler(handler(self,self.conditionCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableViewCondition:registerScriptHandler(handler(self,self.conditionTableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableViewCondition:registerScriptHandler(handler(self,self.conditionNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableViewCondition:reloadData()
    self._panelCondition:addChild(self._tableViewCondition)
end

function EquipHandbookFilterPanel:conditionCellSizeForTable(view, idx)
    return 300, 40
end

function EquipHandbookFilterPanel:conditionNumberOfCellsInTableView(view)
    return math.floor((#self._conditionDataSource + 2) / 3)
end

function EquipHandbookFilterPanel:conditionTableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 3 + 1
    for i = 1, 3, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local width = item:getContentSize().width
        local height = item:getContentSize().height

        local rect = cc.rect(0 , 0 , width , height )
        if cc.rectContainsPoint(rect, pos) then
            if self._curConditionSelected == index then
                return
            end
            if not item:isVisible() then
                return
            end
            for _,v in ipairs(self._conditionCellArray) do
                v:getChildByName("selected_img"):setVisible(false)
            end
            self._curConditionSelected = index
            item:getChildByName("selected_img"):setVisible(true)
            self._curKindSelected = 0
            if self._tableViewKind then
                self:resizeKindPanel()
                self._tableViewKind:reloadData()
            end
            if self._parent then
                self._parent:setFilterResult(self._curConditionSelected, self._curKindSelected, StaticData["local_text"]["map.guide.des1"])
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            break
        end
        index = index + 1
    end
end

function EquipHandbookFilterPanel:conditionTableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 3 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 1, 3, 1 do
            local name = self._conditionDataName[index]
            local width = 0
            local checkbox_item = self:getCheckBox(name)
            width = checkbox_item:getContentSize().width
            checkbox_item:setPosition(cc.p((width * 0.5) + (width + 6) * (i - 1), 10))
            cell:addChild(checkbox_item, 1)
            checkbox_item:setName("item" .. i)
            checkbox_item:setVisible(name ~= nil)
            checkbox_item:getChildByName("selected_img"):setVisible(self._curConditionSelected == index)
            table.insert(self._conditionCellArray, checkbox_item)
            index = index + 1
        end
    else
        for i = 1, 3, 1 do
            local name = self._conditionDataName[index]
            local checkbox_item = cell:getChildByName("item" .. i)
            if checkbox_item == nil then
                return cell
            end
            if name ~= nil then
                checkbox_item:setTitleText(name)
            end
            checkbox_item:setVisible(name ~= nil)
            checkbox_item:getChildByName("selected_img"):setVisible(self._curConditionSelected == index)
            index = index + 1
        end
    end
    return cell
end

function EquipHandbookFilterPanel:initKindTableView()
    local size = self._panelKind:getContentSize()
    self._tableViewKind = cc.TableView:create(cc.size(size.width,size.height))
    self._tableViewKind:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableViewKind:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableViewKind:setPosition(cc.p(0, 0))
    self._tableViewKind:setAnchorPoint(cc.p(0,0))
    self._tableViewKind:setDelegate()

    self._tableViewKind:registerScriptHandler(handler(self,self.kindTableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableViewKind:registerScriptHandler(handler(self,self.kindCellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableViewKind:registerScriptHandler(handler(self,self.kindTableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableViewKind:registerScriptHandler(handler(self,self.kindNumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableViewKind:reloadData()
    self._panelKind:addChild(self._tableViewKind)
end

function EquipHandbookFilterPanel:kindCellSizeForTable(view, idx)
    return 300, 45
end

function EquipHandbookFilterPanel:kindNumberOfCellsInTableView(view)
    return math.floor((#self._conditionDataSource[self._curConditionSelected] + 3) / 3)
end

function EquipHandbookFilterPanel:kindTableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 3
    for i = 1, 3, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local width = item:getContentSize().width
        local height = item:getContentSize().height

        local rect = cc.rect(0 , 0 , width , height )
        if cc.rectContainsPoint(rect, pos) then
            if self._curKindSelected == index then
                return
            end
            if not item:isVisible() then
                return
            end
            for _,v in ipairs(self._kindCellArray) do
                v:getChildByName("selected_img"):setVisible(false)
            end
            self._curKindSelected = index
            item:getChildByName("selected_img"):setVisible(true)
            if self._parent then
                self._parent:setFilterResult(self._curConditionSelected, self._curKindSelected, item:getTitleText())
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            self:runCloseAction()
            break
        end
        index = index + 1
    end
end

function EquipHandbookFilterPanel:kindTableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 3
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 1, 3, 1 do
            local info = self._conditionDataSource[self._curConditionSelected][index]
            local width = 0
            local name = nil
            if info ~= nil then
                name = info.name
            elseif index == 0 then
                name = StaticData["local_text"]["map.guide.des1"]
            end
            local checkbox_item = self:getCheckBox(name)
            width = checkbox_item:getContentSize().width
            checkbox_item:setPosition(cc.p((width * 0.5) + (width + 6) * (i - 1), 20))
            cell:addChild(checkbox_item, 1)
            checkbox_item:setName("item" .. i)
            checkbox_item:setVisible(name ~= nil)
            checkbox_item:getChildByName("selected_img"):setVisible(self._curKindSelected == index)
            table.insert(self._kindCellArray, checkbox_item)
            index = index + 1
        end
    else
        for i = 1, 3, 1 do
            local info = self._conditionDataSource[self._curConditionSelected][index]
            local name = nil
            if info ~= nil then
                name = info.name
            elseif index == 0 then
                name = StaticData["local_text"]["map.guide.des1"]
            end
            local checkbox_item = cell:getChildByName("item" .. i)
            if checkbox_item == nil then
                return cell
            end
            if name ~= nil then
                checkbox_item:setTitleText(name)
            end
            checkbox_item:setVisible(name ~= nil)
            checkbox_item:getChildByName("selected_img"):setVisible(self._curKindSelected == index)
            index = index + 1
        end
    end
    return cell
end

function EquipHandbookFilterPanel:refreshPage()
    self._spriteLock:setVisible(false)
    self._opened = true
    -- uq.intoAction(self._nodeBase)
    if not self._xmlData then
        self._spriteLock:setVisible(true)
        self._txtName:setString('')
        self._opened = false
        return
    end

    self._spriteIcon:setTexture('img/crop/' .. self._xmlData.icon)

    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    local tech_data = self._parent:getTechData()
    local tech_level = tech_data and tech_data.techs[self._index].lvl or 0
    local level_data = self._xmlData.Effect[tech_level]

    if self._xmlData.initLevel > crop_info.level then
        self._spriteLock:setVisible(true)
        self._txtName:setString(string.format(StaticData['local_text']['crop.tech.open.level'], self._xmlData.initLevel))
        self._opened = false
    else
        self._txtLevel:setString(tostring(tech_level))
        self._txtName:setString(self._xmlData.name)
        local level_max = self._index == 1 and #self._xmlData.Effect or level_data.LegionLevel
        self._txtLevelProgress:setString(string.format('%d/%d', tech_level, level_max))
        self._loadLevelProgress:setPercent(tech_level / level_max * 100)
    end
end

function EquipHandbookFilterPanel:getCheckBox(name)
    name = name or ""
    local size = 20
    local font = "font/fzzzhjt.ttf"
    local color = "#142229"
    local button_item = ccui.Button:create("img/equip/s03_00280.png", "img/equip/s03_00280.png", "img/equip/s03_00280.png")
    button_item:setTitleFontSize(size)
    button_item:setTitleFontName(font)
    button_item:setTitleColor(uq.parseColor(color))
    button_item:setTitleText(name)
    button_item:setTouchEnabled(false)
    local selected_img = ccui.ImageView:create("img/equip/s03_0007201.png")
    selected_img:setName("selected_img")
    local width = button_item:getContentSize().width
    local height = button_item:getContentSize().height
    selected_img:setPosition(cc.p(width / 2 , height / 2))
    selected_img:setVisible(false)
    button_item:addChild(selected_img)
    return button_item
end

function EquipHandbookFilterPanel:resizeKindPanel()
    local cell_count = math.floor((#self._conditionDataSource[self._curConditionSelected] + 3) / 3)
    local size = self._tableViewKind:getContentSize()
    self._panelKind:setContentSize(cc.size(size.width, cell_count * 45))
    self._tableViewKind:setViewSize(cc.size(size.width, cell_count * 45))
    self._panelBg:setContentSize(cc.size(self._panelBg:getContentSize().width, 113 + cell_count * 45))
end

return EquipHandbookFilterPanel
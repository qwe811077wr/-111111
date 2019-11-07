local CityFace = class("CityFace", require('app.base.PopupBase'))

CityFace.RESOURCE_FILENAME = "area/CityFace.csb"
CityFace.RESOURCE_BINDING = {
    ["Panel_2"]          = {["varname"] = "_panelList"},
    ["Image_7"]          = {["varname"] = "_imgCity"},
    ["Text_1_0_0_0"]     = {["varname"] = "_txtCityState"},
    ["Text_1_0_0"]       = {["varname"] = "_txtCityDesc"},
    ["Text_1_0_0_0_0_0"] = {["varname"] = "_txtGetDesc"},
    ["Button_2"]         = {["varname"] = "_btnReplace",["events"] = {{["event"] = "touch",["method"] = "onReplace"}}},
}

function CityFace:ctor(name, params)
    CityFace.super.ctor(self, name, params)
end

function CityFace:onCreate()
    CityFace.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    self._curIndex = 1
    self._dataList = StaticData['city_facades']

    network:sendPacket(Protocol.C_2_S_CITY_SKIN_INFO)
end

function CityFace:onExit()
    CityFace.super:onExit()
end

function CityFace:setData(data)
    self._cityData = data
    self:createList()
end

function CityFace:createList()
    local viewSize = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
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

function CityFace:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CityFace:cellSizeForTable(view, idx)
    return 572, 172
end

function CityFace:numberOfCellsInTableView(view)
    return math.ceil(#self._dataList / 3)
end

function CityFace:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("area.CityFaceList")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(index)
    cellItem:setCurCityData(self._cityData)

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))

    if math.ceil(self._curIndex / 3) == index then
        cellItem:setSelected(self._curIndex, true)
        self:setInfo(self._curIndex)
    else
        cellItem:setSelected((index - 1) * 3 + 1, false)
        cellItem:setSelected((index - 1) * 3 + 2, false)
        cellItem:setSelected((index - 1) * 3 + 3, false)
    end

    return cell
end

function CityFace:itemSelected(index)
    self:setSelected(index)
    self:setInfo(index)
end

function CityFace:setSelected(index)
    for i = 1, self:numberOfCellsInTableView() do
        local cell_tb = self._listView:cellAtIndex(i - 1)
        if cell_tb then
            local cell_item = cell_tb:getChildByTag(1000)
            cell_item:setSelected((i - 1) * 3 + 1, false)
            cell_item:setSelected((i - 1) * 3 + 2, false)
            cell_item:setSelected((i - 1) * 3 + 3, false)
        end
    end

    local cell_tb = self._listView:cellAtIndex(math.floor((index - 1) / 3))
    local cell_item = cell_tb:getChildByTag(1000)
    cell_item:setSelected(index, true)

    self._curIndex = index
end

function CityFace:setInfo(index)
    local config = StaticData['city_facades'][index]
    self._imgCity:loadTexture('img/areaicon/' .. config.file .. '.png')
    self._txtCityDesc:setString(config.explain)

    self._hasGet = false
    if index == 5 or index == 6 then
        self._txtGetDesc:setString(string.format('战力排名弟%d名', config.value))
    elseif index == 4 then
        self._txtGetDesc:setString('等级排行1-5名')
    elseif index == 2 then
        self._txtGetDesc:setString('试炼塔排行第1名')
    elseif index == 3 then
        self._txtGetDesc:setString('试炼塔排行2-9名')
    elseif index == 1 then
        self._txtGetDesc:setString('每周军勋排行1-10名')
    elseif index == 7 then
        self._txtGetDesc:setString(config.value)
    else
        self._txtGetDesc:setString(config.value)
    end
    if uq.cache.area._faceGet[index] then
        self._txtCityState:setString('已获取')
        self._btnReplace:setEnabled(true)
    else
        self._txtCityState:setString('尚未获取')
        self._btnReplace:setEnabled(false)
    end
end

function CityFace:setFace()
    self:setInfo(self._curIndex)
end

function CityFace:onReplace(event)
    if event.name == "ended" then
        local function confirm()
            local data = {
                ident = self._curIndex
            }
            network:sendPacket(Protocol.C_2_S_CITY_SKIN_SELECT, data)
        end

        local data = {
            content = '是否替换?',
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    end
end

function CityFace:refreshCurPage()
    local all_data = uq.cache.area:getCityInfo()
    for k,item in ipairs(all_data) do
        if item.seq_no == self._cityData.seq_no then
            self._cityData = item
            break
        end
    end
    self._listView:reloadData()
end

return CityFace
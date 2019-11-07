local CropMain = class("CropMain", require('app.modules.common.BaseViewWithHead'))

CropMain.RESOURCE_FILENAME = "crop/CropMain.csb"
CropMain.RESOURCE_BINDING = {
    ["Panel_8"]                   = {["varname"] = "_pnlList"},
    ["Text_1_0_0_1_0"]            = {["varname"] = "_txtTimer"},
    ["Button_1_0_0"]              = {["varname"] = "_btnCreate",["events"] = {{["event"] = "touch",["method"] = "onCreateCrop"}}},
    ["Button_1_0"]                = {["varname"] = "_btnOneKeyApply",["events"] = {{["event"] = "touch",["method"] = "onOneKeyApply",["sound_id"] = 62}}},
    ["Panel_2"]                   = {["varname"] = "_panelSearch"},
    ["Button_4"]                  = {["varname"] = "_btnSearch",["events"] = {{["event"] = "touch",["method"] = "onSearch"}}},
    ["one_finish_txt"]            = {["varname"] = "_txtOneFinish"},
}

function CropMain:ctor(name, params)
    CropMain.super.ctor(self, name, params)
    self._func = params.func
    self._curSelectIndex = 1
    self._dataList = {}
end

function CropMain:init()
    self:centerView()
    self:parseView()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.CROP_MAIN)
    self:adaptBgSize()
    self._nodePosx = 300
    self._shaderBtn = false
    self._allBoxUi = {}
    self._countryId = uq.cache.role.country_id
    self._countryStr = {
        [0] = StaticData['local_text']['label.collect.all'],
        [1] = StaticData['local_text']['label.power.shu'],
        [2] = StaticData['local_text']['label.power.wu'],
        [3] = StaticData['local_text']['label.power.wei'],
    }
    self:createEditbox()
    self:initPage()
    self:initLayer()
    self._cdTime = uq.cache.crop.join_cd - os.time()
    if self._cdTime > 0 then
        uq.TimerProxy:addTimer("updateCropTime", function()
            self._cdTime = self._cdTime - 1
            self:setApplyCdTime()
            if self._cdTime <= 0 then
                uq.TimerProxy:removeTimer('updateCropTime')
            end
        end, 1, -1)
    end
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_CROP_INFO)
end

function CropMain:onCreate()
    CropMain.super.onCreate(self)

    self._eventRefreshTag = services.EVENT_NAMES.ON_CRROP_REFRESH_MAIN .. tostring(self)
    self._eventRefreshApply = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY .. tostring(self)
    self._eventRefreshInfo = services.EVENT_NAMES.ON_LOAD_CROP_INFO .. tostring(self)

    network:addEventListener(Protocol.S_2_C_LOAD_ALL_CROP_INFO_END, handler(self, self._onRankInfoEnd), '_onRankInfoEnd')
    network:addEventListener(Protocol.S_2_C_LOAD_CROP_INFO, handler(self, self._onCropInfo), self._eventRefreshInfo)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_REFRESH_MAIN, handler(self, self._onCropRefreshMain), self._eventRefreshTag)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY, handler(self, self._refreshApply), self._eventRefreshApply)
end

function CropMain:onExit()
    uq.TimerProxy:removeTimer('updateCropTime')
    network:removeEventListenerByTag('_onRankInfoEnd')
    network:removeEventListenerByTag(self._eventRefreshInfo)
    services:removeEventListenersByTag(self._eventRefreshTag)
    services:removeEventListenersByTag(self._eventRefreshApply)
    if self._func then
        self._func()
    end
    CropMain.super:onExit()
end

function CropMain:_onRankInfoEnd(msg)
    self:refresh()
end

function CropMain:_onCropRefreshMain()
    self:refresh()
end

function CropMain:_refreshApply()
    self:refreshPage()
    for k,v in pairs(self._allBoxUi) do
        v:refreshPage()
    end
end

function CropMain:refresh()
    self._dataList = self:getSameForceCropInfo()
    self:refreshList()
    self:refreshPage()
end

function CropMain:createEditbox()
    local size = self._panelSearch:getContentSize()
    self._editBoxSearch = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxSearch:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxSearch:setFontName("font/fzlthjt.ttf")
    self._editBoxSearch:setFontSize(20)
    self._editBoxSearch:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxSearch:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxSearch:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxSearch:setPosition(cc.p(size.width/2, size.height/2))
    self._editBoxSearch:setPlaceholderFontName("font/fzlthjt.ttf")
    self._editBoxSearch:setPlaceholderFontSize(20)
    self._editBoxSearch:setPlaceHolder(StaticData["local_text"]["crop.input.name"])
    self._editBoxSearch:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._panelSearch:addChild(self._editBoxSearch)
end

function CropMain:initPage()
    self._txtTimer:setString('')
    self._txtOneFinish:setVisible(true)
end

function CropMain:_onCropInfo(msg)
    self._curCropInfo.crop_info = msg.data
end

function CropMain:refreshPage()
    if #self._dataList == 0 then
        self:initPage()
        return
    end
    self._curCropInfo = self._dataList[self._curSelectIndex]
    if self._curCropInfo == nil or next(self._curCropInfo) == nil then
        self._curCropInfo = self._dataList[1] or {}
    end
    self._btnCreate:setVisible(not uq.cache.role:hasCrop())
    self._btnOneKeyApply:setVisible(not uq.cache.role:hasCrop())

    self:setApplyCdTime()
    network:sendPacket(Protocol.C_2_S_LOAD_CROP_INFO, {id = self._curCropInfo.id})
end

function CropMain:initLayer()
    if uq.cache.role.cropsId ~= 0 then
        self._pnlList:setContentSize(cc.size(818, 420))
    end
    local viewSize = self._pnlList:getContentSize()
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
    self._pnlList:addChild(self._listView)
end

function CropMain:refreshList()
    self._dataList = self:getSameForceCropInfo()
    self._listView:reloadData()
end

function CropMain:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    --self:setSelectIndex(index)
end

function CropMain:setSelectIndex(index)
    if index == self._curSelectIndex then
        return
    end
    self._curSelectIndex = index
    self:refreshPage()
end

function CropMain:cellSizeForTable(view, idx)
    return 1280, 96
end

function CropMain:numberOfCellsInTableView(view)
    return #self._dataList
end

function CropMain:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("crop.CropCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))
    cellItem:setData(self._dataList[index], index)

    local box_data = self._dataList[index]
    if box_data and box_data.id then
        self._allBoxUi[box_data.id] = cellItem
    end
    return cell
end


function CropMain:onCreateCrop(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_CREATE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function CropMain:onOneKeyApply(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_APPLY, {crop_id = 0})
    end
end

function CropMain:setApplyCdTime()
    local need_shader = false
    if self._cdTime > 0 then
        self._txtTimer:setString(uq.getTime(self._cdTime, uq.config.constant.TIME_TYPE.HHMMSS))
        self._btnOneKeyApply:setEnabled(false)
        need_shader = true
    else
        self._txtTimer:setString('')
        self._btnOneKeyApply:setEnabled(uq.cache.role.cropsId <= 0)
        need_shader = uq.cache.role.cropsId > 0
    end
    self._txtOneFinish:setVisible(self._cdTime <= 0)
    if need_shader then
        uq.ShaderEffect:addGrayButton(self._btnOneKeyApply)
        self._shaderBtn = true
    else
        if self._shaderBtn then
            uq.ShaderEffect:removeGrayButton(self._btnOneKeyApply)
            self._shaderBtn = false
        end
    end
end

function CropMain:onSearch(event)
    if event.name == "ended" then
        local str = self._editBoxSearch:getText()
        if StaticData['local_text']['crop.input.name'] == str then
            uq.fadeInfo(StaticData['local_text']['crop.input.name'])
            return
        end

        if uq.hasKeyWord(str) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        self._dataList = self:getInfoFuzzySearch(str)
        self._curSelectIndex = 1
        self._listView:reloadData()
        self:refreshPage()
    end
end

function CropMain:getMyCellIndex()
    for i,v in ipairs(self._dataList) do
        if v.id == uq.cache.role.cropsId then
            return i
        end
    end
    return 0
end

function CropMain:getInfoFuzzySearch(str)
    local tab = {}
    for i, v in pairs(uq.cache.crop._allCropInfo) do
        local match_yes = string.match(v.name, str)
        if match_yes ~= nil then
            if v.name == str then
                table.insert(tab, 1, v)
            else
                table.insert(tab, v)
            end
        end
    end
    return tab
end

function CropMain:getSameForceCropInfo()
    return uq.cache.crop._allCropInfo
end

return CropMain
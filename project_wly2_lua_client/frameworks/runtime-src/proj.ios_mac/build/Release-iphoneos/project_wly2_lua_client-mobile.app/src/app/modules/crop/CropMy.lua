local CropMy = class("CropMy", require('app.modules.common.BaseViewWithHead'))

CropMy.RESOURCE_FILENAME = "crop/CropMy.csb"
CropMy.RESOURCE_BINDING = {
    ["Image_14"]                  = {["varname"] = "_imgListBg"},
    ["name_txt"]                  = {["varname"] = "_txtCropName"},
    ["lv_txt"]                    = {["varname"] = "_txtCropLevel"},
    ["member_txt"]                = {["varname"] = "_txtCropNum"},
    ["Text_1_0_0_0"]              = {["varname"] = "_txtCropDeclare"},
    ["Node_1"]                    = {["varname"] = "_nodeTopBtn"},
    ["Node_2"]                    = {["varname"] = "_nodeTwo"},
    ["Node_3"]                    = {["varname"] = "_nodeRight"},
    ["red_list_img"]              = {["varname"] = "_imgApplyRed"},
    ["Panel_1"]                   = {["varname"] = "_pnlTxt"},
    ["Text_2"]                    = {["varname"] = "_txtDecTitle"},
    ["Panel_8"]                   = {["varname"] = "_pnlList"},
    ["icon_spr"]                  = {["varname"] = "_sprIcon"},
    ["bg_spr"]                    = {["varname"] = "_sprIconBg"},
    ["head_bg_img"]               = {["varname"] = "_imgIconClick"},
    ["edit_btn"]                  = {["varname"] = "_btnEdit"},
    ["on_line_bg"]                = {["varname"] = "_imgLineBg"},
    ["on_line_img"]               = {["varname"] = "_imgLine"},
    ["on_line_btn"]               = {["varname"] = "_btnOnLine"},
    ["leader_1_btn"]              = {["varname"] = "_btnOperator1"},
    ["leader_2_btn"]              = {["varname"] = "_btnOperator2"},
    ["leader_3_btn"]              = {["varname"] = "_btnOperator3"},
    ["leader_4_btn"]              = {["varname"] = "_btnOperator4"},
    ["leader_5_btn"]              = {["varname"] = "_btnOperator5"},
    ["leader_6_btn"]              = {["varname"] = "_btnOperator6"},
    ["leader_img"]                = {["varname"] = "_imgOperator"},
    ["btn_node"]                  = {["varname"] = "_nodeBtn"},
    ["leader_node"]               = {["varname"] = "_nodeLeader"},
    ["click_pnl"]                 = {["varname"] = "_pnlClick"},
    ["Button_1_0"]                = {["varname"] = "_btnTech",["events"] = {{["event"] = "touch",["method"] = "onOpenTech"}}},
    -- ["Button_4"]                  = {["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Button_1_1"]                = {["varname"] = "_btnApplyList",["events"] = {{["event"] = "touch",["method"] = "onApplyList"}}},
    ["Button_1_0_0"]              = {["varname"] = "_btnLegionCampaign",["events"] = {{["event"] = "touch",["method"] = "onLegionCampaign"}}},
    ["Button_help"]               = {["varname"] = "_btnCropHelp",["events"] = {{["event"] = "touch",["method"] = "onHelp"}}},
    ["Button_4_0"]                = {["varname"] = "_btnCropSign",["events"] = {{["event"] = "touch",["method"] = "onSign"}}},
    ["Button_self"]               = {["varname"] = "_btnSelf",["events"] = {{["event"] = "touch",["method"] = "onJumpSelf"}}},
}

CropMy.TYPE_JOB = {
    LEADER    = 0,
    ASSISTANT = 1,
    MEMBERPOS = 7
}

function CropMy:ctor(name, params)
    CropMy.super.ctor(self, name, params)
    self._func = params.func
end

function CropMy:init()
    self._dataList = {}
    self._allData = {}
    self._curSelectIndex = 1
    self._txt = ""
    self._isShowAll = false
    self._memberPos = self.TYPE_JOB.MEMBERPOS
    self._operatorIdx = 0
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.CROP_MY)
    self:initList()
    self:initEdit()
    self:initBtn()
    self:refreshIcon()
    self:refreshOnLine()
    self._btnLegionCampaign:setVisible(false)
    self._imgApplyRed:setVisible(uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.CROP_APPLY])
    self._btnApplyList:setVisible(false)
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_CROP_INFO)
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_MEMBER, {crop_id = uq.cache.role.cropsId})
    self._imgIconClick:addClickEventListenerWithSound(function()
        if uq.cache.crop:getMyCropLeaderId() ~= uq.cache.role.id then
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_HEAD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, icon_id = uq.cache.crop._cropIconId, is_create = false})
    end)
    self._btnOnLine:addClickEventListenerWithSound(function()
        self:refreshOnLine()
    end)
    self._pnlClick:addClickEventListenerWithSound(function()
        self._nodeLeader:setVisible(false)
    end)
    uq.intoAction(self._nodeTwo, cc.p(-uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._nodeRight, cc.p(uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._nodeTopBtn, cc.p(0, uq.config.constant.MOVE_DISTANCE))
end

function CropMy:onCreate()
    CropMy.super.onCreate(self)
    self._eventRefreshTag = services.EVENT_NAMES.ON_CRROP_REFRESH_MY .. tostring(self)
    self._eventRefreshInfo = services.EVENT_NAMES.ON_LOAD_CROP_INFO .. tostring(self)
    self._eventLegionOpen = services.EVENT_NAMES.ON_LEGION_CAMPAIGN_OPEN .. tostring(self)
    self._eventApplyRed = services.EVENT_NAMES.ON_CROP_RED_APPLY .. tostring(self)
    self._eventChangeHead = services.EVENT_NAMES.ON_CROP_CHANGE_HEAD .. tostring(self)
    self._eventChangeInfo = services.EVENT_NAMES.ON_CRROP_CHANGE_INFO .. tostring(self)

    services:addEventListener(services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY, handler(self, self._onMembgerInfoEnd), "onCropAppointNotifyByInfo")
    network:addEventListener(Protocol.S_2_C_LOAD_CROP_INFO, handler(self, self._onCropInfo), self._eventRefreshInfo)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_REFRESH_MY, handler(self, self._onCropRefreshMy), self._eventRefreshTag)
    services:addEventListener(services.EVENT_NAMES.ON_LEGION_CAMPAIGN_OPEN, handler(self, self._onLegionCompaignOpen), self._eventLegionOpen)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_RED_APPLY, handler(self, self._onRefreshApplyRed), self._eventApplyRed)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_CHANGE_HEAD, handler(self, self.refreshIcon), self._eventChangeHead)
    services:addEventListener(services.EVENT_NAMES.ON_CRROP_CHANGE_INFO, handler(self, self.refreshCropInfo), self._eventChangeInfo)
end

function CropMy:_onMembgerInfoEnd(msg)
    self:loadMemberlist()
end

function CropMy:onExit()
    network:removeEventListenerByTag(self._eventRefreshInfo)
    services:removeEventListenersByTag("onCropAppointNotifyByInfo")
    services:removeEventListenersByTag(self._eventRefreshTag)
    services:removeEventListenersByTag(self._eventLegionOpen)
    services:removeEventListenersByTag(self._eventApplyRed)
    services:removeEventListenersByTag(self._eventChangeHead)
    services:removeEventListenersByTag(self._eventChangeInfo)
    if self._func then
        self._func()
    end
    CropMy.super:onExit()
end

function CropMy:loadMemberlist()
    self._dataList = self:dealData()
    self._listView:reloadData()
    self:refreshPage()
end

function CropMy:_onCropRefreshMy()
    self:loadMemberlist()
end

function CropMy:initBtn()
    self._btnOperator1:addClickEventListenerWithSound(function()
        local data = self._dataList[self._operatorIdx] or {}
        if not data or next(data) == nil then
            return
        end
    end)
    self._btnOperator2:addClickEventListenerWithSound(function()
        local data = self._dataList[self._operatorIdx] or {}
        if not data or next(data) == nil then
            return
        end
        if data.pos == 1 then
            uq.fadeInfo(string.format(StaticData["local_text"]["crop.appoint.des"], StaticData["local_text"]["crop.government.des7"]))
            return
        end
        network:sendPacket(Protocol.C_2_S_CROP_APPOINT, {role_id = data.id, pos = 1, city_id = 0})
        self._nodeLeader:setVisible(false)
    end)
    self._btnOperator3:addClickEventListenerWithSound(function()
        local data = self._dataList[self._operatorIdx] or {}
        if not data or next(data) == nil then
            return
        end
        if data.pos == 2 then
            uq.fadeInfo(string.format(StaticData["local_text"]["crop.appoint.des"], StaticData["local_text"]["crop.government.des8"]))
            return
        end
        network:sendPacket(Protocol.C_2_S_CROP_APPOINT, {role_id = data.id, pos = 2, city_id = 0})
        self._nodeLeader:setVisible(false)
    end)
    self._btnOperator4:addClickEventListenerWithSound(function()
        local data = self._dataList[self._operatorIdx] or {}
        if not data or next(data) == nil then
            return
        end
        network:sendPacket(Protocol.C_2_S_CROP_KICKOUT, {id = data.id})
        self._nodeLeader:setVisible(false)
    end)
    self._btnOperator5:addClickEventListenerWithSound(function()
        local data = self._dataList[self._operatorIdx] or {}
        if not data or next(data) == nil then
            return
        end
        local data = {
            id = data.id
        }
        network:sendPacket(Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID, data)
        self._nodeLeader:setVisible(false)
    end)
    self._btnOperator6:addClickEventListenerWithSound(function()
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_POP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            local is_leader = self:getMyPos() == self.TYPE_JOB.LEADER
            panel:setIsLeader(is_leader)
            if is_leader and #uq.cache.crop._allMemberInfo > 1 then
                panel:showCannotDismiss()
            elseif is_leader then
                panel:showDismiss()
            else
                panel:showDismissCD()
            end
        end
        self._nodeLeader:setVisible(false)
    end)
end

function CropMy:initList()
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

function CropMy:initEdit()
    local size = self._pnlTxt:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBox:setAnchorPoint(cc.p(0, 1))
    self._editBox:setFontName("font/fzlthjt.ttf")
    self._editBox:setFontSize(20)
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBox:setPosition(cc.p(0, size.height))
    self._editBox:setPlaceholderFontName("font/fzlthjt.ttf")
    self._editBox:setFontColor(uq.parseColor("#FFFFFF"))
    self._editBox:setPlaceholderFontSize(24)
    self._editBox:setMaxLength(36)
    self._editBox:registerScriptEditBoxHandler(function(eventname, sender) self:editboxHandle(eventname, sender) end)
    self._pnlTxt:addChild(self._editBox)
end

function CropMy:refreshIcon()
    local icon_bg, icon_icon = uq.cache.crop:getCropIcon()
    self._sprIcon:setTexture(icon_icon)
end

function CropMy:editboxHandle(event, sender)
    if event == "began" then
        self._editBox:setText(self._txt)
    elseif event == "ended" then
        local txt = self._editBox:getText()
        if txt == "" then
            return
        end
        if uq.hasKeyWord(txt) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        self._txt = txt
        self:sendMsg()
    end
end

function CropMy:sendMsg()
    local tab = {
        len = string.len(self._txt),
        board_msg = self._txt,
    }
    network:sendPacket(Protocol.C_2_S_MODIFY_BOARD_MESSAGE, tab)
end

function CropMy:_onCropInfo(msg)
    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    if next(crop_info) ~= nil and uq.cache.role.cropsId == msg.data.id then
        self._txtCropName:setString(crop_info.name)
        self._txtCropLevel:setString(tostring(crop_info.level))
        self._txtCropNum:setString(#uq.cache.crop._allMemberInfo  .. "/" .. crop_info.max_mem_num)
        self._editBox:setText(msg.data.board_msg)
        local is_leader = uq.cache.role.id == msg.data.leader_id
        self._editBox:setEnabled(uq.cache.role.id == msg.data.leader_id)
        self._btnApplyList:setVisible(is_leader)
        self._txtDecTitle:setVisible(is_leader)
        self._btnEdit:setVisible(is_leader)
        self._txt = msg.data.board_msg
    end
end

function CropMy:refreshCropInfo()
    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    if not crop_info or next(crop_info) == nil then
        return
    end
    self._txtCropLevel:setString(tostring(crop_info.level))
end

function CropMy:refreshPage()
    network:sendPacket(Protocol.C_2_S_LOAD_CROP_INFO, {id = uq.cache.role.cropsId})
end

function CropMy:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    self._curSelectIndex = index
end

function CropMy:cellSizeForTable(view, idx)
    return 880, 90
end

function CropMy:numberOfCellsInTableView(view)
    return #self._dataList
end

function CropMy:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("crop.CropMyCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(self._dataList[index], index, handler(self, self.openBtnLayerByIdx))

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function CropMy:getMyCellIndex()
    for i,v in ipairs(self._dataList) do
        if v.id == uq.cache.role.id then
            return i
        end
    end
    return 0
end

function CropMy:getMyPos()
    for i,v in ipairs(self._dataList) do
        if v.id == uq.cache.role.id then
            return v.pos
        end
    end
    return self._memberPos
end

function CropMy:onApplyList(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_APPLY_LIST, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function CropMy:onGetReward(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_POP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:showReward()
        end
    end
end

function CropMy:onLegionCampaign(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_BOSS_LOAD, {})
    end
end

function CropMy:_onLegionCompaignOpen(msg)
    --军团长选择军团副本界面
    local last_music = uq.getLastMusic()
    local func = function ()
        if last_music ~= "" then
            uq.playBackGroundMusic(last_music)
        end
    end
    if msg.data.cur_instance_id == 0 then
        if uq.cache.role.id == uq.cache.crop:getMyCropLeaderId() then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.LEGION_CAMPAIGN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, func = func})
        else
            uq.fadeInfo(StaticData['local_text']['legion.campaign.open.not'])
        end
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.LEGION_CAMPAIGN_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, func = func})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CUR_LEGION_CAMPAIGN, data = msg.data.cur_instance_id})
    end
    uq.playSoundByID(112)
end

function CropMy:_onRefreshApplyRed(msg)
    self._imgApplyRed:setVisible(uq.cache.hint_status.status[msg.data])
end

function CropMy:onOpenTech(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_TECH, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function CropMy:refreshOnLine()
    local is_all = not self._isShowAll
    self._imgLineBg:setVisible(is_all)
    self._imgLine:setVisible(not is_all)
    self._isShowAll = is_all
    self:loadMemberlist()
end

function CropMy:dealData()
    local tab = {}
    local leader_id = uq.cache.crop:getMyCropLeaderId()
    for i, v in ipairs(uq.cache.crop._allMemberInfo) do
        if self._isShowAll or (not self._isShowAll and (v.is_online == 1 or v.id == uq.cache.role.id)) then
            if v.id == leader_id then
                table.insert(tab, 1, v)
            else
                table.insert(tab, v)
            end
        end
    end
    return tab
end

function CropMy:openBtnLayerByIdx(index)
    local data = self._dataList[index] or {}
    if not data or next(data) == nil then
        return
    end
    self._operatorIdx = index
    self._nodeLeader:setVisible(true)
    local tab = self:getBtnlistByJob(data.pos, data.id)
    local idx = 1
    for i = 1, 6 do
        local is_show = i == tab[idx]
        self["_btnOperator" .. i]:setVisible(is_show)
        if is_show then
            self["_btnOperator" .. i]:setPosition(cc.p(0, -(idx - 1) * 65))
            idx = idx + 1
        end
    end
    self._imgOperator:setContentSize(cc.size(199, idx * 65 - 35))
end

function CropMy:getBtnlistByJob(pos, id)
    if id == uq.cache.role.id then
        return {6}
    end
    local my_pox = self:getMyPos()
    if my_pox == self._memberPos or my_pox >= pos then
        return {5}
    end
    if my_pox == self.TYPE_JOB.LEADER then
        return {2, 3, 4, 5}
    elseif my_pox == self.TYPE_JOB.ASSISTANT then
        return {3, 4, 5}
    end
    return {4, 5}
end

function CropMy:onHelp(event)
    if event.name == "ended" then
        uq.jumpToModule(uq.config.constant.MODULE_ID.CROP_HELP)
    end
end

function CropMy:onJumpSelf(event)
    if event.name ~= "ended" then
        return
    end
    if #self._dataList < 5 then
        return
    end
    local offset = self._listView:getContentOffset();
    local index = 0
    for k, v in ipairs(self._dataList) do
        if v.id == uq.cache.role.id then
            index = k
            break
        end
    end
    offset.y = -(#self._dataList - index) * 90
    if index * 90 < 450 then
        offset.y = offset.y + (460 - index * 90)
    end
    self._listView:setContentOffset(offset)
end

function CropMy:onSign(event)
    if event.name == "ended" then
        uq.jumpToModule(uq.config.constant.MODULE_ID.CROP_SIGN)
    end
end

return CropMy
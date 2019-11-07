local GeneralPoolModule = class("GeneralPoolModule", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

GeneralPoolModule.RESOURCE_FILENAME = "generals/GeneralPool.csb"
GeneralPoolModule.RESOURCE_BINDING = {
    ["img_bg_adapt"]                                                                            = {["varname"] = "_imgBg"},
    ["Node_left"]                                                                               = {["varname"] = "_nodeLeftMiddle"},
    ["Node_left/Panel_recommend_genenral/Panel_action"]                                         = {["varname"] = "_panelRcmdAction"},
    ["Node_left/Panel_recommend_genenral/Image_describe"]                                       = {["varname"] = "_imgRcmdDesc"},
    ["Node_left/Panel_recommend_genenral/Panel_recommend_info"]                                 = {["varname"] = "_panelRcmdInfo"},
    ["Node_left/Panel_recommend_genenral/Panel_recommend_info/Image_recommend_info_bg"]         = {["varname"] = "_imgRcmdInfoBg"},
    ["Node_left/Panel_recommend_genenral/Panel_recommend_info/Image_recommend_rarity"]          = {["varname"] = "_imgRcmdInfoRarity"},
    ["Node_left/Panel_recommend_genenral/Panel_recommend_info/Image_recommend_info_name"]       = {["varname"] = "_imgRcmdInfoName"},
    ["Node_left/Panel_recommend_genenral/Panel_recommend_info/Button_recommend_info"]           = {["varname"] = "_btnRcmdInfo", ["events"] = {{["event"] = "touch",["method"] = "_onOpenRcmdInfo"}}},
    ["Node_mid/Panel_pool_info/Image_title"]                                                    = {["varname"] = "_imgPoolTitle"},
    ["Node_mid/Panel_pool_info/Text_left_time"]                                                 = {["varname"] = "_txtPoolLeftTime"},
    ["Node_mid/Panel_pool_info/Panel_listview"]                                                 = {["varname"] = "_panelPoolListView"},
    ["Node_mid/Panel_pool_info/Panel_listview/Button_pool_info"]                                = {["varname"] = "_btnPoolInfo",  ["events"] = {{["event"] = "touch",["method"] = "_onOpenPoolInfo",["sound_id"] = 0}}},
    ["Node_mid/Panel_pool_info/Text_tip"]                                                       = {["varname"] = "_txtPoolTip"},
    ["Node_mid/Panel_pool_info/Image_tip"]                                                      = {["varname"] = "_imgPoolTip"},
    ["Node_mid/Panel_pool_info/Panel_appoint/Image_appoint_left_bg"]                            = {["varname"] = "_imgPoolLeftAppoint"},
    ["Node_mid/Panel_pool_info/Panel_appoint/Image_appoint_left_bg/Button_appoint"]             = {["varname"] = "_btnPoolLeftAppoint", ["events"] = {{["event"] = "touch",["method"] = "_onPoolAppointLeft",["sound_id"] = 0}}},
    ["Node_mid/Panel_pool_info/Panel_appoint/Image_appoint_right_bg"]                           = {["varname"] = "_imgPoolRightAppoint"},
    ["Node_mid/Panel_pool_info/Panel_appoint/Image_appoint_right_bg/Button_appoint"]            = {["varname"] = "_btnPoolRightAppoint", ["events"] = {{["event"] = "touch",["method"] = "_onPoolAppointRight",["sound_id"] = 0}}},
    ["Node_right_bottom"]                                                                       = {["varname"] = "_nodeRightBottom"},
    ["Node_right_bottom/Panel_pools"]                                                           = {["varname"] = "_panelPools"},
    ["Node_action_bg"]                                                                          = {["varname"] = "_nodeActionBg"},
    ["Node_action_title"]                                                                       = {["varname"] = "_nodeActionTitle"},
}
function GeneralPoolModule:ctor(name, params)
    GeneralPoolModule.super.ctor(self, name, params)
    uq.AnimationManager:getInstance():getEffect('txf_100_1', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('txf_100_2', nil, nil, true)
end

function GeneralPoolModule:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self:adaptNode()
    self:addShowCoinGroup({{type = uq.config.constant.COST_RES_TYPE.MATERIAL, id = uq.config.constant.MATERIAL_TYPE.GENENRAL_VOURCHER}, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.GENERAL_POOL)
    self:setTitle(uq.config.constant.MODULE_ID.TAVERN_VIEW)

    self._curTabIndex = 1
    self._allPoolsItems = {}
    self:getCurData()
    self:initPoolTableView()
    self:initRewardTableView()
    self:refreshPage()
    self._poolsTableView:reloadData()

    services:addEventListener(services.EVENT_NAMES.ON_GENERAL_EXTRACT_RESULT, handler(self, self._onExtractResult), "on_extract_result" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_GENERAL_POOL_CHANGE, handler(self, self._onPoolChange), "on_pool_change" .. tostring(self))
    network:addEventListener(Protocol.S_2_C_BUY_APPOINT_TIMES, handler(self, self._onBuyItem), "on_buy_item" .. tostring(self))
    uq:addEffectByNode(self._nodeActionBg, 900182, -1, true, cc.p(0, 0))
    uq:addEffectByNode(self._nodeActionTitle, 900183, -1, true, cc.p(0, 0))
    if not self._poolData or #self._poolData < 1 then
        uq.fadeInfo(StaticData['local_text']['label.bosom.module.not.open'])
        return
    end
end

function GeneralPoolModule:getCurData()
    self._poolData = {}
    local all_data = uq.cache.generals:GetGeneralPoolInfo()
    if all_data == nil then
        return
    end
    for i = 1, #all_data do
        local server_time = uq.cache.server_data:getServerTime()
        local left_time = all_data[i].duration == 0 and all_data[i].duration or (all_data[i].duration - server_time)
        if left_time > 0 or all_data[i].duration == -1 then
            table.insert(self._poolData, all_data[i])
        end
    end
end

function GeneralPoolModule:_onBuyItem(msg)
    self:refreshCostPanel()
    uq.fadeInfo(StaticData['local_text']['ancient.city.add.num.des3'])
end

function GeneralPoolModule:initRewardTableView()
    local size = self._panelPoolListView:getContentSize()
    self._rewardTableView = cc.TableView:create(cc.size(size.width, size.height))
    self._rewardTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._rewardTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._rewardTableView:setPosition(cc.p(0, 0))
    self._rewardTableView:setDelegate()
    self._rewardTableView:registerScriptHandler(handler(self, self.tableCellTouchedContent), cc.TABLECELL_TOUCHED)
    self._rewardTableView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._rewardTableView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._rewardTableView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelPoolListView:addChild(self._rewardTableView)
end

function GeneralPoolModule:tableCellTouchedContent(view, cell, touch)
end

function GeneralPoolModule:cellSizeForTableContent(view, idx)
    return 100, 120
end

function GeneralPoolModule:numberOfCellsInTableViewContent(view)
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return 0
    end
    local rwds_data = self._poolData[self._curTabIndex].xml.showRwd
    if rwds_data == nil or rwds_data == "" then
        return 0
    end
    local rwds_data_list = string.split(rwds_data, '|')
    return #rwds_data_list
end

function GeneralPoolModule:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    local info = nil
    if self._poolData or not self._poolData[self._curTabIndex] and self._poolData[self._curTabIndex].xml.showRwd ~= nil and self._poolData[self._curTabIndex].xml.showRwd ~= "" then
        local rwds_data = self._poolData[self._curTabIndex].xml.showRwd
        local rwds_data_list = string.split(rwds_data, '|')
        local cur_rwd_data_list = string.split(rwds_data_list[index], ';')
        info = {}
        info.type = tonumber(cur_rwd_data_list[1])
        info.num = tonumber(cur_rwd_data_list[2])
        info.id = tonumber(cur_rwd_data_list[3])
    end

    if not cell then
        cell = cc.TableViewCell:new()
        local euqip_item = nil
        if info ~= nil then
            euqip_item = EquipItem:create({info = info})
            euqip_item:enableEvent(nil, function(equip_info)
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
                uq.showItemTips(equip_info)
            end)
        else
            euqip_item = EquipItem:create()
        end
        euqip_item:setVisible(info ~= nil)
        euqip_item:setScale(0.7)
        euqip_item:setPosition(cc.p(50, 60))
        cell:addChild(euqip_item, 1)
        euqip_item:setTag(1000)
    else
        local euqip_item = cell:getChildByTag(1000)
        if info ~= nil then
            euqip_item:setInfo(info)
            euqip_item:setVisible(true)
        elseif euqip_item then
            euqip_item:setVisible(false)
        end
        euqip_item:enableEvent(nil, function(equip_info)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            uq.showItemTips(equip_info)
        end)
    end
    return cell
end

function GeneralPoolModule:initPoolTableView()
    local size = self._panelPools:getContentSize()
    self._poolsTableView = cc.TableView:create(cc.size(size.width, size.height))
    self._poolsTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._poolsTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._poolsTableView:setPosition(cc.p(0, 0))
    self._poolsTableView:setDelegate()
    self._poolsTableView:registerScriptHandler(handler(self, self.tableCellTouchedPools), cc.TABLECELL_TOUCHED)
    self._poolsTableView:registerScriptHandler(handler(self, self.cellSizeForTablePools), cc.TABLECELL_SIZE_FOR_INDEX)
    self._poolsTableView:registerScriptHandler(handler(self, self.tableCellAtIndexPools), cc.TABLECELL_SIZE_AT_INDEX)
    self._poolsTableView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewPools), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelPools:addChild(self._poolsTableView)
end

function GeneralPoolModule:tableCellTouchedPools(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByTag(1000)
    if item == nil then
        return
    end
    local pos = item:convertToNodeSpace(touch_point)
    local width = item:getCellSize().width
    local height = item:getCellSize().height
    local rect = cc.rect(0 , 0 , width , height )
    if cc.rectContainsPoint(rect, pos) then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
        if self._curTabIndex == index then
            return
        end
        for _,v in pairs(self._allPoolsItems) do
            v:setSelected(false)
        end
        self._curTabIndex = index
        self:refreshPage()
        item:setSelected(true)
    end
end

function GeneralPoolModule:cellSizeForTablePools(view, idx)
    return 138, 95
end

function GeneralPoolModule:numberOfCellsInTableViewPools(view)
    return self._poolData == nil and 0 or #self._poolData
end

function GeneralPoolModule:tableCellAtIndexPools(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    local info = self._poolData

    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = uq.createPanelOnly("generals.GeneralPoolCell")
        cell:addChild(cell_item)
        table.insert(self._allPoolsItems, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setSelected(index == self._curTabIndex)
    cell_item:setTag(1000)
    cell_item:setData(info[index])

    return cell
end

function GeneralPoolModule:refreshPage()
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_data = self._poolData[self._curTabIndex]
    self._imgRcmdDesc:loadTexture("img/general_pool/" .. cur_data.xml.bgText)
    self._imgPoolTitle:loadTexture("img/general_pool/" .. cur_data.xml.titleImg)
    self:refreshDesc()
    self:refreshTimerLeftTime()
    self:refreshCostPanel()
    self._rewardTableView:reloadData()

    --加载武将动画
    local mainGeneral = string.split(cur_data.xml.mainGeneral, ';')
    local generals_xml = StaticData.getCostInfo(tonumber(mainGeneral[1]), tonumber(mainGeneral[3]))
    self._panelRcmdAction:removeAllChildren()
    local pre_path = "animation/spine/" .. generals_xml.imageId .. '/' .. generals_xml.imageId
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        self._panelRcmdAction:addChild(anim)
        anim:setScale(generals_xml.imageRatio)
        anim:setPosition(cc.p(generals_xml.imageX * 3 / 4, generals_xml.imageY))
        anim:setAnimation(0, 'idle', true)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelRcmdAction:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        local size = self._panelRcmdAction:getContentSize()
        img:setScale(generals_xml.imageRatio)
        img:setPosition(cc.p(size.width * 0.3 + generals_xml.imageX, size.height + generals_xml.imageY))
    end

    --加载武将信息(如果有指定的话)
    local show_rcmd_info = cur_data.xml.mainGeneralInfo ~= nil and cur_data.xml.mainGeneralInfo ~= ""
    self._panelRcmdInfo:setVisible(show_rcmd_info)
    if show_rcmd_info then
        mainGeneral = string.split(cur_data.xml.mainGeneralInfo, ';')
        generals_xml = StaticData.getCostInfo(tonumber(mainGeneral[1]), tonumber(mainGeneral[3]))
        local generals_grade = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
        if not generals_grade then
            uq.log("error  MapGuideInfo updateGeneralInfo  ",generals_xml)
            return
        end
        self._imgRcmdInfoRarity:loadTexture("img/generals/" .. generals_grade.image)
        self._imgRcmdInfoName:loadTexture("img/general_pool/" .. generals_xml.nameImage)
        local name_size = self._imgRcmdInfoName:getContentSize()
        self._panelRcmdInfo:setContentSize(cc.size(self._panelRcmdInfo:getContentSize().width, name_size.height + 113))
        self._imgRcmdInfoRarity:setPositionY(name_size.height + 116)
        self._imgRcmdInfoBg:setPositionY(name_size.height + 113)
    end
    uq.cache.generals:addGeneralPoolRedInfo(cur_data)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

function GeneralPoolModule:refreshTimerLeftTime()
    uq.TimerProxy:removeTimer("update_timer_left_time" .. tostring(self))
    self:setLeftTimeTxt()
    uq.TimerProxy:addTimer("update_timer_left_time" .. tostring(self), handler(self, self.setLeftTimeTxt), 1, -1)
end

function GeneralPoolModule:setLeftTimeTxt()
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_data_duration = self._poolData[self._curTabIndex].duration
    local str_left_time = StaticData['local_text']['instance.not.limit']
    if cur_data_duration >= 0 then
        local server_time = uq.cache.server_data:getServerTime()
        local left_time = cur_data_duration == 0 and cur_data_duration or (cur_data_duration - server_time)
        local hours, minutes, seconds, day = uq.getTime(left_time >= 0 and left_time or 0)
        if day >= 1 then
            str_left_time = day .. StaticData['local_text']['label.common.day']
        elseif hours >= 1 then
            str_left_time = hours .. StaticData['local_text']['label.train.time.hour']
        elseif minutes >= 1 then
            str_left_time = minutes .. StaticData['local_text']['label.train.time.minute']
        else
            str_left_time = seconds .. StaticData['local_text']['label.common.second']
        end
        if left_time <= 0 and cur_data_duration ~= -1 then
            self:onPoolEnd(self._poolData[self._curTabIndex].id)
        end
    end
    str_left_time = " " .. str_left_time
    self._txtPoolLeftTime:setHTMLText(string.format(StaticData['local_text']['general.pool.left.time'], str_left_time))
end

function GeneralPoolModule:refreshTimerFree()
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    --处理无免费情况
    local cur_data = self._poolData[self._curTabIndex]
    if cur_data.xml.freeCD == 0 then
        self._imgPoolLeftAppoint:getChildByName('Text_free_time'):setVisible(false)
        return
    end
    --处理免费情况
    local free_state = cur_data.cd_time <= 0 or cur_data.time - os.time() < 0
    self._imgPoolLeftAppoint:getChildByName('Text_free_time'):setVisible(not free_state)
    self:setCostInfo(self._imgPoolLeftAppoint, cur_data.xml.costOne, cur_data.xml.costOnePrice, free_state)
    if free_state then
        return
    end
    --处理免费在cd中情况
    self:setFreeCDTxt()
    uq.TimerProxy:addTimer("update_timer_free" .. tostring(self), handler(self, self.setFreeCDTxt), 1, -1)
end

function GeneralPoolModule:refreshCostPanel()
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_data = self._poolData[self._curTabIndex]
    self:setCostInfo(self._imgPoolLeftAppoint, cur_data.xml.costOne, cur_data.xml.costOnePrice)
    self:setCostInfo(self._imgPoolRightAppoint, cur_data.xml.costTen, cur_data.xml.costTenPrice)
    self:refreshTimerFree()
end

function GeneralPoolModule:setFreeCDTxt()
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_data_free = self._poolData[self._curTabIndex].time - os.time()
    if cur_data_free < 0 then
        self:refreshTimerFree()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_POOL_RED_REFRESH})
        return
    end
    local hours, minutes, seconds, day = uq.getTime(cur_data_free)
    local str_left_time = string.format("%02d", hours) .. ":" .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)
    self._imgPoolLeftAppoint:getChildByName('Text_free_time'):setHTMLText(string.format(StaticData['local_text']['general.pool.free.time'], str_left_time))
end

function GeneralPoolModule:setCostInfo(parent, cost_data, pre_cost_data, is_free)
    local txt_cost_real = parent:getChildByName('Text_cost_real')
    local txt_cost_previous = parent:getChildByName('Text_cost_previous')
    local img_cost = parent:getChildByName('Image_cost')
    local img_discount = parent:getChildByName('Image_discount')
    local txt_discount = parent:getChildByName('Text_discount')
    local img_abandon = parent:getChildByName('Image_abandon')
    local img_red = parent:getChildByName('Image_red')
    txt_cost_previous:setVisible(false)
    img_discount:setVisible(false)
    txt_discount:setVisible(false)
    img_abandon:setVisible(false)
    img_cost:setVisible(not is_free)
    local cost_info_list = string.split(cost_data, ';')
    local cost_info = StaticData.getCostInfo(tonumber(cost_info_list[1]), tonumber(cost_info_list[3]))
    local miniIcon = cost_info and cost_info.miniIcon or "03_0002.png"
    img_cost:loadTexture('img/common/ui/' .. miniIcon)
    if is_free then
        txt_cost_real:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
    else
        txt_cost_real:setString(cost_info_list[2])
    end

    --初始化位置
    local parent_size = parent:getContentSize()
    txt_cost_real:setPositionX(parent_size.width / 2)
    local img_cost_size = img_cost:getContentSize()
    local txt_cost_real_size = txt_cost_real:getContentSize()
    img_cost:setPositionX((parent_size.width - txt_cost_real_size.width - img_cost_size.width) / 2 - 20)
    self:checkPrice(txt_cost_real, cost_info_list, is_free)
    if img_red then
        img_red:setVisible(is_free)
    end
    if is_free then
        return
    end
    --处理减价的情况
    local has_pre_cost = not(pre_cost_data == nil or pre_cost_data == "")
    if not has_pre_cost then
        return
    end
    txt_cost_previous:setVisible(has_pre_cost)
    img_discount:setVisible(has_pre_cost)
    txt_discount:setVisible(has_pre_cost)
    img_abandon:setVisible(has_pre_cost)
    txt_cost_real:setPositionX((parent_size.width + txt_cost_real_size.width + img_cost_size.width) / 2 + 20)
    img_abandon:setContentSize(cc.size(txt_cost_real_size.width + 10, img_abandon:getContentSize().height))
    local pre_cost_info_list = string.split(pre_cost_data, ';')
    txt_cost_previous:setString(pre_cost_info_list[2])
    local discount = math.floor(tonumber(cost_info_list[2]) / tonumber(pre_cost_info_list[2]) * 10)
    local discount_str = string.format("%d%s", discount, StaticData['local_text']['activity.discount'])
    txt_discount:setString(discount_str)
end

function GeneralPoolModule:refreshDesc()
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_pool_data = self._poolData[self._curTabIndex]
    local tip_str = tostring(cur_pool_data.secure == nil and 0 or cur_pool_data.secure)
    if cur_pool_data.xml.secureAppointId == 0 then
        if uq.cache.world_war.world_enter_info and uq.cache.world_war.world_enter_info.season_id then
            local war_tasks_stage = StaticData['war_task'][uq.cache.world_war.world_enter_info.season_id].Stage
            for k, v in pairs(war_tasks_stage) do
                if v.generalAppointId == cur_pool_data.id then
                    tip_str = v.title
                    break
                end
            end
        else
            local war_tasks_stage = StaticData['war_task']
            for k, v in pairs(war_tasks_stage) do
                for _, item in pairs(v.Stage) do
                    if item.generalAppointId == cur_pool_data.id then
                        tip_str = item.title
                        break
                    end
                end
            end
        end
    end
    if tip_str == "0" then
        tip_str = cur_pool_data.xml.secureDesc
    else
        tip_str = string.format(cur_pool_data.xml.desc, tip_str)
    end
    self._txtPoolTip:setHTMLText(tip_str)
    local tip_size = self._txtPoolTip:getContentSize()
    local tip_positionX = self._txtPoolTip:getPositionX()
    self._imgPoolTip:setPositionX(tip_positionX - tip_size.width / 2 - 20)
end

function GeneralPoolModule:checkPrice(txt_node, price_info_list, is_free)
    local color_str = "#FAF3EB"
    txt_node.is_enough = true
    if not is_free then
        local is_enough = uq.cache.role:checkRes(tonumber(price_info_list[1]),tonumber(price_info_list[2]) ,tonumber(price_info_list[3]))
        if not is_enough then
            txt_node.is_enough = false
            color_str = "#f10000"
        end
    end
    txt_node:setTextColor(uq.parseColor(color_str))
end

function GeneralPoolModule:_onOpenRcmdInfo(evt)
    if evt.name ~= "ended" then
        return
    end
    if not self._poolData or not self._poolData[self._curTabIndex] then
        return
    end
    local cur_data = self._poolData[self._curTabIndex]
    local show_rcmd_info = cur_data.xml.mainGeneralInfo ~= nil and cur_data.xml.mainGeneralInfo ~= ""
    if show_rcmd_info then
        local mainGeneral = string.split(cur_data.xml.mainGeneralInfo, ';')
        local info = {}
        info.type = tonumber(mainGeneral[1])
        info.num = tonumber(mainGeneral[2])
        info.id = tonumber(mainGeneral[3])
        uq.showItemTips(info)
    end
end

function GeneralPoolModule:_onOpenPoolInfo(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_POOL_PREVIEW_MODULE, {pool_id = self._poolData[self._curTabIndex].id})
end

function GeneralPoolModule:_onPoolAppointLeft(event)
    if event.name ~= "ended" then
        return
    end
    local is_enough = event.target:getParent():getChildByName('Text_cost_real').is_enough
    self:onExtract(0, is_enough)
end

function GeneralPoolModule:_onPoolAppointRight(event)
    if event.name ~= "ended" then
        return
    end
    local is_enough = event.target:getParent():getChildByName('Text_cost_real').is_enough
    self:onExtract(1, is_enough)
end

function GeneralPoolModule:onExtract(tag, is_enough)
    local price_info = self._poolData[self._curTabIndex]
    if (tag == 0 and price_info.xml.freeCD > 0 and price_info.time - os.time() <= 0) or is_enough then
        network:sendPacket(Protocol.C_2_S_APPOINT_GENERAL, {pool_id = price_info.id, is_ten = tag})
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    else
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        local data = StaticData['general_appoint'].BuyCard[1]
        local info = {
            item_info = data.buyOneWhat,
            coin_info = data.buyOneCard,
            discount_info = data.buyTenCard
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_VOUCHERS, {data = info})
    end
end

function GeneralPoolModule:_onExtractResult(msg)
    local data = msg.data
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_POOL_EXTRACT_RESULT)
    if panel then
        panel:setData(data)
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_POOL_EXTRACT_RESULT, {data = data})
    end
    self:getCurData()
    self:refreshDesc()
    self:refreshTimerLeftTime()
    self:refreshCostPanel()
    self._poolsTableView:reloadData()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

function GeneralPoolModule:_onPoolChange(msg)
    self:getCurData()
    self:refreshDesc()
    self:refreshTimerLeftTime()
    self:refreshCostPanel()
    self._poolsTableView:reloadData()
end

function GeneralPoolModule:onPoolEnd(pool_id)
    self:getCurData()
    if not self._poolData then
        return
    end
    local pool_found = false
    for k, v in pairs(self._poolData) do
        if v.id == pool_id then
            self._curTabIndex = k
            pool_found = true
        end
    end
    if pool_found == false then
        self._curTabIndex = 1
    end
    self:refreshPage()
    self._poolsTableView:reloadData()
    uq.cache.generals:clearGeneralPoolRedInfoByDuration()
end

function GeneralPoolModule:dispose()
    uq.TimerProxy:removeTimer("update_timer_left_time" .. tostring(self))
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    services:removeEventListenersByTag("on_pool_change" .. tostring(self))
    services:removeEventListenersByTag("on_extract_result" .. tostring(self))
    network:removeEventListenerByTag("on_buy_item" .. tostring(self))
    uq.cache.generals:writeGeneralPoolRedFile()
    GeneralPoolModule.super.dispose(self)
end

return GeneralPoolModule
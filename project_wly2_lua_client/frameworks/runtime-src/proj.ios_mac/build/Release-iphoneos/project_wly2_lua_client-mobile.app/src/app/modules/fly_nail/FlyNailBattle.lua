local FlyNailBattle = class("FlyNailBattle", require("app.base.PopupBase"))

local DraftGeneralHeadItem = require("app.modules.equip.DraftGeneralHeadItem")
local EquipItem = require("app.modules.common.EquipItem")

FlyNailBattle.RESOURCE_FILENAME = "fly_nail/FlyNailBattle.csb"

FlyNailBattle.RESOURCE_BINDING  = {
    ["Panel_1/Panel_role"]                          ={["varname"] = "_panelRole"},
    ["Panel_1/btn_close"]                           ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Panel_1/label_name"]                          ={["varname"] = "_nameLabel"},
    ["Panel_1/Node_battle"]                         ={["varname"] = "_battleNode"},
    ["Panel_1/Node_battle/lbl_government"]          ={["varname"] = "_governmentLabel"},
    ["Panel_1/Node_battle/lbl_name"]                ={["varname"] = "_generalNameLabel"},
    ["Panel_1/lbl_des1"]                            ={["varname"] = "_desLabel1"},
    ["Panel_1/lbl_des2"]                            ={["varname"] = "_desLabel2"},
    ["Panel_1/lbl_des3"]                            ={["varname"] = "_desLabel3"},
    ["Panel_1/lbl_rewarddes"]                       ={["varname"] = "_rewardLabel"},
    ["Panel_1/Panel_item"]                          ={["varname"] = "_panelItem"},
    ["Panel_1/btn_battle"]                          ={["varname"] = "_btnBattle",["events"] = {{["event"] = "touch",["method"] = "_onBtnBattle"}}},
    ["Panel_1/Node_soldier"]                        ={["varname"] = "_nodeSoldier"},
    ["Panel_1/Node_soldier/lbl_require1"]           ={["varname"] = "_requireLabel1"},
    ["Panel_1/Node_soldier/lbl_require2"]           ={["varname"] = "_requireLabel2"},
    ["Panel_1/Node_soldier/lbl_require3"]           ={["varname"] = "_requireLabel3"},
    ["Panel_1/Node_soldier/lbl_require4"]           ={["varname"] = "_requireLabel4"},
    ["Panel_1/Node_soldier/lbl_times"]              ={["varname"] = "_timesLabel"},
    ["Panel_1/Node_soldier/btn_traning"]            ={["varname"] = "_btnTraning",["events"] = {{["event"] = "touch",["method"] = "_onBtnTraning"}}},
    ["Panel_1/Node_soldier/Image_generla1"]         ={["varname"] = "_imgChanges1"},
    ["Panel_1/Node_soldier/Image_generla2"]         ={["varname"] = "_imgChanges2"},
    ["Panel_1/Node_soldier/btn_getReward"]          ={["varname"] = "_btnGetReward",["events"] = {{["event"] = "touch",["method"] = "_onBtnGetReward"}}},
    ["Panel_1/Node_soldier/Panel_hero1"]            ={["varname"] = "_panelHero1"},
    ["Panel_1/Node_soldier/Panel_hero2"]            ={["varname"] = "_panelHero2"},
}

function FlyNailBattle:ctor(name, args)
    FlyNailBattle.super.ctor(self, name, args)
    self._info = args.info
    self._requireArray = {}
    self._reward = {}
    self._itemData = {}
    self._generalId1 = 0
    self._generalId2 = 0
    self._timeId = 1
    self._canTraing = false
    self._btnBattlePosX = self._btnBattle:getPositionX()
    self._nodeBattlePosX = self._battleNode:getPositionX()
end

function FlyNailBattle:init()
    self:parseView()
    self:centerView()
    self:initDialog()
    self:initProtocolData()
end

function FlyNailBattle:initDialog()
    self._btnBattle:setPressedActionEnabled(true)
    self._btnTraning:setPressedActionEnabled(true)
    self._btnGetReward:setPressedActionEnabled(true)
    self._panelRole:setTouchEnabled(true)
    local troop_xml = StaticData['eight_diagrams'].Troop[self._info.xml.troop]
    self._panelRole:addClickEventListenerWithSound(function(sender)
        if troop_xml == nil then
            uq.log("error  FlyNailBattle", self._info.xml.troop)
        end
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RANK_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            local general_array = {}
            for k, v in pairs(troop_xml.Army) do
                local data = {
                    rtemp_id = v.generalId,
                    level = v.level,
                    general_id = v.generalId,
                    name = v.name,
                    grade = v.grade
                }
                table.insert(general_array, data)
            end
            local data = {
                is_general = true,
                crop_name = "",
                role_name = troop_xml.name,
                country_id = uq.cache.role.country_id,
                general_id = troop_xml.generalId,
                role_lvl = troop_xml.level,
                power = troop_xml.power,
                generals = general_array
            }
            panel:setData(data)
        end
    end)
    table.insert(self._requireArray, self._requireLabel1)
    table.insert(self._requireArray, self._requireLabel2)
    table.insert(self._requireArray, self._requireLabel3)
    table.insert(self._requireArray, self._requireLabel4)
    self._nameLabel:setString(self._info.xml.name)
    self._generalNameLabel:setString(troop_xml.name)
    self._governmentLabel:setString(troop_xml.government)
    self._governmentLabel:getVirtualRenderer():setLineHeight(26)
    self._governmentLabel:setString(troop_xml.government)
    self._desArray = {}
    table.insert(self._desArray, self._desLabel1)
    table.insert(self._desArray, self._desLabel2)
    table.insert(self._desArray, self._desLabel3)
    local des_array = string.split(self._info.xml.desc, ";")
    for k, v in ipairs(self._desArray) do
        v:setString(des_array[k])
    end
    self._imgChanges1:setTouchEnabled(true)
    self._imgChanges1:addClickEventListenerWithSound(function(sender)
        self:onChangeTring()
    end)
    self._imgChanges2:setTouchEnabled(true)
    self._imgChanges2:addClickEventListenerWithSound(function(sender)
        self:onChangeTring()
    end)
    local general_xml = StaticData['general'][troop_xml.generalId]
    local pre_path = "animation/spine/" .. general_xml.imageId .. '/' .. general_xml.imageId
    local scale = 0.8
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        anim:setAnimation(0, 'idle', true)
        anim:setPosition(cc.p(general_xml.imageX * scale - 200, general_xml.imageY * scale - 90))
        anim:setScale(general_xml.imageRatio * scale)
        self._panelRole:addChild(anim)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelRole:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        local size = self._panelRole:getContentSize()
        img:setScale(general_xml.imageRatio * scale)
        img:setPosition(cc.p(size.width * 0.5 + general_xml.imageX * scale - 50, size.height + general_xml.imageY * scale + 50))
    end
    self:initTableView()
    self:updateTrainState()
end

function FlyNailBattle:initTableView()
    local size = self._panelItem:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelItem:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function FlyNailBattle:cellSizeForTable(view, idx)
    return 120, 120
end

function FlyNailBattle:numberOfCellsInTableView(view)
    return #self._itemData
end

function FlyNailBattle:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._itemData[index]
    if info then
        uq.showItemTips(info)
    end
end

function FlyNailBattle:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local equip_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        equip_item = EquipItem:create({})
        equip_item:setPosition(cc.p(equip_item:getContentSize().width * 0.5, equip_item:getContentSize().height * 0.5))
        equip_item:setName("item")
        equip_item:setScale(0.9)
        cell:addChild(equip_item)
    else
        equip_item = cell:getChildByName("item")
    end
    if equip_item then
        local info = self._itemData[index]
        equip_item:setInfo(info)
    end
    return cell
end

function FlyNailBattle:updateTrainDialog()
    local time_id = self._timeId
    self._canTraing = true
    local idle_xml = self._info.xml.Idle[time_id]
    local index = 1
    local general_info1 = uq.cache.generals:getGeneralDataByID(self._generalId1)
    local general_info2 = uq.cache.generals:getGeneralDataByID(self._generalId2)
    local general_data1 = nil
    local general_data2 = nil
    if general_info1 then
        general_data1 = uq.cache.generals:getGeneralDataXML(general_info1.rtemp_id)
    end
    if general_info2 then
        general_data2 = uq.cache.generals:getGeneralDataXML(general_info2.rtemp_id)
    end
    if idle_xml.generalLevel > 0 then
        local level_full = false
        if general_info1 ~= nil and general_info2 ~= nil and general_info1.lvl >= idle_xml.generalLevel and general_info2.lvl >= idle_xml.generalLevel then
            level_full = true
        end
        self._requireArray[index]:setVisible(true)
        self._requireArray[index]:setString(string.format(StaticData['local_text']['fly.nail.battle.des6'], idle_xml.generalLevel))
        if level_full then
            self._requireArray[index]:setTextColor(cc.c3b(0, 255, 0))
        else
            self._requireArray[index]:setTextColor(cc.c3b(255, 0, 0))
            self._canTraing = false
        end
        index = index + 1
    end
    if idle_xml.qualityType > 0 then
        local quality_full = false
        self._requireArray[index]:setVisible(true)
        local item_quality_data = StaticData['types'].ItemQuality[1].Type[tonumber(idle_xml.qualityType)]
        self._requireArray[index]:setString(string.format(StaticData['local_text']['fly.nail.battle.des12'], item_quality_data.name))
        if (general_data1 ~= nil and general_data1.qualityType >= tonumber(idle_xml.qualityType)) or
        (general_data2 ~= nil and general_data2.qualityType >= tonumber(idle_xml.qualityType)) then
            quality_full = true
        end
        if quality_full then
            self._requireArray[index]:setTextColor(cc.c3b(0, 255 ,0))
        else
            self._requireArray[index]:setTextColor(cc.c3b(255, 0, 0))
            self._canTraing = false
        end

        index = index + 1
    end
    if idle_xml.advanceLevel > 0 then
        local advance_full = false
        local info = StaticData['advance_levels'][tonumber(idle_xml.advanceLevel)]
        self._requireArray[index]:setString(string.format(StaticData['local_text']['fly.nail.battle.des14'], info.name))
        self._requireArray[index]:setVisible(true)
        if (general_info1 ~= nil and general_info1.advanceLevel >= tonumber(idle_xml.advanceLevel)) or
        (general_info2 ~= nil and general_info2.advanceLevel >= tonumber(idle_xml.advanceLevel)) then
            advance_full = true
        end
        if advance_full then
            self._requireArray[index]:setTextColor(cc.c3b(0, 255, 0))
        else
            self._requireArray[index]:setTextColor(cc.c3b(255, 0, 0))
            self._canTraing = false
        end
        index = index + 1
    end
    if idle_xml.soldierType > 0 then
        self._requireArray[index]:setString(idle_xml.soldierDesc)
        local soldier_full = false
        if general_info1 ~= nil and general_info2 ~= nil then
            local soldier1_info1 = StaticData['soldier'][general_info1.soldierId1]
            local soldier1_info2 = StaticData['soldier'][general_info1.soldierId2]
            local soldier2_info1 = StaticData['soldier'][general_info2.soldierId1]
            local soldier2_info2 = StaticData['soldier'][general_info2.soldierId2]
            if (soldier1_info1.type == idle_xml.soldierType or soldier1_info2.type == idle_xml.soldierType) and
                (soldier2_info1.type == idle_xml.soldierType or soldier2_info2.type == idle_xml.soldierType) then
                    soldier_full = true
            end
        end
        if soldier_full then
            self._requireArray[index]:setTextColor(cc.c3b(0, 255, 0))
        else
            self._requireArray[index]:setTextColor(cc.c3b(255, 0, 0))
            self._canTraing = false
        end
        index = index + 1
    end
    for i = index, 4 do
        self._requireArray[i]:setVisible(false)
    end
    self._itemData = self:getTraingReward(self._timeId)
    self._tableView:reloadData()
end

function FlyNailBattle:updateGeneral()
    self._panelHero1:removeAllChildren()
    self._panelHero2:removeAllChildren()
    local general_info1 = uq.cache.generals:getGeneralDataByID(self._generalId1)
    local general_info2 = uq.cache.generals:getGeneralDataByID(self._generalId2)
    self._panelHero1:setVisible(general_info1 ~= nil)
    self._panelHero2:setVisible(general_info2 ~= nil)
    if general_info1 ~= nil then
        local head = DraftGeneralHeadItem:create()
        head:setInfo({general_info = general_info1})
        self._panelHero1:addChild(head)
        head:setPosition(cc.p(self._panelHero1:getContentSize().width * 0.5 , self._panelHero1:getContentSize().height * 0.5))
    end
    if general_info2 ~= nil then
        local head = DraftGeneralHeadItem:create()
        head:setInfo({general_info = general_info2})
        self._panelHero2:addChild(head)
        head:setPosition(cc.p(self._panelHero1:getContentSize().width * 0.5 , self._panelHero1:getContentSize().height * 0.5))
    end
end

function FlyNailBattle:_onBtnGetReward(event)
    if event.name ~= "ended" then
        return
    end
    local left_time = self._info.data.left_time - os.time()
    if left_time > 0 then
        uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des16'])
        return
    end
    network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_DRAW_REWARD, {id = self._info.xml.ident})
end

function FlyNailBattle:_onBtnBattle(event)
    if event.name ~= "ended" then
        return
    end
    local troop_info = StaticData['eight_diagrams'].Troop[self._info.xml.troop]
    local info = uq.cache.fly_nail:getFlyNailInfo()
    local army_data = {
        ids = {info.formation_id},
        array = {'army_1'},
        army_1 = info.generals,
    }
    local data = {
        enemy_data = troop_info.Army,
        army_data = {army_data},
        embattle_type = uq.config.constant.TYPE_EMBATTLE.FLYNAIL_EMBATTLE,
        confirm_callback = function()
            network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_BATTLE, {id = self._info.xml.ident})
        end
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function FlyNailBattle:_onBtnEmbattle(event)
    if event.name ~= "ended" then
        return
    end
    uq.runCmd('enter_embattle')
end

function FlyNailBattle:_onBtnTraning(event)
    if event.name ~= "ended" then
        return
    end
    if self._info.data ~= nil and self._info.data.time_id > 0 then
        uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des11'])
        return
    end
    if self._generalId1 == 0 or self._generalId2 == 0 then
        uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des2'])
        return
    end
    if not self._canTraing then
        uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des3'])
        return
    end
    network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_HANGUP, {id = self._info.data.id, time_id = self._timeId,
    general_id1 = self._generalId1, general_id2 = self._generalId2})
end

function FlyNailBattle:onChangeTring()
    if self._info.data.time_id > 0 then
        uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des11'])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_SELECT,{info = self._info, select_general_id1 = self._generalId1, select_general_id2 = self._generalId2})
end

function FlyNailBattle:initProtocolData()
    network:addEventListener(Protocol.S_2_C_MIRACLE_FIGHT_BATTLE, handler(self, self._onMiracleFightBattle), '_onMiracleFightBattle')
    network:addEventListener(Protocol.S_2_C_MIRACLE_FIGHT_HANGUP, handler(self, self._onMiracleFightHangUp), '_onMiracleFightHangUp')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_DRAW_REWARD, handler(self, self._onFlyNailDrawReward), '_onFlyNailDrawRewardByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_SELECT_GENERALS, handler(self, self._onFlyNailSelectGenerals), '_onFlyNailSelectGenerals')
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_LOAD, handler(self, self._onFlyNailLoad), '_onFlyNailLoadByBattle')
end

function FlyNailBattle:_onFlyNailLoad()
    local info = uq.cache.fly_nail.flyNailInfo
    for k, v in pairs(info.items) do
        if self._info.xml.ident == v.id then
            self._info.data = v
            break
        end
    end
    if not self._info.data then
        return
    end
    self._generalId1 = self._info.data.general_id1
    self._generalId2 = self._info.data.general_id2
    self._timeId = self._info.data.time_id == 0 and 1 or self._info.data.time_id
    self:updateTrainState()
end

function FlyNailBattle:updateTrainState()
    self._nodeSoldier:setVisible(self._info.data ~= nil)
    if self._info.data ~= nil then
        self._battleNode:setPositionX(self._nodeBattlePosX)
        self._generalId1 = self._info.data.general_id1
        self._generalId2 = self._info.data.general_id2
        self._timeId = self._info.data.time_id == 0 and 1 or self._info.data.time_id
        self._rewardLabel:setString(StaticData['local_text']['fly.nail.reward.des2'])
        self._btnBattle:setPositionX(self._btnBattlePosX)
        self:updateTrainDialog()
        self:updateGeneral()
        local left_time = self._info.data.left_time - os.time()
        if left_time <= 0 then
            if self._info.data.general_id1 == 0 and self._info.data.general_id2 == 0 then
                self._btnTraning:setVisible(true)
                self._btnGetReward:setVisible(false)
                self._timesLabel:setVisible(false)
            else
                self._btnTraning:setVisible(false)
                self._btnGetReward:setVisible(true)
                self._timesLabel:setVisible(true)
                self._timesLabel:setString(StaticData['local_text']['fly.nail.general.des9'])
            end
        else
            self._btnTraning:setVisible(false)
            self._btnGetReward:setVisible(true)
            self._timesLabel:setVisible(true)
            if self._cdTimer then
                self._cdTimer:setTime(left_time)
            else
                self._cdTimer = uq.ui.TimerField:create(self._timesLabel, left_time, handler(self, self._cdTimeOver))
            end
        end
        self._reward = {}
        local reward_array = uq.RewardType.parseRewards(self._info.xml.reward)
        for k, v in ipairs(reward_array) do
            local data = v:toEquipWidget()
            local info = {
                type = data.type,
                num = data.num,
                paraml = data.id,
            }
            table.insert(self._reward, info)
        end
    else
        self._reward = {}
        local reward_array = uq.RewardType.parseRewards(self._info.xml.firstReward)
        self._itemData = {}
        for k, v in ipairs(reward_array) do
            local data = v:toEquipWidget()
            table.insert(self._itemData, data)
            local info = {
                type = data.type,
                num = data.num,
                paraml = data.id,
            }
            table.insert(self._reward, info)
        end
        self._battleNode:setPositionX(0)
        self._btnTraning:setVisible(false)
        self._btnGetReward:setVisible(false)
        self._rewardLabel:setString(StaticData['local_text']['fly.nail.reward.des1'])
        self._btnBattle:setPositionX(self._btnTraning:getPositionX())
        self._tableView:reloadData()
    end
end

function FlyNailBattle:_cdTimeOver()
    self._timesLabel:setString(StaticData['local_text']['fly.nail.general.des9'])
    self._btnTraning:setVisible(false)
    self._btnGetReward:setVisible(true)
    self._timesLabel:setVisible(true)
end

function FlyNailBattle:_onFlyNailSelectGenerals(msg)
    self._timeId = msg.data.time_id
    self._generalId1 = msg.data.general_id1
    self._generalId2 = msg.data.general_id2
    self:updateGeneral()
    self:updateTrainDialog()
end

function FlyNailBattle:getTraingReward(time_id)
    local idle_xml = self._info.xml.Idle[time_id]
    local reward = idle_xml.reward
    local lvl = self._info.data.lvl
    local level_xml = nil
    for k, v in pairs(self._info.xml.Skill) do
        if v.level == lvl then
            level_xml = v
            break
        end
    end
    local reward_array = uq.RewardType.parseRewards(reward)
    local array = {}
    if level_xml then
        for k, v in ipairs(reward_array) do
            local data = v:toEquipWidget()
            data.num = data.num + math.floor(data.num * level_xml.buff)
            data.max_num = data.max_num + math.floor(data.max_num * level_xml.buff)
            table.insert(array, data)
        end
    else
        for k, v in ipairs(reward_array) do
            local data = v:toEquipWidget()
            table.insert(array, data)
        end
    end
    return array
end

function FlyNailBattle:_onFlyNailDrawReward(msg)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = msg.data.reward})
    self._generalId1 = 0
    self._generalId2 = 0
    self._timeId = 1
    self:updateTrainState()
end

function FlyNailBattle:_onMiracleFightHangUp(evt)
    uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des9'])
    self._info.data.time_id = evt.data.time_id
    self._info.data.left_time = evt.data.left_time + os.time()
    self._info.data.general_id1 = evt.data.general_id1
    self._info.data.general_id2 = evt.data.general_id2
    self._generalId1 = evt.data.general_id1
    self._generalId2 = evt.data.general_id2
    self:updateTrainState()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FLYNAIL_HANGUP, data = evt.data})
end

function FlyNailBattle:_onMiracleFightBattle(evt)
    local addr = uq.cache.nodes:getReportAddress(evt.data.report_id, '')
    uq.BattleReport:getInstance():load(addr, evt.data.report_id, handler(self, self._reportLoaded), uq.BattleReport.TYPE_PERSONAL)
end

function FlyNailBattle:_reportLoaded(report_id, report)
    if not report then
        return
    end
    local troop_xml = StaticData['eight_diagrams'].Troop[self._info.xml.troop]
    uq.runCmd('enter_single_battle_report', {report, handler(self, self._onPlayReportEnd), 'img/bg/battle/' .. troop_xml.battleBg})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
end

function FlyNailBattle:_onPlayReportEnd(report)
    if not report then
        return
    end
    if report.result > 0 then
        local data = {rewards = self._reward, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_WIN_MODULE, data)
    else
        local data = {npc_id = report.npc_id, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_LOST_MODULE, data)
    end
    network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_LOAD, {})
end

function FlyNailBattle:removeProtocolData()
    network:removeEventListenerByTag("_onMiracleFightBattle")
    network:removeEventListenerByTag("_onMiracleFightHangUp")
    services:removeEventListenersByTag("_onFlyNailDrawRewardByBattle")
    services:removeEventListenersByTag("_onFlyNailSelectGenerals")
    services:removeEventListenersByTag("_onFlyNailLoadByBattle")
end

function FlyNailBattle:dispose()
    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end
    self:removeProtocolData()
    FlyNailBattle.super.dispose(self)
end

return FlyNailBattle

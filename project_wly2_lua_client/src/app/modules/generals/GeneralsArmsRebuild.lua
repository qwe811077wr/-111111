local GeneralsArmsRebuild = class("GeneralsArmsRebuild", require("app.base.PopupBase"))

GeneralsArmsRebuild.RESOURCE_FILENAME = "generals/GeneralsArmsRebuild.csb"

GeneralsArmsRebuild.RESOURCE_BINDING  = {
    ["Panel_2_0/Panel_3/btn_rebuild1"]                          ={["varname"] = "_btnRebuild1",["events"] = {{["event"] = "touch",["method"] = "onBtnRebuild"}}},
    ["Panel_2_0/Panel_10/btn_rebuild2"]                         ={["varname"] = "_btnRebuild2",["events"] = {{["event"] = "touch",["method"] = "onBtnRebuild"}}},
    ["Panel_2_0/Panel_10/btn_replace"]                          ={["varname"] = "_btnReplace",["events"] = {{["event"] = "touch",["method"] = "onBtnReplace"}}},
    ["Panel_2/Panel_1"]                                         ={["varname"] = "_panelArms1"},
    ["Panel_2/Panel_1_0"]                                       ={["varname"] = "_panelArms2"},
    ["Panel_2_0/Panel_10/Panel_1"]                              ={["varname"] = "_panelArms3"},
    ["Panel_2_0/Panel_10/Panel_1_0"]                            ={["varname"] = "_panelArms4"},
    ["Panel_2_0/Panel_10/Panel_res_0/label_costmoney2"]         ={["varname"] = "_costLabel2"},
    ["Panel_2_0/Panel_3/Panel_res/label_costmoney1"]            ={["varname"] = "_costLabel1"},
    ["Panel_2_0/Panel_3/Panel_res/img_money1"]                  ={["varname"] = "_imgCost1"},
    ["Panel_2_0/Panel_10/Panel_res_0/img_money2"]               ={["varname"] = "_imgCost2"},
    ["Panel_2_0/Panel_3"]                                       ={["varname"] = "_panelNoSoldier"},
    ["Panel_2_0/Panel_10"]                                      ={["varname"] = "_panelSoldier"},
    ["Button_1"]                                                ={["varname"] = "_btnExit", ["events"] = {{["event"] = "touch", ["method"] = "_onTouchExit",["sound_id"] = 0}}},
}
function GeneralsArmsRebuild:ctor(name, args)
    GeneralsArmsRebuild.super.ctor(self,name,args)
    self._generalsId = args.general_id or nil
    self._curSelectSoldierId = 0
    self._curReBuildSelectSoldierId = 0
    self._curCostValue = 0
    self._curCostType = 0
    self._itemArms = {}
    self._infoArms = {}
    self._armsInfoItem1 = nil
    self._armsInfoItem2 = nil
end

function GeneralsArmsRebuild:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._curGeneralInfo = uq.cache.generals:getGeneralDataByID(self._generalsId)
    if self._curGeneralInfo == nil then
        return
    end
    self:initUi()
    self:initProtocal()
end

function GeneralsArmsRebuild:initUi()
    self._btnRebuild1:setPressedActionEnabled(true)
    self._btnRebuild2:setPressedActionEnabled(true)
    self._btnReplace:setPressedActionEnabled(true)
    self._curSelectSoldierId = self._curGeneralInfo.battle_soldier_id
    self._curReBuildSelectSoldierId = self._curGeneralInfo.rebuildSoldierId1

    self._tipItem = uq.createPanelOnly("generals.ArmsValueText")
    self._tipItem:setImgBgVisible(true)
    self._tipItem:setVisible(false)
    self._view:addChild(self._tipItem)

    self._panelArms = {self._panelArms1, self._panelArms2, self._panelArms3, self._panelArms4}
    for i = 1, 4 do
        self._itemArms[i] = uq.createPanelOnly("generals.ArmsResInfoItem")
        self._panelArms[i]:setScale(0.9)
        self._panelArms[i]:addChild(self._itemArms[i])
        self._itemArms[i]:addClickEvent(handler(i, handler(self, self._showTip)))
    end

    if self._curGeneralInfo.rebuildSoldierId1 > 0 and self._curGeneralInfo.rebuildSoldierId2 > 0 then
        self._panelNoSoldier:setVisible(false)
        self._panelSoldier:setVisible(true)
    else
        self._panelNoSoldier:setVisible(true)
        self._panelSoldier:setVisible(false)
    end
    self:updateInfo()
    self:updateCost()
end

function GeneralsArmsRebuild:_showTip(tag, flag, info)
    self._tipItem:setVisible(flag)
    if not flag then
        return
    end
    self._tipItem:setData(info)
    local item = self._itemArms[tag]
    local parent = item:getParent()
    local pos_x, pos_y = self._itemArms[tag]:getPosition()
    local world_pos = parent:convertToWorldSpace(cc.p(pos_x, pos_y))
    local pos = self._view:convertToNodeSpace(world_pos)
    self._tipItem:setPosition(cc.p(pos.x - 70, pos.y + 125))
end

function GeneralsArmsRebuild:updateInfo()
    local id_arms = {self._curGeneralInfo.soldierId1, self._curGeneralInfo.soldierId2, self._curGeneralInfo.rebuildSoldierId1, self._curGeneralInfo.rebuildSoldierId2}
    for i = 1, 4 do
        local info = id_arms[i]
        self._itemArms[i]:setInfo(info)
    end
end

function GeneralsArmsRebuild:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_REBULID_SOLDIERS_IDS, handler(self,self._onRebuildSoldierIds), "_onRebuildSoldierIdsByRebuild")
end

function GeneralsArmsRebuild:_onRebuildSoldierIds(msg)
    local info = msg.data
    if self._curGeneralInfo.id == info.genaral_id then
        self._curGeneralInfo.rebuildSoldierId1 = info.soldier_id1
        self._curGeneralInfo.rebuildSoldierId2 = info.soldier_id2
        self._panelNoSoldier:setVisible(false)
        self._panelSoldier:setVisible(true)
        self:updateInfo()
        self:updateCost()
    end
end

function GeneralsArmsRebuild:updateCost()
    --添加消耗的资源
    local info = uq.cache.generals:getAllGeneralInfo()
    if info == nil then
        return
    end
    local cur_rebuild_times = info.rebuildSoldierNums + 1
    if cur_rebuild_times > 5 then
        cur_rebuild_times = 5
    end
    local soldier_info = StaticData["constant"][uq.config.constant.TYPE_CONSTANT.SOLDIER_REBUILD].Data
    if not soldier_info then
        return
    end
    local rebuild_info = soldier_info[cur_rebuild_times]
    local cost_array = string.split(rebuild_info.cost, ";")
    self._curCostValue = tonumber(cost_array[2])
    self._curCostType = tonumber(cost_array[1])
    local type_cost = StaticData['types'].Cost[1].Type[self._curCostType]
    self._costLabel1:setString(self._curCostValue)
    self._costLabel2:setString(self._curCostValue)
    self._imgCost1:loadTexture("img/common/ui/" .. type_cost.miniIcon)
    self._imgCost2:loadTexture("img/common/ui/" .. type_cost.miniIcon)
    if info.isRebuildSoldierFree == 0 then
        self._costLabel1:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
        self._costLabel2:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
        self._curCostValue = 0
    end
end

function GeneralsArmsRebuild:onBtnRebuild(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(self._curCostType,self._curCostValue) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(self._curCostType).name))
        return
    end

    if self._curGeneralInfo.transferSoldierTimes <= 0 then
        uq.fadeInfo(StaticData["local_text"]["soldier.rebuild.des"])
        return
    end
    network:sendPacket(Protocol.C_2_S_REBUILD_SOLDIER, {general_id = self._curGeneralInfo.id})
end

function GeneralsArmsRebuild:onBtnReplace(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_REBUILD_SOLDIER_RES, {general_id = self._curGeneralInfo.id, op = 0})
end

function GeneralsArmsRebuild:dispose()
    for k, v in pairs(self._itemArms) do
        v:dispose()
    end
    GeneralsArmsRebuild.super.dispose(self)
    services:removeEventListenersByTag("_onRebuildSoldierIdsByRebuild")
end

return GeneralsArmsRebuild
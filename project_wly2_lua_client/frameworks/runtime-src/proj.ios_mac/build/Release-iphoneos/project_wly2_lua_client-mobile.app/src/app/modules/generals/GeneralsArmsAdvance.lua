local GeneralsArmsAdvance = class("GeneralsArmsAdvance", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsArmsAdvance.RESOURCE_FILENAME = "generals/GeneralsArmsAdvance.csb"

GeneralsArmsAdvance.RESOURCE_BINDING  = {
    ["Panel_2/btn_advanced"]                        ={["varname"] = "_btnAdvanced",["events"] = {{["event"] = "touch",["method"] = "onBtnAdvanced"}}},
    ["Button_1"]                                    ={["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Panel_2/Node_1"]                              ={["varname"] = "_contidionNode1"},
    ["Panel_2/Node_2"]                              ={["varname"] = "_contidionNode2"},
    ["Panel_2/Panel_res/Node_cost1"]                ={["varname"] = "_itemNode1"},
    ["Panel_2/Panel_res/Node_cost2"]                ={["varname"] = "_itemNode2"},
    ["Panel_2/Panel_res"]                           ={["varname"] = "_panelItem"},
    ["Panel_2/label"]                               ={["varname"] = "_txtTitle"},
    ["Panel_2/label_tip"]                           ={["varname"] = "_txtTip"},
    ["Panel_2/Image_11"]                            ={["varname"] = "_noPressNode"},
    ["Panel_2"]                                     ={["varname"] = "_panelBase"},
}
function GeneralsArmsAdvance:ctor(name, args)
    GeneralsArmsAdvance.super.ctor(self,name,args)
    self._generalsId = args.general_id or nil
    self._isAchieveCondition = true
    self._costNodeArray = {}
    self._conditionNode = {}
end

function GeneralsArmsAdvance:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._curGeneralInfo = uq.cache.generals:getGeneralDataByID(self._generalsId)
    if self._curGeneralInfo == nil then
        return
    end
    table.insert(self._costNodeArray, self._itemNode1)
    table.insert(self._costNodeArray, self._itemNode2)
    table.insert(self._conditionNode, self._contidionNode1)
    table.insert(self._conditionNode, self._contidionNode2)
    self:initUi()
end

function GeneralsArmsAdvance:initUi()
    self:addExceptNode(self._noPressNode)
    self._btnAdvanced:setPressedActionEnabled(true)
    self:updateBaseInfo()
end

function GeneralsArmsAdvance:onBtnAdvanced(event)
    if event.name ~= "ended" then
        return
    end
    if not self._isAchieveCondition then
        uq.fadeInfo(StaticData["local_text"]["soldier.advance.condition.not.achieve"])
        return
    end
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if not soldier_xml1 then
        uq.log("error GeneralsArmsAdvance updateBaseInfo  soldier_xml1")
        return
    end
    local soldier_transfer = StaticData['soldier_transfer'][soldier_xml1.level + 1]
    if soldier_transfer.cost ~= "" then
        local cost_array = string.split(soldier_transfer.cost, "|")
        for k, v in ipairs(cost_array) do
            local info_array = string.split(v, ";")
            if not uq.cache.role:checkRes(tonumber(info_array[1]), tonumber(info_array[2]), tonumber(info_array[3])) then
                uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(tonumber(info_array[1]), tonumber(info_array[3])).name))
                return
            end
        end
    end
    network:sendPacket(Protocol.C_2_S_TRANSFER_SOLDIER,{general_id = self._curGeneralInfo.id})
end


function GeneralsArmsAdvance:updateBaseInfo()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if not soldier_xml1 then
        uq.log("error GeneralsArmsAdvance updateBaseInfo  soldier_xml1")
        return
    end
    local soldier_transfer = StaticData['soldier_transfer'][soldier_xml1.level + 1]
    if soldier_transfer then
        if soldier_transfer.cost ~= "" then
            local reward_items = uq.RewardType.parseRewards(soldier_transfer.cost)
            for k, item in ipairs(reward_items) do
                local info = item:toEquipWidget()
                local euqip_item = EquipItem:create({info = info})
                local cur_num = uq.cache.role:getResNum(info.type, info.id)
                self._costNodeArray[k]:removeAllChildren()
                self._costNodeArray[k]:addChild(euqip_item)
                euqip_item:showName(true, uq.formatResource(cur_num) .. "/" .. uq.formatResource(info.num, true))
                euqip_item:setNameFontSize(18)
                if info.num > cur_num then
                    euqip_item:setNameColor(uq.parseColor("#ff0000"))
                else
                    euqip_item:setNameColor(uq.parseColor("#effdff"))
                end
                euqip_item:setTouchEnabled(true)
                euqip_item:addClickEventListener(function(sender)
                    local info = sender:getEquipInfo()
                    uq.showItemTips(info)
                end)
            end
        else
            self._panelItem:setVisible(false)
            self._btnAdvanced:setPositionX(self._txtTitle:getPositionX())
            self._txtTip:setPositionX(self._txtTitle:getPositionX())
        end
        local index = 1
        if soldier_transfer.rebirthTimes > 0 then
            self._conditionNode[index]:setVisible(true)
            self._conditionNode[index]:getChildByName("label_condition"):setString(string.format(StaticData['local_text']["general.soldier.transfer.des1"], soldier_transfer.rebirthTimes))
            self:showLabelState(index, soldier_transfer.rebirthTimes > self._curGeneralInfo.reincarnation_tims)
            index = index + 1
        end

        if soldier_transfer.level > 0 then
            self._conditionNode[index]:setVisible(true)
            self._conditionNode[index]:getChildByName("label_condition"):setString(string.format(StaticData['local_text']["general.soldier.transfer.des3"], soldier_transfer.level))
            self:showLabelState(index, soldier_transfer.level > self._curGeneralInfo.lvl)
            index = index + 1
        end

        if soldier_transfer.towerFloor > 0 then
            self._conditionNode[index]:setVisible(true)
            self._conditionNode[index]:getChildByName("label_condition"):setString(string.format(StaticData['local_text']["general.soldier.transfer.des2"], soldier_transfer.towerFloor))
            local info = uq.cache.trials_tower:getCurTowerInfo()
            if not info then
                return
            end
            self:showLabelState(index, soldier_transfer.towerFloor > info.ident)
            index = index + 1
        end
    end
end

function GeneralsArmsAdvance:showLabelState(index, is_fail)
    if is_fail then
        self._isAchieveCondition = false
        self._conditionNode[index]:getChildByName("label_condition"):setTextColor(uq.parseColor("#c7280b"))
        self._conditionNode[index]:getChildByName("label_state"):setTextColor(uq.parseColor("#c7280b"))
        self._conditionNode[index]:getChildByName("label_state"):setString(StaticData['local_text']["general.arms.condition.fail"])
        self._conditionNode[index]:getChildByName("img_state"):loadTexture("img/generals/j03_0000904.png")
    else
        self._conditionNode[index]:getChildByName("label_state"):setTextColor(uq.parseColor("#37f413"))
        self._conditionNode[index]:getChildByName("label_condition"):setTextColor(uq.parseColor("#37f413"))
        self._conditionNode[index]:getChildByName("label_state"):setString(StaticData['local_text']["general.arms.condition.finish"])
        self._conditionNode[index]:getChildByName("img_state"):loadTexture("img/generals/j03_0000905.png")
    end
end

function GeneralsArmsAdvance:dispose()
    GeneralsArmsAdvance.super.dispose(self)
end

return GeneralsArmsAdvance
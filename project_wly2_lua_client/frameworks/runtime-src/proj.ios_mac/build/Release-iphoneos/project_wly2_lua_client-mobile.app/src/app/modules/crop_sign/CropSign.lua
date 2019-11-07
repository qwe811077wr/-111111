local CropSign = class("CropSign", require('app.modules.common.BaseViewWithHead'))

CropSign.RESOURCE_FILENAME = "crop_sign/CropSign.csb"
CropSign.RESOURCE_BINDING = {
    ["Text_9_0"]          = {["varname"] = "_txtLevel"},
    ["Text_1"]            = {["varname"] = "_txtTitle"},
    ["Image_10"]          = {["varname"] = "_imgSelect3"},
    ["Image_10_0"]        = {["varname"] = "_imgSelect2"},
    ["Image_10_1"]        = {["varname"] = "_imgSelect1"},
    ["Image_9"]           = {["varname"] = "_imgLevel3",["events"] = {{["event"] = "touch",["method"] = "onLevelSwitch"}}},
    ["Image_9_0"]         = {["varname"] = "_imgLevel2",["events"] = {{["event"] = "touch",["method"] = "onLevelSwitch"}}},
    ["Image_9_1"]         = {["varname"] = "_imgLevel1",["events"] = {{["event"] = "touch",["method"] = "onLevelSwitch"}}},
    ["Text_11"]           = {["varname"] = "_txtStageStar3"},
    ["Text_11_0"]         = {["varname"] = "_txtStageStar2"},
    ["Text_11_1"]         = {["varname"] = "_txtStageStar1"},
    ["Text_1_0_0"]        = {["varname"] = "_txtChallengeNum"},
    ["Text_6_0_0"]        = {["varname"] = "_txtProgress"},
    ["Image_6"]           = {["varname"] = "_imgReward",["events"] = {{["event"] = "touch",["method"] = "onShowReward"}}},
    ["reward_red"]        = {["varname"] = "_spriteRed"},
    ["Button_1"]          = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["node_left_middle"]  = {["varname"] = "_nodeLeftMiddle"},
    ["node_right_middle"] = {["varname"] = "_nodeRightMiddle"},
}

function CropSign:init()
    self:centerView()
    self:parseView()
    self:setTitle(uq.config.constant.MODULE_ID.CROP_SIGN)
    self:adaptNode()
end


function CropSign:onCreate()
    CropSign.super.onCreate(self)

    network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_LOAD)

    self._eventTag = Protocol.S_2_C_CROP_INSTANCE_LOAD .. tostring(self)
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_LOAD, handler(self, self.onCropSignDataLoad), self._eventTag)

    self._eventTag1 = Protocol.S_2_C_CROP_INSTANCE_BATTLE .. tostring(self)
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_BATTLE, handler(self, self.onBattleLoad), self._eventTag1)

    self._eventTag2 = Protocol.S_2_C_CROP_INSTANCE_DRAW .. tostring(self)
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_DRAW, handler(self, self.onCropSignReward), self._eventTag2)
    self:initPage()

    network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_FORMATION_LOAD)
end

function CropSign:initPage()
    self._cropLevel = uq.cache.crop:getCropLevel()
    self._curLevel = 1 --普通
    self._xmlConfig = StaticData['war_sign'].WarSign[self._cropLevel + 1]

    self._soldiers = {}
end

function CropSign:onCropSignDataLoad(evt)
    self._cropSignData = evt.data
    self._configData = {{}, {}, {}}
    for j, item in ipairs(self._xmlConfig.Stage) do
        local troops = string.split(item.troop, ';')
        for k, troop in ipairs(troops) do
            local strs = string.split(troop, ',')
            if self._cropSignData.troop_id == tonumber(strs[1]) then
                self._curLevel = j
            end
            self._configData[j][tonumber(strs[1])] = tonumber(strs[2])
        end
    end
    self:refreshPage()
    self:refreshData()
end

function CropSign:refreshPage()
    local titles = {StaticData['local_text']['chat.red.packet.ordinary'], StaticData['local_text']['label.diffculty'], StaticData['local_text']['label.diffculty.very']}
    self._txtLevel:setString(self._xmlConfig.troopLevel)
    self._txtTitle:setString(titles[self._curLevel])
    for i = 1, 3 do
        self['_imgSelect' .. i]:setVisible(false)
    end
    self['_imgSelect' .. self._curLevel]:setVisible(true)

    for i = 1, 3 do
        if not self._soldiers[i] then
            local soldier = uq.createPanelOnly('crop_sign.CropSoldier')
            table.insert(self._soldiers, soldier)
            self:addChild(soldier)
        end
        self._soldiers[i]:setData(self._xmlConfig, self._curLevel, i)
    end
end

function CropSign:refreshData()
    local stars = {{}, {}, {}}
    for k, item in ipairs(self._cropSignData.instances) do
        stars[item.id][item.troop_id] = item.star
    end
    self._xmlStar = stars

    local total_stars = {0, 0, 0}
    local total_xml_stars = {0, 0, 0}
    for i = 1, 3 do
        for k, star in pairs(stars[i]) do
            total_stars[i] = total_stars[i] + star
        end

        for k, star in pairs(self._configData[i]) do
            total_xml_stars[i] = total_xml_stars[i] + star
        end
    end

    for i = 1, 3 do
        self['_txtStageStar' .. i]:setString(total_stars[i] .. '/' .. total_xml_stars[i])
    end
    self._txtChallengeNum:setString(StaticData['local_text']['label.challenge.today'] .. string.format('：%d/%d', self._cropSignData.times, self._xmlConfig.pass))

    for i = 1, 3 do
        self._soldiers[i]:refreshData(stars[self._curLevel], self._cropSignData.troop_id, self._cropSignData.times)
    end

    local star1 = 0
    local star2 = 0
    for i = 1, 3 do
        star1 = star1 + total_stars[i]
        star2 = star2 + total_xml_stars[i]
    end
    self._txtProgress:setHTMLText(string.format("<font color='#db3c22'>%d</font>/%d", star1, star2))
    self._canGetReward = self._cropSignData.reward == 0 and star1 == star2
    self._spriteRed:setVisible(self._canGetReward)
end

function CropSign:onExit()
    network:removeEventListenerByTag(self._eventTag)
    network:removeEventListenerByTag(self._eventTag1)
    network:removeEventListenerByTag(self._eventTag2)
    CropSign.super.onExit(self)
end

function CropSign:onLevelSwitch(event)
    if event.name ~= "ended" then
        return
    end
    if self._curLevel == event.target:getTag() then
        return
    end
    self._curLevel = event.target:getTag()
    self:refreshPage()
    self:refreshData()
end

function CropSign:onShowReward(event)
    if event.name ~= 'ended' then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_SIGN_GET_REWARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._xmlConfig.starReward, self._cropSignData.reward, self._curLevel, self._canGetReward)
end

function CropSign:onBattleLoad(evt)
    self._resultData = evt.data
    local data = evt.data

    local rewards_array = {}
    local reward_string = string.split(self._xmlConfig.Stage[data.id].reward, "|")
    for k, v in ipairs(reward_string) do
        local strs = string.split(v, ';')
        table.insert(rewards_array, {type = tonumber(strs[1]), num = tonumber(strs[2]), paraml = tonumber(strs[3])})
    end

    local troop_data = StaticData['war_sign'].WarTroop[data.troop_id]
    uq.BattleReport:getInstance():showBattleReport(data.report_id, handler(self, self.onPlayReportEnd), rewards_array)
end

function CropSign:onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)

    if report.is_replay then
        return
    end

    self._cropSignData.troop_id = self._resultData.troop_id
    if report.result > 0 then
        self._cropSignData.times = self._cropSignData.times + 1

        local find = false
        for k, item in ipairs(self._cropSignData.instances) do
            if item.id == self._resultData.id and item.troop_id == self._resultData.troop_id then
                find = true
                if self._xmlStar[self._resultData.id][item.troop_id] > item.star then
                    item.star = item.star + 1
                end
                break
            end
        end

        if not find then
            local data = {
                id = self._resultData.id,
                troop_id = self._resultData.troop_id,
                star = 1
            }
            table.insert(self._cropSignData.instances, data)
        end
    end
    self:refreshPage()
    self:refreshData()
end

function CropSign:onCropSignReward(evt)
    if evt.data.ret ~= 0 then
        return
    end
    self._cropSignData.reward = 1
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._xmlConfig.starReward})
    self:refreshPage()
    self:refreshData()
end

function CropSign:onReport(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_SIGN_BATTLE_REPORT, {id = self._curLevel})
end

return CropSign
local DrillUpLv = class("DrillUpLv", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

DrillUpLv.RESOURCE_FILENAME = "drill/DrillUpLv.csb"
DrillUpLv.RESOURCE_BINDING = {
    ["Node_1/Node_3"]                     = {["varname"] = "_nodeSkill"},
    ["Node_1/line_node"]                  = {["varname"] = "_nodeLine"},
    ["Node_21/Button_12"]                 = {["varname"] = "_btnLeave", ["events"] = {{["event"] = "touch",["method"] = "onBtnLeave"}}},
    ["Node_21/coin_txt"]                  = {["varname"] = "_txtCoin"},
    ["Node_21/coin_img"]                  = {["varname"] = "_imgCoin"},
    ["Node_1/details_node"]               = {["varname"] = "_nodeDetails"},
    ["click_pnl"]                         = {["varname"] = "_pnlClick"},
    ["Image_8"]                           = {["varname"] = "_imgTitleBg"},
    ["right_lbr"]                         = {["varname"] = "_loadingBar"},
    ["Text_75"]                           = {["varname"] = "_txtPrecent"},
    ["Text_5_0"]                          = {["varname"] = "_txtLevel"},
    ["Image_7"]                           = {["varname"] = "_imgSoldier"},
    ["Node_7"]                            = {["varname"] = "_nodeSkillItems"},
    ["Text_88"]                           = {["varname"] = "_txtBtnLeave"},
    ["ScrollView_1"]                      = {["varname"] = "_scrollView"},
}

DrillUpLv.UP_STATUS = {
    CAN_UP      = 0,
    SKILL_LOCK  = 1,
    LEVEL_LESS  = 2,
    COIN_LESS   = 3,
}

function DrillUpLv:ctor(name, params)
    DrillUpLv.super.ctor(self, name, params)
    self._data = params.data or {}
end

function DrillUpLv:init()
    self:addShowCoinGroup({{type = uq.config.constant.COST_RES_TYPE.MATERIAL, id = uq.config.constant.MATERIAL_TYPE.MOIRE},
        uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self:adaptBgSize()

    self._detailData = {}
    self._btnNowStatus = self.UP_STATUS.COIN_LESS
    self._btnTips = ""
    self._upId = 0
    self._expDrillData = StaticData['drill_ground'].GroundLevel or {}
    self._skillData = uq.cache.drill:getDrillInfoById(self._data.index)
    self._skillInfo = uq.cache.drill:getSkillTree(self._data.index, self._data.drill_type)
    self._drillInfo = uq.cache.drill:getDrillXmlById(self._data.index)

    self:initLayer()
    self._playUnlockNode = {}
    self._onEventChange = "_onDrillUp" .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_BATTLE_END, handler(self, self.refreshLvlInfo), 'on_drill_battle_end' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE, handler(self, self._onDrillChange), self._onEventChange)
end

function DrillUpLv:setInfo(info)
    self._data.drill_type = info
    self._skillInfo = uq.cache.drill:getSkillTree(self._data.index, self._data.drill_type)
    local index = 1
    for k, v in pairs(self._skillInfo.SkillTree) do
        self:refreshBoxs(v, self._arrSkillBox[index])
        index = index + 1
    end
    self:refreshBtnState()
end

function DrillUpLv:refreshLvlInfo(data)
    if data and data.data ~= self._data.index then
        return
    end
    local xml_info = StaticData['drill_ground'].GroundLevel[self._skillData.level]
    self._txtLevel:setString("Lv." .. self._skillData.level)
    self._txtPrecent:setString(self._skillData.exp .. '/' .. xml_info.exp)
    self._loadingBar:setPercent(self._skillData.exp / xml_info.exp * 100)
end

function DrillUpLv:_onDrillChange(msg)
    for k, v in ipairs(self._arrSkillBox) do
        self:refreshBoxs(v:getSkillInfo(), v, true)
    end
    for k, v in ipairs(self._tabTypeArray) do
        v:refreshPage()
    end
    self:refreshBtnState()
end

function DrillUpLv:onLvlUpCallBack()
    for k, v in ipairs(self._playUnlockNode) do
        v:playUnlocked()
    end
    self._playUnlockNode = {}
end

function DrillUpLv:onBtnLeave(event)
    if event.name ~= "ended" then
        return
    end

    if not uq.RewardType:checkNeedNumState(StaticData['drill_ground'].Info[1].resetCost) then
        uq.fadeInfo(StaticData["local_text"]["drill.skill.can.reset"])
        return
    end

    uq.ModuleManager:getInstance():show(uq.ModuleManager.CONFIRM_BOX_MODULE)
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CONFIRM_BOX_MODULE)
    local content = StaticData['local_text']['drill.skilltree.reset2']
    local confirm_callback = function()
        network:sendPacket(Protocol.C_2_S_DRILL_GROUND_SKILL_RESET, {id = self._data.index, drill_type = self._data.drill_type})
    end
    panel:addConfirmBox({content = content, confirm_callback = confirm_callback}, uq.config.constant.CONFIRM_TYPE.NULL)
    panel:setScale(0.87)
    panel:setLayerColor(0)
end

function DrillUpLv:initLayer()
    self:refreshBtnState()
    self._arrSkillBox = {}
    for k, v in pairs(self._skillInfo.SkillTree) do
        self:addBoxs(v, self._data.index)
    end
    local reset_cost = StaticData['drill_ground'].Info[1].resetCost
    if reset_cost and reset_cost ~= "" then
        local reward = uq.RewardType:create(reset_cost)
        local mini_icon = reward:miniIcon()
        if mini_icon ~= '' then
            self._imgCoin:loadTexture("img/common/ui/" .. mini_icon)
        end
        self._txtCoin:setString(reward:num())
    end

    self._tabTypeArray = {}
    local size = nil
    for i = 1, 3 do
        local item = uq.createPanelOnly("drill.DrillStrengthType")
        size = item:getItemContentSize()
        item:setPosition(cc.p((size.width + 5) * (i - 0.5), size.height / 2))
        item:setInfo({index = self._data.index, drill_type = i})
        item:setCallback(handler(self, self._onTabChanged))
        item:setImgSelectVisible(self._data.drill_type == i)
        table.insert(self._tabTypeArray, item)
        self._scrollView:addChild(item, 4 - i)
    end
    local scroll_size = self._scrollView:getContentSize()
    self._scrollView:setTouchEnabled(true)
    self._scrollView:setInnerContainerSize(cc.size(size.width * 3 + 20, scroll_size.height))


    local soldier_info = StaticData['types'].Soldier[1].Type[self._drillInfo.type]
    if soldier_info then
        self._imgSoldier:loadTexture("img/generals/" .. soldier_info.miniIcon2)
    end
    self:refreshLvlInfo()
    self._imgTitleBg:loadTexture("img/drill/" .. self._drillInfo.bannerImg)
end

function DrillUpLv:_onTabChanged()
    for k, v in ipairs(self._tabTypeArray) do
        v:setImgSelectVisible()
    end
end

function DrillUpLv:addBoxs(info, index)
    local item = uq.createPanelOnly("drill/DrillSkillBox")
    self:refreshBoxs(info, item)
    table.insert(self._arrSkillBox, item)
    self._nodeSkillItems:addChild(item)
end

function DrillUpLv:refreshBoxs(info, node, flag)
    local lv = self:getSkillUpLevel(info.ident)
    local tab_pre = {}
    if info.prePos and info.prePos ~= 0 then
        tab_pre = string.split(info.prePos, ",")
    end
    local pos = string.split(info.iconDotCoord, ",")
    node:setPosition(cc.p(tonumber(pos[1]), tonumber(pos[2])))

    local is_lock = true
    local is_ground_limit = self._skillData.level < info.groundLimit
    local skill_limit_level = 0
    local is_skill_limit = false
    if info.preSkillLimit and info.preSkillLimit ~= "" then
        local tab_split = string.split(info.preSkillLimit, ";")
        is_skill_limit = true
        for i, v in ipairs(tab_split) do
            local tab_skill = string.split(v, ",")
            if tab_skill[1] then
                local skill_limit_open = self:getSkillUpLevel(tonumber(tab_skill[1])) >= tonumber(tab_skill[2])
                if not skill_limit_open then
                    skill_limit_level = tonumber(tab_skill[2])
                else
                    is_skill_limit = false
                end
                local is_open = not is_ground_limit and skill_limit_open
                if is_open then
                    is_lock = false
                end
                if tab_pre[i] then
                    local img_up = self._nodeLine:getChildByName("up_" .. tab_pre[i] .. "_" .. info.pos .. "_img")
                    local img_down = self._nodeLine:getChildByName("down_" .. tab_pre[i] .. "_" .. info.pos .. "_img")
                    img_up:setVisible(is_open)
                    img_down:setVisible(not is_open)
                end
            end
        end
    end

    if info.pos == 1 then
        is_lock = false
    end
    if flag and not node:getBgState() and not is_lock then
        self._playUnlock = true
        table.insert(self._playUnlockNode, node)
    elseif is_lock or not flag then
        node:setLockState(is_lock)
    end
    local info = {
        open_ground_level  = not is_ground_limit,
        open_skill         = not is_skill_limit,
        skill_limit_level  = skill_limit_level,
        ground_limit_level = info.groundLimit,
        lvl                = lv,
        info               = info,
        flag               = flag,
        name               = self._drillInfo.skillTitle,
        index              = self._data.index
    }
    node:refreshPage(info)
end

function DrillUpLv:getSkillUpLevel(id)
    for k, v in pairs(self._skillData.skillls) do
        if v.id == id then
            return v.num
        end
    end
    return 0
end

function DrillUpLv:refreshBtnState()
    local open_state = false
    for k, v in pairs(self._skillData.skillls) do
        if v.num > 0 then
            open_state = true
            break
        end
    end
    self._btnLeave:setEnabled(open_state)
end

function DrillUpLv:dispose()
    services:removeEventListenersByTag(self._onEventChange)
    services:removeEventListenersByTag('on_drill_battle_end' .. tostring(self))
    DrillUpLv.super.dispose(self)
end

return DrillUpLv
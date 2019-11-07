local NPCDrillLostModule = class("NPCDrillLostModule", require('app.base.PopupBase'))

NPCDrillLostModule.RESOURCE_FILENAME = 'instance/InstanceLostView.csb'
NPCDrillLostModule.RESOURCE_BINDING = {
    ["Button_formation"] = {["varname"] = "_btnEmbattle", ["events"] = {{["event"] = "touch", ["method"] = "onBtnAction"}}},
    ["Button_equip"]     = {["varname"] = "_btnEquip", ["events"] = {{["event"] = "touch", ["method"] = "onBtnAction"}}},
    ["Button_general"]   = {["varname"] = "_btnGeneral", ["events"] = {{["event"] = "touch", ["method"] = "onBtnAction"}}},
    ["Button_cruit"]     = {["varname"] = "_btnTech", ["events"] = {{["event"] = "touch", ["method"] = "onBtnAction"}}},
    ["Button_replay"]    = {["varname"] = "_btnReplay", ["events"] = {{["event"] = "touch", ["method"] = "onReplay"}}},
    ["Button_guide"]     = {["varname"] = "_btnGuide", ["events"] = {{["event"] = "touch", ["method"] = "onGuide"}}},
    ["Panel_1"]          = {["varname"] = "_panelBg"},
    ["Button_confirm"]   = {["varname"] = "_btnConfirm", ["events"] = {{["event"] = "touch", ["method"] = "onConfirm"}}},
    ["node_soldier"]     = {["varname"] = "_nodeSoldier"},
    ["node_battle"]      = {["varname"] = "_nodeBattle"},
    ["node_arena"]       = {["varname"] = "_nodeArena"},
}

function NPCDrillLostModule:ctor(name, params)
    NPCDrillLostModule.super.ctor(self, name, params)
    self._report = params.report
    self._isReplay = false
    self._data = params.data
end

function NPCDrillLostModule:onCreate()
    NPCDrillLostModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
end

function NPCDrillLostModule:init()
    self._btnEmbattle.index = 1
    self._btnEquip.index = 2
    self._btnGeneral.index = 3
    self._btnTech.index = 4
    self._tabModules = {}

    self._nodeBattle:setVisible(false)
    self._nodeSoldier:setVisible(true)
    self._nodeArena:setVisible(false)

    local left_num = 0
    local lost_num = 0
    for k, item in pairs(self._report.atker.left_generals) do
        left_num = left_num + item.cur_soldier_num
    end
    for k, item in pairs(self._report.atker.generals) do
        lost_num = lost_num + item.cur_soldier_num
    end
    lost_num = lost_num - left_num

    self._txtLeftSoldier = self._nodeSoldier:getChildByName('left_soldier_txt')
    self._txtLostSoldier = self._nodeSoldier:getChildByName('lost_soldier_txt')

    local id = uq.cache.drill:getDrillIdOperation()
    local data = uq.cache.drill:getDrillInfoById(id)
    local add = StaticData['drill_ground'].DrillGround[id].Mode[data.cur_mode].expUp
    self._nodeSoldier:getChildByName('num_add_2'):setString(add * 100 .. '%')
    self._nodeSoldier:getChildByName('num_add_1'):setString(self._data.add_exp / add)
    self._nodeSoldier:getChildByName('num_add_3'):setString(self._data.add_exp)
    self._expAddBar = self._nodeSoldier:getChildByName('load_add')
    self._txtAdd = self._nodeSoldier:getChildByName('txt_soldier_add')

    local pre_exp = 0
    local pre_total_exp = 0
    if self._data.exp < self._data.add_exp then
        self._preLevel = self._data.level - 1
        pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
        local exp = self._data.add_exp - self._data.exp
        while exp > pre_total_exp do
            self._preLevel = self._preLevel - 1
            pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
            exp = exp - pre_total_exp
        end
        pre_exp = pre_total_exp - exp
        self._expAddBar:setPercent(100)
    else
        self._preLevel = self._data.level
        pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
        pre_exp = self._data.exp - self._data.add_exp
        self._expAddBar:setPercent(self._data.exp / pre_total_exp * 100)
    end

    self._expBar = self._nodeSoldier:getChildByName('load_soldier')
    self._txtPrecent = self._nodeSoldier:getChildByName('txt_soldier_desc')
    self._txtLvl = self._nodeSoldier:getChildByName('txt_soldier_level')
    self._txtLvl:setString(self._report.drill_tile .. StaticData['local_text']['label.common.level'] .. 'Lv.' .. self._preLevel)

    self._txtAdd:setString('+' .. self._data.add_exp)
    local id = uq.cache.drill:getDrillIdOperation()
    self._expBar:setPercent(pre_exp / pre_total_exp * 100)
    self._txtPrecent:setString(pre_exp .. '/' .. pre_total_exp)

    local delta = self._data.add_exp / 10
    self._addBarTag = "_add_loading_bar" .. tostring(self)
    uq.TimerProxy:removeTimer(self._addBarTag)
    uq.TimerProxy:addTimer(self._addBarTag, function()
        pre_exp = pre_exp + delta
        local integer_pre_exp = math.floor(pre_exp + 0.1)
        self._expBar:setPercent(integer_pre_exp / pre_total_exp * 100)
        self._txtPrecent:setString(integer_pre_exp .. '/' .. pre_total_exp)
        if integer_pre_exp >= pre_total_exp then
            pre_exp = integer_pre_exp - pre_total_exp
            self._preLevel = self._preLevel + 1
            pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
            integer_pre_exp = pre_exp
            self._txtLvl:setString(self._report.drill_tile .. StaticData['local_text']['label.common.level'] .. 'Lv.' .. self._preLevel)
            self._expBar:setPercent(pre_exp / pre_total_exp * 100)
            if self._preLevel < self._data.level then
                self._expAddBar:setPercent(100)
            else
                self._expAddBar:setPercent(self._data.exp / pre_total_exp * 100)
            end
            self._txtPrecent:setString(pre_exp .. '/' .. pre_total_exp)
        end
        if integer_pre_exp >= self._data.exp and self._preLevel >= self._data.level then
            integer_pre_exp = self._data.exp
            self._txtAdd:setVisible(false)
            uq.TimerProxy:removeTimer(self._addBarTag)
        end
    end, 0.1, 20)

    self._btnGuide:setVisible(self._report.instance_id ~= nil)
    self:initUI()
    uq.playSoundByID(59)
end

function NPCDrillLostModule:initUI()
    self._showXmlData = StaticData['defeat'][uq.cache.role:level()]
    self:initNodeTextData(self._btnEmbattle)
    self:initNodeTextData(self._btnEquip)
    self:initNodeTextData(self._btnGeneral)
    self:initNodeTextData(self._btnTech)
end

function NPCDrillLostModule:initNodeTextData(btn)
    local index = btn.index
    local modules = self._showXmlData['moduleId' .. index]
    local tab_module = string.split(modules, ',')
    if #tab_module == 1 then
        table.insert(self._tabModules, tonumber(modules))
    else
        local module_index = math.random(1, #tab_module)
        table.insert(self._tabModules, tonumber(tab_module[module_index]))
    end

    local moduleId = self._tabModules[index]
    local module_data = StaticData['module'][moduleId]
    if not module_data then
        return
    end
    btn:getChildByName('text_desc'):setString(module_data.name)
    btn:loadTextureNormal('img/battle/' .. module_data.jumpIcon)
    btn:loadTexturePressed('img/battle/' .. module_data.jumpIcon)
end

function NPCDrillLostModule:onBtnAction(event)
    if event.name ~= "ended" then
        return
    end

    local index = event.target.index
    uq.jumpToModule(self._tabModules[index])
end

function NPCDrillLostModule:dispose()
    local is_replay = self._isReplay
    NPCDrillLostModule.super.dispose(self)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if not is_replay then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NPC_LOST})
    end
end

function NPCDrillLostModule:onReplay(event)
    if event.name == "ended" then
        self._report.is_replay = true
        self._isReplay = true
        uq.BattleReport:getInstance():replayReport(self._report, self._rewards)
    end
end

function NPCDrillLostModule:onGuide(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_GUIDE_MODULE, {instance_id = self._report.instance_id, npc_id = self._report.npc_id})
end

function NPCDrillLostModule:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end
return NPCDrillLostModule
local NPCLostModule = class("NPCLostModule", require('app.base.PopupBase'))

NPCLostModule.RESOURCE_FILENAME = 'instance/InstanceLostView.csb'
NPCLostModule.RESOURCE_BINDING = {
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

function NPCLostModule:ctor(name, params)
    NPCLostModule.super.ctor(self, name, params)
    self._report = params.report
    self._isReplay = false
end

function NPCLostModule:onCreate()
    NPCLostModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
end

function NPCLostModule:init()
    self._btnEmbattle.index = 1
    self._btnGeneral.index = 2
    self._btnEquip.index = 3
    self._btnTech.index = 4
    self._tabModules = {}

    self._nodeBattle:setVisible(true)
    self._nodeSoldier:setVisible(false)
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

    self._txtLeftSoldier = self._nodeBattle:getChildByName('left_soldier_txt')
    self._txtLostSoldier = self._nodeBattle:getChildByName('lost_soldier_txt')
    self._txtLeftSoldier:setString(uq.formatResource(left_num, true))
    self._txtLostSoldier:setString(uq.formatResource(lost_num, true))

    self._btnGuide:setVisible(self._report.instance_id ~= nil)
    self:initUI()
    uq.playSoundByID(59)
end

function NPCLostModule:initUI()
    self._showXmlData = StaticData['defeat'][uq.cache.role:level()]
    self:initNodeTextData(self._btnEmbattle)
    self:initNodeTextData(self._btnEquip)
    self:initNodeTextData(self._btnGeneral)
    self:initNodeTextData(self._btnTech)
end

function NPCLostModule:initNodeTextData(btn)
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

function NPCLostModule:onBtnAction(event)
    if event.name ~= "ended" then
        return
    end

    local index = event.target.index
    uq.jumpToModule(self._tabModules[index])
end

function NPCLostModule:dispose()
    local is_replay = self._isReplay
    NPCLostModule.super.dispose(self)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if not is_replay then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NPC_LOST})
    end
end

function NPCLostModule:onReplay(event)
    if event.name == "ended" then
        self._report.is_replay = true
        self._isReplay = true
        uq.BattleReport:getInstance():replayReport(self._report)
    end
end

function NPCLostModule:onGuide(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_GUIDE_MODULE, {instance_id = self._report.instance_id, npc_id = self._report.npc_id})
end

function NPCLostModule:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end
return NPCLostModule
local ArenaLostModule = class("ArenaLostModule", require('app.base.PopupBase'))

ArenaLostModule.RESOURCE_FILENAME = 'instance/InstanceLostView.csb'
ArenaLostModule.RESOURCE_BINDING = {
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
    ["Node_4"]           = {["varname"] = "_nodeReward"},
    ["Text_7"]           = {["varname"] = "_txtCurRank"},
    ["img_arrow"]        = {["varname"] = "_imgArrow"},
    ["Text_5"]           = {["varname"] = "_txtRankDiff"},
    ["Text_67"]          = {["varname"] = "_txtTitle"},
    ["Text_69"]          = {["varname"] = "_txtNoChange"},
}

function ArenaLostModule:ctor(name, params)
    ArenaLostModule.super.ctor(self, name, params)
    self._data = params.base_data
    self._report = params.report
    self._rewards = self._data.rewards
    self._callback = params.callback
    self._isReplay = false
    self._desTitle = params.text
end

function ArenaLostModule:onCreate()
    ArenaLostModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
end

function ArenaLostModule:init()
    self._btnEmbattle.index = 1
    self._btnGeneral.index = 2
    self._btnEquip.index = 3
    self._btnTech.index = 4
    self._tabModules = {}

    self._nodeBattle:setVisible(false)
    self._nodeSoldier:setVisible(false)

    self._btnGuide:setVisible(false)
    self:initUI()
    uq.playSoundByID(59)
end

function ArenaLostModule:initUI()
    self._showXmlData = StaticData['defeat'][uq.cache.role:level()]
    self:initNodeTextData(self._btnEmbattle)
    self:initNodeTextData(self._btnEquip)
    self:initNodeTextData(self._btnGeneral)
    self:initNodeTextData(self._btnTech)


    if self._rewards then
        local rwds = ''
        for i = 1, #self._rewards do
            local rwd_str = string.format('%d;%d;%d', self._rewards[i].type, self._rewards[i].num, self._rewards[i].paraml)
            rwds = rwds .. rwd_str
            if i ~= #self._rewards then
                rwds = rwds .. '|'
            end
        end

        local reward_items = uq.RewardType.parseRewards(rwds)
        local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
        reward_node:setPositionX(-total_width / 2)
        self._nodeReward:addChild(reward_node)
        self._nodeReward:setScale(0.7)
    end

    self._imgArrow:setVisible(self._data.rank_diff < 0)
    self._txtRankDiff:setString(self._data.rank_diff)
    local rank_string = (self._data.new_rank >= 5000 or self._data.new_rank <= 0) and StaticData['local_text']['tower.rank.des1'] or self._data.new_rank
    self._txtCurRank:setString(rank_string)
    self._txtNoChange:setVisible(self._data.rank_diff == 0)

    if self._desTitle then
        self._txtTitle:setString(self._desTitle)
    end
end

function ArenaLostModule:initNodeTextData(btn)
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

function ArenaLostModule:onBtnAction(event)
    if event.name ~= "ended" then
        return
    end
    local index = event.target.index
    uq.jumpToModule(self._tabModules[index])
end

function ArenaLostModule:dispose()
    local is_replay = self._isReplay
    ArenaLostModule.super.dispose(self)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if not is_replay then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NPC_LOST})
    end
end

function ArenaLostModule:onReplay(event)
    if event.name ~= "ended" then
        return
    end
    self._isReplay = true
    uq.runCmd('enter_single_battle_report', {self._report, handler(self, self._onPlayReportEnd)})
end

function ArenaLostModule:_onPlayReportEnd(report)
    if self._callback then
        self._callback(report)
    end
end

function ArenaLostModule:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end
return ArenaLostModule
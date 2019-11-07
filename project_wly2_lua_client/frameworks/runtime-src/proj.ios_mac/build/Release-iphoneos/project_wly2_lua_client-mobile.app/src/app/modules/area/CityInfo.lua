local CityInfo = class("CityInfo", require('app.base.PopupBase'))

CityInfo.RESOURCE_FILENAME = "area/CityInfo.csb"
CityInfo.RESOURCE_BINDING = {
    ["Text_1_0"]           = {["varname"] = "_txtCanAttack"},
    ["Text_1_1_1"]         = {["varname"] = "_txtFlag"},
    ["Text_1_1_0_0_0_0"]   = {["varname"] = "_txtPlayerName"},
    ["Text_1_1_0_0_0_0_0"] = {["varname"] = "_txtTitle"},
    ["Text_1_2"]           = {["varname"] = "_txtMasterName"},
    ["Node_1"]             = {["varname"] = "_nodeMaster"},
    ["Text_1_1_0_0"]       = {["varname"] = "_txtFollowerName"},
    ["Text_1_1_0_0_0"]     = {["varname"] = "_txtFollowerNum"},
    ["Button_2_0"]         = {["varname"] = "_btnFace",["events"] = {{["event"] = "touch",["method"] = "onFace"}}},
    ["Button_1"]           = {["varname"] = "_btnRepalce",["events"] = {{["event"] = "touch",["method"] = "onReplace"}}},
    ["Button_2"]           = {["varname"] = "_btnFollower",["events"] = {{["event"] = "touch",["method"] = "onFollower"}}},
}

function CityInfo:ctor(name, params)
    CityInfo.super.ctor(self, name, params)
end

function CityInfo:onCreate()
    CityInfo.super.onCreate(self)

    self:centerView()
    --self:setLayerColor(0.4)
    self:parseView()
end

function CityInfo:onExit()

    CityInfo.super:onExit()
end

function CityInfo:setData(data)
    self._cityData = data
    if data.isRefuseFight == 0 then
        self._txtCanAttack:setString('可攻击')
        self._txtCanAttack:setTextColor(cc.c3b(0,255,0))
    else
        self._txtCanAttack:setString('不可攻击')
        self._txtCanAttack:setTextColor(cc.c3b(255,0,0))
    end
    self._txtFlag:setString(data.flagName)
    self._txtPlayerName:setString(data.playerName)

    local config = uq.cache.area:attackTitle(data.attackVal)
    self._txtTitle:setString(config.name)
    self._txtTitle:setTextColor(uq.parseColor(config.color))

    self._btnRepalce:setVisible(self._cityData.playerName == uq.cache.role.name)
    self._btnFollower:setVisible(self._cityData.playerName == uq.cache.role.name)
    self._btnFace:setVisible(self._cityData.playerName == uq.cache.role.name)
    self._btnFollower:setEnabled(uq.config.OpenModule:checkModuleOpend(3))
end

function CityInfo:setMaster(data)
    if data.master_info[1].master_Name ~= '' then
        self._nodeMaster:setVisible(true)
        self._txtMasterName:setString(data.master_info[1].master_Name)
    else
        self._nodeMaster:setVisible(false)
    end

    if self:getFollowerNum(data.master_info[1].master_name_info) > 0 then
        self._txtFollowerName:setString(data.master_info[1].master_name_info[1].feudatory_Name)
        self._txtFollowerNum:setString(self:getFollowerNum(data.master_info[1].master_name_info) .. '/5')
    else
        self._txtFollowerName:setString('')
        self._txtFollowerNum:setString('')
    end
end

function CityInfo:getFollowerNum(data)
    local num = 0
    for k,item in ipairs(data) do
        if item.feudatory_Name ~= '' then
            num = num + 1
        end
    end
    return num
end

function CityInfo:onFace(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.AREA_CITY_FACE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._cityData)
        end
        --self:disposeSelf()
    end
end

function CityInfo:onReplace(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.AREA_REPLACE_FLAG, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._cityData)
        end
    end
end

function CityInfo:refreshCurPage()
    local all_data = uq.cache.area:getCityInfo()
    for k,item in ipairs(all_data) do
        if item.seq_no == self._cityData.seq_no then
            self._cityData = item
            break
        end
    end
    self:setData(self._cityData)
end

function CityInfo:onFollower(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.AREA_FOLLOWER, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._cityData)
        end
    end
end

return CityInfo
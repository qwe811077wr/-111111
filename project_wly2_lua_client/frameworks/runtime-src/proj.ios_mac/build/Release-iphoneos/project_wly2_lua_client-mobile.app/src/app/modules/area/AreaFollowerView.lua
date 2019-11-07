local AreaFollowerView = class("AreaFollowerView", require('app.base.PopupBase'))

AreaFollowerView.RESOURCE_FILENAME = "area/AreaFollowerView.csb"
AreaFollowerView.RESOURCE_BINDING = {
    ["Node_1"]            = {["varname"] = "_nodeMaster"},
    ["txtMasterVip"]      = {["varname"] = "_txtMasterVip"},
    ["txtMasterName"]     = {["varname"] = "_txtMasterName"},
    ["txtMasterFight"]    = {["varname"] = "_txtMasterFight"},
    ["txtMasterLevel"]    = {["varname"] = "_txtMasterLevel"},
    ["txtMasterCropName"] = {["varname"] = "_txtMasterCropName"},
    ["txtMasterAreaName"] = {["varname"] = "_txtMasterAreaName"},
    ["txtMasterUse"]      = {["varname"] = "_txtMasterUse"},
    ["txtMasterAdd"]      = {["varname"] = "_txtMasterAdd"},
    ["Text_1_2_0_2_0"]    = {["varname"] = "_txtSubReward"},
    --["Image_1"]    = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onBgTouch"}}},
}

function AreaFollowerView:onCreate()
    AreaFollowerView.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    local pos = {377, 234, 95}
    self._followerList = {}

    for i = 1, 3 do
        local panel = uq.createPanelOnly('area.AreaFollowerInfo')
        panel:setPosition(cc.p(511 - 590/2 + 15, pos[i] - 220))
        self:addChild(panel)

        table.insert(self._followerList, panel)
    end
    self._nodeMaster:setVisible(false)
end

function AreaFollowerView:setData(data)
    self._cityData = data
    local data = {
        world_area_id   = self._cityData.area_index,
        area_zone_index = self._cityData.part_index,
        zone_index      = self._cityData.seq_no,
        name_len        = self._cityData.playerNameLen,
        player_name     = self._cityData.playerName
    }
    network:sendPacket(Protocol.C_2_S_AREA_CITYINFO, data)
end

function AreaFollowerView:refreshPage(data)
    if data.master_info[1].master_Name ~= '' then
        self._nodeMaster:setVisible(true)
        self._txtMasterName:setString(data.master_info[1].master_Name)
    else
        self._nodeMaster:setVisible(false)
    end
    self._txtSubReward:setString('x0')

    for i = 1, 3 do
        self._followerList[i]:setData(i, data)
    end
end

return AreaFollowerView
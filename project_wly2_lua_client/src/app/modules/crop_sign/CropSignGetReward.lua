local CropSignGetReward = class("CropSignGetReward", require('app.base.PopupBase'))

CropSignGetReward.RESOURCE_FILENAME = "instance/InstanceRewardInfo.csb"
CropSignGetReward.RESOURCE_BINDING = {
    ["Node_1"]   = {["varname"] = "_nodeReward"},
    ["Button_2"] = {["varname"] = "_btnGet",["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClosePanel"}}},
}

function CropSignGetReward:onCreate()
    CropSignGetReward.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function CropSignGetReward:onExit()
    CropSignGetReward.super.onExit(self)
end

function CropSignGetReward:setData(reward_info, got, id, can_get)
    self._got = got
    self._id = id
    self._canGet = can_get
    local reward_items = uq.RewardType.parseRewards(reward_info)
    local space = 50
    local node_parent = cc.Node:create()
    local total_width = 0
    for k, item in ipairs(reward_items) do
        local panel = uq.createPanelOnly('instance.DropItem')
        panel:setData(item._rewardStr)
        panel:setImgNameVisible(true, false)

        local size = panel:getContentSize()
        local x = (size.width + space) * (k - 1) + size.width / 2
        panel:setPositionX(x)

        node_parent:addChild(panel)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeReward:addChild(node_parent)

    self._btnGet:setEnabled(true)
    if got == 0 then
        self._btnGet:setTitleText(StaticData['local_text']['label.receive'])
        self._btnGet:setEnabled(self._canGet)
        if not self._canGet then
            uq.ShaderEffect:addGrayButton(self._btnGet)
        end
    else
        self._btnGet:setTitleText(StaticData['local_text']['world.city.gate.des1'])
    end
end

function CropSignGetReward:onGetReward(event)
    if event.name ~= "ended" then
        return
    end
    if self._got == 0 then
        network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_DRAW)
        self:disposeSelf()
    else
        self:disposeSelf()
    end
end

function CropSignGetReward:onClosePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return CropSignGetReward
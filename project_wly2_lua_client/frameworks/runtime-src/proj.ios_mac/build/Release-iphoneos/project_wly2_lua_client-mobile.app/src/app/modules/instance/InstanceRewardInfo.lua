local InstanceRewardInfo = class("InstanceRewardInfo", require('app.base.PopupBase'))

InstanceRewardInfo.RESOURCE_FILENAME = "instance/InstanceRewardInfo.csb"
InstanceRewardInfo.RESOURCE_BINDING = {
    ["Node_1"]   = {["varname"] = "_nodeReward"},
    ["Button_2"] = {["varname"] = "_btnGet",["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClosePanel"}}},
}

function InstanceRewardInfo:onCreate()
    InstanceRewardInfo.super.onCreate(self)
    self:centerView()
    self:parseView()
    self._btnType = 1
end

function InstanceRewardInfo:setData(xml_data, instance_id, reward_id)
    local reward_items = uq.RewardType.parseRewards(xml_data.reward)
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

    self._xmlData = xml_data
    self._instanceId = instance_id
    self._rewardId = reward_id

    local star_num = uq.cache.instance:getChapterTotalStar(self._instanceId)
    if not uq.cache.instance:isRewardGet(self._rewardId) and xml_data.star <= star_num then
        self._btnGet:setTitleText(StaticData['local_text']['label.receive'])
    else
        self._btnGet:setTitleText(StaticData['local_text']['world.city.gate.des1'])
    end
end

function InstanceRewardInfo:setRewardInfo(rewards, btn_type, btn_des)
    self._btnType = btn_type or 1
    btn_des = btn_des or StaticData['local_text']['world.city.gate.des1']
    local reward_items = uq.RewardType.parseRewards(rewards)
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
    self._btnGet:setTitleText(btn_des)
end

function InstanceRewardInfo:onGetReward(event)
    if event.name ~= "ended" then
        return
    end
    if self._btnType == 1 then
        local star_num = uq.cache.instance:getChapterTotalStar(self._instanceId)
        if not uq.cache.instance:isRewardGet(self._rewardId) and self._xmlData.star <= star_num then
            network:sendPacket(Protocol.C_2_S_INSTANCE_DRAW, {id = self._rewardId, chapter_id = self._instanceId})
        end
    end
    self:disposeSelf()
end

function InstanceRewardInfo:onClosePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return InstanceRewardInfo
local CropPop = class("CropPop", require('app.base.PopupBase'))

CropPop.RESOURCE_FILENAME = "crop/CropPop.csb"
CropPop.RESOURCE_BINDING = {
    ["Node_1"]           = {["varname"] = "_nodeExit"},
    ["Node_1_0"]         = {["varname"] = "_nodeOtherMember"},
    ["Node_1_1"]         = {["varname"] = "_nodeTime"},
    ["Node_1_1_0"]       = {["varname"] = "_nodeReward"},
    ["Button_confirm_1"] = {["varname"] = "Button_confirm_1",["events"] = {{["event"] = "touch",["method"] = "onConfirmExit"}}},
    ["Button_cancle_1"]  = {["varname"] = "Button_cancle_1",["events"] = {{["event"] = "touch",["method"] = "onCancleExit"}}},
    ["Button_confirm_3"] = {["varname"] = "Button_confirm_3",["events"] = {{["event"] = "touch",["method"] = "onConfirmExit"}}},
    ["Button_cancle_3"]  = {["varname"] = "Button_cancle_3",["events"] = {{["event"] = "touch",["method"] = "onCancleExit"}}},
    ["Button_confirm_2"] = {["varname"] = "Button_confirm_2",["events"] = {{["event"] = "touch",["method"] = "onCancleExit"}}},
    ["Button_reward"]    = {["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "onReward"}}},
    ["Node_5"]           = {["varname"] = "_nodeAward"},
    ["Text_1_0_0_0"]     = {["varname"] = "_txtAward"},
}

function CropPop:onCreate()
    CropPop.super.onCreate(self)

    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()

    self._nodeExit:setVisible(false)
    self._nodeOtherMember:setVisible(false)
    self._nodeTime:setVisible(false)
    self._nodeReward:setVisible(false)
end

function CropPop:onExit()
    CropPop.super:onExit()
end

function CropPop:showDismiss()
    self._nodeExit:setVisible(true)
end

function CropPop:showCannotDismiss()
    self._nodeOtherMember:setVisible(true)
end

function CropPop:showDismissCD()
    self._nodeTime:setVisible(true)
end

function CropPop:showReward()
    self._nodeReward:setVisible(true)
end

function CropPop:setIsLeader(flag)
    self._isLeader = flag
end

function CropPop:onConfirmExit(event)
    if event.name == "ended" then
        if self._isLeader then
            network:sendPacket(Protocol.C_2_S_CROP_DISMISS)
        else
            network:sendPacket(Protocol.C_2_S_CROP_QUIT)
        end
        self:disposeSelf()
    end
end

function CropPop:onCancleExit(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function CropPop:onReward(event)
    if event.name == "ended" then
        --network:sendPacket(Protocol.C_2_S_CROPS_REWARD_GAIN)
        self:disposeSelf()
    end
end

return CropPop
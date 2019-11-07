local InstanceGeneralItem = class("InstanceGeneralItem", require('app.base.ChildViewBase'))

InstanceGeneralItem.RESOURCE_FILENAME = "instance/InstanceRewardItem.csb"
InstanceGeneralItem.RESOURCE_BINDING = {
    ["Node_1"]  = {["varname"]= "_nodeBase"},
    ["Image_3"] = {["varname"]="_imgIcon"},
    ["Text_1"]  = {["varname"]="_txtTip"},
    ["Text_3"]  = {["varname"]="_txtName"},
    ["Panel_3"] = {["varname"]="_panelMask"},
    ["Image_5"] = {["varname"]="_imgGot"},
}

function InstanceGeneralItem:onCreate()
    InstanceGeneralItem.super.onCreate(self)
end

function InstanceGeneralItem:setData(general_id, npc_id, instance_data)
    self._npcId = npc_id
    local general_config = StaticData['general'][general_id]
    self._imgIcon:loadTexture("img/common/general_head/" .. general_config.miniIcon)
    self._txtTip:setString(string.format(StaticData['local_text']['label.instance.pass'], instance_data.chapter, npc_id % 100))
    self._txtName:setString(general_config.name)
end

function InstanceGeneralItem:refreshPage()
    self._panelMask:setVisible(self._npcId <= uq.cache.instance:getMaxNpcID())
    self._imgGot:setVisible(self._npcId <= uq.cache.instance:getMaxNpcID())
end

function InstanceGeneralItem:showAction()
    uq.intoAction(self._nodeBase, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
end

return InstanceGeneralItem
local CropLeaderHead = class("CropLeaderHead", require('app.base.ChildViewBase'))

CropLeaderHead.RESOURCE_FILENAME = "crop/CropInfoHead.csb"
CropLeaderHead.RESOURCE_BINDING = {
    ["Image_12"]  = {["varname"] = "_imgHead"},
    ["Text_16"]   = {["varname"] = "_txtPos"},
    ["Text_16_0"] = {["varname"] = "_txtName"},
    ["Text_16_1"] = {["varname"] = "_txtPower"},
    ["Text_1"]    = {["varname"] = "_txtNone"},
    ["Node_2"]    = {["varname"] = "_nodeInfo"},
}

function CropLeaderHead:onCreate()
    CropLeaderHead.super.onCreate(self)
end

function CropLeaderHead:setData(data, pos)
    local pos_config = StaticData['types'].Position[1].Type[pos]
    self._txtPos:setString(pos_config.name)
    self._txtPos:setTextColor(uq.parseColor(pos_config.color))

    self._txtNone:setVisible(data == nil)
    self._nodeInfo:setVisible(data ~= nil)
    self._imgHead:setVisible(data ~= nil)
    if not data then
        return
    end
    local res_head = uq.getHeadRes(data.img_id, data.img_type)
    self._imgHead:loadTexture(res_head)

    self._txtName:setString(data.name)
    self._txtPower:setString(StaticData['local_text']['label.power'] .. string.format(' %d', data.power))

    local str = {}
    str[uq.config.constant.GOVERNMENT_POS.SUB_COMMANDER] = 'crop.government.des7'
    str[uq.config.constant.GOVERNMENT_POS.WARLOAD] = 'crop.government.des8'
    str[uq.config.constant.GOVERNMENT_POS.TATRAP] = 'crop.government.des9'
end

return CropLeaderHead
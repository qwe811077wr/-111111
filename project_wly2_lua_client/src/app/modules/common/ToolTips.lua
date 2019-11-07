local ToolTips = class("ToolTips", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

ToolTips.RESOURCE_FILENAME = "common/ToolTips.csb"

ToolTips.RESOURCE_BINDING  = {
    ["Image_2"]                     = {["varname"] = "_bgImg"},
    ["panel_txt"]                   = {["varname"] = "_panelTxt"},
    ["txt_name"]                    = {["varname"] = "_labelName"},
    ["txt_num"]                     = {["varname"] = "_labelNum"},
    ["Node_2"]                      = {["varname"] = "_nodeItem"},
    ["Text_6"]                      = {["varname"] = "_labelNumHead"},
}

function ToolTips:ctor(name, args)
    ToolTips.super.ctor(self, name, args)
    self._curToolInfo = args.info
    self._gameMode = args.mode
end

function ToolTips:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._toolItem = EquipItem:create({info = self._curToolInfo})
    self._toolItem:setScale(0.75)
    self._toolItem._nameLabel:setVisible(false)
    self._nodeItem:addChild(self._toolItem)
    self:updateInfo()
end

function ToolTips:updateInfo()
    local xml_data = StaticData.getCostInfo(self._curToolInfo.type, self._curToolInfo.id)
    self._labelName:setString(xml_data.name)
    local num = 0
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        num = uq.cache.instance_war:getRes(self._curToolInfo.type, self._curToolInfo.id)
    else
        num = uq.cache.role:getResNum(self._curToolInfo.type, self._curToolInfo.id)
    end
    self._labelNum:setString(uq.formatResource(num))

    local lbl_desc = ccui.Text:create()
    local size = self._panelTxt:getContentSize()
    lbl_desc:setFontSize(20)
    lbl_desc:setPositionY(size.height)
    lbl_desc:setString(xml_data.desc)
    lbl_desc:setFontName("font/hwkt.ttf")
    lbl_desc:setColor(cc.c3b(239, 253, 255))
    lbl_desc:enableShadow(uq.parseColor("#191d1c"), cc.size(-1, -1))
    lbl_desc:setAnchorPoint(cc.p(0, 1))
    lbl_desc:setTextAreaSize(cc.size(size.width, 0))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self._panelTxt:addChild(lbl_desc)

    if self._curToolInfo.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        local desc = StaticData['types'].Cost[1].Type[self._curToolInfo.type].desc
        local total_num = xml_data.composeNums
        lbl_desc:setString(string.format(desc, total_num, xml_data.name, xml_data.name))
    end

    local height = lbl_desc:getContentSize().height
    self._bgImg:setContentSize(cc.size(self._bgImg:getContentSize().width, self._bgImg:getContentSize().height + height))
    local pos_y = self:getPositionY()
    self:setPositionY(pos_y + height * 0.5)
end

return ToolTips

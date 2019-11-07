local AreaReplaceFlag = class("AreaReplaceFlag", require('app.base.PopupBase'))

AreaReplaceFlag.RESOURCE_FILENAME = "area/AreaReplaceFlag.csb"
AreaReplaceFlag.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"] = "_panelWrite"},
    ["Text_1_0_0"] = {["varname"] = "_txtFlag"},
    ["Button_1"]   = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_1_0"] = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function AreaReplaceFlag:ctor(name, params)
    AreaReplaceFlag.super.ctor(self, name, params)
end

function AreaReplaceFlag:onCreate()
    AreaReplaceFlag.super.onCreate(self)
    self:centerView()
    self:parseView()

    local size = self._panelWrite:getContentSize()
    self._editBoxContent = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxContent:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxContent:setFontName("Arial")
    self._editBoxContent:setFontSize(22)
    self._editBoxContent:setFontColor(cc.c3b(255, 255, 255))
    self._editBoxContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxContent:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxContent:setPosition(cc.p(size.width/2, size.height/2))
    self._editBoxContent:setPlaceholderFontName("Arial")
    self._editBoxContent:setPlaceholderFontSize(22)
    self._editBoxContent:setPlaceHolder('输入一个字做为旗号')
    self._editBoxContent:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._panelWrite:addChild(self._editBoxContent)
end

function AreaReplaceFlag:setData(data)
    self._cityData = data
    self._txtFlag:setString(data.flagName)
end

function AreaReplaceFlag:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function AreaReplaceFlag:onConfirm(event)
    if event.name == "ended" then
        local str = self._editBoxContent:getText()
        if str == '' then
            uq.fadeInfo('输入内容不能为空')
            return
        end
        if uq.hasKeyWord(str) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        local flag = string.subUtf(str, 1, 1)
        local data = {
            world_area_id   = self._cityData.area_index,
            area_zone_index = self._cityData.part_index,
            zone_index      = self._cityData.seq_no,
            flag_len        = string.len(flag),
            flag            = flag
        }
        network:sendPacket(Protocol.C_2_S_CHANGE_PALYER_FLAG, data)
        self:disposeSelf()
    end
end

return AreaReplaceFlag
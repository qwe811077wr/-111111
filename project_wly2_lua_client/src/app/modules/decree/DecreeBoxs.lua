local DecreeBoxs = class("DecreeBoxs", require('app.base.ChildViewBase'))

DecreeBoxs.RESOURCE_FILENAME = "decree/DecreeBoxs.csb"
DecreeBoxs.RESOURCE_BINDING = {
    ["title_txt"]                     = {["varname"] = "_txtTitle"},
    ["Image_2"]                       = {["varname"] = "_imgBg"},
    ["btn_txt"]                       = {["varname"] = "_txtBtn"},
    ["limit_txt"]                     = {["varname"] = "_txtLimit"},
    ["dec_txt"]                       = {["varname"] = "_txtDec"},
    ["Sprite_1"]                      = {["varname"] = "_sprIcon"},
    ["Text_2"]                        = {["varname"] = "_txtNum"},
    ["Button_1"]                      = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnGroup",["sound_id"] = 0}}},
}

function DecreeBoxs:onCreate()
    DecreeBoxs.super.onCreate(self)
    self:parseView()
    self._data = {}
end

function DecreeBoxs:setData(data)
    self._data = data or {}
    if not self._data or next(self._data) == nil then
        return
    end
    self._imgBg:loadTexture("img/decree/" .. self._data.picture)
    self._txtTitle:setString(self._data.name)
    local reward = uq.cache.decree:getDecreeReWard(self._data.ident)
    local is_lock = not reward or next(reward) == nil
    self._txtBtn:setVisible(not is_lock)
    self._btnOk:setVisible(not is_lock)
    self._txtLimit:setVisible(is_lock)
    self._txtDec:setVisible(not is_lock)
    self._sprIcon:setVisible(not is_lock)
    self._txtNum:setVisible(not is_lock)
    self._txtBtn:setString(self._data.button)
    if not is_lock then
        for _, v in ipairs(reward) do
            self._txtNum:setString(tostring(v.num))
            local xml_data = StaticData.getCostInfo(v.type, v.id)
            if xml_data and next(xml_data) ~= nil then
                self._sprIcon:setTexture("img/common/ui/" .. xml_data.miniIcon)
                self._txtDec:setString(string.format(StaticData["local_text"]["decree.estimate.reward"], xml_data.name))
            end
            break
        end
    end
end

function DecreeBoxs:onBtnGroup(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    if not self._data or next(self._data) == nil then
        return
    end
    if uq.cache.decree:getNumDecree() < self._data.cost then
        uq.fadeInfo(StaticData["local_text"]["decree.not.enought"])
        return
    end
    network:sendPacket(Protocol.C_2_S_DECREE, {id = self._data.ident, count = 1})
end

return DecreeBoxs
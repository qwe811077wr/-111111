local GeneralSkillModule = class("GeneralSkillModule", require("app.base.PopupBase"))

GeneralSkillModule.RESOURCE_FILENAME = "generals/GeneralSkillModule.csb"
GeneralSkillModule.RESOURCE_BINDING = {
    ["Image_3"]                     = {["varname"] = "_imgHead"},
    ["Image_2"]                     = {["varname"] = "_imgBg"},
    ["Text_2"]                      = {["varname"] = "_txtSkillName"},
    ["Text_3"]                      = {["varname"] = "_txtSkillDes"}
}

function GeneralSkillModule:ctor(name, params)
    params._isStopAction = true
    GeneralSkillModule.super.ctor(self, name, params)
    self._skillId = params.skill_id
end

function GeneralSkillModule:init()
    self:parseView()
    if not self._skillId then
        return
    end
    self:initPage()
end

function GeneralSkillModule:setSkillId(skill_id)
    self._skillId = skill_id
    if not self._skillId then
        return
    end
    self:initPage()
end

function GeneralSkillModule:initPage()
    local skill_xml = StaticData['skill'][self._skillId]
    if not skill_xml then
        return
    end
    self._txtSkillDes:setHTMLText(skill_xml.tooltip, nil, nil, nil, true, nil)
    local skill_des = string.split(skill_xml.skillType, ',')
    for i = 1, 2 do
        local img = self._view:getChildByName("Image_4_" .. i)
        local state = skill_des[i] ~= nil
        img:setVisible(state)
        if state then
            local img_icon = StaticData['types'].SkillType[1].Type[tonumber(skill_des[i])].icon
            img:loadTexture("img/generals/" .. img_icon)
        end
    end
    self._txtSkillName:setString(skill_xml.name)

    local size = self._txtSkillDes:getContentSize()
    local bg_size = self._imgBg:getContentSize()
    local head_size = self._imgHead:getContentSize()
    self._imgBg:setContentSize(cc.size(bg_size.width, size.height + head_size.height + 20))
end

function GeneralSkillModule:dispose()
    GeneralSkillModule.super.dispose(self)
end

return GeneralSkillModule
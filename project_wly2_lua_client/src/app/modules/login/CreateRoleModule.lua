local CreateRoleModule = class("CreateRoleModule", require('app.base.ModuleBase'))

CreateRoleModule.RESOURCE_FILENAME = "login/CreateRoleView.csb"
CreateRoleModule.RESOURCE_BINDING = {
    ["Button_1"]                           = {["varname"] = "_btn1"},
    ["Button_2"]                           = {["varname"] = "_btn2"},
    ["Button_3"]                           = {["varname"] = "_btn3"},
    ["Button_4"]                           = {["varname"] = "_btnOk"},
    ["head_icon"]                          = {["varname"] = "_nodeHead"},
    ["name_node"]                          = {["varname"] = "_nodeName"},
    ["Node_1"]                             = {["varname"] = "_nodeTitle1"},
    ["Node_1/Sprite_2"]                    = {["varname"] = "_sprSkill1"},
    ["Node_2"]                             = {["varname"] = "_nodeTitle2"},
    ["Node_2/Sprite_3"]                    = {["varname"] = "_sprSkill2"},
    ["body_1_node"]                        = {["varname"] = "_nodeBody1"},
    ["body_2_node"]                        = {["varname"] = "_nodeBody2"},
    ["Node_3"]                             = {["varname"] = "_nodeActionBlue"},
    ["Node_4"]                             = {["varname"] = "_nodeClick"},
    ["arrow_left_img"]                     = {["varname"] = "_imgArrow1"},
    ["arrow_right_img"]                    = {["varname"] = "_imgArrow2"},
    ["head_icon/Image_19"]                 = {["varname"] = "_imgHead"},
    ["body_2_node/Image_28"]               = {["varname"] = "_imgTitle"},
    ["body_2_node/left_sprite_1"]          = {["varname"] = "_spr1"},
    ["body_2_node/left_sprite_2"]          = {["varname"] = "_spr2"},
    ["body_1_node/left_sprite_3"]          = {["varname"] = "_spr3"},
    ["body_1_node/left_sprite_4"]          = {["varname"] = "_spr4"},
    ["body_1_node/Sprite_7"]               = {["varname"] = "_sprTitle"},
    ["body_1_node/Sprite_8"]               = {["varname"] = "_sprDec"},
}

function CreateRoleModule:ctor(name, params)
    CreateRoleModule.super.ctor(self, name, params)
end

function CreateRoleModule:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self:adaptNode()
    self._powerTab = {
        [1] = uq.config.constant.COUNTRY.SHU,
        [2] = uq.config.constant.COUNTRY.WEI,
        [3] = uq.config.constant.COUNTRY.WU
    }
    self._powerStr = {
        [1] = "shu",
        [2] = "wei",
        [3] = "wu"
    }
    self._posClick = {
        [1] = cc.p(-340, 115),
        [2] = cc.p(0, 200),
        [3] = cc.p(-10, -20),
    }
    self._data = StaticData['choose_country'] or {}
    self._selectPowerIdx = 3
    self._pathPrefix = "img/login/"
    self:initLayer()
    uq.playSoundByID(1101)
    uq:addEffectByNode(self._nodeActionBlue, 900108, -1, true, cc.p(46, -21))
    uq:addEffectByNode(self._nodeActionBlue, 900109, -1, true, cc.p(-327, 114.5))
    network:addEventListener(Protocol.S_2_C_ACCOUNT_CREATE, handler(self, self._onCreateRoleResult), '_onCreateRoleResult')
end

function CreateRoleModule:initLayer()
    self:refreshLeftImg()
    self:addArrowAction()
    self:addBodyAction()
    self:addHeadAction(0)
    self._btnOk:addClickEventListenerWithSound(function()
        local role_name = uq.cache.account.rand_name
        local data = {name_len = #role_name, name = role_name, country_id = self._powerTab[self._selectPowerIdx], appearance_id = 0}
        network:sendPacket(Protocol.C_2_S_ACCOUNT_CREATE, data)
    end)
    self:selectPower(self._powerStr[self._selectPowerIdx])
    for k, v in pairs(self._powerTab) do
        self["_btn" .. k]:addClickEventListener(function()
            if k == self._selectPowerIdx then
                return
            end
            uq.playSoundByID(111)
            self:selectPower(self._powerStr[k])
            self._selectPowerIdx = k
            self:refreshLeftImg()
            self:addBodyAction()
            self:addHeadAction()
            self:addTitleAction()
            uq:addEffectByNode(self._nodeClick, 900105, 1, false, self._posClick[k])
        end)
    end
    for i, v in ipairs(self._powerStr) do
        uq:addEffectByNode(self._nodeName:getChildByName("img_" .. v .. "_min"), 900106, -1, true, cc.p(40, 150))
        uq:addEffectByNode(self._nodeName:getChildByName("img_" .. v .. "_max"), 900107, -1, true, cc.p(50, 210))
    end
end

function CreateRoleModule:selectPower(str)
    for k, v in pairs(self._powerStr) do
        self._nodeName:getChildByName("img_" .. v .. "_min"):setVisible(v ~= str)
        self._nodeName:getChildByName("img_" .. v .. "_max"):setVisible(v == str)
    end
end

function CreateRoleModule:addArrowAction()
    for i = 1, 2 do
        local off_x = i == 1 and 10 or -10
        local off_y = i == 1 and 5 or -5
        self["_imgArrow" .. i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(off_x, off_y)), cc.MoveBy:create(0.5, cc.p(-off_x, -off_y)))))
    end
end

function CreateRoleModule:addHeadAction(time)
    local out_time = time or 0.2
    self._nodeHead:stopAllActions()
    local fade_out = cc.FadeOut:create(out_time)
    local func = cc.CallFunc:create(function()
        local tab = self._data[self._powerTab[self._selectPowerIdx]] or {}
        if tab and tab.mastericon and tab.mastericon ~= "" then
            self._imgHead:loadTexture(self._pathPrefix .. tab.mastericon)
        end
    end)
    local fade_in = cc.FadeIn:create(1)
    self._nodeHead:runAction(cc.Sequence:create(fade_out, func, fade_in))
end

function CreateRoleModule:addTitleAction()
    for i=1, 2 do
        self["_nodeTitle" .. i]:setOpacity(0)
        self["_nodeTitle" .. i]:stopAllActions()
        local fade_in = cc.FadeIn:create(1)
        self["_nodeTitle" .. i]:runAction(fade_in)
    end
end

function CreateRoleModule:addBodyAction()
    local off_x = 80
    for i = 1, 2 do
        self["_nodeBody" .. i]:setOpacity(0)
        self["_nodeBody" .. i]:stopAllActions()
        self["_nodeBody" .. i]:setPosition(cc.p(-off_x, 0))
        local time = i == 1 and 0 or 0.2
        local delay = cc.DelayTime:create(time)
        local func = cc.CallFunc:create(function()
            self["_nodeBody" .. i]:setOpacity(0)
        end)
        local move = cc.MoveTo:create(0.2, cc.p(off_x, 0))
        local fade = cc.FadeIn:create(0.2)
        local spawn = cc.Spawn:create(move, fade)
        self["_nodeBody" .. i]:runAction(cc.Sequence:create(func, delay, spawn))
    end
end

function CreateRoleModule:refreshLeftImg()
    local tab = self._data[self._powerTab[self._selectPowerIdx]] or {}
    if not tab or next(tab) == nil then
        return
    end
    for i = 1, 4 do
        if tab["general" .. i] and tab["general" .. i] ~= "" then
            self["_spr" .. i]:setTexture("img/common/general_body/" .. tab["general" .. i])
        end
    end
    if tab.name then
        self._imgTitle:loadTexture(self._pathPrefix .. tab.name)
    end
    if tab.generalName then
        self._sprTitle:setTexture(self._pathPrefix .. tab.generalName)
    end
    if tab.countryIntroduce then
        self._sprDec:setTexture(self._pathPrefix .. tab.countryIntroduce)
    end
    if tab.generalIntroduce1 then
        self._sprSkill1:setTexture(self._pathPrefix .. tab.countryIntroduce)
    end
    for i = 1, 2 do
        if tab["generalIntroduce" .. i] then
            self["_sprSkill" .. i]:setTexture(self._pathPrefix .. tab["generalIntroduce" .. i])
        end
    end

end

function CreateRoleModule:_onCreateRoleResult(evt)
    local data = evt.data
    if data.ret == 2 then
        uq.fadeInfo('name duplicated')
    elseif data.ret == 1 then
        network:sendPacket(Protocol.C_2_S_LOAD_CHAR_INFO)
    else
        uq.log('create role error')
    end
end

function CreateRoleModule:dispose()
    network:removeEventListenerByTag("_onCreateRoleResult")
    CreateRoleModule.super.dispose(self)
end

return CreateRoleModule
local MapGuideLevelUp = class("MapGuideLevelUp", require('app.base.PopupBase'))

MapGuideLevelUp.RESOURCE_FILENAME = "map_guide/MapGuideLevelUp.csb"
MapGuideLevelUp.RESOURCE_BINDING = {
    ["label_title1"]            = {["varname"] = "_titleLabel1"},
    ["label_title2"]            = {["varname"] = "_titleLabel2"},
    ["label_attrdes1"]          = {["varname"] = "_attrDesLabel1"},
    ["label_attrdes2"]          = {["varname"] = "_attrDesLabel2"},
    ["label_attrnum1"]          = {["varname"] = "_numLabel1"},
    ["label_attrnum2"]          = {["varname"] = "_numLabel2"},
    ["Image_11"]                = {["varname"] = "_imgHead"},
    ["Image_9"]                 = {["varname"] = "_imgBg"},
    ["Image_3"]                 = {["varname"] = "_imgTitleBg"},
    ["Image_1"]                 = {["varname"] = "_imgLeft"},
    ["Image_1_0"]               = {["varname"] = "_imgRight"},
    ["Image_5"]                 = {["varname"] = "_imgCenter"},
    ["Panel_1"]                 = {["varname"] = "_panelBase"},
    ["Text_10"]                 = {["varname"] = "_txtTip"},
}

function MapGuideLevelUp:ctor(name, args)
    MapGuideLevelUp.super.ctor(self, name, args)
    self._desArray = {self._attrDesLabel1, self._attrDesLabel2}
    self._valueArray = {self._numLabel1, self._numLabel2}
    self._animShowTag = "anim_show_tag" .. tostring(self)
end

function MapGuideLevelUp:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    uq.playSoundByID(91)
end

function MapGuideLevelUp:initUi()
    local data = uq.cache.illustration.illustration_info
    local exp = data.total_exp
    local stage_info = nil
    local pre_stage_info = nil
    local stage_info_Array = {}
    for k, v in pairs(StaticData['Illustration'].Stage) do
        table.insert(stage_info_Array, v)
    end
    table.sort(stage_info_Array, function(a, b)
        return a.ident < b.ident
    end)
    for k, v in ipairs(stage_info_Array) do
        if v.exp > exp  then
            stage_info = v
            break
        end
        exp = exp - v.exp
    end
    if stage_info == nil then
        stage_info = stage_info_Array[#stage_info_Array]
    end

    pre_stage_info = stage_info_Array[stage_info.ident]
    if pre_stage_info == nil or stage_info == nil then
        return
    end
    self._titleLabel1:setString(pre_stage_info.name)
    self._titleLabel1:setTextColor(uq.parseColor("#" .. pre_stage_info.color))
    self._titleLabel2:setString(stage_info.name)
    self._titleLabel2:setTextColor(uq.parseColor("#" .. stage_info.color))
    local attr_array = string.split(stage_info.attribute, ";")
    local index = 1
    for k, v in ipairs(attr_array) do
        local attr = string.split(v, ",")
        local label_value = self._valueArray[k]
        if not label_value then
            break
        end
        local label_des = self._desArray[k]
        label_value:setVisible(true)
        label_des:setVisible(true)
        local type_xml = StaticData['types'].Effect[1].Type[tonumber(attr[1])]
        label_des:setString(type_xml.name)
        label_value:setString("+" .. uq.cache.generals:getNumByEffectType(tonumber(attr[1]), tonumber(attr[2])))
        index = index + 1
    end
    for k = index, 2, 1 do
        if self._valueArray[k] then
            self._valueArray[k]:setVisible(false)
        end
        if self._desArray[k] then
            self._desArray[k]:setVisible(false)
        end
    end
    self:runOpenAction()
end

function MapGuideLevelUp:runOpenAction()
    local delta = 1 / 12
    self._imgHead:setScale(0.3)
    self._imgHead:setVisible(true)
    self._imgHead:runAction(cc.ScaleTo:create(delta, 1))
    uq:addEffectByNode(self._imgHead, 900138, 1, true, cc.p(216, 116))

    self._imgBg:setOpacity(255 * 0.1)
    local bg_pos_y = self._imgBg:getPositionY()
    self._imgTitleBg:setVisible(true)
    self._imgBg:setPositionY(bg_pos_y - 100)
    self._imgBg:setVisible(true)
    self._imgBg:runAction(cc.Spawn:create(cc.FadeIn:create(3 * delta), cc.MoveBy:create(3 * delta, cc.p(0, 100))))

    self._imgLeft:setScale(0.3)
    self._imgLeft:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 4), cc.CallFunc:create(function()
        self._imgLeft:setVisible(true)
        self._imgCenter:setVisible(true)
        local effect = uq:addEffectByNode(self._imgLeft, 900013, 1, true)
        effect:setScaleX(0.6)
        effect:setScaleY(0.85)
        self._imgLeft:runAction(cc.Sequence:create(cc.ScaleTo:create(delta, 1.2), cc.ScaleTo:create(delta * 2, 1)))
    end)))
    self._imgRight:setScale(0.3)
    self._imgRight:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 5), cc.CallFunc:create(function()
        self._imgRight:setVisible(true)
        local effect = uq:addEffectByNode(self._imgRight, 900013, 1, true)
        effect:setScaleX(0.6)
        effect:setScaleY(0.85)
        self._imgRight:runAction(cc.Sequence:create(cc.ScaleTo:create(delta, 1.2), cc.ScaleTo:create(delta * 2, 1)))
    end)))

    local index = 1
    uq.TimerProxy:removeTimer(self._animShowTag)
    uq.TimerProxy:addTimer(self._animShowTag, function()
        if index == 3 then
            uq:addEffectByNode(self._attrDesLabel1, 900012, 1, true, cc.p(290, 12))
            uq:addEffectByNode(self._attrDesLabel2, 900012, 1, true, cc.p(290, 12))
        else
            local panel = self._panelBase:getChildByName("Node_1_" .. index)
            panel:setVisible(true)
        end
        index = index + 1
    end, delta, 4, delta * 8)

    self._txtTip:setOpacity(0)
    self._txtTip:setVisible(true)
    self._txtTip:runAction(cc.Sequence:create(cc.DelayTime:create(16 * delta), cc.FadeIn:create(10 * delta), cc.CallFunc:create(function()
        self._txtTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(10 * delta, 255 * 0.5), cc.FadeTo:create(10 * delta, 255))))
    end)))
end

function MapGuideLevelUp:dispose()
    uq.TimerProxy:removeTimer(self._animShowTag)
    MapGuideLevelUp.super.dispose(self)
end
return MapGuideLevelUp
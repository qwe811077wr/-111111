local ArmsAdvanceSuccess = class("ArmsAdvanceSuccess", require("app.base.PopupBase"))

ArmsAdvanceSuccess.RESOURCE_FILENAME = "generals/ArmsAdvanceSuccess.csb"

ArmsAdvanceSuccess.RESOURCE_BINDING  = {
    ["Image_2"]                                     ={["varname"] = "_imgBg"},
    ["Image_3"]                                     ={["varname"] = "_imgTitleBg"},
    ["Image_4"]                                     ={["varname"] = "_imgTitle"},
    ["Panel_1"]                                     ={["varname"] = "_panelInfo"},
    ["Panel_2"]                                     ={["varname"] = "_panelItem"},
    ["Panel_3"]                                     ={["varname"] = "_panelItems"},
    ["Panel_4"]                                     ={["varname"] = "_panelTips"},
    ["Panel_5"]                                     ={["varname"] = "_panelHead"},
    ["ScrollView"]                                  ={["varname"] = "_scrollView"},
    ["Text_1_0"]                                    ={["varname"] = "_unLockTip"},
    ["Image_1_2"]                                   ={["varname"] = "_imgType2"},
    ["Image_1_1"]                                   ={["varname"] = "_imgType1"},
    ["Image_7"]                                     ={["varname"] = "_imgCenter"},
    ["Image_23"]                                    ={["varname"] = "_imgTitle1"},
    ["Panel_2_1"]                                   ={["varname"] = "_panelCard1"},
    ["Panel_2_2"]                                   ={["varname"] = "_panelCard2"},
    ["Image_23_0"]                                  ={["varname"] = "_imgTitle2"},
}
function ArmsAdvanceSuccess:ctor(name, args)
    args._isStopAction = true
    ArmsAdvanceSuccess.super.ctor(self,name,args)
    self._curInfo = args.info or nil
end

function ArmsAdvanceSuccess:init()
    self:parseView()
    self:centerView()
    if self._curInfo == nil then
        return
    end
    self:initUi()
end

function ArmsAdvanceSuccess:initUi()
    self:updateBaseInfo()
end

function ArmsAdvanceSuccess:updateBaseInfo()
    local soldier_xml1 = StaticData['soldier'][self._curInfo.new_soldier_id1]
    local soldier_xml2 = StaticData['soldier'][self._curInfo.new_soldier_id2]
    if not soldier_xml1 or not soldier_xml2 then
        return
    end

    local infos = {{id = soldier_xml1.ident, soldier_type = soldier_xml1.type}, {id = soldier_xml2.ident, soldier_type = soldier_xml2.type}}
    table.sort(infos, function(a, b)
        return a.soldier_type < b.soldier_type
    end)

    self._arrItem = {}
    for i = 1, 2 do
        local level_info = StaticData['types'].Soldierlevel[1].Type[soldier_xml1.level + i - 2]  -- -2
        if not level_info then
            return
        end
        local img = self._panelInfo:getChildByName("Image_1_" .. i)
        local txt = img:getChildByName("Text")
        img:loadTexture("img/generals/" .. level_info.tagImg)
        txt:setString(level_info.name)
        if i == 2 then
            self._unLockTip:setString(string.format(StaticData['local_text']['unlock.new.army.type'], level_info.name))
        end

        local panel = self._panelItem:getChildByName("Panel_2_" .. i)
        local item = uq.createPanelOnly("generals/ArmyItem")
        item:setData(infos[i], true)
        item:setImgSoldierTypeVisible(true)
        item:setVisible(false)
        table.insert(self._arrItem, item)
        panel:addChild(item)
    end


    self._curLevelArmsInfo = {}
    for k, v in pairs(StaticData['soldier']) do
        if v.isHidden == 0 and v.level == soldier_xml1.level and (v.type == soldier_xml1.type or v.type == soldier_xml2.type) then
            table.insert(self._curLevelArmsInfo, {id = v.ident, soldier_type = v.type})
        end
    end
    table.sort(self._curLevelArmsInfo, function(a, b)
        return a.soldier_type < b.soldier_type
    end)

    self._scrollView:removeAllChildren()
    self._arrItemList = {}
    local item_size = self._scrollView:getContentSize()
    local index = #self._curLevelArmsInfo
    local inner_width = index * 136
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:setTouchEnabled(inner_width >= item_size.width)
    local max_num = math.floor(item_size.width / 136)
    local item_posX = index < max_num and (max_num - index) * 68 + 5 or 0
    for k, t in ipairs(self._curLevelArmsInfo) do
        local item = uq.createPanelOnly("generals/ArmyItem")
        item:setData(t, true)
        item:setPosition(cc.p(item_posX, 0))
        item:setImgSoldierTypeVisible(true)
        self._scrollView:addChild(item)
        item_posX = item_posX + 136
        item:setVisible(k > 9)
        table.insert(self._arrItemList, item)
    end
    self:runOpenAction()
end

function ArmsAdvanceSuccess:runOpenAction()
    local delta = 1 / 12
    self:setLayerColor(0.3)
    local layer = self:getChildByName("layer_color")
    layer:runAction(cc.FadeTo:create(delta * 2, 0.8 * 255))

    self._imgTitle:setScale(0.3)
    self._imgTitleBg:setVisible(true)
    self._imgTitle:runAction(cc.ScaleTo:create(delta, 1))
    uq:addEffectByNode(self._imgTitle, 900138, 1, true, cc.p(216, 116))

    self._imgBg:setOpacity(25.5)
    local pos_y = self._imgBg:getPositionY()
    self._imgBg:setPositionY(pos_y - 100)
    self._imgBg:setVisible(true)
    self._imgBg:runAction(cc.Spawn:create(cc.FadeIn:create(delta * 3), cc.MoveBy:create(delta * 3, cc.p(0, 100))))

    local index = 1
    local array_panel = {self._imgType1, self._imgCenter, self._imgType2}
    self._animTag = "fade_info" .. tostring(self)
    uq.TimerProxy:removeTimer(self._animTag)
    uq.TimerProxy:addTimer(self._animTag, function()
        local panel = array_panel[index]
        panel:setVisible(true)
        if index == 1 then
            uq:addEffectByNode(panel, 900012, 1, true, cc.p(149, 16))
        end
        index = index + 1
    end, delta, 3, delta * 7)

    local card_index = 1
    local array_card = {self._imgTitle1, nil, self._arrItem[1], self._arrItem[2]}
    local effect_card = {self._imgTitle1, self._panelCard1, self._panelCard2}
    local array_effect = {900024, 900025, 900025}
    local array_pos = {cc.p(124, 18), cc.p(61, 100), cc.p(61, 100)}
    self._animCardTag = "fade_card_info" .. tostring(self)
    uq.TimerProxy:removeTimer(self._animCardTag)
    uq.TimerProxy:addTimer(self._animCardTag, function()
        local panel = array_card[card_index]
        if panel then
            panel:setVisible(true)
        end
        local effect = array_effect[card_index]
        local effect_node = effect_card[card_index]
        if effect_node then
            uq:addEffectByNode(effect_node, effect, 1, true, array_pos[card_index])
        end
        card_index = card_index + 1
    end, delta, 4, delta * 12)

    self._imgTitle2:runAction(cc.Sequence:create(cc.DelayTime:create(13 * delta), cc.CallFunc:create(function()
        self._imgTitle2:setVisible(true)
        uq:addEffectByNode(self._imgTitle2, 900024, 1, true, cc.p(124, 18))
    end)))

    self._scrollView:runAction(cc.Sequence:create(cc.DelayTime:create(18 * delta), cc.CallFunc:create(function()
        for k, v in ipairs(self._arrItemList) do
            if k > 9 then
                break
            end
            local pos_x, pos_y = v:getPosition()
            local size = v:getContentSize()
            local effect = uq.createPanelOnly('common.EffectNode')
            self._scrollView:addChild(effect)
            effect:setPosition(cc.p(pos_x + 61, pos_y + 100))
            effect:playEffectNormal(900025, false, nil, true, 1)
            v:runAction(cc.Sequence:create(cc.DelayTime:create(delta), cc.CallFunc:create(function()
                v:setVisible(true)
            end)))
        end
    end)))

    self._panelTips:setOpacity(0)
    self._panelTips:setVisible(true)
    self._panelTips:runAction(cc.Sequence:create(cc.DelayTime:create(26 * delta), cc.FadeIn:create(10 * delta), cc.CallFunc:create(function()
        self._panelTips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(10 * delta, 255 * 0.5), cc.FadeTo:create(10 * delta, 255))))
    end)))
end

function ArmsAdvanceSuccess:dispose()
    uq.TimerProxy:removeTimer(self._animTag)
    uq.TimerProxy:removeTimer(self._animCardTag)
    ArmsAdvanceSuccess.super.dispose(self)
end

return ArmsAdvanceSuccess
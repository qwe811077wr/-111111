local EquipItem = class("EquipItem",function()
    return ccui.Layout:create()
end)
--[[
    显示装备背景跟图标,需要传入id，type 0表示item表内资源，1表示type表内金币包子等消耗类资源,2表示装备内残影
]]
function EquipItem:ctor(args)
    self._view = nil
    self._equipInfo = args and args.info or {id = 1,type = -2,num = 0, max_num = 0, rate = 1000}
    self:enableNodeEvents()
    self:init()
    self:setCascadeOpacityEnabled(true)
    self._view:setCascadeOpacityEnabled(true)
end

function EquipItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("common/EquipItem.csb")
        self._view = node:getChildByName("resource_layer")
    end
    self._view:removeSelf()
    self._inTouch = false
    self._listener = nil
    self._pressHandler = nil
    self._endHandler = nil
    self._isCanSelect = false
    self._pressTime = 0
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(self._view:getContentSize().width * 0.5,self._view:getContentSize().height * 0.5))
    self._bgImg = self._view:getChildByName("Image_bg");
    self._graybgImg = self._view:getChildByName("Image_graybg");
    self._iconSpr = self._view:getChildByName("icon_spr");
    self._changeImg = self._view:getChildByName("Image_change");
    self._levelLabel = self._view:getChildByName("lbl_level");
    self._addImg = self._view:getChildByName("Image_add");
    self._blackBg = self._view:getChildByName("black_img");
    self._nameLabel = self._view:getChildByName("lbl_name");
    self._selectImg = self._view:getChildByName("img_select");
    self._timeLabel = self._view:getChildByName("txt_time");
    self._timeImg = self._view:getChildByName("img_time");
    self._nameImg = self._view:getChildByName("img_name");
    self._txtName = self._view:getChildByName("txt_name");
    self._nodeIcon = self._view:getChildByName("node_icon");
    self._nodeGeneral = self._view:getChildByName("general_node");
    self._panelSpirit = self._view:getChildByName("panel_general");
    self._imgSpirit = self._panelSpirit:getChildByName("Image_6");
    self._imgCheckBg = self._view:getChildByName("Image_1");
    self._imgCheck = self._imgCheckBg:getChildByName("Image_2");
    self._imgMax = self._view:getChildByName("Image_3");
    self._imgGray = self._view:getChildByName("Image_8");
    self._imgRate = self._view:getChildByName("img_rate");
    self._imgStrength = self._view:getChildByName("Image_strength");
    self._txtCanEquip = self._view:getChildByName("txt_up");
    self._txtEquipName = self._view:getChildByName("Text_11");
    self._nodeSel = self._view:getChildByName("sel_node")
    self._nodeLock = self._view:getChildByName("lock_node")
    self._txtLock = self._nodeLock:getChildByName("Text_1")
    self._imgLocked = self._view:getChildByName("Image_9")
    self._curNameLabelPos = cc.p(self._nameLabel:getPosition())
    self._nodeStar = self._view:getChildByName("node_star")

    self:_initDialog()
end

function EquipItem:setInfo(info)
    self._equipInfo = info
    self._pressHandler = nil
    self._endHandler = nil
    local event_dispatcher = self:getEventDispatcher()
    if self._listener then
        event_dispatcher:removeEventListener(self._listener)
    end
    self._listener = nil
    self:_initDialog()
end

function EquipItem:_initDialog()
    self._imgMax:setVisible(false)
    self._imgGray:setVisible(false)
    self._panelSpirit:setVisible(false)
    self._changeImg:setVisible(false)
    self._levelLabel:setVisible(false)
    self._addImg:setVisible(false)
    self._blackBg:setVisible(false)
    self._nameLabel:setVisible(false)
    self._selectImg:setVisible(false)
    self._bgImg:setVisible(false)
    self._graybgImg:setVisible(false)
    self._iconSpr:setVisible(false)
    self._timeLabel:setVisible(false)
    self._timeImg:setVisible(false)
    self._nameImg:setVisible(false)
    self._txtName:setVisible(false)
    self._imgRate:setVisible(false)
    self._txtCanEquip:setVisible(false)
    self._imgStrength:setVisible(false)
    self._nodeSel:setVisible(false)
    self._nodeLock:setVisible(false)
    self._iconSpr:setScale(1)
    self._txtLock:setString(StaticData["local_text"]["decompose.not"])
    self._imgLocked:setVisible(false)
    self._nodeGeneral:removeAllChildren()
    self._nodeStar:setVisible(false)
    if self._equipInfo.type == uq.config.constant.EQUIPITEM_TYPE.NULL then --只显示九宫格背景
        self._graybgImg:setVisible(true)
        if self._equipInfo.id == -1 then
            self._iconSpr:setVisible(true)
            self._iconSpr:setTexture("img/ware_house/g03_00010 4.png")
        end
        self._nodeIcon:removeAllChildren()
    elseif self._equipInfo.type == uq.config.constant.EQUIPITEM_TYPE.TYPES_ITEM then --只需要显示缩影
        self._nodeIcon:removeAllChildren()
        self._txtCanEquip:setVisible(not self._addImg:isVisible())
        self._txtCanEquip:setString(StaticData['local_text']['general.equip.can.get'])
        local info = StaticData['types'].Item[1].Type[self._equipInfo.id]
        self._iconSpr:setVisible(true)
        self._bgImg:setTexture("img/generals/s03_00086.png")
        self._iconSpr:setTexture("img/generals/" .. info.iconId)
        self._bgImg:setVisible(true)
    else
        local info = StaticData['types'].Cost[1].Type[self._equipInfo.type]
        if not info then
            uq.log("error not find equip COST id: ",self._equipInfo.type)
            return
        end
        self._nameLabel:setPosition(self._curNameLabelPos)
        if self._equipInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
            self:updateEquipDialog()
        elseif self._equipInfo.type == uq.config.constant.COST_RES_TYPE.GENERALS then
            self:updateGeneralsDialog()
        elseif self._equipInfo.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
            self:updateGeneralSpirite()
        else
            self:updateItemDialog()
        end
    end
end

function EquipItem:setTextCanEquipVisible(visible)
    self._txtCanEquip:setVisible(visible)
end

function EquipItem:updateGeneralSpirite()
    local generals_xml = StaticData['general'][tonumber(self._equipInfo.id .. '1')]
    local grade_info = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
    self._equipInfo.quality_type = grade_info.qualityType
    local bg_img = StaticData['types']['ItemQuality'][1]['Type'][self._equipInfo.quality_type].qualityIcon
    self._bgImg:setTexture("img/common/ui/" .. bg_img)
    self._imgSpirit:loadTexture("img/common/general_spirit/" .. generals_xml.pieceIcon)
    self._bgImg:setVisible(true)
    self._panelSpirit:setVisible(true)
    local num = self._equipInfo.num or uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.SPIRIT, self._equipInfo.id) or 0
    local max_num = self._equipInfo.max_num or 0
    local rate = self._equipInfo.rate or 1000
    self:checkRateState(rate, num, max_num)
end

function EquipItem:updateItemDialog()
    self._bgImg:setVisible(true)
    self._iconSpr:setVisible(true)
    local info = StaticData.getCostInfo(self._equipInfo.type,self._equipInfo.id)
    if info == nil then
        return
    end
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
    if item_quality_info then
        self._bgImg:setTexture("img/common/ui/" .. item_quality_info.qualityIcon)
    end
    self._iconSpr:setTexture("img/common/item/" .. info.icon)
    local num = self._equipInfo.num or 0
    local max_num = self._equipInfo.max_num or 0
    local rate = self._equipInfo.rate or 1000
    self:checkRateState(rate, num, max_num)
end

function EquipItem:checkRateState(rate, num, max_num)
    if (rate and rate < 1000) or max_num > num then
        self._nameLabel:setVisible(false)
        self._imgRate:setVisible(true)
    else
        self._imgRate:setVisible(false)
        self._nameLabel:setVisible(num > 0)
        self._nameLabel:setString(uq.formatResource(num))
    end
end

function EquipItem:setImageMaxVisible(visible)
    self._imgMax:setVisible(visible)
end

function EquipItem:setImageGrayVisible(visible)
    self._imgGray:setVisible(visible)
end

function EquipItem:setEquipNameVisible(visible)
    self._txtEquipName:setVisible(visible)
end

function EquipItem:updateGeneralsDialog()
    self._iconSpr:setVisible(true)
    self._bgImg:setVisible(true)
    self._nodeIcon:removeAllChildren()
    local info = StaticData.getCostInfo(self._equipInfo.type,self._equipInfo.id)
    if info == nil then
        return
    end
    local grade_info = StaticData['types'].GeneralGrade[1].Type[info.grade]
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(grade_info.qualityType)]
    if item_quality_info then
        self._bgImg:setTexture("img/common/ui/" .. item_quality_info.qualityIcon)
    end
    if info.miniIcon then
        self._iconSpr:setTexture("img/common/general_head/" .. info.miniIcon)
    end
    local num = self._equipInfo.num or 0
    local max_num = self._equipInfo.max_num or 0
    local rate = self._equipInfo.rate or 1000
    self:checkRateState(rate, num, max_num)
end

function EquipItem:addClippingToNode(parent, target_png)
    local stencil= cc.Sprite:create("img/common/ui/g03_000080-01.png")
    local clipping = cc.ClippingNode:create()
    clipping:setStencil(stencil)
    clipping:setInverted(false)
    clipping:setAlphaThreshold(0)
    local target = cc.Sprite:create(target_png)
    target:setScale(0.8)
    target:setPosition(cc.p(0, 17))
    clipping:addChild(target)
    clipping:setPosition(0.5, -5.2)
    parent:addChild(clipping)
end

function EquipItem:updateEquipDialog()
    self._bgImg:setVisible(true)
    self._iconSpr:setVisible(true)
    if self._equipInfo.expire_time and self._equipInfo.expire_time > 0 then
        self._timeImg:setVisible(true)
    end
    self._imgLocked:setVisible(self._equipInfo.bind_type == 1)
    local info = StaticData['items'][self._equipInfo.id]
    if not info then
        uq.log("error not find equip id: ",self._equipInfo.id)
        return
    end
    self._iconSpr:setTexture("img/common/item/" .. info.icon)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
    if item_quality_info then
        self._bgImg:setTexture("img/common/ui/" .. item_quality_info.qualityIcon)
    end
    self._txtEquipName:setString(info.name)
    self._txtEquipName:setTextColor(uq.parseColor(item_quality_info.color))
    if self._equipInfo.general_id and self._equipInfo.general_id > 0 then
        local info = uq.cache.generals:getGeneralDataByID(self._equipInfo.general_id)
        if not info then
            return
        end
        self:showName(true, info.name)
        self:showNameCenter()
    else
        self:checkRateState(1000, 0, 0)
    end
    if self._equipInfo.lvl and self._equipInfo.lvl > 0 then
        self:showLevel(true,self._equipInfo.lvl)
    end

    self._equipInfo.star = self._equipInfo.star or 0
    self:updateStar(self._equipInfo.star)

    local num = self._equipInfo.num or 0
    local max_num = self._equipInfo.max_num or 0
    local rate = self._equipInfo.rate or 1000
    local pre_score = StaticData['item_score'].EffectTypeScore[info.effectType].score
    if not pre_score then
        return
    end
    local total_score = math.ceil(info.effectValue * pre_score)
    local limit = StaticData['item_score'].ScoreLimit[info.effectType].limit
    if limit and limit <= total_score then
        self:setImageMaxVisible(true)
    end
end

function EquipItem:refreshLockedImgState()
    self._imgLocked:setVisible(self._equipInfo.bind_type == 1)
end

function EquipItem:setLockedImgState(visible)
    self._imgLocked:setVisible(visible)
end

function EquipItem:setAddImgVisible(visible)
    self._addImg:setVisible(visible)
    self._txtCanEquip:setVisible(not visible)
end

function EquipItem:setStrengthImgVisible(visible)
    self._imgStrength:setVisible(visible)
end

function EquipItem:showStrengthImg(show_change)
    local change_state = false
    if show_change then
        if self._equipInfo.general_id and self._equipInfo.general_id ~= 0 then
            local general_info = uq.cache.generals:getGeneralDataByID(self._equipInfo.general_id)
            if general_info then
                local arr_suit = uq.cache.equipment:getGeneralsSuitId(self._equipInfo.general_id)
                if self._equipInfo.xml.suitId then
                    arr_suit[self._equipInfo.xml.suitId] = arr_suit[self._equipInfo.xml.suitId] - 1
                end
                local max_info = uq.cache.equipment:getChangeEquipInfo(self._equipInfo.xml.type, general_info.lvl, arr_suit)
                change_state = max_info ~= nil and max_info.xml.effectValue > self._equipInfo.xml.effectValue
            else
                change_state = false
            end
        else
            change_state = false
        end
    end
    if not self._equipInfo.db_id then
        self._imgStrength:setVisible(false)
        return
    end
    local lvl_state = self._equipInfo.lvl < uq.cache.role.master_lvl
    local xml_cost = StaticData['item_level'][self._equipInfo.lvl].cost
    local cost_array = uq.RewardType.parseRewards(xml_cost)
    local cost_state = true
    for k, v in ipairs(cost_array) do
        local info = v:toEquipWidget()
        if info.num > 0 and not uq.cache.role:checkRes(info.type, info.num, info.id) then
            cost_state = false
            break
        end
    end

    local rising_state = uq.cache.equipment:judgeCouldRisingByEquipDBId(self._equipInfo.db_id)
    self._imgStrength:setVisible((lvl_state and cost_state) or rising_state or change_state)
end

function EquipItem:setChangeImgVisible(visible)
    self._changeImg:setVisible(visible)
end

function EquipItem:getChangeImgVisible()
    return self._changeImg:isVisible()
end

function EquipItem:setSelectImgVisible(visible)
    self._selectImg:setVisible(visible)
end

function EquipItem:showLevel(visible,lvl)
    self._levelLabel:setVisible(visible)
    local str = lvl and lvl or ""
    self._levelLabel:setString("+"..str)
end

function EquipItem:showNum(visible,num)
    self._levelLabel:setVisible(visible)
    local str = num and num or ""
    self._levelLabel:setString(str)
end

function EquipItem:setNumColor(color)
    self._levelLabel:setTextColor(color)
end

function EquipItem:setNameColor(color)
    self._nameLabel:setTextColor(color)
end

function EquipItem:setNameVisible(visible)
    self._nameLabel:setVisible(visible)
end

function EquipItem:showName(visible, name, is_center)
    self._nameLabel:setVisible(visible)
    self._blackBg:setVisible(visible)
    local str = name and name or ""
    self._nameLabel:setString(str.."")

    if not is_center then
        return
    end
    self._nameLabel:setPositionX(self._blackBg:getContentSize().width * 0.5 + self._nameLabel:getContentSize().width * 0.5)
end

function EquipItem:setNameString(num)
    self._nameLabel:setString(num)
end

function EquipItem:setCheckState(state)
    if state == nil then
        state = not self:getCheckState()
    end
    self._imgCheck:setVisible(state)
end

function EquipItem:setCheckUIState(state)
    self._imgCheckBg:setVisible(state)
    self._nameLabel:setVisible(not state)
end

function EquipItem:getCheckState()
    return self._imgCheck:isVisible()
end

function EquipItem:showNameCenter()
    local size = self._view:getContentSize()
    local black_size = self._blackBg:getContentSize()
    self._blackBg:setPositionY(size.height / 2 - black_size.height / 2)
    local pos_y = size.height / 2
    local pos_x = self._blackBg:getContentSize().width * 0.5 + self._nameLabel:getContentSize().width * 0.5
    self._nameLabel:setPosition(cc.p(pos_x, pos_y))
end

function EquipItem:getEquipInfo()
    return self._equipInfo
end

function EquipItem:getBaseLayer()
    return self._view
end

function EquipItem:getBgContentSize()
    return self._bgImg:getContentSize()
end

function EquipItem:setImgNameVisible(txt_visible, img_visible)
    self._nameImg:setVisible(img_visible)
    self._txtName:setVisible(txt_visible)
    if not txt_visible then
        return
    end
    local xml_info = StaticData.getCostInfo(self._equipInfo.type, self._equipInfo.id)
    self._txtName:setString(xml_info.name)
    local quality_info = StaticData['types'].ItemQuality[1].Type[xml_info.qualityType]
    if quality_info then
        self._txtName:setTextColor(uq.parseColor(quality_info.color))
    end
end

function EquipItem:enableEvent(press_handler, end_handler)
    self._pressHandler = press_handler
    self._endHandler = end_handler
    local event_dispatcher = self:getEventDispatcher()
    if self._listener then
        event_dispatcher:removeEventListener(self._listener)
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    self._listener = listener
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self._onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function EquipItem:_onTouchBegin(evt)
    self._touchPoint = evt:getLocation()
    local size = self:getContentSize()
    local pos = self:convertToNodeSpace(self._touchPoint)
    local rect=cc.rect(0, 0, size.width, size.height)
    if not cc.rectContainsPoint(rect, pos) then
        self._inTouch = false
        return false
    end
    self._pressTime = 0
    self._pressState = false
    uq.TimerProxy:addTimer("equip_item_time",function()
        self._pressTime = self._pressTime + 0.1
        if self._pressTime > 0.5 then
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            uq.TimerProxy:removeTimer("equip_item_time")
            self._inTouch = false
            if self._pressHandler then
                self._pressHandler(self._equipInfo)
            else --可以调用tips接口
                uq.showItemTips(self._equipInfo)
            end
        end
    end,0.1,-1)
    self._inTouch = true
    return true
end

function EquipItem:_onTouchMove(evt)
    if not self._inTouch then
        return
    end
    local pos = evt:getLocation()
    if math.abs(pos.x - self._touchPoint.x) > 10 or math.abs(pos.y - self._touchPoint.y) > 10 then
        self._inTouch = false
        uq.TimerProxy:removeTimer("equip_item_time")
    end
end

function EquipItem:_onTouchEnd(evt)
    if not self._inTouch then
        return
    end
    uq.TimerProxy:removeTimer("equip_item_time")
    if self._endHandler then
        self._endHandler(self._equipInfo)
    end
end

function EquipItem:updateStar(star)
    if not self._equipInfo.db_id then
        return
    end
    star = star or self._equipInfo.star
    self._nodeStar:setVisible(star > 0)
    if star == 0 then
        return
    end
    for i = 1, 5 do
        local checkbox = self._nodeStar:getChildByName("CheckBox_" .. i)
        checkbox:setSelected(star >= i)
    end
end

function EquipItem:_onTouchCancelled(evt)
    self._inTouch = false
    uq.TimerProxy:removeTimer("equip_item_time")
end

function EquipItem:showGray(is_gray)
    if is_gray then
        uq.ShaderEffect:addGrayNode(self._bgImg)
        uq.ShaderEffect:addGrayNode(self._iconSpr)
    else
        uq.ShaderEffect:removeGrayNode(self._bgImg)
        uq.ShaderEffect:removeGrayNode(self._iconSpr)
    end
end

function EquipItem:onExit()
    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end
    self._pressHandler = nil
    uq.TimerProxy:removeTimer("equip_item_time")
    local event_dispatcher = self:getEventDispatcher()
    if self._listener then
        event_dispatcher:removeEventListener(self._listener)
    end
    self._listener = nil
end

function EquipItem:setNameFontSize(size)
    self._nameLabel:setFontSize(size)
end

function EquipItem:setSwallow(flag)
    self._listener:setSwallowTouches(flag)
end

function EquipItem:showAction()
    uq.intoAction(self._view)
end

function EquipItem:setNodeLockedVisible(visible)
    self._nodeLock:setVisible(visible)
end

function EquipItem:setUnlockSelect(is_bool, hide_name)
    self._isCanSelect = is_bool
    self._nodeLock:setVisible(not is_bool)
end

function EquipItem:setSelectItems(is_bool)
    self._nodeSel:setVisible(is_bool)
end

return EquipItem
local AncientCityCheckPoint = class("AncientCityCheckPoint", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

AncientCityCheckPoint.RESOURCE_FILENAME = "ancient_city/AncientCityCheckPoint.csb"
AncientCityCheckPoint.RESOURCE_BINDING = {
    ["panel_1/Panel_point/label_title"]         = {["varname"] = "_titleLabel"},
    ["panel_1/Panel_point"]                     = {["varname"] = "_panelPoint"},
    ["panel_1/Panel_point/Panel_information"]   = {["varname"] = "_panelInformation"},
    ["panel_1/Panel_point/btn_detour"]          = {["varname"] = "_btnDetour",["events"] = {{["event"] = "touch",["method"] = "_onBtnDetour"}}},
    ["panel_1/Panel_point/btn_escape"]          = {["varname"] = "_btnEscape",["events"] = {{["event"] = "touch",["method"] = "_onBtnEscape",["sound_id"] = 0}}},
    ["panel_1/Panel_point/btn_attack"]          = {["varname"] = "_btnAttack",["events"] = {{["event"] = "touch",["method"] = "_onBtnAttack"}}},
    ["panel_1/Panel_point/label_cost"]          = {["varname"] = "_costDetourLabel"},
    ["panel_1/Panel_point/btn_strategy"]        = {["varname"] = "_btnStrategy",["events"] = {{["event"] = "touch",["method"] = "_onBtnStrategy"}}},
    ["panel_1/Panel_point/ScrollView_1"]        = {["varname"] = "_scrollView"},
    ["panel_1/Panel_point/Button_4"]            = {["varname"] = "_generalImg",["events"] = {{["event"] = "touch",["method"] = "_onImgGeneral"}}},
    ["panel_1/Panel_fail"]                      = {["varname"] = "_panelFail"},
    ["panel_1/Panel_fail/btn_exit"]             = {["varname"] = "_btnExit",["events"] = {{["event"] = "touch",["method"] = "_onBtnExit"}}},
    ["panel_1/Panel_fail/close_btn_0"]          = {["varname"] = "_btnExit1",["events"] = {{["event"] = "touch",["method"] = "_onBtnExit"}}},
    ["panel_1/Panel_fail/btn_getreward"]        = {["varname"] = "_btnGetReward",["events"] = {{["event"] = "touch",["method"] = "_onBtnGeetReward"}}},
    ["panel_1/Panel_fail/Panel_faildes1"]       = {["varname"] = "_panelFailDes1"},
    ["panel_1/Panel_fail/Panel_faildes2"]       = {["varname"] = "_panelFailDes2"},
    ["panel_1/Panel_fail/Image_1"]              = {["varname"] = "_costImg"},
    ["panel_1/Panel_fail/label_cost"]           = {["varname"] = "_costLabel"},
    ["panel_1"]                                 = {["varname"] = "_pressPanel"},
    ["dec_txt"]                                 = {["varname"] = "_txtDec"},
    ["Node_1"]                                  = {["varname"] = "_nodeBg"},
    ["Image_12"]                                = {["varname"] = "_imgCostBg"},
    ["close_btn"]                               = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnClose"}}},
}

function AncientCityCheckPoint:ctor(name, args)
    AncientCityCheckPoint.super.ctor(self, name, args)
    self._curInfo = args.npc_info
    self._isFail = args.fail or false
    self._detourCost = 0
end

function AncientCityCheckPoint:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._xml = StaticData['ancients_detour'] or {}
    self._xmlInfo = StaticData['ancient_info'][1] or {}
    self._failCost = uq.RewardType.new(self._xmlInfo.findCost):num() or 0
    self:initUi()
    self:updateDialog()
end

function AncientCityCheckPoint:initUi()
    self._btnDetour:setPressedActionEnabled(true)
    self._btnEscape:setPressedActionEnabled(true)
    self._btnAttack:setPressedActionEnabled(true)
    self._btnStrategy:setPressedActionEnabled(true)
    self._btnGetReward:setPressedActionEnabled(true)
    self._btnExit:setPressedActionEnabled(true)
    self.richText1 = uq.RichText:create()
    self.richText1:setAnchorPoint(cc.p(0.5, 0.5))
    self.richText1:setDefaultFont("res/font/hwkt.ttf")
    self.richText1:setFontSize(22)
    local size = self._panelFailDes1:getContentSize()
    self.richText1:setContentSize(cc.size(size.width, size.height))
    self.richText1:setMultiLineMode(true)
    self.richText1:setTextColor(cc.c3b(255,255,255))
    self.richText1:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    self._panelFailDes1:addChild(self.richText1)

    self.richText2 = uq.RichText:create()
    self.richText2:setAnchorPoint(cc.p(0.5, 0.5))
    self.richText2:setDefaultFont("res/font/hwkt.ttf")
    self.richText2:setFontSize(22)
    local size = self._panelFailDes2:getContentSize()
    self.richText2:setContentSize(cc.size(size.width, size.height))
    self.richText2:setMultiLineMode(true)
    self.richText2:setTextColor(cc.c3b(255,255,255))
    self.richText2:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    self._panelFailDes2:addChild(self.richText2)
    self._pressPanel:setTouchEnabled(true)
    self._pressPanel:addClickEventListener(function()
        uq.fadeInfo(StaticData["local_text"]["ancient.check.point.close"])
    end)
    self._txtDec:setHTMLText(StaticData["local_text"]["ancient.decs1"])
end

function AncientCityCheckPoint:updateDialog()
    if self._isFail then
        self._panelFail:setVisible(true)
        self._panelPoint:setVisible(false)
        self._nodeBg:setVisible(false)
        self.richText1:setText(string.format(StaticData["local_text"]["ancient.check.point.des2"],"<img img/common/ui/03_0004.png>"))
        self.richText2:setText(string.format(StaticData["local_text"]["ancient.check.point.des4"],"<img img/common/ui/03_0004.png>"))
        self._titleLabel:setString(StaticData["local_text"]["ancient.check.point.des5"])
        self._costLabel:setString(tostring(self._failCost))
        if uq.cache.ancient_city.city_id <= 1 then --第一关
            self._btnExit:setPositionX(0)
            self._btnGetReward:setVisible(false)
            self._costImg:setVisible(false)
            self._imgCostBg:setVisible(false)
            self._costLabel:setVisible(false)
        end
        return
    end
    self._panelFail:setVisible(false)
    self._panelPoint:setVisible(true)
    self._nodeBg:setVisible(true)
    self:updateItem()
    self._detourCost = 0
    local color = "#251100"
    local tab_xml = self._xml[uq.cache.ancient_city.detour_times + 1] or {}
    if tab_xml and tab_xml.cost and tab_xml.cost ~= "" then
        local base_cost = uq.RewardType.new(tab_xml.cost)
        self._detourCost = base_cost:num()
        if not uq.cache.role:checkRes(base_cost:type(), base_cost:num()) then
            color = "#AF381A"
        end
    end
    self._costDetourLabel:setTextColor(uq.parseColor(color))
    self._costDetourLabel:setString(tostring(self._detourCost))
    self._titleLabel:setString(self._curInfo.name)
    local talk_array = StaticData['types'].AncientNpctalkType[1].Type
    local index = math.random(1, #talk_array)
    self._panelInformation:removeAllChildren()
    local posx = 0
    for k, v in ipairs(self._curInfo.Army) do
        local stsolider = StaticData['soldier'][tonumber(v.soldierId)] --上阵的兵种
        if stsolider then
            local sttype_solider = StaticData['types'].Soldier[1].Type[stsolider.type]
            local img_bg = ccui.ImageView:create("img/common/ui/g03_0000334.png")
            local img = ccui.ImageView:create("img/common/ui/".. sttype_solider.miniIcon1)
            self._panelInformation:addChild(img_bg)
            img_bg:addChild(img)
            img:setPosition(cc.p(img_bg:getContentSize().width * 0.5, img_bg:getContentSize().height * 0.5 + 4))
            img_bg:setPosition(cc.p(posx,10))
            posx = posx + 45
        end
    end
end

function AncientCityCheckPoint:updateItem()
    if not self._curInfo then
        return
    end
    local reward_array = uq.RewardType:parseRewardsAndFilterDrop(self._curInfo.Reward)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #reward_array
    local inner_width = index * 100
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    self._scrollView:setScrollBarEnabled(false)
    local item_posX = 60
    for _,t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX,item_size.height * 0.5))
        euqip_item:setScale(0.8)
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView:addChild(euqip_item)
        item_posX = item_posX + 100
    end
end

function AncientCityCheckPoint:_onBtnExit(event)
    if event.name ~= "ended" then
        return
    end
    local function confirm()
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_QUIT_SCENE, {})
        uq.runCmd('enter_ancient_city')
        self:disposeSelf()
    end
    local des = string.format(StaticData['local_text']['ancient.city.battle.back.des2'], "<img img/common/ui/03_0004.png>")
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function AncientCityCheckPoint:_onBtnEscape(event)
    if event.name ~= "ended" then
        return
    end
    local function confirm()
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ESCAPE, {})
        uq.runCmd('enter_ancient_city')
        if uq.cache.ancient_city.city_id > 1 then
            uq.fadeInfo(StaticData["local_text"]["ancient.city.box.reward.des"])
        else
            uq.fadeInfo(StaticData["local_text"]["ancient.succeed.escape"])
        end
        self:disposeSelf()
    end
    if uq.cache.ancient_city.city_id == 1 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        confirm()
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_TIPS, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, func = confirm, ["type"] = 2})
end

function AncientCityCheckPoint:_onBtnDetour(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._detourCost) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_DETOUR, {})
    self:disposeSelf()
end

--攻击
function AncientCityCheckPoint:_doAtkNPC(evt)
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ATTACK, {})
    self:disposeSelf()
end

function AncientCityCheckPoint:_onBtnAttack(event)
    if event.name ~= "ended" then
        return
    end
    local enemy_data = self._curInfo.Army
    local data = {
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE,
        confirm_callback = handler(self, self._doAtkNPC),
        bg_name = "img/bg/battle/" .. self._curInfo.battleBg
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function AncientCityCheckPoint:_onBtnStrategy(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_STRATEGY, {})
end

function AncientCityCheckPoint:_onImgGeneral(event)
    if event.name ~= "ended" then
        return
    end
    local index = 1
    local top_data = uq.cache.generals:getUpGeneralsByType(0)
    local generals_id = top_data[1].id
    uq.runCmd('open_general_attribute', {{generals_id = generals_id, index = index}})
end

function AncientCityCheckPoint:_onBtnGeetReward(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._failCost) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_FIND_REWARD, {})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_QUIT_SCENE, {})
    uq.runCmd('enter_ancient_city')
    self:disposeSelf()
end

function AncientCityCheckPoint:_onBtnClose(event)
    if event.name ~= "ended" then
        return
    end
    uq.fadeInfo(StaticData["local_text"]["ancient.check.point.close"])
end

function AncientCityCheckPoint:dispose()
    AncientCityCheckPoint.super.dispose(self)
end
return AncientCityCheckPoint
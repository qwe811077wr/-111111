local WorldCityDevelopItem = class("WorldCityDevelopItem", require('app.base.ChildViewBase'))

WorldCityDevelopItem.RESOURCE_FILENAME = "world/WorldCityDevelopItem.csb"
WorldCityDevelopItem.RESOURCE_BINDING = {
    ["Image_1"]                 = {["varname"] = "_selectImg"},
    ["bg"]                      = {["varname"] = "_bgImg"},
    ["Image_state"]             = {["varname"] = "_curStateImg"},
    ["Image_6"]                 = {["varname"] = "_percentBgImg"},
    ["Image_percent"]           = {["varname"] = "_percentImg"},
    ["text_exp"]                = {["varname"] = "_expLabel"},
    ["level"]                   = {["varname"] = "_levelLabel"},
    ["level_next"]              = {["varname"] = "_nextLevelLabel"},
    ["name"]                    = {["varname"] = "_nameLabel"},
    ["Image_next"]              = {["varname"] = "_nextImg"},
    ["Panel_2"]                 = {["varname"] = "_panelDes"},
    ["Image_add"]               = {["varname"] = "_addImg"},
    ["exp_add_base"]            = {["varname"] = "_addBaselabel"},
    ["exp_add"]                 = {["varname"] = "_addLabel"},
    ["text_des"]                = {["varname"] = "_desLabel"},
    ["Panel_3"]                 = {["varname"] = "_panelAdd"},
    ["Image_gold"]              = {["varname"] = "_goldImg"},
    ["Image_money"]             = {["varname"] = "_moneyImg"},
    ["gold"]                    = {["varname"] = "_goldLabel"},
    ["money"]                   = {["varname"] = "_moneyLabel"},
    ["gold_des"]                = {["varname"] = "_goldDesLabel"},
    ["money_des"]               = {["varname"] = "_moneyDesLabel"},
}

function WorldCityDevelopItem:onCreate()
    WorldCityDevelopItem.super.onCreate(self)
    self._selectImg:setVisible(false)
    self._panelWidth = self._panelAdd:getContentSize().width
    self._panelAdd:setContentSize(cc.size(self._panelWidth, 0))
    self._percentSize = cc.size(self._percentBgImg:getContentSize().width - 2, self._percentImg:getContentSize().height)
    self._perFrameHeight = 10
    self._tickrScrollTag = "scroll" .. tostring(self)
    self._goldImg:setTouchEnabled(true)
    self._goldImg:setTag(2)
    self._goldImg:addClickEventListener(handler(self, self.onImgPress))
    self._moneyImg:setTouchEnabled(true)
    self._moneyImg:setTag(1)
    self._moneyImg:addClickEventListener(handler(self, self.onImgPress))
end

function WorldCityDevelopItem:onImgPress(sender)
    if not self._data then
        return
    end
    local xml_info = StaticData['world_develop'][self._data.id]
    local next_info = xml_info.Effect[self._data.level + 1]
    if next_info == nil then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["world.develop.des3"])
        return
    end
    if uq.cache.world_war.world_enter_info.develop_count > 0 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["world.city.info.des4"])
        return
    end
    uq.playSoundByID(81)
    local tag = sender:getTag()
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_DEVELOP, {city_id = self._data.city_id, choice = self._data.id, option = tag})
end

function WorldCityDevelopItem:setData(data)
    self._data = data
    if not self._data then
        return
    end
    local xml_info = StaticData['world_develop'][self._data.id]
    self._nameLabel:setString(xml_info.name)
    self._bgImg:setTexture("img/world/" .. xml_info.icon)
    self._desLabel:setString(xml_info.desc)
    local effect_info = xml_info.Effect[self._data.level]
    self._levelLabel:setString(self._data.level)
    self._nextLevelLabel:setString(self._data.level + 1)
    local next_info = xml_info.Effect[self._data.level + 1]
    self._addImg:setVisible(next_info ~= nil)
    if next_info == nil then
        self._nextImg:setVisible(false)
        self._expLabel:setString(self._data.exp)
        self._percentImg:setContentSize(self._percentSize)
        self._curStateImg:setVisible(false)
        self._addLabel:setString("")
        self._addBaselabel:setString("")
    else
        self._curStateImg:setVisible(uq.cache.world_war.world_enter_info.develop_count > 0)
        self._addLabel:setString(next_info.value)
        self._addBaselabel:setString(effect_info.value)
        self._expLabel:setString(self._data.exp .. "/" .. effect_info.exp)
        self._percentImg:setContentSize(cc.size(self._data.exp / effect_info.exp * self._percentSize.width, self._percentSize.height))
        self._goldDesLabel:setHTMLText(StaticData["local_text"]["world.develop.des1"] .. string.format(StaticData["local_text"]["world.develop.des2"], effect_info.each2))
        self._moneyDesLabel:setString(StaticData["local_text"]["world.develop.des1"] .. effect_info.each1)
        local reward1 = uq.RewardType.new(effect_info.cost1)
        self._moneyLabel:setString(reward1:num())
        local reward2 = uq.RewardType.new(effect_info.cost2)
        self._goldLabel:setString(reward2:num())
    end
end

function WorldCityDevelopItem:selectPanel(is_show)
    if is_show then
        local xml_info = StaticData['world_develop'][self._data.id]
        local next_info = xml_info.Effect[self._data.level + 1]
        if next_info == nil then
            uq.fadeInfo(StaticData["local_text"]["world.develop.des3"])
            return
        end
        self._perFrameHeight = 15
    else
        self._perFrameHeight = -15
    end
    self._selectImg:setVisible(is_show)
    self:openScrollTick()
end

function WorldCityDevelopItem:openScrollTick()
    if not uq.TimerProxy:hasTimer(self._tickrScrollTag) then
        uq.TimerProxy:addTimer(self._tickrScrollTag, handler(self, self.updateScrollPos), 0.02, -1)
    end
end

function WorldCityDevelopItem:updateScrollPos()
    local size = self._panelAdd:getContentSize()
    size.height = size.height + self._perFrameHeight
    if size.height >= 132 then
        size.height = 132
    elseif size.height <= 0 then
        size.height = 0
    end
    self._panelAdd:setContentSize(size)
    local des_size = self._panelDes:getContentSize()
    des_size.height = des_size.height - self._perFrameHeight
    if des_size.height >= 132 then
        des_size.height = 132
    elseif des_size.height <= 0 then
        des_size.height = 0
    end
    self._panelDes:setContentSize(des_size)
    if des_size.height == 132 or des_size.height == 0 then
        uq.TimerProxy:removeTimer(self._tickrScrollTag)
    end
end

function WorldCityDevelopItem:dispose()
    uq.TimerProxy:removeTimer(self._tickrScrollTag)
end

return WorldCityDevelopItem
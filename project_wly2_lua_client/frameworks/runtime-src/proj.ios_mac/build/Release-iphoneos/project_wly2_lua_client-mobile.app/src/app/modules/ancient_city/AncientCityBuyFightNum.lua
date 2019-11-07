local AncientCityBugFightNum = class("AncientCityBugFightNum", require("app.base.PopupBase"))

AncientCityBugFightNum.RESOURCE_FILENAME = "ancient_city/AncientCityNumBuy.csb"

AncientCityBugFightNum.RESOURCE_BINDING  = {
    ["num_slider"]              ={["varname"] = "_slider"},
    ["dec_img"]                 ={["varname"] = "_decImg"},
    ["add_img"]                 ={["varname"] = "_addImg"},
    ["label_cost"]              ={["varname"] = "_costLabel"},
    ["label_buynum"]            ={["varname"] = "_buyNumLabel"},
    ["Image_35"]                ={["varname"] = "_bgImg"},
    ["btn_buy"]                 ={["varname"] = "_btnBuy",["events"] = {{["event"] = "touch",["method"] = "_onBtnBuy"}}},
    ["Button_1"]                ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnClose"}}},
}

function AncientCityBugFightNum:ctor(name, args)
    AncientCityBugFightNum.super.ctor(self, name, args)
    self._curNum = 1
    self._totalNum = 1
    self.extra_times = 0
    self._costNum = 0
    self._costType = 0
end

function AncientCityBugFightNum:init()
    self:parseView()
    self:centerView()
    self:initUi()
    self:setLayerColor()
end

function AncientCityBugFightNum:_onBtnBuy(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(self._costType, self._costNum) then
        local function confirm()
            uq.runCmd('show_add_golden')
        end
        local des = string.format(StaticData['local_text']['ancient.city.sweep.gold.des'], "<img img/common/ui/03_0003.png>")
        local data = {
            content = des,
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_BUY_TIMES, {times = self._curNum})
    self:disposeSelf()
end

function AncientCityBugFightNum:initUi()
    self:addExceptNode(self._bgImg)
    self._btnBuy:setPressedActionEnabled(true)
    local info = uq.cache.ancient_city:getPassCityInfo()
    self.extra_times = info.extra_times
    local ancient_info = StaticData['ancient_info'][1]
    self._totalNum = ancient_info.totalTimes - ancient_info.freeTimes - self.extra_times
    local this = self
    self._slider:addEventListener(function(evt, evt_type)
        if evt_type ~= 0 then
            return
        end
        local percent_num = self._totalNum * evt:getPercent() / 100
        local cur_num = math.ceil(percent_num)
        if cur_num > self._totalNum then
            cur_num = self._totalNum
        end
        this:_updateCurNum(cur_num, false)
    end)
    self._addImg:setTouchEnabled(true)
    self._addImg:addClickEventListenerWithSound(function(evt)
        local cur_num = self._curNum
        if cur_num >= self._totalNum then
            return
        end
        cur_num = cur_num + 1
        this:_updateCurNum(cur_num, true)
    end)
    self._decImg:setTouchEnabled(true)
    self._decImg:addClickEventListenerWithSound(function(evt)
        local cur_num = self._curNum
        if cur_num <= 1 then
            return
        end
        cur_num = cur_num - 1
        this:_updateCurNum(cur_num, true)
    end)
    self:_updateCurNum(self._curNum, true)
end

function AncientCityBugFightNum:_updateCurNum(cur_num, update_slider)
    if cur_num == 0 then
        cur_num = 1
    end
    self._curNum = cur_num
    local num_str = string.format("<font color='#13eb3b'>   %d</font>", cur_num)
    self._buyNumLabel:setHTMLText(string.format(StaticData['local_text']['ancient.buy.fight.num.des'], num_str, self._totalNum))
    self._costNum = 0
    self._costType = 0
    local max_value = 0
    local value_array = {}
    local data = StaticData['constant'][12].Data
    for k, v in ipairs(data) do
        local cost_array = string.split(v.cost, ";")
        self._costType = tonumber(cost_array[1])
        value_array[v.ident] = tonumber(cost_array[2])
        if max_value < value_array[v.ident] then
            max_value = value_array[v.ident]
        end
    end
    while cur_num > 0 do
        local ident = self.extra_times + cur_num
        local cost = value_array[ident]
        if cost then
            self._costNum = self._costNum + cost
        else
            self._costNum = self._costNum + max_value
        end
        cur_num = cur_num - 1
    end
    local color = uq.cache.role:checkRes(self._costType, self._costNum) and "#FFFFFF" or "#F10000"
    self._costLabel:setString(tostring(self._costNum))
    self._costLabel:setTextColor(uq.parseColor(color))
    if update_slider then
        local percent = self._curNum * 100 / self._totalNum
        self._slider:setPercent(percent)
    end
end

function AncientCityBugFightNum:_onBtnClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function AncientCityBugFightNum:dispose()
    AncientCityBugFightNum.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return AncientCityBugFightNum
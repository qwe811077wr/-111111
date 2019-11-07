local RetainerMain = class("RetainerMain", require('app.modules.common.BaseViewWithHead'))

RetainerMain.RESOURCE_FILENAME = "retainer/RetainerMain.csb"
RetainerMain.RESOURCE_BINDING = {
    ["Panel_1/Button_1"]             = {["varname"] = "_btn1"},
    ["Panel_1/Button_2"]             = {["varname"] = "_btn2"},
    ["Panel_1/Button_3"]             = {["varname"] = "_btn3"},
    ["Panel_1/Button_4"]             = {["varname"] = "_btn4"},
    ["Panel_1/Button_5"]             = {["varname"] = "_btn5"},
    ["Panel_1/btn_pnl_1"]            = {["varname"] = "_pnlBtn1"},
    ["Panel_1/btn_pnl_2"]            = {["varname"] = "_pnlBtn2"},
    ["Panel_1/btn_pnl_3"]            = {["varname"] = "_pnlBtn3"},
    ["Panel_1/btn_pnl_4"]            = {["varname"] = "_pnlBtn4"},
    ["Panel_1/btn_pnl_5"]            = {["varname"] = "_pnlBtn5"},
    ["Panel_5"]                      = {["varname"] = "_pnlChange"},
}

function RetainerMain:ctor(name, params)
    RetainerMain.super.ctor(self, name, params)
    self._params = params or {}
end

function RetainerMain:init()
    self:centerView()
    self:parseView()

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.MILITARY_HOON
    }
    self:addShowCoinGroup(coin_group)
    self._selectBtn = 1
    self._nowLayer = nil
    self._strLayer = {
        [1] = "app.modules.retainer.RetainerInfo",
        [2] = "app.modules.retainer.RetainerApply",
        [3] = "app.modules.retainer.RetainerAdd",
        [4] = "app.modules.retainer.RetainerAdd",
        [5] = "app.modules.retainer.RetainerTask",
    }
    for i = 1, 5 do
        self["_btn" .. i]:addClickEventListenerWithSound(function ()
            if self._selectBtn == i then
                return
            end
            self._selectBtn = i
            self:refreshLayer()
        end)
    end
    self:refreshLayer()
    self:adaptBgSize()
end

function RetainerMain:refreshBtnShow()
    for i = 1, 5 do
        self["_btn" .. i]:setEnabled(self._selectBtn ~= i)
        self["_pnlBtn" .. i]:getChildByName("img_down"):setVisible(self._selectBtn ~= i)
        self["_pnlBtn" .. i]:getChildByName("img_down_0"):setVisible(self._selectBtn == i)
    end
end

function RetainerMain:refreshLayer()
    self:refreshBtnShow()
    self._pnlChange:removeAllChildren()
    local now_layer = require(self._strLayer[self._selectBtn]):create()
    if self._selectBtn == 3 or self._selectBtn == 4 then
        now_layer:setStrLayer(self._selectBtn)
    end
    now_layer:init()
    self._pnlChange:addChild(now_layer)
    self._nowLayer = now_layer
end

return RetainerMain
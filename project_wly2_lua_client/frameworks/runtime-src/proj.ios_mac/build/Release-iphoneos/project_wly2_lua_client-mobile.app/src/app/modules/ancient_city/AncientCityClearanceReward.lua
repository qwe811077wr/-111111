local AncientCityClearanceReward = class("AncientCityClearanceReward", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

AncientCityClearanceReward.RESOURCE_FILENAME = "ancient_city/AncientCityClearance.csb"
AncientCityClearanceReward.RESOURCE_BINDING = {
    ["Panel_tabview2"]          = {["varname"] = "_panelTableView2"},
    ["btn_get5"]                = {["varname"] = "_btnGet5",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet5"}}},
    ["btn_get2"]                = {["varname"] = "_btnGet2",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet2"}}},
    ["btn_get1"]                = {["varname"] = "_btnGet",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet"}}},
    ["multiple_1_txt"]          = {["varname"] = "_txtMultiple1"},
    ["Node_eff"]                = {["varname"] = "_effectNode"},
    ["label_cost2"]             = {["varname"] = "_txtCost2"},
    ["label_cost1"]             = {["varname"] = "_txtCost1"},
    ["num_1_txt"]               = {["varname"] = "_txtDec1"},
    ["num_2_txt"]               = {["varname"] = "_txtDec2"},
    ["Node_1"]                  = {["varname"] = "_nodeBase"},
    ["Image_2"]                 = {["varname"] = "_imgBg1"},
    ["Image_4"]                 = {["varname"] = "_imgBg2"},
    ["Image_7"]                 = {["varname"] = "_imgTitle"},
    ["title_node"]              = {["varname"] = "_nodeTitle"},
    ["title_1_node"]            = {["varname"] = "_nodeTitle1"},
    ["txt_node"]                = {["varname"] = "_nodeTxt"},
    ["title_3_node"]            = {["varname"] = "_nodeTitle2"},
    ["label_cost2_0"]           = {["varname"] = "_txtDownDec1"},
    ["Panel_5"]                 = {["varname"] = "_pnlTxt"},
    ["two_node"]                = {["varname"] = "_nodeTwo"},
}

function AncientCityClearanceReward:ctor(name, args)
    AncientCityClearanceReward.super.ctor(self, name, args)
    self._curInfo = nil
    self._curMultiple = 1
    self._newMultiple = 1
    self._imgPath = {
        "img/ancient_city/g04_000086_0001_1.png",
        "img/ancient_city/g04_000086_0002_2.png",
        "img/ancient_city/g04_000086_0003_3.png",
        "img/ancient_city/g04_000086_0004_4.png",
        "img/ancient_city/g04_000086_0005_5.png",
    }
end

function AncientCityClearanceReward:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._allUi = {}
    self._xml = StaticData['ancient_info'][1]
    self._leftCost = uq.RewardType.new(self._xml.doubleCost):num() or 0
    self._rightCost = uq.RewardType.new(self._xml.multipleCost):num() or 0
    self:initUi()
    self:initProtocolData()
    self:openAction()
end

function AncientCityClearanceReward:openAction()
    local time = 1 / 24
    self._imgBg1:setPosition(cc.p(12, -212))
    self._imgBg1:runAction(cc.MoveBy:create(time * 3, cc.p(0, 200)))
    self._imgBg2:setPosition(cc.p(12, -85))
    self._imgBg2:setVisible(false)
    self._imgBg2:runAction(cc.Sequence:create(
        cc.DelayTime:create(time * 2),
        cc.CallFunc:create(function ()
            self._imgBg2:setVisible(true)
        end),
        cc.MoveBy:create(time * 2, cc.p(0, 100))
        ))
    self._imgTitle:setVisible(false)
    self._imgTitle:setScale(0.5)
    self._imgTitle:runAction(cc.Sequence:create(
        cc.DelayTime:create(time * 4),
        cc.CallFunc:create(function ()
            self._imgTitle:setVisible(true)
        end),
        cc.ScaleTo:create(time, 1.2),
        cc.ScaleTo:create(time, 1.1),
        cc.ScaleTo:create(time, 1)
        ))
    uq.delayAction(self._nodeTitle, time * 4, function ()
        uq:addEffectByNode(self._nodeTitle, 900011, 1, true, cc.p(0, 0))
    end)
    self._nodeTxt:setVisible(false)
    uq.delayAction(self._nodeTitle1, time * 9, function ()
        uq:addEffectByNode(self._nodeTitle1, 900024, 1, true, cc.p(0, 0))
        self._nodeTxt:setVisible(true)
    end)
    self._txtDownDec1:setVisible(false)
    self._txtMultiple1:setVisible(false)
    self._pnlTxt:setVisible(false)
    uq.delayAction(self._nodeTitle2, time * 16, function ()
        uq:addEffectByNode(self._nodeTitle2, 900024, 1, true, cc.p(0, 0))
        uq:addEffectByNode(self._nodeTitle2, 900137, 1, true, cc.p(115, 0))
        self._txtMultiple1:setVisible(true)
        self._txtDownDec1:setVisible(true)
        self._pnlTxt:setVisible(true)
    end)
    self._nodeTwo:setVisible(false)
    uq.delayAction(self._nodeTwo, time * 19, function ()
        self._nodeTwo:setVisible(true)
    end)
    self._btnGet:setVisible(false)
    self._btnGet:setPosition(cc.p(0, -380))
    self._btnGet:runAction(cc.Sequence:create(
        cc.DelayTime:create(time * 19),
        cc.CallFunc:create(function ()
            self._btnGet:setVisible(true)
        end),
        cc.MoveBy:create(time * 2, cc.p(0, 100))
        ))
    self._panelTableView2:setVisible(false)
    self._panelTableView2:runAction(cc.Sequence:create(
        cc.DelayTime:create(time * 12),
        cc.CallFunc:create(function ()
            self._panelTableView2:setVisible(true)
            for k, v in pairs(self._allUi) do
                v:getBaseLayer():setVisible(false)
                uq:addEffectByNode(v, 900066, 1, true, cc.p(62, 85))
            end
        end),
        cc.DelayTime:create(time),
        cc.CallFunc:create(function ()
            for k, v in pairs(self._allUi) do
                v:getBaseLayer():setVisible(true)
            end
        end)
        ))
end

function AncientCityClearanceReward:initProtocolData()
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_CHANGE_REWARD, handler(self, self._onAncientCityChangeReward), '_onAncientCityChangeRewardByClearance')
end

function AncientCityClearanceReward:removeProtocolData()
    network:removeEventListenerByTag("_onAncientCityChangeRewardByClearance")
end

function AncientCityClearanceReward:playAction()
    if self._newMultiple == self._curMultiple then
        self._txtDec1:stopAllActions()
        self._txtDec2:stopAllActions()
        return
    end
    local off_x = 16
    local ac1 = cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(0, off_x * 2)), cc.CallFunc:create(handler(self, self.playAction)), nil)
    local ac2 = cc.MoveBy:create(0.3,cc.p(0, off_x * 2))
    self._txtDec1:stopAllActions()
    self._txtDec2:stopAllActions()
    if self._txtDec1:getPositionY() < self._txtDec2:getPositionY() then
        self._txtDec1:runAction(ac2)
        self._txtDec1:setPositionY(off_x)
        self._txtDec1:setString(tostring(self._curMultiple))
        self._txtDec2:setPositionY(-off_x)
        self._txtDec2:runAction(ac1)
        self._txtDec2:setString(tostring(self._curMultiple + 1))
    else
        self._txtDec2:runAction(ac2)
        self._txtDec2:setPositionY(off_x)
        self._txtDec2:setString(tostring(self._curMultiple))
        self._txtDec1:setPositionY(-off_x)
        self._txtDec1:runAction(ac1)
        self._txtDec1:setString(tostring(self._curMultiple + 1))
    end
    self._curMultiple = self._curMultiple + 1
end

function AncientCityClearanceReward:_onAncientCityChangeReward(msg)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.sweep.gold.des2"])
    self._newMultiple = msg.data.rate
    self._txtMultiple1:setString("x")
    self:playAction()
    local ShaderEffect = uq.ShaderEffect
    if self._newMultiple >= 2 then
        ShaderEffect:addGrayButton(self._btnGet2)
        self._btnGet2:setTouchEnabled(false)
    end
    if self._newMultiple >= 5 then
        ShaderEffect:addGrayButton(self._btnGet5)
        self._btnGet5:setTouchEnabled(false)
    end
    self:updateItem()
end

function AncientCityClearanceReward:updateItem()
    self._curInfo = uq.cache.ancient_city.total_rewards_info
    if not self._curInfo then
        return
    end
    self._curRewardInfo = {}
    for k, t in pairs(self._curInfo) do
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(t.paraml)
        info.num = tonumber(t.num) * self._newMultiple
        table.insert(self._curRewardInfo, info)
    end
    if not self._tableView2 then
        self:initTableView()
    end
    self._tableView2:reloadData()
end

function AncientCityClearanceReward:initUi()
    self._btnGet:setPressedActionEnabled(true)
    self._btnGet2:setPressedActionEnabled(true)
    self._btnGet5:setPressedActionEnabled(true)
    local color1 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._leftCost) and "#FFFFFF" or "#F10000"
    self._txtCost2:setString(tostring(self._leftCost))
    self._txtCost2:setTextColor(uq.parseColor(color1))
    local color2 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._rightCost) and "#FFFFFF" or "#F10000"
    self._txtCost1:setString(tostring(self._rightCost))
    self._txtCost1:setTextColor(uq.parseColor(color2))
    self:updateItem()
end

function AncientCityClearanceReward:addRichText(parent, des)
    local rich_text = uq.RichText:create()
    rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    rich_text:setDefaultFont("res/font/qdhgjlb.ttf")
    rich_text:setFontSize(26)
    local size = parent:getContentSize()
    rich_text:setContentSize(cc.size(size.width, size.height))
    rich_text:setTextColor(cc.c3b(218,255,255))
    local x,y = parent:getPosition()
    rich_text:setPosition(cc.p(x, y))
    parent:addChild(rich_text)
    rich_text:setText(des)
end

function AncientCityClearanceReward:_onBtnGet(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_GET_REWARD, {})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_QUIT_SCENE, {})
    uq.runCmd('enter_ancient_city')
    self:disposeSelf()
end

function AncientCityClearanceReward:_onBtnGet2(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._leftCost) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHANGE_REWARD, {is_double = 1})
end

function AncientCityClearanceReward:_onBtnGet5(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._rightCost) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHANGE_REWARD, {is_double = 0})
end

function AncientCityClearanceReward:initTableView()
    local size = self._panelTableView2:getContentSize()
    local size_width = math.min(#self._curRewardInfo * 100, 800)
    self._tableView2 = cc.TableView:create(cc.size(size_width, size.height))
    self._tableView2:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView2:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView2:setAnchorPoint(cc.p(0, 0))
    self._tableView2:setPosition(cc.p(size.width / 2 - size_width / 2, 0))
    self._tableView2:setDelegate()
    self._panelTableView2:addChild(self._tableView2)

    self._tableView2:registerScriptHandler(handler(self,self.tableCellTouched2), cc.TABLECELL_TOUCHED)
    self._tableView2:registerScriptHandler(handler(self,self.cellSizeForTable2), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView2:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView2:registerScriptHandler(handler(self,self.numberOfCellsInTableView2), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function AncientCityClearanceReward:cellSizeForTable2(view, idx)
    return 100, 100
end

function AncientCityClearanceReward:numberOfCellsInTableView2(view)
    return #self._curRewardInfo
end

function AncientCityClearanceReward:tableCellTouched2(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByName("item")
    if item == nil then
        return
    end
    local pos=item:convertToNodeSpace(touch_point)
    local rect=cc.rect(0, 0, item:getContentSize().width, item:getContentSize().height)
    if cc.rectContainsPoint(rect, pos) then
        local info = self._curRewardInfo[index]
        uq.showItemTips(info)
    end
end

function AncientCityClearanceReward:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curRewardInfo[index]
        local width = 0
        local euqip_item = EquipItem:create({info = info})
        euqip_item:setScale(0.8)
        width = euqip_item:getContentSize().width * 0.8
        euqip_item:setPosition(cc.p(50, 50))
        cell:addChild(euqip_item)
        euqip_item:setName("item")
        table.insert(self._allUi, euqip_item)
    else
        local info = self._curRewardInfo[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
        end
        euqip_item:setVisible(info ~= nil)
    end
    return cell
end

function AncientCityClearanceReward:dispose()
    self:removeProtocolData()
    AncientCityClearanceReward.super.dispose(self)
end
return AncientCityClearanceReward
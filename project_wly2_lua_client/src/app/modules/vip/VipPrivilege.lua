local VipPrivilege = class("VipPrivilege", require("app.base.TableViewBase"))
local ShopItem = require("app.modules.vip.ShopItem")

VipPrivilege.RESOURCE_FILENAME = "Vip/VipPrivilege.csb"

VipPrivilege.RESOURCE_BINDING  = {
    ["panel_1/ScrollView_3"]                ={["varname"] = "_scrollView"},
    ["panel_1/Panel_tabView"]               ={["varname"] = "_panelTableView"},
}
function VipPrivilege:ctor(name, args)
    VipPrivilege.super.ctor(self)
    self._tabModuleArray = {}
    self._curTabInfo = {}
    self._curTabIndex = args._tab_index or 1
end

function VipPrivilege:init()
    self:parseView()
    self:initUi()
    self:initTableView()
    self:initTab()
    self:initProtocal()
end

function VipPrivilege:initUi()
    self._scrollView:setScrollBarEnabled(false)
    self._curTotalInfo = StaticData['pay']
end

function VipPrivilege:initTab()
    local node = cc.CSLoader:createNode("Vip/ShopTabItem.csb")
    self._scrollView:removeAllChildren()
    self._tabModuleArray = {}
    local scroll_size = self._scrollView:getContentSize()
    local height = #self._curTotalInfo * 87
    if height > scroll_size.height then
        self._scrollView:setScrollBarEnabled(false)
        self._scrollView:setTouchEnabled(true)
    else
        self._scrollView:setTouchEnabled(false)
        self._scrollView:setScrollBarEnabled(false)
        height = scroll_size.height
    end
    self._scrollView:setInnerContainerSize(cc.size(scroll_size.width,height))
    height = height - 87
    for k,v in ipairs(self._curTotalInfo) do
        local tab_item = node:getChildByName("Panel_1"):clone()
        self._scrollView:addChild(tab_item)
        tab_item:setTouchEnabled(true)
        tab_item:setTag(v.ident)
        tab_item:setPosition(cc.p(0,height))
        table.insert(self._tabModuleArray,tab_item)
        tab_item:getChildByName("label_name"):setString(v.name)
        tab_item:addClickEventListenerWithSound(function(sender)
            self._curTabIndex = sender:getTag()
            self:updateTabStatus()
            self:updateDialog()
        end)
        height = height - 87
    end
    self:updateTabStatus()
    self:updateDialog()
end

function VipPrivilege:initProtocal()
end

function VipPrivilege:update(param)

end

function VipPrivilege:updateTabStatus()
    for k,v in ipairs(self._tabModuleArray) do
        if v:getTag() == self._curTabIndex then
            v:getChildByName("img_bg"):loadTexture("img/vip/g02_0028_1.png")
        else
            v:getChildByName("img_bg"):loadTexture("img/vip/g02_0028.png")
        end
    end
end

function VipPrivilege:updateDialog()
    self._curTabInfo = self._curTotalInfo[self._curTabIndex].Pay
    self._curTabNum = math.floor((#self._curTabInfo + 3) / 4)
    self._tableView:reloadData()
end

function VipPrivilege:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function VipPrivilege:cellSizeForTable(view, idx)
    return 750, 240
end

function VipPrivilege:numberOfCellsInTableView(view)
    return self._curTabNum
end

function VipPrivilege:tableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 4 + 1
    for i = 0,3,1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        local pos=item:convertToNodeSpace(touch_point)
        local rect=cc.rect(0,0,item:getContentSize().width,item:getContentSize().height)
        if cc.rectContainsPoint(rect, pos) then
            if not self._curTabInfo[index] then
                return
            end
            --支付
            local info = self._curTabInfo[index]
            if info.Type == 1 then
                local function confirm()
                end
                local des = string.format(StaticData['local_text']['vip.libao.buy.des2'],info.coin,info.name)
                local data = {
                    content = des,
                    confirm_callback = confirm
                }
                uq.addConfirmBox(data)
            else
                local type_info = StaticData.getCostInfo(tonumber(uq.config.constant.COST_RES_TYPE.GOLDEN))
                local function confirm()
                end
                local icon = "<img img/common/ui/"..type_info.miniIcon..">"
                local des = string.format(StaticData['local_text']['vip.libao.buy.des1'],info.coin,icon,info.gold)
                local data = {
                    content = des,
                    confirm_callback = confirm
                }
                uq.addConfirmBox(data)
            end
            break
        end
        index = index + 1
    end
end

function VipPrivilege:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0,3,1 do
            local info = self._curTabInfo[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = ShopItem:create({info = info})
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5 + 10) + (width + 50) * i,120))
                cell:addChild(euqip_item)
                euqip_item:setName("item"..i)
            else
                euqip_item = ShopItem:create()
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5 + 10) + (width + 50) * i,120))
                cell:addChild(euqip_item)
                euqip_item:setName("item"..i)
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    else
        for i = 0,3,1 do
            local info = self._curTabInfo[index]
            local euqip_item = cell:getChildByName("item"..i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function VipPrivilege:dispose()
    VipPrivilege.super.dispose(self)
end

return VipPrivilege
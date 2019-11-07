local CropRedbagReceiveInfo = class("CropRedbagReceiveInfo", require('app.base.PopupBase'))

CropRedbagReceiveInfo.RESOURCE_FILENAME = "crop/CropRedbagReceiveInfo.csb"
CropRedbagReceiveInfo.RESOURCE_BINDING = {
    ["Panel_1"]      = {["varname"] = "_panelRecive"},
    ["Image_3"]      = {["varname"] = "_imgHeadIcon"},
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_5"]       = {["varname"] = "_txtBlessing"},
    ["Text_11"]      = {["varname"] = "_txtRecivedNum"},
    ["Text_12"]      = {["varname"] = "_txtRedAllNum"},
    ["Image_3_0"]    = {["varname"] = "_imgSelfIcon"},
    ["Text_name"]    = {["varname"] = "_txtSelfName"},
    ["Image_7"]      = {["varname"] = "_imgSelfRewardIcon"},
    ["Text_14"]      = {["varname"] = "_txtSelfRewardNum"}
}

function CropRedbagReceiveInfo:ctor(name, params)
    CropRedbagReceiveInfo.super.ctor(self, name, params)
end

function CropRedbagReceiveInfo:init()
    self:centerView()
    self:parseView()
    self:initRewardList()

    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_DETAIL, handler(self, self._onRedBagDetail), '_onCropRedbagDetail')
end

function CropRedbagReceiveInfo:dispose()
    network:removeEventListenerByTag('_onCropRedbagDetail')
    CropRedbagReceiveInfo.super.dispose(self)
end

function CropRedbagReceiveInfo:setHeadImg(id)
    local data = StaticData['majesty_heads'][id]
    if not data then
        return
    end
    self._imgHeadIcon:loadTexture("img/common/player_head/" .. data.icon)
end

function CropRedbagReceiveInfo:initRewardList()
    local viewSize = self._panelRecive:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelRecive:addChild(self._listView)
end

function CropRedbagReceiveInfo:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CropRedbagReceiveInfo:cellSizeForTable(view, idx)
    return 380, 78
end

function CropRedbagReceiveInfo:numberOfCellsInTableView(view)
    return #self._data.items
end

function CropRedbagReceiveInfo:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("crop.CropRedbagReceiveInfoCell")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(self._data.items[index])

    return cell
end

function CropRedbagReceiveInfo:_onRedBagDetail(msg)
    self._data = msg.data
    self._id = self._data.id
    self:refreshReceive()
    self:selectOwner()
    self._listView:reloadData()
    self:setHeadImg(self._data.img_id)
end

function CropRedbagReceiveInfo:refreshReceive()
    local all_redbag = uq.cache.crop._allRedbag
    for k,v in pairs(all_redbag) do
        if v.id == self._id then
            self._txtName:setString(v.role_name)
            self._txtRedAllNum:setString(StaticData['local_text']['chat.red.packet.interval'] .. v.total_num)
            self._txtRecivedNum:setString(self._data.count)
            break
        end
    end
end

function CropRedbagReceiveInfo:selectOwner()
    for k, v in pairs(self._data.items) do
        if v.name == uq.cache.role.name then
            self:initSelfReward(v)
            table.remove(self._data.items, k)
            return
        end
    end

    --未抢到
    local role_name = uq.cache.role.name
    self._txtSelfName:setString(role_name)
    self._imgSelfRewardIcon:setVisible(false)
    self._txtSelfRewardNum:setString(StaticData['local_text']['chat.red.packet.captured.not'])
end

function CropRedbagReceiveInfo:initSelfReward(data)
    self._txtSelfName:setString(data.name)

    local item = StaticData['legion_envelopes'][data.item_id]
    local reward = uq.RewardType:create(item.reward)
    local info = StaticData.getCostInfo(reward:type(), reward:id())
    local miniIcon = info and info.miniIcon or "03_0002.png"
    self._imgSelfRewardIcon:loadTexture('img/common/ui/' .. miniIcon)


    self._txtSelfRewardNum:setString(reward:num())
end

return CropRedbagReceiveInfo
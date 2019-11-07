local ArmsListItem = class("ArmsListItem", function()
    return ccui.Layout:create()
end)

function ArmsListItem:ctor(args)
    self._view = nil
    self._generalId = 0
    self:init()
    self._local_text = {
        StaticData['local_text']["label.common.num1"],
        StaticData['local_text']["label.common.num2"],
        StaticData['local_text']["label.common.num3"],
        StaticData['local_text']["label.common.num4"],
        StaticData['local_text']["label.common.num5"],
        StaticData['local_text']["general.soldier.level.title"] .. StaticData['local_text']["label.common.num5"],
        StaticData['local_text']["label.common.num6"],
        StaticData['local_text']["label.common.num7"],
        StaticData['local_text']["label.common.num8"],
    }
end

function ArmsListItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("generals/ArmsListItem.csb")
        self._view = node:getChildByName("Panel_3")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._panelItems = self._view:getChildByName("Panel_tableview");
    self._levelLabel = self._view:getChildByName("lbl_level_num");
    self._curInfo = {}
    self._itemList = {}
end

function ArmsListItem:setInfo(info,general_id)
    self._curInfo = info
    self._generalId = general_id
    local tag = self:getTag()
    self._levelLabel:setString(string.format(StaticData['local_text']["general.soldier.level.des"], self._local_text[tag]))
    self:updateData()
end

function ArmsListItem:dispose()
    for k, v in pairs(self._itemList) do
        v:dispose()
    end
end

function ArmsListItem:updateData()
    local num = #self._curInfo
    for k, v in ipairs(self._curInfo) do
        local item = self._itemList[k]
        if not item then
            item = uq.createPanelOnly("generals.ArmsResInfoItem")
            item:setTag(k)
            item:setScale(0.9)
            item:setSelectBgImgVisible(false)
            item:setUpImgVisible(false)
            item:setBgImgTouchEnabled(false)
            self._panelItems:addChild(item)
            table.insert(self._itemList, item)
        end
        local item_info = {general_id = self._generalId, soldier_id = v.ident}
        item:setInfo(item_info)
        if v.mainSoldierLevel > 3 and v.mainSoldierLevel < 6 then
            item:setUpImgVisible(true)
        end
        item:setVisible(true)
        local size = self._panelItems:getContentSize()
        local item_size = item:getContentSize()
        item:setPosition(cc.p(((k - 1) % 4) * (item_size.width * 0.9 + 3), size.height - item_size.height * 0.9 * (math.ceil(k / 4.5))))
    end
    for i = #self._curInfo + 1, #self._itemList do
        self._itemList[i]:setVisible(false)
    end
end

function ArmsListItem:onItemTouch(pos)
    for k, v in ipairs(self._itemList) do
        local node_pos = v:getChildByName("Panel_1"):convertToNodeSpace(pos)
        local size = v:getContentSize()
        local pos_x, pos_y = v:getPosition()
        local rect = cc.rect(0, 0, size.width, size.height)

        if v:isVisible() and cc.rectContainsPoint(rect, node_pos) then
            local info = self._curInfo[k]
            uq.ModuleManager:getInstance():show(uq.ModuleManager.ARMS_INFO_MODULE, {info = info})
        end
    end
end

function ArmsListItem:setContentHeight(height)
    local size = self._panelItems:getContentSize()
    self._panelItems:setContentSize(cc.size(size.width, height))
end

function ArmsListItem:getPanelItemHeight()
    local size = self._panelItems:getContentSize()
    return size.height + 1
end

return ArmsListItem
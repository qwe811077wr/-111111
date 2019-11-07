local HeadItem = class("HeadItem", require('app.base.ChildViewBase'))

HeadItem.RESOURCE_FILENAME = "role/HeadItem.csb"
HeadItem.RESOURCE_BINDING = {
    ["Image_17"] = {["varname"]="_imgHead"},
    ["Panel_1"]  = {["varname"]="_panelUsing"},
    ["Image_18"] = {["varname"]="_imgLock"},
    ["Image_26"] = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onClick"}}},
}

function HeadItem:setData(general_data, callback)
    self._generalData = general_data
    self._callback = callback
    self._headId = general_data.head_id
    self._headType = general_data.head_type
    local res_head = uq.getHeadRes(self._headId, self._headType)
    self._imgHead:loadTexture(res_head)
    self:refreshSelect()
    self._imgBg:setSwallowTouches(false)
end

function HeadItem:refreshSelect()
    local using = uq.cache.role:isMyHeadEqual(self._headId, self._headType)
    self:setSelected(using)
    local xml_data = StaticData['general'][self._generalData.temp_id]
    local is_lock = self._headType == uq.config.constant.HEAD_TYPE.GENERAL and xml_data.qualityType < 2
    self._imgLock:setVisible(is_lock)
end

function HeadItem:setSelected(visible)
    self._panelUsing:setVisible(visible)
end

function HeadItem:getHeadId()
    return self._generalData.head_id
end

function HeadItem:isLock()
    return self._imgLock:isVisible()
end

function HeadItem:onClick(event)
    if event.name ~= 'ended' or self:isLock() or self._panelUsing:isVisible() then
        return
    end
    network:sendPacket(Protocol.C_2_S_MASTER_SET_HEAD_PORTRAIT, {img_type = self._headType, img_id = self._headId})
    if self._callback then
        self._callback()
    end
end

function HeadItem:getContentSize()
    return self._imgLock:getContentSize()
end

return HeadItem
local ConfirmBoxList = class("ConfirmBoxList", require('app.base.PopupBase'))

ConfirmBoxList.RESOURCE_FILENAME = "common/ConfirmBoxList.csb"
ConfirmBoxList.RESOURCE_BINDING = {
}

function ConfirmBoxList:init()
    self._boxList = {}
    self:centerView()
    self:setTouchClose(false)
    self:setLayerColor(0.6)
end

function ConfirmBoxList:addConfirmBox(data,confirm_id)
    local panel = nil
    if confirm_id == uq.config.constant.CONFIRM_TYPE.NULL then
        panel = uq.createPanelOnly("common.ConfirmBoxNoSelect")
    else
        panel = uq.createPanelOnly("common.ConfirmBox")
    end
    panel:setData(data)
    panel:setConfirmId(confirm_id)
    panel:setCallback(handler(self, self.callBack))
    panel:setPosition(cc.p(CC_DESIGN_RESOLUTION.width / 2, CC_DESIGN_RESOLUTION.height / 2))
    self._view:addChild(panel)
    table.insert(self._boxList, panel)
end

function ConfirmBoxList:callBack(panel)
    for index,item in ipairs(self._boxList) do
        if item == panel then
            panel:removeFromParent()
            table.remove(self._boxList, index)
            break
        end
    end

    if #self._boxList == 0 then
        self:disposeSelf()
    end
end

return ConfirmBoxList
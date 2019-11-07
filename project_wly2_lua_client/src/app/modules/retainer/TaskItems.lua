local TaskItems = class("TaskItems", require('app.base.ChildViewBase'))

TaskItems.RESOURCE_FILENAME = "retainer/TalkItems.csb"
TaskItems.RESOURCE_BINDING = {
    ["Panel_4/Button_5"]          = {["varname"]="_btnAward"},
    ["Panel_4/talk_name"]         = {["varname"]="_txtName"},
    ["Panel_4/talk_dec"]          = {["varname"]="_txtDec"},
    ["Panel_4/LoadingBar_1"]      = {["varname"]="_ldbar"},
    ["Panel_4/Image_6_0"]         = {["varname"]="_imgFull"},
    ["Panel_4/items_pnl"]         = {["varname"]="_pnlItems"},
}

function TaskItems:onCreate()
    TaskItems.super.onCreate(self)
end

function TaskItems:setData(data)
    local data = data or {}
    if next(data) ~= nil then
        self._txtName:setString(data.name)
        self._txtDec:setString(data.taskDes)
        local all_num = data.num
        local pct = 100
        local num = 0
        if data.num ~= 0 then
            local tab_id = uq.cache.retainer:getSuzerainEventTab(data.ident)
            if tab_id and tab_id.state then
                self._state = tab_id.state
                pct = math.min(tab_id.num / data.num * 100, 100)
            end
        end
        self._pct = pct
        self._ldbar:setPercent(pct)
        self._imgFull:setVisible(pct == 100)
    end
    self.data = data
    self._btnAward:addClickEventListenerWithSound(function ()
        if not self._pct then
            return
        end
        if self._pct < 100 then
            uq.fadeInfo(StaticData["local_text"]["retainer.not.enough.condition"])
            return
        end
        local data = {
            id = data.ident,
            apprentice_id = uq.cache.role.id
        }
        network:sendPacket(Protocol.C_2_S_ZONG_DRAW_EVENT, data)
    end)
    self:refreshItems()
    self:parseView()
end

function TaskItems:refreshItems()
    self._pnlItems:removeAllChildren()
    local tab = self:dealAward(self.data.reward1)
    local num = math.min(#tab, 3)
    for i = 1, num do
        local euqip_item = uq.createPanelOnly("retainer.PropItems")
        euqip_item:setPosition(cc.p(i * 110 - 50, 5))
        euqip_item:setScale(0.8)
        euqip_item:setData(tab[i])
        self._pnlItems:addChild(euqip_item)
    end
end

function TaskItems:dealAward(str)
    local tab = {}
    local str = str or ""
    local attr_array = string.split(str,"|")
    for k, v in ipairs(attr_array) do
        local attr = string.split(v, ";")
        table.insert(tab, {type = tonumber(attr[1]), id = tonumber(attr[3]), num = tonumber(attr[2])})
    end
    return tab
end

return TaskItems
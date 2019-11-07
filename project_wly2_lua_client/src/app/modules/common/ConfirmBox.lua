local ConfirmBox = class("ConfirmBox", require('app.base.ChildViewBase'))

ConfirmBox.RESOURCE_FILENAME = "common/Confirm.csb"
ConfirmBox.RESOURCE_BINDING = {
    ["Image_9"]      = {["varname"] = "_imgBg"},
    ["Button_2"]     = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "onCancle"}}},
    ["Button_2_0"]   = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["label"]        = {["varname"] = "_title"},
    ["Panel_2"]      = {["varname"] = "_panelCheck"},
    ["Panel_1"]      = {["varname"] = "_bg"},
    ["CheckBox_1_0"] = {["varname"] = "_checkBox"},
    ["Node_1"]       = {["varname"] = "_nodeCheck"},
    ["Button_1"]     = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "onClosed"}}},
}

-- title
-- content
-- confirm_callback
-- cancle_callback
-- confirm_txt
-- cancle_txt
-- style uq.config.constant.CONMFRIM_BOX_STYLE.CONFIRM_BTN_ONLY

function ConfirmBox:onCreate()
    ConfirmBox.super.onCreate(self)
    self._callback = nil
    self._data = nil
    self._confirmId = 0
    self:parseView()

    self._nodeCheck:setVisible(false)

    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0.5, 1))
    self._richText:setDefaultFont("res/font/fzlthjt.ttf")
    self._richText:setFontSize(22)
    local size = self._bg:getContentSize()
    self._richText:setContentSize(cc.size(size.width, 0))
    self._richText:setMultiLineMode(false)
    self._richText:setTextColor(uq.parseColor('#ffffff'))
    local x,y = self._bg:getPosition()
    self._richText:setPosition(cc.p(x, y))
    self:addChild(self._richText)
    self._panelCheck:setTouchEnabled(true)
    self._panelCheck:addClickEventListener(function(sender)
        self._checkBox:setSelected(not self._checkBox:isSelected())
    end)
end

function ConfirmBox:refreshSize()
    local size = self._bg:getContentSize()
    if self._richText:getTextRealSize().width > size.width then
        self._richText:setContentSize(cc.size(size.width, 0))
        self._richText:setMultiLineMode(true)
    end
end

function ConfirmBox:onClosed(event)
    if event.name == "ended" then
        if self._callback then
            self._callback(self)
        end
    end
end

function ConfirmBox:onCancle(event)
    if event.name == "ended" then
        if self._data.cancle_callback then
            self._data.cancle_callback()
        end
        self:onClosed({name = "ended"})
    end
end

function ConfirmBox:setConfirmId(id)
    self._confirmId = id

    if id > 0 then
        self._nodeCheck:setVisible(true)
    end
end

function ConfirmBox:setData(data)
    data.confirm_txt = data.confirm_txt or StaticData['local_text']['label.common.confirm']
    data.cancle_txt = data.cancle_txt or StaticData['local_text']['label.bosom.btn.cancel2']

    self._data = data
    local title = data.title or StaticData['local_text']['label.common.tips']
    self._title:setString(title)

    if data.style == uq.config.constant.CONMFRIM_BOX_STYLE.CONFIRM_BTN_ONLY then
        self._nodeCheck:setVisible(false)
        self._btnCancle:setVisible(false)
        self._btnConfirm:setPositionX(1)
    end
    self._richText:setText(data.content)
    self._richText:formatText()

    self._btnConfirm:getChildByName('Text_30'):setString(data.confirm_txt)
    self._btnCancle:getChildByName('Text_30'):setString(data.cancle_txt)

    self:refreshSize()

    if not self._data.reward then
        return
    end
    local num = #self._data.reward
    local y = self._richText:getPositionY() - self._richText:getContentSize().height / 2 - 50

    for k, v in ipairs(self._data.reward) do
        local info = StaticData['types'].Cost[1].Type[v.type]
        local rich_text = uq.RichText:create()
        rich_text:setAnchorPoint(cc.p(0.5, 0.5))
        rich_text:setDefaultFont("res/font/fzlthjt.ttf")
        rich_text:setFontSize(24)
        rich_text:setMultiLineMode(false)
        rich_text:setTextColor(uq.parseColor('#ffffff'))
        local des = "<img img/common/ui/" .. info.miniIcon .. ">" .. " " .. uq.formatResource(v.cost)
        rich_text:setText(des)
        self:addChild(rich_text)
        rich_text:setPositionY(y)
        if num > 1 then
            local delta = 260 / (num - 1)
            rich_text:setPositionX(delta * (k - 1) - 130)
        end
    end
end

function ConfirmBox:onConfirm(event)
    if event.name == "ended" then
        if self._checkBox:isSelected() then
            uq.cache.role.confirm_ids[self._confirmId] = true
        end
        if self._data.confirm_callback then
            self._data.confirm_callback()
        end
        self:onClosed({name = "ended"})
    end
end

function ConfirmBox:setCallback(callback)
    self._callback = callback
end

return ConfirmBox
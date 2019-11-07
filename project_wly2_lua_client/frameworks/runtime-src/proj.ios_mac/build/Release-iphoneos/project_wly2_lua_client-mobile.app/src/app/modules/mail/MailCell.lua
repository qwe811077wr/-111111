local MailCell = class("MailCell", require('app.base.ChildViewBase'))

MailCell.RESOURCE_FILENAME = "mail/MailCell.csb"
MailCell.RESOURCE_BINDING = {
    ["CheckBox_1"] = {["varname"] = "_checkboxSelect"},
    ["Text_1"]     = {["varname"] = "_txtTitle"},
    ["Text_1_0_0"] = {["varname"] = "_txtTime"},
    ["g03_0118_2"] = {["varname"] = "_imgRewardMail"},
    ["Image_3"]    = {["varname"] = "_imgReceived"},
    ["Image_8"]    = {["varname"] = "_imgRed"},
    ["Image_1"]    = {["varname"] = "_imgBg"},
    ["base_node"]  = {["varname"] = "_nodeBase"},
}

function MailCell:onCreate()
    MailCell.super.onCreate(self)

    self._curIndex = 0
    self._mailData = nil

    self._checkboxSelect:addEventListener(handler(self, self.onCheckSelected))

    self._eventTag = '_mailDetailInfo' .. tostring(self)
end

function MailCell:onExit()
    MailCell.super:onExit()
    network:removeEventListenerByTag(self._eventTag)
end

function MailCell:_mailDetailInfo(msg)
    for k, item in ipairs(msg.data) do
        if item.id == self._mailData.id then
            self:refreshPage(item)
            break
        end
    end
end

function MailCell:addListener()
    network:removeEventListenerByTag(self._eventTag)
    network:addEventListener(Protocol.S_2_C_MAIL_LOAD, handler(self, self._mailDetailInfo), self._eventTag)
end

function MailCell:setCheckBox(flag)
    self._checkboxSelect:setSelected(flag)

    if self._callback then
        self._callback(self._curIndex, flag)
    end
end

function MailCell:setData(mail_data, index)
    self._curIndex = index
    self._mailData = mail_data
    self._checkboxSelect:setSelected(mail_data.is_checked)
    self:addListener()

    local data = uq.cache.mail:getMailInfoByID(mail_data.id)
    if data then
        self:refreshPage(data)
    end

    local red_state = self._mailData.state == uq.config.constant.TYPE_MAIL_CELL_STATE.NEW or (self._mailData.state ~= uq.config.constant.TYPE_MAIL_CELL_STATE.GOT_REWARD and self._mailData.reward ~= '')
    self._imgRed:setVisible(red_state)
    self._imgBg:setVisible(self._mailData.state ~= uq.config.constant.TYPE_MAIL_CELL_STATE.NEW)
    self:setReadState(mail_data.state)
end

function MailCell:setReadState(state)
    self._imgReceived:setVisible(false)
    self._txtTime:setVisible(true)

    if state == uq.config.constant.TYPE_MAIL_CELL_STATE.NEW then
        if self._mailData.reward == '' then
            self._imgRewardMail:loadTexture("img/mail/g03_0000585.png")
        else
            self._imgRewardMail:loadTexture("img/mail/g03_0000585.png")
        end
    elseif state >= uq.config.constant.TYPE_MAIL_CELL_STATE.READ then
        if self._mailData.reward == '' then
            self._imgRewardMail:loadTexture("img/mail/s03_00061.png")
        else
            self._imgRewardMail:loadTexture("img/mail/s03_00062.png")
        end
    end

    if state == uq.config.constant.TYPE_MAIL_CELL_STATE.GOT_REWARD then
        self._imgReceived:setVisible(true)
        self._txtTime:setVisible(false)
    end
end

function MailCell:refreshPage(mail_data)
    local name = #uq.cache.mail:getMailTitle(mail_data)
    local title_len_set = 9 - name / 3
    local title = self:cutString(mail_data.title, title_len_set)

    local str  = string.format("[%s]%s", uq.cache.mail:getMailTitle(mail_data), title)
    self._txtTitle:setString(str)

    local tab = os.date("*t", mail_data.create_time)
    self._txtTime:setString(string.format(StaticData['local_text']['mail.cell.time'], tab.year, tab.month, tab.day))
end

function MailCell:cutString(content, cut_len)
    local title = content
    local str_len = #title
    local title_len = 0
    local start_index = 1
    local end_index = start_index

    for i=1, str_len do
        if start_index > str_len then
            break
        end
        local byte = string.sub(title, start_index, end_index)
        if string.byte(byte) > 127 then
            start_index = end_index + 3
        else
            start_index = end_index + 1
        end
        end_index = start_index
        title_len = title_len + 1
        if title_len >= cut_len then
            break
        end
    end
    if start_index < str_len then
        title = string.sub(title, 1, end_index - 1) .. "..."
    end

    return title
end

function MailCell:onCheckSelected(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        if self._callback then self._callback(self._curIndex, true) end
    elseif eventType == ccui.CheckBoxEventType.unselected then
        if self._callback then self._callback(self._curIndex, false) end
    end
end

function MailCell:setCallback(cb)
    self._callback = cb
end

function MailCell:showAction()
    uq.intoAction(self._nodeBase)
end

return MailCell
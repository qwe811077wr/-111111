local Mail = class("Mail")

function Mail:ctor()
    self._mail = {}
    self._recentContanct = {}
    self._isExistMailRed = false
    self._mailRed= {}

    self:getContanct()

    network:addEventListener(Protocol.S_2_C_MAIL_DELETE, handler(self, self._mailDelete))
    network:addEventListener(Protocol.S_2_C_MAIL_LOAD, handler(self, self._mailNewMail))
    network:addEventListener(Protocol.S_2_C_MAIL_LOAD_BEGIN, handler(self, self._mailBegin))
    network:addEventListener(Protocol.S_2_C_MAIL_REWARD, handler(self, self._mailReward))
    network:addEventListener(Protocol.S_2_C_MAIL_READ, handler(self, self._onMailRead))
end

Mail._MailType = {
    MAIL_SYSTEM = 1,
    MAIL_ARMY   = 2,
}

function Mail:_mailBegin(msg)
    self._mail = {}
end

function Mail:getMailList(type)
    if not type then
        return self._mail
    else
        return self:getMailListByType(type)
    end
end

function Mail:_onMailRead(msg)
    if msg.data.ret ~= 0 then
        return
    end
    for k, item in ipairs(self._mail) do
        if item.id == msg.data.mail_id then
            self._mail[k].state = uq.config.constant.TYPE_MAIL_CELL_STATE.READ
            break
        end
    end
    self:updateRed()
    self:refreshMail()
end

function Mail:getMailListByType(is_army)
    local mail_list = {}
    for k, item in ipairs(self._mail) do
        if is_army and item.mail_type == uq.config.constant.TYPE_MAIL.MAIL_FROM_ARMY then
            table.insert(mail_list, item)
        elseif not is_army and item.mail_type ~= uq.config.constant.TYPE_MAIL.MAIL_FROM_ARMY then
            table.insert(mail_list, item)
        end
    end
    return mail_list
end

function Mail:_mailNewMail(msg)
    msg.data["mails"][1].is_checked = false
    table.insert(self._mail, msg.data["mails"][1])
    uq.playSoundByID(60)
    self:updateRed()
    self.refreshMail()
end

function Mail:updateRed()
    self._mailRed= {}
    for k, v in ipairs(self._mail) do
        local red_state = v.state == uq.config.constant.TYPE_MAIL_CELL_STATE.NEW or (v.reward ~= '' and v.state ~= uq.config.constant.TYPE_MAIL_CELL_STATE.GOT_REWARD)
        local mail_type = self._MailType.MAIL_ARMY
        if v.mail_type ~= uq.config.constant.TYPE_MAIL.MAIL_FROM_ARMY then
            mail_type = self._MailType.MAIL_SYSTEM
        end
        if red_state and not self._mailRed[mail_type] then
            self._mailRed[mail_type] = true
        end
    end
    self._isExistMailRed = next(self._mailRed) ~= nil
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIL_MAIN_RED})
end

function Mail:getMailInfoByID(mail_id)
    for k,item in pairs(self._mail) do
        if item.id == mail_id then
            return item
        end
    end
    return
end

function Mail:getMailTitle(mail_data)
    if mail_data.mail_type == uq.config.constant.TYPE_MAIL.MAIL_FROM_PC then
        return mail_data.sender_name
    elseif mail_data.mail_type == uq.config.constant.TYPE_MAIL.MAIL_FROM_GAME then
        return StaticData["local_text"]["mail.type.game"]
    elseif mail_data.mail_type == uq.config.constant.TYPE_MAIL.MAIL_FROM_BATTLE then
        return StaticData["local_text"]["mail.type.battle"]
    elseif mail_data.mail_type == uq.config.constant.TYPE_MAIL.MAIL_FROM_REWARD then
        return StaticData["local_text"]["mail.type.reward"]
    else
        return ''
    end
end

function Mail:_mailDelete(msg)
    if #msg.data.mail_id > 0 then
        uq.fadeInfo(StaticData["local_text"]["mail.delete.success"])
    else
        uq.fadeInfo(StaticData["local_text"]["mail.delete.fail"])
    end

    for t,v in ipairs(msg.data.mail_id) do
        for k,item in pairs(self._mail) do
            if item.id == v then
                table.remove(self._mail,k)
                break
            end
        end
    end

    self:refreshMail()
end

function Mail:_mailReward(msg)
    if msg.data.ret ~= 0 then
        return
    end

    local ids = {}
    for k, v in ipairs(msg.data.mail_id) do
        ids[v] = v
    end

    local rewards = {}
    for k, item in ipairs(self._mail) do
        if ids[item.id] then
            if item.reward ~= '' then
                item.state = uq.config.constant.TYPE_MAIL_CELL_STATE.GOT_REWARD
                rewards = uq.RewardType:mergeRewardToMap(rewards, uq.RewardType.parseRewards(item.reward))
            else
                item.state = uq.config.constant.TYPE_MAIL_CELL_STATE.READ
            end
        end
    end
    if next(rewards) ~= nil then
        local info = uq.RewardType:convertMapToTable(rewards)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = info})
    end
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_REWARD_GET_REFRESH})
end

function Mail:refreshMail()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.MAIL_MAIN)
    if panel then
        panel:refreshPage()
    end
end

function Mail:setContanct(name)
    local names = ''
    local contanct_num = #self._recentContanct
    local end_index = 3
    if contanct_num < end_index then
        end_index = contanct_num
    end
    local index = end_index - 1
    for i = 0, index do
        names = names .. ";" .. self._recentContanct[contanct_num + i - index]
    end

    cc.UserDefault:getInstance():setStringForKey("mail_contanct", names)
end

function Mail:getContanct()
    local names = cc.UserDefault:getInstance():getStringForKey("mail_contanct", "")
    if names == '' then
        return
    end

    self._recentContanct = string.split(names, ";")
    table.remove(self._recentContanct, 1)
end

function Mail:addContanct(name)
    for k, v in pairs(self._recentContanct) do
        if v == name then
            return
        end
    end

    table.insert(self._recentContanct, name)
    self:setContanct(name)
end

return Mail
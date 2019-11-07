local BosomInfoModule = class("BosomInfoModule", require('app.base.ModuleBase'))
local WordMarquee = require('app/utils/WordMarquee')

BosomInfoModule.NPC_TYPE_NONE = 0
BosomInfoModule.NPC_TYPE_WIFE = 1
BosomInfoModule.NPC_TYPE_TALK_LIST = 2
BosomInfoModule.NPC_TYPE_BOSOM = 3

BosomInfoModule.RESOURCE_FILENAME = "bosom/BosomView.csb"
BosomInfoModule.RESOURCE_BINDING = {
    ["base_info_panel"]                                    = {["varname"] = "_pnlBaseInfo"},
    ["showexp_pnl"]                                        = {["varname"] = "_pnlShowExp"},
    ["click_mask"]                                         = {["varname"] = "_pnlclick"},
    ["base_info_panel/happy_val_txt"]                      = {["varname"] = "_txtVal"},
    ["base_info_panel/name_pic"]                           = {["varname"] = "_imgNamePic"},
    ["base_info_panel/happy_progress_bar"]                 = {["varname"] = "_prgHappy"},
    ["base_info_panel/cur_exp"]                            = {["varname"] = "_imgCurExp"},
    ["base_info_panel/add_exp_txt"]                        = {["varname"] = "_txtAddExp"},
    ["base_info_panel/cur_exp/cur_exp_txt"]                = {["varname"] = "_txtCurExp"},
    ["base_info_panel/satisfy_group/satisfy_val_txt"]      = {["varname"] = "_txtSatisfy"},
    ["talk_words_container/talk_words_panel/Text_2_1"]     = {["varname"] = "_addExpTxt"},
    ["attr_addup_panel"]                                   = {["varname"] = "_pnlAttr"},
    ["attr_addup_panel/now_att_pnl"]                       = {["varname"] = "_pnlNow"},
    ["attr_addup_panel/now_att_pnl/Image_16/Image_18"]     = {["varname"] = "_imgNowBg"},
    ["attr_addup_panel/now_att_pnl/attr_val1_txt"]         = {["varname"] = "_txtNow"},
    ["attr_addup_panel/now_att_pnl/attr_name1_txt"]        = {["varname"] = "_txtNowName"},
    ["attr_addup_panel/now_att_pnl/Text_12"]               = {["varname"] = "_txtNowDec"},
    ["attr_addup_panel/new_att_pnl"]                       = {["varname"] = "_pnlNew"},
    ["attr_addup_panel/new_att_pnl/Image_16_0/Image_18"]   = {["varname"] = "_imgNewBg"},
    ["attr_addup_panel/new_att_pnl/attr_val2_txt"]         = {["varname"] = "_txtNew"},
    ["attr_addup_panel/new_att_pnl/attr_name2_txt"]        = {["varname"] = "_txtNewName"},
    ["attr_addup_panel/new_att_pnl/Text_12_0"]             = {["varname"] = "_txtNewDec"},
    ["auto_searching"]                                     = {["varname"] = "_pnlAuto"},
    ["action2_panel"]                                      = {["varname"] = "_pnlAction2"},
    ["bye_panel_container"]                                = {["varname"] = "_pnlBye"},
    ["bye_panel_container/bye_bosom_panel"]                = {["varname"] = "_pnlByeBye"},
    ["bye_panel_container/bye_wife_panel"]                 = {["varname"] = "_pnlByeWife"},
    ["exchange_famous_btn"]                                = {["varname"] = "_pnlFamous"},
    ["action_panel_container"]                             = {["varname"] = "_pnlAction"},
    ["action_panel_container/action_panel/action1_btn"]    = {["varname"] = "_btnAction1"},
    ["action_panel_container/action_panel/action2_btn"]    = {["varname"] = "_btnAction2"},
    ["action_panel_container/action_panel/action3_btn"]    = {["varname"] = "_btnAction3"},
    ["action_panel_container/action_panel/action2_btn/req_lvl_txt"]    = {["varname"] = "_txtRed2"},
    ["action_panel_container/action_panel/action3_btn/req_lvl_txt"]    = {["varname"] = "_txtRed3"},
}

function BosomInfoModule:ctor(name, params)
    BosomInfoModule.super.ctor(self, name, params)

    self._id = params.id
    self._autoTalk = params.auto_talk
    self._formBosom = params.form_bosom
    self._func = params.func
    self._onlyTalk= params.only_talk
    self._template = StaticData['bosom']['women'][self._id]
    self._talkTemp = nil
    self._marquee = nil
    self._tempWifeId = 0
    self._marryRet = 0
    self._marryTalkStep = 0
    self._npcType = 0
    self._statusMarry = false
    self._autoTalkTimerTag = '_onAutoTalkTimer' .. tostring(self)
    self._autoTalkTimer = false
    self._limitLvl = 15
    if self._id == uq.cache.role.bosom.wife_id then
        self._npcType = self.NPC_TYPE_WIFE
    else
        if uq.cache.role.bosom.bosoms[self._id] and uq.cache.role.bosom.bosoms[self._id].type == uq.config.constant.BOSOM_TYPE.BOSOM then
            self._npcType = self.NPC_TYPE_BOSOM
        else
            if not self._formBosom and uq.cache.role.bosom:inTalkList(self._id) then
                self._npcType = self.NPC_TYPE_TALK_LIST
            end
        end
    end
end

function BosomInfoModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    local bg = self._view:getChildByName('img_bg_adapt')
    bg:ignoreContentAdaptWithSize(true)
    if self._npcType == self.NPC_TYPE_WIFE then
        bg:loadTexture('res/img/bg/g05_0011.png', ccui.TextureResType.localType)
        self:_showWife()
    else
        bg:loadTexture('res/img/bg/g05_0006.png', ccui.TextureResType.localType)
        if self._npcType == self.NPC_TYPE_BOSOM then
            self:_showBosom()
        elseif self._npcType == self.NPC_TYPE_TALK_LIST then
            self:_showBosomInTalk()
        else
            self:_showBosomUnmeet()
        end
    end

    local this = self
    local btn = self._view:getChildByName('return_btn')
    btn:addClickEventListenerWithSound(function()
            if not self._autoTalk then
                this:disposeSelf()
            end
        end)

    self._showCurExp = false
    self._pnlShowExp:addClickEventListenerWithSound(function()
        self._imgCurExp:setVisible(not self._showCurExp)
        self._showCurExp = not self._showCurExp
        if not is_visible then
            self:refreshExpLayer()
        end
        end)

    local talk_func = function()
        this._autoTalkTimer = false
        if this._talkTemp then
            return
        end
        if self._onlyTalk then
            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_TALK, {npc_id = this._id, famous_id = 0, famous_num = 0})
            return
        end
        local cost_talk = uq.cache.role.bosom:getTalkCost()
        local func = function ()
            if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost_talk) then
                uq.fadeInfo(StaticData["local_text"]["bosom.talk.less.gold"])
                return
            end
            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_TALK, {npc_id = this._id, famous_id = 0, famous_num = 0})
        end
        if cost_talk == 0 then
            func()
            return
        end
        local data = {
            content = string.format(StaticData['local_text']['bosom.talk.cost.gold'], '<img img/common/ui/03_0003.png>', cost_talk),
            confirm_callback = function()
                func()
            end
        }
        uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BOSOM_TALK)
    end

    local gift_func = function()
        if this._npcType == self.NPC_TYPE_TALK_LIST then
            local npc = uq.cache.role.bosom.bosoms[self._id]
            if not npc or npc.lvl < self._limitLvl then
                uq.fadeInfo(string.format(StaticData["local_text"]["bosom.less.lv.operator"], self._limitLvl))
                return
            end
        end
        if uq.cache.role.bosom:getFamousNum() <= 0 then
            uq.fadeInfo(StaticData["local_text"]["label.famous.give"])
            return
        end

        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_FAMOUS_MODULE, {id = this._id})
    end

    local bosom_func = function()
        if this._npcType == self.NPC_TYPE_TALK_LIST then
            local npc = uq.cache.role.bosom.bosoms[self._id]
            if not npc or npc.lvl < self._limitLvl then
                uq.fadeInfo(string.format(StaticData["local_text"]["bosom.less.lv.operator"], self._limitLvl))
                return
            end
        end
        self:_doBosomBecome()
    end

    local panel = self._view:getChildByName('action2_panel')
    btn = panel:getChildByName('talk_btn')
    btn:addClickEventListenerWithSound(talk_func)
    btn = panel:getChildByName('send_gift_btn')
    btn:addClickEventListenerWithSound(gift_func)

    panel = self._view:getChildByName('action_panel_container'):getChildByName('action_panel')
    btn = panel:getChildByName('action1_btn')
    btn:addClickEventListenerWithSound(talk_func)
    btn = panel:getChildByName('action2_btn')
    btn:addClickEventListenerWithSound(gift_func)
    self._btnAction3:addClickEventListenerWithSound(bosom_func)

    panel = self._view:getChildByName('talk_words_container')
    btn = self._view:getChildByName('click_mask')
    btn:setVisible(false)
    btn:addClickEventListenerWithSound(handler(self, self._onTalkClick))

    panel = self._view:getChildByName('bye_panel_container')
    panel = panel:getChildByName('bye_wife_panel')
    btn = panel:getChildByName('good_bye_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doWifeGoodBye))
    btn = panel:getChildByName('bye_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doWifeBye))

    panel = self._view:getChildByName('bye_panel_container')
    panel = panel:getChildByName('bye_bosom_panel')
    btn = panel:getChildByName('good_bye_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doBosomGoodBye))
    btn = panel:getChildByName('bye_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doBosomBye))

    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_DIVORCE, handler(self, self._onDivorceRet), '_onBosomWifeDivorce')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_PERSONAL_INFO, handler(self, self._onPersonalInfo), '_onTalkPersonalInfo')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_TALK, handler(self, self._onFriendTalk), '_onBosomFriendTalkInfo')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_MARRY_PROMISE, handler(self, self._onMarryPromise), '_onBosomMarryPromise')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_MARRY, handler(self, self._onMarry), '_onBosomMarry')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_FAMOUS_DEAL_WITH, handler(self, self._onBosomFriendDealWith), '_onBosomFriendDealWith')

    --network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_PERSONAL_INFO, {npc_id = self._id})

    if self._autoTalk then
        local panel = self._view:getChildByName('auto_searching')
        panel:setVisible(true)
        self._waveTimer = require('app/modules/bosom/WordWave'):create(panel, StaticData['local_text']['label.bosom.auto.searching'])
        uq.TimerProxy:addTimer(self._autoTalkTimerTag, talk_func, 0, 1)
        self._autoTalkTimer = true
    else
        if self._onlyTalk then
            talk_func()
        end
    end
end

function BosomInfoModule:_onMarry(evt)
    local data = evt.data
    self._marryRet = data.ret
    self._tempWifeId = data.npc_id
end

function BosomInfoModule:_onMarryPromise(evt)
    self._statusMarry = true
    local this = self
    local data = {
        content = string.format(StaticData['local_text']['bosom.notice.marry.promise'], this._template.name),
        confirm_callback = function()
            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_MARRY, {ret = 1})
        end,
        cancle_callback = function()
            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_MARRY, {ret = 0})
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_onDivorceRet(evt)
    if evt.data.ret == 0 then
        self:disposeSelf()
    end
end

function BosomInfoModule:_onBreakBeauty(evt)
    local data = evt.data
    uq.cache.role.bosom.bosoms[data.npc_id] = nil
    self:disposeSelf()
end

function BosomInfoModule:_sendWifeByeRequest(use_gold)
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_DIVORCE, {use_gold = use_gold})
end

function BosomInfoModule:_doWifeGoodBye(evt)
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 700) then
        return true
    end
    local this = self
    local cost = 0
    local gold_pay = StaticData['types'].GoldPay[1].Type
    if gold_pay[29] and gold_pay[29].value then
        cost = gold_pay[29].value
    end
    local data = {
        content = string.format(StaticData['local_text']['bosom.notice.divorce.friendly'], self._template.name, '<img img/common/ui/03_0003.png>', cost, self._template.name),
        confirm_callback = function()
            this:_sendWifeByeRequest(1)
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_doWifeBye(evt)
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 200) then
        return true
    end
    local this = self
    local cost = 0
    local gold_pay = StaticData['types'].GoldPay[1].Type
    if gold_pay[27] and gold_pay[27].value then
        cost = gold_pay[27].value
    end
    local data = {
        content = string.format(StaticData['local_text']['bosom.notice.divorce'], self._template.name, '<img img/common/ui/03_0003.png>', cost, self._template.name),
        confirm_callback = function()
            this:_sendWifeByeRequest(0)
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_sendBosomByeRequest(npc_id, op)
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_FAMOUS_DEAL_WITH, {op = op, npc_id = npc_id})
end

function BosomInfoModule:_doBosomGoodBye(evt)
    local need_coin = 0
    local tab_coin = StaticData['types'].GoldPay[1].Type[34]
    if tab_coin and tab_coin.value then
        need_coin = tab_coin.value
    end
    local str_format = StaticData['local_text']['bosom.notice.break.beauty.friendly']
    if uq.cache.formation:checkBosomStateById(self._template.ident) then
        str_format = str_format .. StaticData['local_text']['bosom.formation.bye']
    end
    local data = {
        content = string.format(str_format, self._template.name, '<img img/common/ui/03_0003.png>', need_coin, self._template.name),
        confirm_callback = function()
            if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, need_coin) then
                uq.fadeInfo(StaticData["local_text"]["label.common.not.enough.gold"])
                return true
            end
            self:_sendBosomByeRequest(self._id, -1)
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_doBosomBye(evt)
    local str_format = StaticData['local_text']['bosom.notice.break.beauty']
    if uq.cache.formation:checkBosomStateById(self._template.ident) then
        str_format = str_format .. StaticData['local_text']['bosom.formation.break']
    end
    local data = {
        content = string.format(str_format, self._template.name, self._template.name),
        confirm_callback = function()
            self:_sendBosomByeRequest(self._id, 0)
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_doBosomBecome(evt)
    local this = self
    local data = {
        content = string.format(StaticData['local_text']['bosom.change.bosom'], self._template.name, self._template.name),
        confirm_callback = function()
            this:_sendBosomByeRequest(this._id, 1)
        end
    }
    uq.addConfirmBox(data)
end

function BosomInfoModule:_onTalkClick(evt)
    if self._marquee then
        if not self._marquee:finished() then
            self._marquee:showAll()
            self._marquee:dispose()
            self._marquee = nil
            return
        end
        self._marquee:dispose()
        self._marquee = nil
    end
    local cb = handler(self, self.endTalk)
    if self._npcType == self.NPC_TYPE_WIFE and not self._onlyTalk then
        cb = handler(self, self._endWifeTalk)
    elseif self._npcType == self.NPC_TYPE_BOSOM then
        if self._tempWifeId > 0 then
            if self._marryTalkStep == 0 then
                cb = handler(self, self._beginMarryTalk)
                self._marryTalkStep = 1
            else
                cb = handler(self, self._endMarryTalk)
            end
        else
            if not self._onlyTalk then
                cb = handler(self, self._endBosomTalk)
            end
        end
    end
    self._talkTemp = nil
    if not cb then
        return
    end
    self:_hideTalkPanel(cb)
end

function BosomInfoModule:endTalk()
    if self._autoTalk then
        self:_autoFinishCB()
        return
    end
    self:disposeSelf()
end

function BosomInfoModule:_onFriendTalk(evt)
    local data = evt.data
    if data.op == 2 then
        return
    end
    local temp = StaticData['bosom']['women'][data.npc_id]
    if not temp then
        return
    end
    local add_exp = data.add_exp
    if data.op == 0 then
        add_exp = math.floor(add_exp / 2)
    end
    if not uq.cache.role.bosom.bosoms[data.npc_id] then
        uq.cache.role.bosom.bosoms[data.npc_id] = {lvl = 0, exp = 0, happy_lvl = 0, type = 0}
    end
    local npc = uq.cache.role.bosom.bosoms[data.npc_id]
    self:refreshNpcLvAndExp(npc,add_exp)
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_PERSONAL_INFO, {npc_id = data.npc_id})
    local function_type = 0
    if data.op == 0 then --talk
        if data.npc_id == uq.cache.role.bosom.wife_id then
            function_type = 1
        end
    elseif data.op == 1 then --famous
        function_type = 2
    end
    local talk_temp = nil
    if self._npcType == self.NPC_TYPE_WIFE or self._npcType == self.NPC_TYPE_BOSOM then
        local send_to = 0
        if self._npctype == self.NPC_TYPE_WIFE then
            send_to = 1
        end
        local talks = {}
        for _, v in pairs(StaticData['bosom']['talk']) do
            if v.functionType == function_type then
                if data.op == 1 then
                    if v.sendTo == send_to then
                        table.insert(talks, v)
                    end
                else
                    table.insert(talks, v)
                end
            end
        end
        if #talks > 0 then
            talk_temp = talks[math.random(#talks)]
        end
    else
        local dear_type = StaticData['bosom'].getDearType(npc.lvl)
        for _, v in pairs(StaticData['bosom']['talk']) do
            if v.functionType == function_type and v.temperaType == temp.temperaType and
                v.talkType == data.id and v.dear == dear_type then
                talk_temp = v
                break
            end
        end
    end
    if not talk_temp then
        return
    end
    self._talkTemp = talk_temp
    self._addExpTxt:setString("+"..add_exp)
    if self._npcType == self.NPC_TYPE_WIFE then
        self:_beginWifeTalk()
    elseif self._npcType == self.NPC_TYPE_BOSOM then
        self:_beginBosomTalk()
    elseif self._npcType == self.NPC_TYPE_TALK_LIST then
        self:_beginNPCTalkInList()
    end
    self:refreshAddUpLayer(add_exp)
end

function BosomInfoModule:_showWife()
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    local panel = self._view:getChildByName('base_info_panel')
    panel:setVisible(true)
    panel:getChildByName('satisfy_group'):setVisible(false)
    panel:getChildByName('cur_exp'):setVisible(false)
    self._showCurExp = false
    self:_showBaseInfo()

    panel = self._view:getChildByName('wife_attr_container')
    panel:setVisible(true)
    panel = panel:getChildByName('wife_attr_panel')
    local attr_panel = panel:getChildByName('cur_attr')
    local next_attr_panel = panel:getChildByName('next_attr')
    local attrs = StaticData['wife']['effect'][self._template.qualityType - 2]
    for i = 1, 6 do
        attr_panel:getChildByName('name' .. i):setString(StaticData['bosom']['attr_type'][i].name)
        attr_panel:getChildByName('value' .. i):setString(string.format('%+d%%', attrs[base_info.lvl] * 100))
        next_attr_panel:getChildByName('name' .. i):setString(StaticData['bosom']['attr_type'][i].name)
        if attrs[base_info.lvl + 1] then
            next_attr_panel:getChildByName('value' .. i):setString(string.format('%+d%%', attrs[base_info.lvl + 1] * 100))
        else
            next_attr_panel:getChildByName('value' .. i):setString('')
        end
    end

    if not self._onlyTalk then
        self._pnlAction2:setVisible(true)
        self._pnlFamous:setVisible(true)
        self._pnlByeWife:setVisible(true)
    end
    self:_showBodyImg()
end

function BosomInfoModule:_showBosom()
    self._pnlBaseInfo:setVisible(true)
    self._imgCurExp:setVisible(false)
    if not self._onlyTalk then
        self._pnlAttr:setVisible(true)
        self._pnlAction2:setVisible(true)
        self._pnlByeBye:setVisible(true)
        self._pnlFamous:setVisible(true)
    end
    self._showCurExp = false
    self:_showBaseInfo()
    self:_showAddupAttr()
    self:_showBodyImg()
end

function BosomInfoModule:_showBosomInTalk()
    self._pnlBaseInfo:setVisible(true)
    self._imgCurExp:setVisible(false)
    self._pnlAttr:setVisible(true)
    self._pnlAction:setVisible(false)
    self._btnAction3:setVisible(true)
    self._showCurExp = false
    self:_showBaseInfo()
    self:_showAddupAttr()
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    if base_info then
        if base_info.lvl and base_info.lvl >= self._limitLvl then
            self._txtRed2:setVisible(false)
            self._txtRed3:setVisible(false)
        end
        if base_info.type ~= uq.config.constant.BOSOM_TYPE.BEAUTY or uq.cache.role.bosom:getBosomsNum() >= 6 then
           self._btnAction3:setVisible(false)
        end
    end

    self:_showBodyImg()
end

function BosomInfoModule:_showBosomUnmeet()
    local panel = self._view:getChildByName('base_info_panel')
    panel:setVisible(true)
    panel:getChildByName('cur_exp'):setVisible(false)
    self._showCurExp = false
    self:_showBaseInfo()

    panel = self._view:getChildByName('attr_addup_panel')
    panel:setVisible(true)
    self:_showAddupAttr()

    panel = self._view:getChildByName('unmeet_panel')
    panel:setVisible(true)

    self._view:getChildByName('cross_red_img'):setVisible(true)

    panel = self._view:getChildByName('exchange_famous_btn')
    panel:setVisible(true)
    panel:setPosition(cc.p(panel:getPositionX() - 600, panel:getPositionY()))

    self:_showBodyImg()
end

function BosomInfoModule:_showAddupAttr()
    local attr_name = StaticData['bosom']['attr_type'][self._template.attrType].name
    self._txtNowName:setString(attr_name)
    self._txtNewName:setString(attr_name)

    self:_updateAddupAttrInfo()
end

function BosomInfoModule:_updateAddupAttrInfo()
    if not uq.cache.role.bosom.bosoms[self._id] then
        uq.cache.role.bosom.bosoms[self._id] = {lvl = 0, exp = 0, happy_lvl = 0, type = 0}
    end
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    local lvl = base_info.lvl or 0
    local happy_lvl = base_info.happy_lvl or 0
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    local attrs1 = string.splitString(self._template.effectValue, '|')
    local attrs2 = string.splitString(self._template.effectValue2, '|')
    local attr_val = string.format('%+d(%+d)', tonumber(attrs1[lvl + 1]), tonumber(attrs2[happy_lvl + 1]))

    local add_attr1 =  tonumber(attrs1[lvl + 1])
    if attrs1[lvl + 2] then
        add_attr1 = tonumber(attrs1[lvl + 2])
    end
    local add_attr2 = tonumber(attrs1[happy_lvl + 1])
    if attrs2[happy_lvl + 2] then
        add_attr2 = tonumber(attrs2[happy_lvl + 2])
    end
    local attr_next_val = string.format('%+d(%+d)', add_attr1, add_attr2)

    self._txtNow:setString(attr_val)
    self._txtNew:setString(attr_next_val)

    local quality = self:getQualityByLv(lvl)
    local tab_now  = StaticData['types'].DearType[1].Type[quality]
    if tab_now and tab_now.tagIcon then
        self._imgNowBg:loadTexture("img/bosom/" .. tab_now.tagIcon)
        self._txtNowDec:setString(tab_now.name)
    else
        self._pnlNow:setVisible(false)
    end
    local next_lvl_quality = self:getQualityByLv(lvl + 1)
    local tab_new = StaticData['types'].DearType[1].Type[next_lvl_quality]
    if tab_new and tab_new.tagIcon then
        self._imgNewBg:loadTexture("img/bosom/" .. tab_new.tagIcon)
        self._txtNewDec:setString(tab_new.name)
    elseif tab_now and tab_now.tagIcon then
        self._imgNewBg:loadTexture("img/bosom/" .. tab_now.tagIcon)
        self._txtNewDec:setString(tab_now.name)
    else
        self._pnlNew:setVisible(false)
    end
end

function BosomInfoModule:_showBaseInfo()
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    local name_pic = string.format('res/img/common/general_name/%s', self._template.nameImage)
    self._imgNamePic:loadTexture(name_pic, ccui.TextureResType.localType)
    if base_info then
        if not self._scale then
            local total_exp = StaticData['bosom']['level'][self._template.qualityType - 2][base_info.lvl]
            if total_exp then
                local scale = base_info.exp / total_exp
                scale = math.min(math.max(scale, 0), 1)
                self._prgHappy:setScaleX(scale)
                self._level = base_info.lvl
                self._scale = scale
            end
        end
        self._txtVal:setString(tostring(base_info.lvl))
        self._txtSatisfy:setString(tostring(base_info.happy_lvl or 0))
    else
        self._prgHappy:setScaleX(0)
        self._txtVal:setString("0")
        self._txtSatisfy:setString("0")
        self._level = 0
        self._scale = 0
    end
    self:refreshExpLayer()
end

function BosomInfoModule:_showBodyImg()
    local body_img = self._view:getChildByName('body_img')
    body_img:setVisible(true)
    body_img:ignoreContentAdaptWithSize(true)
    body_img:loadTexture(string.format('res/img/common/general_body/%s', self._template.imageId), ccui.TextureResType.localType)
end

function BosomInfoModule:_onPersonalInfo(evt)
    local data = evt.data
    local base_info = uq.cache.role.bosom.bosoms[data.npc_id]
    if not base_info then
        base_info = {}
        base_info.id = data.npc_id
        uq.cache.role.bosom.bosoms[data.npc_id] = base_info
    end
    base_info.lvl = data.level
    base_info.exp = data.exp
    base_info.happy_lvl = data.happy_level

    local panel = self._view:getChildByName('base_info_panel')
    panel:getChildByName('satisfy_group'):getChildByName('satisfy_val_txt'):setString(tostring(data.happy_level))
    self:_showBaseInfo()
    self:_updateAddupAttrInfo()
end

function BosomInfoModule:_beginWifeTalk()
    local dt = 0.2
    local container = self._view:getChildByName('wife_attr_container')
    local panel = container:getChildByName('wife_attr_panel')
    local action = cc.MoveTo:create(dt, cc.p(container:getContentSize().width, panel:getPositionY()))
    panel:runAction(action)

    container = self._view:getChildByName('bye_panel_container')
    panel = container:getChildByName('bye_wife_panel')
    action = cc.MoveTo:create(dt, cc.p(-panel:getContentSize().width, panel:getPositionY()))
    panel:runAction(action)

    panel = self._view:getChildByName('exchange_famous_btn')
    action = cc.FadeTo:create(dt, 0)
    panel:runAction(action)

    panel = self._view:getChildByName('action2_panel')
    action = cc.FadeTo:create(dt, 0)
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._showTalkPanel)))
    panel:runAction(action)
end

function BosomInfoModule:_endWifeTalk()
    local dt = 0.2
    local container = self._view:getChildByName('wife_attr_container')
    local panel = container:getChildByName('wife_attr_panel')
    local action = cc.MoveTo:create(dt, cc.p(0, panel:getPositionY()))
    panel:runAction(action)

    container = self._view:getChildByName('bye_panel_container')
    panel = container:getChildByName('bye_wife_panel')
    action = cc.MoveTo:create(dt, cc.p(50, panel:getPositionY()))
    panel:runAction(action)

    panel = self._view:getChildByName('exchange_famous_btn')
    action = cc.FadeTo:create(dt, 255)
    panel:runAction(action)

    panel = self._view:getChildByName('action2_panel')
    action = cc.FadeTo:create(dt, 255)
    panel:runAction(action)
end

function BosomInfoModule:_beginBosomTalk()
    local dt = 0.2
    local container = self._view:getChildByName('bye_panel_container')
    local panel = container:getChildByName('bye_bosom_panel')
    local action = cc.MoveTo:create(dt, cc.p(-panel:getContentSize().width, panel:getPositionY()))
    panel:runAction(action)

    panel = self._view:getChildByName('exchange_famous_btn')
    action = cc.FadeTo:create(dt, 0)
    panel:runAction(action)

    panel = self._view:getChildByName('action2_panel')
    action = cc.FadeTo:create(dt, 0)
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._showTalkPanel)))
    panel:runAction(action)
end

function BosomInfoModule:_endBosomTalk()
    local dt = 0.2
    local container = self._view:getChildByName('bye_panel_container')
    local panel = container:getChildByName('bye_bosom_panel')
    local action = cc.MoveTo:create(dt, cc.p(50, panel:getPositionY()))
    panel:runAction(action)

    panel = self._view:getChildByName('exchange_famous_btn')
    action = cc.FadeTo:create(dt, 255)
    panel:runAction(action)

    panel = self._view:getChildByName('action2_panel')
    action = cc.FadeTo:create(dt, 255)
    panel:runAction(action)
end

function BosomInfoModule:_showFather()
    local father = self._view:getChildByName('father_img')
    father:loadTexture('res/img/common/general_body/WJB03_0009.png', ccui.TextureResType.localType)
    father:setVisible(true)
    father:setOpacity(0)
    local action = cc.FadeTo:create(0.2, 255)
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._showTalkPanel)))
    father:runAction(action)
end

function BosomInfoModule:_beginMarryTalk()
    local talk_temp = nil
    for _, v in pairs(StaticData['bosom']['talk']) do
        if v.functionType == 6 and v.sendTo == self._marryRet then
            talk_temp = v
            break
        end
    end
    if not talk_temp then
        return
    end
    self._talkTemp = talk_temp
    local action = cc.MoveBy:create(0.2, cc.p(-100, 0))
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._showFather)))
    self._view:getChildByName('body_img'):runAction(action)
end

function BosomInfoModule:_playMarryFail()
end

function BosomInfoModule:_endMarryTalk()
    if self._marryRet == 1 then
        local wife_id = self._tempWifeId
        uq.cache.role.bosom.wife_id = self._tempWifeId
        self:disposeSelf()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_MARRY_MODULE, {id = wife_id})
        return
    end
    local father = self._view:getChildByName('father_img')
    father:setVisible(false)
    local action = cc.MoveBy:create(0.2, cc.p(100, 0))
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._playMarryFail)))
    self._view:getChildByName('body_img'):runAction(action)
end

function BosomInfoModule:_beginNPCTalkInList()
    local dt = 0.2
    local container = self._view:getChildByName('action_panel_container')
    local panel = container:getChildByName('action_panel')
    local action = cc.MoveTo:create(dt, cc.p(panel:getContentSize().width, panel:getPositionY()))
    panel:runAction(action)

    panel = self._view:getChildByName('exchange_famous_btn')
    action = cc.FadeTo:create(dt, 0)
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._showTalkPanel)))
    panel:runAction(action)
end

function BosomInfoModule:_endNPCTalkInList()
    --local dt = 0.2
    --local container = self._view:getChildByName('action_panel_container')
    --local panel = container:getChildByName('action_panel')
    --local action = cc.MoveTo:create(dt, cc.p(0, panel:getPositionY()))
    --panel:runAction(action)

    --panel = self._view:getChildByName('exchange_famous_btn')
    --action = cc.FadeTo:create(dt, 255)
    --panel:runAction(action)

    self:disposeSelf()
end

function BosomInfoModule:_showTalkPanel()
    local dt = 0.2
    local container = self._view:getChildByName('talk_words_container')
    self._view:getChildByName('click_mask'):setVisible(true)
    local panel = container:getChildByName('talk_words_panel')
    panel:getChildByName('words'):setString('')
    panel:setPosition(cc.p(panel:getPositionX(), -panel:getContentSize().height))
    local action = cc.MoveTo:create(dt, cc.p(panel:getPositionX(), 25))
    action = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._beginText)))
    panel:runAction(action)

end

function BosomInfoModule:_hideTalkPanel(cb)
    local dt = 0.2
    local container = self._view:getChildByName('talk_words_container')
    self._view:getChildByName('click_mask'):setVisible(false)
    local panel = container:getChildByName('talk_words_panel')
    panel:setPosition(cc.p(panel:getPositionX(), 25))
    local action = cc.MoveTo:create(dt, cc.p(panel:getPositionX(), -panel:getContentSize().height))
    action = cc.Sequence:create(action, cc.CallFunc:create(cb))
    panel:runAction(action)
end

function BosomInfoModule:_beginText()
    if not self._talkTemp then
        return
    end
    local container = self._view:getChildByName('talk_words_container')
    local panel = container:getChildByName('talk_words_panel')
    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end
    self._marquee = WordMarquee:create(panel:getChildByName('words'), self._talkTemp.talk, handler(self, self._onWordCB))
end

function BosomInfoModule:_onWordCB()
    if self._autoTalk then
        if not self._statusMarry then
            uq.TimerProxy:addTimer(self._autoTalkTimerTag, handler(self, self._autoFinishCB), 0.5, 1)
            self._autoTalkTimer = true
        else
            --结婚事件
            self._pnlAuto:setVisible(false)
            self._pnlclick:setVisible(true)
        end
    end
end

function BosomInfoModule:_autoFinishCB()
    self._autoTalkTimer = false
    self:disposeSelf()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
end

function BosomInfoModule:refreshNpcLvAndExp(info, add_exp)
    local tab_bosom = StaticData['bosom']['level'][self._template.qualityType - 2]
    local quality_old = self:getQualityByLv(info.lvl)
    local lv_exp = tab_bosom[info.lvl]
    local all_exp = info.exp + add_exp
    while(all_exp >= lv_exp)
    do
        all_exp = all_exp - lv_exp
        info.lvl = info.lvl + 1
        local now_exp = tab_bosom[info.lvl]
        if not now_exp then
            break
        end
        lv_exp = now_exp
    end
    info.exp = all_exp
    local quality_now = self:getQualityByLv(info.lvl)
    if quality_now > quality_old then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_QUALITY_UP,{quality_old = quality_old, quality_now = quality_now, name = self._template.name, auto_close = self._autoTalk})
    end
end

function BosomInfoModule:refreshAddUpLayer(add_exp)
    self._txtAddExp:stopAllActions()
    self._txtAddExp:setVisible(true)
    self._txtAddExp:setString("+" .. add_exp)
    local blick = cc.Blink:create(2, 5)
    local func = cc.CallFunc:create(function ()
        self._txtAddExp:setVisible(false)
    end)
    self._txtAddExp:runAction(cc.Sequence:create(blick, func, nil))
    local base_info = uq.cache.role.bosom.bosoms[self._id]
    if base_info and next(base_info) ~= nil then
        local total_exp = StaticData['bosom']['level'][self._template.qualityType - 2][base_info.lvl]
        if total_exp then
            local scale = base_info.exp / total_exp
            scale = math.min(math.max(scale, 0), 1)
            local  action = cc.ScaleTo:create(scale/4, scale, 1)
            if self._level then
                local add_lvl = base_info.lvl - self._level
                if add_lvl > 0 then
                    local scale1 = cc.ScaleTo:create(math.max(1 - self._scale, 0)/4, 1, 1)
                    local func1 = cc.CallFunc:create(function () self._prgHappy:setScaleX(0) end)
                    local scale2 = cc.ScaleTo:create(scale/4, scale, 1)
                    action = cc.Sequence:create(scale1, func1, scale2, nil)
                elseif add_lvl < 0 then
                    local scale3 = cc.ScaleTo:create(self._scale/4, 0, 1)
                    local func2 = cc.CallFunc:create(function () self._prgHappy:setScaleX(1) end)
                    local scale4 = cc.ScaleTo:create(math.max(1 - scale, 0)/4, scale, 1)
                    action = cc.Sequence:create(scale3, func2, scale4, nil)
                else
                    action = cc.ScaleTo:create( (scale - self._scale)/4, scale, 1)
                end
            end
            self._prgHappy:stopAllActions()
            self._prgHappy:runAction(action)
            self._level = base_info.lvl
            self._scale  = scale
        end
    end
    self:_showAddupAttr()
end

function BosomInfoModule:refreshExpLayer()
    if not uq.cache.role.bosom.bosoms[self._id] then
        uq.cache.role.bosom.bosoms[self._id] = {lvl = 0, exp = 0, happy_lvl = 0, type = 0}
    end

    local base_info = uq.cache.role.bosom.bosoms[self._id]
    if self._template and next(self._template) ~= nil then
        local lv_exp = StaticData['bosom']['level'][self._template.qualityType - 2][base_info.lvl]
        self._txtCurExp:setString(base_info.exp .. "/" .. lv_exp)
    end
end

function BosomInfoModule:getQualityByLv(lv)
    local quality = 1
    local tab_type = StaticData['types'].DearType[1].Type
    for i,v in ipairs(tab_type) do
        if v.rank > lv then
            break
        end
        quality = i
    end
    return quality
end

function BosomInfoModule:_onBosomFriendDealWith(evt)
    local data = evt.data
    if uq.cache.role.bosom.bosoms[data.npc_id] then
        if data.op > 0 then
            uq.cache.role.bosom.bosoms[data.npc_id].type = uq.config.constant.BOSOM_TYPE.BOSOM
            uq.cache.role.bosom:removeTalkId(data.npc_id)
        else
            uq.cache.role.bosom:removeTalkId(data.npc_id)
            uq.cache.role.bosom.bosoms[data.npc_id].type = uq.config.constant.BOSOM_TYPE.BEAUTY
            if data.op == 0 then
                uq.cache.role.bosom.bosoms[data.npc_id].lvl = uq.cache.role.bosom.bosoms[data.npc_id].lvl - 1
            end
        end
    end
    local temp = StaticData['bosom']['women'][data.npc_id]
    if temp and temp.name then
        if data.op > 0 then
            uq.fadeInfo(string.format(StaticData["local_text"]["bosom.become.bosom"], temp.name))
        elseif data.op == 0 then
            uq.fadeInfo(string.format(StaticData["local_text"]["bosom.leave.break"], temp.name))
        else
            uq.fadeInfo(string.format(StaticData["local_text"]["bosom.leave.bye"], temp.name))
        end
    end
    self:disposeSelf()
end

function BosomInfoModule:dispose()
    if self._func then
        self._func()
    end

    if self._marquee then
        self._marquee:dispose()
        self._marquee = nil
    end

    if self._waveTimer then
        self._waveTimer:dispose()
        self._waveTimer = nil
    end

    if self._autoTalkTimer then
        uq.TimerProxy:removeTimer(self._autoTalkTimerTag)
        self._autoTalkTimer = false
    end
    BosomInfoModule.super.dispose(self)
    display.removeUnusedSpriteFrames()

    network:removeEventListenerByTag('_onBosomWifeDivorce')
    network:removeEventListenerByTag('_onTalkPersonalInfo')
    network:removeEventListenerByTag('_onBosomFriendTalkInfo')
    network:removeEventListenerByTag('_onBosomMarryPromise')
    network:removeEventListenerByTag('_onBosomFriendDealWith')
end

return BosomInfoModule
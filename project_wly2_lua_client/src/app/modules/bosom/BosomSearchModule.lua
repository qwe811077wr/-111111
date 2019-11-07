local BosomSearchModule = class("BosomSearchModule", require('app.base.ModuleBase'))

BosomSearchModule.RESOURCE_FILENAME = "bosom/BosomSearchView.csb"
BosomSearchModule.RESOURCE_BINDING = {
    ["search_btn"]                = {["varname"] = "_btnSearch"},
    ["cd_time_txt"]               = {["varname"] = "_txtCdTime"},
    ["advance_search_oneky_txt"]  = {["varname"] = "_txtVipLimit"},
    ["advance_search_onekey_btn"] = {["varname"] = "_btnOneKey"},
    ["Image_3/Text_4"]            = {["varname"] = "_txtCost"},
}

function BosomSearchModule:ctor(name, params)
    BosomSearchModule.super.ctor(self, name, params)

    self._totalTalkNum = 10

    self._autoTalk = uq.cache.role.bosom.auto_talk_num > 0
    self._waveTimer = nil

    self._autoTalkTimerTag = '_onAutoTalkTimer' .. tostring(self)
    self._autoTalkTimer = false
    self._cdTimeTag = '_onTimeUpdate' .. tostring(self)

    self._isShowStop = false
    self._isCanBack = true
end

function BosomSearchModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()

    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:setTitle("g04_000000_0010_xf.png")
    self._topUI = top_ui
    top_ui:runActionTop()
    self._view:addChild(top_ui:getNode())
    self:refreshTopRes(true)
    top_ui:setCloseClick(function()
        if not self._isCanBack then
            self:showAutoStopLayer()
        else
            self:disposeSelf()
        end
    end)

    local this = self
    local btn = self._view:getChildByName('beauty_list_btn')
    btn:addClickEventListenerWithSound(function()
        this:disposeSelf()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_LIST_MODULE)
        end)

    self._oneLimit = self:getLimitVipLv(11)
    self._btnOneKey:setEnabled(uq.cache.role.vip_level >= self._oneLimit)
    self._btnOneKey:addClickEventListenerWithSound(handler(self, self._doAutoSearch))
    self._txtVipLimit:setVisible(uq.cache.role.vip_level < self._oneLimit)
    self._txtVipLimit:setString(string.format(StaticData["local_text"]["label.bosom.vip.available"], self._oneLimit))

    btn = self._view:getChildByName('advance_search_btn')
    btn:addClickEventListenerWithSound(handler(self, self._advanceSearch))

    btn = self._view:getChildByName('search_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doSearch))

    self._eventFriendTag = services.EVENT_NAMES.ON_CRROP_REFRESH_MY .. tostring(self)
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_TALK, handler(self, self._onFriendTalk), '_onBosomFriendTalk')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_SEARCH, handler(self, self._onSearch), '_onSearch')
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_FAMOUS_DEAL_WITH, handler(self, self._onBosomFriendDealWith), self._eventFriendTag)
    self:_updateView()

    if self._autoTalk then
        self:_startAutoSearch()
    end
    self:refreshAdvanceCost()
    uq.TimerProxy:addTimer(self._cdTimeTag, handler(self, self.refreshTimeCd), 1, -1)
end

function BosomSearchModule:_onSearch(evt)
    local data = evt.data
    uq.cache.role.bosom.place_id = data.place_id
    uq.cache.role.bosom.advance_search_num = data.advance_search_num
    uq.cache.role.bosom.talk_list = data.npcs
    if data.is_advance == 0 then
        uq.cache.role.bosom.cd_time = os.time() + bit.band(data.cd_time, 0x7FFFFFFF)
    end
    uq.cache.role.bosom:decAutoTalkNum()
    self:_updateView()
    if uq.cache.role.bosom.auto_talk_num > 0 then
        uq.TimerProxy:addTimer(self._autoTalkTimerTag, handler(self, self._doAutoTalk), 1, 1)
        self._autoTalkTimer = true
        self:refreshTopRes(false)
    else
        if self._autoTalk then
            self:_endAutoSearch()
        end
    end
    uq.fadeInfo(StaticData["local_text"]["label.find.bosom.success"])
    self:refreshAdvanceCost()
end

function BosomSearchModule:refreshTopRes(click)
    self._topUI:removeAllItems()
    self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, click))
    self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, click))
end
function BosomSearchModule:_doAutoTalk()
    if self._isShowStop then
        return
    end
    self._autoTalkTimer = false
    for i = 1, #uq.cache.role.bosom.talk_list do
        local id = uq.cache.role.bosom.talk_list[i]
        local temp = StaticData['bosom']['women'][id]
        if uq.cache.role.bosom.auto_talk_ids[id] and temp then
            local cost_talk = uq.cache.role.bosom:getTalkCost()
            if uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost_talk) then
                if temp.type == 1 then
                    uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_INFO_MODULE, {id = id, auto_talk = true, only_talk = true})
                    self:refreshTopRes(true)
                    self._isCanBack = false
                else
                    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_TALK, {npc_id = temp.ident, famous_id = -1, famous_num = 0})
                end
            else
                uq.fadeInfo(StaticData["local_text"]["bosom.talk.less.gold"])
                self:_endAutoSearch()
            end
            return
        end
    end
    if self:canAdvanceSearch() then
        network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_SEARCH, {is_advance = 1})
    else
        uq.fadeInfo(StaticData["local_text"]["bosom.search.less.gold"])
        self:_endAutoSearch()
    end
end

function BosomSearchModule:_doAutoSearch(evt)
    if uq.cache.role.bosom.auto_talk_num > 0 then
        self:_endAutoSearch()
    else
        --self:disposeSelf()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_AUTO_TALK_MODULE)
    end
end

function BosomSearchModule:_startAutoSearch()
    local btn = self._view:getChildByName('beauty_list_btn')
    btn:setEnabled(false)

    btn = self._view:getChildByName('advance_search_onekey_btn')
    btn:setTitleText(StaticData['local_text']['label.bosom.stop.auto.search'])

    btn = self._view:getChildByName('advance_search_btn')
    btn:setEnabled(false)

    btn = self._view:getChildByName('search_btn')
    btn:setEnabled(false)

    local container = self._view:getChildByName('auto_searching')
    container:setVisible(true)

    if self._waveTimer then
        self._waveTimer:dispose()
    end
    self._waveTimer = require('app/modules/bosom/WordWave'):create(self._view:getChildByName('auto_searching'),StaticData['local_text']['label.bosom.auto.searching'])

    uq.TimerProxy:addTimer(self._autoTalkTimerTag, handler(self, self._doAutoTalk), 1, 1)
    self._autoTalkTimer = true
    self:refreshTopRes(false)
    self._isCanBack = false
end

function BosomSearchModule:_endAutoSearch()
    local btn = self._view:getChildByName('beauty_list_btn')
    btn:setEnabled(true)

    btn = self._view:getChildByName('advance_search_onekey_btn')
    btn:setTitleText(StaticData['local_text']['label.bosom.one.key.talk'])

    btn = self._view:getChildByName('advance_search_btn')
    btn:setEnabled(true)

    btn = self._view:getChildByName('search_btn')
    btn:setEnabled(true)

    local container = self._view:getChildByName('auto_searching')
    container:setVisible(false)
    if self._waveTimer then
        self._waveTimer:dispose()
        self._waveTimer = nil
    end
    self._autoTalk = false
    uq.cache.role.bosom.auto_talk_num = 0
    uq.cache.role.bosom.auto_talk_ids = {}
    self:refreshTopRes(true)
    self._autoTalkTimer = false
    self._isCanBack = true
end

function BosomSearchModule:_advanceSearch(evt)
    if not self:canAdvanceSearch() then
        uq.fadeInfo(StaticData["local_text"]["bosom.search.less.gold"])
        return
    end
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_SEARCH, {is_advance = 1})
end

function BosomSearchModule:_doSearch(evt)
    if self._autoTalk then
        return
    end
    local left_time = uq.cache.role.bosom.cd_time - os.time()
    if left_time > 0 then
        local vip = self:getLimitVipLv(21)
        local data = {
            content = string.format(StaticData['local_text']['label.vip.no.cd'], vip),
            confirm_callback = function()
                uq.runCmd('show_add_golden')
            end
        }
        uq.addConfirmBox(data)
        return
    end
    if uq.cache.role.bosom:talkHaveWomen() then
        local data = {
            content = StaticData['local_text']['label.women.continue'],
            confirm_callback = function()
                network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_SEARCH, {is_advance = 0})
            end
        }
        uq.addConfirmBox(data)
        return
    end
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_SEARCH, {is_advance = 0}) -- 0 普通1 高级
end

local bit = require("bit")

function BosomSearchModule:_updateView()
    local talk_left_num = self._totalTalkNum - uq.cache.role.bosom.talk_num
    if talk_left_num < 0 then
        talk_left_num = 0
    end
    self._view:getChildByName('talk_num_txt'):setString(string.format("%d/%d", talk_left_num, self._totalTalkNum))
    self:refreshTimeCd()
    local list = self._view:getChildByName('beaty_list')
    list:removeAllChildren()
    local npc_num = #uq.cache.role.bosom.talk_list
    if npc_num > 0 then
        self._view:getChildByName('empty_bosom_notice'):setVisible(false)
        list:setVisible(true)
        local item_size = cc.size(0, 0)
        for i = 1, npc_num do
            local item = cc.CSLoader:createNode('bosom/BeautyNode.csb'):getChildByName('container')
            item:removeSelf()
            local size = item:getContentSize()
            item:setPosition(cc.p((i - 1) * (size.width + 50), size.height / 2))
            list:addChild(item)
            item:getChildByName('attr_img'):setVisible(false)
            item_size = size
            local temp = StaticData['bosom']['women'][uq.cache.role.bosom.talk_list[i]]
            if temp then
                item:getChildByName('name_txt'):setString(temp.name)
                local bg_path = string.format('res/img/bosom/%s', StaticData['bosom']['quality_type'][temp.qualityType].qualityIcon)
                item:getChildByName('bg'):loadTexture(bg_path, ccui.TextureResType.localType)
                local img_path = string.format('res/img/common/general_head/%s', temp.cardIcon)
                item:getChildByName('img'):loadTexture(img_path, ccui.TextureResType.localType)
                item_size = size
                item.data = temp
                if temp.attrType > 0 then
                    item:getChildByName('attr_img'):setVisible(true)
                    local label = item:getChildByName('attr_img'):getChildByName('attr_name_txt')
                    label:setString(StaticData['bosom']['attr_type'][temp.attrType].display)
                end
                item:addClickEventListenerWithSound(function(btn)
                    local data = btn.data
                    local temp = StaticData['bosom']['women'][data.ident]
                    if not temp then
                        return
                    end
                    local cost_talk = uq.cache.role.bosom:getTalkCost()
                    local talk_func = function ()
                        if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost_talk) then
                            uq.fadeInfo(StaticData["local_text"]["bosom.talk.less.gold"])
                            return
                        end
                        if temp.type == 1 then
                            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_INFO_MODULE, {id = temp.ident, only_talk = true})
                        else
                            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_TALK, {npc_id = temp.ident, famous_id = -1, famous_num = 0})
                        end
                    end
                    if cost_talk == 0 then
                        talk_func()
                        return
                    end
                    local data = {
                        content = string.format(StaticData['local_text']['bosom.talk.cost.gold'], '<img img/common/ui/03_0003.png>', cost_talk),
                        confirm_callback = function()
                            talk_func()
                        end
                    }
                    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BOSOM_TALK)
                end)

                local bosom_btn = item:getChildByName('Button_1')
                local info = uq.cache.role.bosom.bosoms[temp.ident]
                if info and info.lvl >= 15 and info.type == uq.config.constant.BOSOM_TYPE.BEAUTY then
                    bosom_btn:setVisible(true)
                end
                bosom_btn:setEnabled(uq.cache.role.bosom:getBosomsNum() < 6)
                bosom_btn:addClickEventListenerWithSound(function ()
                    local data = {
                        content = string.format(StaticData['local_text']['bosom.change.bosom'], temp.name, temp.name),
                        confirm_callback = function()
                            network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_FAMOUS_DEAL_WITH, {op = 1, npc_id = temp.ident})
                        end
                    }
                    uq.addConfirmBox(data)
                end)
            end
            item:setOpacity(0)
            item:runAction(cc.FadeIn:create(0.3))
        end
        list:setContentSize(cc.size(npc_num * item_size.width + (npc_num - 1) * 50, item_size.height))
        list:setPosition(cc.p(0, list:getPositionY()))
    else
        self._view:getChildByName('empty_bosom_notice'):setVisible(true)
        local list = self._view:getChildByName('beaty_list')
        list:setVisible(false)
    end
end

function BosomSearchModule:_onFriendTalk(evt)
    local data = evt.data
    local npc_id = data.npc_id
    if data.op == 1 then --famous
        return
    end
    if not uq.cache.role.bosom:removeTalkId(npc_id) then
        return
    end
    local temp = StaticData['bosom']['women'][npc_id]
    if not temp then
        return
    end
    if temp.type ~= 1 then
        local parts = string.splitString(temp.talk, '|')
        if #parts > 0 then
            local words = parts[math.random(#parts)]
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_NORMAL_TALK_MODULE, {id = npc_id, ['words'] = words, auto_talk = self._autoTalk})
            return
        end
    end
    self:_updateView()
end

function BosomSearchModule:_onBosomFriendDealWith(evt)
    local data = evt.data
    if uq.cache.role.bosom.bosoms[data.npc_id] and data.op > 0 then
        uq.cache.role.bosom.bosoms[data.npc_id].type = uq.config.constant.BOSOM_TYPE.BOSOM
        uq.cache.role.bosom:removeTalkId(data.npc_id)
    end
    local temp = StaticData['bosom']['women'][data.npc_id]
    if temp and temp.name and data.op > 0 then
        uq.fadeInfo(string.format(StaticData["local_text"]["bosom.become.bosom"], temp.name))
    end
    self:_updateView()
end

function BosomSearchModule:refreshTimeCd()
    local str = ""
    local left_time = uq.cache.role.bosom.cd_time - os.time()
    if left_time >= 0 then
        str = string.format("%02d:%02d:%02d", math.floor(left_time / 3600), math.floor(left_time % 3600 / 60), left_time % 60)
    end
    self._txtCdTime:setString(str)
end

function BosomSearchModule:refreshAdvanceCost()
    local cost = uq.cache.role.bosom:getSearchCost()
    self._txtCost:setString(tostring(cost))
end

function BosomSearchModule:showAutoStopLayer()
    local tab = {
        dec_down = StaticData["local_text"]["label.stop.auto"],
        func_ok = function ()
            self._isShowStop = false
            self:_endAutoSearch()
        end,
        func_cancel = function ()
            self._isShowStop = false
            uq.TimerProxy:addTimer(self._autoTalkTimerTag, handler(self, self._doAutoTalk), 1, 1)
        end
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.AGAIN_CONFIRM, tab)
    self._isShowStop = true
end

function BosomSearchModule:getLimitVipLv(id)
    local tab = StaticData['vip_func'][id]
    if tab and tab.VipFunc then
        local tab_char = string.split(tab.VipFunc, ",")
        for i,v in ipairs(tab_char) do
            if tonumber(v) == 1 then
                return i
            end
        end
    end
    return 0
end

function BosomSearchModule:canAdvanceSearch()
    local cost = uq.cache.role.bosom:getSearchCost()
    return uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost)
end

function BosomSearchModule:dispose()
    if self._topUI then
        self._topUI:dispose()
        self._topUI = nil
    end

    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end

    if self._waveTimer then
        self._waveTimer:dispose()
        self._waveTimer = nil
    end

    if self._autoTalkTimer then
        uq.TimerProxy:removeTimer(self._autoTalkTimerTag)
        self._autoTalkTimer = false
    end
    network:removeEventListenerByTag('_onBosomFriendTalk')
    network:removeEventListenerByTag('_onSearch')
    network:removeEventListenerByTag(self._eventFriendTag)
    uq.TimerProxy:removeTimer(self._cdTimeTag)
    BosomSearchModule.super.dispose(self)
end

return BosomSearchModule
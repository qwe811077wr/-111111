local BosomAutoSearchModule = class("BosomAutoSearchModule", require('app.base.PopupBase'))

local MAX_TALK_NUM = 99

BosomAutoSearchModule.RESOURCE_FILENAME = 'bosom/AutoTalkView.csb'

function BosomAutoSearchModule:ctor(name, params)
    BosomAutoSearchModule.super.ctor(self, name, params)
    self._talkNum = 1
    self._items = {}
    self._npcIds = {13, 23}
end

function BosomAutoSearchModule:init()
    self:addExceptNode(self._view:getChildByName('bg'))
    self:parseView()
    self:centerView()

    local this = self
    local slider = self._view:getChildByName('num_slider')
    slider:setScale9Enabled(true)
    slider:addEventListener(function(evt, evt_type)
        if evt_type ~= 0 then
            return
        end
        local percent_num = MAX_TALK_NUM * evt:getPercent() / 100
        local cur_num = math.ceil(percent_num)
        if cur_num > MAX_TALK_NUM then
            cur_num = MAX_TALK_NUM
        end
        this:_updateCurNum(cur_num, false)
    end)

    local btn = self._view:getChildByName('add_img')
    btn:addClickEventListenerWithSound(function(evt)
        local cur_num = self._talkNum
        if cur_num >= MAX_TALK_NUM then
            return
        end
        cur_num = cur_num + 1
        this:_updateCurNum(cur_num, true)
    end)

    btn = self._view:getChildByName('dec_img')
    btn:addClickEventListenerWithSound(function(evt)
        local cur_num = self._talkNum
        if cur_num <= 0 then
            return
        end
        cur_num = cur_num - 1
        this:_updateCurNum(cur_num, true)
    end)

    btn = self._view:getChildByName('cancel_btn')
    btn:addClickEventListenerWithSound(function(evt)
        this:disposeSelf()
    end)

    btn = self._view:getChildByName('ok_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doRequest))

    btn = self._view:getChildByName('help_btn')
    btn:addClickEventListenerWithSound(function()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_RULE_ADVANCE_SEARCH)
        end)

    this:_updateCurNum(self._talkNum, true)

    btn = self._view:getChildByName('select_orange_ck')
    btn:addEventListener(function(ck, et)
        local selected = et == 0
        for _, v in pairs(this._items) do
            if v.temp.qualityType == 3 then
                v:getChildByName('ck'):setSelected(selected)
            end
        end
    end)

    btn = self._view:getChildByName('npc_all_ck')
    btn:addEventListener(function(ck, et)
        local selected = et == 0
        for i = 1, 2 do
            this._view:getChildByName('npc' .. i .. '_ck'):setSelected(selected)
        end
    end)

    for i = 1, 2 do
        local temp = StaticData['bosom']['women'][self._npcIds[i]]
        btn = self._view:getChildByName('npc' .. i .. '_ck')
        btn.temp = temp
        btn:getChildByName('name'):setString(temp.name)
        btn:addEventListener(function(ck, et)
            if et == 1 then
                this._view:getChildByName('npc_all_ck'):setSelected(false)
                return
            end
            local select_all = true
            for j = 1, 2 do
                local ck = this._view:getChildByName('npc' .. j .. '_ck')
                if not ck:isSelected() then
                    select_all = false
                    break
                end
            end
            this._view:getChildByName('npc_all_ck'):setSelected(select_all)
        end)
    end

    local count = 0
    local list = self._view:getChildByName('beauty_list')
    local row = cc.CSLoader:createNode("bosom/NameRowItem.csb"):getChildByName('container')
    row:removeSelf()

    local tab_qulity = self.getSortQualityTab()
    for _,v in ipairs(tab_qulity) do
        local item = cc.CSLoader:createNode("bosom/NameItem.csb"):getChildByName('container')
        item:removeSelf()
        item.temp = v
        local name = item:getChildByName('name')
        name:setString(v.name)
        local tab_type = StaticData['types'].TalkQualityType[1].Type[v.qualityType]
        if tab_type and tab_type.color then
            name:setTextColor(uq.parseColor(tab_type.color))
        end
        self._items[v.ident] = item
        local size = item:getContentSize()
        item:setPosition(cc.p((count % 3) * size.width, 0))
        row:addChild(item)
        local ck = item:getChildByName('ck')
        ck:addEventListener(handler(self, self._onSelectName))
        count = count + 1
        if count % 3 == 0 then
            list:pushBackCustomItem(row)
            row = cc.CSLoader:createNode("bosom/NameRowItem.csb"):getChildByName('container')
            row:removeSelf()
        end
    end
end

function BosomAutoSearchModule:getSortQualityTab()
    local  tab = {}
    for _, v in pairs(StaticData['bosom']['women']) do
        if v.type == 1 then
            table.insert(tab,v)
        end
    end
    table.sort(tab,function (a, b)
        if a.qualityType == b.qualityType then
            return a.ident < b.ident
        end
        return a.qualityType > b.qualityType
    end)
    return tab
end

function BosomAutoSearchModule:_doRequest(evt)
    if self._talkNum <= 0 then
        uq.fadeInfo(StaticData["local_text"]["bosom.set.time"])
        return
    end
    local has_id = false
    local ids = {}
        for _, v in pairs(self._items) do
        if v:getChildByName('ck'):isSelected() then
            ids[v.temp.ident] = v.temp
            has_id = true
        end
    end
    for i = 1, 2 do
        local ck = self._view:getChildByName('npc' .. i .. '_ck')
        if ck:isSelected() then
            ids[ck.temp.ident] = ck.temp
            has_id = true
        end
    end
    if not has_id then
        uq.fadeInfo(StaticData["local_text"]["bosom.notice.no.select"])
        return
    end
    local cost = uq.cache.role.bosom:getNextSearchCostByTime(self._talkNum)
    local data = {
        content = string.format(StaticData["local_text"]["bosom.one.search.tips"], '<img img/common/ui/03_0003.png>', cost),
        confirm_callback = function()
            if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost) then
                uq.fadeInfo(StaticData["local_text"]["label.common.not.enough.gold"])
                return
            end
            uq.cache.role.bosom.auto_talk_num = self._talkNum
            uq.cache.role.bosom.auto_talk_ids = ids
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
            self:disposeSelf()
        end
    }
    uq.addConfirmBox(data)
end

function BosomAutoSearchModule:_onSelectName(ck, et)
    local select_all = true
    for _, v in pairs(self._items) do
        if v.temp.qualityType == 3 then
            if not v:getChildByName('ck'):isSelected() then
                select_all = false
                break
            end
        end
    end
    self._view:getChildByName('select_orange_ck'):setSelected(select_all)
end

function BosomAutoSearchModule:_updateCurNum(cur_num, update_slider)
    self._view:getChildByName('num_txt'):setString(string.format('%d/%d', cur_num, MAX_TALK_NUM))
    self._talkNum = cur_num
    if update_slider then
        local percent = cur_num * 100 / MAX_TALK_NUM
        self._view:getChildByName('num_slider'):setPercent(percent)
    end
end

function BosomAutoSearchModule:dispose()
    BosomAutoSearchModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return BosomAutoSearchModule
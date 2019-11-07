local BosomFamousModule = class("BosomFamousModule", require('app.base.PopupBase'))

BosomFamousModule.RESOURCE_FILENAME = "bosom/FamousView.csb"

function BosomFamousModule:ctor(name, params)
    BosomFamousModule.super.ctor(self, name, params)

    self._items = {}
    self._curItem = nil
    self._curNum = 0
    self._id = params.id
end

function BosomFamousModule:init()
    self:parseView()
    self:centerView()
    self:addExceptNode(self._view:getChildByName('bg'))

    local this = self
    local slider = self._view:getChildByName('num_slider')
    slider:setScale9Enabled(true)
    slider:addEventListener(function(evt, evt_type)
        if evt_type ~= 0 then
            return
        end
        local cur_item = this._curItem
        if not cur_item then
            return
        end
        local max_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, cur_item.temp.ident)
        local percent_num = (max_num - 1) * evt:getPercent() / 100
        local cur_num = math.floor(percent_num)
        cur_num = math.max(cur_num, 0) + 1
        this:_updateCurNum(cur_item.temp, cur_num, max_num, false)
    end)

    local btn = self._view:getChildByName('add_img')
    btn:addClickEventListenerWithSound(function(evt)
        local cur_item = this._curItem
        if not cur_item then
            return
        end
        local max_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, cur_item.temp.ident)
        local cur_num = self._curNum
        if cur_num >= max_num then
            return
        end
        cur_num = cur_num + 1
        this:_updateCurNum(cur_item.temp, cur_num, max_num, true)
    end)

    btn = self._view:getChildByName('dec_img')
    btn:addClickEventListenerWithSound(function(evt)
        local cur_item = this._curItem
        if not cur_item then
            return
        end
        local max_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, cur_item.temp.ident)
        local cur_num = self._curNum
        if cur_num <= 1 then
            return
        end
        cur_num = cur_num - 1
        this:_updateCurNum(cur_item.temp, cur_num, max_num, true)
    end)

    btn = self._view:getChildByName('cancel_btn')
    btn:addClickEventListenerWithSound(function(evt)
        this:disposeSelf()
    end)

    btn = self._view:getChildByName('ok_btn')
    btn:addClickEventListenerWithSound(handler(self, self._doRequest))

    self:_showItems()
end

function BosomFamousModule:_showItems()
    local count = 0
    local list = self._view:getChildByName('famous_list')
    local gap_size = 20
    local row = ccui.Layout:create()
    local cur_item = nil
    local tab_famous = uq.cache.role.bosom:getFamousRes()

    for k, v in pairs(tab_famous) do
        local temp = StaticData['material'][k]
        if temp and v ~= 0 then
            local item = cc.CSLoader:createNode("bosom/FamousItem.csb"):getChildByName('container')
            item:removeSelf()
            item.temp = temp
            item:getChildByName('num'):setString(v)
            item:getChildByName('icon'):loadTexture(string.format('res/img/common/item/%s', temp.icon), ccui.TextureResType.localType)
            self._items[temp.ident] = item
            local size = item:getContentSize()
            item:setPosition(cc.p((count % 4) * (size.width + gap_size) + gap_size, 0))
            row:addChild(item)
            item:addClickEventListenerWithSound(handler(self, self._updateCurItem))
            if not cur_item then
                cur_item = item
            end
            if count % 4 == 0 then
                local size = item:getContentSize()
                row:setContentSize(cc.size((size.width + gap_size) * 4, size.height + gap_size))
                list:pushBackCustomItem(row)
            end
            count = count + 1
            if count % 4 == 0 then
                row = ccui.Layout:create()
            end
        end
    end

    if not self._curItem and cur_item then
        self:_updateCurItem(cur_item)
    end
end

function BosomFamousModule:_updateCurItem(item)
    if self._curItem then
        self._curItem:getChildByName('glow'):setVisible(false)
    end
    self._curItem = item
    local cur_item_info = self._view:getChildByName('select_item')
    cur_item_info:setVisible(not not item)
    if not item then
        return
    end
    local temp = item.temp
    local max_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, temp.ident)
    local cur_num = 1
    if cur_num > max_num then
        cur_num = max_num
    end
    self._curItem:getChildByName('glow'):setVisible(true)
    cur_item_info:getChildByName('icon'):loadTexture(string.format('res/img/common/item/%s', temp.icon), ccui.TextureResType.localType)
    cur_item_info:getChildByName('num'):setString(max_num)
    self._view:getChildByName('name_txt'):setString(temp.name)
    self:_updateCurNum(temp, cur_num, max_num, true)
end

function BosomFamousModule:_updateCurNum(temp, cur_num, max_num, update_slider)
    self._view:getChildByName('cur_num'):setString(cur_num)
    self._view:getChildByName('addup_value'):setString(temp.effect * cur_num)
    self._curNum = cur_num
    local cur_num = cur_num - 1
    local max_num = max_num - 1
    if update_slider then
        local percent = 100
        if cur_num ~= max_num and max_num > 0  then
            percent = cur_num * 100 / max_num
        end
        self._view:getChildByName('num_slider'):setPercent(percent)
    end
    self._view:getChildByName('num_slider'):setEnabled(cur_num ~= max_num)
end

function BosomFamousModule:_doRequest(evt)
    local cur_item = self._curItem
    if not cur_item then
        return
    end
    local temp = cur_item.temp
    if not temp then
        return
    end
    local max_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, temp.ident)
    local cur_num = self._curNum
    if cur_num > max_num then
        cur_num = max_num
    end
    if cur_num <= 0 then
        return
    end
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_TALK, {npc_id = self._id, famous_id = temp.ident, famous_num = cur_num})
    self:disposeSelf()
end

function BosomFamousModule:dispose()
    BosomFamousModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return BosomFamousModule
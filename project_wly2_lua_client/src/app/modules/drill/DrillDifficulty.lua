local DrillDifficulty = class("DrillDifficulty", require('app.base.PopupBase'))

DrillDifficulty.RESOURCE_FILENAME = "drill/DrillDifficulty.csb"
DrillDifficulty.RESOURCE_BINDING = {
    ["Node_1"]                                 = {["varname"] = "_nodeBase"},
    ["ListView_1"]                             = {["varname"] = "_listView"},
}

function DrillDifficulty:ctor(name, param)
    DrillDifficulty.super.ctor(self, name, param)
    self._data = param.data or {}
    self._mode = self._data.Mode or {}
end

function DrillDifficulty:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._addBoxs = {}
    self._lastCardId = uq.cache.drill:getFinishMaxCardByid(self._data.ident)
    self:initLayer()
    self._onEvenDrill = "_onDrillEnter" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_ENTER, handler(self, self._onDrillEnter), self._onEvenDrill)
end

function DrillDifficulty:initLayer()
    self._listView:setScrollBarEnabled(false)
    for i, v in ipairs(self._mode) do
        self:addOneBoxs(i, v)
    end
    self._listView:addEventListener(handler(self, self._itemSelectLeft))
end

function DrillDifficulty:addOneBoxs(idx, info)
    local item_temp = cc.CSLoader:createNode('drill/DifficultyBoxs.csb')
    local item = item_temp:getChildByName('Panel_1')
    item:removeFromParent()
    self._addBoxs[idx] = item
    self._listView:pushBackCustomItem(item)
    local txt_title = item:getChildByName("title_txt")
    local txt_exp = item:getChildByName("exp_txt")
    local txt_add = item:getChildByName("exp_add")
    local spr_icon = item:getChildByName("Sprite_1")
    local img_lock = item:getChildByName("img_lock")
    local txt_lock = img_lock:getChildByName("exp_limit")
    item.img_lock = img_lock
    local is_lock = false
    local limit_str = ""
    if info.levelLimit > uq.cache.role:level() then
        is_lock = true
        limit_str = string.format(StaticData['local_text']["drill.need.lv"], info.levelLimit)
    elseif info.levelLimit <= uq.cache.role:level() and self._lastCardId + 1 < idx then
        is_lock = true
        limit_str = StaticData['local_text']["drill.need.finish.last"]
    end
    txt_title:setHTMLText(info.name, nil, true)
    txt_lock:setString(limit_str)
    txt_add:setString("+" .. info.expUp * 100 .. "%")
    txt_exp:setVisible(not is_lock)
    txt_add:setVisible(not is_lock)
    img_lock:setVisible(is_lock)
    if info.nameImage then
        spr_icon:setTexture("img/daily_instance/" .. info.nameImage)
    end
end

function DrillDifficulty:_itemSelectLeft(list, evt)
    if evt ~= 1 then
        return
    end
    local list = self._listView
    local data = self._mode
    local idx = list:getCurSelectedIndex()
    if idx < 0 then
        return
    end
    if not data[idx + 1] then
        return
    end
    if self._addBoxs[idx + 1].img_lock:isVisible() then
        return
    end
    network:sendPacket(Protocol.C_2_S_DRILL_GROUND_ENTER, {id = self._data.ident, mode = idx + 1})
end

function DrillDifficulty:_onDrillEnter(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    local data = {
        xml_data = self._data,
        cur_mode = data.mode
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_CARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = data})
    self:disposeSelf()
end

function DrillDifficulty:dispose()
    network:removeEventListenerByTag(self._onEvenDrill)
    DrillDifficulty.super.dispose(self)
end

return DrillDifficulty
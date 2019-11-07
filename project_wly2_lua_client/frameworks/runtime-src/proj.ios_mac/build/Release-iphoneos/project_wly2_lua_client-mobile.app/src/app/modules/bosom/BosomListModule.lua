local BosomListModule = class("BosomListModule", require('app.base.ModuleBase'))

BosomListModule.RESOURCE_FILENAME = "bosom/BeautyListView.csb"
BosomListModule.RESOURCE_BINDING = {
    ["xf_btn"]             = {["varname"] = "_btnXf"},
    ["attr_btn"]           = {["varname"] = "_btnAtt"},
    ["return_btn"]         = {["varname"] = "_btnReturn"},
    ["beauty_list"]        = {["varname"] = "_listBeauty"},
    ["normal_beauty_list"] = {["varname"] = "_listNormal"},
    ["Text_2_0"]           = {["varname"] = "_txtOwnNum"},
    ["Text_2_0_0"]         = {["varname"] = "_txtAllNum"},
}

function BosomListModule:ctor(name, params)
    BosomListModule.super.ctor(self, name, params)
end

function BosomListModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    self._bosoms = {}
    self._npcs = {}
    self:refreshListData()
    self:refreshListUi()
    self._listBeauty:setScrollBarEnabled(false)
    self._listNormal:setScrollBarEnabled(false)
    self._btnXf:addClickEventListenerWithSound(function()
        self:disposeSelf()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_SEARCH_MODULE)
        end)
    self._btnReturn:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
    self._btnAtt:addClickEventListenerWithSound(function()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_ATTR_MODULE)
    end)
end

function BosomListModule:refreshListData()
    local bosoms = {}
    local npcs = {}

    for _, v in pairs(StaticData['bosom']['women']) do
        if v.type == 1 and v.ident ~= uq.cache.role.bosom.wife_id then
            local npc = {lvl = 0, exp = 0, temp = v, id = v.ident}
            local data = uq.cache.role.bosom.bosoms[v.ident]
            if data then
                npc.lvl = data.lvl
                npc.exp = data.exp
            end
            if uq.cache.role.bosom.bosoms[v.ident] and uq.cache.role.bosom.bosoms[v.ident].type == uq.config.constant.BOSOM_TYPE.BOSOM then
                table.insert(bosoms, npc)
            elseif v.ident ~= uq.cache.role.bosom.wife_id then
                table.insert(npcs, npc)
            end
        end
    end

    local sort_func = function(a, b)
        if a.lvl ~= b.lvl then
            return a.lvl > b.lvl
        end
        if a.exp ~= b.exp then
            return a.exp > b.exp
        end
        return a.temp.qualityType > b.temp.qualityType
    end
    table.sort(bosoms, sort_func)
    table.sort(npcs, sort_func)
    self._bosoms = bosoms
    self._npcs = npcs
end

function BosomListModule:refreshListUi()
    self._listBeauty:removeAllChildren()
    self._listNormal:removeAllChildren()
    local bosom_num = 0
    for _, v in pairs(self._bosoms) do
        local item = cc.CSLoader:createNode('bosom/BeautyListNode.csb'):getChildByName('container')
        item:removeSelf()
        local temp = v.temp
        item:getChildByName('name_txt'):setString(temp.name)
        local str = v.lvl .. StaticData['local_text']['label.lv.txt']
        item:getChildByName('level_txt'):setString(str)
        local bg_path = string.format('res/img/bosom/%s', StaticData['bosom']['quality_type'][temp.qualityType].qualityIcon2)
        item:getChildByName('bg'):loadTexture(bg_path, ccui.TextureResType.localType)
        local img_path = string.format('res/img/common/general_head/%s', temp.icon)
        item:getChildByName('img'):loadTexture(img_path, ccui.TextureResType.localType)
        if temp.attrType > 0 then
            local label = item:getChildByName('attr_img'):getChildByName('attr_name_txt')
            label:setString(StaticData['bosom']['attr_type'][temp.attrType].display)
        else
            item:getChildByName('attr_img'):setVisible(false)
        end
        item.data = temp
        item:addClickEventListenerWithSound(function(btn)
            local func = function ()
                self:refreshListData()
                self:refreshListUi()
            end
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_INFO_MODULE, {id = btn.data.ident, func = func})
        end)
        self._listBeauty:pushBackCustomItem(item)
        bosom_num = bosom_num +1
    end
    self._txtOwnNum:setString(tostring(bosom_num))
    self._txtAllNum:setString("/6")

    for _, v in pairs(self._npcs) do
        local item = cc.CSLoader:createNode('bosom/BeautyListNode.csb'):getChildByName('container')
        item:removeSelf()
        local temp = v.temp
        item:getChildByName('name_txt'):setString(temp.name)
        local bg_path = string.format('res/img/bosom/%s', StaticData['bosom']['quality_type'][temp.qualityType].qualityIcon2)
        item:getChildByName('bg'):loadTexture(bg_path, ccui.TextureResType.localType)
        local img_path = string.format('res/img/common/general_head/%s', temp.icon)
        item:getChildByName('img'):loadTexture(img_path, ccui.TextureResType.localType)
        if v.lvl == 0 and v.exp == 0 then
            item:getChildByName('level_txt'):setVisible(false)
        else
            local str = v.lvl .. StaticData['local_text']['label.lv.txt']
            item:getChildByName('level_txt'):setString(str)
        end
        if temp.attrType > 0 then
            local label = item:getChildByName('attr_img'):getChildByName('attr_name_txt')
            label:setString(StaticData['bosom']['attr_type'][temp.attrType].display)
        else
            item:getChildByName('attr_img'):setVisible(false)
        end
        item.data = temp
        item:addClickEventListenerWithSound(function(btn)
            local func = function ()
                self:refreshListData()
                self:refreshListUi()
            end
            uq.ModuleManager:getInstance():show(uq.ModuleManager.BOSOM_INFO_MODULE, {id = btn.data.ident, form_bosom = true, func = func})
        end)
        self._listNormal:pushBackCustomItem(item)
    end
end

function BosomListModule:dispose()
    BosomListModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return BosomListModule
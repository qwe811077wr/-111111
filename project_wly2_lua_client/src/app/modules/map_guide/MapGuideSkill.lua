local MapGuideSkill = class("MapGuideSkill", require('app.base.PopupBase'))
local MapGuideSkillItem = require("app.modules.map_guide.MapGuideSkillItem")

MapGuideSkill.RESOURCE_FILENAME = "map_guide/MapGuideSkill.csb"
MapGuideSkill.RESOURCE_BINDING = {
    ["ScrollView_1"]           = {["varname"] = "_scrollView"},
    ["btn_close"]              ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
}

function MapGuideSkill:ctor(name, args)
    MapGuideSkill.super.ctor(self, name, args)
    self._curDataArray = {}
end

function MapGuideSkill:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initData()
end

function MapGuideSkill:initData()
    uq.cache.illustration.isActive = false
    uq.cache.illustration:updateRed()
    self._curDataArray = {}
    local data = uq.cache.illustration.illustration_info
    local total_exp = data.total_exp
    local state = 0
    if StaticData['Illustration'].Stage[0].exp <= total_exp then
        state = 1
    end
    local cur_exp = StaticData['Illustration'].Stage[0].exp
    total_exp = total_exp - StaticData['Illustration'].Stage[0].exp
    for k, v in ipairs(StaticData['Illustration'].Stage) do
        local info = {}
        info.xml = v
        info.state = state
        info.cur_exp = cur_exp
        if v.exp <= total_exp then
            state = 1   --已激活
        else
            state = 0
        end
        cur_exp = cur_exp + v.exp
        total_exp = total_exp - v.exp
        table.insert(self._curDataArray, info)
    end
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local item_pos_y = #self._curDataArray * 124
    local item_size = self._scrollView:getContentSize()
    if item_pos_y < item_size.height then
        item_pos_y = item_size.height
    end
    self._scrollView:setInnerContainerSize(cc.size(item_size.width, item_pos_y))
    local euqip_item = nil
    local item_pos_x = 0
    item_pos_y = item_pos_y - 124
    for k, txt in ipairs(self._curDataArray) do
        euqip_item = MapGuideSkillItem:create({info = txt})
        euqip_item:setPosition(cc.p(item_pos_x, item_pos_y))
        self._scrollView:addChild(euqip_item)
        item_pos_y = item_pos_y - 124
    end
end

function MapGuideSkill:dispose()
    MapGuideSkill.super.dispose(self)
end
return MapGuideSkill
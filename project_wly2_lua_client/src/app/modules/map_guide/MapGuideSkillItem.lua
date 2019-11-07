local MapGuideSkillItem = class("MapGuideSkillItem", function()
    return ccui.Layout:create()
end)

function MapGuideSkillItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function MapGuideSkillItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("map_guide/MapGuideSkillItem.csb")
        self._view = node:getChildByName("Panel_1")
        self._view:removeSelf()
        self:addChild(self._view)
    end
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0, 0))
    self._titleLabel = self._view:getChildByName("lbl_title");
    self._jihuoImg = self._view:getChildByName("img_active");
    self._valueLabel1 = self._view:getChildByName("lbl_value1");
    self._desLabel1 = self._view:getChildByName("lbl_des1");
    self._valueLabel2 = self._view:getChildByName("lbl_value2");
    self._desLabel2 = self._view:getChildByName("lbl_des2");
    self._valueArray = {self._valueLabel1, self._valueLabel2}
    self._desArray = {self._desLabel1, self._desLabel2}
    self._notActiveLabel = self._view:getChildByName("lbl_not_active");
    self._notActiveLabel:setString(StaticData["local_text"]["map.guide.des16"])
    self:initInfo()
end

function MapGuideSkillItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function MapGuideSkillItem:initInfo()
    self._titleLabel:setHTMLText(string.format(StaticData["local_text"]["map.guide.des21"], self._info.xml.color, self._info.xml.name, self._info.cur_exp))
    local attr_array = string.split(self._info.xml.attribute, ";")
    local index = 1
    for k, v in ipairs(attr_array) do
        local attr = string.split(v, ",")
        local label_value = self._valueArray[k]
        if not label_value then
            break
        end
        local label_des = self._desArray[k]
        label_value:setVisible(true)
        label_des:setVisible(true)
        local type_xml = StaticData['types'].Effect[1].Type[tonumber(attr[1])]
        label_des:setString(string.format(StaticData["local_text"]["map.guide.des"], type_xml.name))
        label_value:setString("+" .. uq.cache.generals:getNumByEffectType(tonumber(attr[1]), tonumber(attr[2])))
        index = index + 1
    end
    for k = index, 2, 1 do
        if self._valueArray[k] then
            self._valueArray[k]:setVisible(false)
        end
        if self._desArray[k] then
            self._desArray[k]:setVisible(false)
        end
    end
    self._jihuoImg:setVisible(self._info.state == 1)
    self._notActiveLabel:setVisible(self._info.state ~= 1)
end

return MapGuideSkillItem
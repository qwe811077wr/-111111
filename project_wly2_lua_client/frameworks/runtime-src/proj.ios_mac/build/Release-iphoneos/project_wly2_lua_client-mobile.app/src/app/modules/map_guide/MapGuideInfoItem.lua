local MapGuideInfoItem = class("MapGuideInfoItem", function()
    return ccui.Layout:create()
end)

function MapGuideInfoItem:ctor(args)
    self._view = nil
    self:init()
end

function MapGuideInfoItem:init()
    if not self._view then
        local cs_name = string.format("map_guide/MapGuideInfoItem1.csb")
        local node = cc.CSLoader:createNode(cs_name)
        self._view = node:getChildByName("Panel_1")
        self._view:removeSelf()
        self:addChild(self._view)
    end
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0, 0))

    self._nameLabel = self._view:getChildByName("lbl_name");
    self._selectImg = self._view:getChildByName("img_select");
    self._redImg = self._view:getChildByName("Image_red");
    self._iconImg = self._view:getChildByName("Panel_4"):getChildByName("img_icon");
end

function MapGuideInfoItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function MapGuideInfoItem:getInfo()
    return self._info
end

function MapGuideInfoItem:initInfo()
    if not self._info then
        return
    end
    local generals_xml = StaticData['general'][self._info.generalId * 10 + 1]
    local grade_info = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
    local quality_info = StaticData['types'].ItemQuality[1].Type[grade_info.qualityType]
    if quality_info and quality_info.color then
        self._nameLabel:setTextColor(uq.parseColor(quality_info.color))
    end
    self._nameLabel:setString(generals_xml.name)
    self._iconImg:loadTexture("img/common/general_head/" .. generals_xml.miniIcon)
    local ShaderEffect = uq.ShaderEffect
    if self._info.state >= 4 or self._info.state == 0 then
        ShaderEffect:removeGrayNode(self._iconImg)
    else
        ShaderEffect:addGrayNode(self._iconImg)
    end
    self._redImg:setVisible(self._info.state >= 4)
end

function MapGuideInfoItem:showSelect(visible)
    self._selectImg:setVisible(visible)
end

return MapGuideInfoItem
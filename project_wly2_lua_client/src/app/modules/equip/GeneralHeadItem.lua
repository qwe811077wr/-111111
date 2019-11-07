local GeneralHeadItem = class("GeneralHeadItem", function()
    return ccui.Layout:create()
end)

function GeneralHeadItem:ctor(args)
    self._view = nil
    self._generalInfo = args and args.info
    self:init()
end

function GeneralHeadItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("equip/GeneralHeadItem.csb")
        self._view = node:getChildByName("Panel_3")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgSelect = self._view:getChildByName("img_select");
    self._imgBg = self._view:getChildByName("img_bg");
    self._imgIcon = self._view:getChildByName("Panel_1"):getChildByName("img_icon");
    self._imgZhen = self._view:getChildByName("img_zhen");
    self._levelLabel = self._view:getChildByName("lbl_level");
    self._nameLabel = self._view:getChildByName("lbl_name");
    self:initInfo()
end

function GeneralHeadItem:setInfo(general_info)
    self._generalInfo = general_info
    self:initInfo()
end

function GeneralHeadItem:initInfo()
    if self._generalInfo == nil then
        return
    end
    self._levelLabel:setString(string.format(StaticData['local_text']['label.level'], self._generalInfo.lvl))
    self._nameLabel:setString(self._generalInfo.name)
    self:setSelectImgVisible(false)
    if uq.cache.formation:checkGeneralIsInFormationById(self._generalInfo.id) then
        self._imgZhen:setVisible(true)
    else
        self._imgZhen:setVisible(false)
    end
    if self._generalInfo.xml == nil then
        self._generalInfo.xml = StaticData['general'][self._generalInfo.temp_id]
    end
    local rgeneral_xml = StaticData['general'][self._generalInfo.rtemp_id]
    if not rgeneral_xml then
        return
    end
    self._imgIcon:loadTexture("img/common/general_head/" .. rgeneral_xml.icon)
    local type_info = StaticData['types'].ItemQuality[1].Type[self._generalInfo.xml.qualityType]
    if type_info then
        self._imgBg:loadTexture("img/embattle/" .. type_info.headQuality)
    end
end

function GeneralHeadItem:setSelectImgVisible(isvisible)
    local scale = isvisible and 1.0 or 0.9
    self:setScale(scale)
end

function GeneralHeadItem:setHeadImgState(isvisible, scale)
    self._imgSelect:setVisible(isvisible)
    local scale = scale and scale or 1
    self._view:setScale(scale)
end

return GeneralHeadItem
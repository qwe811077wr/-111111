local DraftGeneralHeadItem = class("DraftGeneralHeadItem", function()
    return ccui.Layout:create()
end)

function DraftGeneralHeadItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function DraftGeneralHeadItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("fly_nail/GeneralHeadItem.csb")
        self._view = node:getChildByName("Panel_3")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self._view:setAnchorPoint(cc.p(0,0))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgIcon = self._view:getChildByName("Panel_14"):getChildByName("Sprite_1")
    self._imgAdd = self._view:getChildByName("Image_add");
    self._imgLock = self._view:getChildByName("Image_lock");
    self._nodeData = self._view:getChildByName("Node_data");
    self._lvlLabel = self._nodeData:getChildByName("Text_level");
    self._starNode = self._nodeData:getChildByName("Node_1");
    self._starArray = {}
    for i = 1, 5 do
        local star = self._starNode:getChildByName("star_" .. i)
        table.insert(self._starArray, star)
    end
    self:initInfo()
end

function DraftGeneralHeadItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function DraftGeneralHeadItem:initInfo()
    if self._info == nil then
        return
    end
    self._imgIcon:setVisible(self._info.general_info ~= nil)
    self._nodeData:setVisible(self._info.general_info ~= nil)
    self._imgAdd:setVisible(self._info.general_info == nil and not self._info.lock)
    self._imgLock:setVisible(self._info.lock)
    for i = 1, #self._starArray, 1 do
        self._starArray[i]:setVisible(false)
    end
    if self._info.general_info == nil then
        return
    end
    if self._info.general_info.xml == nil then
        local temp_id = self._info.general_info.temp_id or self._info.general_info.general_id
        self._info.general_info.xml = StaticData['general'][temp_id]
    end

    local rgeneral_xml = StaticData['general'][self._info.general_info.rtemp_id]
    self._imgIcon:setTexture("img/common/general_head/" .. rgeneral_xml.miniIcon)
    local level = self._info.general_info.lvl or self._info.general_info.level
    self._lvlLabel:setString(level)
    local star_num = self._info.general_info.xml.qualityType
    for i = 1, star_num, 1 do
        self._starArray[i]:setVisible(true)
    end
    for i = star_num + 1, 5, 1 do
        self._starArray[i]:setVisible(false)
    end
end

return DraftGeneralHeadItem
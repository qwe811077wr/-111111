local FlyNailSelectItem = class("FlyNailSelectItem", function()
    return ccui.Layout:create()
end)

local DraftGeneralHeadItem = require("app.modules.equip.DraftGeneralHeadItem")

function FlyNailSelectItem:ctor(args)
    self:enableNodeEvents()
    self._view = nil
    self._curGeneralInfo = args and args.info
    self:init()
end

function FlyNailSelectItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("fly_nail/FlyNailSelectItem.csb")
        self._view = node:getChildByName("Panel_8")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._view:getChildByName("txtSoldier_0"):setString(StaticData['local_text']['fly.nail.item.des8'])
    self._txtSoldier = self._view:getChildByName("txtSoldier")
    self._headNode = self._view:getChildByName("head_node")
    self._typeImg1 = self._view:getChildByName("Image_type1")
    self._typeImg2 = self._view:getChildByName("Image_type2")
    self._nameLabel = self._view:getChildByName("soldier_name")
    self._btnCollect = self._view:getChildByName("Button_collect")
    self._btnCollect:setTouchEnabled(true)
    self._btnCollect:addClickEventListener(function(sender)
        if self._callBack then
            self._callBack(self._curGeneralInfo)
        end
    end)
    self:setSlidetData()
end

function FlyNailSelectItem:setSelectGeneral(general_id1, general_id2)
    if self._curGeneralInfo and (self._curGeneralInfo.id == general_id1 or self._curGeneralInfo.id == general_id2) then
        self._btnCollect:getChildByName("txtcollect"):setString(StaticData['local_text']['fly.nail.item.des6'])
    else
        self._btnCollect:getChildByName("txtcollect"):setString(StaticData['local_text']['fly.nail.item.des7'])
    end
end

function FlyNailSelectItem:setCallBack(call_back)
    self._callBack = call_back
end

function FlyNailSelectItem:setInfo(info)
    self._curGeneralInfo = info
    self:setSlidetData()
end

function FlyNailSelectItem:setSlidetData()
    if not self._curGeneralInfo then
        return
    end
    self._headNode:removeAllChildren()
    local general_data = uq.cache.generals:getGeneralDataByID(self._curGeneralInfo.id)
    self._headItem = DraftGeneralHeadItem:create()
    self._headItem:setInfo({general_info = general_data})
    self._headNode:addChild(self._headItem)
    local info = StaticData['advance_levels'][general_data.advanceLevel]
    self._txtSoldier:setString(info.name)
    local soldier_xml1 = StaticData['soldier'][general_data.soldierId1]
    local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
    self._typeImg1:loadTexture("img/generals/" .. type_solider1.miniIcon2)
    local soldier_xml2 = StaticData['soldier'][general_data.soldierId2]
    local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
    self._typeImg2:loadTexture("img/generals/" .. type_solider2.miniIcon2)
    local general_xml = StaticData['general'][general_data.rtemp_id]
    self._nameLabel:setString(general_data.name)
end

function FlyNailSelectItem:getInfo()
    return self._curGeneralInfo
end

return FlyNailSelectItem

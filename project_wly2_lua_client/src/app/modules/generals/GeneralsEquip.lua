local GeneralsEquip = class("GeneralsEquip", require("app.base.TableViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsEquip.RESOURCE_FILENAME = "generals/GeneralsEquip.csb"

GeneralsEquip.RESOURCE_BINDING  = {
    ["btn_change"]        ={["varname"] = "_btnChange",["events"] = {{["event"] = "touch",["method"] = "onBtnChange",["sound_id"] = 0}}},
    ["btn_xiexia"]        ={["varname"] = "_btnUnload",["events"] = {{["event"] = "touch",["method"] = "onBtnUnload",["sound_id"] = 0}}},
    ["btn_equip"]         ={["varname"] = "_btnEquip",["events"] = {{["event"] = "touch",["method"] = "onBtnEquip",["sound_id"] = 0}}},
    ["Node_8"]            ={["varname"] = "_nodeEquip"},
    ["Button_17"]         ={["varname"] = "_btnAttribute",["events"] = {{["event"] = "touch",["method"] = "onShowAttribute",["sound_id"] = 0}}},
    ["Image_7"]           ={["varname"] = "_imgBg"},
    ["Panel_2"]           ={["varname"] = "_panelBase"},
}

function GeneralsEquip:ctor(name, args)
    GeneralsEquip.super.ctor(self)
    GeneralsEquip._equipType = {
        1,      --武器
        3,      --坐骑
        4,      --兵书
        6,      --盾牌
        5,      --披风
        2,      --防具
        7,      --宝物
    }
end

function GeneralsEquip:onShowAttribute(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_ATTRIBUTE_MODULE, {id = self._curGeneralInfo.id})
    local pos = self._panelBase:convertToWorldSpace(cc.p(self._imgBg:getPosition()))
    local size = self._imgBg:getContentSize()
    panel:setPosition(cc.p(pos.x - size.width + 50, pos.y))
end

function GeneralsEquip:init()
    self:parseView()
    self._curGeneralInfo = {}
    self._equipArray = {}
    self._nodeEffect = {}
    self._selectEquipItem = nil
    self:initUi()
    self:initProtocal()
    self:initBtnListener()
end

function GeneralsEquip:initUi()
    for i = 1, 7, 1 do
        local equip = self._nodeEquip:getChildByName("Node_" .. i)
        self["_nodeEquip" .. i] = equip
        equip:removeAllChildren()
        table.insert(self._equipArray, equip)
    end
    for i = 1, 7, 1 do
        local node = self._nodeEquip:getChildByName("Node_"..i.."_0")
        self._nodeEffect[self._equipType[i]] = node
    end
end

function GeneralsEquip:onBtnChange(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
    local info = uq.cache.generals:getAllGeneralData()
    local index = 0
    if not info then
        index = 0
    else
        for _, v in pairs(info) do
            index = index + 1
            if index > 1 then
                break
            end
        end
    end
    if index < 2 then
        uq.fadeInfo(StaticData["local_text"]["general.no.change.res"])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EUQIP_REPLACE_MODULE, {general_id = self._curGeneralInfo.id})
end

function GeneralsEquip:onBtnUnload(event)
    if event.name ~= "ended" then
        return
    end
    local ishave = false
    for k, v in ipairs(self._equipType) do
        local info = uq.cache.equipment:getInfoByTypeAndGeneralId(v, self._curGeneralInfo.id)
        if info ~= nil then
            ishave = true
            uq.playSoundByID(49)
            network:sendPacket(Protocol.C_2_S_UNEQUIP_ITEM, {general_id = self._curGeneralInfo.id, item_id = -1})
            break
        end
    end
    if not ishave then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["equip.no.unload.res"])
    end
end

function GeneralsEquip:onBtnEquip(event)
    if event.name ~= "ended" then
        return
    end


    if #self._allCanAddItem == 0 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["equip.no.equip.res"])
    else
        uq.playSoundByID(52)
        for i = #self._allCanAddItem + 1, 7 , 1 do
            table.insert(self._allCanAddItem, 0)
        end
        network:sendPacket(Protocol.C_2_S_BATCH_EQUIP_ITEMS, {general_id = self._curGeneralInfo.id, equip_ids = self._allCanAddItem})
    end
end

function GeneralsEquip:getAllCanAddItem()
    self._allCanAddItem = {}
    local arr_suit = uq.cache.equipment:getGeneralsSuitId(self._curGeneralInfo.id)
    local pre_info = nil
    for k, v in ipairs(self._equipType) do
        local info = uq.cache.equipment:getInfoByTypeAndGeneralId(v, self._curGeneralInfo.id)

        if info and info.xml.suitId then
            arr_suit[info.xml.suitId] = arr_suit[info.xml.suitId] - 1
        end

        local type_info = uq.cache.equipment:getChangeEquipInfo(v, self._curGeneralInfo.lvl, arr_suit)
        if type_info ~= nil and (info == nil or info.xml.effectValue < type_info.xml.effectValue) then
            if type_info.xml.suitId then
                local state = arr_suit[type_info.xml.suitId] and arr_suit[type_info.xml.suitId] > 0
                arr_suit[type_info.xml.suitId] = state and arr_suit[type_info.xml.suitId] + 1 or 1
            end
            table.insert(self._allCanAddItem, type_info.db_id)
        elseif info ~= nil then
            arr_suit[info.xml.suitId] = arr_suit[info.xml.suitId] + 1
        end
    end
    self._btnEquip:setVisible(#self._allCanAddItem ~= 0)
    self._btnUnload:setVisible(#self._allCanAddItem == 0)
end

function GeneralsEquip:initBtnListener()
    self._btnUnload:setPressedActionEnabled(true)
    self._btnEquip:setPressedActionEnabled(true)
    self._btnChange:setPressedActionEnabled(true)
end

function GeneralsEquip:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALEFF, handler(self,self._onShowEquipEffect), "_onShowEquipEffect")
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS, handler(self,self._onUpdateDialog), "_onUpdateDialog")
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO, handler(self,self._onInitDialog), "_onInitDialogByEquip")
    services:addEventListener(services.EVENT_NAMES.ON_ALL_EQUIPMENT, handler(self,self._onAllEquipment), "_onAllEquipment")
    services:addEventListener(services.EVENT_NAMES.ON_CLOSE_EQUIP_SELECT_STATE, handler(self,self._closeSelectState), "_closeSelectState")
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERAL_ATTE_BY_EQUIPMENT, handler(self, self.runAttrUpdateAction), "_onUpdateAttrInfo" .. tostring(self))
end

function GeneralsEquip:_closeSelectState()
    if self._selectEquipItem then
        self._selectEquipItem:setSelectImgVisible(false)
        self._selectEquipItem = nil
    end
end

function GeneralsEquip:_onInitDialog(evt)--切换tab时，如果界面首次打开需要传入数据
    services:removeEventListenersByTag("_onInitDialogByEquip")
    self._curGeneralInfo = evt.data
    self:updateEquip()
end

function GeneralsEquip:_onShowEquipEffect(msg)
    for k, v in ipairs(msg.data) do
        local data = uq.cache.equipment:_getEquipInfoByDBId(v)
        local xml_data = data.xml
        if xml_data == nil  then
            xml_data = StaticData['items'][data.temp_id]
        end
        uq:addEffectByNode(self._nodeEffect[xml_data.type], 900010, 1, true)
    end
end

function GeneralsEquip:_onAllEquipment()
    self:updateEquip()
end

function GeneralsEquip:_onUpdateDialog(evt)
    self._curGeneralInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateEquip()
    else
        self._isChangeInfo = true
    end
end

function GeneralsEquip:update(param)
    if self._isChangeInfo then
        self._isChangeInfo = false
        self:updateEquip()
    end
end

function GeneralsEquip:updateEquip()
    for k, v in ipairs(self._equipType) do
        local info = uq.cache.equipment:getInfoByTypeAndGeneralId(v, self._curGeneralInfo.id)
        local item = self._equipArray[k]:getChildByName("equip_item")
        if item == nil then
            item = EquipItem:create()
            item:setName("equip_item")
            item:setScale(0.8)
            self._equipArray[k]:addChild(item)
        end
        if info == nil then
            info = {id = v, type = uq.config.constant.EQUIPITEM_TYPE.TYPES_ITEM}
            item:setInfo(info)
            item:setImgNameVisible(false, false)
            local type_info = uq.cache.equipment:getInfoByType(v, self._curGeneralInfo.lvl)
            if type_info ~= nil and #type_info > 0 then
                item:setAddImgVisible(true)
            end
        else
            info.type = uq.config.constant.COST_RES_TYPE.EQUIP
            info.id = info.temp_id
            item:setInfo(info)
            item:showStrengthImg()
            item:setImgNameVisible(true, true)

            local arr_suit = uq.cache.equipment:getGeneralsSuitId(info.general_id)
            if info.xml.suitId then
                arr_suit[info.xml.suitId] = arr_suit[info.xml.suitId] - 1
            end
            local max_info = uq.cache.equipment:getChangeEquipInfo(v, self._curGeneralInfo.lvl, arr_suit)
            if max_info ~= nil and max_info.xml.effectValue > info.xml.effectValue then
                item:setChangeImgVisible(true)
            end
        end
        item:setLockedImgState(false)
        item:showName(false)
        item:setTouchEnabled(true)
        item:addClickEventListener(handler(self, self._onTouchEquipItem))
    end
    self:getAllCanAddItem()
end

function GeneralsEquip:runAttrUpdateAction()
    local info = uq.cache.generals._generalAttrChange
    if not info[self._curGeneralInfo.id] then
        return
    end
    local arr_attr = info[self._curGeneralInfo.id]
    local pos = self._view:convertToWorldSpace(cc.p(self._panelBase:getPosition()))
    local pos_y = -220
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_MODULE)
    if not panel then
        return
    end
    local zOrder = panel:zOrder()
    for k, v in pairs(arr_attr) do
        local xml_data = StaticData['types'].Effect[1].Type[k]
        if not xml_data then
            return
        end
        local value = uq.cache.generals:getNumByEffectType(k, math.abs(v))
        local str = v > 0 and "+ " or "- "
        uq.fadeAttr(xml_data.name .. str .. value, pos.x / 2, display.height / 2 + pos_y, "#ffff00", 28, "fzzzhjt.ttf", zOrder)
        pos_y = pos_y + 50
    end
end

function GeneralsEquip:_onTouchEquipItem(sender)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    if not uq.cache.generals:getGeneralDataByID(self._curGeneralInfo.id) then
        uq.fadeInfo(StaticData["local_text"]["general.collect.equip.des"])
        return
    end
    local equip_info = sender:getEquipInfo()
    self._selectEquipItem = sender
    if equip_info.type == uq.config.constant.EQUIPITEM_TYPE.TYPES_ITEM then
        local type_info = uq.cache.equipment:getInfoByType(equip_info.id)
        if type_info == nil or #type_info == 0 then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_EQUIP_RESOURCE_MODULE, {info = equip_info, type = equip_info.id})
            return
        end
        sender:setSelectImgVisible(true)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_EQUIP_BAG_MODULE, {info = equip_info, generals_id = self._curGeneralInfo.id, type = 0})
    else
        sender:setSelectImgVisible(true)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_EQUIP_INFO_MODULE, {info = equip_info, generals_id = self._curGeneralInfo.id})
    end
end

function GeneralsEquip:dispose()
    uq.AnimationManager:getInstance():releaseEffect('txf_0_1')
    services:removeEventListenersByTag("_onUpdateDialog")
    services:removeEventListenersByTag("_onInitDialogByEquip")
    services:removeEventListenersByTag("_onAllEquipment")
    services:removeEventListenersByTag("_onShowEquipEffect")
    services:removeEventListenersByTag("_closeSelectState")
    services:removeEventListenersByTag("_onUpdateAttrInfo" .. tostring(self))
end

return GeneralsEquip
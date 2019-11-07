local GeneralsQuality = class("GeneralsQuality", require("app.base.TableViewBase"))

GeneralsQuality.RESOURCE_FILENAME = "generals/GeneralsQuality.csb"
GeneralsQuality.RESOURCE_BINDING  = {
    ["Panel_2"]                                   ={["varname"] = "_pnlBase"},
    ["Button_1"]                                  ={["varname"] = "_btnOk"},
    ["Panel_2/Node_1"]                            ={["varname"] = "_pnlAtt"},
    ["Panel_2/Text_18_0"]                         ={["varname"] = "_txtNextLv"},
    ["Panel_2/lv_bg1"]                            ={["varname"] = "_imgBg1"},
    ["Panel_2/lv_bg1/Text_20"]                    ={["varname"] = "_txtBgAdd1"},
    ["Panel_2/lv_bg1/Text_19"]                    ={["varname"] = "_txtBg1"},
    ["Panel_2/lv_bg1_0"]                          ={["varname"] = "_imgBg2"},
    ["Panel_2/lv_bg1_0/Text_20"]                  ={["varname"] = "_txtBgAdd2"},
    ["Panel_2/lv_bg1_0/Text_19"]                  ={["varname"] = "_txtBg2"},
    ["Panel_2/Node_2/item_node1"]                 ={["varname"] = "_pnlStone1"},
    ["Panel_2/Node_2/item_node2"]                 ={["varname"] = "_pnlStone2"},
    ["Panel_2/Node_2/item_node3"]                 ={["varname"] = "_pnlStone3"},
    ["Panel_2/Node_2/item_node4"]                 ={["varname"] = "_pnlStone4"},
    ["title_txt"]                                 ={["varname"] = "_txtTitle"},
    ["max_node"]                                  ={["varname"] = "_nodeMax"},
}
function GeneralsQuality:ctor(name, args)
    GeneralsQuality.super.ctor(self)
end

function GeneralsQuality:init()
    self:parseView()

    self._allPos = 4
    self._curGeneralInfo = {}
    self._allPropId = {}
    for i = 1, self._allPos do
        self._allPropId[i] = {["type"] = 0, num = 0, id = 0}
    end
    self:initLayer()
    self:initProtocal()
end

function GeneralsQuality:initLayer()
    for i = 1, self._allPos do
        self["_pnlStone" .. i]:getChildByName("btn_click"):addClickEventListenerWithSound(function()
            if self._allPropId[i].id == 0 then
                return
            end
            local tab = {
                type     = uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL,
                id       = self._allPropId[i].id,
                general_info = self._curGeneralInfo,
                totalNum = self._allPropId[i].num,
            }
            uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, tab)
        end)
    end
    self._btnOk:addClickEventListenerWithSound(function()
        if uq.cache.generals:getGeneralIsHaveByID(self._curGeneralInfo.id) and self:isCanCompose() then
            self:sendQualityUpMsg()
            return
        end
        uq.fadeInfo(StaticData["local_text"]["general.up.not.enought"])
        return
    end)
end

function GeneralsQuality:initProtocal()
    self._eventAdvance = '_onGeneralAdvance' .. tostring(self)
    self._eventChange = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. tostring(self)
    self._eventDialog = services.EVENT_NAMES.ON_CHANGE_GENERALS .. tostring(self)
    self._eventArms = services.EVENT_NAMES.ON_INIT_GENERALS_INFO .. tostring(self)
    network:addEventListener(Protocol.S_2_C_GENERAL_ADVANCE, handler(self, self._onGeneralAdvance), self._eventAdvance)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self._onResChange), self._eventChange)
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS, handler(self,self._onUpdateDialog), self._eventDialog)
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO, handler(self,self._onInitDialog), self._eventArms)
end

--进阶消息回调
function GeneralsQuality:_onGeneralAdvance(evt)
    local data = evt.data
    if evt.data.general_id ~= self._curGeneralInfo.id then
        return
    end
    local tab_advance = StaticData['advance_levels'] or {}
    if tab_advance and tab_advance[data.advance_level] and tab_advance[data.advance_level].attributes then
        local att_tab = self:getFixedAttTab(tab_advance[data.advance_level].attributes)
        local info = {}
        for k, v in ipairs(att_tab) do
            table.insert(info, v.name .. "+" .. v.value)
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_QUALITY_UP_ACTION, data = info})
    end
    self:updateBaseInfo()
end

function GeneralsQuality:_onResChange(evt)
    self:updateBaseInfo()
end


function GeneralsQuality:_onUpdateDialog(evt)
    self._curGeneralInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateBaseInfo()
    else
        self._isChangeInfo = true
    end
end

function GeneralsQuality:_onInitDialog(evt)
    services:removeEventListenersByTag(self._eventArms)
    self._curGeneralInfo = evt.data
    self:updateBaseInfo()
end

function GeneralsQuality:update(param)
    if self._isChangeInfo then
        self._isChangeInfo = false
        self:updateBaseInfo()
    end
end

function GeneralsQuality:updateBaseInfo()
    local general_id = self._curGeneralInfo.id
    if self._curGeneralInfo.advanceLevel == nil then
        self._curGeneralInfo.advanceLevel = 1
    end
    local quality = self._curGeneralInfo.advanceLevel
    local now_color = 1
    local next_color = 1
    local next_quality = quality
    local tab_color = StaticData['types'].AdvanceLevel[1].Type
    local data_colorType = StaticData['advance_levels'] or {}
    if data_colorType[quality + 1] then
        next_quality = quality + 1
    end
    self._btnOk:setVisible(true)
    local is_max = self._curGeneralInfo.advanceLevel and not StaticData['advance_levels'][self._curGeneralInfo.advanceLevel + 1]
    if data_colorType[quality] then
        local str_str, str_add = self:getStrNameTab(data_colorType[quality].name)
        self._txtBg1:setString(str_str)
        self._txtBgAdd1:setString(str_add)
        self._txtNextLv:setString(string.format(StaticData["local_text"]["general.need.lv"], data_colorType[quality].level))
        local is_limit = self._curGeneralInfo.lvl <  data_colorType[quality].level and not is_max
        self._txtNextLv:setVisible(is_limit)
        self._btnOk:setVisible(not is_limit)
        local att_tab = self:getFixedAttTab(data_colorType[quality].attributes)
        local att_next_tab = self:getFixedAttTab(data_colorType[next_quality].attributes)
        for i = 1, 7 do
            if att_tab[i] and att_next_tab[i] then
                self._pnlAtt:getChildByName("name_" .. i .. "_txt"):setString(att_tab[i].name)
                if is_max then
                    self._pnlAtt:getChildByName("old_" .. i .. "_txt"):setHTMLText(string.format(StaticData["local_text"]["general.att.add1"], att_tab[i].value))
                else
                    self._pnlAtt:getChildByName("old_" .. i .. "_txt"):setHTMLText(string.format(StaticData["local_text"]["general.att.add"], att_tab[i].value, att_next_tab[i].value))
                end
            else
                self._pnlAtt:getChildByName("name_" .. i .. "_txt"):setString("")
                self._pnlAtt:getChildByName("old_" .. i .. "_txt"):setString("")
            end
        end
        now_color = data_colorType[quality].color
    end
    self._txtBg1:setTextColor(uq.parseColor("#" .. tab_color[now_color].color))
    self._txtBgAdd1:setTextColor(uq.parseColor("#" .. tab_color[now_color].color))
    if data_colorType[next_quality] then
        local str_str, str_add = self:getStrNameTab(data_colorType[next_quality].name)
        self._txtBg2:setString(str_str)
        self._txtBgAdd2:setString(str_add)
        next_color = data_colorType[next_quality].color
    end
    self._txtBg2:setTextColor(uq.parseColor("#" .. tab_color[next_color].color))
    self._txtBgAdd2:setTextColor(uq.parseColor("#" .. tab_color[next_color].color))
    self:refreshStoneStatus()
    local str_title = is_max and StaticData["local_text"]["general.now.quality"] or StaticData["local_text"]["general.next.adavance"]
    self._txtTitle:setString(str_title)
    self._nodeMax:setVisible(is_max)
    self._btnOk:setEnabled(not is_max)
    if is_max then
        uq.ShaderEffect:addGrayButton(self._btnOk)
    else
        uq.ShaderEffect:removeGrayButton(self._btnOk)
    end
end

function GeneralsQuality:refreshStoneStatus()
    local general_own = uq.cache.generals:getGeneralIsHaveByID(self._curGeneralInfo.id)
    if not general_own then
        return
    end
    local quality = self._curGeneralInfo.advanceLevel
    local max_slot = self:getTabSlot(quality)
    for i = 1, self._allPos do
        local tab = {["type"] = 0, num = 0, id = 0}
        if i <= #max_slot then
            tab = max_slot[i]:toEquipWidget()
        end
        self._allPropId[i] = tab
        self:refreshStoneUi(tab, i)
    end
end

function GeneralsQuality:refreshStoneUi(info, index)
    self["_pnlStone" .. index]:setVisible(info.type ~= 0)
    if info.type == 0 then
        return
    end
    local spr_bg = self["_pnlStone" .. index]:getChildByName("bg_spr")
    local spr_icon = self["_pnlStone" .. index]:getChildByName("Sprite_1")
    local num_show = self["_pnlStone" .. index]:getChildByName("num_txt")
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL, info.id)
    local str = ""
    if num >= info.num then
        str = "<font color=#37F413>" .. num.. "/" .. info.num .. "</font>"
    else
        str = "<font color=#f30b0b>" .. num .. "</font>".. "<font color=#FFFFFF>" .. "/" .. info.num .. "</font>"
    end
    num_show:setHTMLText(str)
    local tab_prop = StaticData['advance_data'][info.id] or {}
    if tab_prop and next(tab_prop) ~= nil then
        spr_icon:setTexture("img/common/item/" .. tab_prop.icon)
        local info = StaticData['types'].ItemQuality[1].Type[tonumber(tab_prop.qualityType)]
        if info and info.qualityIcon then
            spr_bg:setTexture("img/common/ui/" .. info.qualityIcon)
        end
    end
end

function GeneralsQuality:sendQualityUpMsg()
    network:sendPacket(Protocol.C_2_S_GENERAL_ADVANCE,{general_id = self._curGeneralInfo.id})
end

function GeneralsQuality:getTabSlot(quality)
    local quality = quality or 1
    local consume = StaticData['advance_levels'][quality].consume
    local tab_list = uq.RewardType.parseRewards(consume) or {}
    return tab_list
end

function GeneralsQuality:getFixedAttTab(str)
    if str == nil or str == "" then
        return {}
    end
    local tab = {}
    local str_tab = string.split(str, ";")
    for i, v in ipairs(str_tab) do
        local str_str = string.split(v, ",")
        if str_str[2] then
            local tab_types = StaticData['bosom']['attr_type'][tonumber(str_str[1])]
            if tab_types and tab_types.display then
                table.insert(tab, {type = tonumber(str_str[1]), value = tonumber(str_str[2]), name = tab_types.display})
            end
        end
    end
    return tab
end

function GeneralsQuality:getStrNameTab(str)
    local str = str or ""
    local str_len = string.len(str)
    local str_str = str
    local str_add = ""
    if str_len > 3 then
        str_str = string.sub(str, 1, 3)
        str_add = string.sub(str, 4, str_len)
    end
    return str_str, str_add
end

function GeneralsQuality:isCanCompose()
    local lvl = self._curGeneralInfo.lvl
    local quality_type = self._curGeneralInfo.advanceLevel or 1
    local tab_info = StaticData['advance_levels'][quality_type]
    if not tab_info or next(tab_info) == nil or tab_info.level > lvl  then
        return false
    end
    local use_num = {}
    for i, v in ipairs(self._allPropId) do
        if not use_num[v.id] then
            use_num[v.id] = 0
        end
        local num = use_num[v.id] + v.num
        if not uq.cache.role:checkRes(v.type, num, v.id) then
            return false
        end
        use_num[v.id] = num
    end
    return true
end

function GeneralsQuality:dispose()
    network:removeEventListenerByTag(self._eventAdvance)
    services:removeEventListenersByTag(self._eventChange)
    services:removeEventListenersByTag(self._eventDialog)
    services:removeEventListenersByTag(self._eventArms)
end

return GeneralsQuality
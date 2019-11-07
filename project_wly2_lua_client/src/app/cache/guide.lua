local Guide = class('Guide')

function Guide:ctor()
    self._allLoadingGuide = {}
    self._finishGuide = {}
    self._isShow = true
    self._isRunGuide = false
    self._closeMapMove = false
    self._closeMapScale = false
    self._nowGuideId = 0
    self._lastGuideId = 0
    self._tabForce = StaticData['guide'].Guide or {}
    self._tabTrigger = StaticData['guide'].GuideTwo or {}
    self._tabAllGuide = StaticData['guide'].ForceGuide or {}
    network:addEventListener(Protocol.S_2_C_GUIDE_LOAD, handler(self, self._onGuideLoad), '_onGuideLoad')
    self.guide_close = cc.UserDefault:getInstance():getBoolForKey("guide_state")
end

function Guide:setShow(is_bool)
    self._isShow = is_bool
end

function Guide:_onGuideLoad(evt)
    local data = evt.data or {}
    self._finishGuide = data.ids or {}
    self._isRunGuide = true
    self:refreshToNextGuide()
end

function Guide:closeGuideById(id)
    local origin = self:getGuideOriginById(id)
    if origin ~= 0 and self._allLoadingGuide[origin] then
        self._allLoadingGuide[origin] = 0
    end
    local origin = self:getGuideOriginById(id)
    if origin and origin ~= 0 then
        table.insert(self._finishGuide, origin)
    end
    self:setMainCityMapNotMove(false)
    self._nowGuideId = 0
    network:sendPacket(Protocol.C_2_S_FINISH_GUIDE, {id = origin})
end

function Guide:refreshGuideById(id)
    self:getNextGuideByid()
    self:closeGuideById(id)
end

function Guide:isFinishGuide(id)
    for k, v in pairs(self._finishGuide) do
        if v == id then
            return true
        end
    end
    return false
end

function Guide:openGuide(id)
    local tab = self:getGuideInfoById(id)
    if not tab or next(tab) == nil then
        return
    end
    if self:isFinishGuide(id) then
        return
    end
    self:refreshGuideOriginToId(tab.ident)
    local str = uq.ModuleManager:getInstance():getTopLayerName()
    self:sendGuideEvent(str)
end

function Guide:setMainCityMapNotMove(is_bool)
    self._closeMapMove = is_bool
    self._closeMapScale = is_bool
end

function Guide:setGuideForceId(id)
    self._nowGuideId = id
end

function Guide:refreshGuideOriginToId(id)
    local origin = self:getGuideOriginById(id)
    if not origin or origin == 0 then
        return
    end
    self._allLoadingGuide[origin] = id
end

function Guide:addNewGuideById(id)
    local origin = self:getGuideOriginById(id)
    if not origin or origin == 0 then
        return
    end
    if self._allLoadingGuide[origin] and self._allLoadingGuide[origin] ~= nil then
        return
    end
    self._allLoadingGuide[origin] = id
end

function Guide:refreshNextGuideId(id, next_id)
    for k, v in pairs(self._allLoadingGuide) do
        if v == id then
            self._allLoadingGuide[k] = next_id
        end
    end
end

function Guide:getGuideInfoById(id)
    return self._tabAllGuide[id] or {}
end

function Guide:getGuideOriginById(id)
    return self._tabAllGuide[id] and self._tabAllGuide[id].origin or 0
end

function Guide:getGuideSkipId(id)
    return self._tabAllGuide[id] and self._tabAllGuide[id].skip or 0
end

function Guide:getGuideNextId(id)
    local tab = self:getGuideInfoById(id)
    return tab and tab.next or 0
end

function Guide:getNextGuideByid(id)
    local tab = self:getGuideInfoById(id)
    if tab and tab.next then
        return self:getGuideInfoById(tab.next) or {}
    end
    return {}
end

function Guide:dealNextForceGuide()
    if self._nowGuideId == 0 then
        return
    end
    local tab = self:getNextGuideByid(self._nowGuideId)
    if not tab or next(tab) == nil then
        self:closeGuideById(self._nowGuideId)
        return
    end
    self:openGuide(tab.ident)
end
--根据打开界面发送引导监听
function Guide:sendGuideEvent(module_name)
    if self.guide_close then
        return
    end
    if self:isOpenStateGuide() then
        return
    end
    local is_refresh = true
    for k, v in pairs(self._allLoadingGuide) do
        if v ~= 0 then
            local info = self:getGuideInfoById(v)
            if info and next(info) ~= nil then
                if not info.layer or module_name == info.layer then
                    self:operatorLayerByName(module_name, info)
                    return
                end
            end
            is_refresh = false
        end
    end
    if is_refresh then
        self:refreshToNextGuide(module_name)
    end
end

function Guide:isOpenStateGuide()
    local tab = {uq.ModuleManager.GUIDE_PLOT, uq.ModuleManager.GUIDE_TIPS}
    for _, v in pairs(tab) do
        local panel = uq.ModuleManager:getInstance():getModule(v)
        if panel then
            return true
        end
    end
    return false
end

function Guide:operatorLayerByName(name, data)
    local panel = uq.ModuleManager:getInstance():getModule(name)
    if not panel then
        return
    end
    local data = data or {}
    if self._lastGuideId == data.ident then
        return
    end
    if data.type == uq.config.constant.GUIDE_TYPE.TALK or data.type == uq.config.constant.GUIDE_TYPE.DEC or data.type == uq.config.constant.GUIDE_TYPE.CHAPTER_OPNE then
        self:showTalkGuide(data, uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE)
    elseif data.type == uq.config.constant.GUIDE_TYPE.FORCE then
        if data.build and data.build ~= -1 and name == "app.modules.main_city.MainCityModule" then
            panel:moveToBuild(data.build, display.center, false, true, nil, 1)
            self:setMainCityMapNotMove(true)
            if data.open_list == 0 or data.open_list == 1 then
                panel:openListEntry(data.open_list == 1)
            end
        end
        self:showForceGuide(data, panel)
    end
end

function Guide:showTalkGuide(data, guide_type)
    local data = data or {}
    if not data or not data.ident then
        return
    end
    if guide_type == uq.config.constant.GUIDE_BRANCH.FORCE_GUIDE then
        self._lastGuideId = data.ident
    end
    local info = {
        data = data,
        guide_type = guide_type
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GUIDE_PLOT, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 20, data = info, close_open_action = true})
end

function Guide:showForceGuide(data, ui_tab)
    local data = data or {}
    if not data or next(data) == nil then
        return
    end
    self._lastGuideId = data.ident
    self:setGuideForceId(data.ident)
    local pos = self:getGuideBtnPos(data, ui_tab)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GUIDE_TIPS, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 30, data = data, close_open_action = true, pos = pos})
end

function Guide:getGuideBtnPos(data, ui_tab)
    local data = data or {}
    local ui_tab = ui_tab or {}
    if not data.box_name or data.box_name == "" then
        return {}
    end
    local target_child = self:getLowerNodeByStr(ui_tab, data.box_name)
    local target_parent = ui_tab
    if data.box_parent and data.box_parent ~= "" then
        target_parent = self:getLowerNodeByStr(ui_tab, data.box_parent)
    end
    if target_child == nil or target_parent == nil then
        return {}
    end
    local pos_x, pos_y = target_child:getPosition()
    return target_parent:convertToWorldSpace(cc.p(pos_x, pos_y)) or {}
end

function Guide:getLowerNodeByStr(parent_node, str)
    local target_node = parent_node
    local tab = string.split(str, ",")
    for _, v in ipairs(tab) do
        local child_key = v
        local str = string.match(v, '%D')
        if str == nil then
            child_key = tonumber(v)
        end
        target_node = target_node[child_key]
        if not target_node then
            return nil
        end
    end
    return target_node
end

function Guide:refreshToNextGuide(module_name)
    local module_name = module_name or uq.ModuleManager:getInstance():getTopLayerName()
    if self.guide_close then
        return
    end
    if not self._isRunGuide then
        return
    end
    for i, v in ipairs(self._tabForce) do
        if not self:isFinishGuide(v.origin) and not self:isHaveGuideLoading() then
            local is_open = true
            local str_tab = {"lv", "guide", "card"}
            for _, iv in ipairs(str_tab) do
                if v[iv] ~= -1 then
                    if (iv == "lv" and v[iv] > uq.cache.role:level()) or
                    (iv == "guide" and not self:isFinishGuide(v[iv])) or
                    (iv == "card" and not uq.cache.instance:isNpcPassed(v[iv])) then
                        is_open = false
                    end
                end
            end
            if is_open then
                if v.id_list then
                    local guide_list = string.split(v.id_list, ",")
                    for i, v in ipairs(guide_list) do
                        local tab_guide = self:getGuideInfoById(tonumber(v))
                        if tab_guide and tab_guide.layer == module_name then
                            uq.cache.guide:openGuide(tonumber(v))
                            return
                        end
                    end
                else
                    uq.cache.guide:openGuide(v.origin)
                end
                return
            end
        end
    end
end

function Guide:isHaveGuideLoading()
    for k, v in pairs(self._allLoadingGuide) do
        if v ~= 0 then
            return true
        end
    end
    return false
end

function Guide:openTriggerGuide(open_type, param)
    if self.guide_close then
        return
    end
    for k, v in pairs(self._tabTrigger) do
        if v.kind == open_type and v.param == param then
            if not self:isFinishGuide(v.origin) then
                local info = self:getGuideInfoById(v.origin)
                if info and next(info) ~= nil then
                    self:showTalkGuide(info, uq.config.constant.GUIDE_BRANCH.TRIGGER_GUIDE)
                end
            end
            break
        end
    end
end

function Guide:closeTriggerGuideById(id)
    local origin = self:getGuideOriginById(id)
    if not origin or origin == 0 then
        return
    end
    table.insert(self._finishGuide, origin)
    network:sendPacket(Protocol.C_2_S_FINISH_GUIDE, {id = origin})
    self:dealTriggerGuideEnd(origin)
end

function Guide:getUnopenTriggerGuide(open_type, param)
    for k, v in pairs(self._tabTrigger) do
        if v.kind == open_type and v.param == param then
            if not self:isFinishGuide(v.origin) then
                return v.origin
            end
            break
        end
    end
    return 0
end

function Guide:dealTriggerGuideEnd(origin)
    for k, v in pairs(self._tabTrigger) do
        if v.origin == origin then
            if v.kind == uq.config.constant.GUIDE_TRIGGER.CHAPTER_FINISH then
                services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN, data = v.param + 1})
            end
            break
        end
    end
end

return Guide
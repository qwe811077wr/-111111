local DrillMainModule = class("DrillMainModule", require('app.base.PopupTabView'))

DrillMainModule.RESOURCE_FILENAME = "drill/DrillMain.csb"
DrillMainModule.RESOURCE_BINDING  = {
    ["sub_cont"]                  = {["varname"] = "_panelItem"},
    ["Button_1"]                  = {["varname"] = "_btnCheck",["events"] = {{["event"] = "touch",["method"] = "_onCheckPage"}}},
    ["Text_1"]                    = {["varname"] = "_btnText"},
    ["node_right_bottom"]         = {["varname"] = "_nodeRightBottom"},
}

function DrillMainModule:ctor(name, args)
    DrillMainModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    DrillMainModule._subModules = {
        {path = "app.modules.drill.DrillMain"},
        {path = "app.modules.drill.DrillInfoView"},
    }

    DrillMainModule._tabTxt = {
        StaticData['local_text']['label.skill.tree'],
        StaticData['local_text']['label.drill.battle']
    }
end

function DrillMainModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:setTitle(uq.config.constant.MODULE_ID.DRILL_GROUND)
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MATERIAL, true, uq.config.constant.MATERIAL_TYPE.MOIRE))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:refrshBtnState()
    self:adaptBgSize()
    self:adaptNode()
    local path = self._subModules[self._tabIndex].path
    self:addSub(path, nil, nil, self._tabIndex)
    self._subModule[self._tabIndex]:showAction()
end

function DrillMainModule:_onCheckPage(event)
    if event.name ~= "ended" then
        return
    end
    local index = self._tabIndex
    self._tabIndex = index == 1 and 2 or 1
    local path = self._subModules[self._tabIndex].path
    self:addSub(path, nil, nil, self._tabIndex)
    self._subModule[self._tabIndex]:showAction()
    self:refrshBtnState()
end

function DrillMainModule:refrshBtnState()
    self._btnText:setString(self._tabTxt[self._tabIndex])
end

function DrillMainModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    DrillMainModule.super.dispose(self)
end

return DrillMainModule
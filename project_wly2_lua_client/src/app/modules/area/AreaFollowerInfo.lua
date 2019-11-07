local AreaFollowerInfo = class("AreaFollowerInfo", require('app.base.ChildViewBase'))

AreaFollowerInfo.RESOURCE_FILENAME = "area/AreaFollowerInfo.csb"
AreaFollowerInfo.RESOURCE_BINDING = {
    ["Node_1"]       = {["varname"] = "_nodeInfo"},
    ["Node_1"]       = {["varname"] = "_nodeInfo"},
    ["Text_1_2_1_0"] = {["varname"] = "_txtDesc"},
    ["Button_1_0"]   = {["varname"] = "_btnConquer",["events"] = {{["event"] = "touch",["method"] = "onConquer"}}},
    ["Button_1"]     = {["varname"] = "_btnDelete",["events"] = {{["event"] = "touch",["method"] = "onDelete"}}},
}

function AreaFollowerInfo:onCreate()
    AreaFollowerInfo.super.onCreate(self)
    self._nodeInfo:setVisible(false)
    self._btnConquer:setVisible(false)
end

function AreaFollowerInfo:setData(index, data)
    local sub_name = data.master_info[1].master_name_info[index].feudatory_Name
    local config = StaticData['types'].VassalType[1].Type[index]

    if sub_name ~= '' then
        self._btnConquer:setVisible(false)
        self._nodeInfo:setVisible(true)
        self._txtSubName:setString(sub_name)
        self._txtDesc:setString('')
    else
        self._nodeInfo:setVisible(false)
        if uq.cache.role:level() >= config.level then
            self._txtDesc:setString(config.text)
            self._btnConquer:setVisible(true)
        else
            self._txtDesc:setString(string.format('主城等级达到%d级开放第%d个属臣', config.level, index))
            self._btnConquer:setVisible(false)
        end
    end
end

function AreaFollowerInfo:onConquer(event)
    if event.name == "ended" then
        local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_FOLLOWER)
        if area_view then
            area_view:disposeSelf()
        end
    end
end

function AreaFollowerInfo:onDelete(event)
    if event.name == "ended" then
        local function confirm()
        end

        local data = {
            content = '是否放弃城属?',
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    end
end

return AreaFollowerInfo
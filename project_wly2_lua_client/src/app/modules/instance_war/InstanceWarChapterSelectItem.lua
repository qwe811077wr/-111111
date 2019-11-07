local InstanceWarChapterSelectItem = class("InstanceWarChapterSelectItem", require('app.base.ChildViewBase'))

InstanceWarChapterSelectItem.RESOURCE_FILENAME = "instance_war/ChapterSelectItem.csb"
InstanceWarChapterSelectItem.RESOURCE_BINDING = {
    ["Text_1"]  = {["varname"] = "_txtName"},
    ["Image_4"] = {["varname"] = "_imgLock"},
    ["Image_2"] = {["varname"] = "_imgScore"},
    ["Image_3"] = {["varname"] = "_imgSweep",["events"] = {{["event"] = "touch",["method"] = "onSweep"}}},
    ["Text_2"]  = {["varname"] = "_txtTitle"},
}

function InstanceWarChapterSelectItem:onCreate()
    InstanceWarChapterSelectItem.super.onCreate(self)
end

function InstanceWarChapterSelectItem:setData(index)
    self._imgLock:setVisible(false)
    self._imgScore:setVisible(false)
    self._imgSweep:setVisible(false)

    self._instanceId = index + 100
    self._instanceData = StaticData['instance_war'][self._instanceId]

    self._txtName:setString(string.subUtf(self._instanceData.name, 5, 4))
    self._txtTitle:setString(string.subUtf(self._instanceData.name, 1, 3))

    if uq.cache.instance_war:isInstancePassed(self._instanceId) then
        self._imgLock:setVisible(false)
        self._imgSweep:setVisible(true)

        local instance_data = uq.cache.instance_war:getInstanceData(self._instanceId)
        local strs = {'s04_00016.png', 's04_00015.png', 's04_00014.png', 's04_00013.png', 's04_00012.png', 's04_00011.png'}
        if strs[instance_data.score] then
            self._imgScore:setVisible(true)
            self._imgScore:loadTexture('img/generals/' .. strs[instance_data.score])
        end
    elseif not self._instanceData.parent or uq.cache.instance_war:isInstancePassed(self._instanceData.parent.ident) then
        self._imgLock:setVisible(false)
    else
        self._imgLock:setVisible(true)
    end
end

function InstanceWarChapterSelectItem:isLocked()
    return self._imgLock:isVisible()
end

function InstanceWarChapterSelectItem:onSweep(event)
    if event.name ~= 'ended' then
        return
    end

    local data = {
        instance_id = self._instanceId,
        sweep_count = 1,
        items = {},
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_SWEEP, data)
end

return InstanceWarChapterSelectItem
local TaskDaySevenHelp = class("TaskDaySevenHelp", require('app.base.PopupBase'))

TaskDaySevenHelp.RESOURCE_FILENAME = "achievement/TaskDaySevenHelp.csb"
TaskDaySevenHelp.RESOURCE_BINDING = {
    ["Image_bg"]     = {["varname"] = "_imgBg"},
    ["Text_7"]       = {["varname"] = "_txtGeneralTitle"},
    ["Text_8"]       = {["varname"] = "_txtGeneralContent"},
    ["Panel_7"]      = {["varname"] = "_panelGeneral"},
    ["Text_9"]       = {["varname"] = "_txtHalfTitle"},
    ["Image_22"]     = {["varname"] = "_imgHalfContent"},
    ["Button_2"]     = {["varname"] = "_btnReset",["events"] = {{["event"] = "touch",["method"] = "onReset"}}},
}

function TaskDaySevenHelp:onCreate()
    TaskDaySevenHelp.super.onCreate(self)
    self:setLayerColor()

    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
end

function TaskDaySevenHelp:init()
    self:centerView()
    self:parseView()
    self:initTaskDayHelp()
end

function TaskDaySevenHelp:initTaskDayHelp()
    local xml_data = StaticData['rule'][501]['Text']
    local general_data = xml_data[1]
    local half_guide = xml_data[2]

    self._txtGeneralTitle:setString(general_data['subTitle'])

    local size = self._txtGeneralContent:getContentSize()
    self._txtGeneralContent:setString(general_data['description'])

    local item_list = uq.RewardType.parseRewards(general_data['showReward'])
    for k, item in pairs(item_list) do
        local bg = self._imgBg:getChildByTag(377 + k)
        local parent = self._imgBg:getChildByTag(1500 + k)
        local xml = StaticData['general'][item:id()]
        local general_head = ccui.ImageView:create("img/common/general_head/" .. xml.icon)
        general_head:setName("general_head")
        general_head:setScale(0.55)
        local head_size = parent:getContentSize()
        general_head:setPosition(cc.p(head_size.width / 2, head_size.height / 2))
        parent:addChild(general_head)
        local type_info = StaticData['types'].ItemQuality[1].Type[xml.qualityType]
        bg:loadTexture("img/common/ui/" .. type_info.headQuality)
    end

    self._txtHalfTitle:setString(half_guide['subTitle'])

    local content = string.split(half_guide['description'], "|")
    for i = 601, 607 do
        local txt = self._imgHalfContent:getChildByTag(i):getChildByName("Text_11")
        txt:setString(content[i - 600])
    end
end

function TaskDaySevenHelp:onReset(event)
    if event.name ~= "ended" then
        return
    end

    self:disposeSelf()
end

return TaskDaySevenHelp
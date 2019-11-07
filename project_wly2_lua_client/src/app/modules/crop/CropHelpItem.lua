local CropHelpItem = class("CropHelpItem", require('app.base.ChildViewBase'))

CropHelpItem.RESOURCE_FILENAME = "crop/CropHelpItem.csb"
CropHelpItem.RESOURCE_BINDING = {
    ["Image_1"]     = {["varname"] = "_imgHead"},
    ["Text_1"]      = {["varname"] = "_txtName"},
    ["Text_1_0"]    = {["varname"] = "_txtCity"},
    ["Text_1_0_0"]  = {["varname"] = "_txtHelpNum"},
    ["s04_00038_3"] = {["varname"] = "_spriteHelped"},
    ["Button_1"]    = {["varname"] = "_btnHelp",["events"] = {{["event"] = "touch",["method"] = "onHelp"}}},
}

function CropHelpItem:onCreate()
    CropHelpItem.super.onCreate(self)

end

function CropHelpItem:setData(help_data)
    self._helpData = help_data
    local build_xml = StaticData['buildings']['CastleMap'][help_data.build_id]
    local xml_help = StaticData['crop_help'].build[help_data.build_level]
    local crop_mem_data = uq.cache.crop:getMemberInfoById(help_data.member_id)
    local res_head = uq.getHeadRes(crop_mem_data.img_id, crop_mem_data.img_type)
    if res_head == "" then
        res_head = 'img/common/player_head/WJTX0001.png'
    end
    self._txtName:setString(crop_mem_data.name)
    self._imgHead:loadTexture(res_head)
    self._txtCity:setString(string.format('%s（lv.%d）', build_xml.name, help_data.build_level))
    self._txtHelpNum:setHTMLText(string.format("<font color='#e52d28'>%d</font>/%d", #self._helpData.help_player, xml_help.times))

    local helped = uq.cache.crop:isHelped(help_data.help_player)
    self._btnHelp:setVisible(not helped)
    self._spriteHelped:setVisible(helped)
end

function CropHelpItem:oneKeyHelp()
    if not self._spriteHelped:isVisible() then
        network:sendPacket(Protocol.C_2_S_CROP_DO_HELP, {role_id = self._helpData.member_id, build_id = self._helpData.build_id})
    end
end

function CropHelpItem:onHelp(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_DO_HELP, {role_id = self._helpData.member_id, build_id = self._helpData.build_id})
    end
end

return CropHelpItem
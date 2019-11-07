local RoleLevelUp = class("RoleLevelUp", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

RoleLevelUp.RESOURCE_FILENAME = "role/RoleLevelUp.csb"

RoleLevelUp.RESOURCE_BINDING  = {
    ["bm_level"]     ={["varname"] = "_bmFontLevel"},
    ["Panel_1"]      ={["varname"] = "_panelItem"},
    ["Text_des1"]    ={["varname"] = "_desLabel1"},
    ["Text_des2"]    ={["varname"] = "_desLabel2"},
    ["Panel_role"]   ={["varname"] = "_panelRole"},
    ["img_bg_adapt"] ={["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onTouchClose"}}},
}

function RoleLevelUp:ctor(name, args)
    RoleLevelUp.super.ctor(self, name, args)
    self._info = args.info
end

function RoleLevelUp:init()
    self:parseView()
    self:centerView()
    self:initDialog()
    self:adaptBgSize()
end

function RoleLevelUp:initDialog()
    if self._info == nil then
        return
    end
    self._bmFontLevel:setString(self._info.level)
    local name1 = string.format(StaticData['local_text']['general.level.limit.des1'], StaticData['local_text']['label.general'])
    local str1 = string.format(StaticData['local_text']['chat.cell.title.des1'], 22, "#FFFFFF", name1)
    str1 = str1 .. string.format(StaticData['local_text']['chat.cell.title.des1'], 24, "#FDFE82", self._info.level)
    str1 = str1 .. string.format(StaticData['local_text']['chat.cell.title.des1'], 22, "#FFFFFF", StaticData['local_text']['general.level.limit.des2'])
    self._desLabel1:setHTMLText(str1)
    local name2 = string.format(StaticData['local_text']['general.level.limit.des1'], StaticData['local_text']['label.equip'])
    local str2 = string.format(StaticData['local_text']['chat.cell.title.des1'], 22, "#FFFFFF", name2)
    str2 = str2 .. string.format(StaticData['local_text']['chat.cell.title.des1'], 24, "#FDFE82", self._info.level)
    str2 = str2 .. string.format(StaticData['local_text']['chat.cell.title.des1'], 22, "#FFFFFF", StaticData['local_text']['general.level.limit.des2'])
    self._desLabel2:setHTMLText(str2)
    self:initGeneral()
    local pos_x = 0
    local width = self._panelItem:getContentSize().width
    if #self._info.reward % 2 == 0 then
        pos_x = -width / 2 - (math.floor(#self._info.reward / 2) - 1) * width
    else
        pos_x =  - math.floor(#self._info.reward / 2) * width
    end
    for k, t in ipairs(self._info.reward) do
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(t.paraml)
        info.num = tonumber(t.num)
        local euqip_item = EquipItem:create({info = info})
        euqip_item:setScale(0.9)
        euqip_item:setPosition(cc.p(pos_x, 60))
        self._panelItem:addChild(euqip_item)
        pos_x = pos_x + width
    end
end

function RoleLevelUp:initGeneral()
    local generals_xml = StaticData['general'][uq.cache.role.img_id]
    if not generals_xml then
        generals_xml = StaticData['general'][401971]
    end
    local anim_id = generals_xml.imageId
    local pre_path = "animation/spine/" .. anim_id .. '/' .. anim_id
    local size = self._panelRole:getContentSize()
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        self._panelRole:addChild(anim)
        anim:setScale(generals_xml.imageRatio)
        anim:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX - 500, generals_xml.imageY))
        anim:setAnimation(0, 'idle', true)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelRole:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        img:setScale(generals_xml.imageRatio)
        img:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX, size.height + generals_xml.imageY))
    end
end

function RoleLevelUp:dispose()
    RoleLevelUp.super.dispose(self)
    uq.showRoleLevelUp()
end

function RoleLevelUp:onTouchClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return RoleLevelUp

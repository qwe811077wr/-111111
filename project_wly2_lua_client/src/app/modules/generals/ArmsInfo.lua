local ArmsInfo = class("ArmsInfo", require("app.base.PopupBase"))

ArmsInfo.RESOURCE_FILENAME = "generals/ArmsInfo.csb"

ArmsInfo.RESOURCE_BINDING  = {
    ["Panel_1"]                     ={["varname"] = "_panelArms1"},
    ["Panel_5"]                     ={["varname"] = "_panelCurValue"},
    ["ScrollView_1"]                ={["varname"] = "_desScrollView1"},
}
function ArmsInfo:ctor(name, args)
    ArmsInfo.super.ctor(self,name,args)
    self._curInfo = args.info or nil
    self._armsItem1 = nil
    self._armsInfoItem1 = nil
end

function ArmsInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    if self._curInfo == nil then
        return
    end
    self._desScrollView1:setScrollBarEnabled(false)
    self:initUi()
end

function ArmsInfo:initUi()
    self:updateBaseInfo()
    self:_updateChangeDialog()
end

function ArmsInfo:updateBaseInfo()
    self._armsItem1 = uq.createPanelOnly("generals.ArmsResInfoItem")
    self._panelArms1:addChild(self._armsItem1)
    local info = {soldier_id = self._curInfo.ident}
    self._armsItem1:setInfo(info)
    self._armsItem1:setSelectBgImgVisible(false)
    self._armsItem1:setSelectImgVisible(true)
    self._armsItem1:setUpImgVisible(false)
end

function ArmsInfo:_updateChangeDialog()
    self._armsInfoItem1 = uq.createPanelOnly("generals.ArmsValueItem")
    self._panelCurValue:addChild(self._armsInfoItem1)
    self._armsInfoItem1:setData(self._curInfo.ident)
    self:updateDesScroll()
end

function ArmsInfo:updateDesScroll()
    local des = self._curInfo.Content or ""
    self._desScrollView1:removeAllChildren()
    local scroll_size = self._desScrollView1:getContentSize()
    local lbl_height = ccui.Text:create()
    lbl_height:setFontSize(22)
    lbl_height:setFontName("font/hwkt.ttf")
    lbl_height:setContentSize(cc.size(scroll_size.width, 60))
    lbl_height:setHTMLText(des)
    local height = lbl_height:getContentSize().height
    self._desScrollView1:setScrollBarEnabled(height > scroll_size.height)
    self._desScrollView1:setTouchEnabled(height > scroll_size.height)
    if height < scroll_size.height then
        height = scroll_size.height
    end
    self._desScrollView1:setInnerContainerSize(cc.size(scroll_size.width, height))
    local lbl_tips = ccui.Text:create()
    lbl_tips:setFontSize(22)
    lbl_tips:setFontName("font/hwkt.ttf")
    lbl_tips:setAnchorPoint(cc.p(0, 1))
    lbl_tips:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lbl_tips:setPosition(cc.p(0, height))
    lbl_tips:setContentSize(cc.size(scroll_size.width, 60))
    lbl_tips:setHTMLText(des, nil, nil, nil, true)
    self._desScrollView1:addChild(lbl_tips)
end

function ArmsInfo:dispose()
    self._armsItem1:dispose()
    ArmsInfo.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return ArmsInfo
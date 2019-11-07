local ArmsStrengthSuccess = class("ArmsStrengthSuccess", require("app.base.PopupBase"))

ArmsStrengthSuccess.RESOURCE_FILENAME = "generals/ArmsStrengthSuccess.csb"

ArmsStrengthSuccess.RESOURCE_BINDING  = {
    ["img_type1"]                   ={["varname"] = "_imgType1"},
    ["label_level1"]                ={["varname"] = "_levelLabel1"},
    ["label_name1"]                 ={["varname"] = "_nameLabel1"},
    ["img_icon1"]                   ={["varname"] = "_imgIcon1"},
    ["ScrollView_1"]                ={["varname"] = "_desScrollView1"},
    ["img_wugong"]                  ={["varname"] = "_imgPhysicsAtt"},
    ["img_wufang"]                  ={["varname"] = "_imgPhysicsDef"},
    ["img_zhanfagong"]              ={["varname"] = "_imgPlanAtt"},
    ["img_zhanfafang"]              ={["varname"] = "_imgPlanDef"},
    ["img_jicegong"]                ={["varname"] = "_imgWarLawAtt"},
    ["img_jicefang"]                ={["varname"] = "_imgWarLawDef"},
    ["img_title"]                   ={["varname"] = "_imgTitle"},
    ["Image_11"]                    ={["varname"] = "_imgNotPress"},
}
function ArmsStrengthSuccess:ctor(name, args)
    ArmsStrengthSuccess.super.ctor(self,name,args)
    self._soldierId = args.soldier_id or 0
end

function ArmsStrengthSuccess:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    if self._soldierId == 0 then
        return
    end
    self._desScrollView1:setScrollBarEnabled(false)
    self:initUi()
end

function ArmsStrengthSuccess:initUi()
    self:addExceptNode(self._imgNotPress)
    self._imgTitle:setScale(1.2)
    local action1 = cc.ScaleTo:create(0.1, 0.6)
    self._imgTitle:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.5),cc.ScaleTo:create(0.2, 1.0),nil))
    self:updateBaseInfo()
    self:_updateChangeDialog()
end

function ArmsStrengthSuccess:updateBaseInfo()
    local soldier_xml1 = StaticData['soldier'][self._soldierId]
    if not soldier_xml1 then
        uq.log("error ArmsStrengthSuccess updateBaseInfo  soldier_xml1")
        return
    end
    local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
    local type_solider_level1 = StaticData['types'].Soldierlevel[1].Type[soldier_xml1.level]
    self._imgType1:loadTexture("img/generals/"..type_solider1.miniIcon)
    self._nameLabel1:setString(soldier_xml1.name)
    self._levelLabel1:setString(type_solider_level1.name)
    self._levelLabel1:setTextColor(uq.parseColor(type_solider_level1.color))
    self._imgIcon1:loadTexture("img/common/soldier/"..soldier_xml1.file)
end

function ArmsStrengthSuccess:_updateChangeDialog()
    local soldier_xml = StaticData['soldier'][self._soldierId]
    if not soldier_xml then
        uq.log("error ArmsStrengthSuccess updateBaseInfo  soldier_xml")
        return
    end
    local attack_arry = StaticData['types'].AttackQuotiety[1].Type
    local leader_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.leaderAtkRate)
    if leader_att_info then
        self._imgPhysicsAtt:loadTexture("img/generals/"..leader_att_info.icon)
    end
    local strength_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.strengthAtkRate)
    if strength_att_info then
        self._imgWarLawAtt:loadTexture("img/generals/"..strength_att_info.icon)
    end
    local intellect_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.intellectAtkRate)
    if intellect_att_info then
        self._imgPlanAtt:loadTexture("img/generals/"..intellect_att_info.icon)
    end

    local def_arry = StaticData['types'].RecoveryQuotiety[1].Type
    local leader_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.leaderDefRate)
    if leader_def_info then
        self._imgPhysicsDef:loadTexture("img/generals/"..leader_def_info.icon)
    end
    local strength_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.strengthDefRate)
    if strength_def_info then
        self._imgWarLawDef:loadTexture("img/generals/"..strength_def_info.icon)
    end
    local intellect_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.intellectDefRate)
    if intellect_def_info then
        self._imgPlanDef:loadTexture("img/generals/"..intellect_def_info.icon)
    end
    self:updateDesScroll(soldier_xml)
end

function ArmsStrengthSuccess:updateDesScroll(soldier_xml)
    self._desScrollView1:removeAllChildren()
    local des = soldier_xml.Content or ""
    local scroll_size = self._desScrollView1:getContentSize()
    local lbl_height = ccui.Text:create()
    lbl_height:setFontSize(18)
    lbl_height:setFontName("font/fzlthjt.ttf")
    lbl_height:setContentSize(cc.size(scroll_size.width,40))
    lbl_height:setHTMLText(des)
    local height = lbl_height:getContentSize().height
    if height > scroll_size.height then
        self._desScrollView1:setTouchEnabled(true)
        self._desScrollView1:setScrollBarEnabled(true)
    else
        self._desScrollView1:setTouchEnabled(false)
        self._desScrollView1:setScrollBarEnabled(false)
        height = scroll_size.height
    end
    self._desScrollView1:setInnerContainerSize(cc.size(scroll_size.width,height))
    local lbl_tips = ccui.Text:create()
    lbl_tips:setFontSize(18)
    lbl_tips:setFontName("font/fzlthjt.ttf")
    lbl_tips:setAnchorPoint(cc.p(0, 1))
    lbl_tips:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lbl_tips:setPosition(cc.p(0, height))
    lbl_tips:setContentSize(cc.size(scroll_size.width,40))
    lbl_tips:setHTMLText(des)
    self._desScrollView1:addChild(lbl_tips)
end

function ArmsStrengthSuccess:dispose()
    ArmsStrengthSuccess.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return ArmsStrengthSuccess
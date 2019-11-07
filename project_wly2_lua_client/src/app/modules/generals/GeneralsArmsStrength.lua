local GeneralsArmsStrength = class("GeneralsArmsStrength", require("app.base.PopupBase"))

GeneralsArmsStrength.RESOURCE_FILENAME = "generals/GeneralsArmsStrength.csb"

GeneralsArmsStrength.RESOURCE_BINDING  = {
    ["Panel_2_0/Panel_10/btn_strength"]                                 ={["varname"] = "_btnStrength",["events"] = {{["event"] = "touch",["method"] = "onBtnStrength"}}},
    ["Panel_2/Panel_1/img_type1"]                                       ={["varname"] = "_imgType1"},
    ["Panel_2/Panel_1/label_level1"]                                    ={["varname"] = "_levelLabel1"},
    ["Panel_2/Panel_1/label_name1"]                                     ={["varname"] = "_nameLabel1"},
    ["Panel_2/Panel_1/img_icon1"]                                       ={["varname"] = "_imgIcon1"},
    ["Panel_2_0/Panel_10/Panel_1/img_type2"]                            ={["varname"] = "_imgType2"},
    ["Panel_2_0/Panel_10/Panel_1/label_level2"]                         ={["varname"] = "_levelLabel2"},
    ["Panel_2_0/Panel_10/Panel_1/label_name2"]                          ={["varname"] = "_nameLabel2"},
    ["Panel_2_0/Panel_10/Panel_1/img_icon2"]                            ={["varname"] = "_imgIcon2"},
    ["Panel_2/Panel_4/ScrollView_1"]                                    ={["varname"] = "_desScrollView1"},
    ["Panel_2_0/Panel_10/Panel_4/ScrollView_2"]                         ={["varname"] = "_desScrollView2"},
    ["Panel_2/Panel_5/Panel_6_1/img_wugong"]                            ={["varname"] = "_imgPhysicsAtt"},
    ["Panel_2/Panel_5/Panel_6_4/img_wufang"]                            ={["varname"] = "_imgPhysicsDef"},
    ["Panel_2/Panel_5/Panel_6_2/img_zhanfagong"]                        ={["varname"] = "_imgPlanAtt"},
    ["Panel_2/Panel_5/Panel_6_5/img_zhanfafang"]                        ={["varname"] = "_imgPlanDef"},
    ["Panel_2/Panel_5/Panel_6_3/img_jicegong"]                          ={["varname"] = "_imgWarLawAtt"},
    ["Panel_2/Panel_5/Panel_6_6/img_jicefang"]                          ={["varname"] = "_imgWarLawDef"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_1/img_wugong2"]                ={["varname"] = "_imgPhysicsAtt2"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_4/img_wufang2"]                ={["varname"] = "_imgPhysicsDef2"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_2/img_zhanfagong2"]            ={["varname"] = "_imgPlanAtt2"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_5/img_zhanfafang2"]            ={["varname"] = "_imgPlanDef2"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_3/img_jicegong2"]              ={["varname"] = "_imgWarLawAtt2"},
    ["Panel_2_0/Panel_10/Panel_5/Panel_6_6/img_jicefang2"]              ={["varname"] = "_imgWarLawDef2"},
    ["Panel_2_0/Panel_10/Panel_res_0/panel_item1"]                      ={["varname"] = "_panelItem1"},
    ["Panel_2_0/Panel_10/Panel_res_0/panel_item2"]                      ={["varname"] = "_panelItem2"},
    ["Panel_2_0/Panel_10/Panel_res_0/panel_item3"]                      ={["varname"] = "_panelItem3"},
    ["Panel_2/Image_11"]                                                ={["varname"] = "_imgNotPress"},
    ["Panel_2_0/Image_11_2"]                                            ={["varname"] = "_imgNotPress2"},
}
function GeneralsArmsStrength:ctor(name, args)
    GeneralsArmsStrength.super.ctor(self,name,args)
    self._curSoldierId = args.soldier_id or 0
    self._curGeneralId = args.general_id or 0
    self._nextSoldierInfo = nil
end

function GeneralsArmsStrength:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    if self._curSoldierId == 0 or self._curGeneralId == 0 then
        return
    end
    self._nextSoldierInfo = StaticData['reinforce_soldiers'][self._curSoldierId]
    if self._nextSoldierInfo == nil then
        return
    end
    self:initUi()
end

function GeneralsArmsStrength:initUi()
    self._desScrollView1:setScrollBarEnabled(false)
    self._desScrollView2:setScrollBarEnabled(false)
    self:addExceptNode(self._imgNotPress)
    self:addExceptNode(self._imgNotPress2)
    self._btnStrength:setPressedActionEnabled(true)
    self._itemArray = {}
    self._panelItem2:setVisible(false)
    self._panelItem3:setVisible(false)
    table.insert(self._itemArray,self._panelItem1)
    table.insert(self._itemArray,self._panelItem2)
    table.insert(self._itemArray,self._panelItem3)
    self:updateBaseInfoLeft()
    self:_updateDesScrollLeft()
    self:_updateChangeDialogLeft()
    self:updateBaseInfoRight()
    self:_updateDesScrollRight()
    self:_updateChangeDialogRight()
    self:_updateRes()
end

function GeneralsArmsStrength:_updateRes()
    local index = 1
    for _,v in pairs(self._nextSoldierInfo.Item) do
        local item = self._itemArray[index]
        local info = StaticData['material'][v.ident]
        if item ~= nil and info ~= nil then
            item:setVisible(true)
            item:getChildByName("item_img_icon"..index):loadTexture("img/item/"..info.icon)
            item:getChildByName("lbl_num"..index):setString("0/"..v.num)
            if 0 < v.num then
                item:getChildByName("lbl_num"..index):setTextColor(cc.c3b(255,0,0))
            else
                item:getChildByName("lbl_num"..index):setTextColor(cc.c3b(6,277,74))
            end
            index = index + 1
        end
    end
end

function GeneralsArmsStrength:onBtnStrength(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_REINFORCED_SOLDIER,{generalId = self._curGeneralId,soldierId = self._curSoldierId})
end

function GeneralsArmsStrength:updateBaseInfoLeft()
    local soldier_xml1 = StaticData['soldier'][self._curSoldierId]
    if not soldier_xml1 then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml1")
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

function GeneralsArmsStrength:updateBaseInfoRight()
    local soldier_xml2 = StaticData['soldier'][self._nextSoldierInfo.toId]
    if not soldier_xml2 then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml2")
        return
    end
    local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
    local type_solider_level2 = StaticData['types'].Soldierlevel[1].Type[soldier_xml2.level]
    self._imgType2:loadTexture("img/generals/"..type_solider2.miniIcon)
    self._nameLabel2:setString(soldier_xml2.name)
    self._levelLabel2:setString(type_solider_level2.name)
    self._levelLabel2:setTextColor(uq.parseColor(type_solider_level2.color))
    self._imgIcon2:loadTexture("img/common/soldier/"..soldier_xml2.file)
end

function GeneralsArmsStrength:_updateChangeDialogLeft()
    local soldier_xml = StaticData['soldier'][self._curSoldierId]
    if not soldier_xml then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml")
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
end

function GeneralsArmsStrength:_updateChangeDialogRight()
    local soldier_xml = StaticData['soldier'][self._nextSoldierInfo.toId]
    if not soldier_xml then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml")
        return
    end
    local attack_arry = StaticData['types'].AttackQuotiety[1].Type
    local leader_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.leaderAtkRate)
    if leader_att_info then
        self._imgPhysicsAtt2:loadTexture("img/generals/"..leader_att_info.icon)
    end
    local strength_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.strengthAtkRate)
    if strength_att_info then
        self._imgWarLawAtt2:loadTexture("img/generals/"..strength_att_info.icon)
    end
    local intellect_att_info = StaticData.getAttackAndDefInfo(attack_arry,soldier_xml.intellectAtkRate)
    if intellect_att_info then
        self._imgPlanAtt2:loadTexture("img/generals/"..intellect_att_info.icon)
    end

    local def_arry = StaticData['types'].RecoveryQuotiety[1].Type
    local leader_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.leaderDefRate)
    if leader_def_info then
        self._imgPhysicsDef2:loadTexture("img/generals/"..leader_def_info.icon)
    end
    local strength_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.strengthDefRate)
    if strength_def_info then
        self._imgWarLawDef2:loadTexture("img/generals/"..strength_def_info.icon)
    end
    local intellect_def_info = StaticData.getAttackAndDefInfo(def_arry,soldier_xml.intellectDefRate)
    if intellect_def_info then
        self._imgPlanDef2:loadTexture("img/generals/"..intellect_def_info.icon)
    end
end

function GeneralsArmsStrength:_updateDesScrollLeft()
    local soldier_xml = StaticData['soldier'][self._curSoldierId]
    if not soldier_xml then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml")
        return
    end
    local des = soldier_xml.Content or ""
    self._desScrollView1:removeAllChildren()
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

function GeneralsArmsStrength:_updateDesScrollRight()
    local soldier_xml = StaticData['soldier'][self._nextSoldierInfo.toId]
    if not soldier_xml then
        uq.log("error GeneralsArmsStrength updateBaseInfo  soldier_xml")
        return
    end
    local des = soldier_xml.Content or ""
    self._desScrollView2:removeAllChildren()
    local scroll_size = self._desScrollView2:getContentSize()
    local lbl_height = ccui.Text:create()
    lbl_height:setFontSize(18)
    lbl_height:setFontName("font/fzlthjt.ttf")
    lbl_height:setContentSize(cc.size(scroll_size.width,40))
    lbl_height:setHTMLText(des)
    local height = lbl_height:getContentSize().height
    if height > scroll_size.height then
        self._desScrollView2:setTouchEnabled(true)
        self._desScrollView2:setScrollBarEnabled(true)
    else
        self._desScrollView2:setTouchEnabled(false)
        self._desScrollView2:setScrollBarEnabled(false)
        height = scroll_size.height
    end
    self._desScrollView2:setInnerContainerSize(cc.size(scroll_size.width,height))
    local lbl_tips = ccui.Text:create()
    lbl_tips:setFontSize(18)
    lbl_tips:setFontName("font/fzlthjt.ttf")
    lbl_tips:setAnchorPoint(cc.p(0, 1))
    lbl_tips:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lbl_tips:setPosition(cc.p(0, height))
    lbl_tips:setContentSize(cc.size(scroll_size.width,40))
    lbl_tips:setHTMLText(des,nil,nil,nil,true)
    self._desScrollView2:addChild(lbl_tips)
end

function GeneralsArmsStrength:dispose()
    GeneralsArmsStrength.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return GeneralsArmsStrength
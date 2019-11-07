local CropCell = class("CropCell", require('app.base.ChildViewBase'))

CropCell.RESOURCE_FILENAME = "crop/CropCell.csb"
CropCell.RESOURCE_BINDING = {
    ["crop_name_txt"]          = {["varname"] = "_txtCropName"},
    ["lv_txt"]                 = {["varname"] = "_txtCropLevel"},
    ["num_txt"]                = {["varname"] = "_txtCropNum"},
    ["Text_7"]                 = {["varname"] = "_txtRank"},
    ["Image_3"]                = {["varname"] = "_imgRank"},
    ["Text_1_0_0_1"]           = {["varname"] = "_txtLimit"},
    ["finish_img"]             = {["varname"] = "_imgFinish"},
    ["cancel_btn"]             = {["varname"] = "_btnCancel"},
    ["apply_btn"]              = {["varname"] = "_btnApply"},
    ["join_btn"]               = {["varname"] = "_btnJoin"},
}

function CropCell:onCreate()
    CropCell.super.onCreate(self)
    self:parseView()
    self._curCropData = {}
    self:initLayer()
end

function CropCell:onExit()
    CropCell.super:onExit()
end

function CropCell:_refreshCropCell()
    self:refreshPage()
end

function CropCell:initLayer()
    self._btnCancel:addClickEventListenerWithSound(function()
        if not self._curCropData or not self._curCropData.id then
            return
        end
        network:sendPacket(Protocol.C_2_S_CANCEL_APPLY, {crop_id = self._curCropData.id})
    end)
    self._btnApply:addClickEventListenerWithSound(function()
        if not self._curCropData or not self._curCropData.id then
            return
        end
        network:sendPacket(Protocol.C_2_S_CROP_APPLY, {crop_id = self._curCropData.id})
    end)
    self._btnJoin:addClickEventListenerWithSound(function()
        if not self._curCropData or not self._curCropData.id then
            return
        end
        network:sendPacket(Protocol.C_2_S_CROP_APPLY, {crop_id = self._curCropData.id})
    end)
end

function CropCell:setData(crop_info, index)
    self._curCropData = crop_info or {}
    self._index = index
    self:refreshPage()
end

function CropCell:refreshPage()
    self._txtCropName:setString(self._curCropData.name)
    self._txtCropLevel:setString(self._curCropData.level)
    self._txtCropNum:setString(string.format("%d/%d", self._curCropData.mem_num, self._curCropData.max_mem_num))
    if self._index > 3 then
        self._txtRank:setString(self._index)
    else
        self._txtRank:setString('')
        self._imgRank:loadTexture(self:getRankIcon(self._index))
    end
    self._imgRank:setVisible(self._index <= 3)
    if self._curCropData.limit_type == Protocol.CROP_JOIN_LIMIT.LEVEL then
        if self._curCropData.limit_value > 0 then
            self._txtLimit:setString(string.format(StaticData['local_text']['crop.maincity.level'], self._curCropData.limit_value))
            self._txtLimit:setTextColor(cc.c3b(255, 255, 153))
        else
            self._txtLimit:setString(StaticData['local_text']['crop.no.limit'])
            self._txtLimit:setTextColor(cc.c3b(121, 129, 129))
        end
    else
        self._txtLimit:setString(StaticData['local_text']['crop.no.limit'])
        self._txtLimit:setTextColor(cc.c3b(121, 129, 129))
    end
    self._imgFinish:setVisible(false)
    self._btnCancel:setVisible(false)
    self._btnApply:setVisible(false)
    self._btnJoin:setVisible(false)
    if self._curCropData.mem_num == self._curCropData.max_mem_num then
        self._imgFinish:setVisible(true)
    elseif uq.cache.crop:isApplying(self._curCropData.id) then
        self._btnCancel:setVisible(true)
    elseif uq.cache.role:level() >= self._curCropData.limit_value and uq.cache.crop.join_cd < uq.curServerSecond() then
        self._btnJoin:setVisible(true)
    elseif uq.cache.crop.join_cd < uq.curServerSecond() then
        self._btnApply:setVisible(true)
    end
end

function CropCell:getRankIcon(rank)
    if rank == 1 then
        return 'img/crop/s04_00044.png'
    elseif rank == 2 then
        return 'img/crop/s04_00044_2.png'
    else
        return 'img/crop/s04_00044_3.png'
    end
end

return CropCell
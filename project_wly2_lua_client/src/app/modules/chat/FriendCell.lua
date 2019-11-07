local FriendCell = class("FriendCell", require('app.base.ChildViewBase'))

FriendCell.RESOURCE_FILENAME = "chat/FriendCell.csb"
FriendCell.RESOURCE_BINDING = {
    ["Image_select"]    = {["varname"] = "_imgSelect"},
    ["Image_delete"]    = {["varname"] = "_imgDelete"},
    ["Image_country"]   = {["varname"] = "_imgCountry"},
    ["Sprite_1"]        = {["varname"] = "_spriteHead"},
    ["Text_1_0"]        = {["varname"] = "_txtTime"},
    ["Text_1"]          = {["varname"] = "_txtName"}
}

function FriendCell:onCreate()
    self._imgDelete:setTouchEnabled(true)
    self._imgDelete:addClickEventListener(function(sender)
    end)
end

function FriendCell:setData(data)
    self._data = data
    self._txtName:setString(data.contact_name)

    local time_stamp = data.create_time
    if #data.content > 0 then
        time_stamp = data.content[#data.content].create_time
    end
    local time = os.time() - time_stamp
    local content = uq.getTime2(time)
    self._txtTime:setString(content)
    self:setHeadImg(data.img_id, data.img_type)
    self._imgCountry:loadTexture(self:getCountryBg(data.country_id))
end

function FriendCell:setSelect(cur_id)
    self._imgSelect:setVisible(cur_id == self._data.contact_id)
end

function FriendCell:setHeadImg(img_id, img_type)
    local res_head = uq.getHeadRes(img_id, img_type)
    self._spriteHead:setTexture(res_head)
end

function FriendCell:getCountryBg(country_id)
    if country_id == uq.config.constant.COUNTRY.SHU then
        return 'img/common/ui/s03_00034.png'
    elseif country_id == uq.config.constant.COUNTRY.WU then
        return 'img/common/ui/s03_00035.png'
    else
        return 'img/common/ui/s03_00033.png'
    end
end

return FriendCell
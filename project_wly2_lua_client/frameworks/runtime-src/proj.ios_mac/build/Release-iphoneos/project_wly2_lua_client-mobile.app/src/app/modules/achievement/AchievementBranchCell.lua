local AchievementBranchCell = class("AchievementBranchCell", require('app.base.ChildViewBase'))

AchievementBranchCell.RESOURCE_FILENAME = "achievement/AchievementBranchCell.csb"
AchievementBranchCell.RESOURCE_BINDING = {
    ["Text_4"]     = {["varname"] = "_txtName"},
    ["Image_cell"] = {["varname"] = "_imgCell"}
}

function AchievementBranchCell:ctor(name, params)
    AchievementBranchCell.super.ctor(self, name, params)
end

function AchievementBranchCell:setData(data, flag)
    self._txtName:setString(data)

    local size = self._txtName:getContentSize()
    uq.showRedStatus(self._imgCell, flag, size.width / 2 + 23, size.height / 2 + 37)
end

return AchievementBranchCell
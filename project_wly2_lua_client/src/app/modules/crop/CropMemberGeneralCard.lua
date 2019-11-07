local CropMemberGeneralCard = class("CropMemberGeneralCard", require('app.base.ChildViewBase'))

CropMemberGeneralCard.RESOURCE_FILENAME = "crop/CropRoleCard.csb"
CropMemberGeneralCard.RESOURCE_BINDING = {
}

function CropMemberGeneralCard:onCreate()
    CropMemberGeneralCard.super.onCreate(self)
end

function CropMemberGeneralCard:setData(data)

end

return CropMemberGeneralCard
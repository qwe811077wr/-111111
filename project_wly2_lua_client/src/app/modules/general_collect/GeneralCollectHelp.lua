local GeneralCollectHelp = class("GeneralCollectHelp", require('app.base.PopupBase'))

GeneralCollectHelp.RESOURCE_FILENAME = "general_collect/GeneralCollectHelp.csb"
GeneralCollectHelp.RESOURCE_BINDING = {
    ["Text_2"]          ={["varname"] = "_desLabel"},
}

function GeneralCollectHelp:ctor(name, params)
    GeneralCollectHelp.super.ctor(self, name, params)
end

function GeneralCollectHelp:onCreate()
    GeneralCollectHelp.super.onCreate(self)

    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()
    local des = StaticData['rule'][401]['Text'][1]['description']
    self._desLabel:setString(des)
end

return GeneralCollectHelp
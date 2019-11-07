require "app.init"
require('app.base.init')
require('app.config.init')
require('app.locale.init')
require('app.ui.init')
require('app.static_data.init')
require('app.utils.init')
require('app.log.init')
require('app.network.init')
require('app.cache.init')
cc.exports.uq.RichText = require('app.modules.common.RichTextEx')
cc.exports.uq.ShaderEffect = require("app.shader.ShaderEffect")

local MyApp = class("MyApp")

function MyApp:run()
    math.randomseed(os.time())
    cc.Image:setPVRImagesHavePremultipliedAlpha(true)
    require("app.network.InitProtocol"):init()

    uq.ModuleManager:getInstance():init()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_MODULE, {moduleType = 1})
end

return MyApp

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("res/font")
cc.FileUtils:getInstance():addSearchPath("res/ui")
cc.FileUtils:getInstance():addSearchPath("res/img")
cc.FileUtils:getInstance():addSearchPath("res/sound")

require "config"
require "cocos.init"
cc.exports.uq = cc.exports.uq or {}
require "cppapi.init"

local UPDATE_PATH = cc.FileUtils:getInstance():getWritablePath() .. 'update'
cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)

local function resetSearchPath( )
    local searchPaths = {   UPDATE_PATH .. "/" ,
                            UPDATE_PATH .. '/src/',
                            UPDATE_PATH .. '/res/' ,
                            UPDATE_PATH .. '/res/font/',
                            UPDATE_PATH .. '/res/ui/',
                            UPDATE_PATH .. '/res/img/',
                            UPDATE_PATH .. '/res/sound/'}

    local paths = cc.FileUtils:getInstance():getSearchPaths()

    for _, v in ipairs(paths) do
        table.insert(searchPaths, v)
    end
    cc.FileUtils:getInstance():setSearchPaths(searchPaths)
end

local function checkUpdate()
    cc.FileUtils:getInstance():createDirectory(UPDATE_PATH)
    resetSearchPath()
    local am = cc.AssetsManagerEx:create('project.manifest', UPDATE_PATH)
    am:retain()
    display.runScene(require("app.UpdateScene").new(am))
end

local function main()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
        require("app.MyApp"):run()
    else
        checkUpdate()
    end
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

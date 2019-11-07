require("utils")
require("cfg")

print('version ipa', args.version)

local projDir = PROJECT_PATH .. "publish/ios/build"
local ipaFolder = projDir .. "/ipa-build/"
os.execute("rm -rf " .. ipaFolder)
os.execute("mkdir " .. ipaFolder)

local infoPlistTpl = loadText(PROJECT_PATH .. "build/scripts/Info.plist")
saveTo(PROJECT_PATH .. '"frameworks/runtime-src/proj.ios_mac"' .. "/ios/Info.plist", string.format(infoPlistTpl, app_name, packageName, args.version, args.version) )

print('ios info', app_name, packageName, args.version)

-- local mode = " -c Release"
-- local libs = {
-- 	"tools/simulator/libsimulator/proj.ios_mac",
-- 	"cocos/quick_libs/proj.ios_mac",
-- 	"cocos/scripting/lua-bindings/proj.ios_mac",
-- }

-- print("--------- build libs -----------")
-- for k, v in ipairs(libs) do
-- 	local dir = PROJECT_PATH .. "frameworks/cocos2d-x/" .. v
-- 	os.execute(PROJECT_PATH.."build/ios/ipa-build " .. dir ..mode)
-- end

local appdirname = PROJECT_PATH .. "publish/ios/build/pack"
os.execute("cocos compile -p ios -m release --compile-script 0 -o " .. appdirname)

-- print("--------- make ipa -----------")
os.execute("xcrun -sdk iphoneos PackageApplication -v " .. appdirname ..  "/*.app -o " .. "/Users/admin/code/public_code/project_wly2_lua_client/publish/ios/build/ipa-build/project_wly2_lua_client-mobile.ipa")

print("--------- copy ipa -----------")
for f in lfs.dir(ipaFolder) do
    os.rename(ipaFolder .. f, PROJECT_PATH .. "publish/ios/pack/" .. shortName .. "-" .. args.platform .. ".ipa")
end

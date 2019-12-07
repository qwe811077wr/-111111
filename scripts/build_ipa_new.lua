require("utils")
require("cfg")

print('version ipa', args.version)

local projDir = PROJECT_PATH .. "frameworks/runtime-src/proj.ios_mac"
local ipaFolder = projDir.. "/build/ipa-build/"
if isExist(ipaFolder) then
	for f in lfs.dir(ipaFolder) do
		os.remove(ipaFolder..f)
	end
end
local infoPlistTpl = loadText(PROJECT_PATH.."build/scripts/Info.plist")
saveTo( projDir.."/ios/Info.plist", string.format(infoPlistTpl, app_name, packageName, args.version, args.version) )

local mode = " -c Release"
local libs = {
	"tools/simulator/libsimulator/proj.ios_mac",
	"cocos/quick_libs/proj.ios_mac",
	"cocos/scripting/lua-bindings/proj.ios_mac",
}

print("--------- build libs -----------")
for k, v in ipairs(libs) do
	local dir = PROJECT_PATH .. "frameworks/cocos2d-x/" .. v
	os.execute(PROJECT_PATH.."build/ios/ipa-build " .. dir ..mode)
end

print("--------- build ipa -----------")
print("execute:".."ipa-build " .. projDir ..mode)
os.execute(PROJECT_PATH.."build/ios/ipa-build " .. projDir ..mode)

print("--------- copy ipa -----------")
for f in lfs.dir(ipaFolder) do
	os.rename(ipaFolder..f, PROJECT_PATH.."publish/ios/pack/" .. shortName .. "-" .. args.platform .. ".ipa")
end
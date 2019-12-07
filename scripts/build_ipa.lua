require("utils")
require("cfg")

mkDirs("publish/" .. args.platform, PROJECT_PATH)
local appFolder = loadText(PROJECT_PATH.."src/app_folder.lua")
local platformName = loadText(PROJECT_PATH.."src/platform_name.lua")
saveTo(PROJECT_PATH.."src/app_folder.lua", "return \""..packageName.."\"")
saveTo(PROJECT_PATH.."src/platform_name.lua", "return \""..args.platform.."\"")

local func = loadstring(os.date( "return tonumber('%y')*372+tonumber('%m')*31+tonumber('%d')", os.time() ))
local ret, buildNum = pcall(func)

local bigVersion = loadLua( VERSION_PATH )
if not bigVersion then
	bigVersion = "0.0.0"
else
	local arr = string.split(bigVersion, "%.")
	if #arr==4 then
		bigVersion = arr[1] .. "." .. arr[2] .. "." .. arr[3]
	end
end

local __version = bigVersion .. "." .. buildNum

saveTo(VERSION_PATH, "return \""..__version .."\"")


local projDir = PROJECT_PATH .. "frameworks/runtime-src/proj.ios_mac"
local ipaFolder = projDir.. "/build/ipa-build/"
if isExist(ipaFolder) then
	for f in lfs.dir(ipaFolder) do
		os.remove(ipaFolder..f)
	end
end
local infoPlistTpl = loadText(PROJECT_PATH.."build/scripts/Info.plist")
saveTo( projDir.."/ios/Info.plist", string.format(infoPlistTpl, app_name, packageName, bigVersion, bigVersion) )

if args.release=="1" then
	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "src/ -d " .. PROJECT_PATH .. "luac/src/ --encrypt -k 2dxLua -b XXTEA --disable-compile")
	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "platform_cfg/ -d " .. PROJECT_PATH .. "luac/platform_cfg/ --encrypt -k 2dxLua -b XXTEA --disable-compile")
	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "res/ -d " .. PROJECT_PATH .. "luac/res/ --encrypt -k 2dxLua -b XXTEA --disable-compile")
end
local projCfg = loadText(projDir.."/project_wly2_lua_client.xcodeproj/project.pbxproj")
projCfg = string.gsub(projCfg, "shellScript = \"[%w%d%s%$%{%.%-%}%*;\\_/\"]*\";", function(x)
		 		return "shellScript = \"" ..
		 				"rm -R -f $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/src/\\n" ..
		 				"rm -R -f $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/platform_cfg/\\n" ..
		 				"mkdir $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/platform_cfg\\n" ..
		 				"cp -R -f ${SRCROOT}/../../../luac/platform_cfg/" .. args.platform .. "/ $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/platform_cfg/\\n" ..
		 				"cp -R -f ${SRCROOT}/../../../luac/src/ $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/src/\\n" ..
		 				"cp -R -f ${SRCROOT}/../../../res/" .. args.lang .. "/ $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/res/" .. args.lang .. "/\\n" ..
		 				"rm -R -f $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/res/" .. args.lang .. "/data\\n" ..
		 				"rm -R -f $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/res/" .. args.lang .. "/text\\n" ..
		 				"cp -R -f ${SRCROOT}/../../../luac/res/" .. args.lang .. "/data/ $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/res/" .. args.lang .. "/data/\\n" ..
		 				"cp -R -f ${SRCROOT}/../../../luac/res/" .. args.lang .. "/text/ $TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/res/" .. args.lang .. "/text/\\n" ..
		 				"\";"
			end)

projCfg = string.gsub(projCfg, "PROVISIONING_PROFILE = \"[%-%d%w]*\";", function(x)
		 		return "PROVISIONING_PROFILE = \"" .. profile .. "\";"
			end)

saveTo(projDir.."/project_wly2_lua_client.xcodeproj/project.pbxproj", projCfg)

local mode = ""
if args.release=="1" then
	mode = mode .. " -c Release"
else
	mode = mode .. " -c Debug"
end
local libs = {
	"tools/simulator/libsimulator/proj.ios_mac",
	"cocos/quick_libs/proj.ios_mac",
	"cocos/scripting/lua-bindings/proj.ios_mac",
}
print("--------- build libs -----------")
for k,v in ipairs(libs) do
	local dir = PROJECT_PATH .. "frameworks/cocos2d-x/" .. v
	os.execute(PROJECT_PATH.."build/ios/ipa-build " .. dir ..mode)
end

print("--------- build ipa -----------")
print("execute:".."ipa-build " .. projDir ..mode)
os.execute(PROJECT_PATH.."build/ios/ipa-build " .. projDir ..mode)

print("--------- copy ipa -----------")
for f in lfs.dir(ipaFolder) do
	os.rename(ipaFolder..f, PROJECT_PATH.."publish/" .. args.platform .. "/" ..shortName.."-"..args.platform.."-"..__version..".ipa")
end

saveTo(PROJECT_PATH.."src/app_folder.lua", appFolder)
saveTo(PROJECT_PATH.."src/platform_name.lua", platformName)

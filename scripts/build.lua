require("utils")
require("cfg")
require("sdk")


local RES_TYPE = {"png", "jpg", "plist", "max", "csb", "c3b", "vert", "frag", "fsh", "vsh"}
local __version = nil
local __lastVersion = nil
local __versionFolder = nil
local __libFolder = nil
local __resFolder = nil
local __md5Folder = nil
local __newestFlist = nil
local __isFirstVersion = false
local __isNewVersion = true
local __isNewBigVersion = true
local _apkName = nil
local __updatePackagePath = nil
local needUpdateResPackage = false

local cdnFolder = "update"--args.platform
__versionFolder=OUTPUT_FOLDER..cdnFolder.."/versions/"
__libFolder=OUTPUT_FOLDER..cdnFolder.."/lib/"
__md5Folder=OUTPUT_FOLDER..cdnFolder.."/md5/"
__resFolder=OUTPUT_FOLDER..cdnFolder.."/res/"


local function clearEmpty( path, removed )
	local empty = true
	for f in lfs.dir( path ) do
		if string.sub(f, 1,1)~="." then
			if isDir(path .. "\\" .. f ) then

				if clearEmpty( path .. "\\" .. f, true ) then
					--os.remove(path .. "/" .. f)
				else
					empty = false
				end
			else
				empty = false
			end
		end
	end
	if empty and removed then
		print(path, empty)
		removePath(path)
	end
	return empty
end
function updatePackage( day, rePack )
	local path = "..\\..\\publish\\update\\update_" .. day .. "\\res"
	if args.isWin~="1" then
		path = string.gsub( path, "\\\\", "/")
	end
	if isExist(path) then
		clearEmpty( path )
		local out =  "..\\..\\publish\\update\\res_" .. __version .. ".zip"
		if rePack then
			-- local flist = loadLua("..\\..\\publish\\update\\update_5853\\versions\\flist_1.0.4." .. day .. ".lua")
			print("pack res_" .. __version .. ".zip")
			if args.isWin=="1" then
				os.execute( "..\\compile\\pack_files.bat -q -i " .. path .. " -o "  .. out .. " -m zip")
			else
				os.execute( "sh ../compile/pack_files.sh -q -i " .. path .. " -o "  .. out .. " -m zip")
			end
		end
		return fileMd5(out) or ""
	end
	return false
end

--更新flist和版本
local versionArr = loadLua(__versionFolder.."versions.lua") or {}
-- 删除多余flist项
local function fit_flist()
	print("fit_flist")
	for i=#versionArr, 2, -1 do
		local fileMap = {}
		local ver = versionArr[i].version;
		-- if i==#versionArr then
		-- 	ver = "newest"
		-- end
		local lastFlist = loadLua(__versionFolder.."flist_"..ver..".lua")
		if lastFlist then
			for k,v in ipairs(lastFlist) do
				fileMap[v.folder .. "/" .. v.file] = true
			end
			for k=i-1, 1, -1 do
				local flist = loadLua(__versionFolder.."flist_"..versionArr[k].version..".lua")
				local change = false
				local day = string.split(versionArr[k].version, "%.")
				day = day[#day]
				lastPath = PROJECT_PATH .. "/publish/" .. cdnFolder .. "/update_" .. day .. "/"
				for j=#flist, 1, -1 do
					local v = flist[j]
					if fileMap[v.folder .. "/" .. v.file] then
						print(v.folder .. "/" .. v.file, "update new version:".. versionArr[k].version .. "==>" .. ver)
						-- os.remove( lastPath .. v.folder .. "/" .. v.file)
						table.remove(flist, j)
						change = true
					end
				end
				if change then
					saveTo( __versionFolder.."flist_"..versionArr[k].version..".lua", "return "..serialize(flist) )
					-- updatePackage(day, true)
				end
			end
		end
		local day = string.split(versionArr[i].version, "%.")
		local zipPath = PROJECT_PATH .. "/publish/" .. cdnFolder .. "/res_" .. day[#day] .. ".zip"
		if not isExist(zipPath) then
			zipPath = PROJECT_PATH .. "/publish/" .. cdnFolder .. "/res_" .. versionArr[i].version .. ".zip"
		end
		if isExist(zipPath) then
			versionArr[i].zipMd5 = fileMd5(zipPath)
			versionArr[i].zipSize = fileSize(zipPath)
		end
		versionArr[i].restart = nil
	end
	-- for f in lfs.dir(__versionFolder) do
	local lastRestartVersion = nil
	local allFlist = {}
	for k,ver in ipairs(versionArr) do
		local f = "flist_" .. ver.version .. ".lua"
		-- print("fit:",ver.version)
		if --[[f~="." and f~=".." and f~="versions.lua" and ]]not isDir(__versionFolder..f) then
			local flist = loadLua(__versionFolder..f)
			if flist then
				allFlist[ver.version] = flist
				local change = false
				for m,v in ipairs(flist) do
					local md5 = fileMd5(OUTPUT_FOLDER..cdnFolder.."/"..v.folder .. "/" .. v.file)
					if md5~=v.md5 then
						change = true
						print(v.folder .. "/" .. v.file, tostring(v.md5) .. "==>" .. tostring(md5))
						if md5 then
							mkDirs(v.folder, __updatePackagePath)
							copyFile(OUTPUT_FOLDER..cdnFolder.."/"..v.folder .. "/" .. v.file, __updatePackagePath..v.folder .. "/" .. v.file)
							v.md5 = md5
						end
					end
					if string.find(v.folder, "/launcher") then
						--launcher更新，需重启
						if lastRestartVersion and lastRestartVersion~=ver then
							lastRestartVersion.restart = nil
						end
						ver.restart = true
						lastRestartVersion = ver
					end
				end
				if change then
					saveTo( __versionFolder..f, "return "..serialize(flist) )
				end
			end
		end
	end

	saveTo( __versionFolder.."flist.lua", "return " .. serialize(allFlist) )
end
local func = loadstring(os.date( "return tonumber('%y')*372+tonumber('%m')*31+tonumber('%d')", os.time() ))
local ret, buildNum = pcall(func)

if args.version and #args.version>0 then
	local arr = string.split(args.version, "%.")
	if #arr~=4 then
		print("version must be: x.x.x.xxx, but is " .. args.version)
	else
		--指定的版本必须是已存在的
		for k,v in pairs(versionArr) do
			if v.version==args.version then
				__version = args.version
				if k>1 then
					__lastVersion = versionArr[k-1].version
				end
				break
			end
		end
		if not __version then
			print(args.version .. " not exists.")
		end
		buildNum = arr[#arr]
	end
end
if __version then
	__isNewVersion = false
	__isNewBigVersion = false
else
	args.version = nil
	local bigVersion = loadLua( VERSION_PATH )
	if type(bigVersion)=="table" then
		bigVersion = bigVersion[1]
	end
	if not bigVersion then
		bigVersion = "0.0.0"
	else
		local arr = string.split(bigVersion, "%.")
		if #arr>=4 then
			bigVersion = arr[1] .. "." .. arr[2] .. "." .. arr[3]
		end
	end

	__version = bigVersion .. "." .. buildNum


	for k,v in pairs(versionArr) do
		if v.version==__version then
			__isNewVersion = false
		end
		if string.find(v.version,bigVersion) then
			__isNewBigVersion = false
		end
	end
end

__updateFolder = "publish/" .. cdnFolder .. "/" .. "update_"..buildNum.."/"
__updatePackagePath = PROJECT_PATH..__updateFolder
mkDirs(__updateFolder, PROJECT_PATH)
mkDirs("lib", __updatePackagePath)
mkDirs("res", __updatePackagePath)
mkDirs("versions", __updatePackagePath)

mkDirs(cdnFolder.."/lib", OUTPUT_FOLDER)
mkDirs(cdnFolder.."/res", OUTPUT_FOLDER)
mkDirs(cdnFolder.."/md5", OUTPUT_FOLDER)
mkDirs(cdnFolder.."/versions", OUTPUT_FOLDER)

local function copyFlistFiles( flist )
	if not flist then
		return
	end
	for k,v in ipairs(flist) do
		local path = OUTPUT_FOLDER..cdnFolder.."/"..v.folder .. "/" .. v.file
		mkDirs(v.folder, __updatePackagePath)
		copyFile(path, __updatePackagePath..v.folder .. "/" .. v.file )
	end
end
local function getNewestFlist()
	if __newestFlist==nil then
		-- local file = "flist_newest.lua"
		local file = "flist_" .. __version .. ".lua"
		if args.version then
			file = "flist_" ..  args.version .. ".lua"
		end
		__newestFlist = loadLua(__versionFolder..file) or {}
	end
	return __newestFlist
end
local function saveNewestFlist()
	getNewestFlist()
	local file = "flist_" .. __version .. ".lua"
	-- local file = "flist_newest.lua"
	if args.version then
		file = "flist_" ..  args.version .. ".lua"
	-- else
	-- 	saveTo( __versionFolder.."flist_newest.lua", "return " .. serialize(__newestFlist) )
	end
	saveTo( __versionFolder..file, "return " .. serialize(__newestFlist) )
end
local function getFlistItem( folder, file )
	getNewestFlist()
	local item = nil
	for k,v in pairs(__newestFlist) do
		if v.file==file and v.folder==folder then
			item = v
			break;
		end
	end
	if item==nil and not args.version then
		--添加老文件
		item = {folder=folder, file=file}
		table.insert(__newestFlist, item)
	end

	return item
end

local function updateVersion()
	--更新android配置的版本
	print("current version is : " .. __version)


	for k,v in ipairs(versionArr) do
		local flist = __versionFolder.."flist_"..v.version..".lua"
		if not isExist(flist) then
			saveTo( flist, "return {}" )
		end
	end
	if __isNewVersion then
		print("add new version:" .. __version)
		versionArr[#versionArr+1] = {version=__version}
		for k,v in ipairs(versionArr) do
			print(v.version)
		end
	end

	if args.apk=="1" then
		local path = PROJECT_PATH.."frameworks/runtime-src/proj.android/AndroidManifest.xml"
		local xmlfile = loadXml( path )
		if xmlfile~=nil then

			local root = xmlfile:children()[1]
			local code = tonumber(root["@android:versionCode"])+1
			root:addProperty("android:versionCode", code)
			root:addProperty("android:versionName", __version)
			root:addProperty("package", packageName)
			xmlParser:save(xmlfile, path)

			_apkName = shortName .. "-" .. args.platform .. "-" .. __version .. "-" .. code .. ".apk"
		end

		--更新appname.
		path = PROJECT_PATH.."frameworks/runtime-src/proj.android/res/values/strings.xml"
		xmlfile = loadXml(path)
		if xmlfile~=nil then
			local el = xmlfile:children()[1]:children()[1]
			el:setValue( app_name )

			xmlParser:save(xmlfile, path)
		end

		--更新build-cfg
		local tpl = nil
		-- if args.jit=="0" then
		-- 	tpl = io.open(PROJECT_PATH.."build/scripts/build-cfg.json","rt")
		-- else
		-- 	tpl = io.open(PROJECT_PATH.."build/scripts/build-cfg-jit.json","rt")
		-- end
		tpl = io.open(PROJECT_PATH.."build/scripts/build-cfg.json","rt")

		local text = tpl:read("*a")
		text = string.format(text, args.lang, args.platform)

		path = PROJECT_PATH.."frameworks/runtime-src/proj.android/build-cfg.json"
		saveTo(path, text)
		path = PROJECT_PATH.."frameworks/runtime-src/proj.win32/build-cfg.json"
		saveTo(path, text)
	end

	__isFirstVersion = #versionArr==1-- and args.apk=="1"

	saveNewestFlist()

	if #versionArr>1 and not __lastVersion then
		__lastVersion = versionArr[#versionArr-1].version
		print("get last version:" .. __lastVersion)
	end
	if __isNewVersion then
		--如果是新版本，则将之前的flist_newest.lua存为版本flist，不再变更，新建flist_newest内容保存最新变动

		if __lastVersion then
			-- print("move flist to:" .. __lastVersion)
			-- moveFile(__versionFolder.."flist_newest.lua", __versionFolder.."flist_"..__lastVersion..".lua")
			__newestFlist = nil
			-- for md5File in lfs.dir(__md5Folder) do
			-- 	if not isDir(__md5Folder..md5File) then
			-- 		local tail = string.sub( md5File, #md5File-9, #md5File)
			-- 		if tail == "newest.lua" then
			-- 			local header = string.sub( md5File, 1, #md5File-10)
			-- 			copyFile(__md5Folder..md5File, __md5Folder..header..__lastVersion..".lua")
			-- 		end
			-- 	end
			-- end
		end
		saveNewestFlist()

		--打包文件
		-- local lastDay = string.split(__lastVersion, "%.")
		-- lastDay = lastDay[#lastDay]
		-- print("-----------------------zip last update package: res_" .. lastDay .. ".zip")
		-- local arg = "-q -i " .. "..\\..\\publish\\" .. cdnFolder .. "\\update_" .. lastDay .. "\\res -o " .. "..\\..\\publish\\" .. cdnFolder .. "\\res_" .. lastDay .. ".zip -m zip"
		-- if args.isWin=="1" then
		-- 	os.execute( "..\\compile\\pack_files.bat " .. arg)
		-- else
		-- 	os.execute( "sh ../compile/pack_files.sh " .. string.gsub(arg, "\\\\", "/") )
		-- end
	end
	for k,v in ipairs(versionArr) do
		v.md5 = fileMd5(__versionFolder.."flist_"..v.version..".lua")
	end
	if args.forceupdate=="1" then
		versionArr[#versionArr].forceUpdate = _apkName
	end
end

local function packageRes( folder, change, fileTypes )
	if not change then
		return
	end
	print("packet res:" .. folder)
	local arr = string.split(folder, "/")
	local resFolder = arr[#arr-1]
	local allFiles = getAllFiles( folder, "", fileTypes)
	local item = nil
	local newestFlist = getNewestFlist()
	for k,list in pairs(allFiles) do
		if k=="__root__" then
			k = resFolder
		else
			k = resFolder .. "/" .. k
		end
		local destFolder = "res/" .. k
		if #list>0 then
			mkDirs(k, __resFolder)
			mkDirs(k, __updatePackagePath .. "res/")
		end
		for i,f in ipairs(list) do
			--local arr1 = string.split(destFolder, "/")
			local arr2 = string.split(f, "/")
			local fileName = arr2[#arr2]
			local item = getFlistItem(destFolder, fileName)
			if item then
				item.md5 = fileMd5(folder..f)
				item.size = fileSize(folder..f)
				copyFile(folder..f, __updatePackagePath .. "res/"..resFolder.."/"..f)
				moveFile(folder..f, __resFolder..resFolder.."/"..f)
			end
		end
	end
	saveNewestFlist()
end
local function packageLua( folder, change, fileNameFormat, prefix, keepFolder )
	if not change then
		return
	end
	-- local arr = string.split(folder, "/")
	-- local parentFolder = ""
	-- for k=#arr, 1, -1 do
	-- 	if arr[k]~="" then
	-- 		parentFolder = arr[k]
	-- 		break
	-- 	end
	-- end
	-- if keepFolder and parentFolder~="" then
	-- 	fileNameFormat = parentFolder .. "_" .. fileNameFormat
	-- end
	-- local packagePath = string.format(__libFolder .. fileNameFormat, __version)

	-- local file = string.format(fileNameFormat, __version)
	-- local item = getFlistItem("lib", file)
	-- if not item then
	-- 	return ;
	-- end
	-- print("package lua:".. folder .. "["..fileNameFormat.."] ==> " .. packagePath)
	-- --打包lua
	-- os.remove(packagePath)

	--local cmd = "%QUICK_V3_ROOT%quick/bin/compile_scripts.bat -i ../src/app -p app -o output/update/lib/game.zip -e xxtea_chunk -ek 2dxLua -es uqee"
	-- local cmd = ""
	-- if args.isWin=="1" then
	-- 	cmd = "..\\compile\\compile_scripts.bat -i %s "
	-- else
	-- 	cmd = "sh ../compile/compile_scripts.sh -i %s "
	-- end
	-- if prefix~="" then
	-- 	cmd = cmd .. "-p "
	-- end
	-- cmd = cmd .. "%s -o %s"
	-- if args.jit~="0" then
	-- 	cmd = cmd .. " -jit"
	-- end
	-- if args.encrypt~="0" then
	-- 	--xxtea_chunk,xxtea_zip
	-- 	cmd = cmd .. " -e xxtea_chunk -ek 2dxLua -es uqee"
	-- end
	-- if not prefix then
	-- 	prefix = parentFolder
	-- end
	-- cmd = string.format(cmd, folder, prefix, packagePath)
	-- os.execute(cmd)
	local dest = folder
	if prefix then
		local arr = string.split(folder, "/")
		if arr[#arr]=="" then
			arr[#arr-1] = arr[#arr-1] .. prefix
		else
			arr[#arr] = arr[#arr] .. prefix
		end
		dest = table.concat(arr, "/")
	end
	local cmd = "cocos luacompile -s " .. folder .. " -d " .. dest .. " --encrypt -k 2dxLua -b XXTEA --disable-compile"
	print(cmd)
	os.execute(cmd)
	packageRes(dest, change, {"luac"})
	-- local zipFiles = {}
	-- function zip_luac( folder )
	-- 	for f in lfs.dir(folder) do
	-- 		if f~="." and f~=".." then
	-- 			if isDir(folder.."/"..f) then
	-- 				zip_luac(folder.."/"..f)
	-- 			else
	-- 				if string.find(f, ".luac") then
	-- 					os.rename(folder.."/"..f, folder.."/"..prefix..f)
	-- 					zipFiles[#zipFiles] = folder.."/"..prefix..f
	-- 				else
	-- 					os.remove(folder.."/"..f)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- zip_luac(folder)
	-- os.execute("makecab " .. folder .. " " .. __updatePackagePath .. "lib/"..file)
	-- -- local ok, err = zip(__updatePackagePath .. "lib/"..file, unpack(zipFiles))
	-- -- if err then
	-- -- 	print("zip failed:"..err)
	-- -- end
	-- -- copyFile(packagePath, __updatePackagePath .. "lib/"..file)
	-- print("cmd done:" .. "makecab " .. folder .. " " .. __updatePackagePath .. "lib/"..file)
	-- item.md5 = fileMd5(packagePath)
	-- item.size = fileSize(packagePath)
	-- if not item.md5 then
	-- 	for k,v in ipairs(__newestFlist) do
	-- 		if v==item then
	-- 			table.remove(__newestFlist, k)
	-- 			break;
	-- 		end
	-- 	end
	-- end
	-- saveNewestFlist()
end
local function packageApp( folder, change )
	packageLua( folder, change, "game_%s.zip")
end
local function packageLauncher( folder, change )
	packageLua( folder, change, "launcher.zip")
end
local function packagePlatformCfg( folder, change )
	packageLua( folder, change, "platform_cfg.zip", "_platform_cfg")
end
local function packageStaticText( folder, change )
	packageLua( folder, change)
	-- if change then
	-- 	for f in lfs.dir(folder) do
	-- 		if not isDir(folder..f) then
	-- 			-- local name = string.gsub(f, ".lua", "")
	-- 			-- lfs.mkdir(folder..name)
	-- 			-- moveFile(folder..f, folder..name.."/"..f)
	-- 			packageLua( folder..name.."/", true, name .. ".zip")
	-- 		end
	-- 	end
	-- end
end
local function packageStaticData( folder, change )
	packageLua( folder, change)
	-- if change then
	-- 	for f in lfs.dir(folder) do
	-- 		if not isDir(folder..f) then
	-- 			local name = string.gsub(f, ".lua", "")
	-- 			lfs.mkdir(folder..name)
	-- 			moveFile(folder..f, folder..name.."/"..f)
	-- 			packageLua( folder..name.."/", true, name .. ".zip")
	-- 		end
	-- 	end
	-- end
end


local function packageChange( srcFolder, fileTypes, callback, prefix, copyAll, keepFolder )
	local tmpPath = PROJECT_PATH .. "__temp/" .. srcFolder
	local srcPath = PROJECT_PATH .. srcFolder
	mkDirs("__temp/" .. srcFolder, PROJECT_PATH)

	local parentFolder = ""
	local arr = string.split(srcFolder, "/")
	for k=#arr, 1, -1 do
		if arr[k]~="" then
			parentFolder = arr[k]
			break
		end
	end
	if not prefix then
		prefix = parentFolder
	end

	if keepFolder then
		prefix = parentFolder .. "_" .. prefix
	end
	local allFiles = getAllFiles( srcPath, "", fileTypes)
	local md5Path = __md5Folder .. prefix .. "_%s.lua"
	local md5Ver = __version-- "newest"
	if args.version then
		md5Ver = args.version
	end

	local md5NewestList = loadLua(string.format(md5Path,md5Ver))
	local isNew = false
	if not md5NewestList then
		isNew = true
		md5NewestList = {}
	end

	local md5List = loadLua(string.format(md5Path,__lastVersion or "")) or md5NewestList
	local newMd5List = {}
	local needSave = false
	local change = false
	for folder,list in pairs(allFiles) do
		if folder~="api" then
			if folder=="__root__" then
				folder = ""
			else
				mkDirs(folder, tmpPath)
			end
			for k,f in ipairs(list) do
				local key = f
				local md5 = fileMd5(srcPath..f)
				local notFirst = not __isFirstVersion or md5NewestList[key]~=nil
				newMd5List[key] = md5
				local fileChanged = false
				if isNew or not md5NewestList[key] then
					fileChanged = md5List[key]~=md5
				else
					fileChanged = md5NewestList[key]~=md5
				end
				if fileChanged then
					needSave = true
					if notFirst then
						change = true
						--第一个版本，如果文件没有MD5，不需要复制，只需存好MD5
						print(srcPath..f,"==>",md5List[key],md5,md5NewestList[key])

						copyFile(srcPath..f, tmpPath..f)
					end
				end
			end
		end
	end

	-- if change and copyAll then
	-- 	for folder,list in pairs(allFiles) do
	-- 		if folder=="__root__" then
	-- 			folder = ""
	-- 		else
	-- 			mkDirs(folder, tmpPath)
	-- 		end
	-- 		for k,f in ipairs(list) do
	-- 			copyFile(srcPath..f, tmpPath..f)
	-- 		end
	-- 	end
	-- end
	needUpdateResPackage = needUpdateResPackage or change

	callback( tmpPath, change,fileTypes )

	if needSave or isNew then
		saveTo( string.format(md5Path, md5Ver), "return "..serialize(newMd5List) )
	end
end

local destFolder = PROJECT_PATH .. "res/%s/%s/"
mkDirs("build/output", PROJECT_PATH)

function checkChange()
	updateVersion()

	packageChange(string.format("res/%s/dat/", args.lang), {"dat"}, packageRes)
	packageChange(string.format("res/%s/img/", args.lang), RES_TYPE, packageRes)
	packageChange(string.format("res/%s/font/", args.lang), {"ttf", "fnt", "TTF", "png"}, packageRes)
	packageChange(string.format("res/%s/sound/", args.lang), {"aac", "mp3"}, packageRes)
	packageChange(string.format("res/%s/data/", args.lang), {"lua"}, packageStaticData)
	packageChange(string.format("res/%s/text/", args.lang), {"lua"}, packageStaticText)

	packageChange("src/app/", {"lua"}, packageApp)
	packageChange("src/launcher/", {"lua"}, packageLauncher, nil, true)
	for platform,_ in pairs(packageNames) do
		packageChange(string.format("platform_cfg/%s/", platform), {"lua"}, packagePlatformCfg, "platform_cfg", true, true)
	end
	-- for platform,_ in pairs(packageNames) do
	-- 	lfs.mkdir(__versionFolder..platform)
	-- 	for f in lfs.dir(__versionFolder) do
	-- 		if string.find(f, ".lua") then
	-- 			copyFile(__versionFolder..f, __versionFolder..platform.."/"..f)
	-- 		end
	-- 	end
	-- 	if args.apk=="1" and platform==args.platform then
	-- 		saveTo(__versionFolder..platform.."flist_newest.lua", "return {}")
	-- 	end
	-- end
end

if __version~=nil then
	mkDirs(args.lang.."/img", PROJECT_PATH.."res/")
	mkDirs(args.lang.."/font", PROJECT_PATH.."res/")
	mkDirs(args.lang.."/sound", PROJECT_PATH.."res/")
	mkDirs(args.lang.."/data", PROJECT_PATH.."res/")
	mkDirs(args.lang.."/text", PROJECT_PATH.."res/")
	mkDirs(args.lang.."/dat", PROJECT_PATH.."res/")

	if args.apk=="1" then
		changeSdk()
	end
	if __isNewBigVersion and #versionArr>0 then
		--先编译老版本更新
		local v = __version
		local force = args.forceupdate
		local n = __isNewVersion
		local apk = args.apk
		args.apk = nil
		args.forceupdate = nil
		__isNewVersion = true
		__version = versionArr[#versionArr].version

		for k,v in pairs(versionArr) do
			if v.version==__version then
				__isNewVersion = false
			end
		end
		print("last version:",__version)
		saveTo(PROJECT_PATH.."src/lang.lua", "return \"" .. args.lang .. "\"")
		checkChange()
		__newestFlist = nil
		__version = v
		__isNewVersion = n
		args.forceupdate = force
		args.apk = apk
	end
	-- saveTo(VERSION_PATH, "return \"" .. __version .. "\"")

	needUpdateResPackage = false
	saveTo(PROJECT_PATH.."src/lang.lua", "return \"" .. args.lang .. "\"")
	checkChange()

	local lastResMd5 = updatePackage(buildNum, needUpdateResPackage)
	fit_flist()
	if args.full=="1" then
		for f in lfs.dir(__versionFolder) do
			local arr = string.split(f, "%.")
			if #arr>1 and arr[#arr-1]==tostring(buildNum) then
				copyFlistFiles(loadLua(__versionFolder..f) )
			end
		end
		-- copyFlistFiles(loadLua(__versionFolder.."flist_newest.lua") )
	end
	--清空临时目录
	saveTo(VERSION_PATH, "return \""..__version .."\"")
	saveTo(PROJECT_PATH.."src/version_md5.lua", "return \"" .. lastResMd5 .. "\"")
	removePath( PROJECT_PATH .. "__temp" )
	if args.apk=="1" then
		-- if args.jit~="0" then
		-- 	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "src/ -d " .. PROJECT_PATH .. "luac/src/ --encrypt -k 2dxLua -b XXTEA")
		-- 	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "platform_cfg/ -d " .. PROJECT_PATH .. "luac/platform_cfg/ --encrypt -k 2dxLua -b XXTEA")
		-- 	os.execute("cocos luacompile -s " .. PROJECT_PATH .. "res/ -d " .. PROJECT_PATH .. "luac/res/ --encrypt -k 2dxLua -b XXTEA")
		-- end

		local mode = ""
		local srcApk = ""
		if args.release=="1" then
			mode = " -m release"
			srcApk = PROJECT_PATH .. "/publish/android/project_wly2_lua_client-release-signed.apk"
		else
			srcApk = PROJECT_PATH .. "/runtime/android/project_wly2_lua_client-debug.apk"
			if not isExist(srcApk) then
				srcApk = PROJECT_PATH .. "/simulator/android/project_wly2_lua_client-debug.apk"
			end
		end
		print("execute:".."cocos compile -p android --ap android-15 --app-aib armeabi:x86:mips -compile-script -lua-encrypt True -lua-encrypt-key 2dxLua -lua-encrypt-sign uqee"..mode)
		os.execute("cocos compile -p android --app-aib armeabi:x86:mips -compile-script -lua-encrypt True -lua-encrypt-key 2dxLua -lua-encrypt-sign uqee"..mode)
		if _apkName then
			print("move apk:",srcApk, PROJECT_PATH .. "/publish/" .. cdnFolder .. "/" .. _apkName)
			moveFile(srcApk, PROJECT_PATH .. "/publish/" .. cdnFolder .. "/" .. _apkName)
		end
	end
	saveTo( __versionFolder.."versions.lua", "return "..serialize(versionArr) )
	for f in lfs.dir(__versionFolder) do
		if not isDir(__versionFolder..f) then
			copyFile(__versionFolder..f, __updatePackagePath.."versions/"..f)
		end
	end
	saveTo(PROJECT_PATH.."src/lang.lua", "return \"local\"")
	saveTo(PROJECT_PATH.."src/app_folder.lua", "return \"com.cn.bldld\"")
	saveTo(PROJECT_PATH.."src/platform_name.lua", "return \"local\"")

	local path = ""
	if args.isWin=="1" then
		path = "..\\..\\publish\\update\\update_" .. buildNum
		local outPath = "..\\..\\publish\\update\\update_" .. __version
		print("pack update_" .. buildNum .. ".zip")
		os.execute( "..\\compile\\pack_files.bat -q -i " .. path .. " -o " .. outPath .. ".zip -m zip")
	else
		path = "../../publish/update/update_" .. buildNum
		local outPath = "../../publish/update/update_" .. __version
		print("pack update_" .. buildNum .. ".zip")
		os.execute( "sh ../compile/pack_files.sh -q -i " .. path .. " -o " .. outPath .. ".zip -m zip")
	end
	-- moveFile(path .. "/res_" .. buildNum .. ".zip" , "../../publish/update/res_" .. buildNum .. ".zip")

	if args.platform=="local" and args.isWin=="1" then
		local path = "f:\\wly_client\\v162\\wly_publish\\release\\update_121"
		local mode = lfs.attributes(path, "mode")

		if mode then
			local srcPath = string.gsub(__updatePackagePath, "/", "\\")
			local cmd = "xcopy /S /Y /Q " .. string.sub(srcPath,1,#srcPath-1) .. " " .. path .. "\\"
			print(cmd)
			os.execute(cmd)
			cmd = "copy /Y ..\\..\\publish\\" .. cdnFolder .. "\\res_*.zip " .. path .. "\\"
			print(cmd)
			os.execute(cmd)
		end
	end

end
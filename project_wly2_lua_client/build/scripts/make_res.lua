require("utils")
require("cfg")



--合并目录中的所有图片成一个texture
local function mergeImage(srcFolder, destFolder, file, change)
	if change or not isExist(destFolder..file..".png") then
		--合并图片
		print("pack image:"..file)
		os.remove(destFolder..file..".png")
		os.remove(destFolder..file..".plist")

		local format = "cocos2d"
		-- --texture-format png --algorithm MaxRects --enable-rotation --png-opt-level 1 --trim-mode Trim --maxrects-heuristics best --max-width 2048 --max-height 2048 --padding 2
		--local cmd = "TexturePacker --sheet %s.png --data %s.plist --format %s %s";
		--os.execute( string.format(cmd, destFolder..file, destFolder..file, format, srcFolder..file) )
		local cmd,cmdFile,tinypng
		if args.isWin=="1" then
			cmd = "\"%%JAVA_HOME%%/bin/java\""
			cmdFile = "__tmp.bat"
			tinypng = PROJECT_PATH .. "build/pngquant/"
		else
			cmd = "\"/usr/bin/java\""
			cmdFile = "__tmp.sh"
			tinypng = PROJECT_PATH .. "build/pngquant/"
		end
		cmd = cmd .. " SpriteSheetMaker -folder %s -out %s -fileTypes .png,.jpg\n"
		cmd = string.format(cmd, srcFolder..file, destFolder..file)
		if isExist(tinypng.."pngquant.exe") then
			cmd = cmd .. "\"" .. tinypng .. "pngquant\" -f --ext .png --quality 10-90 --speed 1 " .. destFolder..file .. ".png"
		end

		print( cmd )
		saveTo(cmdFile, cmd)
		if args.isWin=="1" then
			os.execute( cmdFile )
		else
			os.execute( "sh " .. cmdFile)
		end
		os.remove(cmdFile)
	end
end

local function mergeData( srcFolder, destFolder, file, change )
	if change or not isExist(destFolder..file..".lua") then
		--合并json
		os.remove(destFolder..file..".lua")

		local dataLua = file .. " = {}\n"
		local folder = srcFolder..file .. "/"
		print("pack staticdata:"..folder .."==>"..file..".lua")

		lfs.mkdir(destFolder.."/" .. file)
		for dataFile in lfs.dir(folder) do
			if not isDir(folder .. dataFile) and #dataFile>=6 then

				local fileName, fileType = getFileType(dataFile)
				local obj = nil
				if fileType=="json" then
					print("[json] not support.", folder..dataFile)
					-- local data = loadText(folder .. dataFile)
					-- local json = json.decode(data)
					-- if json==nil then
					-- 	print("[json] parse failed:"..folder .. dataFile)
					-- else
					-- 	dataLua[fileName] = json
					-- end
				elseif fileType=="xml" then
					--print(folder .. dataFile)
					local xmlDoc = loadXml(folder .. dataFile)

					if xmlDoc==nil then
						print("[xml] parse failed:"..folder .. dataFile)
					else
						obj = xmlToObj(xmlDoc:children()[1])
						local function makeIdMap(obj)
							for k,v in pairs(obj) do
								if type(v)=="table" then
									makeIdMap(v)
									for m,o in ipairs(v) do
										if o.ident then
											if not v._idMap then
												v._idMap = {}
											end
											v._idMap[o.ident] = m
										end
									end
								end
							end
						end
						makeIdMap(obj)
						-- dataLua[fileName] = obj
					end
				elseif fileType=="txt" then
					local data = loadText(folder .. dataFile)
					local list = string.split(data, "[\r\n]+")
					obj = {}

					for k,v in ipairs(list) do
						if v and string.sub(v, 1,2)~="//" then
							v = string.gsub(v, "%%s", "[%%s　]*")
							table.insert(obj, v)
						end
					end

					-- dataLua[fileName] = obj
				end
				if obj then
					saveTo(destFolder.."/" .. file .. "/"..fileName..".lua", "return " .. serialize(obj))
					dataLua = dataLua ..  file .. "." .. fileName .. "=require(\"data." .. file .. "." .. fileName .. "\")\n"
				end
			end
		end
		saveTo(destFolder..file..".lua", dataLua)
	end
end

local function mergeText( srcFolder, destFolder, file, change )
	if change or not isExist(destFolder..file..".lua") then
		--合并text
		os.remove(destFolder..file..".lua")

		local textLua = ""
		local folder = srcFolder..file .. "/"
		print("pack text:"..folder .."==>"..file..".lua")

		local colorTag, colorTagEnd = "", ""
		for textFile in lfs.dir(folder) do
			if not isDir(folder .. textFile) and #textFile>=5 then

				local fileName, fileType = getFileType(textFile)

				if fileType=="txt" then
					local data = loadText(folder .. textFile)
					local list = string.split(data, "[\r\n]+")
					for k,v in ipairs(list) do
						local arr = string.split(v, "=")
						if #arr>=2 then
							textLua = textLua .. "    [\"" .. arr[1] .. "\"] = [==[" .. string.sub(v, #arr[1]+2) .. "]==],\n"
						end
					end
				elseif fileType=="xml" then
					local xmlDoc = loadXml(folder .. textFile)

					if xmlDoc==nil then
						print("[xml] parse failed:"..folder .. textFile)
					else
						local tagTpl = "[color=%s]"
						local tagEnd = "[/color]"
						-- local tagTpl = "<font color='%s'>"
						-- local tagEnd = "</font>"
						for k,node in ipairs(xmlDoc:children()[1]:children()) do
							if node:name()=="SimpleText" then
								local txt = node:value() or ""

								if node["@color"] then
									colorTag = string.format(tagTpl, node["@color"] )
									colorTagEnd = tagEnd
								else
									colorTag = ""
									colorTagEnd = ""
								end
								-- textLua = textLua .. "    [\"" .. node.ident .. "\"] = [==[" .. colorTag .. txt .. colorTagEnd .. "]==],\n"

								textLua = textLua .. "    [\"" .. node["@ident"] .. "\"] = [==[" .. txt  .. "]==],\n"
							else
								local txt = ""
								for j,sub in ipairs(node:children()) do
									if sub["@color"] then
										colorTag = string.format(tagTpl, sub["@color"] )
										colorTagEnd = tagEnd
									else
										colorTag = ""
										colorTagEnd = ""
									end
									local tag = sub:name()
									if tag=="DynamicString" then
										txt = txt .. colorTag .. "{0}" .. colorTagEnd
									elseif tag=="String" then
										txt = txt .. colorTag .. (sub:value() or "") .. colorTagEnd
									elseif tag=="NewLine" then
										txt = txt .. "\n"
									end
								end
								txt = string.gsub(txt, "&lt;", "<")
								txt = string.gsub(txt, "&gt;", ">")
								txt = string.gsub(txt, "%%", "%%%%")
								txt = string.gsub(txt, "%{0%}", "%%s")
								if node["@color"] then
									colorTag = string.format(tagTpl, node["@color"] )
									colorTagEnd = tagEnd
								else
									colorTag = ""
									colorTagEnd = ""
								end

								-- textLua = textLua .. "    [\"" .. node.ident .. "\"] = [==[" .. colorTag .. txt .. colorTagEnd .. "]==],\n"

								textLua = textLua .. "    [\"" .. node["@ident"] .. "\"] = [==[" .. txt  .. "]==],\n"
							end
						end
					end
				end
			end
		end

		saveTo(destFolder..file..".lua", file .. " = {\n" .. textLua .. "}")
	end
end

local function merge( srcFolder, destFolder, fileTypes, callback, flatten, logFile)
	local allFiles = getAllFiles( srcFolder, nil, fileTypes, flatten)

	if flatten then
		local tmp = {}

		for folder,list in pairs(allFiles) do
			local key = string.split(folder, "/")[1]
			if not tmp[key] then
				tmp[key] = {}
			end
			for k,f in ipairs(list) do
				table.insert(tmp[key], f)
			end
		end
		allFiles = tmp
	end
	logFile = logFile or (srcFolder.."file_md5.lua")
	local md5List = loadLua(logFile) or {}
	local newMd5List = {}
	local needSave = false
	for folder,list in pairs(allFiles) do
		local change = false
		for k,f in ipairs(list) do
			local md5 = fileMd5(srcFolder..f)
			newMd5List[f] = md5
			if md5List[f]~=md5 then
				change = true
				needSave = true
			end
		end
		if #list>0 then
			callback( srcFolder, destFolder, folder, change )
		end
	end
	if needSave then
		saveTo( logFile, "return "..serialize(newMd5List) )
	end
end


local function copyDir( srcFolder, destFolder, fileTypes)
	local allFiles = getAllFiles( srcFolder, "", fileTypes)
	local md5List = loadLua(srcFolder.."file_md5.lua") or {}
	local newMd5List = {}
	local needSave = false

	for folder,list in pairs(allFiles) do
		local change = false
		if folder~="__root__" then
			mkDirs(folder, destFolder)
		end
		for k,f in ipairs(list) do
			local md5 = fileMd5(srcFolder..f)
			newMd5List[f] = md5
			if md5List[f]~=md5 then
				copyFile(srcFolder..f, destFolder..f)
				needSave = true
			end
		end
	end
	if needSave then
		saveTo( srcFolder.."file_md5.lua", "return "..serialize(newMd5List) )
	end
end

local function csd2Lua( srcFolder, destFolder)
	local allFiles = getAllFiles( srcFolder, "", {"csd"})
	local md5List = loadLua(srcFolder.."file_md5.lua") or {}
	local newMd5List = {}
	local needSave = false

	--local texMap = loadLua(PROJECT_PATH .. "src/app/ui/uitex.lua") or {}
	for folder,list in pairs(allFiles) do
		local change = false
		if folder~="__root__" then
			mkDirs(folder, destFolder)
		end
		for k,f in ipairs(list) do
			if f~="file_md5.lua" then
				local key = string.gsub(f, "%.csd", "")
				key = string.gsub(key, "/", ".")

				local md5 = fileMd5(srcFolder..f)
				newMd5List[f] = md5
				if md5List[f]~=md5 or not isExist(destFolder..f) then
					csdConvert:csd2lua(srcFolder..f, destFolder..string.gsub(f, "%.csd", ""))
					needSave = true
				end
			end
		end
	end

	if needSave then
		--saveTo( PROJECT_PATH .. "src/app/ui/uitex.lua", "return " .. serialize(texMap))
		saveTo( srcFolder.."file_md5.lua", "return "..serialize(newMd5List) )
	end
end

--冗余代码删除
local ignoreCodeMap = {
	"setPosition(0, 0)",
	"setScaleX(1)",
	"setScaleY(1)",
	"setLocalZOrder(0)",
	--"setAnchorPoint(0.5, 0.5)",
	"loadTexture(\"Default/ImageFile.png\",0)",
	"setOpacity(255)",
	"setColor(cc.c3b(255, 255, 255))",
	"setVisible(true)",
	"setRotation(0)",
	"setRotationSkewX(0)",
	"setRotationSkewY(0)",
	"setFlippedX(false)",
	"setFlippedY(false)",
	"setTitleText(\"\")",
	"setString([[]])",
	"setScale9Enabled(false)",
	--"ignoreContentAdaptWithSize(false)",
	"setPositionPercentXEnabled(false)",
	"setPositionPercentYEnabled(false)",
	"setPositionPercentX(0)",
	"setPositionPercentY(0)",
	"setPercentWidthEnabled(false)",
	"setPercentHeightEnabled(false)",
	"setPercentWidth(0)",
	"setPercentHeight(0)",
	"setHorizontalEdge(0)",
	"setVerticalEdge(0)",
	"setLeftMargin(0)",
	"setRightMargin(0)",
	"setTopMargin(0)",
	"setBottomMargin(0)",
	"setBright(true)",
	"setEnabled(true)",
	"setBackGroundImageCapInsets(cc.rect(0,0,0,0))",
	"setBackGroundImageScale9Enabled(false)",
	"setBackGroundColorType(0)",
	"setBounceEnabled(false)",
	"setDirection(1)",
}
for k,v in ipairs(ignoreCodeMap) do
	v = string.gsub(v, "%(", "%%%(")
	v = string.gsub(v, "%)", "%%%)")
	v = string.gsub(v, "%[", "%%%[")
	v = string.gsub(v, "%]", "%%%]")
	v = string.gsub(v, "%.", "%%%.")
	ignoreCodeMap[k] = v
end

local function copyCcsLua( srcFolder, destFolder)
	local allFiles = getAllFiles( srcFolder, "", {"lua"})
	local md5List = loadLua(srcFolder.."file_md5.lua") or {}
	local newMd5List = {}
	local needSave = false

	--local texMap = loadLua(PROJECT_PATH .. "src/app/ui/uitex.lua") or {}
	for folder,list in pairs(allFiles) do
		local change = false
		if folder~="__root__" then
			mkDirs(folder, destFolder)
		end
		for k,f in ipairs(list) do
			if f~="file_md5.lua" then
				local key = string.gsub(f, "%.lua", "")
				key = string.gsub(key, "/", ".")

				local md5 = fileMd5(srcFolder..f)
				newMd5List[f] = md5
				if md5List[f]~=md5 or not isExist(destFolder..f) then
					--texMap[key] = {}
					local text = loadText(srcFolder..f)
					local usedTex = {}
					text = string.gsub(text, "\"res/img/[a-zA-Z/0-9%._]+\",0", function ( x )
						local arr = string.split(x, "/")
						if #arr>3 then
							usedTex[arr[3]] = true
						end
						return "\"" .. string.sub(x, 10, #x-1) .. "1"
					end)

					local list = string.split(text, "[\r\n]+")
					text = ""
					local endLine = ""
					local fixedFlag = false
					local multiline = false
					local varName = ""
					local varNamePattern = ""
					local uiType = nil
					for i, line in ipairs(list) do

						if multiline then
							if line=="]])" then
								line = ""
							end
							multiline = false
						end
						local defineIdx = string.find(line, "ccui%.[%w]+:create")
						if defineIdx==nil then
							defineIdx = string.find(line, "ccui%.[%w]+:bindLayoutComponent")
						end
						if defineIdx==nil then
							defineIdx = string.find(line, "cc%.[%w]+:create")
						end
						if defineIdx~=nil then
							local tmp = string.sub( line, defineIdx )
							uiType = string.sub(tmp, 1, string.find(tmp, ":")-1)
						end
						for l,ignoreCode in ipairs(ignoreCodeMap) do
							if string.find(line, ignoreCode) then
								line = nil
								break;
							end
						end
						if line then
							if string.find(line, "ccui%.Text:create")~=nil then
								fixedFlag = false
								varName = string.split(line, " = ")[1]
								if string.find(varName, "local ")~=nil then
									varName = string.sub(varName, 7)
								end
								--默认为ccui.Text加一个阴影
								-- line = line .. "\n" .. varName .. ":enableShadow(cc.c4b(0,0,0,255), cc.p(0,0), 2)"
								if string.find(varName, "_auto_")~=nil and string.find(varName, "richtext_")==nil then
									--为ccui.Text修复无法自动对齐问题
									fixedFlag = true
								elseif string.find(varName, "_wrap_")~=nil then
									--为ccui.Text修复无法自动换行问题
									line = line .. "\n" .. varName .. ":ignoreContentAdaptWithSize(false)"
								end
								varNamePattern = string.gsub(varName, "%[", "%%[")
								varNamePattern = string.gsub(varNamePattern, "%]", "%%]")
							elseif string.find(line, "setFontName")~=nil then
								--替换 font/ 路径
								line = string.gsub(line, "res/font/", "font/")
								if varName~="" and string.find(varName, "_outline_") then
									local arr = string.split(varName, "_outline_")
									arr = string.split( arr[2], "_" )
									local size = 1
									if arr[2] then
										size = string.sub(arr[2], 1,1)
									end
									local r = string.sub( arr[1], 1,2 )
									local g = string.sub( arr[1], 3,4 )
									local b = string.sub( arr[1], 5,6 )
									line = line .. "\n" .. varName .. ":enableOutline(cc.c4b(0x" .. r .. ",0x" .. g .. ",0x"..b.. ",255), " .. size .. ")"
								-- elseif varName=="lbl_auto_title" then
								-- 	line = line .. "\n" .. varName .. ":enableOutline(cc.c4b(0x69,0x1f,0x12,255), 2)"
								end
							elseif string.find(line, "res/font/")~=nil then
								--替换 font/ 路径
								line = string.gsub(line, "res/font/", "font/")
								if "ccui.Button"==uiType and string.find(line, "setTitleFontName") then
									line = line .. "\n" .. string.split(line, ":")[1] .. ":getTitleRenderer():enableOutline(cc.c4b(0x27,0x1f,0x1f,255), 2)"
								end
							elseif fixedFlag and string.find(line, "layout:setSize")~=nil then
								-- _auto_ 标记的 Text 不处理 setSize，以实现对齐效果
								line = ""
								fixedFlag = false
							elseif string.find(line, "innerCSD:create")~=nil then
								-- 引用外部CSD添加自动加载 texture
								line = "innerCSD.loadTex()\ninnerProject = innerCSD.create()"
							elseif string.find(line, "innerCSD = require%(\"src/")~=nil then
								-- 引用外部csd路径
								line = string.gsub(line, "require%(\"src/", "require(\"")
								line = string.gsub(line, ".lua", "")
								line = string.gsub(line, "\/", "%.")
							elseif string.find(line, "cc.Sprite:create%(\"res/img/")~=nil then
								--替换 Sprite:create 为 Sprite:createWithSpriteFrameName
								local arr = string.split(line, "/")
								if #arr>3 then
									usedTex[arr[3]] = true
								end
								line = string.gsub(line, "cc.Sprite:create%(\"res/img/", "cc.Sprite:createWithSpriteFrameName(\"")
							elseif string.find(line, "#[%w%.%[%]\"_%*'\"]+#")~=nil then
								--匹配所有设置了 #...# 的内容，Text:setString, Button:setTitleText
								local varName2 = string.split(line, ":")[1]
								if varName2 then
									local cont = string.split(line, "#")[2]
									if string.find(cont, "%[")==nil then
										cont = "static_text[\"" .. cont .. "\"]"

										multiline = true
									end
									if string.find(line, "setString")~=nil then
										if string.find(varName2, "richtext_")~=nil then
											line = ""
											endLine = varName2 .. ":setRichText(" .. cont .. ")"
											-- endLine = varName2 .. ":setHTMLText(" .. cont .. ")"
										else
											line = varName2 .. ":setString(" .. cont .. ")"
										end
									elseif string.find(line, "setTitleText")~=nil then
										line = varName2 .. ":setTitleText(" .. cont .. ")"
									elseif string.find(line, "setPlaceHolder")~=nil then
										line = varName2 .. ":setPlaceHolder(" .. cont .. ")"
									end
								end
							elseif string.find(line, "addChild%(" .. varNamePattern .. "%)")~=nil then
								--在 addChild 后面加入 setRichText
								line = line .. "\n" .. endLine
								endLine = ""
								varName = ""
								varNamePattern = ""
							end
							if string.find(line, "return Result")==nil then
								text = text .. line .. "\n"
							end
						end
					end
					local loadTex = "function Result.loadTex()\n"
					for tex,vv in pairs(usedTex) do
						--table.insert(texMap[key], "img/" .. tex .. ".plist")
						loadTex = loadTex .. string.format("    ui.addSpriteFrames(\"%s\")\n", tex)
					end
					loadTex = loadTex .. "end\nreturn Result"
					saveTo(destFolder..f, text .. loadTex)
					needSave = true
				end
			end
		end
	end

	if needSave then
		--saveTo( PROJECT_PATH .. "src/app/ui/uitex.lua", "return " .. serialize(texMap))
		saveTo( srcFolder.."file_md5.lua", "return "..serialize(newMd5List) )
	end
end


local resFolder = RES_SOURCE_PATH .. "%s/%s/"
local destFolder = PROJECT_PATH .. "%s/%s/%s/"

__currLang = args.lang

mkDirs(__currLang.."/img", PROJECT_PATH.."res/")
mkDirs(__currLang.."/data", PROJECT_PATH.."res/")
mkDirs(__currLang.."/text", PROJECT_PATH.."res/")
mkDirs(__currLang.."/font", PROJECT_PATH.."res/")
if args.static=="1" then
	print("make static_data")
	merge( string.format(resFolder, __currLang, "data"), string.format(destFolder, "res", __currLang, "data"), {"json", "xml", "txt"}, mergeData)
	merge( string.format(resFolder, __currLang, "text"), string.format(destFolder, "res", __currLang, "text"), {"txt", "xml"},mergeText)
	copyDir( string.format(resFolder, __currLang, "img"), string.format(destFolder, "res", __currLang, "img"), {"png", "jpg"} )
end
if not args.static then

	if args.png=="1" then
		local root = PROJECT_PATH .. "res/local/img/"
		local allFiles = getAllFiles( root, "", {"png"})
		print(PROJECT_PATH .. "res/local", #allFiles)
		for folder,list in pairs(allFiles) do
			for k,f in ipairs(list) do
				print("list:",k,f)
				local cmd,cmdFile
				if args.isWin=="1" then
					cmd = "\"" .. PROJECT_PATH .. "build/pngquant/"
					cmdFile = "__tmp.bat"
				else
					cmd = PROJECT_PATH .. "build/pngquant/"
					cmdFile = "__tmp.sh"
				end
				cmd = cmd .. "pngquant\" -f --ext .png --quality 10-90 --speed 1 " .. root .. f
				print( cmd )
				saveTo(cmdFile, cmd)
				if args.isWin=="1" then
					os.execute( cmdFile )
				else
					os.execute( "sh " .. cmdFile)
				end
				os.remove(cmdFile)
			end
		end
		return
	end
	merge( PROJECT_PATH .. "ccs/cocosstudio/res/img/" , string.format(destFolder, "res", "local", "img"), {"png", "jpg"},mergeImage, true, PROJECT_PATH .. "ccs/output/res/img/file_md5.lua")
	copyDir( PROJECT_PATH .. "ccs/cocosstudio/res/font/" , PROJECT_PATH .. "res/local/font/", {"ttf", "fnt", "png"})
	-- csd2Lua(PROJECT_PATH .. "ccs/cocosstudio/src/", PROJECT_PATH .. "tmp/")
	copyCcsLua(PROJECT_PATH .. "ccs/output/src/", PROJECT_PATH .. "src/")



end

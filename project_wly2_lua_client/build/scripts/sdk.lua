
function changeSdk()
	print("------------- update proj.android[" .. args.platform .. "] ---------------------")
	local root = PROJECT_PATH.."build/platform/" .. args.sdk
	local projRoot = root .. "/proj.android"
	local dest = PROJECT_PATH.."frameworks/runtime-src/proj.android/"
	print(root)
	if args.isWin=="1" then
		projRoot = string.gsub(projRoot, "/", "\\")
		dest = string.gsub(dest, "/", "\\")
		os.execute( "del /Q /S " .. dest.."libs\\*.jar" )
		os.execute( "rd /Q /S " .. dest.."res\\layout" )
		os.execute( "rd /Q /S " .. dest.."res\\values" )
		os.execute( "rd /Q /S " .. dest.."src" )
		os.execute( "xcopy /S /Y /Q " .. projRoot .. " " .. dest)
	else
		dest = PROJECT_PATH.."frameworks/runtime-src/"
		os.execute( "rm -R -f " .. dest.."libs/*.jar" )
		os.execute( "rm -R -f " .. dest.."res/layout" )
		os.execute( "rm -R -f " .. dest.."res/values" )
		os.execute( "rm -R -f " .. dest.."src" )
		os.execute( "cp -R -f " .. projRoot .. " " .. dest )
	end
	print("------------- general custom api[" .. args.platform .. "] ---------------------")
	
	copyFile( root .. "/custom_api.ini", PROJECT_PATH .. "custom/custom_api.ini"  )
	local apiPath = "platform_cfg/" .. args.platform .. "/api"
	mkDirs(apiPath, PROJECT_PATH)
	apiPath = PROJECT_PATH .. apiPath

	local classPath = PROJECT_PATH .. "frameworks/runtime-src/Classes"
	if args.isWin=="1" then
		apiPath = string.gsub(apiPath, "/", "\\")
		local classPathWin = string.gsub(classPath, "/", "\\")
		os.execute( "rd /Q /S " .. classPathWin.."\\sdk" )
		os.execute( "del /Q /S " .. apiPath .. "\\*.lua" )
		os.execute( "del /Q /S " .. classPathWin .. "\\auto\\api\\*.lua" )
		os.execute( "xcopy /S /Y /Q " .. string.gsub(root, "/", "\\") .. "\\sdk " .. classPathWin.."\\sdk\\")

		local cmd = "cd " .. string.gsub(PROJECT_PATH .. "custom", "/", "\\")
		cmd = cmd .. "\npython gen-custom-lua.py"
		cmd = cmd .. "\ncd ..\\build\\scripts"
		saveTo("tmp.bat", cmd)
		os.execute( "tmp.bat" )
		os.remove( "tmp.bat" )
		print("xcopy /S /Y /Q " .. apiPath .. " " .. classPathWin.."\\auto\\api")
		os.execute( "xcopy /S /Y /Q " .. classPathWin.."\\auto\\api" .. " " .. apiPath)

	else
		os.execute( "rm -R -f " .. classPath.."/sdk" )
		os.execute( "rm -R -f " .. apiPath .. "/*.lua" )
		os.execute( "rm -R -f " .. classPath .. "/auto/api/*.lua" )
		os.execute( "cp -R -f " .. root .. "/sdk " .. classPath.."/sdk/" )			

		local cmd = "cd " .. PROJECT_PATH .. "custom"
		cmd = cmd .. "\npython gen-custom-lua.py"
		cmd = cmd .. "\ncd ../build/scripts"
		saveTo("tmp.sh", cmd)
		os.execute( "sh tmp.sh" )
		os.remove( "tmp.sh" )

		os.execute( "cp -R -f " .. classPath.."/auto/api" .. " " .. apiPath )
	end
	removePath( apiPath .. "/lua_custom_api_auto_api.lua" )
	local lua_require = ""
	for f in lfs.dir(apiPath) do
		if string.find(f, ".lua") then
			lua_require = lua_require .. "\nrequire(\"api." .. string.gsub(f, ".lua", "") .. "\")"
		end
	end
	saveTo(apiPath .. "/init.lua", lua_require)
	
	saveTo(PROJECT_PATH.."src/app_folder.lua", "return \""..app_folder.."\"")
	saveTo(PROJECT_PATH.."src/platform_name.lua", "return \""..args.platform.."\"")
	print("-------- sdk ready -----------------")
end
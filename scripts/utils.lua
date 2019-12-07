
package.path = package.path .. ";lua_ext/?.lua;"

require("lfs")
--require('LuaXml')
--require('json')
require("md5")
require("list")
require("string_ext")
--csdConvert = require("csd2lua")
xmlParser  = require("XmlParser").newParser()
md5 = require("md5")

function getFileType( filePath )
	local fileType = ""
	local fileName = ""
	local isName = false
	for k=#filePath, 1, -1 do
		if filePath[k]=="/" or filePath[k]=="\\" then
			break
		end
		if filePath[k]=="." then
			isName = true
		else
			if isName then
				fileName = filePath[k] .. fileName
			else
				fileType = filePath[k] .. fileType
			end
		end
	end
	return fileName, string.lower(fileType)
end

function getAllFiles( rootPath, folder, fileTypes )
	if rootPath==nil then
		return {}
	end
	local files = {}

	local path = rootPath
	local key = folder

	if folder=="" then
		key = "__root__"
	elseif folder~=nil then
		path = path .. folder .. "/"
	end
	if key~=nil then
		files[key] = {}
	end
	for f in lfs.dir(path) do
		if f~="." and f~=".." then
			local file = f
			if folder~=nil and folder~="" then
				file = folder.."/"..f
			end
			if isDir(path..f) then
				local arr = getAllFiles(rootPath, file, fileTypes)

				for k,v in pairs(arr) do
					if #v>0 then
						files[k] = v
					end
				end
			elseif key~=nil then
				local fileName, fileType = getFileType(f)
				if table.indexof(fileTypes, fileType)~=false then
					table.insert(files[key], file)
				end
			end
		end
	end
	if files[key] and #files[key]==0 then
		files[key] = nil
	end
	return files
end
function moveFile( src, dest )
    os.remove(dest)
    os.rename(src, dest)
end
function copyFile( src, dest )
	--print(dest)
	local f = io.open(src, "rb")
	local data = f:read("*a")
	f:close()

	f = io.open(dest, "wb")
	if f then
		f:write(data)
		f:flush()
		f:close()
	else
		print("file not found:",dest)
	end
end

--[[
function loadJson( path )
	local f = io.open(path, "rt")
	local data = f:read("*a")
	--print(data)
	f:close()
	return json.decode(data)
end]]

function serialize(obj)
    local t = type(obj)
	if t == "table" then
		local lua = "{\n"
		local parsed = {}
		for k, v in ipairs(obj) do
	        lua = lua .. "    " .. serialize_child(v) .. ",\n"
	        parsed[k] = true
	    end
		for k, v in pairs(obj) do
			if not parsed[k] then
	        	lua = lua .. "    [" .. serialize_child(k) .. "]=" .. serialize_child(v) .. ",\n"
	        end
	    end
		lua = lua .. "}"
		return lua
	else
		return serialize_child(obj)
	end
end
function serialize_child(obj)
    local lua = ""
    local t = type(obj)

    if t == "table" then
        lua = lua .. "{"
		local parsed = {}
		for k, v in ipairs(obj) do
	        lua = lua .. " " .. serialize_child(v) .. ","
	        parsed[k] = true
	    end
		for k, v in pairs(obj) do
			if not parsed[k] then
	        	lua = lua .. " [" .. serialize_child(k) .. "]=" .. serialize_child(v) .. ","
	        end
	    end
	    --[[local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
	        for k, v in pairs(metatable.__index) do
	            lua = lua .. "    [" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
	        end
	    end  ]]
        lua = lua .. " }"
    elseif t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

function table.join( arr, char )
	local str = ""
	char = char or ","
	for k=1,#arr-1 do
       str = str .. arr[k] .. char
	end

	return str .. arr[#arr]
end


function table.indexof( arr, value )
	for k,v in pairs(arr) do
		if v==value then
			return k
		end
	end
	return false
end

function table.mergeArray( dest, src )
	local len = #dest
	for k,v in pairs(src) do
		dest[k+len] = v
	end
end

function mkDirs(path, root)
	if root==nil then
		root = PROJECT_PATH
	end
	if isExist(root..path) then
		return
	end
	local arr = string.split(path, "/")
	for k,f in ipairs(arr) do
		if f~="" then
			root = root .. f .. "/"
			lfs.mkdir(root)
		end
	end
end
function isDir( path )
	local newPath = path
	local last = string.sub(path, #path)
	if last=="/" then
		newPath = string.sub(path, 1, #path-1)
	end
	return lfs.attributes(newPath, "mode")=="directory"
end
function isExist( path )
	if string.sub(path, #path, #path)=="/" then
		path = string.sub(path, 1, #path-1)
	end
	local mode = lfs.attributes(path, "mode")
	if mode then
		return true
	end

	return false
end

function fileSize(path)
	local file = io.open(path, "rb")
	if file~=nil then
	    local currentPos = file:seek() -- 获取当前位置
	    local size = file:seek("end") -- 获取文件大小
	    file:seek("set", currentPos)
	    file:close()
	    return size
	end
	return 0
end
function getMd5(data)
	if data ~= nil then
		return md5.sumhexa(data)
	else
		return nil
	end
end
function fileMd5(filePath)
    local file = io.open(filePath, "rb")
    if file~=nil then
	    local data = file:read("*a")
		file:close()

		return getMd5(data) or false
	end
	return false
end

function saveTo( path, text )
	local file = io.open(path, "w+t")
	if not file then
		print("file not exist:"..tostring(path))

		return
	end
	file:write(text)
	file:flush()
	file:close()
end

function loadXml( path )
	if isExist(path) then
		local file = io.open(path, "rb")
		local data = file:read("*a")
		-- print(data)
		file:close()
		local char1,char2,char3 = string.byte(data, 1,3)
		if char1==239 and char2==187 and char3==191 then
			file = io.open(path, "wb")
			file:write( string.sub(data,4) )
			file:close()
		end
		return xmlParser:loadFile(path)
		--return xml.load(path)
	end

	print("xml is not exists, make sure the prject_path is correct:" .. path)
	return nil
end
function loadText( path )
	if isExist(path) then
		local file = io.open(path, "rb")
		local data = file:read("*a")
		file:close()
		local char1,char2,char3 = string.byte(data, 1,3)
		if char1==239 and char2==187 and char3==191 then
			data = string.sub(data,4)
		end

		return data
	end

	return ""
end

function loadLua( path )
	if isExist(path) then
		local func = loadfile(path)
		local ret, value = pcall(func)

		if ret then
			return value
		else
			print("Read file failed. Invaild content:" .. path)
		end
	else
		print("Read file failed. file not exist:" .. path)
	end
	return nil
end

function xmlToObj( xmlDoc )
	local obj = {}
	local props = xmlDoc:properties()
	for k,v in pairs(props) do
		obj[v.name] = v.value
	end
	local children = xmlDoc:children()
	if #children==0  then
		obj["innerText"] = xmlDoc:value()
		return obj
	end
	for k,v in ipairs(children) do
		local tag = v:name()
		if #v:properties()==0 and #v:children()==0 and #xmlDoc[tag]==1 then
			obj[tag] = v:value()
		else
			if obj[tag]==nil then
				obj[tag] = {}
			elseif type(obj[tag])~="table" then
			      	print("[waring]attribute name is same as node name." .. tag)
				obj[tag] = {}
			end
			local item = xmlToObj(v)
			table.insert( obj[tag], item )
		end

	end

	return obj
end

function removePath(path)
    if isDir(path) then
        local dirPath = path.."/"
        for file in lfs.dir(dirPath) do
            if file ~= "." and file ~= ".." then
                local f = dirPath..file
                removePath(f)
            end
        end
        lfs.rmdir(path)
    else
        os.remove(path)
    end
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

-- local xml = loadXml("E:/project_wly2_lua_client/frameworks/runtime-src/proj.android/AndroidManifest.xml")
-- xmlParser:save(xml, "E:/project_wly2_lua_client/frameworks/runtime-src/proj.android/AndroidManifest.xml")
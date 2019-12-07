require("utils")
require("cfg")

local function copyTo(src, dest, fileTypes)
	print(src)
	for file in lfs.dir(src) do
		if file~="." and file~=".." then
			local fileType = string.sub( file, #file-3, #file)			
			if table.indexof(fileTypes, fileType)~=false and fileMd5(src..file)~=fileMd5(dest..file) then
				local srcFile = io.open(src..file, "rt")
				local destFile = io.open(dest..file, "wt")
				destFile:write( srcFile:read() )
				destFile:flush()
				io.close(srcFile)
				io.close(destFile)
			end
		end
	end
end

local function to_cn(folder, fileTypes)
	copyTo( string.format(folder,"local"), string.format(folder,"cn"), fileTypes)
end

to_cn(PROJECT_PATH.."res_source/%s/staticdata/", {"json"})
to_cn(PROJECT_PATH.."res_source/%s/text/", {".txt"})
to_cn(PROJECT_PATH.."res_source/%s/img_package/", {".png", ".jpg"})
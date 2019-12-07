require("utils")
require("cfg")

local ccs = xmlParser:parseXmlText([[<Solution>
  <PropertyGroup Name="project_wly2_lua_client" Version="2.3.3.0" Type="CocosStudio" />
  <SolutionFolder>
    <Group ctype="ResourceGroup">
      <RootFolder Name=".">
      </RootFolder>
    </Group>
  </SolutionFolder>
</Solution>]])

function make_file_tree( dir, node )
	for f in lfs.dir(dir) do
		if f~="." and f~=".." then
			local path = dir .. "/" .. f
			if isDir( path) then
				local newNode = xmlParser:newNode("Folder")
				node:addChild(newNode)
				newNode:addProperty("Name", f)
				make_file_tree(path, newNode)
			else
				local fileType = string.sub(f, #f-3)
				fileType = string.lower(fileType)
				if fileType==".csd" then
					local csd = loadXml(path)
					if csd then
						local proj = xmlParser:newNode("Project")
						node:addChild(proj)
						proj:addProperty("Name", f)
						proj:addProperty("Type", csd.GameFile[1].PropertyGroup[1]["@Type"])
					end
				elseif fileType==".png" or fileType==".jpg" then
					local sub = xmlParser:newNode("Image")
					sub:addProperty("Name", f)
					node:addChild(sub)
				elseif fileType==".udf" or fileType=="tore" then -- tore is .DS_Store
					--do nothing
				elseif fileType==".ttf" or fileType==".ttc" then
					local sub = xmlParser:newNode("TTF")
					sub:addProperty("Name", f)
					node:addChild(sub)
				elseif fileType==".fnt" then
					local sub = xmlParser:newNode("Fnt")
					sub:addProperty("Name", f)
					node:addChild(sub)
				else
					local sub = xmlParser:newNode("File")
					sub:addProperty("Name", f)
					node:addChild(sub)
				end
			end
		end
	end
end

make_file_tree(PROJECT_PATH .. "cocosstudio", ccs.Solution[1].SolutionFolder[1].Group[1].RootFolder[1])

xmlParser:save(ccs, PROJECT_PATH.."project_wly2_lua_client.ccs", false)
print("make project_wly2_lua_client.ccs done.")
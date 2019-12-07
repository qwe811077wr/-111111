require("utils")
require("cfg")
package.path = package.path .. ";../../res/?.lua"
local unplist_path = 'unplist'
local unplist = require(unplist_path)

RES_PATH = '../../../project_wly2_lua_client/res/ui_local/'
DEST_PATH = '../../../project_wly2_lua_client/res/ui'

if isExist(DEST_PATH) then
	removePath(DEST_PATH)
end
mkDirs(DEST_PATH, '')

print('不合图文件')
local unplist_map = {}
for k, item in ipairs(unplist) do
    print(item)
    unplist_map[item] = true
end

--冗余代码删除
local ignore_map = {
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
for k, v in ipairs(ignore_map) do
	v = string.gsub(v, "%(", "%%%(")
	v = string.gsub(v, "%)", "%%%)")
	v = string.gsub(v, "%[", "%%%[")
	v = string.gsub(v, "%]", "%%%]")
	v = string.gsub(v, "%.", "%%%.")
	ignore_map[k] = v
end

local function convertLua(src_folder)
	local all_files = getAllFiles(src_folder, "", {"lua"})
	for folder, list in pairs(all_files) do
		for k, f in ipairs(list) do
			local text = loadText(src_folder .. f)
			local used_tex = {}

			text = string.gsub(text, "\"img_local/[a-zA-Z/0-9%._-]+\",0", function ( x )
				local arr = string.split(x, "/")
				local str = ''
				for i = 2, #arr - 1 do
					if i ~= #arr - 1 then
						str = str .. arr[i] .. '/'
					else
						str = str .. arr[i]
					end
				end
				if not unplist_map[str] then
					return "\"img" .. string.sub(x, 11, #x - 1) .. "1"
				else
					return "\"img" .. string.sub(x, 11, #x - 1) .. "0"
				end
			end)

			local list = string.split(text, "[\r\n]+")
			text = ""
			for i, line in ipairs(list) do
				for l, ignoreCode in ipairs(ignore_map) do
					if string.find(line, ignoreCode) then
						print('ignore ' .. ignoreCode)
						line = nil
						break
					end
				end

				if line then
					if string.find(line, "enableShadow") ~= nil then
						line = string.gsub(line, "a = 255", "a = 127.5")
					elseif string.find(line, "cc.Sprite:create%(\"img_local/") ~= nil then
						--替换 Sprite:create 为 Sprite:createWithSpriteFrameName
						local arr = string.split(line, "/")
						local str = ''
						for i = 2, #arr - 1 do
							if i ~= #arr - 1 then
								str = str .. arr[i] .. '/'
							else
								str = str .. arr[i]
							end
						end
						if not unplist_map[str] then
							line = string.gsub(line, "cc.Sprite:create%(\"img_local/", "cc.Sprite:createWithSpriteFrameName(\"img/")
						else
							line = string.gsub(line, "cc.Sprite:create%(\"img_local/", "cc.Sprite:create(\"img/")
						end
					end

					if string.find(line, "return Result") == nil then
						text = text .. line .. "\n"
					else
						break
					end
				end
			end
			text = text .. "return Result"

			local path = src_folder .. f
			local path_dest = string.gsub(path, '/ui_local/', '/ui/')
			local path_pre = string.gsub(path_dest, "/[a-zA-Z0-9_-]+[.]lua", '')

			if not isExist(path_pre) then
				mkDirs(path_pre, '')
			end
			if not isExist(path_dest) then
				copyFile(path, path_dest)
			end
			print(path_dest)
			saveTo(path_dest, text)
		end
	end
end

convertLua(RES_PATH)

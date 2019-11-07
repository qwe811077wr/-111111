require("utils")
require("cfg")

local svn_root = '../../../wly2_lua_svn/美术/res_project/animation/'
-- local set = {'effect', 'soldier'}
local set = {"idle"}

print('更新' .. svn_root)
os.execute('svn up ' .. svn_root)

for k, v in ipairs(set) do
    local root = svn_root .. v .. "/"
    local dest_path = PROJECT_PATH .. "res/animation/" .. v .. "/"

    local copy_dir = svn_root .. v .. '_copy'
    os.execute('rm -rf ' .. svn_root .. v .. '_copy')
    os.execute('mkdir ' .. svn_root .. v .. '_copy')

    for ani_f in lfs.dir(root) do
        if ani_f ~= "." and ani_f ~= ".." and ani_f ~= ".DS_Store" and isDir(root .. ani_f) then
            os.execute('mkdir ' .. svn_root .. v .. '_copy/' .. ani_f)

            local file_path = root .. ani_f
            local copy_file_path = svn_root .. v .. '_copy/' .. ani_f
            for child_f in lfs.dir(file_path) do
                if child_f ~= "." and child_f ~= ".." and child_f ~= ".DS_Store" then
                    local src_file = file_path .. '/' .. child_f
                    local dst_file = copy_file_path .. '/' .. ani_f .. '_' .. child_f
                    print('copy file', src_file, dst_file)
                    os.execute(string.format('cp -i %s %s', src_file, dst_file))
                end
            end

            if isExist(file_path .. '.txt') then
                os.execute(string.format('cp -r %s %s', file_path .. '.txt', svn_root .. v .. '_copy/'))
            end
        end
    end
end


for k, v in ipairs(set) do
    local root = svn_root .. v .. '_copy' .. "/"
    local dest_path = PROJECT_PATH .. "res/animation/" .. v .. "/"

    os.execute('rm -rf ' .. dest_path)
    for f in lfs.dir(root) do
        if f ~= "." and f ~= ".." and f ~= ".DS_Store" and isDir(root .. f) then
            local file_path = root .. f
            local dest_file = dest_path .. f
            --force-squared
            --max size 16384
            local cmd = string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096', file_path, dest_file, dest_file, PNG_FORMAT)
            cmd = cmd .. ';' .. "pngquant -f --ext .png --quality 10-90 --speed 1 " .. dest_file .. ".png"
            os.execute(cmd)

            if isExist(file_path .. '.txt') then
                os.execute(string.format('cp -r %s %s', file_path .. '.txt', dest_path))
            end
        end
    end
end
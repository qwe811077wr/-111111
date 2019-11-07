require("utils")
require("cfg")

PNG_FORMAT = 'png'

local svn_root = '../../../wly2_lua_svn/美术/res'

-- print('更新' .. svn_root)
-- os.execute('svn up ' .. svn_root)

local dest_path = svn_root .. '_copy'
os.execute('rm -rf ' .. dest_path)
os.execute(string.format('cp -rf %s %s', svn_root, dest_path))

print('mkdir' .. dest_path)

local jpg_file = {}
function recursiveFile(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if isDir(f) then
                recursiveFile(f)
            else
                local file_name, file_type = getFileType(f)
                if file_type == 'png' or file_type == 'jpg' or file_type == 'jpeg' then
                    print(f)
                    local prefix = string.sub(f, 1, #f - 4)
                    local cmd = ''
                    cmd = "../pngquant/pngquant -f --ext .png --quality 10-90 --speed 1 " .. f
                    cmd = cmd .. ';' .. string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096 --extrude 0', f, prefix, prefix, PNG_FORMAT)
                    cmd = cmd .. ';' .. "pngquant -f --ext .png --quality 10-90 --speed 1 " .. f
                    cmd = cmd .. ';' .. 'rm -rf ' .. prefix .. '.plist'
                    if file_type == 'jpg' then
                        cmd = cmd .. ';' .. 'rm ' .. prefix .. '.jpg'
                        cmd = cmd .. ';' .. 'mv ' .. f .. '.png ' .. prefix .. '.png'
                        table.insert(jpg_file, f)
                    end
                    os.execute(cmd)
                end
            end
        end
    end
end
recursiveFile(dest_path)

for k, item in ipairs(jpg_file) do
    print('jpg file ---------------------', item)
end

-- local project_path = PROJECT_PATH .. "res/"
-- for file in lfs.dir(dest_path) do
--     if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--         local dest_file = project_path .. file
--         local src_file = dest_path .. '/' .. file
--         print(string.format('copy file %s  %s', src_file, dest_file))
--         os.execute('rm -rf ' .. dest_file)
--         os.execute(string.format('cp -rf %s %s', src_file, dest_file))
--     end
-- end



require("utils")
require("cfg")

local svn_root = '/Users/admin/code/client/wly2_lua_svn/美术/res_project/animation/'
local dest_root = '/Users/admin/code/client/commit/project_wly2_lua_client/res/animation/'
local set = {'soldier', 'idle', 'effect'}

print('更新' .. svn_root)
os.execute('svn up ' .. svn_root)

local path = '/Users/admin/code/client/commit/project_wly2_lua_client'
os.execute('cd ' .. path .. ";git pull")

local dir_list = {}
for k, v in ipairs(set) do
    local root = svn_root .. v .. "/"
    local dest_path = dest_root .. v .. "/"

    local copy_dir = svn_root .. v .. '_copy'
    os.execute('rm -rf ' .. svn_root .. v .. '_copy')
    os.execute('mkdir ' .. svn_root .. v .. '_copy')

    for file_name in lfs.dir(root) do
        if file_name ~= "." and file_name ~= ".." and file_name ~= ".DS_Store" then
            local file_path = root .. file_name
            if isDir(root .. file_name) then
                os.execute('mkdir ' .. svn_root .. v .. '_copy/' .. file_name)
                local copy_file_path = svn_root .. v .. '_copy/' .. file_name
                for child_f in lfs.dir(file_path) do
                    if child_f ~= "." and child_f ~= ".." and child_f ~= ".DS_Store" then
                        local src_file = file_path .. '/' .. child_f
                        local dst_file = copy_file_path .. '/' .. file_name .. '_' .. child_f
                        -- print('copy file', src_file, dst_file)
                        os.execute(string.format('cp -i %s %s', src_file, dst_file))
                    end
                end
                dir_list[v .. '/' .. file_name] = true
            else
                os.execute(string.format('cp -r %s %s', file_path, svn_root .. v .. '_copy/'))
            end
        end
    end
end


for k, v in ipairs(set) do
    local root = svn_root .. v .. '_copy' .. "/"
    local dest_path = dest_root .. v .. "/"

    if not isExist(dest_path) then
        os.execute('mkdir -p ' .. dest_path)
    end

    -- os.execute('rm -rf ' .. dest_path)
    for f in lfs.dir(root) do
        if f ~= "." and f ~= ".." and f ~= ".DS_Store" then
            local file_path = root .. f
            print(file_path)
            if isDir(root .. f) then
                local dest_file = dest_path .. f
                --force-squared
                --max size 16384
                --prepend-folder-name         Adds the smart folders name to the sprite names
                --png-opt-level <value>       Optimization level for pngs (0=off, 1=use 8-bit, 2..7=png-opt)
                local cmd = string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096 --png-opt-level 1 --extrude 0', file_path, dest_file, dest_file, PNG_FORMAT)
                -- cmd = cmd .. ';' .. "pngquant -f --ext .png --quality 10-90 --speed 1 " .. dest_file .. ".png"
                os.execute(cmd)
            else
                os.execute(string.format('cp -r %s %s', file_path, dest_path))
            end
        end
    end
end

--删除遗留数据
for k, v in ipairs(set) do
    local dest_path = dest_root .. v .. "/"
    for f in lfs.dir(dest_path) do
        if f ~= "." and f ~= ".." and f ~= ".DS_Store" then
            local parts = string.split(f, '.')
            local file_path = dest_path .. f
            local name, file_type = getFileType(f)
            if file_type == 'png' then
                if not dir_list[v .. '/' .. name] then
                    print('remove', file_path)
                    os.execute('rm -rf ' .. file_path)

                    local plist_path = dest_path .. name .. '.plist'
                    os.execute('rm -rf ' .. plist_path)

                    local txt_path = dest_path .. name .. '.txt'
                    if isExist(txt_path) then
                        os.execute('rm -rf ' .. txt_path)
                    end
                end
            end
        end
    end
end

local path = '/Users/admin/code/client/commit/project_wly2_lua_client'
os.execute('cd ' .. path .. ";pwd;git add res/animation/" .. args.set .. ";git commit -m 'update effect resource';git push origin HEAD:refs/for/master")


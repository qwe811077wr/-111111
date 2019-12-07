require("utils")
require("cfg")
package.path = package.path .. ";../../res/?.lua"

local svn_root = '../../res'
local img_path = '../../res/img_local'
local img_path_md5 = '../../res/img_md5.txt'
local temp_path = '../../res/temp/img'
local unplist_path = 'unplist'
local dest_path = '../../res/img'
local unplist = require(unplist_path)

-- print('更新' .. svn_root)
-- os.execute('svn up ' .. svn_root)

-- if not isExist(img_path_md5) then
--     os.execute("touch " .. img_path_md5)
-- end

-- print('读取md5文件')
-- local file_read = io.open(img_path_md5)
-- local md5_item_old = {}
-- local line = file_read:read()
-- while line do
--     local strs = string.split(line, ' ')
--     md5_item_old[strs[1]] = strs[2]
--     line = file_read:read()
-- end
-- print('清空md5文件')
-- os.execute("rm " .. img_path_md5)
-- os.execute("touch " .. img_path_md5)

local need_change = {}
local item_list = {}
local dir_list = {}
local md5_item_new = {}
function recursiveMd5(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if not isDir(f) then
                -- local str_md5 = fileMd5(f)
                -- md5_item_new[f] = str_md5
                -- os.execute(string.format('echo %s >> %s', string.format("%s %s", f, str_md5), img_path_md5))

                -- if not md5_item_old[f] or md5_item_old[f] ~= str_md5 then
                --     need_change[f] = true
                -- end
                item_list[f] = true
            else
                dir_list[f] = true
                recursiveMd5(f)
            end
        end
    end
end
recursiveMd5(img_path)

-- --删除的文件
-- for k, item in pairs(md5_item_old) do
--     local strs = string.split(k, ' ')
--     if not md5_item_new[strs[1]] and not need_change[strs[1]] then
--         need_change[strs[1]] = true
--     end
-- end

-- print('变更的文件夹')
-- local need_change_dir = {}
-- for k, item in pairs(need_change) do
--     local dir_path = string.gsub(k, "/[a-zA-Z0-9%._-]+.png", '')
--     if not need_change_dir[dir_path] then
--         print(dir_path)
--         need_change_dir[dir_path] = true
--     end
-- end

if not isExist(temp_path) then
    os.execute('mkdir -p ' .. temp_path)
else
    os.execute('rm -rf ' .. temp_path .. '/')
end

if not isExist(dest_path) then
    os.execute('mkdir -p ' .. dest_path)
end
os.execute(string.format('cp -r %s/ %s', img_path, dest_path))

print('不合图文件')
local unplist_map = {}
for k, item in ipairs(unplist) do
    print(item)
    unplist_map[item] = true
end

--合图处理
function recursiveFile(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if isDir(f) then
                local str = string.sub(f, 21, #f)
                if not found and not unplist_map[str] then
                    --合图处理
                    print('合图处理', f)
                    os.execute('rm -rf ' .. temp_path)
                    local path1 = string.gsub(f, 'img_local/', 'temp/img/')
                    local path2 = string.gsub(f, 'img_local/', 'img/')
                    os.execute('mkdir -p ' .. path1)
                    os.execute(string.format('cp -r %s/ %s', f, path1))
                    local cmd = string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096 --prepend-folder-name --png-opt-level 1', temp_path, path2, path2, PNG_FORMAT)
                    os.execute(cmd)
                end
                recursiveFile(f)
            end
        end
    end
end
recursiveFile(img_path)

-- 清理已经合图文件夹
function recursiveClearFile(path)
    if not isExist(path) then
        return
    end
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if isDir(f) then
                if isExist(f .. '.plist') then
                    os.execute('rm -rf ' .. f)
                end
                recursiveClearFile(f)
            end
        end
    end
end
recursiveClearFile(dest_path)

for k, item in pairs(dir_list) do
    print(k)
end

for k, item in pairs(item_list) do
    print(k)
end

--清理遗留文件
function recursiveClearSvnFile(path)
    if not isExist(path) then
        return
    end

    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if not isDir(f) then
                local name, file_type = getFileType(f)
                if file_type == 'png' then
                    local plist_path = path .. '/' .. name .. '.plist'
                    if isExist(plist_path) then
                        --合图文件
                        local path1 = string.gsub(path .. '/' .. name, 'img', 'img_local')
                        if not dir_list[path1] then
                            print('remove plist', f)
                            os.execute('rm -rf ' .. f)
                            os.execute('rm -rf ' .. plist_path)
                        end
                    else
                        local path1 = string.gsub(f, 'img', 'img_local')
                        if not item_list[path1] then
                            print('remove png', f)
                            os.execute('rm -rf ' .. f)
                        end
                    end
                end
            else
                local path1 = string.gsub(f, 'img', 'img_local')
                if not dir_list[path1] then
                    print('remove dir', f)
                    os.execute('rm -rf ' .. f)
                end
                recursiveClearSvnFile(f)
            end
        end
    end
end
recursiveClearSvnFile(dest_path)

--svn commit

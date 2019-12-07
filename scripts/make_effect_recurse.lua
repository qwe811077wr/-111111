require("utils")
require("cfg")

PNG_FORMAT = 'png'

local svn_root = '../../../wly2_lua_svn/美术/res_project/animation/test'

-- print('更新' .. svn_root)
-- os.execute('svn up ' .. svn_root)

local dest_path = svn_root .. '_temp'
os.execute('rm -rf ' .. dest_path)
os.execute('rm -rf ' .. svn_root .. '_copy')
os.execute(string.format('cp -rf %s %s', svn_root, dest_path))

print('mkdir' .. dest_path)

--删除800 文件夹 保留900文件夹
-- function recursiveFileRemove(path)
--     for file in lfs.dir(path) do
--         if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--             local f = path .. '/' .. file
--             if isDir(f) and isExist(f) then
--                 print(f)
--                 if string.find(f, '800') then
--                     os.execute('rm -rf ' .. f)
--                 elseif string.find(f, '960') then
--                     local dest_file = f .. '/..'
--                     os.execute(string.format('cp -rf %s// %s', f, dest_file))
--                     os.execute('rm -rf ' .. f)
--                 else
--                     recursiveFileRemove(f)
--                 end
--             end
--         end
--     end
-- end
-- recursiveFileRemove(dest_path)

-- 动作将1 2 3动作合并到父文件夹
function recursiveFileMerge(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local f = path .. '/' .. file
            if isDir(f) then
                print(f)
                os.execute('rm -rf ' .. f .. '/*.db')
                for child_file in lfs.dir(f) do
                    local child_path = f .. '/' .. child_file
                    if isDir(child_path) and child_file ~= "." and child_file ~= ".." and child_file ~= ".DS_Store" then
                        os.execute('rm -rf ' .. child_path .. '/*.db')
                        print(child_path)
                        os.execute(string.format('cp -rf %s/ %s/..', child_path, child_path))
                        os.execute('rm -rf ' .. child_path)
                    end
                end
            end
        end
    end
end
recursiveFileMerge(dest_path)

-- -- 动作将1 2 3动作合并到父文件夹
-- function recursiveFileMerge(path)
--     for file in lfs.dir(path) do
--         if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--             local f = path .. '/' .. file
--             if isDir(f) then
--                 recursiveFileMerge(f)
--             else
--                 local file_name, file_type = getFileType(f)
--                 local dest_file = path .. '/..'

--                 if file_type == 'png' and isExist(path) then
--                     print(path)
--                     os.execute('rm -rf ' .. path .. '/*.db')
--                     os.execute(string.format('cp -rf %s// %s', path, dest_file))
--                     os.execute('rm -rf ' .. path)
--                 end
--             end
--         end
--     end
-- end
-- recursiveFileMerge(dest_path)

-- function toLowerPath(path)
--     local files = string.split(path, '/')

--     local str = ''
--     for i = 1, #files - 1 do
--         str = str .. files[i] .. '/'
--     end

--     str = str .. string.lower(files[#files])

--     return str
-- end

-- --合图
-- function recursiveFilePlist(path)
--     for file in lfs.dir(path) do
--         if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--             local f = path .. '/' .. file
--             if isDir(f) then
--                 recursiveFilePlist(f)
--             else
--                 local file_name, file_type = getFileType(f)
--                 if file_type == 'png' and isExist(path) then
--                     local dest_file = toLowerPath(string.gsub(path, '_temp', '_copy'))
--                     print(dest_file)

--                     local cmd = string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096', path, dest_file, dest_file, PNG_FORMAT)
--                     cmd = cmd .. ';' .. "pngquant -f --ext .png --quality 10-90 --speed 1 " .. dest_file .. ".png"
--                     cmd = cmd .. ';' .. 'rm -rf ' .. path
--                     os.execute(cmd)
--                 end
--             end
--         end
--     end
-- end
-- recursiveFilePlist(dest_path)

-- --合并文件夹 特效文件提前
-- function recursiveFileMerge2(path)
--     for file in lfs.dir(path) do
--         if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--             local file_path = path .. '/' .. file
--             if isDir(file_path) then
--                 print(file_path)
--                 local dest_file = file_path .. '/..'
--                 os.execute(string.format('cp -rf %s// %s', file_path, dest_file))
--                 os.execute('rm -rf ' .. file_path)
--             end
--         end
--     end
-- end

-- for file in lfs.dir(svn_root .. '_copy') do
--     recursiveFileMerge2(svn_root .. '_copy/' .. file)
-- end
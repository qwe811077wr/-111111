require("utils")
require("cfg")

local svn_root = '../../../../wly2_lua_svn/美术/res_project/animation/'
local set = {'effect', 'soldier', 'idle'}

local md5_file = svn_root .. 'md5.txt'
if not isExist(md5_file) then
    os.execute("touch " .. md5_file)
end

print('更新' .. svn_root)
os.execute('svn up ' .. svn_root)

print('读取md5文件')
local file_read = io.open(md5_file)
local md5_item_old = {}
local md5_file_old = {}
local line = file_read:read()
while line do
    local strs = string.split(line, ' ')
    md5_item_old[strs[1]] = strs[2]

    strs = string.split(strs[1], '/')
    md5_file_old[strs[1] .. '/' .. strs[2]] = true

    line = file_read:read()
end
print('清空md5文件')
os.execute("rm " .. md5_file)
os.execute("touch " .. md5_file)

local need_change = {}
local md5_item_new = {}
local md5_file_new = {}
for k, v in ipairs(set) do
    local root = svn_root .. v .. "/"
    for file_name in lfs.dir(root) do
        if file_name ~= "." and file_name ~= ".." and file_name ~= ".DS_Store" then
            local file_path = root .. file_name
            if isDir(file_path) then
                for item_name in lfs.dir(file_path) do
                    if item_name ~= "." and item_name ~= ".." and item_name ~= ".DS_Store" then
                        local item_path = file_path .. '/' .. item_name
                        local str_path = string.format('%s/%s/%s', v, file_name, item_name)
                        local str_md5 = fileMd5(item_path)
                        md5_item_new[str_path] = str_md5
                        os.execute(string.format('echo %s >> %s', string.format("%s %s", str_path, str_md5), md5_file))
                        if not need_change[v .. '/' .. file_name] then
                            if not md5_item_old[str_path] or md5_item_old[str_path] ~= str_md5 then
                                need_change[v .. '/' .. file_name] = true
                            end
                        end
                    end
                end
            else
                --txt文件
                local str_path = string.format('%s/%s', v, file_name)
                local str_md5 = fileMd5(file_path)
                md5_item_new[str_path] = str_md5
                os.execute(string.format('echo %s >> %s', string.format("%s %s", str_path, str_md5), md5_file))
                if not md5_item_old[str_path] or md5_item_old[str_path] ~= str_md5 then
                    need_change[v .. '/' .. file_name] = true
                end
            end
            md5_file_new[v .. '/' .. file_name] = true
        end
    end
end
local file_rm = {}
for k, item in pairs(md5_file_old) do
    if not md5_file_new[k] then
        file_rm[k] = true
    end
end

for k, item in pairs(md5_item_old) do
    local strs = string.split(k, '/')
    local file_name = strs[1] .. '/' .. strs[2]
    if not md5_item_new[k] and not file_rm[file_name] and not need_change[file_name] then
        need_change[file_name] = true
    end
end

for k, item in pairs(need_change) do
    print('need_change', k)
end

for k, item in pairs(file_rm) do
    print('file_rm', k)
end

for k, v in ipairs(set) do
    local root = svn_root .. v .. "/"
    local dest_path = PROJECT_PATH .. "res/animation/" .. v .. "/"

    local copy_dir = svn_root .. v .. '_copy'
    os.execute('rm -rf ' .. svn_root .. v .. '_copy')
    os.execute('mkdir ' .. svn_root .. v .. '_copy')

    for file_name in lfs.dir(root) do
        if file_name ~= "." and file_name ~= ".." and file_name ~= ".DS_Store" then
            local file_path = root .. file_name
            if isDir(root .. file_name) then
                if need_change[v .. '/' .. file_name] then
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
                end
            else
                if need_change[v .. '/' .. file_name] then
                    os.execute(string.format('cp -r %s %s', file_path, svn_root .. v .. '_copy/'))
                end
            end
        end
    end
end


for k, v in ipairs(set) do
    local root = svn_root .. v .. '_copy' .. "/"
    local dest_path = '../../../../wly2_lua_svn/data_project/res_pc/res/animation/' .. v .. "/"

    -- os.execute('rm -rf ' .. dest_path)
    for f in lfs.dir(root) do
        if f ~= "." and f ~= ".." and f ~= ".DS_Store" then
            local file_path = root .. f
            if isDir(root .. f) then
                local dest_file = dest_path .. f
                --force-squared
                --max size 16384
                --png-opt-level <value>       Optimization level for pngs (0=off, 1=use 8-bit, 2..7=png-opt)
                local cmd = string.format('TexturePacker %s --sheet %s.png --data %s.plist --format cocos2d --texture-format %s --algorithm MaxRects --trim-mode Trim --opt RGBA8888 --max-size 4096', file_path, dest_file, dest_file, PNG_FORMAT)
                -- cmd = cmd .. ';' .. "pngquant -f --ext .png --quality 10-90 --speed 1 " .. dest_file .. ".png"
                os.execute(cmd)
            else
                os.execute(string.format('cp -r %s %s', file_path, dest_path))
            end
        end
    end
end

for k, item in pairs(file_rm) do
    local file_path = '../../../../wly2_lua_svn/data_project/res_pc/res/animation/' .. k
    if isExist(file_path) then
        os.execute('rm -rf ' .. file_path)
        os.execute('svn rm ' .. file_path)
    end
end

print('提交svn')

local path = '../../../../wly2_lua_svn/data_project/res_pc/res/animation/'
os.execute('cd ' .. path .. ";pwd;svn add --force ./*;svn commit -m 'update effect resource'")


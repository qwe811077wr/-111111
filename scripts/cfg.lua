PROJECT_PATH = "../../../project_wly2_lua_client/"
RES_SOURCE_PATH = "../../../wow_resource/project_wly2_lua_client/"
VERSION_PATH = PROJECT_PATH .. "src/version.lua"
OUTPUT_FOLDER = PROJECT_PATH .. "build/output/"
PNG_FORMAT = 'png'


args = {}
for k, v in ipairs(arg) do
    local arr = string.split(v, "=")
    if #arr == 2 then
        args[arr[1]] = arr[2]
    end
end

LANG_LIST={
    "local", "cn"
}
local lang = LANG_LIST[1]
if args.lang then
    for k,v in ipairs(LANG_LIST) do
        if v==args.lang then
            lang = v
            break
        end
    end
end
args.lang = lang
if not args.platform or args.platform=="" then
    args.platform = "local"
end
for k,v in ipairs(args) do
    print("args." .. k .."="..v)
end


packageNames = {
    ["local"] = "com.cn.newwl",
    ["yihuan"] = "com.cn.newwl",
    ["yihuan_test"] = "com.cn.newwl.test",
    ["yihuan_sdktest"] = "com.cn.newwl.sdktest",
    ["yihuan_noupdater"] = "com.cn.newwl.noupdater",
    ["yihuan_ios"] = "com.cn.newwl",
    ["yihuan_I4"] = "com.yh.newwl.i4",
    ["yihuan_91"] = "com.yh.newwl.91",
    ["yihuan_pp"] = "com.yh.newwl.pp",
    ["yihuan_tb"] = "com.yh.newwl.tb",
    ["yihuan_xy"] = "com.yh.newwl.xy",
    ["yihuan_ky"] = "com.yh.newwl.ky",
    ["yihuan_haima"] = "com.yh.newwl.hm",
    ["yihuan_itool"] = "com.yh.newwl.itool",
}
local profiles = {
    ["local"] = "02ad30a9-e261-4305-8dff-9e6f770f445b",
    ["yihuan"] = "789daee1-b70e-4726-8639-ed41b18f5a7a",
    ["yihuan_test"] = "789daee1-b70e-4726-8639-ed41b18f5a7a",
    ["yihuan_sdktest"] = "789daee1-b70e-4726-8639-ed41b18f5a7a",
    ["yihuan_noupdater"] = "789daee1-b70e-4726-8639-ed41b18f5a7a",
    ["yihuan_ios"] = "789daee1-b70e-4726-8639-ed41b18f5a7a",
    ["yihuan_I4"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_91"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_pp"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_tb"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_xy"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_ky"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_haima"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
    ["yihuan_itool"] = "3afb3b65-901c-4c39-aab7-0a8fdd083b9e",
}
local appNames = {
    ["local"] = "新卧龙吟(内部)",
    ["yihuan"] = "新卧龙吟",
    ["yihuan_test"] = "新卧龙吟(测试)",
    ["yihuan_sdktest"] = "新卧龙吟(SDK测试)",
    ["yihuan_noupdater"] = "新卧龙吟(不更新)",
    ["yihuan_ios"] = "新卧龙吟",
    ["yihuan_I4"] = "新卧龙吟",
    ["yihuan_91"] = "新卧龙吟",
    ["yihuan_pp"] = "新卧龙吟",
    ["yihuan_tb"] = "新卧龙吟",
    ["yihuan_xy"] = "新卧龙吟",
    ["yihuan_ky"] = "新卧龙吟",
    ["yihuan_haima"] = "新卧龙吟",
    ["yihuan_itool"] = "新卧龙吟",

}
--热更新目录
appFolderNames = {
    ["local"] = "com.cn.newwl.local",
    ["yihuan"] = "com.cn.newwl",
    ["yihuan_test"] = "com.cn.newwl.test",
    ["yihuan_sdktest"] = "com.cn.newwl.sdktest",
    ["yihuan_noupdater"] = "com.cn.newwl.noupdater",
    ["yihuan_ios"] = "com.cn.newwl",
    ["yihuan_I4"] = "com.yh.newwl.i4",
    ["yihuan_91"] = "com.yh.newwl.91",
    ["yihuan_pp"] = "com.yh.newwl.pp",
    ["yihuan_tb"] = "com.yh.newwl.tb",
    ["yihuan_xy"] = "com.yh.newwl.xy",
    ["yihuan_ky"] = "com.yh.newwl.ky",
    ["yihuan_haima"] = "com.yh.newwl.hm",
    ["yihuan_itool"] = "com.yh.newwl.itool",
}
local sdkFolders = {
    ["local"] = "local",
    ["yihuan"] = "yihuan",
    ["yihuan_test"] = "local",
    ["yihuan_sdktest"] = "yihuan",
    ["yihuan_noupdater"] = "local",
    ["yihuan_ios"] = "yihuan",
    ["yihuan_I4"] = "yihuan",
    ["yihuan_91"] = "yihuan",
    ["yihuan_pp"] = "yihuan",
    ["yihuan_tb"] = "yihuan",
    ["yihuan_xy"] = "yihuan",
    ["yihuan_ky"] = "yihuan",
    ["yihuan_haima"] = "yihuan",
    ["yihuan_itool"] = "yihuan",
}
args.sdk = sdkFolders[args.platform]
app_name = appNames[args.platform]
profile = profiles[args.platform]
packageName = packageNames[args.platform]
app_folder = appFolderNames[args.platform]
shortName = "newwl"
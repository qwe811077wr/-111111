local function __dump(depth, ...)
    local str = '' .. os.date('%c', os.time()) .. '  '
    for i = 1, depth do
        str = str .. '\t'
    end
    local arg = {...}
    if #arg == 1 and type(arg[1]) == 'table' then
        arg = arg[1]
    end
    for k, v in pairs(arg) do
        local s = str
        if type(k) == 'string' then
            s = s .. k .. ':'
        end
        if type(v) == 'table' then
            print(s)
            __dump(depth + 1, v)
        else
            print(s .. tostring(v))
        end
    end
end

function uq.jumpToBuildGuide(jump_id)
    --主城建筑跳转
    local info = StaticData['module'][jump_id]
    if info.jumpObject == '' then
        return
    end
    local objects = string.split(info.jumpObject, ',')
    if #objects > 0 then
        local building_info = StaticData['buildings']['CastleMap'][tonumber(objects[1])]
        if building_info.level > uq.cache.role:level() then
            uq.fadeInfo(building_info.name .. StaticData['local_text']['decree.not.open'])
            return
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_JUMP_TO_ITEM, build_id = tonumber(objects[1]), item_id = tonumber(objects[2])})
    end
end

function uq.jumpToModule(jump_id, args, hide_show)
    local info = StaticData['module'][jump_id]
    if not info or info.cmdName == "" then
        if not hide_show then
            uq.fadeInfo(StaticData["local_text"]["label.common.module.des"])
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.FAIL)
        end
        return false
    end

    local instance_id = math.floor(tonumber(info.openMission) / 100)
    if instance_id ~= 0 then
        local instance_config =  StaticData['instance'][instance_id]
        local map_config = StaticData.load('instance/' .. instance_config.fileId).Map[instance_id].Object[info.openMission]
        if not uq.cache.instance:isNpcPassed(info.openMission) then
            if not hide_show then
                uq.fadeInfo(string.format('%s%s %s', StaticData['local_text']['main.pass.instance.limit'], instance_config.name, map_config.Name))
            end
            return false
        end
    end

    if info.jumpObject ~= "" then
        local module_info = string.split(info.jumpObject, ',')
        local building_info = StaticData['buildings']['CastleMap'][tonumber(module_info[1])]
        if building_info.level > uq.cache.role:level() then
            if not hide_show then
                uq.fadeInfo(building_info.name .. StaticData['local_text']['decree.not.open'])
            end
            return false
        end
    end

    if tonumber(info.openLevel) > uq.cache.role:level() then
        if not hide_show then
            uq.fadeInfo(string.format(StaticData["local_text"]["label.main.city.open.lv"],info.openLevel))
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.FAIL)
        end
        return false
    end
    if hide_show then
        return true
    end
    local params = {}
    params = info.Param and info.Param[1]
    if params == nil then
        params = {}
    end
    if args ~= nil then
        for k, v in pairs(args) do
            params[k] = v
        end
    end
    uq.runCmd(info.cmdName, {params})
    return true
end

function uq.debug(...)
    __dump(0, ...)
end

function uq.showRedStatus(node, status, off_x, off_y)
    local img = node:getChildByName("widget_red_img")
    if status then
        if img == nil then
            local red_img = ccui.ImageView:create("img/common/ui/g03_0257.png")
            node:addChild(red_img)
            red_img:setName("widget_red_img")
            off_x = off_x == nil and 0 or off_x
            off_y = off_y == nil and 0 or off_y
            red_img:setPosition(cc.p(node:getContentSize().width * 0.5 + off_x, node:getContentSize().height * 0.5 + off_y))
        end
    else
        if img ~= nil then
            img:removeSelf()
        end
    end
end

function uq.setSymbolContentColor(str, str_start, str_end, color)
    local str = str or ""
    if str == "" then
        return ""
    end
    local str_str = ""
    local color = color or '#06e349'
    local tab = str.toChars(str)
    for i, v in ipairs(tab) do
        if v == str_start then
            str_str = str_str .. str_start .. "<font color=" .. color .. ">"
        elseif v == str_end then
            str_str = str_str .. "</font>" ..str_end
        else
            str_str = str_str .. v
        end
    end
    return str_str
end

function uq.runCmd(cmdName, args)
    local cmd = require('app/cmd/' .. cmdName)
    if cmd ~= nil then
        return cmd.run(unpack(checktable(args)))
    end
    return false
end

function uq.fadeInfo(msg, x, y, color, bg, effect, off_x, off_y)
    -- TODO Words Tips Position
    x = x or 0
    y = y or 44
    uq.ModuleManager:getInstance():show(uq.ModuleManager.TIP_MODULE, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 1, moduleType = 4, msg = msg, x = x, y = y, color = color, bg = bg, effect = effect, off_x = off_x, off_y = off_y})
end

function uq.fadeItemInfo(item_info, x, y)
    -- TODO Words Tips Position
    x = x or 0
    y = y or 44
    uq.ModuleManager:getInstance():show(uq.ModuleManager.TOAST_ITEM_INFO, {moduleType = 4, x = x, y = y, item_info = item_info})
end

function uq.fadeAttr(msg, x, y, color, size, font, zOrder)
    x = x or display.width / 2
    y = y or display.height / 2
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ATTRIBUTE_TIP_MODULE, {moduleType = 4, msg = msg, x = x, y = y, color = color, size = size, font = font, zOrder = zOrder})
end

function uq.confirm(msg, okHandler, cancelHandler)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CONFIRM_MODULE, {moduleType=2, msg=msg, okHandler=okHandler, cancelHandler=cancelHandler, zOrder=10001})
end

function uq.addConfirmBox(data,confirm_id)
    local confirm_id = confirm_id or uq.config.constant.CONFIRM_TYPE.NULL
    if uq.cache.role.confirm_ids[confirm_id] then
        if data.confirm_callback then
            data.confirm_callback()
        end
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CONFIRM_BOX_MODULE)
    if not panel then
        panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CONFIRM_BOX_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.CONFIRM_BOX_ZORDER)
        panel:addConfirmBox(data,confirm_id)
    else
        panel:addConfirmBox(data,confirm_id)
    end
end

function uq.checkRewardsByCountry(rewards)
    --剔除国家不一样的武将奖励
    local reward_array = {}
    if type(rewards) == "string" then
        reward_array = uq.RewardType.parseRewards(rewards)
    else
        reward_array = rewards
    end
    if #reward_array == 0 then
        return reward_array
    end
    local index = 1
    while index <= #reward_array do
        local reward = reward_array[index]
        if reward:type() == uq.config.constant.COST_RES_TYPE.GENERALS or reward:type() == uq.config.constant.COST_RES_TYPE.SPIRIT then
            local data = reward:data()
            if data.camp ~= 0 and data.camp ~= uq.cache.role.country_id then
                table.remove(reward_array, index)
                index = index - 1
            end
        end
        index = index + 1
    end

    local arr_reward_info = {}
    for k, v in ipairs(reward_array) do
        local info = v:toEquipWidget()
        table.insert(arr_reward_info, info)
    end
    return arr_reward_info
end

function uq.closeConfirmBox()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CONFIRM_BOX_MODULE)
    if panel then
        panel:disposeSelf()
    end
end

function uq.sendShareMsg(info)
    if uq.cache.role:level() < 2 then
        uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.module.des4'], 2))
        return
    elseif info.channel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if not uq.cache.role:hasCrop() then
            uq.fadeInfo(StaticData['local_text']['arena.rank.crop.not'])
            return
        end
        if uq.cache.role:level() < 10 then
            uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.module.des4'], 10))
            return
        end
    end

    local chat_server_id = '0'
    local chat_name = ''
    local contact_id = 1
    local data = {
        msg_type = info.channel,
        server_id_len = string.len(chat_server_id),
        server_id = chat_server_id,
        contact_role_id = contact_id,
        contact_role_name_len = string.len(chat_name),
        contact_role_name = chat_name,
        content_type = info.content_type,
        content = info.content
    }
    network:sendPacket(Protocol.C_2_S_CHAT_MSG, data)
    uq.fadeInfo(StaticData['local_text']['fly.nail.battlereport.des1'])
end

function uq.showLoading(msg)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.PROGRESS_MODULE, {zOrder=100000, msg=msg})
end

function uq.showItemTips(info, equip_id)
    if info.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ITEM_TIPS_MODULE,{info = info, pre_equip_id = equip_id, mode = info.mode})
    elseif info.type == uq.config.constant.COST_RES_TYPE.GENERALS or info.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_TIPS_MODULE,{general_id = info.id, _type = info.type, mode = info.mode})
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.TOOL_TIPS_MODULE,{info = info, mode = info.mode})
    end
end

function uq.closeLoading()
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.PROGRESS_MODULE)
end

function uq.curSecond()
    return require('socket').gettime()
end

function uq.curMillSecond()
    return uq.Utils:getMilliSecond()
end

function uq.curFloatSecond()
    return uq.Utils:getMilliSecond() / 1000
end

function uq.curServerSecond()
    return uq.cache.server_data:getServerTime()
end

function uq.curWeekDay()
    return os.date("%w", uq.curServerSecond())
end

function uq.curDay()
    return os.date("%d", uq.curServerSecond())
end

function uq.timeSecond(hour, min, sec, deltaDay)
    local curDate = os.date("*t", uq.curServerSecond())
    return os.time({
        day=curDate.day + (deltaDay or 0),
        month=curDate.month,
        year=curDate.year,
        hour=hour or curDate.hour,
        min=min or curDate.min,
        sec=sec or curDate.sec})
end

function uq.timeSecondByDate(month, day, hour, min, sec, deltaDay)
    local curDate = os.date("*t", uq.curServerSecond())
    return os.time({
        day=(day or curDate.day) + (deltaDay or 0),
        month=(month or curDate.month),
        year=curDate.year,
        hour=hour or curDate.hour,
        min=min or curDate.min,
        sec=sec or curDate.sec})
end

function uq.formatTime(datatime,tag,showHour)
    if datatime < 1000000 then
        tag = tag or ":"
        local hour = math.floor(datatime / 3600)
        local minutes = math.floor((datatime - hour * 3600) / 60)
        local sec = datatime - hour * 3600 - minutes * 60

        if sec < 10 then
            sec = "0"..sec
        end

        if minutes < 10 then
            minutes = "0"..minutes
        end

        if showHour then
            if hour < 10 then
               hour = "0"..hour
            end

            return hour..tag..minutes..tag..sec
        else
            return hour*60+minutes..tag..sec
        end
    else
        local tab=os.date("*t",datatime)
        tag = tag or "-"
        return tab.year..tag..tab.month..tag..tab.day..tag..tab.hour..tag..tab.min..tag..tab.sec
    end
end

function uq.randomArrayItems (arr, num, excepts)
    local temp_array = {}
    if excepts == nil then
       excepts = {}
    else
       excepts = excepts
    end

    for index = 1,#arr do
        local isJump = false
        for i = 1,#excepts do
            if excepts[i]~=nil and  arr[index] == excepts[i] then
                isJump = true
                break
            end
        end

        if not isJump then
            table.insert(temp_array,arr[index])
        end
    end

    local return_array = {}
    for i = 1,num do
        if #temp_array >0 then
            local arrIndex = math.random(1,#temp_array)
            return_array[i] = temp_array[arrIndex]
            table.remove(temp_array,arrIndex)
        else
            break
        end
    end

    return return_array

end

uq.log = function( ... )
    if not CC_SHOW_FPS then
        return
    end

    local tv = "\n"
    local xn = 0
    local function tvlinet(xn) for i=1,xn do tv = tv.."\t" end end
    local function printTab(i,v)
        if type(v) == "table" then
            tvlinet(xn)
            xn = xn + 1
            tv = tv..""..i..":Table{\n"
            table.foreach(v,printTab)
            tvlinet(xn)
            tv = tv.."}\n"
            xn = xn - 1
        elseif type(v) == nil then
            tvlinet(xn)
            tv = tv..i..":nil\n"
        else
            tvlinet(xn)
            tv = tv..i..":"..tostring(v).."\n"
        end
    end
    local function dumpParam(tab)
        for i=1, #tab do
            if tab[i] == nil then
                tv = tv.."nil\t"
            elseif type(tab[i]) == "table" then
                xn = xn + 1
                tv = tv.."\ntable{\n"
                table.foreach(tab[i],printTab)
                tv = tv.."\t}\n"
            else
                tv = tv..tostring(tab[i]).."\t"
            end
        end
    end
    local x = ...
    if type(x) == "table" then
        table.foreach(x,printTab)
    else
        dumpParam({...})
    end
    print(tv)
    uq.ModuleManager:getInstance():debugInfo(tv)
end

function  math.pointIsInCircle(cPoint, cRadius, point)
    -- 两点之间的距离
    local dis = math.p2pDistance(point, cPoint);
    --在边上也认为在圆内
    if dis <= cRadius then
        return math.max(dis, 1);
    else
        return 0;
    end
end

function math.boxCircleIntersect(rect, p, r)
         -- 计算矩形的中心点
        local c = cc.p(rect.x + rect.width / 2, rect.y + rect.height / 2)
        -- 计算矩形的半长
        local h = math.sqrt(rect.width * rect.width + rect.height * rect.height) / 2
        -- 第1步：转换至第1象限
        local v = cc.p(math.abs(p.x - c.x), math.abs(p.y - c.y))
        -- 第2步：求圆心至矩形的最短距离矢量
        local u = cc.p(math.max(v.x - h, 0), math.max(v.y - h, 0))
        -- 第3步：长度平方与半径平方比较
        return u.x * u.x + u.y * u.y <= r * r
end

function math.rectOverlapRatio(rect1, rect2)
    local x1 = rect1.x
    local y1 = rect1.y
    local width1 = rect1.width
    local height1 = rect1.height
    local D

    local x2 = rect2.x
    local y2 = rect2.y
    local width2 = rect2.width
    local height2 = rect2.height

    local endx = math.max(x1 + width1, x2 + width2)
    local startx = math.min(x1, x2)
    local width = width1 + width2 - (endx - startx)

    local endy = math.max(y1 + height1, y2 + height2)
    local starty = math.min(y1, y2)
    local height = height1 + height2 - (endy - starty)

    if width <= 0 or height <= 0 then
        D = 0
    else
        local Area = width * height
        local Area1 = width1 * height1
        local Area2 = width2 * height2
        local ratio = Area / (Area1 + Area2 - Area)

        D = ratio
    end
    return D
end

--[[
    获取带颜色文本中剔除颜色代码后的文本
    -- 目前只能处理的是类似 [color='0xffffff']something[/color] 这种格式 -- 这个后面再做兼容吧
    目前只能处理的是类似 [color='#ffffff']something[/color] 这种格式
    eg:
    -- local text = [color='0xffffff']something[/color] -- 这个后面再做兼容吧
    local text = [color='#ffffff']something[/color]
    local newText = getRichTextContent(text)

    print(newText) -- newText = something
]]
function uq.getRichTextContent( text )
    local function _getRichTextColor( _text )
        local endIdx = string.find( _text, "%]")
        if endIdx==nil then
            return  _text
        end
        endIdx = endIdx - 1

        return string.sub(_text, endIdx+2, #_text-8)
    end

    local startArr = {}
    local endArr = {}
    local _string = ""

    local tmp = text
    -- local startIdx = string.find(tmp, "%[color='0[xX]%w%w[%w]?[%w]?[%w]?[%w]?'%]")
    local startIdx = string.find(tmp, "%[color='#%w%w[%w]?[%w]?[%w]?[%w]?'%]")
    if not startIdx then
        return text
    end
    while startIdx~=nil do
        tmp = string.sub(tmp, startIdx + 9)
        if startArr[#startArr] then
            startIdx = startArr[#startArr] + startIdx + 8
        end
        startArr[#startArr+1] = startIdx
        -- local idx = string.find(tmp, "%[color='0[xX]%w%w[%w]?[%w]?[%w]?[%w]?'%]")
        local idx = string.find(tmp, "%[color='#%w%w[%w]?[%w]?[%w]?[%w]?'%]")
        -- "%[color=0[xX]%w%w%w%w%w%w%]" 为什么不用这种方式？ 原因：匹配0x25 这种情况 (?零次或一次匹配前面的字符或子表达式)
        startIdx = idx
    end
    tmp = text
    local endIdx = string.find(tmp, "%[/color%]")
    while endIdx~=nil do
        tmp = string.sub(tmp, endIdx + 8)
        -- uq.log(" ------------ tmp",tmp)
        if endArr[#endArr] then
            endIdx = endArr[#endArr] + endIdx
        end
        endArr[#endArr+1] = endIdx + 7
        local idx = string.find(tmp, "%[/color%]")
        endIdx = idx
    end
    if #startArr>0 and #endArr>0 then
        if startArr[1]==1 and endArr[#endArr]==#text then
            --全局颜色
            if #startArr==1 or startArr[2]<endArr[1] then
                local str = _getRichTextColor(text)
                text = str
                table.remove(startArr,1)
                table.remove(endArr,#endArr)
            end
        end

        local strArr = {}
        local lastIdx = 1
        -- uq.log(" ----------- startArr",startArr)
        for k, idx in ipairs(startArr) do
            if idx~=lastIdx then
                strArr[#strArr+1] = string.sub(text, lastIdx, idx-1)
            end
            strArr[#strArr+1] = string.sub(text, idx, endArr[k])
            lastIdx = endArr[k] + 1
        end
        if lastIdx<#text then
            strArr[#strArr+1] = string.sub(text, lastIdx)
        end
        if #strArr>0 then
            for k, v in ipairs(strArr) do
                local str = _getRichTextColor(v)
                -- str = string.gsub(str, "[\r\n]+", "") --TODO:换行支持(cocos不支持)
                _string = _string..str
            end
            return _string
        end
    end
    return _string
end

function string.toChars(str)
    local len = #str
    local skip = 0
    local ret = {}
    for i = 1, len do
        if i >= skip then
            local cur_byte = string.byte(str, i)
            local byte_count = 1
            if cur_byte > 0 and cur_byte <= 127 then
                byte_count = 1
            elseif cur_byte >= 192 and cur_byte < 224 then
                byte_count = 2
            elseif cur_byte >= 224 and cur_byte < 240 then
                byte_count = 3
            elseif cur_byte >= 240 and cur_byte <= 247 then
                byte_count = 4
            end
            local char = string.sub(str, i, i + byte_count - 1)
            skip = i + byte_count
            table.insert(ret, char)
        end
    end
    return ret
end
--截取中文字符
--@param string str 源字符串
--@param number startIdx 从几个字符开始
--@param number len  截取几个字符（每个中文，英文，数字都算一个）
function string.subUtf(str, startIdx, len)
    if len==0 then
        return ""
    end
    local lenInByte = #str
    local tmp = ""
    local skip = 0
    local charIdx = 1
    local charCount = 0
    for i=1,lenInByte do
        if i>=skip then
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<224 then
                byteCount = 2
            elseif curByte>=224 and curByte<240 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(str, i, i+byteCount-1)
            skip = i + byteCount
            if charIdx>=startIdx then
                tmp = tmp .. char
                charCount = charCount + 1
                if charCount==len then
                    break
                end
            end
            charIdx = charIdx + 1
        end
    end
    return tmp
end

function string.utfLen(str)
    local lenInByte = #str
    local skip = 0
    local charIdx = 0
    local t = {0,0,0,0}

    for i=1,lenInByte do
        if i>=skip then
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
                t[1] = t[1] + 1
            elseif curByte>=192 and curByte<224 then
                byteCount = 2
                t[2] = t[2] + 1
            elseif curByte>=224 and curByte<240 then
                byteCount = 3
                t[3] = t[1] + 1
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
                t[4] = t[4] + 1
            end

            skip = i + byteCount
            charIdx = charIdx + 1
        end
    end
    return charIdx, t
end

local bit = require("bit")
function string.unicodeToUtf8(str)
    if type(str)~="string" then
        return str
    end

    local ret = ""
    local i = 1
    while true do
        local code = nil
        local num = string.byte(str,i)

        if num ~= nil and string.sub(str,i,i+1) == "\\u" then
            code = tonumber("0x"..string.sub(str,i+2,i+5))
            i = i+6
        elseif num ~= nil then
            code = num
            i = i+1
        else
            break
        end

        -- uq.log("unicodeToUtf8  code",code)
        if code <= 0x007f then
            ret = ret..string.char(bit.band(code,0x7f))
        elseif code >= 0x0080 and code <= 0x07ff then
            ret = ret..string.char(bit.bor(0xc0,bit.band(bit.rshift(code,6),0x1f)))
            ret = ret..string.char(bit.bor(0x80,bit.band(code,0x3f)))
        elseif code >= 0x0800 and code <= 0xffff then
            ret = ret..string.char(bit.bor(0xe0,bit.band(bit.rshift(code,12),0x0f)))
            ret = ret..string.char(bit.bor(0x80,bit.band(bit.rshift(code,6),0x3f)))
            ret = ret..string.char(bit.bor(0x80,bit.band(code,0x3f)))
        end

        if i % 3000 == 0 then
            collectgarbage("collect")
        end
    end
    ret = ret..'\0'
    -- uq.log("unicodeToUtf8  ret",ret)
    return ret
end

function string.utf8ToUnicode(str)
    if type(str)~="string" then
        return str
    end

    local ret = ""
    local i = 1
    local num1 = string.byte(str, i)

    while num1 ~= nil do

        print(num1)

        local tempVar1,tempVar2

        if num1 >= 0x00 and num1 <= 0x7f then

            tempVar1=num1

            tempVar2=0

        elseif bit.band(num1,0xe0)== 0xc0 then

            local t1 = 0
            local t2 = 0

            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(str,i)

            t2 = bit.band(num1,bit.rshift(0xff,2))


            tempVar1=bit.bor(t2,bit.lshift(bit.band(t1,bit.rshift(0xff,6)),6))

            tempVar2=bit.rshift(t1,2)

        elseif bit.band(num1,0xf0)== 0xe0 then

            local t1 = 0
            local t2 = 0
            local t3 = 0

            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(str,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            i=i+1
            num1=string.byte(str,i)
            t3 = bit.band(num1,bit.rshift(0xff,2))

            tempVar1=bit.bor(bit.lshift(bit.band(t2,bit.rshift(0xff,6)),6),t3)
            tempVar2=bit.bor(bit.lshift(t1,4),bit.rshift(t2,2))

        end

        ret=ret..string.format("\\u%02x%02x",tempVar2,tempVar1)
        print(ret)

        i=i+1
        num1=string.byte(str,i)
    end

    print(ret)

    return ret
end

function uq.format(str, ...)
    local function replaceParam(str, i, v)
        str = string.gsub(str,"{"..i.."}", v)
        return str
    end

    local i = 1
    local x = {...}
    for k,v in pairs(x) do
        str = replaceParam(str, i, v)
        i = i + 1
    end
    return str
end

function uq.formatA(str, params)
    for i = 1,#params do
        str = string.gsub(str,"{"..i.."}", params[i])
    end
    return str
end

--转换 0xffffff 这种类型的颜色值变为 cc.c4b, alpha=nil cc.c3b
function uq.parseColor( color, alpha )
    -- uq.log(" ========================== color",color)
    color = string.gsub(tostring(color), "0x", "")
    local r = tonumber("0x0"..string.sub(color, #color-5, #color-4) )
    local g = tonumber("0x0"..string.sub(color, #color-3, #color-2) )
    local b = tonumber("0x0"..string.sub(color, #color-1, #color) )
    if alpha then
        return cc.c4b(r,g,b,alpha)
    else
        return cc.c3b(r,g,b)
    end
end

--扩展Text,处理RichText
local Text = ccui.Text
function uq.richTextToHTML(str)
    return (string.gsub(str, '%[color=[\'\"]?[0]?[xX]?[#]?([0-9A-Fa-f]-)[\'\"]?%](.-)%[/color%]', '<font color="0x%1">%2</font>'))
end

function string.splitString(str, sep)
    local ret = {}
    local s, e = string.find(str, sep)
    while s do
        if s > 1 then
            table.insert(ret, string.sub(str, 1, s - 1))
        end
        str = string.sub(str, e + 1)
        s, e = string.find(str, sep)
    end
    table.insert(ret, str)
    return ret
end


--<font color='#FFFFFF'>xx\nxx</font>
function Text:setHTMLText(html, maxLen, isOutline, outlinecolor, isleft, isMultip, maxHeight)
    --Don't challenge me with complex pattern, although I have an elegant looking, but simple core
    if #html == 0 then
        return
    end
    local anchor = self:getAnchorPoint()
    local fontSize = self:getFontSize()
    local fontName = self:getFontName()

    self:removeAllChildren()
    self:ignoreContentAdaptWithSize(false)
    self:setString('')
    self:removeAllChildren()
    self:setAnchorPoint(0, 0)
    local size = self:getContentSize()
    local isMult = size.height >= fontSize*2
    if isMultip then
        isMult = true
    end
    local originWidth = size.width
    if originWidth == 0 then
        self:setContentSize(cc.size(100, 20))
        originWidth = 100
    end
    if not maxLen then
        maxLen = string.utfLen(html)
    end
    local text = ccui.Text:create()
    text:setString('1')
    text:setFontName(self:getFontName())
    text:setFontSize(self:getFontSize())
    if isOutline then
        if not outlinecolor then
            text:enableOutline(cc.c3b(0, 0, 0), 1) -- TODO Add Outline
        else
            text:enableOutline(outlinecolor, 1)
        end
    end
    local singleHeight = text:getContentSize().height
    local _width = originWidth
    local _totalWidth = 0
    local MAX_CHARACTERS_LINE = math.ceil(originWidth / text:getContentSize().width)
    local MAX_LINE_LEN =  math.ceil(originWidth / (fontSize))
    local nodes = {}
    local stack = {}
    local PATTERN = "(.-)<(.-)>"
    local first, last, m1, m2 = string.find(html, PATTERN)
    while first and maxLen > 0 do
        if #m1 > 0 then
            if string.utfLen(m1) > maxLen then
                m1 = string.subUtf(m1, 1, maxLen)
            end
            local node = {text = m1, tags = {}}
            for i = 1, #stack, 1 do
                table.insert(node.tags, stack[i])
            end
            table.insert(nodes, node)
            maxLen = maxLen - string.utfLen(m1)
            if maxLen <= 0 then
                break
            end
        end
        if #m2 > 0 then
            if string.sub(m2, 1, 1) == '/' then
                if #stack > 0 then
                    table.remove(stack)
                end
            else
                local t = string.splitString(m2, '%s+')
                if #t > 0 then
                    local tag = {name = t[1], attr = {}}
                    for i = 2, #t, 1 do
                        local t1 = string.splitString(t[i], '=')
                        local attrName = t1[1]
                        if #t1 > 1 then
                            tag.attr[attrName] = string.gsub(t1[2], '["\']', '')
                        else
                            tag.attr[attrName] = ''
                        end
                    end
                    table.insert(stack, tag)
                end
            end
        end
        html = string.sub(html, last + 1)
        first, last, m1, m2 = string.find(html, PATTERN)
    end
    if #html > 0 then
        if string.utfLen(html) > maxLen then
            html = string.subUtf(html, 1, maxLen)
        end
        local node = {text = html, tags = {}}
        table.insert(nodes, node)
    end

    local maxLineHeight = 0
    local newHeight = 0
    local posX, posY = 0, 0
    local i = 1
    local curNode = nodes[i]
    local fields = {}
    while i < #nodes or curNode do
        if not curNode then
            i = i + 1
            curNode = nodes[i]
        end
        local text = ccui.Text:create()
        text:setTextColor(self:getTextColor())
        text:setFontName(self:getFontName())
        text:setFontSize(self:getFontSize())
        text:setAnchorPoint(0, 0)
        if isOutline then
            -- text:enableOutline(cc.c3b(0, 0, 0), 1) -- TODO Add Outline
            if not outlinecolor then
                text:enableOutline(cc.c3b(0, 0, 0), 1) -- TODO Add Outline
            else
                text:enableOutline(outlinecolor, 1)
            end
        end
        for j = 1, #curNode.tags, 1 do
            local name = string.lower(curNode.tags[j].name)
            if name == 'font' then
                for k, v in pairs(curNode.tags[j].attr) do
                    if string.lower(k) == 'color' then
                        local s, e, m1 = string.find(v, '[0]?[xX]?[#]?([0-9A-Fa-f]+)')
                        if s then
                            text:setTextColor(uq.parseColor(m1))
                        end
                    elseif string.lower(k) == 'size' then
                        text:setFontSize(tonumber(v))
                    end
                end
            elseif name == 'a' then
                for k, v in pairs(curNode.tags[j].attr) do
                    if string.lower(k) == 'color' then
                        local s, e, m1 = string.find(v, '[0]?[xX]?[#]?([0-9A-Fa-f]+)')
                        if s then
                            text:setTextColor(uq.parseColor(m1))
                        end
                    elseif string.lower(k) == 'size' then
                        text:setFontSize(tonumber(v))
                    end
                end
                text:setTouchEnabled(true)
                text:addClickEventListener(handler(curNode.tags[j].attr, uq.handleHref))
            end
        end
        local txt = curNode.text
        local utfLen = string.utfLen(txt)
        local endIdx = utfLen
        if isMult and utfLen >= MAX_CHARACTERS_LINE then
            txt = string.subUtf(txt, 1, MAX_CHARACTERS_LINE)
        end
        text:setString(txt)
        if isMult and posX + text:getContentSize().width > originWidth then
            local widthLeft = originWidth - posX
            local tmpTxt = txt
            local shiftChars = 0
            while widthLeft > 0 and #tmpTxt > 0 do
                local guessMaxLen = math.ceil(widthLeft / text:getContentSize().width * #tmpTxt)
                local tmpTxtLen = string.utfLen(tmpTxt)
                if guessMaxLen > tmpTxtLen then
                    guessMaxLen = tmpTxtLen
                end
                local guessMinLen = math.floor(widthLeft / text:getContentSize().width * #tmpTxt / 3)
                if guessMinLen < 1 then
                    break
                end
                shiftChars = shiftChars + guessMinLen
                text:setString(string.subUtf(tmpTxt, 1, guessMinLen))
                widthLeft = widthLeft - text:getContentSize().width
                tmpTxt = string.subUtf(tmpTxt, guessMinLen + 1, guessMaxLen - guessMinLen)
                text:setString(tmpTxt)
            end
            endIdx = shiftChars
        end
        text:setPosition(posX, posY)
        posX = posX + text:getContentSize().width
        local nextStartIdx = endIdx + 1
        local newLineS, newLineE = string.find(string.subUtf(curNode.text, 1, endIdx), '[\r]?\n[\r]?')
        if newLineS then
            endIdx = string.utfLen(string.sub(curNode.text, 1, newLineS - 1))
            nextStartIdx = endIdx + (newLineE - newLineS) + 2
        end
        if endIdx < utfLen then
            text:setString(string.subUtf(curNode.text, 1, endIdx))
            curNode = {text = string.subUtf(curNode.text, nextStartIdx, utfLen - nextStartIdx + 1), tags = nodes[i].tags}
            posX = 0
            posY = 0 --(posY - maxLineHeight)
        end
        if text:getContentSize().height > maxLineHeight then
            maxLineHeight = maxHeight or text:getContentSize().height
        end
        _totalWidth = text:getContentSize().width + _totalWidth
        if endIdx < utfLen then
            newHeight = newHeight + maxLineHeight
            for k, v in pairs(fields) do
                v:setPosition(v:getPositionX(), v:getPositionY() + maxLineHeight)
            end
            text:setPosition(text:getPositionX(), maxLineHeight)
            maxLineHeight = 0
        else
            curNode = nil
        end
        if endIdx > 0 then
            self:addChild(text)
            table.insert(fields, text)
        end
    end
    newHeight = newHeight + maxLineHeight
    _width = _totalWidth
    if newHeight <= singleHeight then
        originWidth = _width
    end
    if not isleft and #fields > 0 then
        local posy = math.floor(fields[1]:getPositionY())
        local info = {}
        local label_array = {}
        for k, v in pairs(fields) do
            if posy ~= math.floor(v:getPositionY()) then
                posy = math.floor(v:getPositionY())
                info = {}
            end
            table.insert(info,v)
            label_array[posy] = info
        end
        local width = 0
        for k, v in pairs(label_array) do
            width = 0
            for _,t in ipairs(v) do
                width = width + t:getContentSize().width
            end
            if width < originWidth then --居中显示
                for _,t in ipairs(v) do
                    t:setPosition(t:getPositionX() + (originWidth - width) / 2, t:getPositionY())
                end
            end
        end
    end
    self:setContentSize(originWidth, newHeight)
    self:setAnchorPoint(cc.p(anchor.x, anchor.y))
end

function uq.handleHref(attr, evt)
    -- cclog(" -- handleHref -- ",attr.href,evt)
    local list = {}
    local str = attr.href
    list = string.split(str, ",")

    -- TODO处理定义类型的点击事件
    if list[1] == "event:"..uq.TypeConst.MOVE_TO_POSITION then
        local _mapId = tonumber(list[2])
        local _pos = cc.p(tonumber(list[3]), tonumber(list[4]))
        local param = {mid=_mapId, pos=_pos}
        local tk = uq.WorldTracker:create(param)
        uq.cache.role:setTarget(tk)
    end
end

----拷贝
function uq.tableCopy(_table)
    if type(_table) ~= "table" then
        return
    end
    local new_tab = {};
    for i,v in pairs(_table) do
        if type(v) == "table" then
            new_tab[i] = uq.tableCopy(v)
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

function uq.isValueInTb(value , tb)
    for k , v in pairs(tb) do
        uq.log("key ::: " , k , " ---- value ::: " , v , " -- value :::" , value)
        if v == value then
            return true
        end
    end
    return false
end

function uq.isKeyInTb(key , tb)
    for k , v in pairs(tb) do
        if k == key then
            return true
        end
    end
    return false
end

function uq.restoreSpriteBlend(signSp)
    local cb1 = {}
    cb1.src = GL_ONE
    cb1.dst = GL_ONE_MINUS_SRC_ALPHA
    --混合后的RGBA为：(Rs*N_Rs+ Rd* N_Rd，Gs*N_Gs+ Gd* N_Gd，Bs*N_Bs+ Bd* N_Bd，As*N_As+ Ad* N_Ad)
    signSp:setBlendFunc(cb1)
    signSp:visit()
end

function uq.setBtnScaleEvent(btn)
    btn:setPressedActionEnabled(true)
    btn:setZoomScale(uq.config.BUTTON_ZOOM_SCALE)
end

function uq.getTime(seconds,mType)
    local day = math.floor(seconds / 24 / 3600)
    seconds = seconds % (24 * 3600)
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    -- return hours,minutes,seconds
    if mType ~= nil then
        local cdTime = ""
        if mType == uq.config.constant.TIME_TYPE.HHMMSS then -- HHMMSS
            cdTime = string.format("%02d", hours + day * 24) .. ":"..string.format("%02d",minutes)..":"..string.format("%02d",seconds)
        elseif mType == uq.config.constant.TIME_TYPE.MMSS then -- MMSS
            cdTime = string.format("%02d",minutes)..":"..string.format("%02d",seconds)
        end
        return cdTime
    else
        return hours,minutes,seconds,day
    end
end

function uq.getTimeStampByDaily(time)
    if string.len(time) < 12 then
        return 0
    end
    local year = string.sub(time, 1, 4)
    local month = string.sub(time, 5, 6)
    local day = string.sub(time, 7, 8)
    local hour = string.sub(time, 9, 10)
    local minutes = string.sub(time, 11, 12)
    local seconds = string.sub(time, 13, 14)
    seconds = seconds == "" and 0 or seconds
    return os.time({day = day, month = month, year = year, hour = hour, minute = minutes, second = seconds})
end

function uq.getCountDownTime(time, hours, minutes, seconds)
    local time = time or uq.cache.server_data:getServerTime()
    local hours = hours or 4
    local minutes = minutes or 0
    local seconds = seconds or 0

    local tab_server_time = os.date("*t", time)
    local server_time = tab_server_time.hour * 3600 + tab_server_time.min * 60 + tab_server_time.sec

    local deadline = hours * 3600 + minutes * 60 + seconds
    local delta_time = deadline - server_time
    if delta_time < 0 then
        delta_time = delta_time + 3600 * 24
    end
    return delta_time
end

--返回不为零的最大单位
function uq.getTime2(seconds)
    local day = math.floor(seconds / 24 / 3600)
    seconds = seconds % (24 * 3600)
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    if day > 0 then
        return day .. StaticData['local_text']['label.common.day']
    elseif hours > 0 then
        return hours .. StaticData['local_text']['label.train.time.hour']
    elseif minutes > 0 then
        return minutes .. StaticData['local_text']['label.train.time.minute']
    elseif seconds >= 0 then
        return seconds .. StaticData['local_text']['label.common.second']
    end
end

-- @param 传入需要格式化的字符串,返回新的字符串和参数的计算类型
-- @param _type    0: 不需要传参；1：参数计算公式一  2：参数计算公式二
function uq.formatShowString( mString )
    local descDes = uq.static_data_manager.Lang:getNameByOriginalKey(mString)

    -- TODO 替换百分号
    local k = string.find(descDes, "%%")
    if k then
        descDes = string.gsub(descDes,"%%","%%%%")
    end

    local m = string.find(descDes,"#1")
    local _type = 0
    local pattern = nil

    local repString = "%%s"
    if not m then
        local k = string.find(descDes,"#2")
        if not k then -- == 没有参数 ==
            -- uq.log(" == 没有参数 == ")
            _type = 0
        else -- == 参数类型为 2
            -- uq.log(" == 参数类型为 2 == ")
            pattern = "#2"
            _type = 2
        end
    else -- == 参数类型为 1
        -- uq.log(" == 参数类型为 1 == ")
        pattern = "#1"
        _type = 1
    end

    local str = descDes
    if pattern then
        str = string.gsub(descDes,pattern,repString)
    end
    return str,_type
end

-- @param 本函数返回的是一个创建好了的RichText控件
-- @param 如果想只要一个空的RichText, 则根据自身需求来传参即可,另外需要自己在外部将RichText添加到想要添加的控件上
-- @param mWidget: (mIsEmpty为false)为传进来的控件模版,在编辑器中的text控件,根据此控件的设置来创建RichText,并设置为text的设置，其他参数可不传
-- @param mDataList 参数格式为：mWidget(模版控件)，mContSize(控件尺寸)，mAnPt(锚点)，mFont(字体文件路径)，
--                                  mFontSize(字体大小)，mMultiLine(是否换行)，mString(内容)，mIsEmpty(是否创建空的RichText)
-- @param mIsEmpty  是否要创建一个空的RichText   true:是； false:否
function uq.createRichText( mDataList)
    local mWidget = mDataList.mWidget
    local mContSize = mDataList.mContSize
    local mAnPt = mDataList.mAnPt
    local mFont = mDataList.mFont
    local mFontSize = mDataList.mFontSize
    local mMultiLine = mDataList.mMultiLine
    local mString = mDataList.mString or ""
    local mIsEmpty = mDataList.mIsEmpty

    local mWidgetSize = cc.size(20, 20)
    local mWidgetAnPt = cc.p(0.5,0.5)
    local mWidget_X = 0
    local mWidget_Y = 0

    if not mIsEmpty then
        if not mWidget then
            -- uq.log(" == 不是空的RichText,缺少在编辑器中的模版控件 == ")
            return
        end
        mWidget:setVisible(false)
        mWidgetSize = mWidget:getContentSize()
        mWidgetAnPt = mWidget:getAnchorPoint()
        mWidget_X = mWidget:getPositionX()
        mWidget_Y = mWidget:getPositionY()
    end

    local richText = uq.RichText:create()
    richText:setAnchorPoint(mAnPt or mWidgetAnPt)
    richText:setDefaultFont(mFont or "res/font/" .. uq.config.TTF_FONT)
    richText:setFontSize(mFontSize or 20)
    richText:setContentSize(mContSize or mWidgetSize)
    richText:setMultiLineMode(mMultiLine or true)
    richText:setText(mString or "")
    richText:setPosition(cc.p(mWidget_X, mWidget_Y))

    if not mIsEmpty then
        mWidget:getParent():addChild(richText)
    end

    return richText
end
-- local testStr = "<#FFFFFF>已开启{1}/{2}次,辣椒素<#FF00FF>打飞机<#FFFF00>客观地洒落扩大两国将萨科的老个空间的<#FFFFFF>萨拉噶快看到萨拉戈看破啊额四大皆空了",
-- local mDataList = {mWidget=des,mString=uq.formatA(testStr, {1,10})}
-- uq.createRichText( mDataList)


-- 动态格式化字符串
-- @param mSta      目标字符串
-- @param mTable    参数列表 (表为有序的，mTable[i]直接为值)
function uq.formatString( mStr, mTable )
    local newStr = mStr
    local testStr = "return string.format(\"" .. mStr  .. " \" "
    for i =1 , #mTable do
        testStr = testStr .. " , " .. ("\""..mTable[i].."\"")
    end
    testStr = testStr .. " )"
    newStr = loadstring(testStr)()
    return newStr
end

-- 骨骼动作音效一起播
function uq.animationPlay(anim, modelKey, action, repeatNums)
    anim:play(action)
    uq.playHeroActionSound(modelKey, action)
end

function uq.shakeScreen(layer, pos, offest_pos, scale, shake_time, speed_ratio, shake_tag)
    shake_tag = shake_tag or 9999
    if layer.shaking then
        return
    end
    local org_scale = layer:getScale()

    local scale_time = 0.01
    if scale == 1 then
        scale_time = 0
    end

    local per_round_time = 0.06 / speed_ratio --0.1
    local count = math.ceil((shake_time - scale_time * 2)/ per_round_time)

    layer.shaking = true
    layer:stopActionByTag(shake_tag)

    local pos_x = pos.x
    local pos_y = pos.y
    local offset_x = offest_pos.x
    local offset_y = offest_pos.y
    local pos1 = cc.pAdd(cc.p(pos_x, pos_y), cc.p(offset_x, offset_y))
    local pos2 = cc.pAdd(cc.p(pos_x, pos_y), cc.p(-offset_x, -offset_y))
    local shake_action = cc.Sequence:create(
            cc.MoveTo:create(per_round_time / 4, pos1),
            cc.MoveTo:create(per_round_time / 2, pos2),
            cc.MoveTo:create(per_round_time / 4, cc.p(pos_x, pos_y))
        )
    local action = cc.Sequence:create(
            cc.ScaleTo:create(scale_time, scale),
            cc.Repeat:create(shake_action, count),
            cc.ScaleTo:create(scale_time, org_scale),
            cc.CallFunc:create(function ()
                layer.shaking = nil
            end))

    action:setTag(shake_tag)
    layer:runAction(action)
end

function uq.shakeScreenByEffectFrame(shake_node, effect_item, shake_pos, effect_node)
    if not shake_node or not effect_node or not effect_node:getSkillEffectNode() then
        return
    end

    local org_scale = shake_node:getScale()
    local x, y = shake_node:getPosition()
    local org_pos = cc.p(x, y)

    local shakes = string.split(effect_item.shake, ',')
    if #shakes == 0 then
        return
    end

    local shake_start_config = {}
    local shake_end_config = {}

    for k, shake_index in ipairs(shakes) do
        local shake_item = StaticData['shake'][tonumber(shake_index)]
        if shake_item then
            shake_start_config[shake_item.startframe] = shake_item
            shake_end_config[shake_item.overframe] = shake_item

            shake_start_config[shake_item.startframe].shakeTag = 10000 + k
            shake_end_config[shake_item.overframe].shakeTag = 10000 + k

            shake_start_config[shake_item.startframe].shakeTime = (shake_item.overframe - shake_item.startframe) * effect_node:getAnimation():getDelayPerUnit()
        end
    end

    local function frameCallback(frame_num)
        if not shake_node.shaking and shake_start_config[frame_num] then
            local shake_config = shake_start_config[frame_num]

            if shake_config.shakeTime <= 0 then
                return
            end

            local offest_pos = cc.p(0, 0)
            if shake_config.shakemode == 1 then
                offest_pos = cc.p(shake_config.offest, 0)
            else
                offest_pos = cc.p(0, shake_config.offest)
            end

            uq.shakeScreen(shake_node, shake_pos, offest_pos, 1, shake_config.shakeTime, shake_config.speedRatio, shake_config.shakeTag)
        elseif shake_node.shaking == true and shake_end_config[frame_num] then
            local shake_config = shake_end_config[frame_num]
            shake_node:stopActionByTag(shake_config.shakeTag)
            shake_node.shaking = nil
            shake_node:setScale(org_scale)
            shake_node:setPosition(org_pos)
        end
    end
    effect_node:setFrameCallback(frameCallback)
end

-- 64位右移32位
function uq.bit64_rshift2(num)
    local div = math.pow(2, 32)
    local hight_32 = math.floor(num / div)  -- 高32位
    local low_32 = bit.band(num, 0x00000000ffffffff) -- 低32位
    local low_8 = bit.band(num, 0x00000000000000ff) -- 低8位
    return hight_32, low_32, low_8
end

function uq.bit64_rshift(num, arrNum)
    local div = math.pow(2, arrNum)
    local hightNum = math.floor(num / div)  -- 高arrNum位
    local lowNum = num % div -- 低arrNum位
    return hightNum, lowNum
end

-- 解析 func   错误码不为0时 不弹出错误码
function uq.ParseFromString(msg,data,func)
    msg:ParseFromString(data)
    uq.log("-------------> msg.ret",msg.ret)
    if msg.ret and msg.ret ~= 0 then
        if func then
            return msg
        end
        uq.log("---------proto msg ret:",msg.ret)
        local tip_index = "tip_" .. msg.ret
        local error_str = uq.Language.error_code[tip_index]
        if tonumber(msg.ret) == 217 then
            if msg.recruit_type then
                if msg.recruit_type == 1 or msg.recruit_type == 2 or msg.recruit_type == 5 or msg.recruit_type == 6 or msg.recruit_type == 7 then
                    uq.topUpCommonTip()
                else
                    local _state,_str = uq.static_data_manager.Module:isOpenFunctionByModuleId(48)
                    if not _state then
                        uq.TipLayer:createTipLayer(uq.Language.text[55]):show()
                    else
                        uq.ModuleManager:getInstance():show(uq.ModuleManager.BUY_GOLD)
                    end
                end
            else
                local _state,_str = uq.static_data_manager.Module:isOpenFunctionByModuleId(48)
                if not _state then
                    uq.TipLayer:createTipLayer(uq.Language.text[55]):show()
                else
                    uq.ModuleManager:getInstance():show(uq.ModuleManager.BUY_GOLD)
                end
            end
        elseif tonumber(msg.ret) == 201 then
            local function recharge()
                uq.functionOpenEvent(48, function ( sender )
                      uq.ModuleManager:getInstance():show(uq.ModuleManager.BUY_GOLD)
                  end )
            end
            uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE , {title = uq.Language.tips.buyGold , btn={{image = "d/d0020.png" , cb = recharge , close = true} , {image = "d/d0019.png" } } , content = uq.Language.text[458] })
        elseif tonumber(msg.ret) == 202 then
            uq.topUpCommonTip(uq.config.constant.COMMON_TIP_TYPE.DIAMOND)
        elseif tonumber(msg.ret) ~= 2201 then
            uq.TipLayer:createTipLayer(error_str):show()

        else
            uq.log("新手引导重复保存，但是不属于错误！" .. error_str .. "\n")
        end
        return false
    else
        return msg
    end
end

-- @param   moduleId: module配置里面的moduleId
-- @param   func:点击后要执行的方法
function uq.functionOpenEvent( moduleId, func )
    local moduleId = moduleId
    local _state,_str = uq.static_data_manager.Module:isOpenFunctionByModuleId( moduleId )
    if not _state then
        uq.TipLayer:createTipLayer(_str):show()
    else
        if func then
            func()
        end
    end
end

function uq.topUpCommonTip(tag)
    local languageCfg = uq.Language.tips
    local typeCfg = uq.config.constant.COMMON_TIP_TYPE

    local _title = languageCfg.buyGold
    local _cont = languageCfg.diamondLack
    if tag then
        if tonumber(tag) == typeCfg.GOLD then

        elseif tonumber(tag) == typeCfg.DIAMOND then
            _title = languageCfg.tip
            _cont = languageCfg.diamondLack
        elseif tonumber(tag) == typeCfg.VIP_LEVEL then
            _title = languageCfg.tip
            _cont = languageCfg.vipLvlLack
        else

        end
    end
    local function recharge()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.VIP_RECHARGE)
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE , {title = _title , btn={{image = "d/d0315.png" , cb = recharge , close = true} , {image = "d/d0019.png" } } , content = _cont})
end

function uq.getCurVersion()
    require("src/cocos/cocos2d/json")
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename("version.manifest")
    if io.open(fullPath, "r") then
        local file = io.open(fullPath, "r")
        local data = file:read("*a") -- 读取所有内容
        file:close()

        local versionTb = json.decode(data)
        uq.log("version tb : " , versionTb)

        return versionTb.version
    else
        return "v1.0.0"
    end
end

function uq.getCurCacheVersion(filepath)
    require("src/cocos/cocos2d/json")
    local file = io.open(filepath, "r");
    local data = file:read("*a"); -- 读取所有内容
    file:close();

    local versionTb = json.decode(data)
    uq.log("version tb : " , versionTb)

    return versionTb.version
end

function uq.compareVersion(ver1 , ver2)
    local bigVer1 , bigVer2
    local subVer1 , subVer2
    bigVer1 = string.split(ver1 , "-")[1]
    subVer1 = string.split(ver1 , "-")[2]

    bigVer2 = string.split(ver2 , "-")[1]
    subVer2 = string.split(ver2 , "-")[2]

    local bigVerFir1 , bigVerFir2
    bigVerFir1 = string.split(bigVer1 , ".")[1]
    bigVerFir2 = string.split(bigVer2 , ".")[1]

    uq.log("bigVerFir1 : " , bigVerFir1)
    uq.log("bigVerFir2 : " , bigVerFir2)
    uq.log("subVer1 : " , subVer1)
    uq.log("subVer2 : " , subVer2)
    if (tonumber(bigVerFir1) > tonumber(bigVerFir2)) or (tonumber(subVer1) > tonumber(subVer2)) then
        return true
    end

    return false
end

function uq.showOfficerSickPoint(build_id, cancle_back, confirm_back, confirm_type)
    confirm_type = confirm_type or uq.config.constant.CONFIRM_TYPE.NULL
    local info = StaticData['officer_build_map'][build_id]
    local build_xml = StaticData['buildings']['CastleMap'][info.castleMapId]
    local list_sick = uq.cache.role:getSickBuildOfficer(build_id)
    local names = ''
    for k, genersl_id in ipairs(list_sick) do
        local info = uq.cache.generals:getGeneralDataByID(genersl_id)
        names = names .. info.name
        if k < #list_sick then
            names = names .. ','
        end
    end
    local des = string.format(StaticData['local_text']['draft.general.des22'], build_xml.name, names)
    local data = {
        content = des,
        confirm_callback = cancle_back,
        cancle_callback = confirm_back,
        confirm_txt = StaticData['local_text']['draft.general.des21'],
    }
    uq.addConfirmBox(data, confirm_type)
end

function uq.createPanelOnly(name)
    if string.find(name, "app.") then
        return name
    end
    local path = "app.modules." .. name
    local m = require(path).new(name, {})
    return m
end

--获取富文本实际文本
function uq.getRichRealText(text)
    local text_start = 0
    local text_end = 0
    local real_text = ''

    for i=1, #text do
        if string.byte(text, i) == string.byte(">") then
            text_start = i + 1
        end

        if string.byte(text, i) == string.byte("<") then
            text_end = i - 1

            if text_start > 0 and text_start < text_end then
                real_text = real_text .. string.sub(text, text_start, text_end)
                text_start = 0
            end
        end
    end

    return real_text
end

--计算中文字符串长度，可能不准确
function uq.getTextLength(inputstr, font_width, font_space)
    font_width = font_width or 0
    font_space = font_space or 0
    -- 计算字符串宽度
    -- 可以计算出字符宽度，用于显示使用
    local len_byte = #inputstr
    local font_total_width = 0

    local i = 1
    while i <= len_byte do
        local cur_byte = string.byte(inputstr, i)
        local byte_count = 1
        local char_num = 1
        if cur_byte > 0 and cur_byte <= 127 then
            byte_count = 1
            char_num = 1
        elseif cur_byte >= 192 and cur_byte < 224 then
            byte_count = 2
            char_num = 2    --双字节字符
        elseif cur_byte >= 224 and cur_byte < 240 then
            byte_count = 3
            char_num = 2    --汉字
        elseif cur_byte >= 240 and cur_byte <= 247 then
            byte_count = 4
            char_num = 2    --4字节字符
        else
            byte_count = 3
            char_num = 2
        end
        font_total_width = font_total_width + font_width * char_num
        local char = string.sub(inputstr, i, i + byte_count - 1)
        i = i + byte_count                                 -- 重置下一字节的索引
    end
    return font_total_width
end

function uq.rewardToGrid(reward_items, space, templat, swallow_touch, flag)
    space = space or 3
    swallow_touch = swallow_touch or false

    local node_parent = cc.Node:create()
    local total_width = 0
    for k, item in ipairs(reward_items) do
        local panel = item:toWidget(templat)
        if panel.setCanSwallow then
            panel:setCanSwallow(swallow_touch)
        end
        if not templat and flag ~= nil then
            panel:setTouch(flag)
        end
        local size = panel:getContentSize()
        local x = (k - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        node_parent:addChild(panel)

        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    return node_parent, total_width
end
--名字輸入判斷
function uq.isLimiteName(str)
    local str = str or ""
    if str == "" then
        return true
    end
    local len = #str
    local skip = 0
    for i = 1, len do
        if i >= skip then
            local cur_byte = string.byte(str, i)
            local byte_count = 1
            if (cur_byte >= string.byte(0) and cur_byte <= string.byte(9)) or (cur_byte >= string.byte('a') and cur_byte <= string.byte('z')) or (cur_byte >= string.byte('A') and cur_byte <= string.byte('Z')) then
                byte_count = 1
            elseif cur_byte >= 224 and cur_byte < 240 then
                byte_count = 3
            else
                return true
            end
            skip = i + byte_count
        end
    end
    return false
end

function uq:addEffectByNode(node, effect_id, loop_num, async, pos, func, scale, rotate, reserve, zroder)
    local scale = scale or 1
    local repeated = (loop_num < 0)
    local effect = uq.createPanelOnly('common.EffectNode')
    if zroder then
        node:addChild(effect, zroder)
    else
        node:addChild(effect)
    end
    if pos then
        effect:setPosition(pos)
    else
        local size = node:getContentSize()
        effect:setPosition(size.width / 2, size.height / 2)
    end
    effect:setScale(scale)
    effect:playEffectNormal(effect_id, repeated, func, async, loop_num, reserve)
    node.effect = effect
    if rotate then
        effect:rotate(rotate)
    end
    return effect
end

function uq.jumpToInstanceChapter(chapter_id)
    if uq.cache.instance:isNpcPassed(chapter_id) then
        uq.jumpToModule(21, {chapter_id = chapter_id})
    elseif uq.cache.instance:isNpcPassed(math.floor(chapter_id / 100) * 100) then
        uq.jumpToModule(21, {instance_id = math.floor(chapter_id / 100)})
    else
        uq.fadeInfo(StaticData["local_text"]["instance.unlock"])
    end
end

function uq.showRoleLevelUp()
    if #uq.cache.role.level_up_array == 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
        return
    end
    local data = uq.cache.role.level_up_array[1]
    table.remove(uq.cache.role.level_up_array, 1)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ROLE_LEVEL_UP, {info = data})
end

function uq.getHeadRes(head_id, head_type)
    local path = "img/common/general_head/"
    if head_type == 0 then
        for k,v in pairs(StaticData['majesty_heads']) do
            return path .. v.icon
        end
    end
    local str_key = "miniIcon"
    local res_path = uq.dealHeadName(head_id, head_type, path, str_key)
    return res_path
end

function uq.dealHeadName(head_id, head_type, path, str_key)
    local res_path = ""
    local res = ''
    if head_type <= uq.config.constant.HEAD_TYPE.NORMAL then --初始武将
        head_id = StaticData['majesty_heads'][1].type
    elseif head_type == uq.config.constant.HEAD_TYPE.GENERAL then
        if not StaticData['general'][head_id] then
            head_id = StaticData['majesty_heads'][1].type
        end
    end

    local general_config = StaticData['general'][head_id]
    if general_config and next(general_config) ~= nil and general_config[str_key] then
        res_path = path .. general_config[str_key]
        res = general_config[str_key]
    end

    return res_path, general_config
end

function uq.delayAction(node, time, callback)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end

function uq.intoAction(node, off_pos, start_pos, end_pos, time, opacity)
    local pos_x, pos_y = node:getPosition()
    local pos = cc.p(pos_x, pos_y)
    local start_pos = start_pos or pos
    local end_pos = end_pos or pos
    if off_pos then
        start_pos = cc.p(pos_x + off_pos.x, pos_y + off_pos.y)
    end
    local time = time or 0.2
    local opacity = opacity or 50
    node:setPosition(start_pos)
    node:setOpacity(opacity)
    node:stopAllActions()
    node:runAction(cc.Spawn:create(
        cc.MoveTo:create(time, end_pos),
        cc.FadeIn:create(time)
        ))
end

function uq.getScreenScale()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local framesize = view:getFrameSize()
    local scaleX, scaleY = framesize.width / CC_DESIGN_RESOLUTION.width, framesize.height / CC_DESIGN_RESOLUTION.height

    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        return scaleX
    else
        return scaleY
    end
end

function uq.showNewGenerals(info, is_show)
    uq.cache.generals:addNewGenerals(info)
    if is_show then
        uq.refreshNextNewGeneralsShow()
    end
end

function uq.refreshNextNewGeneralsShow(end_call)
    if not uq.cache.generals:isNeetShowGenerals() then
        if end_call then
            end_call()
        end
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_UNLOCKED_VIEW)
    if panel then
        return
    end
    local info = uq.cache.generals:getFristGeneralsAddRemove()
    if info.id ~= 0 then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_UNLOCKED_VIEW, {info = info, zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 10})
        panel:setEndCallBack(end_call)
    end
end

function uq.alphaTouchCheck(img, pt)
    local size = img:getContentSize()
    local ret = uq.Utils:getNodePixelColor(img, pt.x, size.height - pt.y + 1)
    local div = 16777216 --math.pow(2, 24)
    local alpha = math.ceil(ret / div)
    return alpha > 0
end

function uq.getWeekByTimeStamp(time_stamp, is_regression)
    local t = time_stamp or os.time()
    if is_regression then
        t = t - 4 * 3600
    end
    return os.date("*t", t).wday - 1
end

function uq.http_request(method, url, call_back)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(method, url)
    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            if call_back then
                call_back(xhr)
            end
        else
            uq.log("ERROR:  response",xhr.response)
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChanged)
    xhr:send()
end

function uq.getAdaptOffX()
    local safe_area = cc.Director:getInstance():getSafeAreaRect()
    if safe_area.x > 0 then
        return safe_area.x
    end
    return 0
end

require('app.utils.BattleReport')
require('app.utils.keyword')
require('app.utils.TimerProxy')
require('app.utils.Formula')
require('app.utils.sound')
require('app.utils.RewardType')
require('app.utils.BattleRule')
require('app.utils.VideoPlayer')
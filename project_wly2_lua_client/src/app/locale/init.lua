uq.formatResource = function(val)
    return val
end

if uq.config.LANG == 'zh_cn' then
    uq.formatResource = function(val, up_state)
        local integer = val
        local remainder = 0
        local des = ''
        if val >= 100000000 then
            integer,remainder = math.modf(val / 100000000)
            des = StaticData['local_text']['res.unit.yi']
        elseif val >= 10000 then
            integer, remainder = math.modf(val / 10000)
            des = StaticData['local_text']['res.unit.wan']
        else
            return val
        end
        if up_state then
            remainder = math.ceil(remainder * 10)
        else
            remainder = math.floor(remainder * 10)
        end
        return integer + remainder * 0.1 .. des
    end
end


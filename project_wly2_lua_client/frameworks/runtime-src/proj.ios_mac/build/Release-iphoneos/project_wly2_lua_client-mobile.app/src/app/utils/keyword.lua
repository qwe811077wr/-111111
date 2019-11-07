local uq = cc.exports.uq or {}
local _keyword = StaticData['keyword'] or {}

local _wordIndex = {}

for k, word in ipairs(_keyword) do
    local len = string.utfLen(word)
    local start = _wordIndex
    for i = 1, len, 1 do
        local char = string.lower(string.subUtf(word, i, 1))
        if not start[char] then
            start[char] = {}
        end
        start = start[char]
    end
    start[1] = true
end

function uq.filterWord( str )
    if not str or #str == 0 then
        return str
    end
    local len = string.utfLen(str)
    local i = 1
    local ret = ''
    local startIdx = 1
    while i <= len do
        local char = string.lower(string.subUtf(str, i, 1))
        local idx = _wordIndex[char]
        local j = i
        while idx do
            if idx[1] then
                ret = ret .. string.subUtf(str, startIdx, i - startIdx) .. '*'
                i = j
                startIdx = j + 1
                break
            end
            j = j + 1
            char = string.lower(string.subUtf(str, j, 1))
            idx = idx[char]
        end
        i = i + 1
    end
    ret = ret .. string.subUtf(str, startIdx, len - startIdx + 1)
    return ret
end

function uq.hasKeyWord( str )
    if not str or #str == 0 then
        return false
    end
    local len = string.utfLen(str)
    local i = 1
    local startIdx = 1
    while i <= len do
        local char = string.subUtf(str, i, 1)
        local idx = _wordIndex[char]
        local j = i
        while idx do
            if idx[1] then
                return true
            end
            j = j + 1
            char = string.subUtf(str, j, 1)
            idx = idx[char]
        end
        i = i + 1
    end
    return false
end

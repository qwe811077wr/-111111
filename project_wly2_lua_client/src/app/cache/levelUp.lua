local LevelUp = class("LevelUp")

function LevelUp:ctor()
    self._funcIndex = 1
    self._funcData = {}
    self._isExist = false
    self._isShowOpen = true
end

function LevelUp:isFunctionOver()
    if self._funcIndex > #self._funcData then
        self._isExist = false
        return false
    end

    if not self._isExist then
        return false
    end

    return true
end

function LevelUp:getFuncData()
    return self._funcData
end

function LevelUp:getFuncIndex()
    return self._funcIndex
end

function LevelUp:addIndex()
    self._funcIndex = self._funcIndex + 1
end

function LevelUp:setFuncData(data)
    self._funcData = data
    self._funcIndex = 1
    self._isExist = true
end

function LevelUp:setFlag(flag)
    self._isExist = flag
end

function LevelUp:setShowOpen(flag)
    self._isShowOpen = flag
end

return LevelUp
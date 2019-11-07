local uq = cc.exports.uq or {}

local sound = {
    format = ".ogg",
    lastMusic = nil,
    music_value = 0,
    sound_value = 0
}
--[[
if CC_TARGET_PLATFORM==cc.PLATFORM_OS_WIN32 or CC_TARGET_PLATFORM==0 then
    sound.format = ".mp3"
end
]]--

---------------------------Sound基础函数---------------------------------
function uq.playBackGroundMusic(file_name, is_loop)
    if not file_name or file_name == "" or sound.music_value == 0 then
        return
    end
    sound.lastMusic = file_name
    audio.playMusic(file_name .. sound.format, is_loop)
    uq.log("uq.playBackGroundMusic end file_name : " , file_name)
end

function uq.stopBackGroundMusic()
    uq.log("uq.stopBackGroundMusic fileName : " , sound.lastMusic)
    audio.stopMusic()
end

function uq.pauseBackGroundMusic()
    uq.log("uq.pauseBackGroundMusic fileName : " , sound.lastMusic)
    audio.pauseMusic()
end

function uq.resumeBackGroundMusic()
    uq.log("audio.isMusicPlaying",audio.isMusicPlaying())
    audio.resumeMusic()
    if not audio.isMusicPlaying() then
        local index = math.random(1,2)
        local sound_name = "mainCity" .. index
        uq.playBackGroundMusic(sound_name, true)
    end
end

function uq.playSound(file_name, is_loop)
    if sound.sound_value == 0 then
        return
    end
    local path = file_name .. sound.format
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return nil
    end
    return audio.playSound(path, is_loop)
end

function uq.playSoundByID(sound_id)
    local sound_id = tonumber(sound_id)
    local sound_data = StaticData['sound'][sound_id]
    if sound_data then
        if sound_data.type == 1 then
            uq.playSound('sound/' .. sound_data.sound, false)
        elseif sound_data.type == 0 then
            uq.playBackGroundMusic('sound/' .. sound_data.sound, true)
        end
    end
end

function uq.stopSound(audio_id)
    audio.stopSound(audio_id)
end

function uq.pauseSound(audio_id)
    audio.pauseSound(audio_id)
end

function uq.resumeSound(audio_id)
    audio.resumeSound(audio_id)
end

function uq.getMusicVolume()
    return audio.getMusicVolume()
end

function uq.setMusicVolume(volume)
    audio.setMusicVolume(volume)
    sound.music_value = volume
end

function uq.getSoundsVolume()
    return audio.getSoundsVolume()
end

function uq.setSoundsVolume(volume)
    audio.setSoundsVolume(volume)
    sound.sound_value = volume
end

function uq.getLastMusic()
    return sound.lastMusic or ""
end
---------------------------Sound基础函数结束---------------------------------

---------------------------Sound游戏应用函数---------------------------------
function uq.playBackGroundMusicByModule(modId, formType)
    local soundName = nil
    local isLoop = true
    if modId == uq.ModuleManager.MAIN_MODULE then
        local index = math.random(1,2)
        soundName = "mainCity"..index
    elseif modId == uq.ModuleManager.MISSION_MODULE then
        local index = math.random(1,2)
        soundName = "battle"..index
    elseif modId == uq.ModuleManager.BATTLE_MODULE then
        if not formType then
            local index = math.random(1,2)
            soundName = "battle"..index
        elseif formType == uq.config.constant.FORMATION_TYPE.PVE or
            formType == uq.config.constant.FORMATION_TYPE.PVE_ACTIVITY or
            formType == uq.config.constant.FORMATION_TYPE.PVE_ACTIVITY_OTHERS or
            formType == uq.config.constant.FORMATION_TYPE.PVP_CHAMPION_RACE then
            local index = math.random(1,2)
            soundName = "battle"..index
        elseif formType == uq.config.constant.FORMATION_TYPE.PVE_TOWER then
            soundName = "tower"
        elseif formType == uq.config.constant.FORMATION_TYPE.PVP_ARENA then
            soundName = "jjc"
        elseif formType == uq.config.constant.FORMATION_TYPE.PVP_CROP_WAR then
            soundName = "boss"
        end
    elseif modId == uq.ModuleManager.BATTLE_WIN_MODULE then
        soundName = "battle_success"
        isLoop = false
    elseif modId == uq.ModuleManager.BATTLE_FAIL_MODULE or modId == uq.ModuleManager.CLONE_WAR_FAILED_MODULE then
        soundName = "battle_fail"
        isLoop = false
    elseif modId == "battle_cheer" then
        soundName = "battle_cheer"
        isLoop = false
    elseif modId == uq.ModuleManager.SDK_LOGIN_MODULE or modId == uq.ModuleManager.LOGIN_MODULE then
        soundName = "login_sounds"
    end

    if soundName then
        uq.playBackGroundMusic(soundName, isLoop)
    end
end

function uq.playHeroVoiceSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    uq.playSound("voice_sounds/" .. soundName, false)
end

function uq.playHeroActionSound(modelKey, action)
    if not modelKey or not action or string.len(modelKey) <= 0 or string.len(action) <= 0 then
        return
    end
    return uq.playSound("hero_action_sounds/" .. string.sub(modelKey, 1, 7) .. action, false)
end

function uq.playBattleSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    uq.playSound("battle_sounds/" .. soundName, false)
end

function uq.playUiSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    uq.playSound("UI_sounds/" .. soundName, false)
end

function uq.preloadHeroVoiceSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    local path = "voice_sounds/" .. soundName .. sound.format
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return
    end
    audio.preloadSound(path)
end

function uq.preloadHeroActionSound(modelKey, action)
    if not modelKey or not action or string.len(modelKey) <= 0 or string.len(action) <= 0 then
        return
    end
    local path = "hero_action_sounds/" .. string.sub(modelKey, 1, 7) .. action .. sound.format
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return
    end
    audio.preloadSound(path)
end

function uq.preloadBattleSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    local path = "battle_sounds/" .. soundName .. sound.format
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return
    end
    audio.preloadSound(path)
end

function uq.preloadUiSound(soundName)
    if not soundName or string.len(soundName) <= 0 then
        return
    end
    local path = "UI_sounds/" .. soundName .. sound.format
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return
    end
    audio.preloadSound(path)
end

--弃用，但是代码内多处添加 未注释掉
function uq.playUiSoundByType(uiSoundType)
    do
        return
    end

    local strSoundName = ""
    if uiSoundType == 1 then
        strSoundName = "common_click1"
    elseif uiSoundType == 2 then
        strSoundName = "common_click2"
    elseif uiSoundType == 3 then
        strSoundName = "common_close"
    end

    uq.playUiSound(strSoundName)
end

--iconsprite imageview button等控件 1：按钮控件 2：按钮控件（特指X关闭）
function uq.PlayUiSoundBtnClickByType(uiSoundType)
    if uiSoundType == nil then
        uiSoundType = 1
    end

    local strSoundName = ""
    if uiSoundType == 1 then
        strSoundName = "common_click1"
    elseif uiSoundType == 2 then
        strSoundName = "common_click2"
    elseif uiSoundType == 3 then
        strSoundName = "common_close"
    end

    uq.playUiSound(strSoundName)
end

function uq.PlayUiSoundTabClick()
    uq.playUiSound("common_click2")
end
---------------------------Sound游戏应用函数结束---------------------------------
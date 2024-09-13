local Legacy = exports.LEGACYCORE:GetCoreData()

local Core   = {}

function Core:GetPlayerData(src)
    local LegacyPlayer = Legacy.DATA:GetPlayerDataBySlot(src)
    if not LegacyPlayer then return end
    return LegacyPlayer
end

function Core:GetPlayerName(src)
    local LegacyPlayer = Core:GetPlayerData(src)
    local playerName = LegacyPlayer?.playerName
    return playerName
end

function Core:GetPlayerGroup(src)
    local PlayerGroup = Legacy.DATA:GetPlayerGroup(src)
    if PlayerGroup then
        return PlayerGroup
    end
end

function Core:GetPlayerJob(src)
    local PlayerData = Core:GetPlayerData(src)
    local Job = PlayerData?.JobName
    if Job then
        return Job
    end
end

return Core

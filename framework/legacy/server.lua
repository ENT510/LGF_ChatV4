local Legacy = exports.LEGACYCORE:GetCoreData()

local BRIDGE   = {}

function BRIDGE:GetPlayerData(src)
    local LegacyPlayer = Legacy.DATA:GetPlayerDataBySlot(src)
    if not LegacyPlayer then return end
    return LegacyPlayer
end

function BRIDGE:GetPlayerName(src)
    local LegacyPlayer = BRIDGE:GetPlayerData(src)
    local playerName = LegacyPlayer?.playerName
    return playerName
end

function BRIDGE:GetPlayerGroup(src)
    local PlayerGroup = Legacy.DATA:GetPlayerGroup(src)
    if PlayerGroup then
        return PlayerGroup
    end
end

function BRIDGE:GetPlayerJob(src)
    local PlayerData = BRIDGE:GetPlayerData(src)
    local Job = PlayerData?.JobName
    if Job then
        return Job
    end
end

return BRIDGE

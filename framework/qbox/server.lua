local Qbox = exports['qb-core']:GetCoreObject()

local Core = {}

function Core:GetPlayerData(src)
    local PlayerData = exports.qbx_core:GetPlayer(src).PlayerData
    if PlayerData then
        return PlayerData
    else
        Utils.DebugPrint(('No player data found for the provided source %s.'):format(src))
    end
end

function Core:GetPlayerIdentifier(src)
    local PlayerData = Core:GetPlayerData(src)
    return PlayerData.license
end

function Core:GetPlayerGroup(src)
    if IsPlayerAceAllowed(src, 'admin') then
        return 'admin'
    end
end

return Core

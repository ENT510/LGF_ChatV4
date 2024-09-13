local Qbox = exports['qb-core']:GetCoreObject()

local BRIDGE = {}

function BRIDGE:GetPlayerData(src)
    local PlayerData = exports.qbx_core:GetPlayer(src).PlayerData
    if PlayerData then
        return PlayerData
    else
        Utils.DebugPrint(('No player data found for the provided source %s.'):format(src))
    end
end

function BRIDGE:GetPlayerName(src)
    local qboxPlayer = BRIDGE:GetPlayerData(src)
    if not qboxPlayer then return end
    return string.format("%s %s", qboxPlayer.charinfo.firstname, qboxPlayer.charinfo.lastname)
end

function BRIDGE:GetPlayerJob(src)
    local qboxPlayer = BRIDGE:GetPlayerData(src)
    local Job = qboxPlayer.job.label
    if not Job then return end
    return Job
end

function BRIDGE:GetPlayerGroup(src)
    if IsPlayerAceAllowed(src, 'admin') then
        return 'admin'
    elseif IsPlayerAceAllowed(src, 'god') then
        return 'god'
    elseif IsPlayerAceAllowed(src, 'mod') then
        return 'mod'
    end
end

return BRIDGE

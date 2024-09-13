local ESX <const> = exports.es_extended:getSharedObject()
local BRIDGE = {}


function Core:GetPlayerData(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        return xPlayer
    else
        Utils.DebugPrint(('No player data found for the provided source %s.'):format(src))
    end
end

function Core:GetPlayerGroup(src)
    local xPlayer = Core:GetPlayerData(src)
    if xPlayer then
        return xPlayer.getGroup()
    end
end

function BRIDGE:GetPlayerName(src)
    local xPlayer = BRIDGE:GetPlayerData(src)
    local playerName = string.format("%s %s", xPlayer.get("firstName"), xPlayer.get("lastName"))
    if not playerName then return end
    return playerName
end

function BRIDGE:GetPlayerJob(src)
    local xPlayer = BRIDGE:GetPlayerData(src)
    local Job = xPlayer?.job?.name
    if not Job then return end
    return Job
end

return BRIDGE

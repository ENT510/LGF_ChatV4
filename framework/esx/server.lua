local ESX <const> = exports.es_extended:getSharedObject()
local Core = {}


function Core:GetPlayerData(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        return xPlayer
    else
        SHARED.GETDEBUG(('No player data found for the provided source %s.'):format(src))
    end
end

function Core:GetPlayerIdentifier(src)
    local xPlayer = Core:GetPlayerData(src)
    if xPlayer then
        return xPlayer.identifier
    end
end

function Core:GetPlayerGroup(src)
    local xPlayer = Core:GetPlayerData(src)
    if xPlayer then
        return xPlayer.getGroup()
    end
end


return Core

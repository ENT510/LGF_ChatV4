local ESX <const> = exports.es_extended:getSharedObject()


local Core = {}

function Core:GetPlayerData()
    return ESX.GetPlayerData() or {}
end

function Core:GetPlayerName()
    local playerData = self:GetPlayerData()
    local firstName = playerData.firstName or ""
    local lastName = playerData.lastName or ""
    return string.format("%s %s", firstName, lastName)
end

print('ESX')


return Core

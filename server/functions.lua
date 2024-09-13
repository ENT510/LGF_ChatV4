Functions                       = {}
local BOT_TOKEN                 = ('Bot %s'):format("token")
local GetPlayerName             = GetPlayerName
local tonumber                  = tonumber
local GetPlayerIdentifierByType = GetPlayerIdentifierByType
local PerformHttpRequest        = PerformHttpRequest
local avatar                    = {}

function Functions.RequestAvatar(target)
    local discordId = GetPlayerIdentifierByType(target, "discord")

    if not discordId then return print("ERROR: Discord id not found") end

    local formattedId = string.gsub(discordId, "discord:", "")

    if avatar[discordId] then return avatar[discordId] end

    local image = promise.new()

    local api = ('https://discord.com/api/v10/users/%s'):format(formattedId)

    PerformHttpRequest(api, function(code, response)
        if code ~= 200 then return end

        local responseData = json.decode(response)
        avatar[discordId] = ('https://cdn.discordapp.com/avatars/%s/%s.png'):format(responseData.id, responseData.avatar)
        image:resolve(avatar[discordId])
    end, 'GET', nil, {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = BOT_TOKEN
    })

    return Citizen.Await(image)
end

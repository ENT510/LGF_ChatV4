Functions = {}


local BOT_TOKEN = ('Bot %s'):format(GetConvar('LGF_Chat:bot_token', ''))

local GetPlayerIdentifierByType = GetPlayerIdentifierByType
local PerformHttpRequest = PerformHttpRequest
local avatar = {}


function Functions.RequestAvatar(target)
    local discordId = GetPlayerIdentifierByType(target, "discord")
    if not discordId then return print("ERROR: Discord ID not found") end

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

function Functions.SendMessageToAllowedGroups(data, source)
    local author = data.author
    local message = data.message

    if not author or not message then return end

    local allowedToSend = false
    local players = GetPlayers()

    for i = 1, #players do
        local playerId = players[i]
        local playerGroup = BRIDGE:GetPlayerGroup(tonumber(playerId))
        if CFG.GroupAllowed[playerGroup] then
            allowedToSend = true
            lib.TriggerClientEvent('chatMessage', playerId, BRIDGE:GetPlayerName(source), message, source, BRIDGE:GetPlayerGroup(source), false)
        end
    end

    if not allowedToSend then
        lib.TriggerClientEvent('chatMessage', source, "System", "No authorized to send Admin Message.", source, "system",  true)
    end
end

function Functions.containsBadWord(message)
    for _, badWord in ipairs(CFG.BlackListedWords) do
        if string.find(message:lower(), badWord:lower()) then
            return true
        end
    end
    return false
end

function Functions.mutePlayer(targetPlayerId, duration)
    if not targetPlayerId or duration <= 0 then
        return false
    end

    if not BRIDGE:GetPlayerName(targetPlayerId) then
        return false
    end

    mutedPlayers[targetPlayerId] = os.time() + duration
    return true
end

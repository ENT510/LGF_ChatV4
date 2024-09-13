local GetFolder = require('framework.GetFramework'):new()
Core = GetFolder:getFrameworkObject(true)


RegisterServerEvent("_chat:messageEntered")
AddEventHandler("_chat:messageEntered", function(message, playerJob)
    local source = source
    local author = GetPlayerName(source)

    if not message or not author then return end
    local isSystemMessage = (playerJob == "system")

    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        lib.TriggerClientEvent('chatMessage', -1, Core:GetPlayerName(source), message, source,
            Core:GetPlayerGroup(source), isSystemMessage)
    end
end)


lib.callback.register("LGF_Chat_V4.Avatar.GetPlayerImage", function(target)
    if not target then return end
    return Functions.RequestAvatar(target)
end)



local function SendMessageToAllowedGroups(data, source)
    local author = data.author
    local message = data.message

    if not author or not message then
        print("Error: Missing author or message")
        return
    end

    local allowedToSend = false
    local players = GetPlayers()
    local numPlayers = #players

    for i = 1, numPlayers do
        local playerId = players[i]
        local playerGroup = Core:GetPlayerGroup(tonumber(playerId))


        if CFG.GroupAllowed[playerGroup] then
            allowedToSend = true
            lib.TriggerClientEvent('chatMessage', playerId, Core:GetPlayerName(source), message, source,
                Core:GetPlayerGroup(source), false)
        end
    end

    if not allowedToSend then
        lib.TriggerClientEvent('chatMessage', source, "System", "No authorized to send Admin Message.", source, "system",
            true)
    end
end


RegisterCommand(CFG.Command.Admin, function(source, args, rawCommand)
    local playerId = source
    local playerName = Core:GetPlayerName(playerId)
    local description = table.concat(args, " ")

    if args and #args > 0 then
        local messageData = { author = playerName, message = description, isSystemMessage = true }
        SendMessageToAllowedGroups(messageData, playerId)
    else
        lib.TriggerClientEvent('chatMessage', source, "Error", "Usage: /sendToAllowedGroups [message]")
    end
end, false)

local function SendAdvertisementMessage(data, source)
    local author = data.author
    local message = data.message
    local job = Core:GetPlayerJob(source)
    if job == "unemployed" then return end

    if not author or not message then
        print("Error: Missing author or message")
        return
    end

    lib.TriggerClientEvent('chatMessage', -1, "Advertise", message, source, Core:GetPlayerJob(source), false)
end

RegisterCommand("ad", function(source, args, rawCommand)
    local playerId = source
    local playerName = Core:GetPlayerName(playerId)
    local description = table.concat(args, " ")

    if #args < 1 then
        lib.TriggerClientEvent('chatMessage', source, "Error", "Usage: /advertisement [message]")
        return
    end

    local messageData = { author = playerName, message = description }
    SendAdvertisementMessage(messageData, playerId)
end, false)

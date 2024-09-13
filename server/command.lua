lib.addCommand(CFG.Command.Admin, { 
    help = 'Send a message to allowed admin groups',
    params = {
        {
            name = 'message',
            type = 'longString',
            help = 'The message to send',
        },
    },
}, function(source, args, rawCommand)
    local playerId = source
    local playerName = BRIDGE:GetPlayerName(playerId)
    local message = args.message

    if message then
        local messageData = { author = playerName, message = message, isSystemMessage = false }
        Functions.SendMessageToAllowedGroups(messageData, playerId)
    else
        lib.TriggerClientEvent('chatMessage', source, "Error", "Usage: /adm [message]")
    end
end)



lib.addCommand(CFG.Command.MutePlayer, {
    help = 'Mute a player for a specified duration',
    params = {
        {
            name = 'playerId',
            type = 'playerId',
            help = 'ID of the player to mute',
        },
        {
            name = 'duration',
            type = 'number',
            help = 'Duration of mute in seconds (default is 60)',
            optional = true
        },
    },
}, function(source, args, rawCommand)
    local playerId = source
    local playerGroup = BRIDGE:GetPlayerGroup(playerId)
    local targetPlayerId = tonumber(args.playerId)
    local muteDuration = tonumber(args.duration) or 60

    if CFG.GroupAllowed[playerGroup] then
        if targetPlayerId and muteDuration then
            if Functions.mutePlayer(targetPlayerId, muteDuration) then
                lib.TriggerClientEvent('chatMessage', -1, "System",
                    ("Player %s has been muted for %d seconds."):format(BRIDGE:GetPlayerName(targetPlayerId),
                        muteDuration), playerId, "system", true)
            else
                lib.TriggerClientEvent('chatMessage', playerId, "System",
                    "Failed to mute player. Please check the player ID and duration.", playerId, "system", true)
            end
        else
            lib.TriggerClientEvent('chatMessage', playerId, "System", "Usage: /muteplayer [playerId] [duration]",
                playerId, "system", true)
        end
    else
        lib.TriggerClientEvent('chatMessage', playerId, "System", "You do not have permission to use this command.",
            playerId, "system", true)
    end
end)

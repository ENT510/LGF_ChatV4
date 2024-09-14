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
        TriggerClientEvent('chatMessage', source, "Error", "Usage: /adm [message]")
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
                TriggerClientEvent('chatMessage', -1, "System",  ("Player %s has been muted for %d seconds."):format(BRIDGE:GetPlayerName(targetPlayerId),   muteDuration), playerId, "system", true)
            else
                TriggerClientEvent('chatMessage', playerId, "System",  "Failed to mute player. Please check the player ID and duration.", playerId, "system", true)
            end
        else
            TriggerClientEvent('chatMessage', playerId, "System", "Usage: /muteplayer [playerId] [duration]", playerId, "system", true)
        end
    else
        TriggerClientEvent('chatMessage', playerId, "System", "You do not have permission to use this command.", playerId, "system", true)
    end
end)

for jobName, jobInfo in pairs(CFG.JobChat) do
    lib.addCommand(jobInfo.command, {
        help = ('Send a message to the %s group'):format(jobName),
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

        local playerJob = BRIDGE:GetPlayerJob(playerId)
        if playerJob ~= jobName then
            TriggerClientEvent('chatMessage', playerId, "System", "You are not authorized to use this command.", source,
                "system", true)
            return
        end

        if jobInfo.private then
            local players = GetPlayers()
            for i = 1, #players do
                local targetPlayerId = players[i]
                local targetJob = BRIDGE:GetPlayerJob(targetPlayerId)
                if targetJob == jobName then
                    TriggerClientEvent('chatMessage', targetPlayerId, jobInfo.label, ("[%s]: %s"):format(playerName, message), source, nil, false)
                end
            end
        else
            TriggerClientEvent('chatMessage', -1, jobInfo.label, ("[%s]: %s"):format(playerName, message), source, nil, false)
        end
    end)
end

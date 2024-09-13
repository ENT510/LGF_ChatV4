local GetFolder = require('framework.GetFramework'):new()
BRIDGE = GetFolder:getFrameworkObject(true)


local spamProtection = {
    enableAntiSpam = true,  -- Enable Or Disable anti Spam Protection
    timeFrame = 6,          -- Time window (in seconds) to check for spam
    maxMessages = 3,        -- Maximum number of messages allowed within the time window
    warningsBeforeMute = 2, -- Number of warnings before muting player
    muteTime = 60           -- Time (in seconds) to mute the player
}

playerMessageLogs = {}
mutedPlayers = {}

RegisterServerEvent("_chat:messageEntered")
AddEventHandler("_chat:messageEntered", function(message, playerJob)
    local source = source
    local author

    if CFG.NameUsed == "steam" then
        author = GetPlayerName(source)
    elseif CFG.NameUsed == "char" then
        author = BRIDGE:GetPlayerName(source)
    end

    if not message or not author then return end
    local isSystemMessage = (playerJob == "system")
    
    if spamProtection.enableAntiSpam then
        if mutedPlayers[source] and mutedPlayers[source] > os.time() then
            local remainingTime = mutedPlayers[source] - os.time()
            lib.TriggerClientEvent('chatMessage', source, "System",  ("You are muted. Wait %d seconds."):format(remainingTime), source, "system", true)
            CancelEvent()
            return
        elseif mutedPlayers[source] and mutedPlayers[source] <= os.time() then
            mutedPlayers[source] = nil
        end

        if not playerMessageLogs[source] then
            playerMessageLogs[source] = { messages = {}, warnings = 0 }
        end

        local currentTime = os.time()
        table.insert(playerMessageLogs[source].messages, currentTime)

        for i = #playerMessageLogs[source].messages, 1, -1 do
            if playerMessageLogs[source].messages[i] < currentTime - spamProtection.timeFrame then
                table.remove(playerMessageLogs[source].messages, i)
            end
        end

        if #playerMessageLogs[source].messages > spamProtection.maxMessages then
            playerMessageLogs[source].warnings = playerMessageLogs[source].warnings + 1

            if playerMessageLogs[source].warnings >= spamProtection.warningsBeforeMute then
                mutedPlayers[source] = currentTime + spamProtection.muteTime
                lib.TriggerClientEvent('chatMessage', source, "System", ("You have been muted for spamming. Wait %d seconds."):format(spamProtection.muteTime), source, "system", true)
                lib.TriggerClientEvent('chatMessage', -1, "System", ("Player %s has been muted for spamming. They will be muted for %d seconds."):format(author, spamProtection.muteTime), source, "system", true)
            else
                lib.TriggerClientEvent('chatMessage', source, "System", ("Stop spamming! You will be muted after %d more warnings."):format(spamProtection .warningsBeforeMute - playerMessageLogs[source].warnings), source, "system", true)
            end

            CancelEvent()
            return
        end
    end


    if Functions.containsBadWord(message) then
        lib.TriggerClientEvent('chatMessage', source, "System", "Your message contains inappropriate words and has been blocked.", source, "system", true)
        CancelEvent()
        return
    end

    if not WasEventCanceled() then
        lib.TriggerClientEvent('chatMessage', -1, author, message, source, BRIDGE:GetPlayerGroup(source), isSystemMessage)
    end
end)

lib.callback.register("LGF_Chat_V4.Avatar.GetPlayerImage", function(target)
    if not target then return end
    return Functions.RequestAvatar(target)
end)


RegisterNetEvent("LGF_Chat_V4:ClearChatMessage", function()
    local source = source
    if not source then return end
    lib.TriggerClientEvent('chatMessage', source, "System", "Chat Cleared Correctly", source, "system", true)
end)


lib.versionCheck('ENT510/LGF_ChatV4') 

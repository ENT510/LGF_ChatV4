CreateThread(function()
  DisableMultiplayerChat(false)
  SetTextChatEnabled(false)
end)

LocalPlayer.state.ChatIsOpen = false
Encode = json.encode
Decode = json.decode

function ShowChat(action, shouldShow, id)
  SetNuiFocus(shouldShow, shouldShow)
  SendNUIMessage({ action = action, data = { visible = shouldShow, id = id } })
  if action == 'openChat' then LocalPlayer.state.ChatIsOpen = shouldShow end
end

RegisterNUICallback('sendMessage', function(data, cb)
  local message = data.message
  if message:sub(1, 1) == "/" then return ExecuteCommand(data.message:sub(2)) end
  TriggerServerEvent("_chat:messageEntered", message, nil)
    cb(true)
end)



RegisterNetEvent("chatMessage", function(author, message, source, playerJob, isSystemMessage)
  local MyAvatar = lib.callback.await("LGF_Chat_V4.Avatar.GetPlayerImage", 100)
  if isSystemMessage then author = "System" end
  SendNUIMessage({
    action = 'addSendMessage',
    data = {
      message = message,
      author = author,
      playerJob = playerJob,
      id = source,
      avatar = MyAvatar,
      isSystemMessage = isSystemMessage
    }
  })
  SetTimeout(700, function()
    ShowChat("openChat", false, nil)
  end)
end)

RegisterNUICallback("LGF_Chat_V4.GetConfig", function(data, callback)
  callback({ EnableGroupMessage = CFG.EnableGroupMessage })
end)


RegisterNuiCallback('LGF_Chat_V4:CloseChat', function(data, callback)
  SetNuiFocus(false, false)
  if data.name == 'openChat' then
    LocalPlayer.state.ChatIsOpen = false
    callback(true)
  end
  ShowChat(data.name, false, nil)
end)




RegisterNUICallback('sendSystemMessage', function(data, callback)
  Utils.DebugPrint(Encode(data, { indent = true }))
  local message = data.message
  SendNUIMessage({
    action = 'addSendMessage',
    data = {
      message = message,
      author = "system",
      playerJob = nil,
      id = source,
      avatar = nil,
      isSystemMessage = true
    }
  })
  callback({ status = 'success' })
end)


RegisterNetEvent("__cfx_internal:serverPrint")
AddEventHandler("__cfx_internal:serverPrint", function(msg)
  if not CFG.EnablePrintSystem then return end
  if msg and msg ~= "" and msg:sub(1, 1) ~= "/" then
    SendNUIMessage({ action = 'addSendMessage', data = { message = msg, author = "System", isSystemMessage = true } })
  end
end)

CreateBind = function()
  local GetBind = GetConvar("LGF_Chat:ToggleChat", "Z")
  lib.addKeybind({
    name = 'open_new_chat+1',
    description = 'Press Z to toggle chat visibility',
    defaultKey = GetBind,
    onPressed = function(self)
      local SHOWCHAT = not GetChatState()
      ShowChat('openChat', SHOWCHAT, cache.serverId)
    end,
  })
end


local suggs = {}

function GenerateSuggestions()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()
    for _, command in ipairs(registeredCommands) do
      if IsAceAllowed(("command.%s"):format(command.name)) and not suggs["/" .. command.name] then
        local suggestion = { name = "/" .. command.name, help = command.help or "" }
        suggs["/" .. command.name] = true
        SendNUIMessage({ action = "addSuggestion", suggestion = suggestion })
        TriggerEvent("chat:addSuggestions", suggestion)
      end
    end
  end
end

RegisterNetEvent("chat:addSuggestions")
AddEventHandler("chat:addSuggestions", function(suggestions)
  for k, v in pairs(suggestions) do
    SendNUIMessage({ action = "addSuggestion", suggestion = v })
  end
end)

AddEventHandler("playerSpawned", function(spawn)
  GenerateSuggestions()
end)

AddEventHandler("onClientResourceStart", function(resName)
  Wait(500)
  GenerateSuggestions()
end)

AddEventHandler("onClientResourceStop", function(resName)
  Wait(500)
  GenerateSuggestions()
end)


CreateThread(CreateBind)

function GetChatState() return LocalPlayer.state.ChatIsOpen end

-- Removed Inusual Variable for Job
-- Added Job Message (Private or not)
-- Substitute Lib.trigger whit TriggerClientEvent
-- Removed Server Side Trigger for ClearChat
-- Added Suggestions Chat
-- Removed Slide Animations and added Simple Fade in Fade out
-- Added arrow up for retrieve last command/message
-- Diminished Delay after close Chat

local isUIOpen = false
local MSG = {}
Encode = json.encode
Decode = json.decode

function ShowNui(action, shouldShow, id)
  SetNuiFocus(shouldShow, shouldShow)
  SendNUIMessage({ action = action, data = { visible = shouldShow, id = id } })
  if action == 'openChat' then
    isUIOpen = true
  end
end

function SendNUI(action, data)
  SendNUIMessage({ action = action, data = data })
end

RegisterNUICallback('sendMessage', function(data, cb)
  local message = data.message
  if message:sub(1, 1) == "/" then
    cb({ status = 'success' })
    return ExecuteCommand(data.message:sub(2))
  end

  TriggerServerEvent("_chat:messageEntered", message, "police")
  cb({ status = 'success' })
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
end)

RegisterNUICallback("LGF_Chat_V4.GetConfig", function(data, callback)
  callback({
    EnableGroupMessage = CFG.EnableGroupMessage
  })
end)

RegisterNUICallback("LGF_Chat_V4.GetPlayerGroup", function(data, callback)
  local playerGroup = "admin"
  local groupAllowed = { "admin", "mod" }

  callback({
    PlayerGroup = playerGroup,
    GroupAllowed = groupAllowed
  })
end)



RegisterNuiCallback('ui:Close', function(data, cb)
  SetNuiFocus(false, false)
  if data.name == 'openChat' then
    isUIOpen = false
    cb(true)
  end
  SetTimeout(2000, function() ShowNui(data.name, false, nil) end)
end)


RegisterNUICallback('sendSystemMessage', function(data, cb)
  Utils.DebugPrint(Encode(data, { indent = true }))
  local message = data.message
  TriggerServerEvent("_chat:messageEntered", message, "system")
  cb({ status = 'success' })
end)

local keybind = lib.addKeybind({
  name = 'open_new_chat+1',
  description = 'press F to pay respects',
  defaultKey = 'Z',
  onPressed = function(self)
    local show = false
    show = not show
    ShowNui('openChat', show, cache.serverId)
  end,
})


function IsUi()
  return isUIOpen
end

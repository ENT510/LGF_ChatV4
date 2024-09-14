CFG = {}

-- [[To enable Anti Spam go to "server/main.lua" to manage spam properties ]]
-- [[If you don't see your discord image account, make sure you have entered your discord token in the convars]]

-- Show Group Badge in message content
CFG.EnableGroupMessage = true

-- When Restart a resource o start ecc Send a Message
CFG.EnablePrintSystem = true

-- Use Name steam o Character Name
CFG.NameUsed = "char" -- "steam" or "char"

-- Allowed groups for sending admin messages [for qbox use Ace Perms, go to framework/qbox/server.lua and add or remove group in function BRIDGE:GetPlayerGroup]
CFG.GroupAllowed = {
    ["admin"] = true,
    ["player"] = false,
}

-- Command configuration
CFG.Command = {
    Admin = "adm",            -- Command only for Group Allowed, and only allowed groups will see it
    MutePlayer = "mutePlayer" -- Command To Mote Player only for Group Allowed,
}

-- BlackListedWords Control
CFG.BlackListedWords = {
    "fanculo",
    "stocazz"
}

-- Chat For Job
CFG.JobChat = {
    police = {                 -- Job Name
        command = "pol",       --Command Name
        label = "Police Chat", -- Chat Label
        private = false,       -- If Private only Allowed job see the message
    },
    ambulance = {
        command = "amb",
        label = "Ambulance Chat",
        private = false,
    },
    -- ambulance = {
    --     command = "amb",
    --     label = "Ambulance Chat",
    --     private = false,
    -- },
}

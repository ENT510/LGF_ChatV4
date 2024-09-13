local FRAMEWORK = {}

local CONTEXT_PATHS = {
    CLIENT = 'client',
    SERVER = 'server'
}

--[[ NEED TO CALL THE FOLDER WHIT THE NAME ASSOCIATED]]
local FRAMEWORKS = {
    ES_EXTENDED = { folder = 'esx' },
    QB_CORE = { folder = 'qbox' },
    LEGACYCORE = { folder = 'legacy' },
    CUSTOM = { folder = 'custom' }
}


local CACHED_FRAMEWORKS = {}

--- Creates a new instance of FRAMEWORK.

function FRAMEWORK:new()
    local OBJ = {}
    setmetatable(OBJ, self)
    self.__index = self
    return OBJ
end

--- Returns the appropriate framework object based on the server/client context.
-- @param IS_SERVER boolean: indicates if the context is server.
-- @return SHARED_OBJECT: the found framework object or nil if not found.

function FRAMEWORK:getFrameworkObject(IS_SERVER)
    local CONTEXT = IS_SERVER and CONTEXT_PATHS.SERVER or CONTEXT_PATHS.CLIENT

    if CACHED_FRAMEWORKS[CONTEXT] then
        Utils.DebugPrint(('Framework found in cache: %s'):format(CACHED_FRAMEWORKS[CONTEXT].RESOURCE_NAME))
        return CACHED_FRAMEWORKS[CONTEXT].SHARED_OBJECT
    end

    for RESOURCE_NAME, FRAMEWORK_DATA in pairs(FRAMEWORKS) do
        local FOLDER_NAME = FRAMEWORK_DATA.folder
        local EXPORT_FUNCTION_PATH = ("framework.%s.%s"):format(FOLDER_NAME, CONTEXT)

        if GetResourceState(RESOURCE_NAME) == 'started' then
            local SUCCESS, SHARED_OBJECT = pcall(require, EXPORT_FUNCTION_PATH)
            if SUCCESS then
                CACHED_FRAMEWORKS[CONTEXT] = { RESOURCE_NAME = RESOURCE_NAME, SHARED_OBJECT = SHARED_OBJECT }
                Utils.DebugPrint(('Framework found and cached: %s'):format(RESOURCE_NAME))
                return SHARED_OBJECT
            else
                Utils.DebugPrint(("Error retrieving shared object from %s: %s"):format(RESOURCE_NAME, SHARED_OBJECT))
            end
        end
    end

    Utils.DebugPrint('No framework found.')
    return nil
end

return FRAMEWORK

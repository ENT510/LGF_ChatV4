Utils = {}


local DebugEnabled = true


function Utils.DebugPrint(...)
    if not DebugEnabled then return end

    print("[^3DEBUG^7]", ...)
end

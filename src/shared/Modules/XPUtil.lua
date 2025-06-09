local XPUtil = {}

-- TEMP
local MAX_LEVEL = 10
function XPUtil.GetXPForNextLevel(currLevel: number): number
    if currLevel >= 10 then
        return nil
    end

    return 150 * currLevel
end

return XPUtil
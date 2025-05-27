local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerTimeController = Knit.CreateController({ Name = "ServerTimeController"})

local ServerTimeObject = workspace.ServerTime :: NumberValue 

--local FIXED_OFFSET = 1748352777
function ServerTimeController:KnitInit() 
    
end

function ServerTimeController:GetTime() 
    return ServerTimeObject.Value -- must I add the fixed offset? Probably not.
end
return ServerTimeController
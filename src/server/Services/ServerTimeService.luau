local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerTimeService = Knit.CreateService({ Name = "ServerTimeService"})

local ServerTimeObject = workspace.ServerTime :: NumberValue 

local FIXED_OFFSET = 1748352777
function ServerTimeService:KnitInit() 
    coroutine.wrap(function() 
        while true do 
            ServerTimeObject.Value = tick() - FIXED_OFFSET
            task.wait() 
        end
    end)()
end

function ServerTimeService:GetTime()
    return  ServerTimeObject.Value
end


return ServerTimeService
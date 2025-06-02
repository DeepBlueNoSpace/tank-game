local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Packages.Signal)

local TDM = Knit.CreateService {
    Name = "TDMGamemode",
    Ended = Signal.new(),
    Client = {},
}

function TDM:Start()

end


function TDM:KnitInit()
    
end


function TDM:KnitStart()
    
end


return TDM

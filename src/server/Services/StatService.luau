local SAVE_PROFILE_SCHEMA = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("SAVE_PROFILE_SCHEMA"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local StatService = Knit.CreateService {
    Name = "StatService",
    Client = {},
}

function StatService:IncrementStat(player: Player, statName: string, amount: number)
    if not SAVE_PROFILE_SCHEMA.Stats[statName] then
        warn("StatService:IncrementStat - Invalid stat name:", statName)
        return
    end

    self.DataService:GetReplicaPromise(player):andThen(function(replica)
        replica:SetValue({"Stats", statName}, (replica.Data.Stats[statName] or 0) + amount)
    end)
end

function StatService:KnitInit() 
    self.DataService = Knit.GetService("DataService")
end

function StatService:KnitStart() end

return StatService

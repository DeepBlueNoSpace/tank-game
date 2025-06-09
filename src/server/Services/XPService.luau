local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local XPUtil = require(Knit.Modules.XPUtil)

local XPService = Knit.CreateService {
    Name = "XPService",
    Client = {},
}

function XPService:IncrementXP(player: Player, amount: number)
    if amount < 0 then
        warn("Attempted to add a negative amount of XP:", amount)
        return false
    end

    local replica = self.DataService:GetReplica(player)
    if not replica then
        warn("No replica found for player:", player.Name)
        return false
    end

    local xpToNext = XPUtil.GetXPForNextLevel(replica.Data.LevelData.Level)
    local newXP = replica.Data.LevelData.XP + amount
    local level = replica.Data.LevelData.Level

    while xpToNext ~= nil and newXP > xpToNext do
        newXP = newXP % xpToNext
        level += 1
        xpToNext = XPUtil.GetXPForNextLevel(level)
    end

    replica:SetValue({"LevelData", "Level"}, level)
    replica:SetValue({"LevelData", "XP"}, newXP)
    return true
end


function XPService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end


function XPService:KnitStart()
    
end


return XPService

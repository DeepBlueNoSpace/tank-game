--[[
    Handles distributing rewards
    Rewards (Type.RewardData) is a way to record an arbitrary disribution of items, currency, etc
    Thus various services don't need to re-implement giving currency, tanks, upgrades, etc and can have variable reward types
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local RewardService = Knit.CreateService {
    Name = "RewardService",
    Client = {},
}


function RewardService:GiveReward(player: Player, rewardData: Types.RewardData)
    warn("RewardService:GiveReward - Giving reward to player:", player.Name, "RewardData:", rewardData)
    Knit.GetService("DataService"):GetReplicaPromise(player):andThen(function(replica)
        if rewardData.RewardType == "Currency" then
            self.CurrencyService:IncrementCurrency(player, rewardData.CurrencyName, rewardData.Amount)
        else
            warn("RewardService:GiveReward - Unsupported reward type:", rewardData.RewardType)
            return
        end
    end)
end

function RewardService:KnitInit()
    self.CurrencyService = Knit.GetService("CurrencyService")
end


function RewardService:KnitStart()
    
end


return RewardService

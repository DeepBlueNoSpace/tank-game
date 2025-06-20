local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local QuestData = {}

QuestData.GenericTasks = {
    ["Buy1Tank"] = {
        StatName = "TanksPurchased",
        StatCountType = "Total",
        StatCount = 2,
        Description = "Buy a tank!",
        Reward = {
            RewardType = "Currency",
            CurrencyName = "Cash",
            Amount = 250,
        }
    },

} :: {[string]: Types.QuestData}

return QuestData
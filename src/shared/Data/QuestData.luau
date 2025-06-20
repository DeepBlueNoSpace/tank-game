local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local QuestData = {}

QuestData.GenericTasks = {
    ["FTUE_Buy_Tank"] = {
        StatName = "TanksPurchased",
        StatCountType = "Total",
        StatCount = 2,
        Description = "Buy 2 tanks! uWu :3",
        Reward = {
            RewardType = "Currency",
            CurrencyName = "Cash",
            Amount = 250,
        }
    },
    ["FTUE_Upgrades"] = {
        StatName = "UpgradesPurchased",
        StatCountType = "Total",
        StatCount = 1,
        Description = "Buy any tank upgrade!",
        Reward = {
            RewardType = "Currency",
            CurrencyName = "Cash",
            Amount = 123456,
        }
    },
    ["FTUE_Kills"] = {
        StatName = "Kills",
        StatCountType = "Total",
        StatCount = 5,
        Description = "Kill 5 opps",
        Reward = {
            RewardType = "Currency",
            CurrencyName = "Cash",
            Amount = 750,
        }
    },

} :: {[string]: Types.QuestData}

return QuestData
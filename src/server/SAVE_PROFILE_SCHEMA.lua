local CurrencyData = require(game:GetService("ReplicatedStorage").Shared.Data.CurrencyData)

local DATASCHEMA = {}

DATASCHEMA.Kills = 0
DATASCHEMA.Deaths = 0;

DATASCHEMA.EquippedTank = "Type 87"
DATASCHEMA.OwnedTanks = {
    ["Type 87"] = {
        Wrap = nil,
        Armor = 0;
        Engine = 0;
        Damage = 0;
    },
}


DATASCHEMA.Quests = {
    Completed = {}, -- [QuestName] = true
    --IncrementalStartCount = {}, -- stores stat count at the start of an incremental quest
}

DATASCHEMA.Quests = {
    Completed = {}, -- [QuestName] = true
    --IncrementalStartCount = {}, -- stores stat count at the start of an incremental quest
}

DATASCHEMA.Quests = {
    Completed = {}, -- [QuestName] = true
    --IncrementalStartCount = {}, -- stores stat count at the start of an incremental quest
}

DATASCHEMA.Quests = {
    Completed = {}, -- [QuestName] = true
    --IncrementalStartCount = {}, -- stores stat count at the start of an incremental quest
}

DATASCHEMA.Quests = {
    Completed = {}, -- [QuestName] = true
    --IncrementalStartCount = {}, -- stores stat count at the start of an incremental quest
}

DATASCHEMA.Currency = {}

for currencyName, data in pairs(CurrencyData) do
    DATASCHEMA.Currency[currencyName] = data.DefaultValue or 0
end
 
DATASCHEMA.LevelData = {
    Level = 1,
    XP = 0,
}

DATASCHEMA.Stats = {
    TanksPurchased = 0,
    UpgradesPurchased = 0,
    Kills = 0,
    Deaths = 0,
    Wins = 0,
}

return DATASCHEMA

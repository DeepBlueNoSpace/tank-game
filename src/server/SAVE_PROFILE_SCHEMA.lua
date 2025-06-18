local CurrencyData = require(game:GetService("ReplicatedStorage").Shared.Data.CurrencyData)

local DATASCHEMA = {}

DATASCHEMA.Kills = 0
DATASCHEMA.Deaths = 0;

DATASCHEMA.EquippedTank = "Sherman 1"
DATASCHEMA.OwnedTanks = {
    ["Sherman 1"] = {
        Wrap = nil,
        Armor = 0;
        Engine = 0;
        Damage = 0;
    },
}


DATASCHEMA.Currency = {}

for currencyName, data in pairs(CurrencyData) do
    DATASCHEMA.Currency[currencyName] = data.DefaultValue or 0
end
 
DATASCHEMA.LevelData = {
    Level = 1,
    XP = 0,
}

return DATASCHEMA

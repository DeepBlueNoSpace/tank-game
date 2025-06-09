local CurrencyData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("CurrencyData"))

local DATASCHEMA = {}

DATASCHEMA.Kills = 0
DATASCHEMA.Deaths = 0;

DATASCHEMA.EquippedTank = "Sherman"
DATASCHEMA.OwnedTanks = {
    ["Sherman"] = true,
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

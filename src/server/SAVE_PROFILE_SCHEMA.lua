local CurrencyData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("CurrencyData"))

local DATASCHEMA = {}

DATASCHEMA.Kills = 0
DATASCHEMA.Deaths = 0;

DATASCHEMA.EquippedTank = "Sherman 1"
DATASCHEMA.OwnedTanks = {
    ["Sherman 1"] = true,
}

DATASCHEMA.TankUpgrades = {
    -- NOTE!
    -- For now, equipped has Munition1 and Munition2
    -- But OWNED has Munitions (shared ownership pool)

    OwnedUpgrades = {},
    --[[
        [TankName] = {
            Engine = {
                ["UpgradeName"] = true
            }
        }
    ]]


    EquippedUpgrades = {}
     --[[
        [TankName] = {
            Engine = 'upgradeName'
        }
    ]]
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

--[[
    The main purpose of this module is collect the available upgrades for each tank and assign an ID/cost to each, to facillitate transactions    

    Tanks have a base set of TankAttributes
    Upgrades are additive with a tank's base attribute, e.g health = baseHealth + armor health + engine health

    Munition are defined in MunitionData
    Engines and Armor defined here for now, can be split if needed
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local MunitionData = require(Knit.Data.MunitionData)


-- Prefabs -- atribute sets reusable across multiple tanks

local PREFAB_ATTRIBUTES = {} :: {[string]: {[string]: Types.TankAttributes}}

PREFAB_ATTRIBUTES.ENGINE = {
    Engine1 = {
        Acceleration = 10,
        MaxSpeed = 10,
    },
    Engine2 = {
        Acceleration = 20,
        MaxSpeed = 20,
    },
}

PREFAB_ATTRIBUTES.ARMOR = {
    Armor1 = {
        Health = 500,
        Mass = 100,
        MaxSpeed = -5,
        Acceleration = -2,
    },
    Armor2 = {
        Health = 1000,
        Mass = 200,
        MaxSpeed = -10,
        Acceleration = -4,
    },
}

-------------------------------------------------

local TankUpgradeData = {} :: {
    [string]: {
        Engine: {[string]: Types.TankUpgradeData},
        Armor: {[string]: Types.TankUpgradeData},
        Munitions: {[string]: Types.TankUpgradeData},
    }
}

TankUpgradeData["Sherman"] = {
    Engine = {
        Sherman_Engine1 = {
            Name = "Sherman_Engine1",
            DisplayName = "Engine 1",
            CurrencyType = "Cash",
            Cost = 100,
            Attributes = PREFAB_ATTRIBUTES.ENGINE.Engine1,
        },
        Sherman_Engine2 = {
            Name = "Sherman_Engine2",
            DisplayName = "Engine 2",
            CurrencyType = "Cash",
            Cost = 200,
            Attributes = PREFAB_ATTRIBUTES.ENGINE.Engine2,
        }
    },
    Armor = {
        Sherman_Armor1 = {
            Name = "Sherman_Armor1",
            DisplayName = "Armor 1",
            CurrencyType = "Cash",
            Cost = 150,
            Attributes = PREFAB_ATTRIBUTES.ARMOR.Armor1,
        },
        Sherman_Armor2 = {
            Name = "Sherman_Armor2",
            DisplayName = "Armor 2",
            CurrencyType = "Cash",
            Cost = 300,
            Attributes = PREFAB_ATTRIBUTES.ARMOR.Armor2,
        }
    },
    Munitions = {
        Sherman_Medium = {
            Name = "Sherman_Medium",
            DisplayName = "Medium",
            CurrencyType = "Cash",
            Cost = 50,
            MunitionData = MunitionData["Medium"],
        },
        Sherman_Heavy = {
            Name = "Sherman_Heavy",
            DisplayName = "Heavy",
            CurrencyType = "Cash",
            Cost = 100,
            MunitionData = MunitionData["Heavy"],
        },
    },
}

return TankUpgradeData
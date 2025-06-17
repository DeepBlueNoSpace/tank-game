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
        Acceleration = 0,
        MaxSpeed = 0,
    },
    Engine2 = {
        Acceleration = 20,
        MaxSpeed = 20,
    },
}

PREFAB_ATTRIBUTES.ARMOR = {
    Armor1 = {
        Health = 0,
        Mass = 0,
        MaxSpeed = 0,
        Acceleration = 0,
    },
    Armor2 = {
        Health = 5000,
        Mass = 0,
        MaxSpeed = 0,
        Acceleration = 0,
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

TankUpgradeData["Sherman 1"] = {
    Defaults = {
        Engine = "Sherman_Engine1",
        Armor = "Sherman_Armor1",
        Munition1 = "Sherman_Medium_Munition",
        Munition2 = "Sherman_Heavy_Munition",
    },
    Engine = {
        Sherman_Engine1 = {
            Name = "Sherman_Engine1",
            DisplayName = "Engine 1",
            CurrencyType = "Cash",
            Cost = 0,
            Attributes = PREFAB_ATTRIBUTES.ENGINE.Engine1,
        },
        Sherman_Engine2 = {
            Name = "Sherman_Engine2",
            DisplayName = "Engine 2",
            CurrencyType = "Cash",
            Cost = 10,
            Attributes = PREFAB_ATTRIBUTES.ENGINE.Engine2,
        }
    },
    Armor = {
        Sherman_Armor1 = {
            Name = "Sherman_Armor1",
            DisplayName = "Armor 1",
            CurrencyType = "Cash",
            Cost = 0,
            Attributes = PREFAB_ATTRIBUTES.ARMOR.Armor1,
        },
        Sherman_Armor2 = {
            Name = "Sherman_Armor2",
            DisplayName = "Armor 2",
            CurrencyType = "Cash",
            Cost = 15,
            Attributes = PREFAB_ATTRIBUTES.ARMOR.Armor2,
        }
    },
    Munitions = {
        Sherman_Medium_Munition = {
            Name = "Sherman_Medium_Munition",
            DisplayName = "Medium",
            CurrencyType = "Cash",
            Cost = 0,
            MunitionData = MunitionData["Medium"],
        },
        Sherman_Heavy_Munition = {
            Name = "Sherman_Heavy_Munition",
            DisplayName = "Heavy",
            CurrencyType = "Cash",
            Cost = 0,
            MunitionData = MunitionData["Heavy"],
        },
    },
}

return TankUpgradeData
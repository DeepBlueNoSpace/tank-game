--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local UpgradeTracks = {} :: {[string]: Types.UpgradeTrack}

UpgradeTracks["Damage"] = {
    [1] = {
        PriceMultiplier = 0.5, -- How much it costs relative to the cost of the base tank,
        Effects = {
            ['MaxDamage'] = 1.2,
        }
    },
    [2] = {
        PriceMultiplier = 1, 
        Effects = {
            ['MaxDamage'] = 1.5, 
        }
    },

    [3] = {
        PriceMultiplier = 1.5, 
        Effects = {
            ['MaxDamage'] = 2,
        }
    },

    [4] = {
        PriceMultiplier = 2,
        Effects = {
            ['MaxDamage'] = 2.5,
        }
    },
}

UpgradeTracks["Armor"] = {
    [1] = {
        PriceMultiplier = 0.5, -- How much it costs relative to the cost of the base tank,
        Effects = {
            ['Health'] = 1.2,
        }
    },

    [2] = {
        PriceMultiplier = 1, 
        Effects = {
            ['Health'] = 1.5, 
        }
    },

    [3] = {
        PriceMultiplier = 1.5, 
        Effects = {
            ['Health'] = 2,
        }
    },

    [4] = {
        PriceMultiplier = 2,
        Effects = {
            ['Health'] = 2.5,
        }
    },
}

UpgradeTracks["Engine"] = {
    [1] = {
        PriceMultiplier = 0.5, -- How much it costs relative to the cost of the base tank,
        Effects = {
            ['MaxSpeed'] = 1.2,
        }
    },

    [2] = {
        PriceMultiplier = 1, 
        Effects = {
            ['MaxSpeed'] = 1.5, 
        }
    },

    [3] = {
        PriceMultiplier = 1.5, 
        Effects = {
            ['MaxSpeed'] = 2,
        }
    },

    [4] = {
        PriceMultiplier = 2,
        Effects = {
            ['MaxSpeed'] = 2.5,
        }
    },
}


return UpgradeTracks
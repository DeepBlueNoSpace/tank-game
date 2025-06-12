--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankData = {}

TankData["Sherman 1"] = {
    Name = "Sherman 1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 0,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30,
        
    }

} :: Types.TankData

TankData["Sherman 2"] = {
    Name = "Sherman 2",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData


TankData["Sherman 3"] = {
    Name = "Sherman 3",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 2,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData

TankData["Sherman 4"] = {
    Name = "Sherman 4",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData

TankData["Sherman 5"] = {
    Name = "Sherman 5",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 4,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData

TankData["Sherman 6"] = {
    Name = "Sherman 6",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData

TankData["Sherman 7"] = {
    Name = "Sherman 7",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 6,

    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    },

    BaseAtrributes = {
        Health = 2000,
        Torque = 200000000, 
        Acceleration = 8,
        MaxSpeed = 30
    }

} :: Types.TankData


return TankData
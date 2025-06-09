--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankData = {}

TankData["Sherman"] = {
    Name = "Sherman",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 0,
    Health = 2000,
    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    }
} :: Types.TankData

TankData["Sherman Blue"] = {
    Name = "Sherman Blue",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 100,
    Health = 2000,
    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    }
}

TankData["Sherman Red"] = {
    Name = "Sherman Red",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 100,
    RequiredLevel = 2,
    Health = 2000,
    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    }
}

TankData["Panzer"] = {
    Name = "Panzer",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 100,
    RequiredLevel = 3,
    Health = 1000,
    Munitions = {
        [1] = "Medium",
        [2] = "Light"
    }
} :: Types.TankData

return TankData
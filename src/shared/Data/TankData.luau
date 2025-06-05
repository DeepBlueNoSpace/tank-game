--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankData = {}

TankData["Sherman"] = {
    Name = "Sherman",
    Health = 2000,
    Munitions = {
        [1] = "Medium",
        [2] = "Heavy"
    }
} :: Types.TankData

TankData["Panzer"] = {
    Name = "Panzer",
    Health = 1000,
    Munitions = {
        [1] = "Medium",
        [2] = "Light"
    }
} :: Types.TankData

return TankData
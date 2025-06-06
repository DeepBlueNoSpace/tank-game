--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local HitboxMultiplier = {
    Front = {
        DamageMultiplier = 0.5,
        Color = Color3.fromRGB(0, 255, 0)    
    },  
    Top = {
        DamageMultiplier = 0.8,
        Color = Color3.fromRGB(91, 154, 76)    
    },  
    Left = {
        DamageMultiplier = 1,
        Color = Color3.fromRGB(255, 255, 0)    
    },
    Right = {
        DamageMultiplier = 1,
        Color = Color3.fromRGB(255, 255, 0)    
    },
    Back = {
        DamageMultiplier = 1,
        Color = Color3.fromRGB(255, 0, 0)    
    },
} :: {[string]: Types.HitboxData}

return HitboxMultiplier
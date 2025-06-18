--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local UpgradeTypes = {} :: {[string]: Types.UpgradeType}

UpgradeTypes["Armor"] = {
    DisplayIcon = "rbxassetid://112385107323807",
    EffectDescription = "Health", --What it says it does (e.g +20% Health)
    HeadlineEffect = "Health" -- the attribute change we advertise
}

UpgradeTypes["Damage"] = {
    DisplayIcon = "rbxassetid://87493405797584",
    EffectDescription = "Damage",
    HeadlineEffect = "MaxDamage"
}

UpgradeTypes["Engine"] = {
    DisplayIcon = "rbxassetid://75559510194558",
    EffectDescription = "Speed",
    HeadlineEffect = "MaxSpeed"
} 


return UpgradeTypes
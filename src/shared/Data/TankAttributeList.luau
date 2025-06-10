local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

return {
   ["Health"] = true,
   ["Torque"] = true,
   ["Acceleration"] = true,
   ["Mass"] = true,
   ["MaxSpeed"] = true,
}
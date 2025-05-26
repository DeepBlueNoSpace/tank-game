local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local UIController = Knit.CreateController({ Name = "UIController"})

function UIController:KnitInit() 
    self.PlayerGui = Player:WaitForChild("PlayerGui")
    self.DungeonGui = self.PlayerGui:WaitForChild("Dungeon")
    print(self.DungeonGui)
end

return UIController
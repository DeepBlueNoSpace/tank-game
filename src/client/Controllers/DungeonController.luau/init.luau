local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DungeonController = Knit.CreateController({ Name = "DungeonController"})

local ClientDungeonSequence = require(script.ClientDungeonSequence)

function DungeonController:KnitInit()
    self.DungeonService = Knit.GetService("DungeonService")
end

function DungeonController:KnitStart()
    
end

function DungeonController:StartDungeon(dungeonData: {})
    self.LiveSequence = ClientDungeonSequence.new(dungeonData)    
end




return DungeonController

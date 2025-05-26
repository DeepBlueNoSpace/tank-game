
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollDie = require(ReplicatedStorage.Shared.Modules.RollDie)
local DiceData = require(ReplicatedStorage.Shared.Data.DiceData)

local DungeonSequence = {}
DungeonSequence.__index = DungeonSequence


function DungeonSequence.new(player: Player)
    local self = setmetatable({}, DungeonSequence)
    self.Player = player 
    self.Stage = 1 


    return self
end

function DungeonSequence:GetInitData()
    return {Stage = 1}
end

function DungeonSequence:GetNextRollResult()
    local playerRoll = RollDie(DiceData["Good"])
    local enemyRoll = RollDie(DiceData["Standard"])

    local playerVictory = playerRoll > enemyRoll

    if playerVictory then 
        self.Stage +=1 
    end

    local Results = { 
        PlayerRoll = playerRoll;
        EnemyRoll = enemyRoll,
        PlayerVictory = playerVictory;
        Stage = self.Stage
    }

    if self.Player.leaderstats.HighestStage.Value < self.Stage then 
        self.Player.leaderstats.HighestStage.Value = self.Stage
    end
    
    if not playerVictory then 
        self:Destroy()
    end
    
    return Results, not playerVictory
end

function DungeonSequence:Destroy()
    print("Game over kid")
end

return DungeonSequence
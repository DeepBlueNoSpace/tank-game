--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ClientDungeonSequence = {}
ClientDungeonSequence.__index = ClientDungeonSequence 

function ClientDungeonSequence.new(dungeonData: {})
    local self = setmetatable({}, ClientDungeonSequence)
    self.DungeonService = Knit.GetService("DungeonService")
    self.DungeonController = Knit.GetController("DungeonController")

    self.Data = dungeonData
    self.UI = Knit.GetController("UIController").DungeonGui 

    self.Stage = dungeonData.Stage
    self:HandleWave()

    return self
end

function ClientDungeonSequence:HandleWave()
    local playerRoll = self.UI:WaitForChild("PlayerRoll")
    local enemyRoll = self.UI:WaitForChild("EnemyRoll")
    local rollButton = self.UI:WaitForChild("Roll") 
    local stageLabel = self.UI:WaitForChild("Stage") 

    stageLabel.Text = string.format("Stage %s", self.Stage)

    playerRoll.Visible = false 
    enemyRoll.Visible = false

    rollButton.Visible = false 

    self.UI.Enabled = true 

   self.DungeonService:GetNextRollResult():andThen(function(results)
        rollButton.Visible = true 
    
        rollButton.Activated:Wait()
        rollButton.Visible = false

        playerRoll.Visible = true 
        enemyRoll.Visible = true 

        playerRoll.Value.Text = results.PlayerRoll 
        enemyRoll.Value.Text = results.EnemyRoll 
        
        task.wait(0.5)
        if results.PlayerVictory then 
            --set up next wave 
            self.Stage = results.Stage
            self:HandleWave()
        else
            self:Destroy()
        end
    end)
   
end

function ClientDungeonSequence:Destroy()
    self.DungeonController.LiveSequence = nil 
    self.UI.Enabled = false
end

return ClientDungeonSequence
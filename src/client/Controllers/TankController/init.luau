local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ClientTank = require(script.ClientTank)

local TankController = Knit.CreateController({ Name = "TankController" })

function TankController:KnitInit()
    self.TankService = Knit.GetService("TankService")
    
end

function TankController:KnitStart()
    --spawn(function() 
    --    wait(1)
    --    self:InitTank()
    --    Player.CharacterAdded:Connect(function() 
    --        self:InitTank()
    --    end)
    --end)
end


function TankController:FireLocalTank() 
    
end

function TankController:InitTank()
    self.TankService:RequestTank():andThen(function(tank)
        self.Tank = ClientTank.new(tank) 
    end)
end

function TankController:AttemptDeploy()
    if Knit.GetService("GameLoopService").State:Get() ~= "Active" then
		warn("Cannot deploy, game state is:", self.GameLoopService.State:Get())
		return
	end

    Knit.GetController("LobbyMainUI"):Close()

    if Player.Team then
        self:InitTank()
    else
        -- TODO: kick over to the team selector ui
        -- Will call attempt deploy again after selecting team
        Knit.GetService("TeamService"):RequestAssignTeam():andThen(function(team)
            self:InitTank()
        end):catch(function(err)
            warn("Failed to request team:", err)
        end)
    end
end

return TankController
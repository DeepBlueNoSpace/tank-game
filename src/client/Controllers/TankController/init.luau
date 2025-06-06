--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ClientTank = require(script.ClientTank)

local TankController = Knit.CreateController({ Name = "TankController", 
    Tank = nil :: {}?})

function TankController:KnitInit()
    self.TankService = Knit.GetService("TankService")
    
end

function TankController:KnitStart()
    self.TankService.DestroyClientTank:Connect(function() 
        if self.Tank then 
            self.Tank:Destroy()
            self.Tank = nil 
        end
    end)
end

function TankController:GetTankFromPlayer(player) : Model?
    if not player then return nil end

    local tanksFolder = workspace:WaitForChild("Tanks") :: Folder
    for _, tank in tanksFolder:GetChildren() do 
        local tankModel = tank :: Model
        if tankModel:GetAttribute("Alive") and tankModel:GetAttribute("OwnerName") == player.Name then 
            return tankModel 
        end
    end

    return nil
end

function TankController:InitTank()
    self.TankService:RequestTank():andThen(function(tankId: string, type: string)
        local tankModel = workspace:WaitForChild("Tanks"):WaitForChild(tankId, 3) :: Model
        assert(tankModel, "FUCK FUCK FUCK")

        self.Tank = ClientTank.new(tankModel, type) 
        Knit.GetController("GameUI"):OpenFrame()
    end)
end

function TankController:AttemptDeploy()
    if Knit.GetService("GameLoopService").State:Get() ~= "Active" then
		warn("Cannot deploy, game state is:", self.GameLoopService.State:Get())
		return
	end

    Knit.GetController("LobbyMainUI"):CloseFrame()

    if Player.Team then
        self:InitTank()
    else
        -- TODO: kick over to the team selector ui
        -- Will call attempt deploy again after selecting team
        Knit.GetService("TeamService"):RequestAssignTeam():andThen(function(_team)
            self:InitTank()
        end):catch(function(err)
            warn("Failed to request team:", err)
        end)
    end
end

return TankController
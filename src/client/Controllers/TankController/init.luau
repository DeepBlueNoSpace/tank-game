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
    self.GameLoopService = Knit.GetService("GameLoopService")
    
end

function TankController:KnitStart()
    self.TankService.DestroyClientTank:Connect(function() 
        if self.Tank then 
            self.Tank:Destroy()
            self.Tank = nil 
        end
    end)

    self.TankService.DisableClientTanks:Connect(function() 
        if self.Tank then 
            self.Tank:Disable()
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
    return self.TankService:RequestTank():andThen(function(tankId: string, type: string)
        if not tankId then
            warn("Failed to get tankId from TankService")
            return
        end

        local tankModel = workspace:WaitForChild("Tanks"):WaitForChild(tankId, 3) :: Model
        assert(tankModel, "no tankey wankey")

        self.Tank = ClientTank.new(tankModel, type) 
        Knit.GetController("GameUI"):OpenFrame()
        return true
    end)
end

function TankController:AttemptDeploy()
    if self.GameLoopService.State:Get() ~= "Active" then
		warn("Cannot deploy, game state is:", self.GameLoopService.State:Get())
		return
	end

    local function callInitTank()
        self:InitTank():andThen(function(success)
            if success then
                Knit.GetController("LobbyMainUI"):CloseFrame()
            else
                warn("Failed to initialize tank")
            end
        end):catch(function(err)
            warn("Error initializing tank:", err)
        end)
    end

    if Player.Team then
        callInitTank()
    else
        -- TODO: kick over to the team selector ui
        -- Will call attempt deploy again after selecting team
        Knit.GetService("TeamService"):RequestAssignTeam():andThen(function(_team)
            callInitTank()
        end):catch(function(err)
            warn("Failed to request team:", err)
        end)
    end
end

return TankController
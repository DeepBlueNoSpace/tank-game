--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local KillcamUI= Knit.CreateController({ Name = "KillcamUI", Open = false })

function KillcamUI:Open(killer: Player)
    self.Open = true
    self.Frame.Visible = true

    self.BackgroundFrame.TextLabel.Text = "You were merc'd by " .. killer.DisplayName

    local killerTank = Knit.GetController("TankController"):GetTankFromPlayer(killer)
    if killerTank then
        local camera = workspace.CurrentCamera
        game.Players.LocalPlayer.CameraMinZoomDistance = 30
        camera.CameraSubject = killerTank.PrimaryPart
    end
end

function KillcamUI:CloseFrame()
    self.Open = false
    self.Frame.Visible = false
end

function KillcamUI:LocalReplicaCreated(replica)
	self.Replica = replica
end

function KillcamUI:KnitInit()
    self.Open = false

    self.UIController = Knit.GetController("UIController")
	self.GameLoopService = Knit.GetService("GameLoopService")
end

function KillcamUI:KnitStart()
    self.Frame = self.UIController.GameGui:WaitForChild("KillCam")
    self.BackgroundFrame = self.Frame:WaitForChild("Background")

    self.GameLoopService.PlayerKilled:Connect(function(killer, victim)
        if victim == Players.LocalPlayer then
            self:Open(killer)
        end
    end)
end

return KillcamUI

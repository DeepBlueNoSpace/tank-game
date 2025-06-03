--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local KillcamUI= Knit.CreateController({ Name = "KillcamUI", open = false })

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local GameGui = PlayerGui:WaitForChild("GameGui")
local KillcamFrame = GameGui:WaitForChild("Killcam")
local BackgroundFrame = KillcamFrame:WaitForChild("Background")

function KillcamUI:Open(killer: Player)
    warn("KillcamUI OPEN!!!")
    self.open = true
    self.frame.Visible = true

    BackgroundFrame.TextLabel.Text = "You were merc'd by " .. killer.DisplayName

    local killerTank = Knit.GetController("TankController"):GetTankFromPlayer(killer)
    if killerTank then
        local camera = workspace.CurrentCamera
        game.Players.LocalPlayer.CameraMinZoomDistance = 30
        camera.CameraSubject = killerTank.PrimaryPart
    else
        warn("Killer's tank not found for killcam:", killer.Name)
    end


end

function KillcamUI:Close()
    self.open = false
    self.frame.Visible = false
end

function KillcamUI:LocalReplicaCreated(replica)
	self.replica = replica
end

function KillcamUI:KnitInit()
    self.frame = KillcamFrame
    self.open = false

    self.UIController = Knit.GetController("UIController")
	self.GameLoopService = Knit.GetService("GameLoopService")
end

function KillcamUI:KnitStart()
    self.GameLoopService.PlayerKilled:Connect(function(killer, victim)
        warn("KillcamUI: Player killed:", victim, "by", killer)
        if victim == Players.LocalPlayer then
            self:Open(killer)
        end
    end)
end

return KillcamUI

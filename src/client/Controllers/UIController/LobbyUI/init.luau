--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local LobbyMainUI= Knit.CreateController({ Name = "LobbyMainUI", open = false })

function LobbyMainUI:Open()
	warn("LobbyMainUI OPEN!!!!")
	Knit.GetController("GameUI"):Close()

	self.open = true
	self.frame.Visible = true

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = CameraPart.CFrame
end

function LobbyMainUI:Close()
	self.open = false
    self.frame.Visible = false
end



function LobbyMainUI:LocalReplicaCreated(replica)
	self.replica = replica
end

function LobbyMainUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
end

function LobbyMainUI:KnitStart()
	self.frame = self.UIController.lobbyGui:WaitForChild("Main")
	self.deployButton = self.frame:WaitForChild("DeployButton")

	self.deployButton.Activated:Connect(function()
		Knit.GetController("TankController"):AttemptDeploy()
	end)

	self:Open()

	game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:Open()
	end)
end

return LobbyMainUI

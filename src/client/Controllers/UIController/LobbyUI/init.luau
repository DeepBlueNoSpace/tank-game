local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local LobbyMainUI= Knit.CreateController({ Name = "LobbyMainUI", Open = false })

function LobbyMainUI:OpenFrame()
	Knit.GetController("GameUI"):CloseFrame()

	self.Open = true
	self.Frame.Visible = true

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = CameraPart.CFrame
end

function LobbyMainUI:CloseFrame()
	self.Open = false
    self.Frame.Visible = false
end

function LobbyMainUI:UpdateCash()
	local moneyCounter = self.Frame:FindFirstChild("MoneyCounter")
	moneyCounter.TextLabel.Text = tostring(self.LocalReplica.Data.Currency.Cash)
end




function LobbyMainUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
end

function LobbyMainUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("Main")
	self.DeployButton = self.Frame:WaitForChild("Deploy")

	self.DeployButton.Activated:Connect(function()
		Knit.GetController("TankController"):AttemptDeploy()
	end)

	self:OpenFrame()

	game.Players.LocalPlayer.CharacterAdded:Connect(function()
		self:OpenFrame()
	end)

	Knit.GetController("DataController"):GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
		self.LocalReplica = replica

		self:UpdateCash()
		replica:ListenToChange({"Currency", "Cash"}, function()
			self:UpdateCash()
		end)
	end)
end

return LobbyMainUI

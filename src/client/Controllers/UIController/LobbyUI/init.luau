local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local LobbyMainUI= Knit.CreateController({ Name = "LobbyMainUI", Open = false })

function LobbyMainUI:OpenFrame()
	Knit.GetController("GameUI"):CloseFrame()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	self.Open = true
	self.Frame.Visible = true

	
	Knit.GetController("DataController"):GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
		self.TankDisplay:SetTank(replica.Data.EquippedTank)
		self.TankDisplay:EnableCamera()
	end)
end

function LobbyMainUI:CloseFrame()
	self.Open = false
    self.Frame.Visible = false
end

function LobbyMainUI:UpdateCash()
	local moneyCounter = self.Frame:FindFirstChild("MoneyCounter")
	moneyCounter:WaitForChild("TextLabel").Text = tostring(self.LocalReplica.Data.Currency.Cash)
end

function LobbyMainUI:HookLevelComponent(frame: Frame)
	local XPUtil = require(Knit.Modules.XPUtil)

	local rankImage = frame:WaitForChild("RankImage")
	local levelLabel = frame:WaitForChild("LevelLabel")
	local barBackground = frame:WaitForChild("BarBackground")
	local barFill = barBackground:WaitForChild("BarFill")
	local xpLabel = barBackground:WaitForChild("XPLabel")

	Knit.GetController("DataController"):GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
		local function update()
			levelLabel.Text = "LVL " .. replica.Data.LevelData.Level
			
			local xpToNext = XPUtil.GetXPForNextLevel(replica.Data.LevelData.Level)
			local progressAlpha = replica.Data.LevelData.XP / xpToNext

			barFill.Size = UDim2.new(progressAlpha, 0, 1, 0)
			xpLabel.Text = string.format("%d / %d XP", replica.Data.LevelData.XP, xpToNext)
		
		end

		replica:ListenToChange({"LevelData", "Level"}, function()
			update()
		end)

		replica:ListenToChange({"LevelData", "XP"}, function()
			update()
		end)

		update()
	end)
end


function LobbyMainUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
	self.TankDisplay = Knit.GetController("TankDisplay")
end

function LobbyMainUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("Main")
	self.DeployButton = self.Frame:WaitForChild("Deploy")
	self.Options = self.Frame:WaitForChild("Options")

	self.TankShopButton = self.Options:WaitForChild("Tanks")

	self.TankShopButton.Activated:Connect(function()
		self:CloseFrame()
		self.UIController:AttemptOpen(Knit.GetController("TankShopUI"))
	end)
	
	self:HookLevelComponent(self.Frame:WaitForChild("LevelComponent"))

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

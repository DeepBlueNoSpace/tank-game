local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local QuestUI= Knit.CreateController({ Name = "QuestUI", Open = false })

function QuestUI:OpenFrame()
	self.Open = true
	self.Frame.Visible = true
end

function QuestUI:CloseFrame()
	self.Open = false
    self.Frame.Visible = false
end

function QuestUI:UpdateCash()
	local moneyCounter = self.Frame:FindFirstChild("MoneyCounter")
	moneyCounter:WaitForChild("TextLabel").Text = tostring(self.LocalReplica.Data.Currency.Cash)
end

function QuestUI:AddQuestTile(questName: string)
	if not self.Prefab then
		repeat task.wait() until self.Prefab
	end

	local uiComponent = self.Prefab:Clone()
	uiComponent.Name = questName
	uiComponent.Parent = self.Container
	uiComponent.Visible = true
	return uiComponent
end


function QuestUI:KnitInit()
	self.UIController = Knit.GetController("UIController")
end

function QuestUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("Quests")

	self.Container = self.Frame:WaitForChild("Tasks"):WaitForChild("List")
	self.Prefab = self.Container:WaitForChild("Prefab")
	self.Prefab.Visible = false

	self.BackButton = self.Frame:WaitForChild("Back")

	self.BackButton.Activated:Connect(function()
		self.UIController:AttemptClose(self)
        Knit.GetController("LobbyMainUI"):OpenFrame()
	end)
	
end

return QuestUI

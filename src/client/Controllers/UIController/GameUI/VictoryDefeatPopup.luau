local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local VictoryDefeatPopup= Knit.CreateController({ Name = "VictoryDefeatPopup", Open = false })

function VictoryDefeatPopup:OpenFrame()
	self.Open = true
	self.Frame.Visible = true
end

function VictoryDefeatPopup:CloseFrame()
	self.Open = false
    self.Frame.Visible = false
end

function VictoryDefeatPopup:ShowPopup(wasVictory: boolean)
	self.TextLabel.Text = wasVictory and "VICTORY" or "DEFEAT"
	self.UIController:AttemptOpen(self)
end

function VictoryDefeatPopup:KnitInit()
	self.UIController = Knit.GetController("UIController")
end

function VictoryDefeatPopup:KnitStart()
	self.Frame = self.UIController.GameGui:WaitForChild("VictoryDefeatPopup")
	self.Banner = self.Frame:WaitForChild("Banner")
	self.TextLabel = self.Banner:WaitForChild("TextLabel")

	
end

return VictoryDefeatPopup

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local UIController = Knit.CreateController({
	Name = "UIController",
	activeController = nil,
	canOpen = true :: boolean,

	defaultOpenPosition = UDim2.fromScale(0.5, 0.5) :: UDim2,
	defaultClosePosition = UDim2.fromScale(0.5, 1.5) :: UDim2,
})

--[[
Attempts to run the enable function of the requested controller.
    Returns if it was successful.
]]

function UIController:AttemptOpen(controller): boolean
	if self.ActiveController then
		if self.ActiveController == controller then
			return false
		end

		UIController:AttemptClose(self.ActiveController)
	end

	controller:OpenFrame()
	self.ActiveController = controller

	return true
end

function UIController:AttemptClose(controller): boolean
	if self.ActiveController == controller then
		self.ActiveController:CloseFrame()
		self.ActiveController = nil
		GuiService.SelectedObject = nil
    else
        controller:CloseFrame()
	end

	return true
end


function UIController:KnitInit()
	self.PlayerGui = PlayerGui
	self.LobbyGui = self.PlayerGui:WaitForChild("LobbyGui")
	self.GameGui = self.PlayerGui:WaitForChild("GameGui")
end

function UIController:KnitStart()

end

return UIController

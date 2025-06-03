--!nocheck
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIController = Knit.CreateController({
	Name = "UIController",
	activeController = nil,
	canOpen = true :: boolean,

	defaultOpenPosition = UDim2.fromScale(0.5, 0.5) :: UDim2,
	defaultClosePosition = UDim2.fromScale(0.5, 1.5) :: UDim2,
})

local Blur = Instance.new("BlurEffect")
Blur.Name = "UIControllerBlur"
Blur.Enabled = true
Blur.Size = 0
Blur.Parent = game.Lighting

local UIControllerArray= {}

--[[
Attempts to run the enable function of the requested controller.
    Returns if it was successful.
]]

function UIController:AttemptOpen(controller): boolean
	if self.activeController then
		if self.activeController == controller then
			return
		end

		UIController:AttemptClose(self.activeController)
	end

	controller:Open()
	self.activeController = controller

	return true
end

function UIController:AttemptClose(controller): boolean
	if self.activeController == controller then
		self.activeController:Close()
		self.activeController = nil
		GuiService.SelectedObject = nil
    else
        controller:Close()
	end

	return true
end


function UIController:KnitInit()


	self.playerGui = PlayerGui
	self.lobbyGui = self.playerGui:WaitForChild("LobbyGui")
	self.gameGui = self.playerGui:WaitForChild("GameGui")
end

function UIController:KnitStart()

end

return UIController

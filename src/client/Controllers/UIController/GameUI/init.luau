--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LobbyScene = workspace:WaitForChild("LobbyScene")
local CameraPart = LobbyScene:WaitForChild("CameraPart")

local GameUI= Knit.CreateController({ Name = "GameUI", open = false })

function GameUI:Open()
    local currGamemode = self.GameLoopService.Gamemode:Get()
    if not currGamemode then
        warn("No gamemode set, cannot open UI??")
        return
    else
        self.GamemodeUIControllers[currGamemode]:Open()
    end
end

function GameUI:Close()
    for _, v in pairs(self.GamemodeUIControllers) do
        v:Close()
    end

    Knit.GetController("KillcamUI"):Close()
end

function GameUI:LocalReplicaCreated(replica)
	self.replica = replica
end

function GameUI:KnitInit()
    self.UIController = Knit.GetController("UIController")
	self.GameLoopService = Knit.GetService("GameLoopService")
    self.GamemodeUIControllers = {
        ["Deathmatch"] = Knit.GetController("DeathmatchGamemodeUI"),
    }
end

function GameUI:KnitStart()
    self.screenGui = self.UIController.gameGui
end

return GameUI

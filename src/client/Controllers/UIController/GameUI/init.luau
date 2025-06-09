--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GameUI= Knit.CreateController({ Name = "GameUI", Open = false })

function GameUI:OpenFrame()
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    local currGamemode = self.GameLoopService.Gamemode:Get()
    if not currGamemode then
        warn("No gamemode set, cannot open UI??")
        return
    else
        self.GamemodeUIControllers[currGamemode]:OpenFrame()
    end
end

function GameUI:CloseFrame()
    for _, v in pairs(self.GamemodeUIControllers) do
        v:CloseFrame()
    end

    Knit.GetController("KillcamUI"):CloseFrame()
end

function GameUI:LocalReplicaCreated(replica)
	self.Replica = replica
end

function GameUI:KnitInit()
    self.UIController = Knit.GetController("UIController")
	self.GameLoopService = Knit.GetService("GameLoopService")
    self.GamemodeUIControllers = {
        ["Deathmatch"] = Knit.GetController("DeathmatchGamemodeUI"),
    }
end

function GameUI:KnitStart()
    self.ScreenGui = self.UIController.GameGui
end

return GameUI

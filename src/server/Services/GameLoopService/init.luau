local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GameLoopService = Knit.CreateService {
    Name = "GameLoopService",
    
    GamemodeController = nil,

    Client = {
        State = Knit.CreateProperty("Intermission"),
        Gamemode = Knit.CreateProperty(nil),
    }
}

function GameLoopService:Main()
    while true do
        self.Client.State:Set("Intermission")
        self.Client.Gamemode:Set(nil)
        -- Cleanup any player tanks

        -- wait a few seconds...............

        -- Select gamemode
        warn("TODO: players vote on gamemode")
        local selectedGamemode = "TDM"

        -- Select + load map
        warn("TODO: players vote on map")
        warn("TODO: Load map")

        -- Setup teams, just assume all maps have 2 for now
        Knit.GetService("TeamService"):SetupTeams(2)

        -- Start game
        self.Client.State:Set("Active")
        self.Client.Gamemode:Set(selectedGamemode)
        self.GamemodeController = self.GamemodeOptions[selectedGamemode]
        self.GamemodeController:Start()

        -- Gamemode over for whatever reason
        self.GamemodeController.Ended:Wait()
        
    end
end

function GameLoopService:_setState(state)
    self.Client.State:Set(state)
    warn("State set to:", state)
end


function GameLoopService:PlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 0
    end)
    
end


function GameLoopService:PlayerRemoving()
    
end


function GameLoopService:KnitInit()
    self.GamemodeOptions = {
        ["TDM"] = Knit.GetService("TDMGamemode"),
    }
    
end


function GameLoopService:KnitStart()
    self:Main()
end


return GameLoopService

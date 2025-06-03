local ROUND_TIME = 60 * 10

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local GameLoopService = Knit.CreateService {
    Name = "GameLoopService",
    
    GamemodeController = nil,

    Client = {
        State = Knit.CreateProperty("Intermission"),
        StateEndTime = Knit.CreateProperty(-1),
        Gamemode = Knit.CreateProperty(nil),
        PlayerKilled = Knit.CreateSignal(),
    }
}

function GameLoopService:Main()
    while true do
        self.Client.State:Set("Intermission")
        self.Client.Gamemode:Set(nil)
        -- wait a few seconds...............

        -- Select gamemode
        warn("TODO: players vote on gamemode")
        local selectedGamemode = "Deathmatch"

        -- Select + load map
        warn("TODO: players vote on map")
        warn("TODO: Load map")

        -- Setup teams, just assume all maps have 2 for now
        Knit.GetService("TeamService"):SetupTeams(2)

        -- Start game
        self.Client.State:Set("Active")
        self.Client.StateEndTime:Set(Knit.GetService("ServerTimeService"):GetTime() + ROUND_TIME)
        self.Client.Gamemode:Set(selectedGamemode)
        self.GamemodeController = self.GamemodeOptions[selectedGamemode]
        self.GamemodeController:Start()

        -- Gamemode over for whatever reason
        self.GamemodeController.Ended:Wait()

        -- TODO handle this better, leaderboards, maybe slow em all down and disable shooting for 10s something aesthetic
        warn("ROUND OVER!!!!!!!!!!!!!!!!!!!!!!!!!!")
        Knit.GetService("TankService"):DestroyAllTanks()
        
    end
end

function GameLoopService:_setState(state)
    self.Client.State:Set(state)
    warn("State set to:", state)
end


function GameLoopService:ReportKill(killer: Player, victim: Player)
    if self.GamemodeController and self.GamemodeController.ReportKill then
        self.GamemodeController:ReportKill(killer, victim)
    end

    self.Client.PlayerKilled:FireAll(killer, victim)
end

function GameLoopService:PlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 0
    end)
end

function GameLoopService:PlayerRemoving() end

function GameLoopService:KnitInit()
    self.GamemodeOptions = {
        ["Deathmatch"] = Knit.GetService("DeathmatchGamemodeService"),
    }
end


function GameLoopService:KnitStart()
    self:Main()
end


return GameLoopService

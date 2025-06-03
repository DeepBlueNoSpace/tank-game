local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Packages.Signal)
local Trove = require(Knit.Packages.Trove)

local DeathmatchGamemode = Knit.CreateService {
    Name = "DeathmatchGamemodeService",
    Ended = Signal.new(),
    Trove = Trove.new(),
    Client = {
        KillLeaderboard = Knit.CreateProperty({})
    },
}

function DeathmatchGamemode:Start()
    self.Client.KillLeaderboard:Set({})
    for _, plyr in pairs(game.Players:GetPlayers()) do
        self:PlayerAdded(plyr)
    end
    
    
    self.Trove:Add(game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if self:CheckWinCondition() then
            self:End()
        end
    end))
end

function DeathmatchGamemode:CheckWinCondition()
    return self.ServerTimeService:GetTime() > self.GameLoopService.Client.StateEndTime:Get() -- no win condition, just end the game after a time
end

function DeathmatchGamemode:End()
    self.Trove:Clean()
    self.Ended:Fire()
end

function DeathmatchGamemode:ReportKill(killer: Player, victim: Player)
    local leaderboard = self.Client.KillLeaderboard:Get()
    if not leaderboard[killer.Name] then
        leaderboard[killer.Name] = 0
    end
    leaderboard[killer.Name] += 1
    self.Client.KillLeaderboard:Set(leaderboard)
end

function DeathmatchGamemode:PlayerAdded(player: Player)
    -- Initialize player data if needed
    local leaderboard = self.Client.KillLeaderboard:Get()
    if not leaderboard[player.Name] then
        leaderboard[player.Name] = 0
        self.Client.KillLeaderboard:Set(leaderboard)
    end

    self.Trove:Add( player:GetPropertyChangedSignal("Team"):Connect(function()
        self.Client.KillLeaderboard:Set(self.Client.KillLeaderboard:Get()) -- force update leaderboard on team change, a lil hacky but yolo
    end))

end

function DeathmatchGamemode:KnitInit()
    self.GameLoopService = Knit.GetService("GameLoopService")
    self.ServerTimeService = Knit.GetService("ServerTimeService")
end


function DeathmatchGamemode:KnitStart()
    
end


return DeathmatchGamemode

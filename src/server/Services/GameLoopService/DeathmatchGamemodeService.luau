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
    local winners: {[string]: boolean} = {}
    local endgameDataPackage: {Types.EndgamePlayerPackage} = {}

    -- get winners
    local leaderboardHash = self.Client.KillLeaderboard:Get()
    local leaderboardArr = {}

    for player: Player, kills: number in pairs(leaderboardHash) do
        local playerObj = game.Players:FindFirstChild(player)
        if not playerObj then
            continue -- player left, skip them
        end
        local replica = self.DataService:GetReplica(playerObj)
        if not replica then
            continue -- no replica, skip them
        end

        table.insert(leaderboardArr, {
            Player = playerObj,
            Kills = kills,
            Replica = replica,
        })
    end

    table.sort(leaderboardArr, function(a, b)
        return a.Kills > b.Kills
    end)

    if #leaderboardArr > 0 then -- probably overkill but make sure no edge case server crashes with 0 players
        -- first 1/2 of the leaderboard is winners, rest are losers
        -- doesn't handle case where players are tied
        for i = 1, math.max(math.floor(#leaderboardArr / 2),1) do
            winners[leaderboardArr[i].Player.Name] = true
        end

        -- populate endgameDataPackage with players sorted by performance
        for i, data in pairs(leaderboardArr) do
            table.insert(endgameDataPackage, {
                PlayerName = data.Player.Name,
                Player = data.Player,
                Tank = data.Replica.Data.EquippedTank,
                Rank = i,
                IsWinner = winners[data.Player.Name] == true,
                Kills = data.Kills,
                Team = data.Player.Team,
            })
        end
    end

    self.Trove:Clean()
    self.Ended:Fire(winners, endgameDataPackage)
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

    self.Trove:Add(player:GetPropertyChangedSignal("Team"):Connect(function()
        self.Client.KillLeaderboard:Set(self.Client.KillLeaderboard:Get()) -- force update leaderboard on team change, a lil hacky but yolo
    end))

end

function DeathmatchGamemode:KnitInit()
    self.DataService = Knit.GetService("DataService")
    self.GameLoopService = Knit.GetService("GameLoopService")
    self.ServerTimeService = Knit.GetService("ServerTimeService")
end


function DeathmatchGamemode:KnitStart()
    
end


return DeathmatchGamemode

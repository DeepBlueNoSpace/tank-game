local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RbxTeamService = game:GetService("Teams")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TeamUtil = require(Knit.Modules.TeamUtil)

local TeamService = Knit.CreateService {
    Name = "TeamService",
    Client = {},
}

function TeamService:SetupTeams(amount: boolean)
    for i=1, amount do
        local teamData = TeamUtil.TeamData[i]
        local team = Instance.new("Team")
        team.Name = teamData.Name
        team.TeamColor = teamData.Color
        team.AutoAssignable = false
        team.Parent = RbxTeamService
    end
end

function TeamService:ResetTeams()
    for _, team in pairs(RbxTeamService:GetTeams()) do
        team:Detroy()
    end

    for i,v in pairs(game.Players:GetPlayers()) do
        if v.Team then
            v.Team = nil
        end
    end
end

function TeamService:AutoAssignTeam(player: Player)
    warn("AutoAssigning team for player:", player.Name, "... in future add team selection")

    -- find smallest team
    local teamCount = TeamUtil.GetTeamCount()
    local min = math.huge
    local minTeam = nil

    for teamIndex, count in pairs(teamCount) do
        if count < min then
            min = count
            minTeam = teamIndex
        end
    end

    -- assign player to the smallest team
    local teamObj = RbxTeamService:FindFirstChild(TeamUtil.TeamData[minTeam].Name)
    player.Team = teamObj
    return teamObj
end

function TeamService.Client:RequestAssignTeam(player: Player, teamIndex: number?)
    if not teamIndex then
        return TeamService:AutoAssignTeam(player)
    end
end

function TeamService:KnitInit()
    
end


function TeamService:KnitStart()
    
end


return TeamService

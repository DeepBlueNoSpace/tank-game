local TeamsService = game:GetService("Teams")
local TeamUtil = {}

TeamUtil.TeamData = {
    [1] = {
        Name = "Evil Bloxxers",
        Color = BrickColor.new("Bright red"),
        Index = 1
    },
    [2] = {
        Name = "Chad Looksmaxxers",
        Color = BrickColor.new("Bright blue"),
        Index = 2
    },
}

TeamUtil.TeamDataByName = {}
for i,v in pairs(TeamUtil.TeamData) do
    TeamUtil.TeamDataByName[v.Name] = v
end


-- Map spawns use index rather than hardcoded names 
function TeamUtil.GetTeamIndex(teamName: string)
    if typeof(teamName) == "Instance" then
        teamName = teamName.Name
    end

    return TeamUtil.TeamDataByName[teamName].Index
end

function TeamUtil.GetTeamCount()
    local count = {}

    for _, team in pairs(TeamsService:GetTeams()) do
        count[TeamUtil.GetTeamIndex(team.Name)] = 0
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        if not player.Team or player.Neutral then
            continue
        end

        local teamIndex = TeamUtil.GetTeamIndex(player.Team.Name)
        count[teamIndex] = count[teamIndex] + 1
    end

    return count
end


return TeamUtil
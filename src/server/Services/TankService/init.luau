local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", 
    Client = {
        DestroyClientTank = Knit.CreateSignal()}, 
        LiveTanks = {} :: {[Player]:{}}
    })
local ServerTank = require(script.ServerTank)
local TeamUtil = require(Knit.Modules.TeamUtil)

function TankService:KnitInit() 

end

function TankService:RemovePlayersTankIndex(player: Player, tankObject: {})
    --Only unindexed once the tank object has done deleting itself.
    if self.LiveTanks[player] == tankObject then 
        self.LiveTanks[player] = nil
    end
end

function TankService.Client:RequestTank(player: Player)
    if not player.Character or player.Character.Parent == nil then
        warn("Player does not have a character when requesting a tank:", player)
        return
    end

    if player.Team then
        local teamIndex = TeamUtil.GetTeamIndex(player.Team)
        local map = workspace:WaitForChild("Map") -- TODO get from gamemode controller
        local spawns = map:WaitForChild("Spawns"):WaitForChild(tostring(teamIndex))
        local chosenSpawn = spawns:GetChildren()[math.random(1, #spawns:GetChildren())]
        player.Character:PivotTo(chosenSpawn.CFrame * CFrame.new(Vector3.new(0,player.Character.Humanoid.HipHeight,0)))
    else
        warn("Player does not have a team assigned when requesting a tank:", 
            player.Name, "are you sure this is supposed to happen?")
    end
    
    local tank = ServerTank.new(player)
    TankService.LiveTanks[player] = tank

    return tank.Model
end

function TankService:DestroyAllTanks()
    for _, tank in pairs(self.LiveTanks) do
        tank:Disable(0)
    end
end

function TankService:GetTankFromModel(model: Model)
    for _, tank in self.LiveTanks do 
        if tank.Model == model then 
            return tank 
        end
    end

    return nil
end




return TankService
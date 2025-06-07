--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", 
    Client = {
        DestroyClientTank = Knit.CreateSignal()}, 
        LiveTanks = {} :: {[Player]:{}}
    })
local ServerTank = require(script.ServerTank)
local TeamUtil = require(ReplicatedStorage.Shared.Modules.TeamUtil)

function TankService:KnitInit() 
    self.DataService = Knit.GetService("DataService")

end

function TankService:RemovePlayersTankIndex(player: Player, tankObject: {})
    --Only unindexed once the tank object has done deleting itself.
    if self.LiveTanks[player] == tankObject then 
        self.LiveTanks[player] = nil
    end
end

local tankIdGen = 1 

function TankService.Client:RequestTank(player: Player)
    if not player.Character or player.Character.Parent == nil then
        warn("Player does not have a character when requesting a tank:", player)
        return
    end

    local replica = TankService.DataService:GetReplica(player)
    if not replica then 
        return 
    end

    if player.Team then
        local playerTeam = tostring(player.Team)
        local teamIndex = TeamUtil.GetTeamIndex(playerTeam)

        local map = workspace:WaitForChild("Map") -- TODO get from gamemode controller
        local spawns = map:WaitForChild("Spawns"):WaitForChild(tostring(teamIndex))
        local chosenSpawn = spawns:GetChildren()[math.random(1, #spawns:GetChildren())]

        local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid
        if not humanoid then 
            return 
        end

        local height = humanoid and humanoid.HipHeight or 0
        player.Character:PivotTo(chosenSpawn.CFrame * CFrame.new(Vector3.new(0,height,0)))
    else
        warn("Player does not have a team assigned when requesting a tank:", 
            player.Name, "are you sure this is supposed to happen?")
    end


    local tankType = replica.Data.EquippedTank
    local tank = ServerTank.new(player, tankType)
    TankService.LiveTanks[player] = tank

    local tankId = tankIdGen
    tank.Model.Name = tostring(tankId)
    tankIdGen+=1
    
    task.wait(1)

    return tankId, tankType
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
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", 
    Client = {
        DestroyClientTank = Knit.CreateSignal(),
        DisableClientTanks = Knit.CreateSignal()}, 
        LiveTanks = {} :: {[Player]:{}}
    })
local ServerTank = require(script.ServerTank)
local TeamUtil = require(ReplicatedStorage.Shared.Modules.TeamUtil)

function TankService:KnitInit() 
    self.DataService = Knit.GetService("DataService")
    self.GameLoopService = Knit.GetService("GameLoopService")

end

function TankService:RemovePlayersTankIndex(player: Player, tankObject: {})
    --Only unindexed once the tank object has done deleting itself.
    if self.LiveTanks[player] == tankObject then 
        self.LiveTanks[player] = nil
    end
end

local tankIdGen = 1 

function TankService.Client:RequestTank(player: Player)
    if TankService.GameLoopService.Client.State:Get() ~= "Active" then
        warn("Player tried to request a tank when the game is not active:", player, TankService.GameLoopService.Client.State:Get())
        return false
    end

    local replica = TankService.DataService:GetReplica(player)
    if not replica then 
        return 
    end

    if not player.Team then
        warn("Player does not have a team assigned when requesting a tank:", 
            player, " -- not handled rn")
        return
    end


    local playerTeam = tostring(player.Team)
    local teamIndex = TeamUtil.GetTeamIndex(playerTeam)

    local map = workspace:WaitForChild("Map") -- TODO get from gamemode controller
    local spawns = map:WaitForChild("Spawns"):WaitForChild(tostring(teamIndex))
    local chosenSpawn = spawns:GetChildren()[math.random(1, #spawns:GetChildren())]

    local tankType = replica.Data.EquippedTank
    local tankUpgrades = replica.Data.OwnedTanks[tankType]
    local tank = ServerTank.new(player, tankType, tankUpgrades, chosenSpawn.CFrame)
    
    TankService.LiveTanks[player] = tank

    local tankId = tankIdGen
    tank.Model.Name = tostring(tankId)
    tankIdGen+=1
    
    task.wait(1)

    return tankId, tankType
end

function TankService:DestroyAllTanks()
    for _, tank in pairs(self.LiveTanks) do
        tank:Destroy()
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

function TankService:DeactivateTanks()
for _, tank in pairs(self.LiveTanks) do
        tank:Disable()
    end
end



return TankService
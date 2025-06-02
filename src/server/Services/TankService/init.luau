local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", Client = {}})
local ServerTank = require(script.ServerTank)
local TeamUtil = require(Knit.Modules.TeamUtil)

function TankService:KnitInit() 

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
        warn("Player does not have a team assigned when requesting a tank:", player.Name, "are you sure this is supposed to happen?")
    end
    
    


    local tank = ServerTank.new(player)
    return tank.Model
end

function TankService.Client:Fire(player: Player, tank: Model)
    local barrelEnd = tank:FindFirstChild("BarrelEnd", true) :: Attachment?
    if not barrelEnd then return end

    -- Direction to fire: straight forward from the barrel
    local origin = barrelEnd.WorldPosition
    local direction = barrelEnd.WorldCFrame.LookVector * 1000 -- 1000 studs ahead

    -- Raycast parameters (ignore the tank itself)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {tank}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    -- Fire the ray
    local result = workspace:Raycast(origin, direction, rayParams)

    if result then
        local hitPos = result.Position

        -- Create an explosion at the hit point
        local explosion = Instance.new("Explosion")
        explosion.Position = hitPos
        explosion.BlastRadius = 10
        explosion.BlastPressure = 5000
        explosion.Parent = workspace
    end
end

return TankService
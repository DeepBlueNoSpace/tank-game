local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", Client = {}})

function TankService:KnitInit() 

end

function TankService.Client:RequestTank(player: Player)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local tank = ReplicatedStorage.Tank:Clone()
    tank.Parent = workspace

    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    tank:SetPrimaryPartCFrame(spawnCFrame)

    repeat 
        wait() 
    until tank.Chassis.VehicleSeat.Anchored == false 

    tank.PrimaryPart:SetNetworkOwner(player)
    return tank
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
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    -- Fire the ray
    local result = workspace:Raycast(origin, direction, rayParams)

    if result then
        local hitPos = result.Position

        -- Create an explosion at the hit point
        local explosion = Instance.new("Explosion")
        explosion.Position = hitPos
        explosion.BlastRadius = 10
        explosion.BlastPressure = 500000
        explosion.DestroyJointRadiusPercent = 30
        explosion.Parent = workspace
    end
end

return TankService
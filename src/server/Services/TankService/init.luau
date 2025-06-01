local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankService = Knit.CreateService({ Name = "TankService", Client = {}})
local ServerTank = require(script.ServerTank)

function TankService:KnitInit() 

end

function TankService.Client:RequestTank(player: Player)
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
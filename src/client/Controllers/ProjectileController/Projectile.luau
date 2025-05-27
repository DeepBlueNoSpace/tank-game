local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets 

local ServerTime = workspace:WaitForChild("ServerTime")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Types = require(ReplicatedStorage.Shared.Data.Types)

local Projectile = {}
Projectile.__index = Projectile

--ALL TIMES ARE SERVER TIMES
function Projectile.new(isLocal: boolean, projectileData: Types.ProjectileData)
    local self = setmetatable({}, Projectile)
    self.ProjectileService = Knit.GetService("ProjectileService")

    self.Id = projectileData.Id 
    self.Origin = projectileData.Origin 
    self.MuzzleVelocity = projectileData.MuzzleVelocity
    self.StartTime = projectileData.StartTime
    self.LastUpdate = projectileData.StartTime
    
    self.IsLocal = isLocal

    self.Position = self.Origin
    self.Velocity = self.MuzzleVelocity

    self:SetUpModel()
    
    if isLocal then 
        self:ReplicateToServer(projectileData)
    end

    return self 
end

function Projectile:ReplicateToServer(projectileData: Types.ProjectileData)
    self.ProjectileService.SpawnProjectile:Fire(projectileData)
end

function Projectile:SetUpModel()
    local model = Assets.ProjectilePrefab:Clone()
    model.Parent = workspace
    self.Model = model 

    self:UpdateModelPosition()
end

function Projectile:UpdateModelPosition()
    self.Model:PivotTo(CFrame.new(self.Position, self.Velocity))
end

function Projectile:OnHit(result: RaycastResult)
    --Do visuals (this will get replaced with a custom, scalable effect)
    local explosion = Instance.new("Explosion")
    explosion.Position = result.Position
    explosion.BlastRadius = 0
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace

    --Replicate to server
    self.ProjectileService.ProjectileHit:Fire(self.Id, result.Position)

    --Clean up
    self:Destroy()
end 

function Projectile:Destroy()
    self.Model:Destroy()
end

function Projectile:Update(serverTime: number): boolean
    --Calculations
    local t = serverTime - self.LastUpdate
    local distanceTravelled = t * self.Velocity

    local currentPosition = self.Position
    local nextPosition = currentPosition + distanceTravelled
    local direction = nextPosition - currentPosition

    -- Raycast to detect obstacles
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {self.Model} 
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(currentPosition, direction, raycastParams)

    if result then
        self:OnHit(result)
        return true
    else
        self.Position = nextPosition
        self:UpdateModelPosition()
        return false
    end
end

return Projectile
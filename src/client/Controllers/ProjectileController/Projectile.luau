local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets 

local ServerTime = workspace:WaitForChild("ServerTime")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Types = require(ReplicatedStorage.Shared.Data.Types)
local MunitionData = require(ReplicatedStorage.Shared.Data.MunitionData)

local Projectile = {}
Projectile.__index = Projectile

--ALL TIMES ARE SERVER TIMES
function Projectile.new(isLocal: boolean, projectileData: Types.ProjectileData)
    local self = setmetatable({}, Projectile)
    self.ProjectileService = Knit.GetService("ProjectileService")
    self.VFXController = Knit.GetController("VFXController")

    self.Id = projectileData.Id :: string
    self.Origin = projectileData.Origin :: Vector3
    self.MuzzleVelocity = projectileData.MuzzleVelocity :: Vector3
    self.StartTime = projectileData.StartTime :: number
    self.LastUpdate = projectileData.StartTime :: number 
    self.BarrelEnd = projectileData.BarrelEnd :: Attachment?
    self.MunitionType = projectileData.MunitionType :: string

    self.IsLocal = isLocal :: boolean
    
    self.Position = self.Origin :: Vector3
    self.Velocity = self.MuzzleVelocity :: Vector3

    self:SetUpModel()
    self:SpawnEffect() 

    if isLocal then 
        self:ReplicateToServer(projectileData)
    end

    return self 
end

function Projectile:SpawnEffect()
    local barrelEnd = self.BarrelEnd
    if not barrelEnd then 
        return 
    end

    local vfxInfo = {
        Parent = barrelEnd
    } :: Types.VFXInfo

    self.VFXController:SpawnVFX("CannonFire", vfxInfo)
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

local BaseRadius = 20 

function Projectile:OnHit(result: RaycastResult)
    local blastRadius = MunitionData[self.MunitionType].BlastRadius
    local blastScalar = blastRadius/BaseRadius
    local explosionInfo = {
        ScaleSize = 2*blastScalar, 
        CFrame = CFrame.new(result.Position)
    } :: Types.VFXInfo

    self.VFXController:SpawnVFX("Explosion", explosionInfo)

    --Replicate to server
    if self.IsLocal then 
        self.ProjectileService.ProjectileHit:Fire(self.Id, result.Position, result.Instance)
    end

    --Clean up
    self:Destroy()
end 

function Projectile:Destroy()
     self.Model:Destroy()
end

function Projectile:CastRay(currentPosition: Vector3, direction: Vector3, collisionGroup: string) : RaycastResult
   -- Raycast to detect obstacles
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {self.Model} 
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude   
    raycastParams.IgnoreWater = true
    raycastParams.CollisionGroup = collisionGroup

    local result = workspace:Raycast(currentPosition, direction, raycastParams)
    return result 
end

function Projectile:Update(serverTime: number): boolean
    --Calculations
    local t = serverTime - self.LastUpdate
    local distanceTravelled = t * self.Velocity

    local currentPosition = self.Position
    local nextPosition = currentPosition + distanceTravelled
    local direction = nextPosition - currentPosition

    local result = self:CastRay(currentPosition, direction, "TankHitbox")
    if not result then 
        result = self:CastRay(currentPosition, direction, "Default")
    end
 
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
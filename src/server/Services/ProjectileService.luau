local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local MunitionData = require(ReplicatedStorage.Shared.Data.MunitionData)

local ProjectileService = Knit.CreateService({ Name = "ProjectileService", 
    Client = {
        SpawnProjectile = Knit.CreateSignal(),
        ProjectileHit = Knit.CreateSignal()
    },
    LiveProjectiles = {

    }:: {[string]: Types.ProjectileData}
})

function ProjectileService:KnitStart() 
    self.ExplosionService = Knit.GetService("ExplosionService")
end

function ProjectileService:KnitInit()
    self.Client.SpawnProjectile:Connect(function(player: Player, projectileData: Types.ProjectileData)
        projectileData.Owner = player
        self.LiveProjectiles[projectileData.Id] = projectileData

        self.Client.SpawnProjectile:FireAll(projectileData)

        task.delay(10, function() 
            if self.LiveProjectiles[projectileData.Id]  then 
                self.LiveProjectiles[projectileData.Id]  = nil 
            end
        end)
    end)

    self.Client.ProjectileHit:Connect(function(player: Player, projectileId: string, hitPosition: Vector3, hitInstance: BasePart?)
        local projectile = self.LiveProjectiles[projectileId]
        assert(projectile, "Projectile not found")
        assert(projectile.Owner == player, "Player not owner of projectile") 

        local munitionData = MunitionData[projectile.MunitionType]
        self.ExplosionService:SpawnExplosion(player, hitPosition, hitInstance, munitionData.BlastRadius, munitionData.BaseDamage)
    end)
end



return ProjectileService
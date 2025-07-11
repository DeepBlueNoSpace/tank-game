local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)

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
    self.TankService = Knit.GetService("TankService")
end

local DEFAULT_RADIUS = 10

function ProjectileService:KnitInit()
    self.Client.SpawnProjectile:Connect(function(player: Player, projectileData: Types.ProjectileData)
        local firingTank = self.TankService.LiveTanks[player]
        if not firingTank then 
            return 
        end

        projectileData.Owner = player
        projectileData.MaxDamage = firingTank.Attributes.MaxDamage

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

        self.ExplosionService:SpawnExplosion(player, hitPosition, hitInstance, DEFAULT_RADIUS, projectile.MaxDamage)
    end)
end



return ProjectileService
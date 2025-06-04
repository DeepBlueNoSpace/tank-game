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


local DEFAULT_RADIUS = 25
local DEFAULT_DAMAGE = 100

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

    self.Client.ProjectileHit:Connect(function(player: Player, projectileId: string, hitPosition: Vector3)
        local projectile = self.LiveProjectiles[projectileId]
        assert(projectile, "Projectile not found")
        assert(projectile.Owner == player, "Player not owner of projectile") 

        self.ExplosionService:SpawnExplosion(player, hitPosition, DEFAULT_RADIUS, DEFAULT_DAMAGE)
    end)
end



return ProjectileService
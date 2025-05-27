local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Projectile = require(script.Projectile)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local ProjectileController = Knit.CreateController({ Name = "ProjectileController", LiveProjectiles = {}})

function ProjectileController:KnitInit()
    self.ServerTimeController = Knit.GetController("ServerTimeController")
end

function ProjectileController:KnitStart()

    RunService.Heartbeat:Connect(function() 
        self:UpdateProjectiles()
    end)
end

function ProjectileController:AddProjectile(isLocal: boolean, data: Types.ProjectileData)
    local projectile = Projectile.new(isLocal, data)
    self.LiveProjectiles[projectile.Id] = projectile

    return projectile
end

function ProjectileController:UpdateProjectiles()
    local serverTime: number = self.ServerTimeController:GetTime()

    for projectileId, projectile in self.LiveProjectiles do 
        local cleanUp = projectile:Update(serverTime)
        if cleanUp then 
            self.LiveProjectiles[projectileId] = nil
        end
    end
end


return ProjectileController
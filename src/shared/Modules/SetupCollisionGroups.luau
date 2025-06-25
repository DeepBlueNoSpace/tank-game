-- TankChassis
-- TankHitbox

local PhysicsService = game:GetService("PhysicsService")

--PhysicsService:RegisterCollisionGroup("TankChassis")
--PhysicsService:RegisterCollisionGroup("TankHitbox")
PhysicsService:RegisterCollisionGroup("TankBody") -- Default proxy

PhysicsService:RegisterCollisionGroup("NoTankCollision")
PhysicsService:CollisionGroupSetCollidable("NoTankCollision", "Default", false)
PhysicsService:CollisionGroupSetCollidable("NoTankCollision", "TankChassis", false)
PhysicsService:CollisionGroupSetCollidable("NoTankCollision", "TankHitbox", false)

return {}
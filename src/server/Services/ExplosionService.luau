local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Terrain = workspace.Terrain

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExplosionService = Knit.CreateService({ Name = "ExplosionService"})

local DEFAULT_PRESSURE = 350
local PHYSICS_RADIUS_MOD = 0.5
local TERRAIN_RADIUS_MOD = 0.1 

function ExplosionService:KnitInit()
	self.TankService = Knit.GetService("TankService")
	self.DamageService = Knit.GetService("DamageService")
end

function ExplosionService:DamageTanks(sender: Player, position: Vector3, radius: number, damage: number)
	--Damage tanks
	for _, tank in ipairs(CollectionService:GetTagged("Tank")) do
		local tankObject = self.TankService:GetTankFromModel(tank)
		if not tankObject then
			continue 
		end

		local isAlive = tank:GetAttribute("Alive") ::boolean
		if not isAlive then 
			continue 
		end
		
		local primary = tank.PrimaryPart or tank:FindFirstChild("PrimaryPart") or tank:FindFirstChildWhichIsA("BasePart")
		if not primary then continue end

		local distance = (primary.Position - position).Magnitude
		if distance > radius then continue end

		local health = tank:GetAttribute("Health")
		if health <= 0 then
			continue
		end

		warn('yeetimus', damage, distance, radius)
		local scaledDamage = damage * (1 - (distance / radius))
		tankObject:TakeDamage(scaledDamage, sender)
	end
end

function ExplosionService:DamageTerrain(position: Vector3, radius: number)
	Terrain:FillBall(position, radius*TERRAIN_RADIUS_MOD, Enum.Material.Air)
end


local function isValidPart(part)
	local current = part

	while current do
		if current:IsA("Model") then
			if CollectionService:HasTag(current, "Tank") then
				return false
			end
			if current:FindFirstChildOfClass("Humanoid") then
				return false
			end
		end
		current = current.Parent
	end

	return true
end

function ExplosionService:DoPhysicsDamage(position: Vector3, radius: number)
	radius *= PHYSICS_RADIUS_MOD

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { workspace }

	local parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)
	local filteredParts = {}
	for _, part in ipairs(parts) do
		if isValidPart(part) then
			table.insert(filteredParts, part)
		end
	end
	parts = filteredParts

	for _, part in ipairs(parts) do
		for _, constraint in ipairs(part:GetDescendants()) do
			if constraint:IsA("Weld") or constraint:IsA("WeldConstraint") or constraint:IsA("Motor6D") then
				constraint:Destroy()
			end
		end
	end

	task.wait()

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and not part.Anchored then
			local direction = (part.Position - position).Unit
			local distance = (part.Position - position).Magnitude
			local falloff = math.clamp(1 - (distance / radius), 0, 1)

			local force = direction * DEFAULT_PRESSURE * falloff
			part:ApplyImpulse(force * part.AssemblyMass)
		end
	end
end



function ExplosionService:SpawnExplosion(sender: Player, position: Vector3, radius: number, damage: number)
	self:DamageTanks(sender, position, radius, damage)
	self:DamageTerrain(position, radius) 
	self:DoPhysicsDamage(position, radius)	
end

return ExplosionService
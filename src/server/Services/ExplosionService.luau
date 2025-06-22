--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Terrain = workspace.Terrain

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExplosionService = Knit.CreateService({ Name = "ExplosionService"})

local DEFAULT_PRESSURE = 300
local PHYSICS_RADIUS_MOD = 0.8
local TERRAIN_RADIUS_MOD = 0.2

function ExplosionService:KnitInit()
	self.TankService = Knit.GetService("TankService")
	self.DamageService = Knit.GetService("DamageService")
	self.DestructionService = Knit.GetService("DestructionService")
end

local SIDE_NORMALS = {
	Front = Vector3.new(0, 0, -1),
	Back = Vector3.new(0, 0, 1),
	Left = Vector3.new(-1, 0, 0),
	Right = Vector3.new(1, 0, 0),
	Top = Vector3.new(0, 1, 0),
	Bottom = Vector3.new(0, -1, 0),
}


local function GetHitSide(tank: Model, hitboxParts: {BasePart}, position: Vector3): (string?, number)
	local modelCFrame, _ = tank:GetBoundingBox()
	local toExplosion = (position - modelCFrame.Position).Unit

	local bestPartName = nil
	local bestDot = -math.huge
	local bestDistance = math.huge

	for _, part in hitboxParts do
		if part:IsA("BasePart") then
			local sideName = part.Name
			local baseNormal = SIDE_NORMALS[sideName]
			if baseNormal then
				local worldNormal = modelCFrame:VectorToWorldSpace(baseNormal)
				local dot = worldNormal:Dot(toExplosion)
				local distance = (part.Position-position).Magnitude
				if (dot+0.1) >= bestDot and distance<bestDistance then
					bestDot = dot
					bestPartName = sideName
					bestDistance = distance
				end
			end
		end
	end

	return bestPartName, bestDistance
end

function ExplosionService:GetHitboxesInLOS(hitboxParts: {BasePart}, tankModel: Model, origin: Vector3): {BasePart}
	local hitboxesInLOS = {}

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {tankModel}
	rayParams.IgnoreWater = true

	for _, part in ipairs(hitboxParts) do
		local direction = part.Position - origin
		local rayResult = workspace:Raycast(origin, direction, rayParams)

		-- if the ray hits nothing or hits the part itself, it's in LOS
		--it will never hit the part itself as its in a different collision group
		if not rayResult or rayResult.Instance == nil then
			table.insert(hitboxesInLOS, part)
		end
	end

	return hitboxesInLOS
end

function ExplosionService:DamageTanks(sender: Player, position: Vector3, hitInstance: BasePart?, radius: number, damage: number)
	for _, tank in ipairs(CollectionService:GetTagged("Tank")) do
		local tankObject = self.TankService:GetTankFromModel(tank)
		if not tankObject then continue end

		if not tank:GetAttribute("Alive") then continue end

		local primary = tank.PrimaryPart or tank:FindFirstChild("PrimaryPart") or tank:FindFirstChildWhichIsA("BasePart")
		if not primary then continue end

		local health = tank:GetAttribute("Health")
		if health <= 0 then continue end

		local hitboxFolder = tank:FindFirstChild("Hitbox")
		local eligableHitboxParts = self:GetHitboxesInLOS(hitboxFolder:GetChildren(), tankObject.Model, position)

		local bestPartName, distance = GetHitSide(tank, eligableHitboxParts, position)
		if distance > radius then 
			continue 
		end
	
		if not bestPartName then 
			continue 
		end

		if hitInstance and hitInstance.Parent == tank.Hitbox then 
			tankObject:TakeDamage(damage, sender, hitInstance.Name, true)
			continue
		end
		
		local scaledDamage = damage * (1 - (distance / radius))
		tankObject:TakeDamage(scaledDamage, sender, bestPartName)
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


	task.wait()
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and not part.Anchored then
			local direction = (part.Position - position).Unit
			local distance = (part.Position - position).Magnitude
			local falloff = math.clamp(1 - (distance / radius), 0, 1)

			local force = direction * DEFAULT_PRESSURE * falloff
			part:ApplyImpulse(force)
		end
	end

	self.DestructionService:DestroyParts(position, radius, DEFAULT_PRESSURE)
end



function ExplosionService:SpawnExplosion(sender: Player, position: Vector3, hitInstance: BasePart?, radius: number, damage: number)
	--Hit isntance could be nil if it exploded when it ran out of range
	self:DamageTanks(sender, position, hitInstance, radius, damage)
	self:DamageTerrain(position, radius) 
	self:DoPhysicsDamage(position, radius)	
end

return ExplosionService
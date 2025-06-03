local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Terrain = workspace.Terrain

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExplosionService = Knit.CreateService({ Name = "ExplosionService"})

function ExplosionService:KnitInit()
	self.TankService = Knit.GetService("TankService")
end

function ExplosionService:DamageTanks(sender: Player, position: Vector3, radius: number, damage: number)
	--Damage tanks
	for _, tank in ipairs(CollectionService:GetTagged("Tank")) do
		local primary = tank.PrimaryPart or tank:FindFirstChild("PrimaryPart") or tank:FindFirstChildWhichIsA("BasePart")
		if not primary then continue end

		local distance = (primary.Position - position).Magnitude
		if distance > radius then continue end

		local health = tank:GetAttribute("Health")
		if health <= 0 then
			continue
		end

		local scaledDamage = damage * (1 - (distance / radius))
		local tankObject = self.TankService:GetTankFromModel(tank)
		tankObject:TakeDamage(scaledDamage, sender)
	end
end

local DEFAULT_PRESSURE = 350

function ExplosionService:SpawnExplosion(sender: Player, position: Vector3, radius: number, damage: number)
	self:DamageTanks(sender, position, radius, damage)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { workspace }

	local parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and not part.Anchored then
			-- Check if this part belongs to a tagged "Tank" model
			local inTank = false
			local ancestor = part
			while ancestor do
				if ancestor:IsA("Model") and CollectionService:HasTag(ancestor, "Tank") then
					inTank = true
					break
				end
				ancestor = ancestor.Parent
			end

			-- Only destroy welds if NOT in a Tank
			if not inTank then
				for _, constraint in ipairs(part:GetDescendants()) do
					if constraint:IsA("Weld") or constraint:IsA("WeldConstraint") or constraint:IsA("Motor6D") then
						constraint:Destroy()
					end
				end
			end
		end
	end

	-- Clear terrain in area
	Terrain:FillBall(position, radius, Enum.Material.Air)

	task.wait()

	-- Apply physics forces
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

return ExplosionService


--[[

function ExplosionService:SpawnExplosion(position: Vector3, radius: number, blastPressure: number)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { workspace }

	local parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)

	--Break welds
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and part.Anchored == false then
			for _, constraint in ipairs(part:GetDescendants()) do
				if constraint:IsA("Weld") or constraint:IsA("WeldConstraint") or constraint:IsA("Motor6D") then
					constraint:Destroy()
				end
			end
		end
	end


	Terrain:FillBall(position, radius, Enum.Material.Air)
	
	task.wait()

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and part.Anchored == false then
			local direction = (part.Position - position).Unit
			local distance = (part.Position - position).Magnitude
			local falloff = math.clamp(1 - (distance / radius), 0, 1)

			local force = direction * blastPressure * falloff
			part:ApplyImpulse(force * part.AssemblyMass)
		end
	end

end]]
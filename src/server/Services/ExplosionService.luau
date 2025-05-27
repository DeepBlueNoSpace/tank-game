local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Terrain = workspace.Terrain

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExplosionService = Knit.CreateService({ Name = "ExplosionService"})

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

	--Do physics
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and part.Anchored == false then
			local direction = (part.Position - position).Unit
			local distance = (part.Position - position).Magnitude
			local falloff = math.clamp(1 - (distance / radius), 0, 1)

			local force = direction * blastPressure * falloff
			part:ApplyImpulse(force * part.AssemblyMass)
		end
	end

end

return ExplosionService



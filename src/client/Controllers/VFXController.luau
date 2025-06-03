local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFX = ReplicatedStorage.Assets.VFX 

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Trove = require(Knit.Packages.Trove)

local VFXController = Knit.CreateController({ Name = "VFXController"})

function VFXController:KnitInit()
    
end

local function scaleParticleSize(particle, factor: number)
	if not particle:IsA("ParticleEmitter") then return end

	local oldSize = particle.Size
	local newKeypoints = {}
	for _, keypoint in ipairs(oldSize.Keypoints) do
		table.insert(newKeypoints, NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * factor,
			keypoint.Envelope * factor
		))
	end
	particle.Size = NumberSequence.new(newKeypoints)
end


function VFXController:SpawnVFX(vfxType: string, info: Types.VFXInfo)
    info = (info or {}) :: Types.VFXInfo

    local vfxTrove = Trove.new() 

    local baseVFX = VFX[vfxType]
    local effectParent = nil
    
    --If a parent and not a CFrame is provided, make a fake part 
    if info.CFrame then 
        -- for some reason if this is an attachment it breaks some particleemitters idk why 
        effectParent = vfxTrove:Add(Instance.new("Part"))
        effectParent.Parent = workspace 
        effectParent.CFrame = info.CFrame
        effectParent.Anchored = true 
        effectParent.CanCollide = false 
        effectParent.Transparency =1 
    elseif info.Parent then 
        effectParent = info.Parent
    else 
        assert("No parent for VFX", vfxType)
    end


    local despawnTime = 0 

    for _, object: ParticleEmitter | Sound in baseVFX:GetDescendants() do 
        --Handle sounds
        if object:IsA("Sound") then 
            local clone = object:Clone()
            clone.Parent = effectParent
            clone.PlayOnRemove = true 
            clone:Destroy()
            continue
        end

        --If its not a particle emiiter we don't care
        if not object:IsA("ParticleEmitter") then 
            continue 
        end

        local clone = object:Clone() :: ParticleEmitter

        --Apply other info bits 
        local scaleSize = info.ScaleSize
        if scaleSize then 
            scaleParticleSize(clone, scaleSize)
        end

        --Make sure all effects display in their entirity before we delete them
        if clone.Lifetime.Max > despawnTime then 
            despawnTime = clone.Lifetime.Max
        end

        --Emit :D
        clone.Parent = effectParent
        clone:Emit(clone.Rate)
    end

    task.delay(despawnTime, function() 
        --vfxTrove:Destroy()
    end)
end

return VFXController
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFX = ReplicatedStorage.Assets.VFX 

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Trove = require(Knit.Packages.Trove)

local VFXController = Knit.CreateController({ Name = "VFXController"})

function VFXController:KnitInit()
    self.VFXService = Knit.GetService("VFXService")
end

function VFXController:KnitStart()
    self.VFXService.TransmitEffect:Connect(function(vfxType: string, info: Types.VFXInfo)
        if info.Parent == nil and info.CFrame == nil then 
            return 
        end

        self:SpawnVFX(vfxType, info)
    end)
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

local function PlaySoundByRemoving(sound: Sound, newParent: Instance)
    local newSound = sound:Clone()
    newSound.Parent = newParent
    newSound.PlayOnRemove = true 
    newSound:Destroy()
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
        effectParent.CanQuery = false
        effectParent.Anchored = true 
        effectParent.CanCollide = false 
        effectParent.Transparency =1 
    elseif info.Parent then 
        effectParent = info.Parent
    else 
        assert("No parent for VFX", vfxType)
    end


    local despawnTime = 0 

    if info.SoundSource then 
        local selectedSound = info.SoundSource:GetChildren()[math.random(1,#info.SoundSource:GetChildren())]
        PlaySoundByRemoving(selectedSound, effectParent)        
    end

    for _, object: ParticleEmitter | Sound in baseVFX:GetDescendants() do 
        --Handle sounds
        if object:IsA("Sound") then 
            PlaySoundByRemoving(object, effectParent)    
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
--[[
VFX TESTER

for _, object in game:GetService("Selection"):Get()[1]:GetChildren() do 
    object:Emit(object.Rate)
end
]]
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local VoxBreaker = require(ReplicatedStorage.Shared.Modules.VoxBreaker)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DestructionService = Knit.CreateService({ Name = "DestructionService", LiveParts = {}})

local MAX_PARTS = 500

function DestructionService:KnitInit()
	self.TankService = Knit.GetService("TankService")
	self.DamageService = Knit.GetService("DamageService")
end

function DestructionService:KnitStart()
    for _, model in CollectionService:GetTagged("Destructible") do 
        for _, x in model:GetDescendants() do 
            if x:IsA("BasePart") then 
                x:SetAttribute("Destroyable", true)

            end
        end
    end
    CollectionService:GetInstanceAddedSignal("Destructible"):Connect(function(model: Model)
        for _, x in model:GetDescendants() do 
            if x:IsA("BasePart") then 
                x:SetAttribute("Destroyable", true)
            end
        end
    end)

    
end

function DestructionService:DestroyParts(position: Vector3, radius: number, blastPressure: number)
    local Voxels = VoxBreaker:CreateHitbox(Vector3.new(radius,radius,radius), CFrame.new(position), Enum.PartType.Ball, 2)

    for _, x in pairs(Voxels) do
        if math.random() < 0.6 then -- destroy roughly 60% of the voxels
            x:Destroy()
        else
            x:SetAttribute("Destroyable", false)
            x.Anchored = false
            
            local direction = (x.Position - position).Unit
			local distance = (x.Position - position).Magnitude
            local falloff = math.clamp(1 - (distance / radius), 0, 1)

            x:ApplyImpulse(direction * blastPressure * falloff)

            table.insert(self.LiveParts, x)
        end
    end

    local livePartCount = #self.LiveParts
    local delta = livePartCount-MAX_PARTS

    if delta > 0 then 
        for _ = 1, delta do 
            self.LiveParts[1]:Destroy()
            table.remove(self.LiveParts, 1)
        end
    end
end

return DestructionService
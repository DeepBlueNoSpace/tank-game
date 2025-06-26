local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Runservice = game:GetService("RunService")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalSaveReplica = nil

local HealtherDropController = Knit.CreateController { Name = "HealthDropController" }

function HealtherDropController:_initHealthDrop(model: Model)
    local medkit = model:FindFirstChild("FloatingMesh")
    local clone = medkit:Clone()
    clone.Parent = medkit.Parent
    medkit:Destroy()
    medkit = clone

    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.Position = model.PrimaryPart.Position
    bodyPosition.Parent = medkit

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = model.PrimaryPart.CFrame
    bodyGyro.Parent = medkit

    medkit.Anchored = false

    local rot = 0
    local y = 0
    local hb = Runservice.Heartbeat:Connect(function(dt)
        y += dt
        rot += dt
        local cf = CFrame.new(model.PrimaryPart.Position + Vector3.new(0,math.sin(y)*2,0)) * CFrame.Angles(0, rot, 0)
        bodyPosition.Position = cf.Position
        bodyGyro.CFrame = cf
    end)

    model.Destroying:Connect(function()
        hb:Disconnect()
    end)
end

function HealtherDropController:Pickup(model: Model)
    self.HealthDropService:RequestPickupHealthDrop(model)
    -- assume it worked...
    model:Destroy()
    game:GetService("SoundService"):PlayLocalSound(ReplicatedStorage.Assets.Sound.MedkitPickedUp)

end

function HealtherDropController:KnitInit()
    self.HealthDropService = Knit.GetService("HealthDropService")
end

function HealtherDropController:KnitStart()
    for i,v in pairs(CollectionService:GetTagged("HealthDropHitbox")) do
        self:_initHealthDrop(v.Parent)
    end

    CollectionService:GetInstanceAddedSignal("HealthDropHitbox"):Connect(function(hitbox)
        self:_initHealthDrop(hitbox.Parent)
    end)
end


return HealtherDropController

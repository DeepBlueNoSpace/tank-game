local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local HealthDropService = Knit.CreateService {
    Name = "HealthDropService",
    Client = {},
}


function HealthDropService:SpawnHealthDrop(position: Vector3, healthAward: number)
    healthAward = healthAward or 500

    local healthDrop = ReplicatedStorage.Assets.HealthDrop:Clone()
    healthDrop:SetPrimaryPartCFrame(CFrame.new(position))
    healthDrop:SetAttribute("HealthAward", 500) -- Set initial health value
    healthDrop.PrimaryPart.Transparency = 1
    
    healthDrop.Parent = workspace.RuntimeContent.Drops
end

function HealthDropService:PickupHealthDrop(model: Model, tank)
    if not model or not model.PrimaryPart or not model.PrimaryPart:HasTag("HealthDropHitbox") then
        warn("HealthDropService:PickupHealthDrop - Invalid model or not a health drop hitbox")
        return
    end

    local healthAward = model:GetAttribute("HealthAward")
    local newHealth = tank.Model:GetAttribute("Health") + healthAward
    tank.Model:SetAttribute("Health", math.min(newHealth, tank.Model:GetAttribute("MaxHealth")))

    model:Destroy()
end

function HealthDropService.Client:RequestPickupHealthDrop(player, model: Model)
    if not model or typeof(model) ~= "Instance" or not model.Parent or not model.PrimaryPart or not model.PrimaryPart:HasTag("HealthDropHitbox") then
        warn("HealthDropService.Client:RequestPickupHealthDrop - Invalid model or not a health drop hitbox")
        return
    end

    local playerTank = HealthDropService.TankService:GetServerTank(player)
    if (playerTank.Model.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude > 50 then
        warn("HealthDropService.Client:RequestPickupHealthDrop - Player is too far from the health drop")
        return
    end

    self.Server:PickupHealthDrop(model, playerTank)
end

function HealthDropService:KnitInit()
    self.TankService = Knit.GetService("TankService")
end


function HealthDropService:KnitStart()
    
end


return HealthDropService

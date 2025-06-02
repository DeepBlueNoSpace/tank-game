local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets 

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(Knit.Packages.Trove)

local TankBillboardController = Knit.CreateController({ Name = "TankBillboardController", 
    IndexedTanks = {} :: {[Model]:{}} })

function TankBillboardController:KnitInit() 

end

function TankBillboardController:KnitStart()
    for _, tank: Model in CollectionService:GetTagged("Tank") do 
        self:IndexTank(tank)
    end

    CollectionService:GetInstanceAddedSignal("Tank"):Connect(function(tank:Model)
        self:IndexTank(tank)
    end)
end

function TankBillboardController:IndexTank(tank: Model)
    if tank:GetAttribute("OwnerName") == Player.Name then 
        return 
    end
    
    local billboardTrove = Trove.new() 

    local attachment = billboardTrove:Add(Assets.Attachments.TankBillboard:Clone())
    attachment.Parent = tank:WaitForChild("Chassis"):WaitForChild("VehicleSeat")
    
    
    local healthFill = attachment.BillboardGui.Health.Fill 
    local _teamColor = attachment.BillboardGui.TeamColor 
    local _ownerLabel = attachment.BillboardGui.Owner 


    local function updateHealth()
        local health = tank:GetAttribute("Health") ::number 
        local maxHealth = tank:GetAttribute("MaxHealth") ::number 
        healthFill.Size = UDim2.fromScale(health/maxHealth, 1)
    end

    updateHealth()
    billboardTrove:Add(tank:GetAttributeChangedSignal("Health"):Connect(updateHealth))-- this must be in trove cuz the model will persist.
end

return TankBillboardController
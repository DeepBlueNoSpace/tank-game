--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage.Assets 

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Types = require(ReplicatedStorage.Shared.Data.Types)

type TankBillboardData = {
    Billboard: BillboardGui,
    Trove: Types.Trove
}

local TankBillboardController = Knit.CreateController({ Name = "TankBillboardController", 
    IndexedTanks = {} :: {[Model]:TankBillboardData} })


local SEE_NAME_DISTANCE = 200

function TankBillboardController:KnitInit() 

end

function TankBillboardController:KnitStart()
    for _, tank: Model in CollectionService:GetTagged("Tank") do 
        self:IndexTank(tank)
    end

    CollectionService:GetInstanceAddedSignal("Tank"):Connect(function(tank:Model)
        self:IndexTank(tank)
    end)

    CollectionService:GetInstanceRemovedSignal("Tank"):Connect(function(tank:Model)
        local tankData = self.IndexedTanks[tank]
        if tankData then 
            tankData.Trove:Destroy()
        end
    end)


    RunService.Heartbeat:Connect(function() 
        local character = GetSafeCharacter()
        local playerPosition 
        if character then 
            playerPosition = character:GetPivot().Position
        end

        for tank: Model, data: {} in self.IndexedTanks do 
            local removeIndex = self:UpdateTankBillboard(tank, data, playerPosition)
            if removeIndex then 
                self.IndexedTanks[tank] = nil
            end
        end
    end)
end

function TankBillboardController:UpdateTankBillboard(tank: Model, data: TankBillboardData, playerPosition: Vector3?) :boolean
    if tank:GetAttribute("Alive") == false then 
        data.Trove:Destroy()
        return true 
    end

    local ownerObject = Players:FindFirstChild(tank:GetAttribute("OwnerName"))
    if ownerObject then 
        local teamColorImage = data.Billboard:FindFirstChild("TeamColor") :: Frame

        if ownerObject.Team == Player.Team then 
           teamColorImage.BackgroundColor3 = Color3.fromRGB(255,255,255)
        else
            teamColorImage.BackgroundColor3 = Color3.fromRGB(255, 133, 133)
        end
    end

    local makeVisible = false 
    if playerPosition then 
        local distance = (playerPosition-tank:GetPivot().Position).Magnitude
        makeVisible = distance < SEE_NAME_DISTANCE
    end

    local healthFrame = data.Billboard:FindFirstChild("Health") :: Frame
    local ownerLabel = data.Billboard:FindFirstChild("Owner") :: TextLabel

    ownerLabel.Visible = makeVisible
    healthFrame.Visible = makeVisible

    return false
end

function TankBillboardController:IndexTank(tank: Model)
    if tank:GetAttribute("OwnerName") == Player.Name then 
        return 
    end
    
    local billboardTrove = Trove.new() 

    local attachment = billboardTrove:Add(Assets.Attachments.TankBillboard:Clone())
    attachment.Parent = tank:WaitForChild("Chassis"):WaitForChild("VehicleSeat")
    
    
    local healthFill = attachment.BillboardGui.Health.Fill 
    local ownerLabel = attachment.BillboardGui.Owner 


    local function updateHealth()
        local health = tank:GetAttribute("Health") ::number 
        local maxHealth = tank:GetAttribute("MaxHealth") ::number 
        healthFill.Size = UDim2.fromScale(health/maxHealth, 1)
    end

    updateHealth()
    billboardTrove:Add(tank:GetAttributeChangedSignal("Health"):Connect(updateHealth))-- this must be in trove cuz the model will persist.

    ownerLabel.Text = tank:GetAttribute("OwnerName")
    
    self.IndexedTanks[tank] = {
        Billboard = attachment.BillboardGui,
        Trove = billboardTrove
    }
end

return TankBillboardController
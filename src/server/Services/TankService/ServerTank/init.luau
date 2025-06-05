--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankPrefabs = ReplicatedStorage.Assets.Tanks

local ServerTank = {}
ServerTank.__index = ServerTank


function ServerTank.new(driver: Player, tankType: string) 
    local self = setmetatable({}, ServerTank)

    --Variables
    self.TankService = Knit.GetService("TankService")
    self.Trove = Trove.new() 

    self.Type = tankType :: string 

    self.TankData = TankData[self.Type] :: Types.TankData
    self.Character = driver.Character :: Model
    self.Model = self.Trove:Add(TankPrefabs[tankType]:Clone()) :: Model
    self.Chassis = self.Model:FindFirstChild("Chassis") :: Model 
    self.Seat = self.Chassis:FindFirstChild("VehicleSeat") :: VehicleSeat
    self.Driver = driver :: Player
    self.Constraints = self.Model:FindFirstChild("Constraints") :: Folder 

    self.Alive = true :: boolean

    --Set up
    local hrp = self.Character:WaitForChild("HumanoidRootPart") :: BasePart
    self.Model.Name = driver.Name
    self.Model.Parent = workspace:WaitForChild("Tanks")
    
    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    self.Model:PivotTo(spawnCFrame)

    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(driver)

    local tankSeat = self.Seat
    local humanoid = self.Character:FindFirstChild("Humanoid") :: Humanoid
    tankSeat:Sit(humanoid)
    
    self:SetUpAttributes()
    self.Trove:Add(humanoid.Died:Connect(function() 
        self:Disable()
    end))

    task.wait(1)-- let it replicate. this feels risky
    --TODO: add check here to see if we should still send the tank?
    return self
end

--Tank tag is only added once its ready for clients to listen to it
function ServerTank:SetUpAttributes()
    self.Model:SetAttribute("Health", self.TankData.Health)
    self.Model:SetAttribute("MaxHealth", self.TankData.Health)
    self.Model:SetAttribute("OwnerName", self.Driver.Name)

    self.Model:AddTag("Tank")
end

function ServerTank:EndClientPhysics()
    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(nil)
    task.wait()
    primaryPart.AssemblyAngularVelocity = Vector3.zero
    primaryPart.AssemblyLinearVelocity = Vector3.zero
end

function ServerTank:Disable(waitTime: number?)
    --Flow:
    --disabled (so its not alive now) --> wait --> clean
    --Only time disable shouldnt be called first is when the round is over or the player leaves.
    local actualWaitTime = waitTime or 5 :: number

    self.Alive = false
    self.Character:Destroy()
    self.TankService.Client.DestroyClientTank:Fire(self.Driver)

    self:EndClientPhysics()
    
    task.wait(actualWaitTime)
    self.Driver:LoadCharacter()

    task.wait(actualWaitTime*10) -- a long death is cool
    self:Destroy()

end

function ServerTank:Destroy()
    self.TankService:RemovePlayersTankIndex(self.Driver, self)
    self.Trove:Destroy()
end


function ServerTank:TakeDamage(damage: number, sender: Player?)
    local newHealth = self.Model:GetAttribute("Health")-damage

    if newHealth <= 0 then 
        if self.Alive then
            Knit.GetService("GameLoopService"):ReportKill(sender, self.Driver)
        end

        self.Model:SetAttribute("Health", 0)
        self:Disable()
        return
    end

    self.Model:SetAttribute("Health", newHealth)
end


return ServerTank
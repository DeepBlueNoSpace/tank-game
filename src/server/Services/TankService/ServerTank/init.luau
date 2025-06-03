local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(Knit.Packages.Trove)

local ServerTank = {}
ServerTank.__index = ServerTank


function ServerTank.new(driver: Player) 
    local self = setmetatable({}, ServerTank)
    self.TankService = Knit.GetService("TankService")
    self.Trove = Trove.new() 

    self.Character = driver.Character :: Model
    self.Model = self.Trove:Add(ReplicatedStorage.Tank:Clone()) :: Model
    self.Chassis = self.Model.Chassis :: Model 
    self.Seat = self.Chassis.VehicleSeat :: VehicleSeat
    self.Driver = driver :: Player
    self.Constraints = self.Model.Constraints :: Folder 

    self.Alive = true 

    local hrp = self.Character:WaitForChild("HumanoidRootPart")
    self.Model.Name = driver.Name
    self.Model.Parent = workspace:WaitForChild("Tanks")
    
    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    self.Model:SetPrimaryPartCFrame(spawnCFrame)
    self.Model.PrimaryPart:SetNetworkOwner(driver)

    local tankSeat = self.Model.Chassis.VehicleSeat
    tankSeat:Sit(self.Character.Humanoid)
    
    self:SetUpAttributes()
    task.wait(1)-- let it replicate. this feels risky

    self.Trove:Add(self.Character.Humanoid.Died:Connect(function() 
        self:Disable()
    end))
    return self
end

--Tank tag is only added once its ready for clients to listen to it
function ServerTank:SetUpAttributes()
    self.Model:SetAttribute("Health", 1000)
    self.Model:SetAttribute("MaxHealth", 1000)
    self.Model:SetAttribute("OwnerName", self.Driver.Name)

    self.Model:AddTag("Tank")
end

function ServerTank:EndClientPhysics()
    self.Model.PrimaryPart:SetNetworkOwner(nil)
    task.wait()
    self.Model.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
    self.Model.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
end

function ServerTank:Disable(waitTime)
    --Flow:
    --disabled (so its not alive now) --> wait --> clean
    --Only time disable shouldnt be called first is when the round is over or the player leaves.
    waitTime = waitTime or 5
    self.Alive = false
    self.Character:Destroy()
    self.TankService.Client.DestroyClientTank:Fire(self.Driver)
    self:EndClientPhysics()
    
    task.wait(waitTime)
    self.Driver:LoadCharacter()

    task.wait(waitTime*10) -- a long death is cool
    self:Destroy()

end

function ServerTank:Destroy()
    self.TankService:RemovePlayersTankIndex(self.Driver)
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
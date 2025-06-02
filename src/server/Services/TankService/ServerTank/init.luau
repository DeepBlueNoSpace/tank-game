local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ServerTank = {}
ServerTank.__index = ServerTank


function ServerTank.new(driver: Player) 
    local self = setmetatable({}, ServerTank)
    self.TankService = Knit.GetService("TankService")

    self.Character = driver.Character :: Model
    self.Model = ReplicatedStorage.Tank:Clone() :: Model
    self.Chassis = self.Model.Chassis :: Model 
    self.Seat = self.Chassis.VehicleSeat :: VehicleSeat
    self.Driver = driver :: Player

    self.Alive = true 

    local hrp = self.Character:WaitForChild("HumanoidRootPart")
    self.Model.Parent = workspace

    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    self.Model:SetPrimaryPartCFrame(spawnCFrame)
    self.Model.PrimaryPart:SetNetworkOwner(driver)

    local tankSeat = self.Model.Chassis.VehicleSeat
    tankSeat:Sit(self.Character.Humanoid)
    
    self:SetUpAttributes()
    task.wait(1)-- let it replicate. this feels risky
    return self
end

--Tank tag is only added once its ready for clients to listen to it
function ServerTank:SetUpAttributes()
    self.Model:SetAttribute("Health", 200)
    self.Model:SetAttribute("MaxHealth", 200)
    self.Model:SetAttribute("OwnerName", 200)

    self.Model:AddTag("Tank")
end

function ServerTank:Disable()
    --Flow goes disabled (so its not alive now), waits a bit, then cleans itself up
    self.Alive = false
    self.Character:Destroy()
    print'hello'
    self.TankService.Client.DestroyClientTank:Fire(self.Driver)
    task.wait(3)
    self:Destroy()
    self.Driver:LoadCharacter()
end

function ServerTank:Destroy()
    self.TankService:RemovePlayersTankIndex(self.Driver)
end


function ServerTank:TakeDamage(damage: number)
    local newHealth = self.Model:GetAttribute("Health")-damage
    if newHealth < 0 then 
        self.Model:SetAttribute("Health", 0)
        self:Disable()
        return 
    end

    self.Model:SetAttribute("Health", newHealth)
end


return ServerTank
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerTank = {}
ServerTank.__index = ServerTank


function ServerTank.new(driver: Player) 
    local self = setmetatable({}, ServerTank)
    self.Character = driver.Character 
    self.Model = ReplicatedStorage.Tank:Clone()
    self.Chassis = self.Model.Chassis
    self.Seat = self.Chassis.VehicleSeat

    local hrp = self.Character:WaitForChild("HumanoidRootPart")

     self.Model.Parent = workspace

    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    self.Model:SetPrimaryPartCFrame(spawnCFrame)
    self.Model.PrimaryPart:SetNetworkOwner(driver)

    local tankSeat =  self.Model.Chassis.VehicleSeat
    tankSeat:Sit(self.Character.Humanoid)
    
    return self
end


return ServerTank
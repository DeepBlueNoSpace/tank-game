local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ClientTank = require(script.ClientTank)

local TankController = Knit.CreateController({ Name = "TankController" })

function TankController:KnitInit()
    self.TankService = Knit.GetService("TankService")
    
end

function TankController:KnitStart()
    spawn(function() 
        wait(1)
        self:InitTank()
        Player.CharacterAdded:Connect(function() 
            self:InitTank()
        end)
    end)
end


function TankController:FireLocalTank() 
    
end

function TankController:InitTank()
    self.TankService:RequestTank():andThen(function(tank)
        self.Tank = ClientTank.new(tank) 
    end)
end

return TankController
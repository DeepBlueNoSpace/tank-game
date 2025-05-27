local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankController = Knit.CreateController({ Name = "TankController" })

function TankController:KnitInit()
    self.TankService = Knit.GetService("TankService")
end

function TankController:KnitStart()

    local lastShot = 0
    UserInputService.InputBegan:Connect(function(inputObject: InputObject)
        if tick() - lastShot < 1 then 
            return 
        end
        lastShot = tick()
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.TankService:Fire(self.Tank)
        end
    end)

    spawn(function() 
        wait(3)
        self:InitTank()
        Player.CharacterAdded:Connect(function() 
            self:InitTank()
        end)
    end)
end
function TankController:InitTank()
    self.TankService:RequestTank():andThen(function(tank)
        self.Tank = tank 

        local turret = tank:WaitForChild("Turret")
        local rotator = turret:WaitForChild("Rotator")
        local barrelHinge: HingeConstraint = rotator:WaitForChild("BarrelHinge")
        local rotatorServo: HingeConstraint = turret:WaitForChild("Base"):WaitForChild("RotatorServo")
        local basePart = turret.Base

        local barrelEnd = tank:FindFirstChild("BarrelEnd", true) :: Attachment?
        if not barrelEnd then return end


        local x = Player:WaitForChild("PlayerGui"):WaitForChild("UI"):WaitForChild("Frame")

        local bind = RunService.Heartbeat:Connect(function()
            local camera = workspace.CurrentCamera
            local mouseRay = camera:ScreenPointToRay(Mouse.X, Mouse.Y)
            x.Position = UDim2.fromScale(Mouse.X, Mouse.Y)
            local rayOrigin = mouseRay.Origin
            local rayDirection = mouseRay.Direction * 1000

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {self.Tank}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
            local mouseHit = result and result.Position or (rayOrigin + rayDirection)

            -- ROTATION (Yaw) from base
            local turretPos = basePart.Position
            local worldDir = (mouseHit - turretPos).Unit
            local localDir = basePart.CFrame:VectorToObjectSpace(worldDir)
            local yaw = math.deg(math.atan2(-localDir.X, -localDir.Z))
            rotatorServo.TargetAngle = yaw

            -- PITCH from rotator
            local toTarget = (mouseHit - rotator.Position).Unit
            local pitchDir = rotator.CFrame:VectorToObjectSpace(toTarget)
            local pitch = math.deg(math.atan2(pitchDir.Y, -pitchDir.Z))
            barrelHinge.TargetAngle = pitch
        end)

        Player.Character.Humanoid.Died:Connect(function() 
            bind:Disconnect()
        end)
    end)
end

return TankController
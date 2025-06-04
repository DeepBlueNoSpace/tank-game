local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Spring = require(Knit.Modules.Spring)

local Camera = workspace.CurrentCamera

local TankCamera = {}
TankCamera.__index = TankCamera

local DEFAULT_Y_OFFSET = 4.5
local DEFAULT_Z_OFFSET = 30
local GAMEPAD_DEAD_ZONE = .1
local X_SENS_ADJUST = 0.05
local Y_SENS_ADJUST = -0.05 

function TankCamera.new(tank: {})
    local self = setmetatable({}, TankCamera)
    self.Tank = tank 
    self.CameraYaw = 0 
    self.CameraPitch = 0

    self.zSpring = Spring.new(0, 0, 30,0.5)
    self.ySpring = Spring.new(0, 0, 30,0.5)
 
    self.LastInputDelta = Vector2.new() 

    Camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false

    self.Tank.Trove:Add(RunService.Heartbeat:Connect(function(dT: number)
        self:Update(dT)
    end))

    self.Tank.Trove:Add(UserInputService.InputChanged:Connect(function(inputObject: InputObject)    
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            self.LastInputDelta  = inputObject.Delta
            return
        end

        if inputObject.UserInputType == Enum.UserInputType.Touch then
            local pos = inputObject.Position
            if pos.X < Camera.ViewportSize.X / 2 then
                return -- ignore input from the left side
            end
            self.LastInputDelta = inputObject.Delta * 2
            return
        end


        if inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
            local Temp = inputObject.Position
            if Temp.magnitude > GAMEPAD_DEAD_ZONE then
                self.LastInputDelta  = Vector2.new(Temp.X, -Temp.Y) * 6.5
            else
                self.LastInputDelta  = Vector2.new(0, 0)
            end
        end
    end))

    return self
end
local BARREL_ANG_VELOCITY = 60

local function moveToward(current, target, maxDelta)
    local delta = (target - current + 180) % 360 - 180 -- shortest angle difference
    if math.abs(delta) <= maxDelta then
        return target
    end
    return (current + math.sign(delta) * maxDelta + 180) % 360 - 180
end

function TankCamera:ApplyShotImpulse(force: number)
    self.zSpring:Accelerate(force*0.8)
    self.ySpring:Accelerate(force*0.2)
end


function TankCamera:UpdateBarrel(dT: number)
    local maxAngleChange = BARREL_ANG_VELOCITY * dT

    local camera = workspace.CurrentCamera
    local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y *0.35)
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * 1000

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {self.Tank}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    local hitPos = result and result.Position or (rayOrigin + rayDirection)

    -- Get turret base position
    local turretBasePos = self.Tank.Turret.Rotator.BarrelConnection.WorldPosition
    local toTarget = (hitPos - turretBasePos).Unit

    -- Compute yaw and corrected pitch
    local yaw = math.deg(math.atan2(-toTarget.X, -toTarget.Z))
    local flatDist = math.sqrt(toTarget.X^2 + toTarget.Z^2)
    local pitch = math.deg(math.atan2(toTarget.Y, flatDist))

    -- Smoothly move towards target yaw and pitch
    self.Tank.BarrelYaw = moveToward(self.Tank.BarrelYaw, yaw, maxAngleChange)
    self.Tank.BarrelPitch = moveToward(self.Tank.BarrelPitch, pitch, maxAngleChange)
end

function TankCamera:Update(dT: number)
    local basePosition = self.Tank.Seat.CameraPostion.WorldPosition
    local xAdjustment = X_SENS_ADJUST * self.LastInputDelta.X 
    local yAdjustment = Y_SENS_ADJUST * self.LastInputDelta.Y 

    self.CameraYaw = self.CameraYaw-xAdjustment
    self.CameraPitch = self.CameraPitch+yAdjustment

    local ySpringOffset = self.ySpring:Solve(dT)
    local xSpringOffset = self.zSpring:Solve(dT)

    Camera.CFrame = CFrame.new(basePosition) 
        * CFrame.Angles(0,math.rad(self.CameraYaw),0)
        * CFrame.Angles(math.rad(self.CameraPitch),0,0)
        * CFrame.new(0,DEFAULT_Y_OFFSET+ySpringOffset,DEFAULT_Z_OFFSET+xSpringOffset)

    self.LastInputDelta = Vector2.new()
    self:UpdateBarrel(dT)
end

function TankCamera:Destroy()
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

return TankCamera

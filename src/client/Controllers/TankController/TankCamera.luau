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

local DEFAULT_FOV = 70
local SCOPED_FOV = 50

local MIN_ZOOM = 0.5
local MAX_ZOOM = 2


function TankCamera.new(tank: {})
    local self = setmetatable({}, TankCamera)
    self.Tank = tank 
    self.CameraYaw = 0 
    self.CameraPitch = 0
    self.IsScoped = false 

    self.Zoom = 1 

    self.zSpring = Spring.new(0, 0, 30,0.5)
    self.ySpring = Spring.new(0, 0, 30,0.5)
    
    self.ScopeSpring = Spring.new(0, 0, 30,1)

    self.LastInputDelta = Vector2.new() 

    Camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false

    self.Heartbeat = self.Tank.Trove:Add(RunService.Heartbeat:Connect(function(dT: number)
        self:Update(dT)
    end))


    self.Tank.Trove:Add(UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent then return end
        if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            self.IsScoped = not self.IsScoped
            if self.IsScoped then 
                self.ScopeSpring:SetTarget(1)
            else
                self.ScopeSpring:SetTarget(0)
            end
        end
    end))

    self.Tank.Trove:Add(UserInputService.InputChanged:Connect(function(inputObject: InputObject)    
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            self.LastInputDelta  = inputObject.Delta
            return
        end

        if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
            local scrollAmount = inputObject.Position.Z/10
            self.Zoom = math.clamp(self.Zoom+scrollAmount,MIN_ZOOM,MAX_ZOOM)
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
    local maxAngleChange = self.Tank.TankData.BaseAtrributes.TurretAngularVelocity * dT

    local camera = workspace.CurrentCamera

    local yOffset = 0.35
    if self.IsScoped then 
        yOffset = 0.5
    end

    local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y * yOffset)
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * 1000

    local result = workspace:Raycast(rayOrigin, rayDirection, self.Tank.RaycastParamsIgnoreSelf)
    local hitPos = result and result.Position or (rayOrigin + rayDirection)
    
    local turretBasePos = self.Tank.Turret.Rotator.BarrelConnection.WorldPosition
    local toTarget = (hitPos - turretBasePos).Unit

    local yaw = math.deg(math.atan2(-toTarget.X, -toTarget.Z))
    local flatDist = math.sqrt(toTarget.X^2 + toTarget.Z^2)
    local pitch = math.deg(math.atan2(toTarget.Y, flatDist))

    -- Smoothly move towards target yaw and pitch
    self.Tank.BarrelYaw = moveToward(self.Tank.BarrelYaw, yaw, maxAngleChange)
    self.Tank.BarrelPitch = moveToward(self.Tank.BarrelPitch, pitch, maxAngleChange)
    return yaw, pitch
end

local MAX_PITCH = 15 
local MIN_PITCH = -60

function TankCamera:GetPopperCamPosition(basePosition: Vector3, targetPosition: Vector3): Vector3?
    local delta = targetPosition-basePosition
    
    local result = workspace:Raycast(basePosition, delta, self.Tank.RaycastParamsIgnoreSelf)
    if not result then 
        return nil 
    end

    return result.Position
end

function TankCamera:GetFreeCamUpdate(basePosition: Vector3, yOffset: number, xOffset: number)
    local targetCFrame = CFrame.new(basePosition) 
        * CFrame.Angles(0, math.rad(self.CameraYaw), 0)
        * CFrame.Angles(math.rad(self.CameraPitch), 0, 0)
        * CFrame.new(0, (DEFAULT_Y_OFFSET * self.Zoom) + yOffset, (DEFAULT_Z_OFFSET * self.Zoom) + xOffset)

    local popperPosition = self:GetPopperCamPosition(basePosition, targetCFrame.Position) :: Vector3
    if popperPosition then
        targetCFrame = CFrame.new(popperPosition) * CFrame.fromOrientation(targetCFrame:ToOrientation())
    end

    return targetCFrame
end

function TankCamera:GetScopedUpdate(basePosition: Vector3, yOffset: number, xOffset: number)
    local targetCFrame = CFrame.new(basePosition) 
        * CFrame.Angles(0, math.rad(self.CameraYaw), 0)
        * CFrame.Angles(math.rad(self.CameraPitch), 0, 0)
        * CFrame.new(0, yOffset, xOffset)

    return targetCFrame
end

local function lerp(v0:number,v1:number,t:number): number
    return v0+(v1-v0)*t 
end

function TankCamera:SetScopedProgress(progress)
    self.Tank.Model.Body.Turret.Transparency = progress
    self.Tank.TankGui.Scope.ImageTransparency = 1-progress
    self.Tank.TankGui.Crosshair.ImageTransparency = 1-progress
    for _, frame in self.Tank.TankGui.ScopeBacking do 
        if frame:IsA("Frame") then 
            frame.BackgroundTransparency = 1-progress
        end
    end

    for _, frame in self.Tank.TankGui.AimerHairs do 
        frame.BackgroundTransparency = progress
    end

    self.Tank.TankGui.Reticle.ImageTransparency = progress
    Camera.FieldOfView = lerp(DEFAULT_FOV, SCOPED_FOV, progress)
    self.Tank.TankGui.Crosshair.Position = self.Tank.TankGui.Aimer.Position
end

function TankCamera:Update(dT: number)
    local basePosition = self.Tank.Seat.CameraPostion.WorldPosition
    local xAdjustment = X_SENS_ADJUST * self.LastInputDelta.X 
    local yAdjustment = Y_SENS_ADJUST * self.LastInputDelta.Y 

    self.CameraYaw = self.CameraYaw - xAdjustment
    self.CameraPitch = math.clamp(self.CameraPitch + yAdjustment, MIN_PITCH, MAX_PITCH)

    local ySpringOffset = self.ySpring:Solve(dT)
    local xSpringOffset = self.zSpring:Solve(dT)

    self.LastInputDelta = Vector2.new()
    local _barrelYaw, _barrelPitch = self:UpdateBarrel(dT)

    local scopedPosition = self:GetScopedUpdate(basePosition,  ySpringOffset, xSpringOffset)
    local freecamPosition = self:GetFreeCamUpdate(basePosition, ySpringOffset, xSpringOffset)

    local scopeProgress = self.ScopeSpring:Solve(dT)
    Camera.CFrame = freecamPosition:Lerp(scopedPosition, scopeProgress)
    self:SetScopedProgress(scopeProgress)
end

function TankCamera:Destroy()
    self.Heartbeat:Disconnect()
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

return TankCamera

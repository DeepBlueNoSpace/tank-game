local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera

local TankCamera = {}
TankCamera.__index = TankCamera

local DEFAULT_Y_OFFSET = 6.5
local DEFAULT_Z_OFFSET = 22
local GAMEPAD_DEAD_ZONE = .1
local X_SENS_ADJUST = 0.05
local Y_SENS_ADJUST = -0.05 

function TankCamera.new(tank: {})
    local self = setmetatable({}, TankCamera)
    self.Tank = tank 
    self.CameraYaw = 0 
    self.CameraPitch = 0

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
          --  if inputObject.Position.X > CharacterStatus:GetScreenCenter().X then
                self.LastInputDelta  = inputObject.Delta * 1.15
           -- end
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

function TankCamera:Update(dT: number)
    local basePosition = self.Tank.Seat.CameraPostion.WorldPosition
    local xAdjustment = X_SENS_ADJUST * self.LastInputDelta.X 
    local yAdjustment = Y_SENS_ADJUST * self.LastInputDelta.Y 

    self.CameraYaw = self.CameraYaw-xAdjustment
    self.CameraPitch = self.CameraPitch+yAdjustment

    Camera.CFrame = CFrame.new(basePosition) 
        * CFrame.Angles(0,math.rad(self.CameraYaw),0)
        * CFrame.Angles(math.rad(self.CameraPitch),0,0)
        * CFrame.new(0,DEFAULT_Y_OFFSET,DEFAULT_Z_OFFSET)

    self.LastInputDelta = Vector2.new()
end

function TankCamera:Destroy()
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

return TankCamera

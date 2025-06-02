local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local MUZZLE_VELOCITY = 600 
local RECOIL_FORCE = 300

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(Knit.Packages.Trove)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local GetSafeCharacter = require(Knit.Modules.GetSafeCharacter)
local Chassis = require(script.Parent.Chassis)
local Keymap = require(script.Parent.Keymap)
local TankCamera = require(script.Parent.TankCamera)
local TankGui = require(script.Parent.TankGui)

local ClientTank = {}
ClientTank.__index = ClientTank

local _rawInput = Keymap.newInputTable()

local function _clearInput()
	for k, _ in pairs(_rawInput) do
		_rawInput[k] = 0
	end
end


function ClientTank.new(tankModel: Model)
    local self = setmetatable({}, ClientTank)

    local character = GetSafeCharacter() 
    if not character then 
        return 
    end

    --Knit controllers/services
    self.ProjectileController = Knit.GetController("ProjectileController")
    self.ServerTimeController = Knit.GetController("ServerTimeController")

    self.Trove = Trove.new() 
    
    self.Chassis = self.Trove:Add(Chassis.new(tankModel))
    --Parts
    self.Model = tankModel :: Model
    self.Seat = tankModel:WaitForChild("Chassis"):WaitForChild("VehicleSeat") :: VehicleSeat
    self.Turret = tankModel:WaitForChild("Turret") :: Model
    self.TurretBase = self.Turret:WaitForChild("Base") :: BasePart
    self.Rotator = self.Turret:WaitForChild("Rotator") :: BasePart
    self.BarrelHinge = self.Rotator:WaitForChild("BarrelHinge") :: HingeConstraint
    self.RotatorServo = self.Turret:WaitForChild("Base"):WaitForChild("RotatorServo") :: HingeConstraint
    self.TargetBarrelAngle = 0 :: number 
    self.TargetRotatorAngle = 0 :: number 

    self.Character = character 
    self.Humanoid = self.Character.Humanoid 
    
    --State
    self.IsOccupied = false 

    self.Trove:Add(RunService.Heartbeat:Connect(function()
        self:Update()
    end))

    self.Trove:Add(UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean) 
        self:HandleInput(inputObject, gameProcessed)
    end))

    self.Trove:Add(self.Humanoid.Died:Connect(function() 
        
    end))

    self.Trove:Add(RunService.RenderStepped:Connect(function() 
        local throttle, steering, handbreak = self:GetInputValues()

        local currentVel = self.Chassis:GetAverageVelocity()
        self.Chassis:UpdateSteering(steering, currentVel)
        self.Chassis:UpdateThrottle(currentVel, throttle)

        if handbreak > 0 then
            self.Chassis:EnableHandbrake()
        end
    end))


    self.Camera = self.Trove:Add(TankCamera.new(self))
    self.TankGui = self.Trove:Add(TankGui.new(self))

    return self 
end


local function _updateRawInput(inputState, inputObj)
	local key = inputObj.KeyCode
	local data = Keymap.getData(key)
	
	if not data then 
		return
	end
	
	local axis = data.Axis
	local val = 0
	
	if axis then
		val = inputObj.Position:Dot(axis)
	else
		val = (inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.Change) and 1 or 0
	end
	
	val = val * (data.Sign or 1)
	
	_rawInput[key] = val
	
end

local function onInputBegan(input, gameProcessed)
	if not gameProcessed and table.find(Keymap.allKeys(), input.KeyCode) then
		_updateRawInput(Enum.UserInputState.Begin, input)
	end
end


local function onInputEnded(input, gameProcessed)
	if not gameProcessed and table.find(Keymap.allKeys(), input.KeyCode) then
		_updateRawInput(Enum.UserInputState.End, input)
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

local function _calculateInput(action)
	-- Loop through all mappings for this action and calculate a resultant value from the raw input
	local mappings = Keymap[action]
	local val = 0
	local absVal = val
	
	for _, data in ipairs(mappings) do
		local thisVal = _rawInput[data.KeyCode]
		if math.abs(thisVal) > absVal then
			val = thisVal
			absVal = math.abs(val)
		end
	end
	
	return val
end


function ClientTank:GetInputValues()
    local throttle, steering, handbreak = _calculateInput("Throttle") - _calculateInput("Brake"), _calculateInput("SteerLeft") + _calculateInput("SteerRight"), _calculateInput("Handbrake")
    return throttle, steering, handbreak
end

function ClientTank:Update()
    self.IsOccupied = self.Seat.Occupant == Player.Character.Humanoid

    if self.IsOccupied then 
        self:UpdateTurret()
    end
end

local lastShot = 0

function ClientTank:HandleInput(inputObject: InputObject, gameProcessed: boolean)
    if gameProcessed then 
        return 
    end

    if not self.IsOccupied then 
        return 
    end

    if tick() - lastShot < 1 then 
        return 
    end

    lastShot = tick()
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
        self:Fire() 
    end
end

local function lerp(v0,v1,t)
    return v0+(v1-v0) * t 
end

function ClientTank:UpdateTurret()
    local mouseRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local rayOrigin = mouseRay.Origin
    local rayDirection = mouseRay.Direction * 1000

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {self.Tank}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    local mouseHit = result and result.Position or (rayOrigin + rayDirection)

    local turretPos = self.TurretBase.Position
    local worldDir = (mouseHit - turretPos).Unit
    local localDir =  self.TurretBase.CFrame:VectorToObjectSpace(worldDir)
    local yaw = math.deg(math.atan2(-localDir.X, -localDir.Z))
    local currentYaw = self.RotatorServo.TargetAngle

    self.TargetRotatorAngle = yaw 
    self.RotatorServo.TargetAngle = lerp(currentYaw, self.TargetRotatorAngle, 0.5)

    local toTarget = (mouseHit - self.Rotator.Position).Unit
    local pitchDir = self.Rotator.CFrame:VectorToObjectSpace(toTarget)
    local targetPitch = math.deg(math.atan2(pitchDir.Y, -pitchDir.Z))

    local currentPitch = self.BarrelHinge.CurrentAngle

    self.TargetBarrelAngle = targetPitch
    self.BarrelHinge.TargetAngle = lerp(currentPitch, self.TargetBarrelAngle, 0.5)
end

function ClientTank:Fire()
    --next thing is to make the local tank its own object
    local barrel = self.Turret.Barrel :: BasePart
    local directionOfFire = barrel.BarrelEnd.WorldCFrame.LookVector
    local projectileData = {
        Id = HttpService:GenerateGUID(),
        MuzzleVelocity = MUZZLE_VELOCITY * directionOfFire,
        Origin = barrel.BarrelEnd.WorldPosition,
        StartTime = self.ServerTimeController:GetTime()
    } :: Types.ProjectileData


    self.ProjectileController:AddProjectile(true, projectileData)

    --Add recoil
    barrel:ApplyImpulse(directionOfFire*RECOIL_FORCE*-1)
end

function ClientTank:CharacterDied() 
    self.Trove:Destroy() -- removes all the binds n shit
end

return ClientTank
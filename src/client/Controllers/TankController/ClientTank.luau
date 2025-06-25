local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(Knit.Packages.Trove)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local GetSafeCharacter = require(Knit.Modules.GetSafeCharacter)
local TankUtil = require(ReplicatedStorage.Shared.Modules.TankUtil)
local Chassis = require(script.Parent.Chassis)
local Keymap = require(script.Parent.Keymap)
local TankCamera = require(script.Parent.TankCamera)
local TankGui = require(script.Parent.TankGui)
local Tracks = require(script.Parent.Tracks)


local ClientTank = {}
ClientTank.__index = ClientTank

local _rawInput = Keymap.newInputTable()

local function _clearInput()
	for k, _ in pairs(_rawInput) do
		_rawInput[k] = 0
	end
end

function ClientTank.new(tankModel: Model, type: string)
    local self = setmetatable({}, ClientTank)
    local character = GetSafeCharacter() 
    if not character then 
        return 
    end

    --Data 
    self.Replica = Knit.GetController("DataController"):GetReplica(Player)

    self.TankType = type :: string
    self.TankData = TankData[type] :: Types.TankData
    self.UpgradeData = self.Replica.Data.OwnedTanks[self.TankType]
    self.Cooldown = TankUtil.GetAttribute("Cooldown", self.TankType, self.UpgradeData)

    --Knit controllers/services
    self.ProjectileController = Knit.GetController("ProjectileController")
    self.ServerTimeController = Knit.GetController("ServerTimeController")
    self.VFXController = Knit.GetController("VFXController")
    self.DamageService = Knit.GetService("DamageService")

    self.Trove = Trove.new() 
    self.Chassis = self.Trove:Add(Chassis.new(tankModel, self.TankData.BaseAtrributes, self))

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
    self.TankAimPosition = Vector3.new() :: Vector3 
    self.TargetBarrelYaw = 0 :: number
    self.BarrelWorldYaw = 0 :: number
    self.BarrelPitch = 0 :: number
    self.CurrentRelativeYaw = 0 :: number
    self.Character = character :: Model
    self.Humanoid = self.Character.Humanoid :: Humanoid
    self.RaycastParamsIgnoreSelf = RaycastParams.new() :: RaycastParams

    --State
    --self.IsOccupied = false :: boolean
    self.IsJoystickControlled = false :: boolean
    self.LastShotTime = 0 :: number 
    self.Disabled = false :: boolean 
    self.Speed = 0 :: number -- this is just written to for access. changing it does not set the tank's speed

    self.JoystickThrottle = {
        Z = 0,
        X = 0,
        Braking = false,
    } :: Types.JoystickThrottle


    --Functions
    self.LeftTracks = self.Trove:Add(Tracks.new(self.Model.Body.LeftWheels, self))
    self.RightTracks = self.Trove:Add(Tracks.new(self.Model.Body.RightWheels, self))

    self.Trove:Add(RunService.Heartbeat:Connect(function(dT)
        self:Update(dT)
    end))

    self.Trove:Add(UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean) 
        self:HandleInput(inputObject, gameProcessed)
    end))

    self.Trove:Add(RunService.RenderStepped:Connect(function() 
        if self.Disabled then 
            self.Chassis:EnableHandbrake()
            return
        end

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

    self.RaycastParamsIgnoreSelf.FilterType = Enum.RaycastFilterType.Exclude
    self.RaycastParamsIgnoreSelf.FilterDescendantsInstances = CollectionService:GetTagged("RaycastIgnore")
    self.RaycastParamsIgnoreSelf:AddToFilter{self.Model, Player.Character}
    self.RaycastParamsIgnoreSelf.RespectCanCollide = false 

    self.Trove:Add(CollectionService:GetInstanceAddedSignal("RaycastIgnore"):Connect(function(instance: Instance)
        self.RaycastParamsIgnoreSelf:AddToFilter{instance}
    end))

    self:_initDestroyableObjectConnections()

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

function ClientTank:_initDestroyableObjectConnections()
    for i,v in pairs(self.Model.Hitbox:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Touched:Connect(function(hit: BasePart)
                if hit:HasTag("DestroyableObjectPart") then
                    Knit.GetController("DestroyableObjectController"):HandleTankCollision(hit, self.Model.PrimaryPart.Position)
                end
            end)
        end
    end
end

function ClientTank:GetInputValues()
    local throttle, steering, handbreak 
    --Kind of a rachet way to do it. We should average the values if they both are reporting?
    if self.IsJoystickControlled then 
        throttle, steering, handbreak = self.JoystickThrottle.Z, self.JoystickThrottle.X, self.JoystickThrottle.Braking and 1 or 0
    else    
        throttle, steering, handbreak = _calculateInput("Throttle") - _calculateInput("Brake"), _calculateInput("SteerLeft") + _calculateInput("SteerRight"), _calculateInput("Handbrake")
    end

    return throttle, steering, handbreak
end

function ClientTank:Update(dT: number)
    self:UpdateTurret(dT)
    self.IsOccupied = self.Seat.Occupant == Player.Character.Humanoid


    self.LeftTracks:Update(dT)
    self.RightTracks:Update(dT)
end

function ClientTank:HandleInput(inputObject: InputObject, gameProcessed: boolean)
    if gameProcessed then 
        return 
    end

    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
        self:AttemptFire()
        return 
    end

end

local function lerp(v0,v1,t)
    return v0+(v1-v0) * t 
end

local function moveToward(current, target, maxDelta)
    local delta = (target - current + 180) % 360 - 180 -- shortest angle difference
    if math.abs(delta) <= maxDelta then
        return target
    end
    return (current + math.sign(delta) * maxDelta + 180) % 360 - 180
end

function ClientTank:UpdateTurret(dT)
    local maxAngleChange = self.TankData.BaseAtrributes.TurretAngularVelocity * dT

    local baseCFrame = self.TurretBase.CFrame
    local currentYaw = self.RotatorServo.TargetAngle
    local desiredYawWorld = self.TargetBarrelYaw

    local baseYaw = math.deg(math.atan2(-baseCFrame.LookVector.X, -baseCFrame.LookVector.Z))
    local desiredRelativeYaw = desiredYawWorld - baseYaw

    local delta = (desiredRelativeYaw - self.CurrentRelativeYaw + 180) % 360 - 180
    self.CurrentRelativeYaw += delta

    self.TargetRotatorAngle = self.CurrentRelativeYaw
    self.RotatorServo.TargetAngle = moveToward(currentYaw, self.TargetRotatorAngle, maxAngleChange)

    self.BarrelWorldYaw = baseYaw + self.RotatorServo.TargetAngle
    
    -- PITCH
    local rotatorCFrame = self.Rotator.CFrame
    local currentPitch = self.BarrelHinge.CurrentAngle
    local desiredPitchWorld = self.BarrelPitch

    local rotatorLook = rotatorCFrame.LookVector
    local worldPitch = math.deg(math.asin(rotatorLook.Y))
    local relativePitch = desiredPitchWorld - worldPitch

    self.TargetBarrelAngle = relativePitch
    self.BarrelHinge.TargetAngle = lerp(currentPitch, self.TargetBarrelAngle, 0.5)
end

function ClientTank:AttemptFire()
    if tick() - self.LastShotTime < self.Cooldown then 
        return 
    end

    self:Fire()
end

function ClientTank:Fire()
    self.LastShotTime = tick() 

    local barrel = self.Turret.Barrel :: BasePart
    local barrelEnd = barrel.BarrelEnd :: Attachment

    local targetPosition = self.TankAimPosition
    local directionOfFire = (targetPosition - barrelEnd.WorldPosition).Unit

    local projectileData = {
        Id = HttpService:GenerateGUID(),

        Origin = barrel.BarrelEnd.WorldPosition,
        StartTime = self.ServerTimeController:GetTime(),
        BarrelEnd = barrel.BarrelEnd,

        MuzzleVelocity = self.TankData.BaseAtrributes.MuzzleVelocity * directionOfFire,
        BlastRadius = TankUtil.GetAttribute("BlastRadius", self.TankType, self.UpgradeData),

    } :: Types.ProjectileData

    self.ProjectileController:AddProjectile(true, projectileData)

    self.Seat:ApplyImpulse(directionOfFire*TankUtil.GetAttribute("RecoilForce", self.TankType, self.UpgradeData)*-1)
    self.Camera:ApplyShotImpulse(200)
end

function ClientTank:Disable()
    self.Disabled = true
    self.TankGui:Destroy() 
    self.TankGui = nil 
end

function ClientTank:Destroy() 
    self.Trove:Destroy() -- removes all the binds n shit
end


return ClientTank
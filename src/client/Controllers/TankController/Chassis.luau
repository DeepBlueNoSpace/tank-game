--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Data.Types)

local SoundAssets = ReplicatedStorage.Assets.Sound

local mphConversion = 0.6263 -- using a 28cm = 1stud conversion rate

local torqueDamping = 0.6

--[[ Chassis Variables ]]--
--[[
local VehicleParameters = { -- These are default values in the case the package structure is broken
	MaxSpeed = 40/mphConversion,
	ReverseSpeed = 20/mphConversion,
	AccelerationMax = 10,
	DrivingTorque = 500000,
	BrakingTorque = 50000000,
	StrutSpringStiffnessFront = 34000,
	StrutSpringDampingFront = 1430,
	StrutSpringStiffnessRear = 32000,
	StrutSpringDampingRear = 1400,
	TorsionSpringStiffness = 20000,
	TorsionSpringDamping = 150,
	MaxSteer = 0.8,
	WheelFriction = 2,
	BaseEngineRPM = 1745
}
]]

local Chassis = nil
local LimitSteerAtHighVel = true
-- Limits the amount you can steer based on velocity. Helpful for keyboard/non-analog steer inputs
local SteerLimit = 0.2 -- Max amount the steering float (-1 to 1) will be limited by if limitSteerAtHighVel is true


--[[ Private Functions ]]--

--[[ Module Functions ]]--
Chassis = {}
Chassis.__index = Chassis 

local REVERSE_SPEED_MULT = 0.5
local BREAKING_TORQUE_MULT = 10
local DISTANCE_PER_TREAD = 1

local function CreateVehicleParameters(tankAttributes: Types.TankAttributes)
	local parameters = {
		MaxSpeed = tankAttributes.MaxSpeed/mphConversion,
		ReverseSpeed = (tankAttributes.MaxSpeed/mphConversion) * REVERSE_SPEED_MULT,
		AccelerationMax = tankAttributes.Acceleration, 
		DrivingTorque = tankAttributes.Torque, 
		BrakingTorque = tankAttributes.Torque * BREAKING_TORQUE_MULT,
		MaxSteer = tankAttributes.MaxSteer,

		--random crap we dont care about 
		StrutSpringStiffnessFront = 34000,
		StrutSpringDampingFront = 1430,
		StrutSpringStiffnessRear = 32000,
		StrutSpringDampingRear = 1400,
		TorsionSpringStiffness = 20000,
		TorsionSpringDamping = 150,
		WheelFriction = 2,
		BaseEngineRPM = 1745
	}

	return parameters
end

function Chassis.new(vehicle: Model, baseAtrributes: Types.TankAttributes, tank: {}) 
    local self = setmetatable({}, Chassis)
	self.parameters = CreateVehicleParameters(baseAtrributes)

    self.root = vehicle:FindFirstChild("Chassis") :: Model
    self.driverSeat = self.root:FindFirstChildOfClass("VehicleSeat") :: VehicleSeat
    self.constraints = vehicle:WaitForChild("Constraints") :: Folder 
    self.vehicle = vehicle :: Model
    self.RedressMount = self.root:WaitForChild("RedressMount") :: BasePart
	self.CosmeticWheelMotors = self.root:WaitForChild("FloorPanel"):WaitForChild("WheelMotors"):GetChildren() :: {}
	self.Tank = tank
	
	self.Motors = {}
	self.LastFakeRPM = 0 

    self.SteeringPrismatic = self.constraints:FindFirstChild("SteeringPrismatic") :: PrismaticConstraint
	self.SteeringPrismatic.UpperLimit = self.parameters.MaxSteer
	self.SteeringPrismatic.LowerLimit = -self.parameters.MaxSteer

    local randomSuspension = self.root:FindFirstChild("SuspensionFL") :: Model
    local randomWheel = randomSuspension:FindFirstChild("Wheel") :: BasePart
	local wheelRadius = randomWheel.Size.Y/2 
	self.RandomWheel = randomWheel

	self.TotalDistanceTravelled = 0 :: number
	self.LastPosition = self.driverSeat.Position :: Vector3
	self.DistanceTravelledSinceLastTread = 0 :: number

    self.driverSeat.MaxSpeed = self.parameters.MaxSpeed * wheelRadius

	self:InitializeDrivingValues()

	self.StartSound = SoundAssets.TankStart:Clone() :: Sound
	self.DriveSound = SoundAssets.TankDrive:Clone() :: Sound

	self.StartSound.Parent = self.root 
	self.DriveSound.Parent = self.root 

	self.LiveSound = self.StartSound
	self.StartSound:Play()

	self.StartSound.Ended:Connect(function() 
		self.DriveSound:Play()
		self.LiveSound = self.DriveSound
	end)
	return self
end

function Chassis:getVehicleMotors()
	local motors = {}
	for _, c in pairs(self.constraints:GetChildren()) do
		if c:IsA("CylindricalConstraint") then
			table.insert(motors, c)
        end
    end
	return motors
end

function Chassis:getSprings(springType)
	local springs = {}
	local trailer = self.vehicle:FindFirstChild("Trailer")
	
	local function search(children)
		local searchStrutSpring = "StrutSpring"
		local searchFrontSpring = "StrutSpringF"
		local searchTorsionSpring = "TorsionBarSpring"
		for _, c in pairs(children) do
			if c:IsA("SpringConstraint") then
				if springType == "StrutFront" then
					if string.find(c.Name, searchFrontSpring) then
						table.insert(springs, c)
					end
				elseif springType == "StrutRear" then
					if (not string.find(c.Name, searchFrontSpring)) and string.find(c.Name, searchStrutSpring) then
						table.insert(springs, c) -- we have option of Mid and Rear for these
					end
				elseif springType == "TorsionBar" then
					if string.find(c.Name, searchTorsionSpring) then
						table.insert(springs, c)
					end
				end
			end
		end
	end

	search(self.constraints:GetChildren())
	if trailer then
		search(trailer.Constraints:GetChildren())
	end
	
	return springs
end

function getMotorVelocity(motor)
	return motor.Attachment1.WorldAxis:Dot(motor.Attachment1.Parent.RotVelocity )
end

local function adjustSpring( spring, stiffness, damping )
	spring.Stiffness = stiffness
	spring.Damping = damping
end
function Chassis:setMotorTorque(torque)
	for _, motor in pairs(self.Motors) do		
		motor.MotorMaxTorque = torque
	end
end

function Chassis:setMotorTorqueDamped(torque, velocityDirection, accelDirection)
	
	for _, motor in pairs(self.Motors) do
		if self.parameters.MaxSpeed == 0 then 
			motor.MotorMaxTorque = 0
		else
			local maxSpeed = self.parameters.MaxSpeed
			if accelDirection < 0 and velocityDirection < 0 then
				maxSpeed = self.parameters.ReverseSpeed
			end
			
			local speed = self.driverSeat.Velocity.Magnitude :: number
			
			local r = math.abs( speed / maxSpeed)
			motor.MotorMaxTorque = math.exp( -3 * r * r ) * torque * torqueDamping
		end
	end
end

function Chassis:setMotorMaxAcceleration(acceleration)
	for _, motor in pairs(self.Motors) do
		motor.MotorMaxAngularAcceleration = acceleration
	end
end


function Chassis:InitializeDrivingValues()
	-- Constraint tables always ordered FL, FR, RL, RR
	self.Motors = self:getVehicleMotors()
	
	local strutSpringsFront = self:getSprings("StrutFront")
	local strutSpringsRear = self:getSprings("StrutRear")
	local torsionSprings = self:getSprings("TorsionBar") 

	self.RedressMount = self.root:WaitForChild("RedressMount") :: BasePart
	
	self.SteeringPrismatic = self.constraints:FindFirstChild("SteeringPrismatic") :: PrismaticConstraint
	self.SteeringPrismatic.UpperLimit = self.parameters.MaxSteer
	self.SteeringPrismatic.LowerLimit = -self.parameters.MaxSteer
	
	for _,s in pairs(strutSpringsFront) do
		adjustSpring(s, self.parameters.StrutSpringStiffnessFront, self.parameters.StrutSpringDampingFront)
	end
	for _,s in pairs(strutSpringsRear) do
		adjustSpring(s, self.parameters.StrutSpringStiffnessRear, self.parameters.StrutSpringDampingRear)
	end
	for _,s in pairs(torsionSprings) do
		adjustSpring(s, self.parameters.TorsionSpringStiffness, self.parameters.TorsionSpringDamping)
	end
	
	local chassisChildren = self.root:GetChildren()
	for i = 1, #chassisChildren do
		local model = chassisChildren[i]
		if model:IsA("Model") then
			local wheel = model:FindFirstChild("Wheel") :: BasePart
			if wheel then
				local old = wheel.CustomPhysicalProperties
				local new = PhysicalProperties.new(old.Density, self.parameters.WheelFriction, old.Elasticity, old.FrictionWeight, old.ElasticityWeight)
				wheel.CustomPhysicalProperties = new
			end
		end
	end

	self:setMotorTorque(10000)
end

function Chassis:GetDriverSeat()
	return self.driverSeat
end

function Chassis:GetPassengerSeats()
	return self.passengerSeats
end

function Chassis:GetBase()
	return self.root.PrimaryPart or self.root:FindFirstChild("FloorPanel")
end

--Set target angular velocity for all 4 wheels.
function Chassis:SetMotorVelocity(vel)
	for _, motor in pairs(self.Motors) do
		motor.AngularVelocity = vel
	end
end

--Get average angular velocity from all 4 wheels
function Chassis:GetAverageVelocity()
	local t = 0
	for _, motor in pairs(self.Motors) do
		t = t + getMotorVelocity(motor)
	end
	return t * (1/#self.Motors)
end

--Set braking torque and stop back 2 wheels
function Chassis:EnableHandbrake()
	self.Motors[3].MotorMaxTorque = self.parameters.BrakingTorque
	self.Motors[4].MotorMaxTorque = self.parameters.BrakingTorque
	self.Motors[3].AngularVelocity = 0
	self.Motors[4].AngularVelocity = 0
end

--Set target steering position based on current velocity
function Chassis:UpdateSteering(steer:number, currentVel:number)
	local maxSteer = self.parameters.MaxSteer	
	if LimitSteerAtHighVel then
		local c = SteerLimit * (math.abs(currentVel)/self.parameters.MaxSpeed) + 1
		--decrease steer value as speed increases to prevent tipping (handbrake cancels this)
		steer = steer/c
	end
	self.SteeringPrismatic.TargetPosition = steer * steer * steer * maxSteer
end

local function lerp(v0: number,v1:number,t:number): number
	return v0+(v1-v0)*t 
end

local idlePitch = 0.7
local maxPitch = 1.6
local baseVolume = 0.3

function Chassis:UpdateThrottle(currentSpeed, throttle)
	local targetVel = 0
	local fakeRPM = 0

	self.Tank.Speed = self.driverSeat.Velocity.Magnitude

	if math.abs(throttle) < 0.1 then
		-- Idling
		self:setMotorMaxAcceleration(self.parameters.AccelerationMax)
		self:setMotorTorque(self.parameters.BrakingTorque)
	elseif math.sign(throttle * currentSpeed) > 0 or math.abs(currentSpeed) < 0.5 then
		self:setMotorMaxAcceleration(self.parameters.AccelerationMax)

		local velocity = self.driverSeat.Velocity
		local velocityVector = velocity.Unit
		local directionalVector = self.driverSeat.CFrame.lookVector
		local dotProd = velocityVector:Dot(directionalVector) -- Dot product is a measure of how similar two vectors are; if they're facing the same direction, it is 1, if they are facing opposite directions, it is -1, if perpendicular, it is 0
		
		local torque = self.parameters.DrivingTorque :: number
		self:setMotorTorqueDamped(torque * throttle * throttle, dotProd, math.sign(throttle))

		local movingBackwards = dotProd < 0
		local acceleratingBackwards = throttle < 0
		local useReverse = (movingBackwards and acceleratingBackwards)
		
		local maxSpeed = (useReverse and self.parameters.ReverseSpeed or self.parameters.MaxSpeed)
		targetVel = math.sign(throttle) * maxSpeed
		
		local normalizedSpeed = math.clamp(currentSpeed / maxSpeed, 0, 1)
		fakeRPM = 0.3 * normalizedSpeed + 0.7 * math.abs(throttle)

	else
		self:setMotorMaxAcceleration(self.parameters.AccelerationMax*3)

		local torque = self.parameters.BrakingTorque :: number
		self:setMotorTorque(torque * throttle * throttle)
		targetVel = math.sign(throttle) * 500
	end

	local newRPM = lerp(self.LastFakeRPM,fakeRPM,0.5)
	self.LiveSound.PlaybackSpeed = idlePitch + (maxPitch - idlePitch) * newRPM
	self.LiveSound.Volume = (baseVolume*0.5) + (0.5 * newRPM * baseVolume)

	self.LastFakeRPM = newRPM
	
	self:SetMotorVelocity(targetVel)
	self:UpdateWheelMotors()
end


function Chassis:UpdateWheelMotors()
	local newPosition = self.driverSeat.Position :: Vector3
	local forward = self.driverSeat.CFrame.LookVector :: Vector3 
	local delta = self.LastPosition - newPosition 

	local signedDistance = delta:Dot(forward) :: number
	self.TotalDistanceTravelled += signedDistance 
	self.DistanceTravelledSinceLastTread += signedDistance

	if math.abs(self.DistanceTravelledSinceLastTread) > DISTANCE_PER_TREAD then 
		local emitFromBack = self.DistanceTravelledSinceLastTread<0
		self.Tank.LeftTracks:Emit(emitFromBack)
		self.Tank.RightTracks:Emit(emitFromBack)
		self.DistanceTravelledSinceLastTread = 0 
	end	

	self.LastPosition = newPosition
end

function Chassis:Destroy() 
	--idk actually know if there is anything to destroy here

end

return Chassis

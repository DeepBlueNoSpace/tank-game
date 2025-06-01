local Workspace = game:GetService("Workspace")
local mphConversion = 0.6263 -- using a 28cm = 1stud conversion rate

local torqueDamping = 0.6

--[[ Chassis Variables ]]--
local VehicleParameters = { -- These are default values in the case the package structure is broken
	MaxSpeed = 40/mphConversion,
	ReverseSpeed = 20/mphConversion,
	AccelerationMax = 10,
	DrivingTorque = 35000,
	BrakingTorque = 40000,
	StrutSpringStiffnessFront = 34000,
	StrutSpringDampingFront = 1430,
	StrutSpringStiffnessRear = 32000,
	StrutSpringDampingRear = 1400,
	TorsionSpringStiffness = 20000,
	TorsionSpringDamping = 150,
	MaxSteer = 0.5,
	WheelFriction = 2,
	BaseEngineRPM = 1745
}

local Chassis = nil
local LimitSteerAtHighVel = true
-- Limits the amount you can steer based on velocity. Helpful for keyboard/non-analog steer inputs
local SteerLimit = 0.2 -- Max amount the steering float (-1 to 1) will be limited by if limitSteerAtHighVel is true


--[[ Private Functions ]]--

--[[ Module Functions ]]--
Chassis = {}
Chassis.__index = Chassis 

function Chassis.new(vehicle) 
    local self = setmetatable({}, Chassis)
    self.root = vehicle:FindFirstChild("Chassis") --the root of the Chassis model
    self.driverSeat = self.root:FindFirstChildOfClass("VehicleSeat")
    self.constraints = vehicle:WaitForChild("Constraints")
    self.vehicle = vehicle
    self.RedressMount = self.root:WaitForChild("RedressMount")

    self.SteeringPrismatic = self.constraints:FindFirstChild("SteeringPrismatic")
	self.SteeringPrismatic.UpperLimit = VehicleParameters.MaxSteer
	self.SteeringPrismatic.LowerLimit = -VehicleParameters.MaxSteer

    local randomSuspension = self.root:FindFirstChild("SuspensionFL")
    local wheelRadius = randomSuspension.Wheel.Size.y/2
    self.driverSeat.MaxSpeed = VehicleParameters.MaxSpeed * wheelRadius

    self.parameters = VehicleParameters

	self:InitializeDrivingValues()
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
	return motor.Attachment1.WorldAxis:Dot( motor.Attachment1.Parent.RotVelocity )
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
		if VehicleParameters.MaxSpeed == 0 then 
			motor.MotorMaxTorque = 0
		else
			local maxSpeed = VehicleParameters.MaxSpeed
			if accelDirection < 0 and velocityDirection < 0 then
				maxSpeed = VehicleParameters.ReverseSpeed
			end
			
			local r = math.abs(self.driverSeat.Velocity.Magnitude / maxSpeed)
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

	self.RedressMount = self.root:WaitForChild("RedressMount")
	
	self.SteeringPrismatic = self.constraints:FindFirstChild("SteeringPrismatic")
	self.SteeringPrismatic.UpperLimit = VehicleParameters.MaxSteer
	self.SteeringPrismatic.LowerLimit = -VehicleParameters.MaxSteer

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
			local wheel = model:FindFirstChild("Wheel")
			if wheel then
				local old = wheel.CustomPhysicalProperties
				local new = PhysicalProperties.new(old.Density, VehicleParameters.WheelFriction, old.Elasticity, old.FrictionWeight, old.ElasticityWeight)
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
function Chassis:UpdateSteering(steer, currentVel)

	local maxSteer = VehicleParameters.MaxSteer
	
	
	if LimitSteerAtHighVel then
		local c = SteerLimit * (math.abs(currentVel)/VehicleParameters.MaxSpeed) + 1
		--decrease steer value as speed increases to prevent tipping (handbrake cancels this)
		steer = steer/c
	end
	self.SteeringPrismatic.TargetPosition = steer * steer * steer * maxSteer
end

function Chassis:UpdateThrottle(currentSpeed, throttle)
	local targetVel = 0
	local gainModifier = 0
	
	if math.abs(throttle) < 0.1 then
		-- Idling
		self:setMotorMaxAcceleration(VehicleParameters.AccelerationMax)
		self:setMotorTorque(2000)
	elseif math.sign(throttle * currentSpeed) > 0 or math.abs(currentSpeed) < 0.5 then
		self:setMotorMaxAcceleration(VehicleParameters.AccelerationMax)

		local velocity = self.driverSeat.Velocity
		local velocityVector = velocity.Unit
		local directionalVector = self.driverSeat.CFrame.lookVector
		local dotProd = velocityVector:Dot(directionalVector) -- Dot product is a measure of how similar two vectors are; if they're facing the same direction, it is 1, if they are facing opposite directions, it is -1, if perpendicular, it is 0
		
		self:setMotorTorqueDamped(self.parameters.DrivingTorque * throttle * throttle, dotProd, math.sign(throttle))
		-- Arbitrary large number
		local movingBackwards = dotProd < 0
		local acceleratingBackwards = throttle < 0
		local useReverse = (movingBackwards and acceleratingBackwards)
		
		local maxSpeed = (useReverse and VehicleParameters.ReverseSpeed or VehicleParameters.MaxSpeed)
		targetVel = math.sign(throttle) * maxSpeed
		
		-- if we are approaching max speed, we should take that as an indication of throttling down, even if not from input
		local maxAccelSpeed = targetVel
		
		-- lets say we start throttling down after reaching 75% of max speed, then linearly drop to 0
		local function quad(x)
			return math.sign(x)*(x^2)
		end
		
		
		local r = math.abs(velocity.Magnitude / maxSpeed*2.5) -- adding a bit to the max speed so that it sounds better (always trying to rev engines)
		local desiredRPM = math.exp(-3*r*r)
		
		
		gainModifier = desiredRPM
		
		if gainModifier > 0 then
			effectsThrottleState = true
		end
	else
		-- Braking
		self:setMotorMaxAcceleration(VehicleParameters.AccelerationMax*3)
		self:setMotorTorque(self.parameters.BrakingTorque * throttle * throttle)
		targetVel = math.sign(throttle) * 500
	end
	
	self:SetMotorVelocity(targetVel)
end

local redressingState = false
local targetAttachment
function Chassis:Redress()
	if redressingState then
		return
	end
	redressingState = true
	local p = self.driverSeat.CFrame.Position + Vector3.new( 0,10,0 )
	local xc = Chaselfssis.driverSeat.CFrame.RightVector
	xc = Vector3.new(xc.x,0,xc.z)
	xc = xc.Unit
	local yc = Vector3.new(0,1,0)

	if not targetAttachment then
		targetAttachment = self.RedressMount.RedressTarget
	end

	targetAttachment.Parent = Workspace.Terrain
	targetAttachment.Position = p
	targetAttachment.Axis = xc
	targetAttachment.SecondaryAxis = yc
	self.RedressMount.RedressOrientation.Enabled = true
	self.RedressMount.RedressPosition.Enabled = true
	wait(1.5)
	self.RedressMount.RedressOrientation.Enabled = false
	self.RedressMount.RedressPosition.Enabled = false
	targetAttachment.Parent = self.RedressMount
	wait(2)
	redressingState = false
end

function Chassis:Reset() --Reset user inputs and redress (For when a player exits the vehicle)
	self:UpdateThrottle(1, 1) --Values must  be changed to replicate to client.
	self:UpdateSteering(1, 0) --i.e. setting vel to 0 when it is 0 wont update to clients
	self:EnableHandbrake()
	self.setMotorTorque(self.parameters.BrakingTorque)
	self:SetMotorVelocity(0)
	self:UpdateSteering(0, 0)
	self.RedressMount.RedressOrientation.Enabled = true
	self.RedressMount.RedressPosition.Enabled = true
	self.RedressMount.RedressOrientation.Enabled = false
	self.RedressMount.RedressPosition.Enabled = false
	redressingState = false
end

return Chassis

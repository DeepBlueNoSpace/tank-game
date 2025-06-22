local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TreadEmitterPrefab =  ReplicatedStorage.Assets.VFX.TreadEmitter 

local Tracks = {}
Tracks.__index = Tracks

local MAX_DIST = 0.3

local WIDTH = 1.3
local THICKNESS = 0.5

local treadPrefab = Instance.new("Part")
treadPrefab.BrickColor = BrickColor.Black()
treadPrefab.CanCollide = false 
treadPrefab.CanQuery = false 
treadPrefab.Anchored = true
treadPrefab.CastShadow = false
treadPrefab.TopSurface = Enum.SurfaceType.Smooth
treadPrefab.BottomSurface = Enum.SurfaceType.Smooth

local roundPrefab = Instance.new("Part")
roundPrefab.BrickColor = BrickColor.Black()
roundPrefab.CanCollide = false 
roundPrefab.CanQuery = false 
roundPrefab.Anchored = true
roundPrefab.Size = Vector3.new(WIDTH, THICKNESS, THICKNESS)
roundPrefab.Shape = Enum.PartType.Cylinder
roundPrefab.CastShadow = false
roundPrefab.TopSurface = Enum.SurfaceType.Smooth
roundPrefab.BottomSurface = Enum.SurfaceType.Smooth

function Tracks.new(wheels: Model, tank: { [Model]: Model })
    local self = setmetatable({}, Tracks)
    self.Wheels = {} :: {Wheel: BasePart, Motor: Motor6D, DefaultC0: CFrame, FixedWheel: boolean?, BottomRound: BasePart}
    self.TankModel = tank.Model :: Model
    self.Part0 = self.TankModel.Chassis.FloorPanel

    self.EmitterAttachment = Instance.new("Attachment")
    self.EmitterAttachment.Parent = self.Part0 

    self.TrackEmitter = TreadEmitterPrefab:Clone()
    self.TrackEmitter.Parent = self.EmitterAttachment 

    for _, child in wheels:GetChildren() do
        if child:IsA("BasePart") then
            local sidePrefix = wheels.Name == "LeftWheels" and "L" or "R"
            local motor6D = tank.Model.Chassis.FloorPanel.WheelMotors:FindFirstChild(string.format("%s%s", sidePrefix, tostring(child.Name)))

            self.Wheels[tonumber(child.Name)] = {
                Wheel = child, 
                Motor = motor6D,
                DefaultC0 = motor6D.C0,
                FixedWheel = child:HasTag("FixedWheel"),
                BottomRound = roundPrefab:Clone()
            }

            self.Wheels[tonumber(child.Name)].BottomRound.Parent = workspace
        end
    end

    self.Tank = tank 

    self.Treads = self:GenerateTreads()
    self.TopTread = treadPrefab:Clone()
    self.TopTread.Parent = workspace

    return self
end


function Tracks:Emit(emitFromBack)
    local wheelNum = 2 
    if not emitFromBack then 
        wheelNum = 7 
    end
    
    local roundCFrame = self.Wheels[wheelNum].BottomRound.CFrame
    local position = roundCFrame.Position
    local _, y, _ = self.Part0.CFrame:ToEulerAnglesYXZ()

    self.EmitterAttachment.WorldCFrame = CFrame.new(position) * CFrame.Angles(0, y+math.pi, 0)
    self.TrackEmitter:Emit(1)
end

function Tracks:GenerateTreads()
    local treads = {} :: {[number]: {Top:BasePart, Bottom:BasePart}}

    local treadSegmentsToGenerate = #self.Wheels-1 
    for i = 1, treadSegmentsToGenerate do 
        treads[i] = {
            Top = treadPrefab:Clone(),
            Bottom = treadPrefab:Clone()
        }

        treads[i].Top.Parent = workspace
        treads[i].Bottom.Parent = workspace
    end

    return treads
end

function Tracks:SetTread(tread: BasePart, pointA: Vector3, pointB: Vector3, isTop: boolean)
    local sign = isTop and 1 or -1
    local chassisCFrame = self.Part0.CFrame

    pointA += Vector3.new(0, sign * THICKNESS / 2, 0)
    pointB += Vector3.new(0, sign * THICKNESS / 2, 0)

    local between = pointB - pointA
    local distance = between.Magnitude
    local midpoint = pointA + (between * 0.5)

    local right = chassisCFrame.RightVector
    local up = right:Cross(between.Unit)

    tread.CFrame = CFrame.fromMatrix(midpoint, right, up)
    tread.Size = Vector3.new(WIDTH, THICKNESS, distance)
end

function Tracks:Update()
    local wheelPositions = self:CalculateWheelPositions()
    for trackNumber, tracks in self.Treads do  
        local wheel1 = wheelPositions[trackNumber]
        local wheel2 = wheelPositions[trackNumber+1]

        self:SetTread(tracks.Bottom, wheel1.Bottom, wheel2.Bottom, false)
    end

    self:SetTread(self.TopTread, wheelPositions[1].Top, wheelPositions[8].Top, true)
end

local LERP_FACTOR = 0.3

function Tracks:UpdateWheel(wheelData)
    local wheelRadius = wheelData.Wheel.Size.Y / 2

    if not wheelData.FixedWheel then 
        local defaultWheelPosition = self.Part0.CFrame * wheelData.DefaultC0
        local direction = Vector3.new(0, -5, 0) 

        local result = workspace:Raycast(defaultWheelPosition.Position, direction, self.Tank.RaycastParamsIgnoreSelf)
        if result then
            local hitY = result.Position.Y
            local wheelY = defaultWheelPosition.Position.Y
            local offset = wheelY - hitY

            local clampedOffset = math.clamp(offset - wheelRadius - (THICKNESS), -MAX_DIST, MAX_DIST) -- leave room for tread and wheel lol
            local newC0 = wheelData.DefaultC0 * CFrame.new(0, -clampedOffset, 0)

            wheelData.Motor.C0 = wheelData.Motor.C0:lerp(newC0, LERP_FACTOR)
        else
            wheelData.Motor.C0 = wheelData.Motor.C0:lerp(wheelData.DefaultC0 * CFrame.new(0, MAX_DIST, 0), LERP_FACTOR)
        end
    end

    local wheelCFrame = wheelData.Motor.Part0.CFrame * wheelData.Motor.C0
    local wheelCenter = wheelCFrame.Position
    local yOffset = wheelRadius + (THICKNESS / 2)

    local chassisCFrame = wheelData.Motor.Part0.CFrame
    local chassisRotation = chassisCFrame - chassisCFrame.Position
    local bottomPos = wheelCenter - Vector3.new(0, yOffset, 0)

    local cylinderAlignment = CFrame.Angles(math.rad(90), 0, 0)

    wheelData.BottomRound.CFrame = CFrame.new(bottomPos) * chassisRotation * cylinderAlignment
end

function Tracks:CalculateWheelPositions()
    for _, wheelData in self.Wheels do 
        self:UpdateWheel(wheelData)
    end

    local wheelPositions = {} :: {[number]: {Top:Vector3,Bottom:Vector3}}

    for wheelNumber, wheelData in self.Wheels do  
        local wheelPosition = wheelData.Wheel.Position 
        local wheelRadius = Vector3.new(0,wheelData.Wheel.Size.Y/2,0)
        wheelPositions[wheelNumber] = {
            Top = wheelPosition + wheelRadius,
            Bottom = wheelPosition - wheelRadius,
        }
    end

    return wheelPositions   
end

function Tracks:Destroy()
    for _, x in self.Treads do 
        x.Top:Destroy()
        x.Bottom:Destroy()
    end
    for _, x in self.Wheels do 
        x.BottomRound:Destroy()
    end
end
return Tracks

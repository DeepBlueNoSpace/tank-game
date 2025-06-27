local Wheel = {}
Wheel.__index = Wheel

local WIDTH = 1.3
local THICKNESS = 0.5

local soothPointPrefab = Instance.new("Part")
soothPointPrefab.Color = Color3.fromRGB(45, 44, 39)
soothPointPrefab.CanCollide = false 
soothPointPrefab.CanQuery = false 
soothPointPrefab.Anchored = true
soothPointPrefab.Size = Vector3.new(WIDTH, THICKNESS, THICKNESS)
soothPointPrefab.Shape = Enum.PartType.Cylinder
soothPointPrefab.TopSurface = Enum.SurfaceType.Smooth
soothPointPrefab.BottomSurface = Enum.SurfaceType.Smooth
soothPointPrefab.Material = Enum.Material.Leather
soothPointPrefab.Name = "Sooth"

function Wheel.new(wheel: Part, chassis: Part, tank: {})
    local self = setmetatable({}, Wheel)
    self.Tank = tank
    self.Part = wheel 
    self.WheelModel = self.Part.Wheel
    self.Chassis = chassis 

    self.Immoveable = self.WheelModel:GetAttribute("Immoveable") :: boolean
    self.IsBottom = self.WheelModel:GetAttribute("BottomWheel") :: boolean
    self.NoTread = self.WheelModel:GetAttribute("NoTread") :: boolean

    self.Motor = wheel:FindFirstChild("Motor") :: Motor6D
    self.CosmeticMotor = wheel:FindFirstChild("CosmeticMotor") :: Motor6D
    self.DefaultCosmeticC0 = self.CosmeticMotor.C0 :: CFrame
    self.DefaultC0 = self.Motor.C0 :: CFrame
    self.r = math.max(self.WheelModel.Size.X, self.WheelModel.Size.Y)/2
    self.DownGive = 1:: number 
    self.UpGive = .2:: number 
    self.TouchingGround = false :: boolean
    self.YOffset = 0 :: number

    self.AttachmentOffsets = self:CalculateAttachmentOffsets() :: {CFrame}
    self.SoothingPoints = self:GenerateSoothingParts() :: {Part}
    self.TreadConnections = self:CalculateTreadConnections() :: {CFrame}

    return self
end

function Wheel:CalculateAttachmentOffsets() : {CFrame}
    local attachments = {}
    local sortedAttachments = {} :: {Attachment}

    for _, x in self.WheelModel:GetChildren() do 
        if x:IsA("Attachment") then 
            table.insert(attachments,x)
        end
    end

    table.sort(attachments, function(a, b)
            print(a.Name, b.Name)

        return tonumber(a.Name) < tonumber(b.Name)
    end)

    for _, attachment in attachments do
        table.insert(sortedAttachments, attachment)
    end


    local trackPoints = {} :: {CFrame}
    for _, attachment in sortedAttachments do
        trackPoints[tonumber(attachment.Name)] = self.Part.CFrame:ToObjectSpace(attachment.WorldCFrame)
    end

    return trackPoints
end

function Wheel:GenerateSoothingParts() : {Part}
    local soothingParts = {}
    for index, _ in self.AttachmentOffsets do 
        local part = soothPointPrefab:Clone() 
        part.Parent = self.Part 
        soothingParts[index] = part
    end

    return soothingParts
end


local LERP_FACTOR = 0.3


function Wheel:Update(totalDistanceMoved: number)
    if not self.Immoveable then 
        local defaultWheelPosition = self.Chassis.CFrame * self.DefaultC0
        local direction = Vector3.new(0, -5, 0) 

        local result = workspace:Raycast(defaultWheelPosition.Position, direction, self.Tank.RaycastParamsIgnoreSelf)
        if result then
            local hitY = result.Position.Y
            local wheelY = defaultWheelPosition.Position.Y
            local offset = wheelY - hitY
            self.YOffset = offset

            local clampedOffset = math.clamp(self.r+-offset+THICKNESS, -self.DownGive, self.UpGive)
            local newC0 = self.DefaultC0 * CFrame.new(0, clampedOffset, 0)

            self.Motor.C0 = self.Motor.C0:lerp(newC0, LERP_FACTOR)
            self.TouchingGround = true
        else
            self.YOffset = -self.DownGive
            self.Motor.C0 = self.Motor.C0:lerp(self.DefaultC0 * CFrame.new(0,  -self.DownGive, 0), LERP_FACTOR)
            self.TouchingGround = false
        end
    end

    local radius = self.r

    local angle = totalDistanceMoved / radius
    local rotation = CFrame.Angles(0, angle, 0)
    self.CosmeticMotor.C0 = self.DefaultCosmeticC0 * rotation

    self.TreadConnections = self:CalculateTreadConnections()
    self:PositionSoothingParts()
end

function Wheel:CalculateCurrentOffsets(): {CFrame}
    local currentOffsets = {}
    for index, defaultOffset in self.AttachmentOffsets do 
        currentOffsets[index] = defaultOffset --* CFrame.new(Vector3.new(0,self.YOffset,0))
    end
    return currentOffsets
end

local cylinderAlignment = CFrame.Angles(0, 0, math.rad(90))
function Wheel:PositionSoothingParts()
    for index, offset in self.TreadConnections do 
        local part = self.SoothingPoints[index]
        part.CFrame = offset * cylinderAlignment
    end
end

function Wheel:CalculateTreadConnections(): {CFrame}
    local treadConnections = {}
    for index, offset in self.AttachmentOffsets do 
        treadConnections[index] = self.Part.CFrame * offset
    end
    return treadConnections
end




--[[BORK
function Wheel:Update()
    local chassisDown = self.Chassis.CFrame.YVector*-1
    local defaultWheelPosition = self.Chassis.CFrame * self.DefaultC0
    local direction = Vector3.new(0, -20, 0) 

    local result = workspace:Raycast(defaultWheelPosition.Position, direction, self.Tank.RaycastParamsIgnoreSelf)

    if result then
        print'hit smtn'
        -- Transform hit position to chassis local space
        local localHit = self.Chassis.CFrame:PointToObjectSpace(result.Position)
        local localWheel = self.Chassis.CFrame:PointToObjectSpace(defaultWheelPosition.Position)

        local offset = localWheel.Y - localHit.Y

        --local clampedOffset = math.clamp(offset, -self.DownGive, self.UpGive) -- leave room for tread and wheel lol
         
        local newC0 = self.DefaultC0 * CFrame.new(0, offset, 0)
        self.Motor.C0 = self.Motor.C0:lerp(newC0, LERP_FACTOR)
    else
        self.Motor.C0 = self.Motor.C0:lerp(self.DefaultC0* CFrame.new(0, -self.DownGive, 0), LERP_FACTOR)
    end
end]]




--[[

function Tracks:Update(dT)
    local wheelPositions = self:CalculateWheelPositions()
    local currentSpeed = self.Tank.Speed 
    for trackNumber, tracks in self.Treads do  
        local wheel1 = wheelPositions[trackNumber]
        local wheel2 = wheelPositions[trackNumber+1]

        self:SetTread(tracks.Bottom, wheel1.Bottom, wheel2.Bottom, false)
        tracks.Texture.OffsetStudsV = tracks.Texture.OffsetStudsV + (currentSpeed * dT)
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
        x.Bottom:Destroy()
    end
    for _, x in self.Wheels do 
        x.BottomRound:Destroy()
    end
end]]

return Wheel
local TreadSegment = {}
TreadSegment.__index = TreadSegment

local WIDTH = 1.3
local THICKNESS = 0.5

local treadPrefab = Instance.new("Part")
treadPrefab.Color = Color3.fromRGB(45, 44, 39)
treadPrefab.CanCollide = false 
treadPrefab.CanQuery = false 
treadPrefab.Anchored = true
treadPrefab.TopSurface = Enum.SurfaceType.Smooth
treadPrefab.BottomSurface = Enum.SurfaceType.Smooth
treadPrefab.Material = Enum.Material.Leather
treadPrefab.Name = "Tread"

function TreadSegment.new(wheel1: {}, attachment1Index: number, wheel2: {}, attachment2Index: number)
    local self = setmetatable({}, TreadSegment)
    self.Wheel1 = wheel1 
    self.Wheel2 = wheel2 
    self.Attachment1Index = attachment1Index
    self.Attachment2Index = attachment2Index

    self.Part = treadPrefab:Clone() 
    self.Part.Parent = wheel1.Part

    return self
end

function TreadSegment:Update()
    local chassisCFrame = self.Wheel1.Part.CFrame

    local p1 = self.Wheel1.TreadConnections[self.Attachment1Index].Position
    local p2 = self.Wheel2.TreadConnections[self.Attachment2Index].Position
    local between = p2 - p1
    local distance = between.Magnitude
    local midpoint = p1 + (between * 0.5)

    local right = chassisCFrame.RightVector
    local up = right:Cross(between.Unit)

    self.Part.CFrame = CFrame.fromMatrix(midpoint, right, up)
    self.Part.Size = Vector3.new(WIDTH, THICKNESS, distance)
end


return TreadSegment

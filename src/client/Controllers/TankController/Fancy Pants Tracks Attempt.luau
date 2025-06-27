--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local TreadEmitterPrefab =  Assets.VFX.TreadEmitter 

local Tracks = {}
Tracks.__index = Tracks


local beltPart = Assets.TrackPrefab:Clone()
local beltPartLength = beltPart.Size.Z-0.2
local initBeltSize = beltPart.Size
local OVERLAP_DIST = beltPartLength*1.4

function Tracks.new(wheels: Model, tank: { [Model]: Model })
    local self = setmetatable({}, Tracks)
    self.Wheels = {} :: {Wheel: BasePart, Motor: Motor6D, DefaultC0: CFrame, FixedWheel: boolean?, BottomRound: BasePart}
    self.TankModel = tank.Model :: Model
    self.Part0 = self.TankModel.Chassis.FloorPanel

    self.Model = Instance.new("Model")
    self.Model.Name = "Tracks"

    self.EmitterAttachment = Instance.new("Attachment")
    self.EmitterAttachment.Parent = self.Part0 

    self.TrackEmitter = TreadEmitterPrefab:Clone()
    self.TrackEmitter.Parent = self.EmitterAttachment 

    self.Parts = self:GenerateParts() :: {Part}
    self.TrackPoints = self:GenerateTrackPoints(wheels) :: {CFrame} -- Defined as a CFrame offset to the chassis
    self.StartLink = 1 :: number
    self.StartOffset = 0 :: number

    return self
end

function Tracks:GenerateParts() 
    local parts = {}
    for i = 1, 60 do 
        local part = beltPart:Clone() 
        parts[i] = part
        part.Parent = workspace
    end
    return parts
end

function Tracks:GenerateTrackPoints(wheels: Model): {CFrame}
    local sortedWheels = {}

    for _, wheel in wheels:GetChildren() do
        table.insert(sortedWheels, wheel)
    end
    table.sort(sortedWheels, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    local sortedAttachments = {}

    for _, wheel in sortedWheels do 
        local attachments = {}
        
        for _, child in wheel:GetChildren() do 
            if child:IsA("Attachment") then
                table.insert(attachments, child)
            end
        end

        table.sort(attachments, function(a, b)
            return tonumber(a.Name) < tonumber(b.Name)
        end)

        for _, attachment in attachments do
            table.insert(sortedAttachments, attachment)
        end
    end

    local trackPoints = {} :: {CFrame}
    for index, attachment in sortedAttachments do
        trackPoints[index] = self.Part0.CFrame:ToObjectSpace(attachment.WorldCFrame)
    end

    return trackPoints
end

function Tracks:IncrementStartOffset(offset: number)
    self.StartOffset += offset
end

function Tracks:Update()
    -- build world-space CFrames of all attachment points
    local currentAttachmentPoints = {}
    for i, attachCF in ipairs(self.TrackPoints) do
        currentAttachmentPoints[i] = self.Part0.CFrame:ToWorldSpace(attachCF)
    end

    local totalSegments = #currentAttachmentPoints
    local segmentIndex = self.StartLink
    local partIndex    = 1

    -- find initial segment and offset
    local aCF = currentAttachmentPoints[segmentIndex]
    local bCF = currentAttachmentPoints[segmentIndex+1] or currentAttachmentPoints[1]
    local delta = bCF.Position - aCF.Position

    -- if our startOffset pushes us past this segment, advance
    if self.StartOffset > delta.Magnitude then
        self.StartOffset = self.StartOffset - delta.Magnitude
        segmentIndex = segmentIndex + 1
        if segmentIndex > totalSegments then segmentIndex = 1 end
        aCF = currentAttachmentPoints[segmentIndex]
        bCF = currentAttachmentPoints[segmentIndex+1] or currentAttachmentPoints[1]
        delta = bCF.Position - aCF.Position
    end

    -- the world-space point where the first link should sit
    local lastLinkPos = aCF.Position + delta.Unit * self.StartOffset

    -- iterate through each belt part
    while partIndex <= #self.Parts do
        -- refresh segment endpoints
        local aCF = currentAttachmentPoints[segmentIndex]
        local bCF = currentAttachmentPoints[segmentIndex+1] or currentAttachmentPoints[1]
        local aPos, bPos = aCF.Position, bCF.Position

        -- direction to stretch this link
        local dir = (bPos - lastLinkPos).Unit
        local linkLen = beltPartLength

        -- compute the midpoint & look-at target
        local midPoint = lastLinkPos + dir * linkLen * 0.5
        local lookAt   = midPoint + dir

        -- interpolate up-vector between aCF.UpVector and bCF.UpVector
        local totalLen = (bPos - aPos).Magnitude
        local traveled = (midPoint - aPos).Magnitude
        local t
        if totalLen > 0 then
            -- clamp fraction to [0,1]
            t = math.clamp(traveled / totalLen, 0, 1)
        else
            t = 0
        end
        local upA, upB = aCF.UpVector, bCF.UpVector
        local upVec = upA:Lerp(upB, t)

        -- finally, set the CFrame with our custom up-vector
        self.Parts[partIndex].CFrame = CFrame.lookAt(midPoint, lookAt, upVec)

        -- advance
        lastLinkPos = lastLinkPos + dir * linkLen
        partIndex = partIndex + 1

        -- if we just passed bPos, move onto the next segment
        if (lastLinkPos - bPos).Magnitude < 1e-4 then
            segmentIndex = segmentIndex + 1
            if segmentIndex > totalSegments then segmentIndex = 1 end
        end
    end
end

function Tracks:Emit() 

end

function Tracks:Destroy() 

end


return Tracks
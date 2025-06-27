local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local TreadEmitterPrefab =  Assets.VFX.TreadEmitter 

local Wheel = require(script.Wheel)
local TreadSegment = require(script.TreadSegment)

local Tracks = {}
Tracks.__index = Tracks

function Tracks.new(wheels: Model, tank: { [Model]: Model })
    local self = setmetatable({}, Tracks)
    self.Tank = tank 

    self.TankModel = tank.Model :: Model
    self.Part0 = self.TankModel.Chassis.FloorPanel
    self.Model = Instance.new("Model")
    self.Model.Name = "Tracks"

    self.EmitterAttachment = Instance.new("Attachment")
    self.EmitterAttachment.Parent = self.Part0 

    self.TrackEmitter = TreadEmitterPrefab:Clone()
    self.TrackEmitter.Parent = self.EmitterAttachment 

    self.Wheels = self:GenerateWheels(wheels)
    self.Treads = self:GenerateTreads()

    self.Model.Parent = self.TankModel
    return self
end

function Tracks:GenerateWheels(wheels: Model) : {}
    local wheelTable = {}
    for _, wheelObj in wheels:GetChildren() do 
        if wheelObj:IsA("BasePart") then 
            local wheelPart = wheelObj:: Part
            local wheel = Wheel.new(wheelPart, self.Part0, self.Tank)
            table.insert(wheelTable, wheel)
        end
    end

    table.sort(wheelTable, function(v0,v1) 
        return tonumber(v0.Part.Name) < tonumber(v1.Part.Name)
    end)

    return wheelTable
end

function Tracks:Emit(emitFromBack)
    local bottomWheels = {}
    for _, wheel in self.Wheels do 
        if wheel.IsBottom and wheel.TouchingGround then 
            table.insert(bottomWheels, wheel)
        end
    end

    table.sort(bottomWheels, function(v0,v1) 
        return tonumber(v0.Part.Name) < tonumber(v1.Part.Name)
    end)

    if #self.Wheels == 0 then 
        return 
    end
    local wheelNum = 1
    if not emitFromBack then 
        wheelNum = #bottomWheels
    end

    local selectedWheel = bottomWheels[wheelNum]
    if not selectedWheel then 
        return -- fix this at some pt
    end

    --gahhh
    local roundCFrame = selectedWheel.SoothingPoints[math.random(1, #selectedWheel.SoothingPoints)]
    local position = roundCFrame.Position
    local _, y, _ = self.Part0.CFrame:ToEulerAnglesYXZ()

    self.EmitterAttachment.WorldCFrame = CFrame.new(position) * CFrame.Angles(0, y+math.pi, 0)
    self.TrackEmitter:Emit(1)
end

function Tracks:GenerateTreads()
    local treads = {}

    if self.Tank.TankData.BaseAtrributes.SequentialTrackAttachments then 
        local connectionPoints = {}
        for _, wheel in self.Wheels do
            if wheel.NoTread then 
                continue 
            end

            for attachmentIndex, _ in wheel.TreadConnections do
                table.insert(connectionPoints, {Wheel = wheel, AttachmentIndex = attachmentIndex})
            end
        end

        table.sort(connectionPoints, function(v0,v1) 
            return tonumber(v0.AttachmentIndex) < tonumber(v1.AttachmentIndex)
        end)

        for _, attachmentData in connectionPoints do 
            local target = connectionPoints[attachmentData.AttachmentIndex+1]
            if not target then 
                target = connectionPoints[1]
            end

            local tread = TreadSegment.new(attachmentData.Wheel, attachmentData.AttachmentIndex, target.Wheel, target.AttachmentIndex)
            table.insert(treads, tread)
        end
        return treads
    end

    for wheelIndex, wheel in self.Wheels do
        for attachmentIndex, _ in wheel.TreadConnections do 
            local tread 
            if wheel.TreadConnections[attachmentIndex+1]  then -- attach it to this wheel
                tread = TreadSegment.new(wheel, attachmentIndex, wheel, attachmentIndex+1)
            else
                if self.Wheels[wheelIndex+1] and self.Wheels[wheelIndex+1].NoTread == nil then 
                    tread = TreadSegment.new(wheel, attachmentIndex, self.Wheels[wheelIndex+1], 1)
                else
                    tread = TreadSegment.new(wheel, attachmentIndex, self.Wheels[1], 1) -- wrap it round to the starts
                end
            end
            
            table.insert(treads, tread)
        end
    end
    
    return treads
end


function Tracks:Update()
    --Update wheels
    for _, wheel in self.Wheels do 
        wheel:Update(self.Tank.Chassis.TotalDistanceTravelled)
    end

    --Update treads
    for _, tread in self.Treads do 
        tread:Update()
    end
end


function Tracks:Destroy()

end

return Tracks

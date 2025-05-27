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

local ClientTank = {}
ClientTank.__index = ClientTank

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
    
    --Parts
    self.Model = tankModel :: Model
    self.Seat = tankModel:WaitForChild("DriveSeat") :: VehicleSeat
    self.Turret = tankModel:WaitForChild("Turret") :: Model
    self.TurretBase = self.Turret:WaitForChild("Base") :: BasePart
    self.Rotator = self.Turret:WaitForChild("Rotator") :: BasePart
    self.BarrelHinge = self.Rotator:WaitForChild("BarrelHinge") :: HingeConstraint
    self.RotatorServo = self.Turret:WaitForChild("Base"):WaitForChild("RotatorServo") :: HingeConstraint

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



    return self 
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
    self.RotatorServo.TargetAngle = yaw

    -- PITCH from rotator
    local toTarget = (mouseHit - self.Rotator.Position).Unit
    local pitchDir = self.Rotator.CFrame:VectorToObjectSpace(toTarget)
    local pitch = math.deg(math.atan2(pitchDir.Y, -pitchDir.Z))
    self.BarrelHinge.TargetAngle = pitch
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
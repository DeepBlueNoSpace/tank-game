local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets 
local TankGuiPrefab = Assets.Gui.Tank

local PlayerGui = Player:WaitForChild("PlayerGui")

local TankGui = {}
TankGui.__index = TankGui

function TankGui.new(tank: {})
    local self = setmetatable({}, TankGui)
    self.Tank = tank :: {}
    
    self.Gui = self.Tank.Trove:Add(TankGuiPrefab:Clone()) :: ScreenGui
    self.Aimer = self.Gui.Aimer :: ImageLabel 
    self.HealthFill = self.Gui.Health.Fill :: Frame 
    self.HealthValue = self.Gui.Health.Value :: TextLabel 

    self.Gui.Parent = PlayerGui

    self.Tank.Trove:Add(RunService.Heartbeat:Connect(function()
        self:Update()
    end))

    return self
end

function TankGui:UpdateAimingReticle()
    local barrelEndCFrame = self.Tank.Turret.Barrel.BarrelEnd.WorldCFrame
    local origin = barrelEndCFrame.Position
    local direction = barrelEndCFrame.LookVector * 2000 

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {self.Tank}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, direction, raycastParams)
    local hitPosition = result and result.Position or (origin + direction)
    local camera = workspace.CurrentCamera
    local screenPoint = camera:WorldToViewportPoint(hitPosition)

    local aimerTargetPosition = UDim2.fromOffset(screenPoint.X, screenPoint.Y)
    self.Aimer.Position = self.Aimer.Position:lerp(aimerTargetPosition,0.5)
end

function TankGui:UpdateHealthBar()
    local health = self.Tank.Model:GetAttribute("Health")
    local maxHealth = self.Tank.Model:GetAttribute("MaxHealth")
    self.HealthFill.Size = UDim2.fromScale(health/maxHealth, 1)
    self.HealthValue.Text = string.format("%s/%s HP", health, maxHealth)
end

function TankGui:Update()
    self:UpdateAimingReticle()
    self:UpdateHealthBar()
end

function TankGui:Destroy()

end

return TankGui
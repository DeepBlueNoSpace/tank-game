local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets 
local TankGuiPrefab = Assets.Gui.Tank

local PlayerGui = Player:WaitForChild("PlayerGui")

local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankGui = {}
TankGui.__index = TankGui

function TankGui.new(tank: {})
    local self = setmetatable({}, TankGui)
    self.Tank = tank :: {}
    
    self.Gui = self.Tank.Trove:Add(TankGuiPrefab:Clone()) :: ScreenGui
    self.Aimer = self.Gui.Aimer :: ImageLabel 
    self.HealthFill = self.Gui.Health.Fill :: Frame 
    self.HealthValue = self.Gui.Health.Value :: TextLabel 

    self.MobileFire = self.Gui:WaitForChild("MobileFire") :: ImageButton

    self.Gui.Parent = PlayerGui

    self.Tank.Trove:Add(RunService.Heartbeat:Connect(function()
        self:Update()
    end))

    self.ThumbstickStart = nil :: ImageLabel?
    self.ThumbstickEnd = nil :: ImageLabel?

    local touchGui = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui") :: ScreenGui

    if touchGui then
        self:SetUpMobile(touchGui)
    else
        self.Tank.Trove:Add(PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == "TouchGui" then
                self:SetUpMobile(touchGui)
            end
        end))
    end
    return self
end

function TankGui:SetUpMobile(touchGui: ScreenGui) 
    -- realistically this should never fail right?
    local controlFrame = touchGui:WaitForChild("TouchControlFrame", 1) :: Frame? 
	if not controlFrame then
		return
	end

	local DThumbstickFrame = controlFrame:WaitForChild("DynamicThumbstickFrame", 1) :: Frame?
	if not DThumbstickFrame then
		return
	end
	
    self.ThumbstickStart = DThumbstickFrame:WaitForChild("ThumbstickStart") :: ImageLabel
	self.ThumbstickEnd = DThumbstickFrame:WaitForChild("ThumbstickEnd") :: ImageLabel

    self.MobileFire.Visible = true -- This will be replaced with a generic hide and show mobile UI function function presumably
    self.MobileFire.Activated:Connect(function() 
        self.Tank:AttemptFire()
    end)
end

function TankGui:UpdateAimingReticle()
    local barrelEndPosition = self.Tank.Turret.Barrel.BarrelEnd.WorldPosition
    local rayYaw = math.rad(self.Tank.BarrelYaw)
    local rayPitch = math.rad(self.Tank.BarrelPitch)

    local direction = CFrame.fromEulerAnglesYXZ(rayPitch, rayYaw, 0).LookVector * 2000

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {self.Tank}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(barrelEndPosition, direction, raycastParams)
    local hitPosition = result and result.Position or (barrelEndPosition + direction)

    local camera = workspace.CurrentCamera
    local screenPoint = camera:WorldToViewportPoint(hitPosition)

    local aimerTargetPosition = UDim2.fromOffset(screenPoint.X, screenPoint.Y)
    self.Aimer.Position = self.Aimer.Position:lerp(aimerTargetPosition, 0.5)

    self.Tank.TankAimPosition = hitPosition
end

function TankGui:UpdateHealthBar()
    local health = self.Tank.Model:GetAttribute("Health")
    local maxHealth = self.Tank.Model:GetAttribute("MaxHealth")
    self.HealthFill.Size = UDim2.fromScale(health/maxHealth, 1)
    self.HealthValue.Text = string.format("%s/%s HP", tostring(math.floor(0.5+health)), maxHealth)
end

function TankGui:Update()
    self:UpdateAimingReticle()
    self:UpdateHealthBar()

    local mobileJumpButton = PlayerGui:FindFirstChild("JumpButton", true)
    if mobileJumpButton then 
        mobileJumpButton.Visible = false 
    end

    if self.ThumbstickStart and self.ThumbstickEnd then 
        self:ComputeMobileThrottle()
    end
end

local zScaling = 100 -- TODO: Scale to screen size
function TankGui:ComputeMobileThrottle()
    self.Tank.IsJoystickControlled = true 

    if self.ThumbstickEnd.ImageTransparency == 1 then
        -- there is no current input, throttle to 0 
        self.Tank.JoystickThrottle = {Z=0,X=0, Braking = true} :: Types.JoystickThrottle
        return
    end

    local startP = self.ThumbstickStart.AbsolutePosition
    local endP = self.ThumbstickEnd.AbsolutePosition
    local delta = endP - startP

    local Z = math.clamp(delta.Y/zScaling, -1, 1) * -1
    local X = math.clamp(delta.X/zScaling, -1, 1) * -1

    local throttle = {
        Z = Z;
        X = X, 
        Braking = false
    } :: Types.JoystickThrottle

    self.Tank.JoystickThrottle = throttle 
end

function TankGui:Destroy()

end

return TankGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local GuiAssets = ReplicatedStorage.Assets.Gui 
local TankGuiPrefab = GuiAssets.Tank

local PlayerGui = Player:WaitForChild("PlayerGui")

local Types = require(ReplicatedStorage.Shared.Data.Types)
local HitboxData = require(ReplicatedStorage.Shared.Data.HitboxData)
local HitNeedle = require(script.Parent.HitNeedle)

local TankGui = {}
TankGui.__index = TankGui

function TankGui.new(tank: {})
    local self = setmetatable({}, TankGui)
    self.Tank = tank :: {}
    self.HitNeedles = {} :: {[string]:{}}

    self.Gui = self.Tank.Trove:Add(TankGuiPrefab:Clone()) :: ScreenGui
    self.Aimer = self.Gui:FindFirstChild("Aimer") :: ImageLabel 
    self.HealthFill = self.Gui:FindFirstChild("Health").Fill :: Frame 
    self.HealthValue = self.Gui:FindFirstChild("Health").Value :: TextLabel 
    self.MunitionsFrame = self.Gui:FindFirstChild("Munitions") :: Frame 
    self.MobileFire = self.Gui:WaitForChild("MobileFire") :: ImageButton
    self.Reticle = self.Gui:FindFirstChild("Reticle") :: ImageLabel
    self.CooldownProgress = self.Reticle.Progress 
    self.CooldownGradient1 = self.CooldownProgress.Frame1.Top.UIGradient 
    self.CooldownGradient2 = self.CooldownProgress.Frame2.Top.UIGradient 
    self.Gui.Parent = PlayerGui

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

    self:HandleDoingDamage()
    self:HandleReceivingDamage()
    self.Tank.Trove:Add(RunService.Heartbeat:Connect(function()
        self:Update()
    end))

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

    local result = workspace:Raycast(barrelEndPosition, direction, self.Tank.RaycastParamsIgnoreSelf)
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

function TankGui:UpdateCooldown()
    local i = (tick() - self.Tank.LastShotTime)/self.Tank.Cooldown 
    if i > 1 then 
        self.CooldownProgress.Visible = false 
    else
        self.CooldownProgress.Visible = true 
    end 

    local degs = 360*i 
    self.CooldownGradient1.Rotation = math.clamp(180-degs, 0,180)
    self.CooldownGradient2.Rotation = math.clamp(180-degs, -180,0)
end

function TankGui:Update()
    self:UpdateAimingReticle()
    self:UpdateHealthBar()
    self:UpdateCooldown()

    local mobileJumpButton = PlayerGui:FindFirstChild("JumpButton", true)
    if mobileJumpButton then 
        mobileJumpButton.Visible = false 
    end

    if self.ThumbstickStart and self.ThumbstickEnd then 
        self:ComputeMobileThrottle()
    end

    for playerName, needle in self.HitNeedles do 
        local removeIndex = needle:Update() 
        if removeIndex then 
            self.HitNeedles[playerName] = nil
        end
    end
end

function TankGui:HandleDoingDamage()
    self.Tank.Trove:Add(self.Tank.DamageService.DidDamage:Connect(function(damage: number, hitbox: string, directHit: boolean)
        local hitMessage = string.format("[%s %s]", directHit and "DIRECT" or "INDIRECT", string.upper(hitbox))
        
        local damageUI = GuiAssets.Damage:Clone() 
        damageUI.Side.Text = hitMessage
        damageUI.Side.TextColor3 = HitboxData[hitbox].Color 
        damageUI.Value.Text = tostring(math.floor(0.5+damage))
    
        damageUI.Parent = self.Gui 

        task.delay(2, function() 
            damageUI:Destroy()
        end)
    end))
end

function TankGui:HandleReceivingDamage() 
    self.Tank.Trove:Add(self.Tank.DamageService.TookDamage:Connect(function(playerName: string, damage: number)
        local existingNeedle = self.HitNeedles[playerName]
        if existingNeedle then 
            existingNeedle:AddDamage(damage)
            return
        end

        local attacker = Players[playerName]
        if not attacker then 
            return 
        end

        local needle = HitNeedle.new(attacker, damage)
        self.HitNeedles[playerName] = needle

        needle.Needle.Parent = self.Gui
        print'ya'
    end))
end

function TankGui:Destroy()

end

return TankGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiAssets = ReplicatedStorage.Assets.Gui 
local TweenService = game:GetService("TweenService")

local TankUtil = require(ReplicatedStorage.Shared.Modules.TankUtil)

local Camera = workspace.Camera

local NeedlePrefab = GuiAssets.Needle

local FADE_COOLDOWN = 0.5
local FADE_PER_FRAME = 2 --TODO: make this scale with local tank health
local OFFSET = 0.35 -- the amount of pixels the tag should be offset from the centre as a % of the Y Axis
local MIN_TRANSPARENCY = 0.2
local MAX_TRANSPARENCY = 1
local MAX_RED = Color3.fromRGB(213, 10, 8)
local MIN_RED = Color3.fromRGB(254, 76, 88)

local HitNeedle = {}
HitNeedle.__index = HitNeedle


function HitNeedle.new(shooter: Player, initalDamage: number)
	local self = setmetatable({}, HitNeedle)
	self.OriginTank = TankUtil.GetPlayerTank(shooter)
	if not self.OriginTank then 
		return 
	end

	self.ShownDamage = initalDamage
	self.LastDamaged = tick()
	self.Needle = NeedlePrefab:Clone()
	self.Player = shooter

	return self
end

function HitNeedle:AddDamage(damage: number)
	self.ShownDamage += damage
end

function HitNeedle:Destroy()
	self.Needle:Destroy()
end

local function lerp(v0: number, v1: number, t: number)
	return v0 + (v1-v0) * t 
end


function HitNeedle:Update()
	local tD = tick() - self.LastDamaged
	if tD >= FADE_COOLDOWN then
		self.ShownDamage -= FADE_PER_FRAME
		if self.ShownDamage <= 0 then
			self:Destroy()
			return true
		end
	end

	local needle = self.Needle
	local target = self.OriginTank

	if not target.Parent then 
		self:Destroy()
		return true
	end

	local rootPart = target.PrimaryPart
	if not rootPart then
		self:Destroy()
		return true
	end

	if not rootPart.Parent then
		self:Destroy()
		return true
	end

	local targetRootPosition = rootPart.Position

	local totalPixelOffset = Camera.ViewportSize.Y * OFFSET

	local flatCameraCFrame = CFrame.new(Camera.CFrame.p, Camera.CFrame.p + Camera.CFrame.lookVector * Vector3.new(1, 0, 1))
	local pointRelativeToCamera = flatCameraCFrame:pointToObjectSpace(targetRootPosition)
	local unitRelativeVector = (pointRelativeToCamera * Vector3.new(1, 0, 1)).unit

	needle.Position = UDim2.new(0.5, unitRelativeVector.X * totalPixelOffset, 0.5,
		unitRelativeVector.Z * totalPixelOffset)
	needle.Rotation =  180 - math.deg(math.atan2(unitRelativeVector.X, unitRelativeVector.Z))

	local scalar = math.clamp(TweenService:GetValue(self.ShownDamage/500, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),0,1)

	needle.ImageColor3 = MIN_RED:lerp(MAX_RED, scalar)
	needle.ImageTransparency = lerp(MAX_TRANSPARENCY, MIN_TRANSPARENCY, scalar)

	return false
end

return HitNeedle
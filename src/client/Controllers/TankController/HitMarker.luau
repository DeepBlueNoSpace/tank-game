--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiAssets = ReplicatedStorage.Assets.Gui 

local Camera = workspace.CurrentCamera

local HitMarkerPrefab = GuiAssets.HitMarker :: ImageLabel

local SHOW_TIME = 0.3

local HitMarker = {}
HitMarker.__index = HitMarker

export type HitMarker = {
	Marker: ImageLabel,
	WorldPosition: Vector3,
	StartTime: number
} & typeof(HitMarker)

function HitMarker.new(worldPosition: Vector3, directHit: boolean): HitMarker
	local self = setmetatable({}:: HitMarker , HitMarker)
	self.Marker = HitMarkerPrefab:Clone() :: ImageLabel
	self.WorldPosition = worldPosition
	self.StartTime = tick() 

	if directHit then 
		self.Marker.ImageColor3 = Color3.fromRGB(255, 119, 119)
	end

	self:Update()
	return self
end

function HitMarker:Update() : boolean
	local t = tick() - self.StartTime 
	if t > SHOW_TIME then 
		self:Destroy()
		return true 
	end

	local screenPos, onScreen = Camera:WorldToViewportPoint(self.WorldPosition)

	if onScreen then
		local uiPosition = UDim2.fromOffset(screenPos.X, screenPos.Y)
		self.Marker.Position = uiPosition
		self.Marker.Visible = true
	else
		self.Marker.Visible = false
	end

	return false
end

function HitMarker:Destroy()
	self.Marker:Destroy()
end


return HitMarker
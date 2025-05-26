local TO_SCALE = { "LeftPec", "RightPec" }
local scale_factor = Vector3.new(1.05, 1, 1)

local model = workspace.CURRSELECTED

for _, muscle in pairs(TO_SCALE) do
	local musclePart = model.Muscles:FindFirstChild(muscle, true)
	musclePart.Size = musclePart.Size * scale_factor
end

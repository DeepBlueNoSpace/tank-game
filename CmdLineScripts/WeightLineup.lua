local ref = workspace.WEIGHT_WIP.WEIGHTLABEL

for i = 1, 100 do
	local x = ref:Clone()
	x.Name = i
	x.SurfaceGui.TextLabel.Text = i
	x.CFrame = ref.CFrame * CFrame.new(0, 0, -i * 20)
	x.Parent = workspace.WEIGHT_WIP
end

--- layout weights

-- print selection -----------------------------------

local selectedItems = game:GetService("Selection"):Get()
local str = ""
for _, item in ipairs(selectedItems) do
	str = str .. item.Name .. "\n"
end
print(str)

-- rig weights -------------------------------------

local function clean(weightModel)
	for i, v in pairs(weightModel:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Weights"
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.Massless = true
		elseif v:IsA("Weld") or v:IsA("WeldConstraint") then
			if not weightModel:FindFirstChild("Humanoid", true) then
				v:Destroy()
			end
		end
	end

	for i, v in pairs(weightModel:GetDescendants()) do
		if v == weightModel.PrimaryPart then
			continue
		end

		if v:IsA("BasePart") then
			local x = Instance.new("WeldConstraint")
			x.Part0 = weightModel.PrimaryPart
			x.Part1 = v
			x.Name = "AutoWeld_" .. v.Name
			x.Parent = weightModel.PrimaryPart
		end
	end
end

local function updateAttach(model)
	local attach = model.PrimaryPart:FindFirstChild("HandAttachment")
	if not attach then
		attach = Instance.new("Attachment")
		attach.Name = "HandAttachment"
		attach.Parent = model.PrimaryPart
	end

	local _, size = model:GetBoundingBox()

	attach.Position = Vector3.new(0, 0, size.Z / 2)
	attach.Orientation = Vector3.new(0, 0, 0)
end

local function rigWeight(weight)
	local model = weight
	if weight:IsA("BasePart") then
		model = Instance.new("Model")
		weight.Parent = model
		model.Name = weight.Name
		weight.Name = "PrimaryPart"
		model.PrimaryPart = weight
		weight.Anchored = false
	end

	if not model:IsA("Model") then
		warn("err with:", model)
	end

	clean(model)
	return model
end

local selectedItems = game:GetService("Selection"):Get()
for _, item in ipairs(selectedItems) do
	local model = rigWeight(item)
	updateAttach(model)
	model.Parent = workspace.RIGGEDWEIGHTS
end

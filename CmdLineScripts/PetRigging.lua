local function rig(pet)
	local originalModel = pet
	local ogParent = pet.Parent
	pet = pet:Clone()
	local petModel = nil
	if pet:IsA("BasePart") then
		petModel = Instance.new("Model")
		petModel.PrimaryPart = pet
		petModel.Name = pet.Name
		pet.Name = "PrimaryPart"
		pet.Parent = petModel
	elseif pet:IsA("Model") then
		petModel = pet
		if not petModel.PrimaryPart then
			warn(petModel, "Missing primary part")
			return
		end
	end

	local partsModel = petModel:FindFirstChild("Parts")
	if not partsModel then
		partsModel = Instance.new("Model")
		partsModel.Name = "Parts"
		partsModel.Parent = petModel
	end

	for i, v in pairs(partsModel:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then
			v:Destroy()
		end
	end

	if not partsModel.PrimaryPart then
		-- move the primary part to the parts model
		local ogPrimaryPart = petModel.PrimaryPart
		ogPrimaryPart.Parent = partsModel
		partsModel.PrimaryPart = ogPrimaryPart
		ogPrimaryPart.Name = "PartsRoot"

		-- generate new invisible fake base part
		local newPrimaryPart = Instance.new("Part")
		newPrimaryPart = Instance.new("Part")
		newPrimaryPart.Name = "PrimaryPart"
		newPrimaryPart.CanCollide = false
		newPrimaryPart.Size = ogPrimaryPart.Size
		newPrimaryPart.CFrame = ogPrimaryPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
		newPrimaryPart.CanCollide = false
		newPrimaryPart.Anchored = false
		newPrimaryPart.Transparency = 1
		newPrimaryPart.Massless = true
		newPrimaryPart.Parent = petModel
		petModel.PrimaryPart = newPrimaryPart

		-- weld the partsmodel pp to the root pp
		-- welld partsRoot to the true primarypart
		local weld = Instance.new("Motor6D")
		weld.Part0 = newPrimaryPart
		weld.Part1 = ogPrimaryPart
		weld.Parent = newPrimaryPart
		weld.C1 = CFrame.new(0, 0, 0) --* CFrame.Angles(0, math.rad(90), 0)
		--weld.Part0 = ogPrimaryPart
		--weld.Part1 = newPrimaryPart
		--weld.Parent = ogPrimaryPart
		weld.Name = "PrimaryPart"
	end

	for i, v in pairs(petModel:GetDescendants()) do
		if v:IsA("BasePart") and v ~= petModel.PrimaryPart and v ~= partsModel.PrimaryPart then
			v.Parent = partsModel
			v.Anchored = false
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.Massless = true

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = partsModel.PrimaryPart
			weld.Part1 = v
			weld.Parent = v
			weld.Name = "PartsRoot"
		elseif v == petModel.PrimaryPart then
			v.Anchored = false
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.Massless = true
		end
	end

	local animController = petModel:FindFirstChild("AnimationController")
	if not animController then
		animController = Instance.new("AnimationController")
		animController.Parent = petModel
	end

	petModel.Parent = ogParent
	originalModel:Destroy()
end

local selectedItems = game:GetService("Selection"):Get()

local str = ""
local found = {}
for _, item in ipairs(selectedItems) do
	found[item.Name] = true
	str = str .. item.Name .. "\n"
	rig(item)
end
print(str)

--- Convert pets back into parts
local selectedItems = game:GetService("Selection"):Get()

for _, item in ipairs(selectedItems) do
	local name = item.Name
	local baseMeshPart = item.Parts.PrimaryPart
	local x = baseMeshPart:Clone()
	x.Name = name
	x.Parent = workspace.PetsWaitingZone
end

-- convert bad pets back to parts
local selectedItems = game:GetService("Selection"):Get()

for _, item in ipairs(selectedItems) do
	local name = item.Name
	local baseMeshPart = item.Parts["OldPrimaryPart"]
	local x = baseMeshPart:Clone()
	x.Name = name
	x.Parent = workspace.PetsWaitingZone
end

for i, v in pairs(workspace.PetsWaitingZone:GetDescendants()) do
	if not v:IsA("BasePart") then
		v:Destroy()
	end
end

-- Delete pets so can copy over

for i, v in pairs(workspace.PetsWaitingZone:GetChildren()) do
	local x = game.ReplicatedStorage.Assets.Pets:FindFirstChild(v.Name)
	if x then
		x:Destroy()
	end

	v.Parent = game.ReplicatedStorage.Assets.Pets
end

---- Align pet floors

--local selectedItems = game:GetService("Selection"):Get()
--
--for _, item in ipairs(selectedItems) do
--	local partsPP = item.Parts.PartsRoot
--	local rootPP = item.PrimaryPart
--
--	rootPP.CFrame = partsPP.CFrame * CFrame.new(0, rootPP.Size.Y / 2, 0)  * CFrame.new(0, -partsPP.Size.Y / 2, 0)
--end

-----------------------------------
-- ROTATE PETS

local Y_ROT = 90

local function updateRot(model)
	local parts = model.Parts
	local oldPP = model.PrimaryPart
	local newPP = Instance.new("Part")
	newPP.Size = oldPP.Size
	newPP.CFrame = oldPP.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(Y_ROT), 0)
	newPP.Anchored = false
	newPP.CanCollide = false
	newPP.CastShadow = false
	newPP.Transparency = 1
	newPP.Parent = oldPP.Parent

	oldPP.Name = "OldPrimaryPart"
	newPP.Name = "PrimaryPart"

	oldPP.Parent = parts

	model.PrimaryPart = newPP

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = oldPP
	weld.Part1 = newPP
	weld.Parent = oldPP
	weld.Name = newPP.Name
end

for _, item in ipairs(game:GetService("Selection"):Get()) do
	updateRot(item)
end

------------------
-- PRINT SELECTION

local str = ""
for _, item in ipairs(game:GetService("Selection"):Get()) do
	str = str .. item.Name .. "\n"
end
print(str)

------------------
-- Convert eggs to models

for _, item in ipairs(game:GetService("Selection"):Get()) do
	local pp = item
	local model = Instance.new("Model")
	model.Name = pp.Name
	model.Parent = pp.Parent
	pp.Parent = model
	model.PrimaryPart = pp
end

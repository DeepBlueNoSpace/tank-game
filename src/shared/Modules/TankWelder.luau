local tank = workspace.Tank 
local turret = tank.Turret 
local armour = tank.Armour 

local function weldTo(x, y)

	local motor = Instance.new("Motor6D")
	motor.Name = x.Name .. "_Motor_" .. y.Name
	motor.Part0 = x
	motor.Part1 = y

	-- Create the attachments based on current positions
	motor.C0 = x.CFrame:ToObjectSpace(y.CFrame)
	motor.C1 = CFrame.new() -- Assume Part1 is at its origin relative to itself

	motor.Parent = y
end

local selection = game:GetService("Selection"):Get()
weldTo(selection[1], selection[2])


for _, part in armour.Barrel:GetChildren() do 
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = turret.Barrel
    weld.Part1 = part 
    weld.Parent = armour.Barrel
end

for _, part in armour.Turret:GetChildren() do 
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = turret.Rotator
    weld.Part1 = part 
    weld.Parent = armour.Turret
end

for _, part in armour.Base:GetChildren() do 
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = tank.Misc.Chassis
    weld.Part1 = part
    weld.Parent = tank.Misc.Chassis
end


local tank = workspace:FindFirstChild("BaseTank")
if not tank then error("BaseTank not found") end

-- List of wheel names and sides
local wheelNames = {
	{ name = "L1WH", side = -1 },
	{ name = "L2WH", side = -1 },
	{ name = "L3WH", side = -1 },
	{ name = "R1WH", side = 1 },
	{ name = "R2WH", side = 1 },
	{ name = "R3WH", side = 1 },
}

-- Corrected wheel dimensions
local wheelDiameter = 1.2
local wheelThickness = 3 -- axle depth (Y-axis)
local wheelSize = Vector3.new(wheelDiameter, wheelThickness, wheelDiameter)

for _, entry in ipairs(wheelNames) do
	local oldWheel = tank:FindFirstChild(entry.name)
	if oldWheel and oldWheel:IsA("BasePart") then
		local parent = oldWheel.Parent
		local children = oldWheel:GetChildren()

		local newWheel = Instance.new("Part")
		newWheel.Shape = Enum.PartType.Cylinder
		newWheel.Name = entry.name
		newWheel.Size = wheelSize
		newWheel.Anchored = false
		newWheel.CanCollide = true
		newWheel.Material = Enum.Material.Metal
		newWheel.Parent = parent

		-- Rotate 90° about X to lie flat, then offset along X-axis based on thickness
		local offset = Vector3.new((wheelThickness / 2 + 0.05) * entry.side, 0, 0)
		newWheel.CFrame = oldWheel.CFrame * CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(offset)

		-- Move attachments/constraints
		for _, obj in ipairs(children) do
			obj.Parent = newWheel
		end

		oldWheel:Destroy()
	end
end



local function weldTo(x, y)

	local motor = Instance.new("Motor6D")
	motor.Name = y.Name .. "_Motor"
	motor.Part0 = x
	motor.Part1 = y

	-- Create the attachments based on current positions
	motor.C0 = x.CFrame:ToObjectSpace(y.CFrame)
	motor.C1 = CFrame.new() -- Assume Part1 is at its origin relative to itself

	motor.Parent = x
end

local selection = game:GetService("Selection"):Get()

for i = 2, #selection do 
	local object = selection[i]
	weldTo(selection[1], object)
end

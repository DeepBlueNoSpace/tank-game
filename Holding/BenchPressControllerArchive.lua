local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local BenchPressUI = nil
local TrainingService = nil

local Trove = require(Knit.Packages.Trove)
local NumberUtil = require(Knit.Modules.NumberUtil)

local Player = game.Players.LocalPlayer
--local MainGui = Player.PlayerGui:WaitForChild("MainGui")

local BenchPressController = Knit.CreateController({ Name = "BenchPressController" })
--[[

BenchPressController.Trove = Trove.new()
BenchPressController.Animations = {}
BenchPressController.EquippedWeights = {} -- {["2.5"]=1, ["5"]=2}...Dictionary of weights on bar; mirrored across barbell, so 2x for total weight
BenchPressController.TotalWeight = 0
BenchPressController.CurrentEquipment = nil

local WEIGHT_OPTIONS = {2.5, 5, 10, 25, 50, 100}

]]

-- TODO move this logic to server so weights replicate
--[[local function updateWeights()
    local sum = 0
    for weightName, count in pairs(BenchPressController.EquippedWeights) do
        sum = sum + count * tonumber(weightName)
    end
    BenchPressController.TotalWeight = sum

    BenchPressController.CurrentEquipment.Bar.DynamicWeights:ClearAllChildren()
    BenchPressController.CurrentEquipment.Bar.LeftWeightPlaceholder.Transparency = 1
    BenchPressController.CurrentEquipment.Bar.RightWeightPlaceholder.Transparency = 1
    local leftOffset = BenchPressController.CurrentEquipment.Bar.PrimaryPart.CFrame:ToObjectSpace(BenchPressController.CurrentEquipment.Bar.LeftWeightPlaceholder.CFrame)
    local rightOffset = BenchPressController.CurrentEquipment.Bar.PrimaryPart.CFrame:ToObjectSpace(BenchPressController.CurrentEquipment.Bar.RightWeightPlaceholder.CFrame)

    -- convert weight keys to a dictionary and sort; biggest weights go inside
    local orderedWeights = {}
    for weightName, _ in pairs(BenchPressController.EquippedWeights) do
        table.insert(orderedWeights, weightName)
    end
    table.sort(orderedWeights, function(a,b) return tonumber(a) > tonumber(b) end)

    for i, weightName in pairs(orderedWeights) do
        local template = BenchPressController.CurrentEquipment.WeightTemplates[weightName]
        local numEquipped = BenchPressController.EquippedWeights[weightName]
        for j=1, numEquipped do
            local right = template:Clone()
            right.Parent = BenchPressController.CurrentEquipment.Bar.DynamicWeights
            right.CFrame = BenchPressController.CurrentEquipment.Bar.PrimaryPart.CFrame * rightOffset
            rightOffset = rightOffset * CFrame.new(0, -right.Size.Y - 0.02, 0 )

            local left = template:Clone()
            left.Parent = BenchPressController.CurrentEquipment.Bar.DynamicWeights
            left.CFrame = BenchPressController.CurrentEquipment.Bar.PrimaryPart.CFrame * leftOffset
            leftOffset = leftOffset * CFrame.new(0, left.Size.Y + 0.02, 0)
        end
    end


    BenchPressUI:UpdateWeightSelectionButtons(BenchPressController.EquippedWeights, NumberUtil.Shorten(sum))
end]]

local function doPress()
	if BenchPressController.Animations["Activate"].IsPlaying then
		--- Todo "heat" / speed up animation with more clicks
		return
	end

	BenchPressController.Animations["Idle"]:Stop()
	BenchPressController.Animations["Activate"]:Play()

	TrainingService:RequestWorkout("BenchPress", BenchPressController.TotalWeight)

	local stoppedConnection = nil
	stoppedConnection = BenchPressController.Trove:Add(BenchPressController.Animations["Activate"].Stopped:Connect(function()
		BenchPressController.Animations["Idle"]:Play()
		stoppedConnection:Disconnect()
	end))
end

-- Public functions

function BenchPressController:AddWeight(weightName)
	--[[print("Add", weightName)
    if not BenchPressController.EquippedWeights[weightName] then
        warn("Invalid weight: " .. weightName)
        return
    end
    BenchPressController.EquippedWeights[weightName] = BenchPressController.EquippedWeights[weightName] + 1

    updateWeights()]]
end

function BenchPressController:RemoveWeight(weightName)
	--[[print("Remove", weightName)
    if not BenchPressController.EquippedWeights[weightName] then
        warn("Invalid weight: " .. weightName)
        return
    end
    BenchPressController.EquippedWeights[weightName] = math.max(BenchPressController.EquippedWeights[weightName] - 1, 0)

    updateWeights()]]
end

function BenchPressController:StartWorkout(model)
	--[[BenchPressController.CurrentEquipment = model

    local character = Player.Character
    initAnims()

    -- Initialize to 0 weights
    -- TODO: store in settings?
    -- TODO: derive possible weights from the benchpressModel
    BenchPressController.EquippedWeights = {}
    BenchPressController.TotalWeight = 0
    for _, weightName in pairs(WEIGHT_OPTIONS) do
        BenchPressController.EquippedWeights[weightName] = 0
    end
    updateWeights()

    BenchPressController.Animations["Idle"]:Play()
    ]]
end

local function setupBarbell(barbell: Model)
	local trove = Trove.new()
	local character = game.Players.LocalPlayer.Character

	-- The bar dynamically follows the player's hands
	local angle = barbell.PrimaryPart.CFrame - barbell.PrimaryPart.Position
	trove:Add(RunService.RenderStepped:Connect(function(dt)
		barbell:SetPrimaryPartCFrame(
			CFrame.new(character.LeftHand.Position - (character.LeftHand.Position - character.RightHand.Position) / 2 + Vector3.new(0, 0.1, 0)) * angle -- add in original orientation
		)
	end))

	return trove
end

function BenchPressController:InitEquipment(equipment: Model, playerWeights: { [string]: Model })
	return setupBarbell(playerWeights.Barbell)
end

function BenchPressController:KnitInit()
	BenchPressUI = Knit.GetController("BenchPressUI")
	TrainingService = Knit.GetService("TrainingService")
end

function BenchPressController:KnitStart() end

return BenchPressController

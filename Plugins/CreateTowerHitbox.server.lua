local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

-- Create a new toolbar section titled "Custom Script Tools"
local toolbar = plugin:CreateToolbar("Create Hitbox")
local newScriptButton = toolbar:CreateButton("Create Tower Hitbox", "Create Tower Hitbox", "rbxassetid://14978048121")
newScriptButton.ClickableWhenViewportHidden = true

newScriptButton.Click:Connect(function()
    local selected = Selection:Get()
    if #selected ~= 1 then
        warn("Select exactly 1 model")
        return
    end

    local rig = selected[1]

    if not rig:IsA("Model") then
        warn("Select a model")
        return
    end
    if not rig.PrimaryPart then
        warn("Give rig primary part")
        return
    end
    if rig:FindFirstChild("AnimSaves") then
        warn("Rig has animsaves!")
    end

    rig.Name = "Rig"
    local model = Instance.new("Model")
    model.Name = "UnitName"
    model.Parent = rig.Parent
    rig.Parent = model


    local primaryPart = rig.PrimaryPart
    rig.PrimaryPart = nil

    local cf, size = model:GetBoundingBox()
    rig.PrimaryPart = primaryPart

    local hitboxPart = Instance.new("Part")
    hitboxPart.Size = size
    hitboxPart.CFrame = cf
    hitboxPart.Color = Color3.new(255, 0, 191)
    hitboxPart.CanCollide = false
    hitboxPart.Transparency = 0.5
    hitboxPart.Anchored = true
    hitboxPart.Parent = model

    model.PrimaryPart = hitboxPart

    -- hitnox
    local floorAttachment = Instance.new("Attachment")
    floorAttachment.Parent = hitboxPart
    floorAttachment.Name = "FloorAttachment"
    floorAttachment.CFrame = CFrame.new(Vector3.new(0,-hitboxPart.Size.Y/2,0))

    -- rig floor attachment
    local rigFloorAttachment = Instance.new("Attachment")
    rigFloorAttachment.Parent = rig.PrimaryPart
    rigFloorAttachment.Name = "FloorAttachment"
    rigFloorAttachment.WorldCFrame = floorAttachment.WorldCFrame

    -- ui  attachment
    local uiAttachment = Instance.new("Attachment")
    uiAttachment.Parent = rig.PrimaryPart
    uiAttachment.Name = "FloorAttachment"
    uiAttachment.CFrame = CFrame.new(0,5,0)




end)


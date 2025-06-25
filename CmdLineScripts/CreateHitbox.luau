local function createHitbox(model)
    local cf, size = model:GetBoundingBox()
    local part = Instance.new("Part")
    part.Size = size
    part.CFrame = cf
    part.Anchored = true
    part.CanCollide = false
    part.Name = "Hitbox"
    part.Transparency = 0.5
    part.BrickColor = BrickColor.new("Hot pink")
    part.Parent = model
end

local selection = game:GetService("Selection"):Get()
for _, v in ipairs(selection) do
    createHitbox(v)
end
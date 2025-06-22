for i,v in pairs(workspace.EndgameScene.Prefabs:GetChildren()) do
    local cf, size = v:GetBoundingBox()
    local part = Instance.new("Part")
    part.Size = size
    part.CFrame = cf
    part.Anchored = true
    part.CanCollide = false
    part.Name = "TankPart"
    part.Transparency = 0.5
    part.BrickColor = BrickColor.new("Hot pink")
    part.Parent = v.Parent
end
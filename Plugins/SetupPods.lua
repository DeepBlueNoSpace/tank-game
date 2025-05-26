local pods = {
    [1] = CFrame.new(-76.9499817, 12.2714844, 603.068909, -1, 0, -0, 0, 0, -1, 0, -1, -0),
    [2] = CFrame.new(-76.9499817, 12.2714844, 648.268921, -1, 0, -0, 0, 0, -1, 0, -1, -0),
    [3] = CFrame.new(-76.9499817, 12.2714844, 693.718933, -1, 0, -0, 0, 0, -1, 0, -1, -0),
    [4] = CFrame.new(-172.546387, 12.2714844, 603.305359, 1, 0, 0, 0, 0, -1, 0, 1, 0),
    [5] = CFrame.new(-172.546387, 12.2714844, 648.755371, 1, 0, 0, 0, 0, -1, 0, 1, 0),
    [6] = CFrame.new(-172.546387, 12.2714844, 693.955383, 1, 0, 0, 0, 0, -1, 0, 1, 0),

}

local podTemplate = workspace.PODTEMPLATE

for i,v in pairs(pods) do
    local newPod = podTemplate:Clone()
    newPod.Name = "LevelSelector_"..i
    newPod:SetPrimaryPartCFrame(v)
    newPod.Parent = workspace.Lobby.Interactables.DefaultLevelSelectors
end
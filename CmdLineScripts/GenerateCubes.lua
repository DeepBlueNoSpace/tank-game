local refCube = game.ReplicatedStorage.Assets.Weights.blue_cube

for i = 1, 100 do
	local x = refCube:Clone()
	x.PrimaryPart.Color = Color3.new(math.random(), math.random(), math.random())
	x.Name = "cube_" .. i
	x.Parent = game.ReplicatedStorage.Assets.Weights
end

local Selection = game:GetService("Selection")

for _, object in pairs(Selection:Get()) do
	print(object.CFrame)
end
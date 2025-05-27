local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

-- expose modules and assets
Knit.Packages = ReplicatedStorage.Packages
Knit.Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
Knit.Assets = ReplicatedStorage:WaitForChild("Assets")
Knit.Data = ReplicatedStorage.Shared:WaitForChild("Data")
Knit.Shared = ReplicatedStorage.Shared

-- init all services
Knit.AddControllersDeep(script.Parent.Controllers)

Knit.Start()
	:andThen(function()
		local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
		Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
	end)
	:catch(warn)


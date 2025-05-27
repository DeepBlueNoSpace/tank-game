local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
print'hnmmm'
local Knit = require(ReplicatedStorage.Packages.Knit)
print'server knit going'
-- expose modules and assets
Knit.Packages = ReplicatedStorage.Packages
Knit.Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
Knit.Assets = ReplicatedStorage:WaitForChild("Assets")
Knit.Data = ReplicatedStorage.Shared:WaitForChild("Data")
Knit.Shared = ReplicatedStorage.Shared
print'ja'
-- init all services
Knit.AddServicesDeep(script.Parent.Services)
print'yaaa'

Knit.Start()
	:andThen(function()
		local function playerAdded(player: Player)
			for _, service in pairs(Knit.GetServices()) do
				if service.PlayerAdded then
					service:PlayerAdded(player)
				end
			end
		end

		local function playerRemoving(player: Player)
			for _, service in pairs(Knit.GetServices()) do
				if service.PlayerRemoving then
					service:PlayerRemoving(player)
				end
			end
		end

		for _, player in pairs(game.Players:GetPlayers()) do
			coroutine.wrap(function()
				playerAdded(player)
			end)()
		end

		game.Players.PlayerAdded:Connect(function(player)
			playerAdded(player)
		end)

		game.Players.PlayerRemoving:Connect(function(player)
			playerRemoving(player)
		end)
		print'd'
		spawn(function()
			local cmdr = require(Knit.Packages.Cmdr)
			cmdr:RegisterDefaultCommands()
			cmdr:RegisterCommandsIn(game.ServerScriptService.Server.Cmdr.CmdrCommands)
			cmdr:RegisterHooksIn(game.ServerScriptService.Server.Cmdr.CmdrHooks)
			cmdr:RegisterTypesIn(game.ServerScriptService.Server.Cmdr.CmdrTypes)
		end)
	end)
	:catch(warn)

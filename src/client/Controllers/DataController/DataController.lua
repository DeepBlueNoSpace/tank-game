local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Promise = require(Knit.Util.Promise)
local Trove = require(Knit.Packages.Trove)

local DataController = Knit.CreateController({ Name = "DataController" })
DataController.SaveReplicas = {}
DataController.TempReplicas = {}

----- Modules -----

local ReplicaController = require(script.Parent:WaitForChild("ReplicaController"))

----- Private Variables -----

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

----- Private functions -----

----- Public functions -----

function DataController:_debugPrint(targetPlayer)
	warn("CLIENT data for", targetPlayer.Name .. ":", DataController.SaveReplicas[targetPlayer].Data)
end

function DataController:GetReplica(player)
	if not DataController.SaveReplicas[player] then
		--warn("Requested replica but doesn't exist for:", player)
		return nil
	end

	return DataController.SaveReplicas[player]
end

function DataController:GetReplicaPromise(player)
	return Promise.new(function(resolve, reject, onCancel)
		local replica = self:GetReplica(player)
		if replica then
			resolve(replica)
		else
			local trove = Trove.new()

			onCancel(function()
				trove:Destroy()
			end)

			trove:Add(ReplicaController.ReplicaOfClassCreated("SaveProfile", function(replica)
				if player == replica.Tags.Player then
					trove:Destroy()
					resolve(replica)
				end
			end))

			trove:Add(game.Players.PlayerRemoving:Connect(function(removedPlayer)
				if player == removedPlayer then
					trove:Destroy()
					reject()
				end
			end))

			if not game.Players:FindFirstChild(player.Name) then
				trove:Destroy()
				reject()
			end
		end
	end)
end

----- Knit init -----

function DataController:KnitInit()
	ReplicaController.ReplicaOfClassCreated("SaveProfile", function(replica)
		DataController.SaveReplicas[replica.Tags.Player] = replica
		local is_local = replica.Tags.Player == LocalPlayer

		if is_local then
			local controllers = Knit.GetControllers()
			for _, controller in controllers do
				if controller.LocalReplicaCreated then
					-- the xpcall makes init take forever idk why @nic
					coroutine.wrap(function()
						controller:LocalReplicaCreated(replica)
					end)()
					
					--local success, err = xpcall(function()
					--	
					--end, debug.traceback)
--
					--if not success then
					--	warn("Error in LocalReplicaCreated: " .. err)
					--end
					--end)()
				end
			end
		end
	end)

	ReplicaController.RequestData()
end

function DataController:KnitStart() end

----- Initialize -----

return DataController

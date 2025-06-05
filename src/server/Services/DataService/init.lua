----- Modules -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SAVE_PROFILE_SCHEMA = require(game.ServerScriptService:WaitForChild("Server"):WaitForChild("SAVE_PROFILE_SCHEMA"))

local ProfileService = require(script.ProfileService)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Packages.Signal)
local TEST_CONFIGS = require(ReplicatedStorage.Shared.TEST_CONFIGS)
local TableDeepCopy = require(Knit.Modules.TableDeepCopy)
local Trove = require(Knit.Packages.Trove)

local ReplicaService = require(script.ReplicaService)

local GET_REPLICA_TIMEOUT = 3

-- Knit Instantiation

local DataService = Knit.CreateService({
	Name = "DataService",
	ReplicaService = ReplicaService,
	SaveReplicaCreated = Signal.new(),
})

----- Private Variables -----

local Players = game:GetService("Players")

local SaveProfileStore = nil -- saved to datastores
local SaveProfileClassToken = ReplicaService.NewClassToken("SaveProfile")
local SaveProfileTemplate = {}

local PlayerProfiles = {} -- [player] = {Profile = profile, Replica = replica}

----- Private functions -----

-- If missing any keys, e.g due to data update, it adds that key using default value from SAVE_PROFILE_SCHEMA
local function ValidateReplica(player, replica)
	local function recursive(schemaTable, dataTable, key)
		local defaultVal = schemaTable[key]

		if defaultVal and not dataTable[key] then
			print("Added missing key to data for", player, ":", key, defaultVal)
			dataTable[key] = defaultVal
		end

		if typeof(defaultVal) ~= typeof(dataTable[key]) then
			warn("Mismatched types for key. Replacing with default value:", key, schemaTable[key], dataTable[key])
			dataTable[key] = defaultVal
		end

		if typeof(defaultVal) == "table" then
			for secondKey, _ in pairs(defaultVal) do
				recursive(schemaTable[key], dataTable[key], secondKey)
			end
		end
	end

	for key, _ in pairs(SAVE_PROFILE_SCHEMA) do
		recursive(SAVE_PROFILE_SCHEMA, replica.Data, key)
	end
end

local VERS = 4

local function PlayerAdded(player)
	local playerId = VERS .. "_Player_" .. player.UserId

	local profile = SaveProfileStore:LoadProfileAsync(TEST_CONFIGS.Is("CLEAN_DATA") and tostring(math.random()) or playerId, "ForceLoad")
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			PlayerProfiles[player].Replica:Destroy()
			PlayerProfiles[player] = nil
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			local player_profile = {
				Profile = profile,
				Replica = ReplicaService.NewReplica({
					ClassToken = SaveProfileClassToken,
					Tags = { Player = player },
					Data = profile.Data,
					Replication = "All",
				}),
				_player = player,
			}
			--setmetatable(player_profile, PlayerProfile)
			ValidateReplica(player, player_profile.Replica)
			PlayerProfiles[player] = player_profile

			if player_profile.Replica.Data.FirstJoinTime == false then
				player_profile.Replica:SetValue("FirstJoinTime", math.floor(tick()))
			end

			DataService.SaveReplicaCreated:Fire(player, player_profile.Replica)

			--warn("Player data loaded:", player_profile)

			--InventoryService:PlayerAddedAndDataLoaded(player, player_profile.Replica)
			--Knit.GetService("PlayerNameplateService"):PlayerAddedAndDataLoaded(player, player_profile.Replica)
			--Knit.GetService("QuestsService"):PlayerAddedAndDataLoaded(player, player_profile.Replica)
		else
			profile:Release()
		end

		--DataService.MonetisationService:LoadGamepasses(player)
	else
		player:Kick()
	end

	DataService:HandleLeaderstats(player)
end

----- Public functions -----

function DataService:RegisterSchema(profileName: string, schema: table)
	warn("Deprecated: DataService:RegisterSchema()", profileName, schema)
	coroutine.wrap(function()
		for key, value in pairs(schema) do
			local copy = TableDeepCopy(value)
			if profileName == "SaveProfile" then
				SaveProfileTemplate[key] = copy
			else
				warn("Invalude profileName:", profileName)
			end
		end
	end)()
end

function DataService:GetReplica(player, dontAllowTimeOut)
	if not PlayerProfiles[player] or not PlayerProfiles[player].Replica then
		if dontAllowTimeOut then
			return nil
		else
			local start = tick()
			repeat
				task.wait()
			until (not PlayerProfiles[player] or not PlayerProfiles[player].Replica) or tick() - start > GET_REPLICA_TIMEOUT

			if not PlayerProfiles[player] or not PlayerProfiles[player].Replica then
				return nil
			end
		end
		return nil
	end

	return PlayerProfiles[player].Replica
end

function DataService:GetReplicaPromise(player)
	return Promise.new(function(resolve, reject, onCancel)
		local replica = self:GetReplica(player, true)
		if replica then
			resolve(replica)
		else
			local trove = Trove.new()

			onCancel(function()
				trove:Destroy()
			end)

			trove:Add(DataService.SaveReplicaCreated:Connect(function(replicaOwner, replica)
				if player == replicaOwner then
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

function DataService:_debugPrint(fromPlayer, targetPlayer)
	warn("SERVER data for", fromPlayer.Name .. ":", PlayerProfiles[targetPlayer].Replica.Data)
end

function DataService:HandleLeaderstats(player)
	local replica = self:GetReplica(player)
	if not replica then
		return
	end

	local trove = Trove.new()

	local leaderstats = trove:Add(Instance.new("Model"))
	leaderstats.Name = "leaderstats"

	local winsValue = Instance.new("NumberValue")
	winsValue.Name = "Kills"
	winsValue.Value = replica.Data.Kills
	winsValue.Parent = leaderstats

	local cashValue = Instance.new("NumberValue")
	cashValue.Name = "Deaths"
	cashValue.Value = replica.Data.Deaths
	cashValue.Parent = leaderstats

	leaderstats.Parent = player

	trove:Add(Players.PlayerRemoving:Connect(function(tPlayer)
		if not (tPlayer == player) then
			return
		end

		trove:Destroy()
	end))
end

function DataService:WipeData(player)
	local replica = self:GetReplica(player)
	if not replica then
		return
	end

	for key, value in replica.Data do
		replica:SetValue(key, nil)
	end

	-- reset defaults
	for key, value in pairs(SaveProfileTemplate) do
		replica:SetValue(key, value)
	end

	warn("Finished wiping", player, replica.Data)

	player:Kick("Data wiped, plz rejoin")
end

----- Initialize -----

function DataService:KnitInit()

end

function DataService:KnitStart()
	for key, value in pairs(SAVE_PROFILE_SCHEMA) do
		local copy = value
		if type(copy) == "table" then
			copy = TableDeepCopy(value)
		end
		SaveProfileTemplate[key] = copy
	end

	warn("DataService:KnitStart() with schema:", SaveProfileTemplate)

	SaveProfileStore = ProfileService.GetProfileStore("PlayerData", SaveProfileTemplate)

	for _, player in pairs(game.Players:GetPlayers()) do
		coroutine.wrap(PlayerAdded)(player)
	end

	game.Players.PlayerAdded:Connect(PlayerAdded)

	game.Players.PlayerRemoving:Connect(function(player)
		local player_profile = PlayerProfiles[player]
		if player_profile ~= nil then
			player_profile.Profile:Release()
		end
	end)
end

return DataService

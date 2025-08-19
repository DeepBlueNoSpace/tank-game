--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local TestConfigs = require(Knit.Shared.TEST_CONFIGS)

local ROUND_TIME = TestConfigs.Is("ROUND_TIME") or 60 * 10

local GameLoopService = Knit.CreateService {
    Name = "GameLoopService",
    
    GamemodeController = nil,

    Client = {
        State = Knit.CreateProperty("Intermission"),
        StateEndTime = Knit.CreateProperty(-1),
        Gamemode = Knit.CreateProperty(nil),
        PlayerKilled = Knit.CreateSignal(),
        GameEnding = Knit.CreateSignal(),
    }
}

function GameLoopService:Main()
    while true do
        local succ, err = pcall(function()
            self.Client.State:Set("Intermission")
            self.Client.Gamemode:Set(nil)

            for _, folder in pairs(workspace.RuntimeContent:GetChildren()) do
                folder:ClearAllChildren()
            end
            

            -- wait a few seconds...............

            -- Select gamemode
            --warn("TODO: players vote on gamemode")
            local selectedGamemode = "Deathmatch"

            -- Select + load map
           -- warn("TODO: players vote on map")
           -- warn("TODO: Load map")

            -- Setup teams, just assume all maps have 2 for now
            Knit.GetService("TeamService"):SetupTeams(2)

            -- Start game
            self.Client.State:Set("Active")
            self.Client.StateEndTime:Set(Knit.GetService("ServerTimeService"):GetTime() + ROUND_TIME)
            self.Client.Gamemode:Set(selectedGamemode)
            self.GamemodeController = self.GamemodeOptions[selectedGamemode]
            self.GamemodeController:Start()

            -- Gamemode over for whatever reason
            local winners: {[string]:boolean}, endgameDataPackage: {Types.EndgamePlayerPackage} = self.GamemodeController.Ended:Wait()
            self.Client.State:Set("Ending")

            warn("Gamemode ended, winners:", winners, "endgameDataPackage:", endgameDataPackage)

            self.Client.GameEnding:FireAll(winners, endgameDataPackage)
            self:_renderHumanoidsAtEndgameScene(endgameDataPackage)

            -- TODO give rewards to winners?

            Knit.GetService("TankService"):DeactivateTanks()

            task.wait(6.1) -- give time for victory/defeat popup to show + move on to leaderboard
            Knit.GetService("TankService"):DestroyAllTanks()
        end)

        if not succ or err then
            warn("!!!!!!!!!!!!! CORE LOOP ERROR !!!!!!!!!!!!!")
            warn(err)
        end
    end
end

-- applyhumanoiddesc has to be on server
-- so it goes here for now :shrug: 
function GameLoopService:_renderHumanoidsAtEndgameScene(endgameDataPackage: {Types.EndgamePlayerPackage})
    local EndgameScene = workspace:WaitForChild("EndgameScene")

	for i=1, math.min(3, #endgameDataPackage) do
		local prefab = EndgameScene.Prefabs:FindFirstChild(tostring(i))
		local data: Types.EndgamePlayerPackage = endgameDataPackage[i]

		spawn(function()
			local userId = game.Players:FindFirstChild(data.PlayerName).UserId
			local humanoidDescription = game.Players:GetHumanoidDescriptionFromUserId(userId)
			prefab.PlayerRig.Humanoid:ApplyDescription(humanoidDescription)
		end)

	end
end

function GameLoopService:_setState(state)
    self.Client.State:Set(state)
    warn("State set to:", state)
end


function GameLoopService:ReportKill(killer: Player, victim: Player)
    if self.GamemodeController and self.GamemodeController.ReportKill then
        self.GamemodeController:ReportKill(killer, victim)
    end

    self.Client.PlayerKilled:FireAll(killer, victim)

    local killerTank = self.TankService.LiveTanks[killer]
    print("setting victim replication focus to killer tank:", killerTank)
    if killerTank then
        victim.ReplicationFocus = killerTank.Model.PrimaryPart
    end
end

local function makeCharacterInvisible(character)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SpecialMesh") or descendant:IsA("MeshPart") then
			descendant.Transparency = 1
		elseif descendant:IsA("Accessory") then
			local handle = descendant:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				handle.Transparency = 1
				handle.CanCollide = false
				for _, child in ipairs(handle:GetDescendants()) do
					if child:IsA("Decal") or child:IsA("Texture") then
						child.Transparency = 1
					end
				end
			end
		elseif descendant:IsA("Shirt") or descendant:IsA("Pants") or descendant:IsA("ShirtGraphic") then
			descendant:Destroy()
		end
	end
end

function GameLoopService:PlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 0

        makeCharacterInvisible(character)

        local ff = character:FindFirstChildOfClass("ForceField")
		if ff then
			ff:Destroy()
		end

        humanoid.Died:Connect(function()
            local tank = self.TankService.LiveTanks[player]
            if tank then
                tank:TakeDamage(math.huge, player)
            end
        end)
    end)
end

function GameLoopService:PlayerRemoving() end


function GameLoopService.Client.RequestReplicationFocus(player: Player, request: string)
    if request == "Lobby" then
        player.ReplicationFocus = workspace.LobbyScene.CameraPart
    end
end

function GameLoopService:KnitInit()
    self.GamemodeOptions = {
        ["Deathmatch"] = Knit.GetService("DeathmatchGamemodeService"),
    }

    self.TankService = Knit.GetService("TankService")
end


function GameLoopService:KnitStart()
    game.Players.RespawnTime = 0
    self:Main()
end


return GameLoopService

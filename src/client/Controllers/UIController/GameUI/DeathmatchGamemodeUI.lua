--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(Knit.Packages.Trove)

local DeathmatchGamemodeUI= Knit.CreateController({ Name = "DeathmatchGamemodeUI", Open = false })
DeathmatchGamemodeUI.Trove = Trove.new()
DeathmatchGamemodeUI.CachedThumbnails = {}

function DeathmatchGamemodeUI:OpenFrame()
	self.Frame.Visible = true

	self.DeathmatchGamemodeService.KillLeaderboard:OnReady():andThen(function()
		self:UpdateLeaderboard()
		self.Trove:Add(self.DeathmatchGamemodeService.KillLeaderboard.Changed:Connect(function()
			self:UpdateLeaderboard()
		end))
	end)

	self.Trove:Add(game:GetService("RunService").Heartbeat:Connect(function()
		self:UpdateTimer()
	end))
end

function DeathmatchGamemodeUI:CloseFrame()
	self.Frame.Visible = false
	self.Trove:Destroy()
	self.CachedThumbnails = {}
end

local leaderboardTiles = {}  -- [index] = tile
local MAX_TILES = 10

function DeathmatchGamemodeUI:UpdateLeaderboard()
	local leaderboardData = self.DeathmatchGamemodeService.KillLeaderboard:Get()

	-- process and sort players
	local transformedData = {}
	for playerName, killCount in pairs(leaderboardData) do
		table.insert(transformedData, {
			PlayerName = playerName,
			KillCount = killCount,
		})
	end

	table.sort(transformedData, function(a, b)
		return a.KillCount > b.KillCount
	end)

	for i=1, MAX_TILES do
		-- if tile exists but not enough players in the leaderboard, this is outdated, delete
		if leaderboardTiles[i] and not transformedData[i] then
			leaderboardTiles[i]:Destroy()
			leaderboardTiles[i] = nil
		end

		-- initialize tile if it's missing
		if transformedData[i] and not leaderboardTiles[i] then
			local prefab = self.LeaderboardFrame:WaitForChild("Prefab")
			local tile = prefab:Clone()
			leaderboardTiles[i] = tile
			tile.Parent = self.LeaderboardFrame
			tile.Visible = true
		end

		-- finally, update the tile
		if transformedData[i] then
			local tile = leaderboardTiles[i]
			local data = transformedData[i]

			tile.LayoutOrder = i
			tile.KillCount.Text = tostring(data.KillCount)
			tile.Rank.Text = "#"..tostring(i)

			local playerObj = game.Players:FindFirstChild(data.PlayerName)
			if playerObj then
				local color3 = playerObj.TeamColor.Color
				tile.KillCount.TextColor3 = color3
				tile.Rank.TextColor3 = color3
			end

			coroutine.wrap(function()
				local thumb = self.CachedThumbnails[data.PlayerName]
				if not thumb and playerObj then
					thumb = Players:GetUserThumbnailAsync(playerObj.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					self.CachedThumbnails[playerObj] = thumb
				end

				if thumb then
					tile.ImageLabel.Image = thumb
					tile.ImageLabel.Visible = true
				else
					tile.ImageLabel.Visible = false
				end
			end)()
		end
	end
end

function DeathmatchGamemodeUI:UpdateTimer()
	local timeRemaining = self.GameLoopService.StateEndTime:Get() - self.ServerTimeController:GetTime()
	timeRemaining = math.max(timeRemaining, 0)

	local minutes = math.floor(timeRemaining / 60)
	local seconds = timeRemaining % 60
	self.TimerFrame.TextLabel.Text = string.format("%02d:%02d", minutes, seconds)
end

function DeathmatchGamemodeUI:LocalReplicaCreated(replica)
	self.Replica = replica
end

function DeathmatchGamemodeUI:KnitInit()
	self.UIController = Knit.GetController("UIController")
	self.ServerTimeController = Knit.GetController("ServerTimeController")

	self.GameLoopService = Knit.GetService("GameLoopService")
    self.DeathmatchGamemodeService = Knit.GetService("DeathmatchGamemodeService")

	local gameGui = self.UIController.GameGui 

	local GamemodesFrame = gameGui:WaitForChild("Gamemodes")
	self.Frame = GamemodesFrame:WaitForChild("Deathmatch")
	self.TimerFrame = self.Frame:WaitForChild("Timer")
	self.LeaderboardFrame = self.Frame:WaitForChild("Leaderboard")

	self.LeaderboardFrame:WaitForChild("Prefab").Visible = false

end

function DeathmatchGamemodeUI:KnitStart()
	
end

return DeathmatchGamemodeUI

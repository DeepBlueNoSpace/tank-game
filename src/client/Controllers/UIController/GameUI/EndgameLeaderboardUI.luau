local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local TankUtil = require(Knit.Modules.TankUtil)

local EndgameScene = workspace:WaitForChild("EndgameScene")
local CameraPart = EndgameScene:WaitForChild("CameraPart")


local LeaderboardUI= Knit.CreateController({ Name = "EndgameLeaderboardUI", Open = false })

function LeaderboardUI:OpenFrame()
	if Knit.GetController("LobbyMainUI").Open then
		return false
	end

	self.Open = true

	if self.TankController.Tank and self.TankController.Tank.Camera then
		self.TankController.Tank.Camera:Destroy()
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = CameraPart.CFrame

	self.Frame.Visible = true
end

function LeaderboardUI:CloseFrame()
	self.Open = false
    self.Frame.Visible = false
end

function LeaderboardUI:_loadLeaderboard(endgameDataPackage: {Types.EndgamePlayerPackage})
	for i,v in pairs(self.Container:GetChildren()) do
		if v:IsA("GuiObject") and v ~= self.Prefab then
			v:Destroy()
		end
	end

	for i, data: Types.EndgamePlayerPackage in pairs(endgameDataPackage) do
		local player = game.Players:FindFirstChild(data.PlayerName)
		if not player then
			warn("Player not found in game:", data.Player.Name)
			continue
		end

		local prefab = self.Prefab:Clone()
		
		prefab.LayoutOrder = data.Rank
		prefab.Rank.Text = string.format("#%d", data.Rank)
		prefab.Count.Text = string.format("%d Kils", data.Kills)
		prefab.PlayerName.Text = player.Name

		coroutine.wrap(function()
			local userId = player.UserId
			local thumbType = Enum.ThumbnailType.HeadShot
			local thumbSize = Enum.ThumbnailSize.Size100x100
			local content, isReady = game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
			prefab.Thumbnail.Image = content
		end)()

		prefab.Parent = self.Container
		prefab.Visible = true
	end
end

function LeaderboardUI:_loadModels(endgameDataPackage: {Types.EndgamePlayerPackage})
	warn("LoadModels", endgameDataPackage)
	for i,v in pairs(EndgameScene.Prefabs:GetChildren()) do
		local tankPart = v:WaitForChild("TankPart")
		v.TankPart.Transparency = 1
		if v:FindFirstChild("Tank") then
			v.Tank:Destroy()
		end
	end


	for i=1, 3 do
		local prefab = EndgameScene.Prefabs:FindFirstChild(tostring(i))
		if #endgameDataPackage >= i then

			local data: Types.EndgamePlayerPackage = endgameDataPackage[i]

			-- HUMANOIDS DONE ON CLIENT

			local tankModel = TankUtil.SpawnTankModelAtPart(data.Tank, prefab.TankPart)
			tankModel.Name = "Tank"
			tankModel.Parent = EndgameScene.Prefabs[tostring(i)]
		else
			local allTanks = ReplicatedStorage.Assets.Tanks:GetChildren()
			local randomTank = allTanks[math.random(1, #allTanks)].Name
			local tankModel = TankUtil.SpawnTankModelAtPart(randomTank, prefab.TankPart)
			tankModel.Name = "Tank"
			tankModel.Parent = EndgameScene.Prefabs[tostring(i)]
		end

	end
end

function LeaderboardUI:PreloadScene(endgameDataPackage: {Types.EndgamePlayerPackage})
	self:_loadLeaderboard(endgameDataPackage)
	self:_loadModels(endgameDataPackage)
end

function LeaderboardUI:KnitInit()
	self.UIController = Knit.GetController("UIController")
	self.TankController = Knit.GetController("TankController")
end

function LeaderboardUI:KnitStart()
	self.Frame = self.UIController.GameGui:WaitForChild("EndgameLeaderboard")

	self.Container = self.Frame:WaitForChild("Tasks"):WaitForChild("List")
	self.Prefab = self.Container:WaitForChild("Prefab")
	self.Prefab.Visible = false

	self.LobbyButton = self.Frame:WaitForChild("LobbyButton")

	self.LobbyButton.Activated:Connect(function()
		self.UIController:AttemptClose(self)
        Knit.GetController("LobbyMainUI"):OpenFrame()
	end)
	
end

return LeaderboardUI

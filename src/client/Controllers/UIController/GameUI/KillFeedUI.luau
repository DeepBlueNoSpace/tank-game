--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local KillFeedUI= Knit.CreateController({ Name = "KillFeedUI", Open = false })

function KillFeedUI:OpenFrame(killer: Player)
    self.Open = true
    --self.Frame.Visible = true
end

function KillFeedUI:CloseFrame()
    self.Open = false
    --self.Frame.Visible = false
end

local localRewardStack = {}
function KillFeedUI:PushLocalReward(text: string, reward: number)
    local tile = self.LocalRewardsPrefab:Clone()
    tile.TextLabel.Text = text
    tile.RewardLabel.Text = reward

    tile.Parent = self.LocalRewardsContainer
    tile.Visible = true

    table.insert(localRewardStack, 1, tile)

    -- delete excess tiles if they're stacking up too fast
    local maxTiles = 2
    if #localRewardStack > maxTiles then
        local oldTile = localRewardStack[#localRewardStack]
        table.remove(localRewardStack, #localRewardStack)
        oldTile:Destroy()
    end

    -- Automatically delete this tile after a delay
    delay(3, function()
        local idx = table.find(localRewardStack, tile)
        if idx then
            table.remove(localRewardStack, idx)
            tile:Destroy()
        end
    end)
end

local globalKillsStack = {}
function KillFeedUI:PushGlobalKill(killer: Player, victim: Player)
    local tile = self.GlobalKillsPrefab:Clone()
    tile.TextLabel.Text = killer.Name .. " -> " .. victim.Name
    tile.Parent = self.GlobalKillsContainer
    tile.Visible = true

    table.insert(localRewardStack, 1, tile)

    -- delete excess tiles if they're stacking up too fast
    local maxTiles = 4
    if #globalKillsStack > maxTiles then
        local oldTile = globalKillsStack[#globalKillsStack]
        table.remove(globalKillsStack, #globalKillsStack)
        oldTile:Destroy()
    end

    -- fade out this tile after a delay
    delay(2, function()
        if tile then
            tile.BackgroundTransparency = 0.25
        end
    end)
end



function KillFeedUI:KnitInit()
    self.Open = false

    self.UIController = Knit.GetController("UIController")
	self.GameLoopService = Knit.GetService("GameLoopService")
    self.DamageService = Knit.GetService("DamageService")
end

function KillFeedUI:KnitStart()
    self.Frame = self.UIController.GameGui:WaitForChild("KillFeeds")

    self.LocalRewardsContainer = self.Frame:WaitForChild("LocalRewardsContainer")
    self.LocalRewardsPrefab = self.LocalRewardsContainer:WaitForChild("Prefab")

    self.GlobalKillsContainer = self.Frame:WaitForChild("GlobalKillsContainer")
    self.GlobalKillsPrefab = self.GlobalKillsContainer:WaitForChild("Prefab")

    self.DamageService.Killed:Connect(function(killer, victim, cashReward)
        if killer == Players.LocalPlayer then
            self:PushLocalReward("Killed", cashReward)
        end
        self:PushGlobalKill(killer, victim)
        warn("Killed called:", killer, victim, cashReward)
    end)

    self.DamageService.Assisted:Connect(function(assistingPlayer, victim, cashReward)
        self:PushLocalReward("Assisted", cashReward)
        warn("Assisted called:", assistingPlayer, victim, cashReward)
    end)
end

return KillFeedUI

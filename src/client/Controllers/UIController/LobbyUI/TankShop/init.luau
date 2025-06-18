--!strict
--[[
    TODO: cleanup a bit when implementing real UI
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Colors = require(ReplicatedStorage.Shared.Data.Colors)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local TankUtil = require(ReplicatedStorage.Shared.Modules.TankUtil)

local TankShopUI= Knit.CreateController({ Name = "TankShopUI", Open = false })
TankShopUI.SelectedTank = nil :: string?

TankShopUI._buyButtonConnection = nil :: RBXScriptConnection?

function TankShopUI:OpenFrame()
    self.Open = true
    self.Frame.Visible = true
end

function TankShopUI:CloseFrame()
    self.Open = false
    self.Frame.Visible = false
end

function TankShopUI:_renderTanks(forceSelectTank: string?)
    -- TODO: add tank types
    local prefab = self.TankScrollingFrame:WaitForChild("Prefab")
    prefab.Visible = false

    -- clear previous tiles
    for _, v in pairs(self.TankScrollingFrame:GetChildren()) do
        if v:IsA("GuiObject") and v.Name ~= "Prefab" then
            v:Destroy()
        end
    end

    local tanks = {}
    for _tankName, tankData: Types.TankData in pairs(TankData) do
        table.insert(tanks, tankData)
    end
    
    -- For now sort tanks by cost
    -- In future need a more explicit sort?
    table.sort(tanks, function(a, b)
        a.RequiredLevel = a.RequiredLevel or 1
        b.RequiredLevel = b.RequiredLevel or 1
        if a.RequiredLevel ~= b.RequiredLevel then
            return a.RequiredLevel < b.RequiredLevel
        else
            return a.Cost < b.Cost
        end
    end)

    local playerData = self.LocalReplica.Data
    for i, tankData: Types.TankData in ipairs(tanks) do
        local tile = prefab:Clone()
        tile.LayoutOrder = i
        tile.Name = tankData.Name
        
        tile.ImageLabel.Image = tankData.Image
        tile.TankName.Text = tankData.Name

        tile.ImageLabel.ImageTransparency = playerData.OwnedTanks[tankData.Name] and 0 or 0.2

        local isOwned = playerData.OwnedTanks[tankData.Name]
        local isUnlocked = playerData.LevelData.Level >= (tankData.RequiredLevel or 1)

        local statusLabel = tile.Status.Value
        if isOwned then 
            if playerData.EquippedTank == tankData.Name then 
                statusLabel.Text = "EQUIPPED"
                statusLabel.TextColor3 = Colors.ACTIVE_BLUE
            else
                statusLabel.Text = "Owned"
                statusLabel.TextColor3 = Colors.INACTIVE_BLUE
            end
        else
            statusLabel.Text = string.format("$%s", tostring(tankData.Cost))
            statusLabel.TextColor3 = Colors.CASH_GREEN
        end

        tile.LockedFrame.Visible = not isUnlocked
        tile.LockedFrame.TextLabel.Text = "Requires Level " .. (tankData.RequiredLevel or 1)
        
        tile.Activated:Connect(function()
            self:SelectTank(tankData.Name)
        end)

        tile.Visible = true
        tile.Parent = self.TankScrollingFrame

        if forceSelectTank and tankData.Name == forceSelectTank then
            self:SelectTank(tankData.Name) -- auto-select equipped tank
        end
    end
end

function TankShopUI:RenderTiles(forceSelectTank: string?)
    self:_renderTanks(forceSelectTank)
end

function TankShopUI:SelectTank(tankName: string)
    --local tankData: Types.TankData = TankData[tankName]
    self.SelectedTank = tankName
    self.TankDisplay:SetTank(tankName)
    self:UpdateBuyEquipButton()

    if TankUtil.OwnsTank(self.LocalReplica, self.SelectedTank) then
        self.UpgradeShop:Open() 
    else
        self.UpgradeShop:Close() 
    end

    self.ShopStats:SetStatsForTank(tankName)
end

function TankShopUI:UpdateBuyEquipButton()
    if self._buyButtonConnection then
        self._buyButtonConnection:Disconnect()
    end

    local data: Types.TankData = TankData[self.SelectedTank]

    local meetsLevelReq = self.LocalReplica.Data.LevelData.Level >= (data.RequiredLevel or 1)
    self.BuyEquipButton.Visible = (self.LocalReplica.Data.EquippedTank ~= self.SelectedTank) and (meetsLevelReq) -- hide buy button if tank is already equipped or if level requirement is not met

    if TankUtil.OwnsTank(self.LocalReplica, self.SelectedTank) then
        self.BuyEquipButton.TextLabel.Text = "Equip"
        self._buyButtonConnection = self.BuyEquipButton.Activated:Connect(function()
            self.TankShopService:RequestEquipTank(self.SelectedTank)
        end)
    else
        self.BuyEquipButton.TextLabel.Text = "Buy"
        self._buyButtonConnection = self.BuyEquipButton.Activated:Connect(function()
            self.TankShopService:RequestBuyTank(self.SelectedTank)
        end)
    end
end

function TankShopUI:UpdateCash()
    local moneyCounter = self.TankOptions:FindFirstChild("MoneyCounter")
    if moneyCounter then
        moneyCounter:WaitForChild("Value").Text = string.format("$%s", tostring(self.LocalReplica.Data.Currency.Cash))
    end
end

function TankShopUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
    self.TankDisplay = Knit.GetController("TankDisplay")
    self.UpgradeShop = Knit.GetController("UpgradeShop")
    self.TankShopService = Knit.GetService("TankShopService")
    self.ShopStats = Knit.GetController("ShopStats")
end

function TankShopUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("TankShop")
    self.StatsFrame = self.Frame:WaitForChild("Stats")
	self.BuyEquipButton = self.StatsFrame:WaitForChild("BuyEquip")
    self.BackButton = self.Frame:WaitForChild("Back")
    self.TankOptions = self.Frame:WaitForChild("TankOptions")
    self.TankScrollingFrame = self.TankOptions:WaitForChild("TankScrollingFrame")


    self.BackButton.Activated:Connect(function()
        self.UIController:AttemptClose(self)
        Knit.GetController("LobbyMainUI"):OpenFrame()
    end)

	Knit.GetController("DataController"):GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
		self.LocalReplica = replica

		self:UpdateCash()
		replica:ListenToChange({"Currency", "Cash"}, function()
			self:UpdateCash()
		end)

        self:RenderTiles(self.LocalReplica.Data.EquippedTank)
        replica:ListenToChange({"OwnedTanks"}, function()
            self:RenderTiles()
            self:UpdateBuyEquipButton()
        end)
        replica:ListenToChange({"EquippedTank"}, function()
            self:RenderTiles()
            self:UpdateBuyEquipButton()
        end)

        replica:ListenToChange({"LevelData", "Level"}, function()
            self:RenderTiles()
        end)
	end)
end

return TankShopUI

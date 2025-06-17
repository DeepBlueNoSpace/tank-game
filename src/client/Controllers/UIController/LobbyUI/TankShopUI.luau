--[[
    TODO: cleanup a bit when implementing real UI
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TankData = require(Knit.Data.TankData)
local TankUtil = require(Knit.Modules.TankUtil)
local UpgradeData = require(Knit.Data.UpgradeData)

local TankShopUI= Knit.CreateController({ Name = "TankShopUI", Open = false })
TankShopUI.SelectedTank = nil :: string?
TankShopUI.SelectedUpgrade = nil :: string?
TankShopUI.SelectedUpgradeType = nil :: string? -- e.g. "Engine", "Armor", "Munition1", "Munition2"
TankShopUI.Mode = "Tank" -- Tank, Engine, Armor, Munition1, Muntion2

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
    for i,v in pairs(self.TankScrollingFrame:GetChildren()) do
        if v:IsA("GuiObject") and v.Name ~= "Prefab" then
            v:Destroy()
        end
    end

    local tanks = {}
    for tankName, tankData: Types.TankData in pairs(TankData) do
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

    for i, tankData: Types.TankData in ipairs(tanks) do
        local tile = prefab:Clone()
        tile.LayoutOrder = i
        tile.Name = tankData.Name
        
        tile.ImageLabel.Image = tankData.Image
        tile.TankName.TextLabel.Text = tankData.Name
        tile.MoneyCounter.TextLabel.Text = tostring(tankData.Cost)

        tile.MoneyCounter.Visible = not self.LocalReplica.Data.OwnedTanks[tankData.Name]
        tile.Equipped.Visible = self.LocalReplica.Data.EquippedTank == tankData.Name
        tile.ImageLabel.ImageTransparency = self.LocalReplica.Data.OwnedTanks[tankData.Name] and 0 or 0.8

        tile.LockedFrame.Visible = not (self.LocalReplica.Data.LevelData.Level >= (tankData.RequiredLevel or 1))
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

function TankShopUI:_renderUpgrades()
    local selectedTank = self.SelectedTank
    local selectedUpgrade = self.Mode -- e.g. "Engine", "Armor", "Munition1", "Munition2"
    local selectedUpgradeType = self.Mode 
    if selectedUpgradeType == "Munition1" or selectedUpgradeType == "Munition2" then
        selectedUpgradeType = "Munitions"
    end

    local prefab = self.TankScrollingFrame:WaitForChild("Prefab")
    prefab.Visible = false

    -- clear previous tiles
    for i,v in pairs(self.TankScrollingFrame:GetChildren()) do
        if v:IsA("GuiObject") and v.Name ~= "Prefab" then
            v:Destroy()
        end
    end

    --local upgradeData = UpgradeData[self.LocalReplica.Data.EquippedTank][selectedUpgradeType]
    local availableUpgrades = UpgradeData[selectedTank] or {}
    availableUpgrades = availableUpgrades[selectedUpgradeType] or {}

    local upgrades = {}
    for upgradeName, data: Types.TankUpgradeData in pairs(availableUpgrades) do
        table.insert(upgrades, data)
    end
    
    table.sort(upgrades, function(a, b)
        a.RequiredLevel = a.RequiredLevel or 1
        b.RequiredLevel = b.RequiredLevel or 1
        if a.RequiredLevel ~= b.RequiredLevel then
            return a.RequiredLevel < b.RequiredLevel
        else
            return (a.Cost or 0) < (b.Cost or 0)
        end
    end)

    for i, upgradeData: Types.TankUpgradeData in pairs(upgrades) do
        warn("ASDF", i, upgradeData)
        local tile = prefab:Clone()
        tile.LayoutOrder = i
        tile.Name = upgradeData.Name
        
        tile.ImageLabel.Image = upgradeData.Image or ""
        tile.TankName.TextLabel.Text = upgradeData.DisplayName
        tile.MoneyCounter.TextLabel.Text = tostring(upgradeData.Cost)

        local isOwned = TankUtil.IsUpgradeOwned(self.LocalReplica, self.LocalReplica.Data.EquippedTank, upgradeData.Name)
        local isEquipped = TankUtil.IsUpgradeEquipped(self.LocalReplica, self.LocalReplica.Data.EquippedTank, selectedUpgrade, upgradeData.Name)
        
        tile.MoneyCounter.Visible = not isOwned and not isEquipped
        tile.Equipped.Visible = isEquipped
        tile.ImageLabel.ImageTransparency = isOwned and 0 or 0.8

        tile.LockedFrame.Visible = not (self.LocalReplica.Data.LevelData.Level >= (upgradeData.RequiredLevel or 1))
        tile.LockedFrame.TextLabel.Text = "Requires Level " .. (upgradeData.RequiredLevel or 1)
        
        tile.Activated:Connect(function()
            self:SelectUpgrade(upgradeData.Name)
        end)

        tile.Visible = true
        tile.Parent = self.TankScrollingFrame
    end
end

function TankShopUI:RenderTiles(forceSelectTank: string?)
    if self.Mode == "Tank" then
        self:_renderTanks(forceSelectTank)
    else
        self:_renderUpgrades()
    end
end

function TankShopUI:SelectTank(tankName: string)
    --local tankData: Types.TankData = TankData[tankName]
    self.SelectedTank = tankName
    self.TankDisplay:SetTank(tankName)
    self:UpdateBuyEquipButton()
end

function TankShopUI:SelectUpgrade(upgradeName: string)
    self.SelectedUpgrade = upgradeName
    self:UpdateBuyEquipButton()
end

function TankShopUI:UpdateBuyEquipButton()
    if self._buyButtonConnection then
        self._buyButtonConnection:Disconnect()
    end

    if self.Mode == "Tank" then
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
    else
        local upgradeType = self.Mode
        local selectedTank  = self.SelectedTank
        local selectedUpgrade = self.SelectedUpgrade

        local upgradeData: Types.TankUpgradeData = TankUtil.GetUpgradeData(selectedTank, upgradeType, selectedUpgrade)
        local isOwned = TankUtil.IsUpgradeOwned(self.LocalReplica, selectedTank, selectedUpgrade)
        local isEquipped = TankUtil.IsUpgradeEquipped(self.LocalReplica, selectedTank, upgradeType, selectedUpgrade)
        local meetsLevelReq = self.LocalReplica.Data.LevelData.Level >= (upgradeData.RequiredLevel or 1)

        self.BuyEquipButton.Visible = meetsLevelReq

        if isOwned then
            if isEquipped then
                self.BuyEquipButton.TextLabel.Text = "Unequip"
            else
                self.BuyEquipButton.TextLabel.Text = "Equip"
            end
            self._buyButtonConnection = self.BuyEquipButton.Activated:Connect(function()
                self.UpgradeService:RequestEquipUpgrade(selectedTank, self.Mode, selectedUpgrade, not isEquipped) -- pass in mode to keep granularity of Munition1, Munition2
            end)
        else
            self.BuyEquipButton.TextLabel.Text = "Buy"
            self._buyButtonConnection = self.BuyEquipButton.Activated:Connect(function()
                self.UpgradeService:RequestBuyUpgrade(selectedTank, upgradeType, selectedUpgrade)
            end)
        end
    end
end

function TankShopUI:UpdateCash()
    local moneyCounter = self.Frame:FindFirstChild("MoneyCounter")
    if moneyCounter then
        moneyCounter:WaitForChild("TextLabel").Text = tostring(self.LocalReplica.Data.Currency.Cash)
    end
end

function TankShopUI:UpdateEquippedDisplay()
    local tankData: Types.TankData = TankData[self.LocalReplica.Data.EquippedTank]
    self.TankButton.ItemNameLabel.TextLabel.Text = self.LocalReplica.Data.EquippedTank
    self.TankButton.ImageLabel.Image = tankData.Image

    local equippedUpgrades = TankUtil.GetCurrUpgrades(self.LocalReplica)

    self.EngineButton.ItemNameLabel.TextLabel.Text = tostring(equippedUpgrades.Engine)
    self.ArmorButton.ItemNameLabel.TextLabel.Text = tostring(equippedUpgrades.Armor)
    self.Munition1Button.ItemNameLabel.TextLabel.Text = tostring(equippedUpgrades.Munition1)
    self.Munition2Button.ItemNameLabel.TextLabel.Text = tostring(equippedUpgrades.Munition2)
end

function TankShopUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
    self.TankDisplay = Knit.GetController("TankDisplay")

    self.TankShopService = Knit.GetService("TankShopService")
    self.UpgradeService = Knit.GetService("UpgradeService")
end

function TankShopUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("TankShop")
	self.BuyEquipButton = self.Frame:WaitForChild("BuyEquip")
    self.BackButton = self.Frame:WaitForChild("Back")
    self.TankOptions = self.Frame:WaitForChild("TankOptions")
    self.TankScrollingFrame = self.TankOptions:WaitForChild("TankScrollingFrame")

    self.EquippedDisplay = self.Frame:WaitForChild("EquippedDisplay")
    self.TankButton = self.EquippedDisplay:WaitForChild("TankButton")
    self.EngineButton = self.EquippedDisplay:WaitForChild("EngineButton")
    self.ArmorButton = self.EquippedDisplay:WaitForChild("ArmorButton")
    self.Munition1Button = self.EquippedDisplay:WaitForChild("Munition1Button")
    self.Munition2Button = self.EquippedDisplay:WaitForChild("Munition2Button")

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
            self:UpdateEquippedDisplay()
        end)

        replica:ListenToChange({"LevelData", "Level"}, function()
            self:RenderTiles()
        end)


        self:UpdateEquippedDisplay()
        replica:ListenToChange({"TankUpgrades", "EquippedUpgrades"}, function()
            self:UpdateEquippedDisplay()
            self:RenderTiles()
        end)

        replica:ListenToChange({"TankUpgrades", "OwnedUpgrades"}, function()
            self:UpdateEquippedDisplay()
            self:RenderTiles()
        end)

        --- init left side

        local function initLeftButton(button: GuiObject, itemType: string)
            warn("INIT LEFT BUTTON:", button, itemType)
            button.Activated:Connect(function()
                warn("CLICKED:", itemType)
                self.Mode = itemType

                if itemType ~= "Tank" then
                    self.SelectedUpgradeType = itemType
                    self.SelectedUpgrade = nil
                end

                self:RenderTiles()
            end)
        end 

        initLeftButton(self.TankButton, "Tank")
        initLeftButton(self.EngineButton, "Engine")
        initLeftButton(self.ArmorButton, "Armor")
        initLeftButton(self.Munition1Button, "Munition1")
        initLeftButton(self.Munition2Button, "Munition2")
	end)
end

return TankShopUI

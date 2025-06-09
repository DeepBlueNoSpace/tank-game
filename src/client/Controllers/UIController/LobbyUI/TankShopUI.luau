local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TankData = require(Knit.Data.TankData)
local TankUtil = require(Knit.Modules.TankUtil)

local TankShopUI= Knit.CreateController({ Name = "TankShopUI", Open = false })
TankShopUI.SelectedTank = nil :: string?

function TankShopUI:OpenFrame()
    self.Open = true
    self.Frame.Visible = true
end

function TankShopUI:CloseFrame()
    self.Open = false
    self.Frame.Visible = false
end

function TankShopUI:RenderTiles(forceSelectTank: string?)
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

    warn("TANK SORT:", tanks)

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

function TankShopUI:SelectTank(tankName: string)
    --local tankData: Types.TankData = TankData[tankName]
    self.SelectedTank = tankName
    self.TankDisplay:SetTank(tankName)
    self:UpdateBuyEquipButton()
end

function TankShopUI:UpdateBuyEquipButton()
    local data: Types.TankData = TankData[self.SelectedTank]

    local meetsLevelReq = self.LocalReplica.Data.LevelData.Level >= (data.RequiredLevel or 1)
    self.BuyEquipButton.Visible = (self.LocalReplica.Data.EquippedTank ~= self.SelectedTank) and (meetsLevelReq) -- hide buy button if tank is already equipped or if level requirement is not met

    if TankUtil.OwnsTank(self.LocalReplica, self.SelectedTank) then
        self.BuyEquipButton.TextLabel.Text = "Equip"
    else
        self.BuyEquipButton.TextLabel.Text = "Buy"
    end
end

function TankShopUI:UpdateCash()
    local moneyCounter = self.Frame:FindFirstChild("MoneyCounter")
    if moneyCounter then
        moneyCounter:WaitForChild("TextLabel").Text = tostring(self.LocalReplica.Data.Currency.Cash)
    end
end

function TankShopUI:KnitInit()
	self.GameLoopService = Knit.GetService("GameLoopService")
	self.UIController = Knit.GetController("UIController")
    self.TankDisplay = Knit.GetController("TankDisplay")

    self.TankShopService = Knit.GetService("TankShopService")
end

function TankShopUI:KnitStart()
	self.Frame = self.UIController.LobbyGui:WaitForChild("TankShop")
	self.BuyEquipButton = self.Frame:WaitForChild("BuyEquip")
    self.BackButton = self.Frame:WaitForChild("Back")
    self.TankOptions = self.Frame:WaitForChild("TankOptions")
    self.TankScrollingFrame = self.TankOptions:WaitForChild("TankScrollingFrame")

    self.BackButton.Activated:Connect(function()
        self.UIController:AttemptClose(self)
        Knit.GetController("LobbyMainUI"):OpenFrame()
    end)

    self.BuyEquipButton.Activated:Connect(function()
        if self.SelectedTank == nil then
            warn("No tank selected!")
            return
        end
        
        if TankUtil.OwnsTank(self.LocalReplica, self.SelectedTank) then
            -- Equip the tank
            self.TankShopService:RequestEquipTank(self.SelectedTank)
        else
            -- Buy the tank
            self.TankShopService:RequestBuyTank(self.SelectedTank)
        end
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

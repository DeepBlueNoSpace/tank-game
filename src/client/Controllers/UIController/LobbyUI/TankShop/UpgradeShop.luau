--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local _Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local UpgradeTracks = require(ReplicatedStorage.Shared.Data.UpgradeTracks)
local UpgradeTypes = require(ReplicatedStorage.Shared.Data.UpgradeTypes)

local UpgradeShop = Knit.CreateController({ Name = "UpgradeShop", Open = false, CurrentTrack = "Damage"})


function UpgradeShop:KnitInit()
    self.UIController = Knit.GetController("UIController")
    self.DataController = Knit.GetController("DataController")
    self.TankShop = Knit.GetController("TankShopUI")
    self.ShopStats = Knit.GetController("ShopStats")
    self.UpgradeService = Knit.GetService("UpgradeService")
end

function UpgradeShop:KnitStart()
    self.TankShopFrame = self.UIController.LobbyGui:WaitForChild("TankShop")
    self.Frame = self.TankShopFrame:WaitForChild("Upgrades")
    self.UpgradeTrack = self.TankShopFrame:WaitForChild("UpgradeTrack")
    self.Display = self.UpgradeTrack:WaitForChild("Display")
    self.Prefab = self.Display:WaitForChild("Prefab")
    self.CloseButton = self.UpgradeTrack:WaitForChild("Close")

    for upgradeType: string, _  in UpgradeTypes do 
        local clicker = self.Frame:WaitForChild(upgradeType):WaitForChild("Clicker")
        clicker.Activated:Connect(function()
            self.CurrentTrack = upgradeType

            self:RenderTrack(upgradeType)
            self.UpgradeTrack.Visible = true
        end)
    end

    self.DataController:GetReplicaPromise(Player):andThen(function(replica)
        replica:ListenToChange("OwnedTanks", function() 
            self:RenderTrack(self.CurrentTrack)
            self.ShopStats:SetStatsForTank(self.TankShop.SelectedTank )
        end)
    end)

    self.CloseButton.Activated:Connect(function() 
        self.UpgradeTrack.Visible = false
    end)
end

function UpgradeShop:Open()
    self.Frame.Visible = true 
end

function UpgradeShop:Close()
    self.Frame.Visible = false 
end

function ConvertToPercentageIncrease(value: number) : string
    local increase = (value - 1) * 100
    local rounded = math.floor(increase + 0.5)
    return rounded .. "%"
end


function UpgradeShop:RenderTrack(trackName: string)
    local replica = self.DataController:GetReplica(Player)
    if not replica then 
        return 
    end

    local trackData = UpgradeTracks[trackName]
    local upgradeTypeData = UpgradeTypes[trackName]

    local selectedTankData = replica.Data.OwnedTanks[self.TankShop.SelectedTank]
    if not selectedTankData then 
        return 
    end

    local progress = selectedTankData[trackName]
    for _, object in self.Display:GetChildren() do 
        if object:IsA("Frame") then 
            if object.Visible then 
                object:Destroy() 
            end
        end
    end

    for i, data in trackData do 
        local tile = self.Prefab:Clone() 
        tile.Title.Text = string.format("%s %s", trackName, tostring(i))
        tile.Buff.Text = string.format("+%s %s", ConvertToPercentageIncrease(data.Effects[upgradeTypeData.HeadlineEffect]), upgradeTypeData.EffectDescription)
        tile.Icon.Image = upgradeTypeData.DisplayIcon
        
        if i <= progress then 
            --its owned 
            tile.Interact.Visible = false 
        elseif i == progress + 1 then 
            --its the one to buy 
            tile.Interact.Visible = true
        else
            tile.Interact.Visible = false 
            tile.Icon.ImageTransparency = 0.8
        end

        tile.Visible = true
        tile.Parent = self.Display

        tile.Interact.Activated:Connect(function() 
            self.UpgradeService:RequestUpgrade(self.TankShop.SelectedTank, trackName)
        end)
    end
end


return UpgradeShop
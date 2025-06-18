local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local UpgradeTracks = require(ReplicatedStorage.Shared.Data.UpgradeTracks)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)

local TankUtil = require(Knit.Modules.TankUtil)

local UpgradeService = Knit.CreateService {
    Name = "UpgradeService",
    Client = {},
}


function UpgradeService:KnitInit()
    self.DataService = Knit.GetService("DataService")
    self.CurrencyService = Knit.GetService("CurrencyService")
end


function UpgradeService:KnitStart()
    
end

function UpgradeService.Client:RequestUpgrade(player: Player, tankName: string, trackName: string): boolean
    local replica = UpgradeService.DataService:GetReplica(player)
    if not replica then 
        return false
    end

    local ownedTanks = replica.Data.OwnedTanks
    local tankUpgrades = ownedTanks[tankName]
    assert(tankUpgrades, "Player doesnt own the tank")

    local currentProgress = tankUpgrades[trackName]
    assert(currentProgress, "Track name is not under tank upgrades")

    local nextProgress = currentProgress+1

    local trackData = UpgradeTracks[trackName]
    assert(trackData, "No upgrade track")

    local upgradeToBuy = trackData[nextProgress]
    assert(upgradeToBuy, "No next track")

    local tankData = TankData[tankName]
    local costOfUpgrade = upgradeToBuy.PriceMultiplier*tankData.Cost

    if replica.Data.Currency.Cash < costOfUpgrade then 
        return false
    end

    replica:SetValue({"Currency", "Cash"}, replica.Data.Currency.Cash - costOfUpgrade)
    tankUpgrades[trackName] = nextProgress

    replica:SetValue({"OwnedTanks"}, ownedTanks)

    return true
end


return UpgradeService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TankUtil = require(Knit.Modules.TankUtil)

local UpgradeService = Knit.CreateService {
    Name = "UpgradeService",
    Client = {},
}

function UpgradeService:EquipUpgrade(player: Player, tank: string, upgradeType: string, upgradeName: string, enable: boolean?)
    warn("UpgradeService:EquipUpgrade - Player:", player.Name, "Tank:", tank, "UpgradeType:", upgradeType, "UpgradeName:", upgradeName, "ShouldEquip:", enable)
    local replica = UpgradeService.DataService:GetReplica(player)
    if not replica then
        warn("UpgradeService:EquipUpgrade - Replica not found for player", player.Name)
        return
    end

    -- validate that upgrade exists
    local upgradeData: Types.TankUpgradeData = TankUtil.GetUpgradeData(tank, upgradeType, upgradeName)
    if not upgradeData then
        warn("UpgradeService:EquipUpgrade - Upgrade data not found for", tank, upgradeType, upgradeName)
        return
    end

    if not TankUtil.IsUpgradeOwned(replica, tank, upgradeType, upgradeName) then
        warn("UpgradeService:EquipUpgrade - Upgrade NOT owned:", tank, upgradeType, upgradeName)
        return
    end

    local equippedUpgrades = replica.Data.TankUpgrades.EquippedUpgrades
    equippedUpgrades[tank] = equippedUpgrades[tank] or {}
    equippedUpgrades[tank][upgradeType] = enable and upgradeName or nil
    replica:SetValue({"TankUpgrades", "EquippedUpgrades"}, equippedUpgrades)
end

function UpgradeService.Client:RequestBuyUpgrade(player: Player, tank: string, upgradeType: string, upgradeName: string)
    warn("UpgradeService:RequestBuyUpgrade - Player:", player.Name, "Tank:", tank, "UpgradeType:", upgradeType, "UpgradeName:", upgradeName)
    local replica = UpgradeService.DataService:GetReplica(player)
    if not replica then
        warn("UpgradeService:RequestBuyUpgrade - Replica not found for player", player.Name)
        return
    end
    
    -- validate that upgrade exists
    local upgradeData: Types.TankUpgradeData = TankUtil.GetUpgradeData(tank, upgradeType, upgradeName)
    if not upgradeData then
        warn("UpgradeService:RequestBuyUpgrade - Upgrade data not found for", tank, upgradeType, upgradeName)
        return
    end

    if TankUtil.IsUpgradeOwned(replica, tank, upgradeType, upgradeName) then
        warn("UpgradeService:RequestBuyUpgrade - Upgrade already owned:", tank, upgradeType, upgradeName)
        return
    end

    local succ = UpgradeService.CurrencyService:AttemptSpendCurrency(player, upgradeData.CurrencyType, upgradeData.Cost)
    if not succ then
        warn("UpgradeService:RequestBuyUpgrade - Not enough currency for upgrade:", tank, upgradeType, upgradeName)
        return
    end

    local ownedUpgrades = replica.Data.TankUpgrades.OwnedUpgrades
    ownedUpgrades[tank] = ownedUpgrades[tank] or {}
    ownedUpgrades[tank][upgradeType] = ownedUpgrades[tank][upgradeType] or {}
    ownedUpgrades[tank][upgradeType][upgradeName] = true
    replica:SetValue({"TankUpgrades", "OwnedUpgrades"}, ownedUpgrades)
end

function UpgradeService.Client:RequestEquipUpgrade(player: Player, tank: string, upgradeType: string, upgradeName: string, enable: boolean?)
    UpgradeService:EquipUpgrade(player, tank, upgradeType, upgradeName, enable)
end

function UpgradeService:KnitInit()
    self.DataService = Knit.GetService("DataService")
    self.CurrencyService = Knit.GetService("CurrencyService")
end


function UpgradeService:KnitStart()
    
end


return UpgradeService

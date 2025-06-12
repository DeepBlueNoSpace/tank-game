local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UpgradeData = require(Knit.Data.UpgradeData)


local TankUtil = {}

function TankUtil.OwnsTank(replica, tankName)
    return replica.Data.OwnedTanks[tankName] == true
end

-- Helps for now while setting up the saving logic
function TankUtil.GetCurrUpgrades(replica)
    local ret = {
        Engine = nil,
        Armor = nil,
        Munition1 = nil,
        Munition2 = nil,
    }

    if replica.Data.TankUpgrades.EquippedUpgrades[replica.Data.EquippedTank] then
        for upgradeType, upgradeName in pairs(replica.Data.TankUpgrades.EquippedUpgrades[replica.Data.EquippedTank]) do
            ret[upgradeType] = upgradeName
        end
    end

    return ret
end

function TankUtil.IsUpgradeOwned(replica, tankName, upgradeType, upgradeName)
    if upgradeType == "Munition1" or upgradeType == "Munition2" then
        upgradeType = "Munitions"
    end
    
    if not replica.Data.TankUpgrades.OwnedUpgrades[tankName] then
        return false
    end

    if not replica.Data.TankUpgrades.OwnedUpgrades[tankName][upgradeType] then
        return false
    end

    return replica.Data.TankUpgrades.OwnedUpgrades[tankName][upgradeType][upgradeName] == true
end

function TankUtil.IsUpgradeEquipped(replica, tankName, upgradeType, upgradeName)
    if not replica.Data.TankUpgrades.EquippedUpgrades[tankName] then
        return false
    end

    return replica.Data.TankUpgrades.EquippedUpgrades[tankName][upgradeType] == upgradeName
end

function TankUtil.GetUpgradeData(tankName, upgradeType, upgradeName)
    if upgradeType == "Munition1" or upgradeType == "Munition2" then
        upgradeType = "Munitions"
    end

    local data = UpgradeData[tankName]
    if not data then
        return nil
    end


    data = data[upgradeType]
    if not data then
        return nil
    end

    data = data[upgradeName]
    if not data then
        return nil
    end

    return data
end

return TankUtil
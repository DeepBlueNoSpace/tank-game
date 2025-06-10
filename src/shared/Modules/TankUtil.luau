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
    if not replica.Data.TankUpgrades.OwnedUpgrades[tankName] then
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

return TankUtil
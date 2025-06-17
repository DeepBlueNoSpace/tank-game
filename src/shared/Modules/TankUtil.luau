local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UpgradeData = require(Knit.Data.UpgradeData)


local TankUtil = {}

function TankUtil.OwnsTank(replica, tankName)
    return replica.Data.OwnedTanks[tankName] == true
end

-- Helps for now while setting up the saving logic
function TankUtil.GetCurrUpgrades(replica)
    local ret = {}

    ret["Engine"] = TankUtil.GetEquippedUpgrade(replica, replica.Data.EquippedTank, "Engine")
    ret["Armor"] = TankUtil.GetEquippedUpgrade(replica, replica.Data.EquippedTank, "Armor")
    ret["Munition1"] = TankUtil.GetEquippedUpgrade(replica, replica.Data.EquippedTank, "Munition1")
    ret["Munition2"] = TankUtil.GetEquippedUpgrade(replica, replica.Data.EquippedTank, "Munition2")

    return ret
end

function TankUtil.IsUpgradeOwned(replica, tankName, upgradeName)
    --warn("IsUpgradeOwned called for tank: " .. tankName .. ", upgrade: " .. upgradeName)
    local inDefaults = false
    for upgradeType, name in pairs(UpgradeData[tankName]["Defaults"]) do
        if name == upgradeName then
            inDefaults = true
            break
        end
    end

    return inDefaults or (replica.Data.TankUpgrades.OwnedUpgrades[tankName] and replica.Data.TankUpgrades.OwnedUpgrades[tankName][upgradeName] == true)
end

function TankUtil.IsUpgradeEquipped(replica, tankName, upgradeType, upgradeName)
    return TankUtil.GetEquippedUpgrade(replica, tankName, upgradeType) == upgradeName
end

function TankUtil.GetEquippedUpgrade(replica, tankName, upgradeType)
    local currEquipped = replica.Data.TankUpgrades.EquippedUpgrades[tankName] and replica.Data.TankUpgrades.EquippedUpgrades[tankName][upgradeType]
    if currEquipped then
        return currEquipped
    end

    -- if tank isn't owned, or no upgrade is formally equipped, return the default upgrade if it exists

    return UpgradeData[tankName]["Defaults"][upgradeType]
end

function TankUtil.GetUpgradeData(tankName, upgradeType, upgradeName)
    if upgradeName == nil then
        return nil
    end
    
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
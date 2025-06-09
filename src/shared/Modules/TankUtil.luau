local TankUtil = {}

function TankUtil.OwnsTank(replica, tankName)
    return replica.Data.OwnedTanks[tankName] == true
end

return TankUtil
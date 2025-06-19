local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TankData = require(Knit.Data.TankData)
local TankUtil = require(Knit.Modules.TankUtil)

local TankShopService = Knit.CreateService {
    Name = "TankShopService",
    Client = {},
}

function TankShopService.Client:RequestEquipTank(player: Player, tankType: string)
    local replica = TankShopService.DataService:GetReplica(player)
    if not replica then
        warn("No replica found for player: " .. player.Name)
        return false
    end

    local data: Types.TankData = TankData[tankType]
    if not data then
        warn("Invalid tank type: " .. tankType)
        return false
    end

    if not TankUtil.OwnsTank(replica, tankType) then
        warn(player, "doesnt own tank:", tankType)
        return false
    end

    replica:SetValue({"EquippedTank"}, tankType)
    return true
end

function TankShopService.Client:RequestBuyTank(player: Player, tankType: string)
    local replica = TankShopService.DataService:GetReplica(player)
    if not replica then
        warn("No replica found for player: " .. player.Name)
        return false
    end

    local data: Types.TankData = TankData[tankType]
    if not data then
        warn("Invalid tank type: " .. tankType)
        return false
    end

    if TankUtil.OwnsTank(replica, tankType) then
        warn("Player already owns tank: " .. tankType)
        return false
    end

    local succ = Knit.GetService("CurrencyService"):AttemptSpendCurrency(player, data.CurrencyType, data.Cost)
    if not succ then
        return false
    end

    local ownedTanks = replica.Data.OwnedTanks
    ownedTanks[tankType] = {
        Wrap = nil,
        Armor = 0;
        Engine = 0;
        Damage = 0;
    }

    replica:SetValue({"OwnedTanks"}, ownedTanks) -- do it like this to prompt update on the ownedtanks field
    replica:SetValue({"EquippedTank"}, tankType)
    return true
end

function TankShopService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end


function TankShopService:KnitStart()
    
end


return TankShopService

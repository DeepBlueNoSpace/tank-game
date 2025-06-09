local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CurrencyData = require(Knit.Data.CurrencyData)

local CurrencyService = Knit.CreateService {
    Name = "CurrencyService",
    Client = {},
}

function CurrencyService:IncrementCurrency(player: Player, currencyName: string, amount: number)
    if not CurrencyData[currencyName] then
        warn("Invalid currency name:", currencyName)
        return
    end

    self.DataService:GetReplicaPromise(player):andThen(function(replica)
        replica:SetValue({"Currency", currencyName}, replica.Data.Currency[currencyName] + amount)
    end)
end

function CurrencyService:AttemptSpendCurrency(player: Player, currencyName: string, amount: number)
    if amount < 0 then
        warn("Attempted to spend a negative amount of currency:", amount)
        return false
    end

    if not CurrencyData[currencyName] then
        warn("Invalid currency name:", currencyName)
        return false
    end

    local replica = self.DataService:GetReplica(player)
    if not replica then
        warn("No replica found for player:", player.Name)
        return false
    end

    if replica.Data.Currency[currencyName] < amount then
        warn("Not enough currency:", player.Name, currencyName, replica.Data.Currency[currencyName], amount)
        return false
    end

    replica:SetValue({"Currency", currencyName}, replica.Data.Currency[currencyName] - amount)
    return true
end

function CurrencyService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end


function CurrencyService:KnitStart()
    
end


return CurrencyService

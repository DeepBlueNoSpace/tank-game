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

function CurrencyService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end


function CurrencyService:KnitStart()
    
end


return CurrencyService

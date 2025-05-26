return function (context, player, currencyName, amount)
    local Knit = require(game.ReplicatedStorage.Packages.Knit)
    local replica =Knit.GetService("DataService"):GetReplica(player)
    replica:SetValue({"Currency", currencyName}, replica.Data.Currency[currencyName] + amount)
end
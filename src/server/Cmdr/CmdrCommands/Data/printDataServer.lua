return function (context, targetPlayer)
    local Knit = require(game.ReplicatedStorage.Packages.Knit)
    Knit.GetService("DataService"):_debugPrint(context.Executor, targetPlayer)

    return "Printed Data"
end
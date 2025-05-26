return function (context, targetPlayer, confirm)
    local Knit = require(game.ReplicatedStorage.Packages.Knit)
    if confirm == true then
        Knit.GetService("DataService"):WipeData(targetPlayer)
    else 
        warn("Didn't confirm on data wipe")
    end

    return "Wiped data"
end
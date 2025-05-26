return function(context, player, amount)
	local Knit = require(game.ReplicatedStorage.Packages.Knit)
	local replica = Knit.GetService("DataService"):GetReplica(player)
	replica:SetValue({ "Strength" }, amount)
end

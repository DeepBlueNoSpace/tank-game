return function(context, targetPlayer, petId)
	local Knit = require(game.ReplicatedStorage.Packages.Knit)
	Knit.GetService("PetService"):GivePet(targetPlayer, {
		["petId"] = petId[1],
	})

	return "Gave unit"
end

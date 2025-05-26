return {
	Name = "pet-give",
	Aliases = { "none" },
	Description = "Add pet to inventory",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player whose data to print",
		},
		{
			Type = "pet",
			Name = "petId",
			Description = "The pet to give",
		},
	},

	ClientRun = function(context, targetPlayer)
		--local Knit = require(game.ReplicatedStorage.Packages.Knit)
		--Knit.GetController("DataController"):_debugPrint(targetPlayer)
	end,
}

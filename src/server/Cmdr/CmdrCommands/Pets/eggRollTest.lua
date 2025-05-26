return {
	Name = "egg-roll-test",
	Aliases = { "none" },
	Description = "Add pet to inventory",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "eggId",
			Description = "The egg to test rolling",
		},
		{
			Type = "number",
			Name = "luck",
			Description = "luck lol",
		},
	},

	ClientRun = function(context, targetPlayer)
		--local Knit = require(game.ReplicatedStorage.Packages.Knit)
		--Knit.GetController("DataController"):_debugPrint(targetPlayer)
	end,
}

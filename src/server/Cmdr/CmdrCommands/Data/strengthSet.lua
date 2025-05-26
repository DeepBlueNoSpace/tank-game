return {
	Name = "strength-set",
	Aliases = { "none" },
	Description = "Set strength",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to give money to",
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "Amount of strength",
		},
	},
}

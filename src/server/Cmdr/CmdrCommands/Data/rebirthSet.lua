return {
	Name = "rebirth-set",
	Aliases = { "none" },
	Description = "Give amount of arbitrary currency",
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
			Description = "rebirth number",
		},
	},
}

return {
	Name = "currency-give";
	Aliases = {"none"};
	Description = "Give amount of arbitrary currency";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to give money to"
		},
		{
			Type = "currency";
			Name = "currency";
			Description = "The currency type to award"
		},
		{
			Type = "integer";
			Name = "amount";
			Description = "Amount of money"
		},
	};
}
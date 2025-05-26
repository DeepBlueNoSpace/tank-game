return {
	Name = "data-wipe";
	Aliases = {"none"};
	Description = "Wipes player's data";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player whose data to wipe"
		},
		{
			Type = "boolean";
			Name = "confirm";
			Description = "Type 'true' to confirm you want to wite"
		}
	};

	ClientRun = function(context, targetPlayer)
		local Knit = require(game.ReplicatedStorage.Packages.Knit)
    	Knit.GetController("DataController"):_debugPrint(targetPlayer)
	end
}
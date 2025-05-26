return {
	Name = "data-print";
	Aliases = {"none"};
	Description = "Prints Data on Server and Client";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player whose data to print"
		}
	};

	ClientRun = function(context, targetPlayer)
		local Knit = require(game.ReplicatedStorage.Packages.Knit)
    	Knit.GetController("DataController"):_debugPrint(targetPlayer)
	end
}
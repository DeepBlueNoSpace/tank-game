return function(context, eggId, luck)
	local Knit = require(game.ReplicatedStorage.Packages.Knit)
	local PetEggData = require(Knit.Data.Pets.PetEggData)
	local RNGUtil = require(game.ReplicatedStorage.Shared.Modules.RNGUtil)

	local eggChances = PetEggData[eggId].Lootbox

	warn("TEST ROLLING", eggId, luck, eggChances)

	local NUM_ROLLS = 1000000

	local count = {}
	for key, value in pairs(eggChances) do
		count[value.Item] = 0
	end

	for i=1, NUM_ROLLS do
		local result = RNGUtil.Roll(eggChances, 1, luck)
		count[result[1]] = count[result[1]] + 1
	end

	local cleanedup = {}
	for key, value in pairs(count) do
		table.insert(cleanedup, {PetId = key, Count = value, Percent = value / NUM_ROLLS * 100})
	end

	table.sort(cleanedup, function(a, b)
		return a.Count > b.Count
	end)

	for key, value in pairs(cleanedup) do
		warn(value.PetId, ":", value.Count, value.Percent)
	end

	return "Gave unit"
end

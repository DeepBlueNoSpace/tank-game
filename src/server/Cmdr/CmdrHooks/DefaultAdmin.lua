local IsStudio = game:GetService("RunService"):IsStudio()
return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "DefaultAdmin" and context.Executor:GetRankInGroup(35596010) < 254 and not IsStudio then
			return "You don't have permission to run this command"
		end
	end)
end
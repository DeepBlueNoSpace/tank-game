local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function GetSafeCharacter(): Model?
	local character = Player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return nil
	end

	if character.Parent == nil then
		return
	end

	return character
end

return GetSafeCharacter
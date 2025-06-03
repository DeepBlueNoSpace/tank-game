--Stops players from jumping so they can't get out their tank lol
local ContextActionService = game:GetService("ContextActionService")

local function blockJump()
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("DisableJump", blockJump, false,
	Enum.KeyCode.Space,
	Enum.UserInputType.Gamepad1,
	Enum.UserInputType.Touch
)

return true
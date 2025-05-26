local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local PathModule = require(game.ReplicatedStorage.Shared.Modules.MobPath)

-- Create a new toolbar section titled "Custom Script Tools"
local toolbar = plugin:CreateToolbar("Path Vizualizer")
local newScriptButton = toolbar:CreateButton("Path Vizualizer", "Toggle Path Vizualizer", "rbxassetid://14978048121")
newScriptButton.ClickableWhenViewportHidden = true

local function onNewScriptButtonClicked()
	local selectedObjects = Selection:Get()
	local parent = game:GetService("ServerScriptService")
	if #selectedObjects > 0 then
		parent = selectedObjects[1]
	end

	local newScript = Instance.new("Script")
	newScript.Source = ""
	newScript.Parent = parent
	ChangeHistoryService:SetWaypoint("Added new empty script")
end

local function updateVizualization()
    local PATHMODEL = workspace:FindFirstChild("PATH")
    local path = PathModule.generateFromModel(PATHMODEL)
    PathModule._vizualize(path, 2)
end

local enabled = false
local connection = nil
local lastChangeTime = 0

newScriptButton.Click:Connect(function()
    warn("TOGGLE VISUALIZATION", not enabled)
    --local PATHMODEL = workspace:FindFirstChild("PATH")

    if enabled then
        enabled = false
        workspace["_pathViz"]:Destroy()
    else
        enabled = true
        while enabled do
            updateVizualization()
            wait(1)
        end
    end
end)
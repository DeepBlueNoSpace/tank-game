local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

-- Create a new toolbar section titled "Custom Script Tools"
local toolbar = plugin:CreateToolbar("Create Hitbox")
local newScriptButton = toolbar:CreateButton("Create Hitbox", "Create Hitbox", "rbxassetid://14978048121")
newScriptButton.ClickableWhenViewportHidden = true

newScriptButton.Click:Connect(function()
    local selected = Selection:Get()
    if #selected ~= 1 then
        warn("Select exactly 1 model")
        return
    end


end)

-- delete wleds
local function asdf()
    local Selection = game:GetService("Selection")
    local selected = Selection:Get()
    if #selected ~= 1 then
        warn("Select exactly 1")
        return
    end
    for _, v in pairs(selected[1]:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("ManualWeld") then
            v:Destroy()
        end
    end
end
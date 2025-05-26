local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local function HandleDungeonSpawner(spawner: Model) 
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Start Dungeon?"
    proximityPrompt.Parent = spawner:WaitForChild("Head")

    local debounce = false
    proximityPrompt.Triggered:Connect(function()
        if debounce then 
            return 
        end
        debounce = true
        local DungeonService = Knit.GetService("DungeonService")
        DungeonService:RequestDungeon():andThen(function(dungeonData)
            if dungeonData then 
                local DungeonController = Knit.GetController("DungeonController")
                DungeonController:StartDungeon(dungeonData)
            end
            debounce = false
        end)
    end)
end

for _, spawner in CollectionService:GetTagged("DungeonSpawner") do 
    HandleDungeonSpawner(spawner)
end

CollectionService:GetInstanceAddedSignal("DungeonSpawner"):Connect(HandleDungeonSpawner)

return true
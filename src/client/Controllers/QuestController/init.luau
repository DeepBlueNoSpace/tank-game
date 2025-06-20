local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestData = require(Knit.Data.QuestData)

local QuestController = Knit.CreateController { Name = "QuestController" }
QuestController.ActiveQuests = {}

function QuestController:KnitInit()
    self.DataController = Knit.GetController("DataController")
end


function QuestController:KnitStart()
    local ClientQuest = require(script:WaitForChild("ClientQuest"))

    self.DataController:GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
        for questName, data: Types.QuestData in QuestData.GenericTasks do
            local quest = ClientQuest.new(questName)
            table.insert(self.ActiveQuests, quest)
            local uiComponent = Knit.GetController("QuestUI"):AddQuestTile(questName)
            quest:HookUIComponent(uiComponent)
        end
    end)
end


return QuestController

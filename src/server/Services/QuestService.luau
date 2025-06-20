local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestUtil = require(Knit.Modules.QuestUtil)
local QuestData = require(Knit.Data.QuestData)

local QuestService = Knit.CreateService {
    Name = "QuestService",
    Client = {},
}

function QuestService:AttemptCompleteQuest(player: Player, questName: string)
    local data = QuestUtil.GetQuestData(questName)
    if not data then
    warn("QuestService:AttemptCompleteQuest - Invalid quest name:", questName)
        return false
    end

    local replica = Knit.GetController("DataController"):GetReplica(player)
    if not replica then
        warn("QuestService.Client:RequestCompleteQuest - No replica found for player", player.Name)
        return
    end

    local hasCompleted, previouslyCompleted = QuestUtil.IsQuestCompleted(replica, questName)

    if not hasCompleted or previouslyCompleted then
        return false
    end

    local completedQuests = replica.Data.Quests.Completed
    completedQuests[questName] = true

    if hasCompleted then
        if previouslyCompleted then
            return false
        else
            -- Logic to reward the player for completing the quest
            replica.Data.Quests.Completed[questName] = true
            replica.Data.Stats[questName] = (replica.Data.Stats[questName] or 0) + 1
            
            -- Notify client of completion
            self.Client.OnQuestCompleted:Fire(player, questName)
        end
    else
        warn("QuestService.Client:RequestCompleteQuest - Quest not completed yet:", questName)
    end
end

function QuestService.Client:RequestCompleteQuest(player: Player, questName: string)

end

function QuestService:KnitInit()
    
end


function QuestService:KnitStart()
    
end


return QuestService

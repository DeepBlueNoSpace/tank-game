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
    local data: Types.QuestData = QuestUtil.GetQuestData(questName)
    if not data then
        warn("QuestService:AttemptCompleteQuest - Invalid quest name:", questName)
        return false
    end

    local replica = Knit.GetService("DataService"):GetReplica(player)
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
    replica:SetValue({"Quests", "Completed"}, completedQuests)

    self.RewardService:GiveReward(player, data.Reward)   
end

function QuestService.Client:RequestCompleteQuest(player: Player, questName: string)
    QuestService:AttemptCompleteQuest(player, questName)
end

function QuestService:KnitInit()
    self.RewardService = Knit.GetService("RewardService")
    
end


function QuestService:KnitStart()
    
end


return QuestService

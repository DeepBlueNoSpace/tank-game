local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestData = require(Knit.Data.QuestData)

local QuestUtil = {}

function QuestUtil.IsQuestCompleted(replica, questName: string)
    if not replica or not questName then
        warn("QuestUtil.IsQuestCompleted - Invalid input", replica, questName)
        return false, nil
    end

    local data = QuestUtil.GetQuestData(questName)
    if not data then
        warn("QuestUtil.IsQuestCompleted - Invalid quest name: " .. tostring(questName))
        return false, nil
    end

    local previouslyCompleted = replica.Data.Quests.Completed[questName] ~= nil
    local hasCompleted = replica.Data.Stats[data.StatName] >= data.StatCount

    return hasCompleted, previouslyCompleted
end

-- This exists because QuestData might be fragmented for organization
function QuestUtil.GetQuestData(questName: string)
    if not questName then
        warn("QuestUtil.GetQuestData - Invalid quest name: " .. tostring(questName))
        return nil
    end

    return QuestData.GenericTasks[questName]
end

return QuestUtil
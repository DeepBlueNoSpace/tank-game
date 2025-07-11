local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)
local QuestData = require(Knit.Data.QuestData)
local QuestUtil = require(Knit.Modules.QuestUtil)
local Trove = require(Knit.Packages.Trove)

local LocalPlayer = game.Players.LocalPlayer

local ClientQuest = {}
ClientQuest.__index = ClientQuest

function ClientQuest.new(questName: string)
    local self = setmetatable({}, ClientQuest)

    self.Trove = Trove.new()

    self.QuestName = questName
    self.Data = QuestData.GenericTasks[questName]
    if not self.Data then
        error("ClientQuest.new - Invalid quest name: " .. tostring(questName))
    end

    self.Replica = nil

    self.UIComponents = {}

    self:HookPlayerData()

    return self
end

function ClientQuest:HookPlayerData()
    Knit.GetController("DataController"):GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
        self.Replica = replica

        self.Trove:Add(self.Replica:ListenToChange({"Stats", self.Data.StatName}, function()
            self:Update()
        end))

        self:Update()
    end)
end

function ClientQuest:HookUIComponent(frame:Frame)
    table.insert(self.UIComponents, frame)
    frame.Destroying:Connect(function()
        for i, uiComponent in ipairs(self.UIComponents) do
            if uiComponent == frame then
                table.remove(self.UIComponents, i)
                break
            end
        end
    end)

    self:Update()
end

function ClientQuest:Update()
    --warn("ClientQuest - Update", self.QuestName, self)

    if not self.Replica then
        repeat task.wait() until self.Replica
    end

    local hasCompleted, previouslyCompleted = QuestUtil.IsQuestCompleted(self.Replica, self.QuestName)
    if hasCompleted and not previouslyCompleted then
        --warn("ClientQuest - Completing quest:", self.QuestName)
        Knit.GetService("QuestService"):RequestCompleteQuest(self.QuestName) -- asks for rewards to be distributed
    end

    local currCount, requiredCount = self.Replica.Data.Stats[self.Data.StatName], self.Data.StatCount
    local progressAlpha = math.clamp(currCount / requiredCount, 0, 1)

    for i, frame in pairs(self.UIComponents) do
        local descriptionLabel = frame:WaitForChild("DescriptionLabel")
        local progressBar = frame:WaitForChild("ProgressBar")
        
        descriptionLabel.Text = self.Data.Description
        progressBar:WaitForChild("Fill").Size = UDim2.new(progressAlpha, 0, 1, 0)
        progressBar:WaitForChild("TextLabel").Text = string.format("%d/%d", math.min(currCount,requiredCount), requiredCount)

        frame:WaitForChild("Reward"):WaitForChild("TextLabel").Text = string.format("$%d", self.Data.Reward.Amount)

        if hasCompleted then
            frame:WaitForChild("Completed").Visible = true
        end
    end
end

function ClientQuest:Destroy()
    self.Trove:Destroy()
end


return ClientQuest

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DungeonService = Knit.CreateService({ Name = "DungeonService", Client = {}, LiveDungeons = {} })

local DungeonSequence = require(script.DungeonSequence)

function DungeonService:KnitInit()

end

function DungeonService:KnitStart()

end

function DungeonService.Client:RequestDungeon(player: Player)
    if DungeonService.LiveDungeons[player] then 
        return 
    end

    DungeonService.LiveDungeons[player] = DungeonSequence.new(player)
    return DungeonSequence:GetInitData()
end

function DungeonService.Client:GetNextRollResult(player: Player)
    local sequence = DungeonService.LiveDungeons[player] 
    local result, unindex = sequence:GetNextRollResult()

    if unindex then 
        DungeonService.LiveDungeons[player] = nil 
    end

    return result 
end

return DungeonService
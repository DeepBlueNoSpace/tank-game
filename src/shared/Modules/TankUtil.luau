--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local UpgradeTypes = require(ReplicatedStorage.Shared.Data.UpgradeTypes)

local Knit = require(ReplicatedStorage.Packages.Knit)

local TankUtil = {}

function TankUtil.OwnsTank(replica, tankName)
    return replica.Data.OwnedTanks[tankName]
end

function TankUtil.GetAttribute(attribute: string, tankType: string, _savedTankData: Types.TankUpgrades): number
    local baseData = TankData[tankType].BaseAtrributes
    --local multiplier = 1 + (tankUpgrades[attribute]*0.2)
    return baseData[attribute] --* multiplier
end

function TankUtil.GetEquippedPlayerTankAndUpgrades(player) : (string?, Types.TankData?, Types.TankUpgrades?)
    local DataService = Knit.GetService("DataService")
    local replica = DataService:GetReplica(player)
    if not replica then 
        return 
    end

    local equippedTankType = replica.Data.EquippedTank
    local baseData = TankData[equippedTankType]
    local tankUpgrades = replica.Data.OwnedTanks[equippedTankType]


    return equippedTankType, baseData, tankUpgrades
end

function TankUtil.SpawnTankModelAtPart(tankType: string, part: BasePart)
    local tankModel = ReplicatedStorage.Assets.Tanks[tankType]:Clone()

    local cf, bbSize = tankModel:GetBoundingBox()
    local bbOffset = tankModel.PrimaryPart.CFrame:ToObjectSpace(cf)

    tankModel:SetPrimaryPartCFrame(part.CFrame * CFrame.new(0,-part.Size.Y/2 + bbSize.Y/2,0) * bbOffset)

    return tankModel
end



return TankUtil
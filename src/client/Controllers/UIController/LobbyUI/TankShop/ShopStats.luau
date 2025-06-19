--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local Spring = require(ReplicatedStorage.Shared.Modules.Spring)
local UpgradeTracks = require(ReplicatedStorage.Shared.Data.UpgradeTracks)

local ShopStats = Knit.CreateController({ Name = "ShopStats"})

local Stats = {
     MaxDamage = {
        Min = math.huge, 
        Max = 0,
        Spring = Spring.new(0, 0, 30, 1),
        AbsValue = 0, 
        UpgradeTrack = "Damage",
    },
    Acceleration = {
        Min = math.huge, 
        Max = 0,
        Spring = Spring.new(0, 0, 30, 1),
        AbsValue = 0, 
    },
    Health = {
        Min = math.huge, 
        Max = 0,
        Spring = Spring.new(0, 0, 30, 1),
        AbsValue = 0, 
        UpgradeTrack = "Armor",
    },
    Cooldown = {
        Min = math.huge, 
        Max = 0,
        Spring = Spring.new(0, 0, 30, 1),
        Inverse = true,
        AbsValue = 0, 
    },
    MaxSpeed = {
        Min = math.huge, 
        Max = 0,
        Spring = Spring.new(0, 0, 30, 1),
        AbsValue = 0, 
        UpgradeTrack = "Engine"
    },
} :: {[string]: {Min: number, Inverse: boolean?, UpgradeTrack: string?, Max: number, Spring: Spring.SpringType}}

function ShopStats:KnitInit()
    self.UIController = Knit.GetController("UIController")
    self.DataController = Knit.GetController("DataController")
    self.TankShop = Knit.GetController("TankShopUI")
end

local function lerp(v0: number,v1: number,t: number): number
    return v0 + (v1-v0) * t 
end

function ShopStats:KnitStart()
    self:CalculateBaseStats()

    self.Frame = self.UIController.LobbyGui:WaitForChild("TankShop"):WaitForChild("Stats"):WaitForChild("List")
    RunService.Heartbeat:Connect(function(dT) 
        --TODO: only run when shop is open
        for statName, info in Stats do 
            local value = info.Spring:Solve(dT)
            local frame = self.Frame:FindFirstChild(statName)
            frame.Bar.Fill.Size = UDim2.fromScale(value, 1)

            frame.Value.Text = tostring(math.floor(lerp(info.Min, info.Max, value)+0.5))
        end
    end)
end

function ShopStats:CalculateBaseStats()
    for _, tankData in TankData do 
        local attributes = tankData.BaseAtrributes

        for statName, statData in Stats do 
            local maxMultiplier = 1 
            if statData.UpgradeTrack then 
                maxMultiplier = UpgradeTracks[statData.UpgradeTrack][4].Effects[statName]
            end

            --TODO: augment these stats as if they were maxed out
            if attributes[statName] > statData.Max then 
                statData.Max = attributes[statName]*maxMultiplier
            elseif attributes[statName] < statData.Min then
                statData.Min = attributes[statName]
            end
        end
    end
end

function ShopStats:SetStatsForTank(tankName: string)
    local tankData = TankData[tankName]
    local tankAttributes = tankData.BaseAtrributes

    local tankUpgradeData = self.TankShop.LocalReplica.Data.OwnedTanks[tankName]

    for statName, statData in Stats do 
        local multiplier = 1 
        if statData.UpgradeTrack and tankUpgradeData then 
            local upgradeProgress = tankUpgradeData[statData.UpgradeTrack]
            local upgradeTrack = UpgradeTracks[statData.UpgradeTrack]
            if upgradeProgress > 0 then 
                multiplier = upgradeTrack[upgradeProgress].Effects[statName]
            end
        end

        local value = tankAttributes[statName]*multiplier
        local i = (value-statData.Min)/(statData.Max-statData.Min)
        if statData.Inverse then 
            i = 1 - i 
        end

        statData.Spring:SetTarget(i)
    end
end



return ShopStats
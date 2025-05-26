local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local AnalyticsService = Knit.CreateService({ Name = "AnalyticsService" })

local BUILD_ID = "0.0"
function AnalyticsService:KnitInit() end

function AnalyticsService:KnitStart()
	self.GAModule = require(ReplicatedStorage.Shared.GA)
	self.GAModule:setEnabledInfoLog(false)
	self.GAModule:setEnabledVerboseLog(false)
	self.GAModule:configureBuild(BUILD_ID)

	self.GAModule:initServer("e88c5479a1d7cba85da1af1277bee46c", "7941859f06d693c84d2b0964f07a621ae81f5b9e")
end

function AnalyticsService:RecordEconomySink(player, sum, type, id)
	self.GAModule:addResourceEvent(player.UserId, {
		flowType = self.GAModule.EGAResourceFlowType.Sink,
		currency = "Gems",
		amount = sum,
		itemType = type,
		itemId = id,
	})
end

function AnalyticsService:RecordDesignEvent(player, id, value)
	self.GAModule:addDesignEvent(player.UserId, {
		eventId = id,
		value = value,
	})
end

function AnalyticsService:RecordEconomySource(player, sum, type, id)
	self.GAModule:addResourceEvent(player.UserId, {
		flowType = self.GAModule.EGAResourceFlowType.Source,
		currency = "Gems",
		amount = sum,
		itemType = type,
		itemId = id,
	})
end

return AnalyticsService

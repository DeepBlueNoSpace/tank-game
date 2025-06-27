--!strict
local TEST_CONFIGS = {}
TEST_CONFIGS.TESTING = true

--configurables
TEST_CONFIGS.CLEAN_DATA = true -- data is fresh each time

TEST_CONFIGS.ROUND_TIME = false -- force round time to be X seconds, FALSE if not usig this


TEST_CONFIGS.TANK_DMG = false  -- force set damage all tank bullets do
TEST_CONFIGS.VISUALISE_AIM = false  

TEST_CONFIGS.SOUNDTRACK_OFF = true

local PLACEID = 138314303849362
local STAGINGID = 0 --112899678167402 SUCK MY BALLS TEST CONFIGS SHOULD BE ON IN STAGING TURN THEM OFF IF U DONT WANT EM

function TEST_CONFIGS.Is(value: string): boolean
	return TEST_CONFIGS.TESTING and TEST_CONFIGS[value]
end

local RunService = game:GetService("RunService")

if (not RunService:IsStudio()) and (game.PlaceId == PLACEID or game.PlaceId == STAGINGID) then
	TEST_CONFIGS.TESTING = false
end

return TEST_CONFIGS

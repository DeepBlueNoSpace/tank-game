local TEST_CONFIGS = {}
TEST_CONFIGS.TESTING = false

--configurables
TEST_CONFIGS.CLEAN_DATA = true -- data is fresh each time
TEST_CONFIGS.PUMP_TEST = false -- 1 rep to pump, pump last longer
TEST_CONFIGS.QUICK_BATTLES = false -- less transition and waiting time
TEST_CONFIGS.INF_CASH = false
TEST_CONFIGS.INF_STRENGTH = false
TEST_CONFIGS.LOADSCREEN_OFF = true -- pastes weights in order in game
TEST_CONFIGS.INF_REBIRTH = 0 -- pastes weights in order in game

TEST_CONFIGS.SOUNDTRACK_OFF = true
TEST_CONFIGS.ANY_WORLD = false -- every world is unlocked
TEST_CONFIGS.FAST_WALKSPEED = false -- set to false or 22
TEST_CONFIGS.MEGA_STRONG = false -- doesnt write to data schema, instead returns high damage value. ONLY PLAYERS
TEST_CONFIGS.MEGA_FIT = false -- doesnt write to data schema, instead returns high health value. ONLY PLAYERS
TEST_CONFIGS.LAYOUT_ALL_WEIGHTS = false -- pastes weights in order in game
TEST_CONFIGS.ONE_CLICK_PROGRESSION = false -- after one lift moves player to the next weight

local PLACEID = 138314303849362
local STAGINGID = 0 --112899678167402 SUCK MY BALLS TEST CONFIGS SHOULD BE ON IN STAGING TURN THEM OFF IF U DONT WANT EM

function TEST_CONFIGS.Is(value)	
	return TEST_CONFIGS.TESTING and TEST_CONFIGS[value]
end

local RunService = game:GetService("RunService")

if (not RunService:IsStudio()) and (game.PlaceId == PLACEID or game.PlaceId == STAGINGID) then
	TEST_CONFIGS.TESTING = false
end

return TEST_CONFIGS

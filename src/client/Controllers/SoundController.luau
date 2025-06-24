--!strict 
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)

local Assets = ReplicatedStorage.Assets

local SoundAssets = Assets.Sound

local DEFAULT_PARENT = SoundService
local DEFAULT_VOLUME = 5
local DEFAULT_PLAYBACK_SPEED = 1


local SoundController = Knit.CreateController({ Name = "SoundController"})

local function GetSoundInstance(soundSource: number | Sound | string | Folder): Sound 
    if type(soundSource) == "number" then
		local soundInstance = Instance.new("Sound") :: Sound
		soundInstance.SoundId = string.format("rbxassetid://%s", tostring(soundSource))
        return soundInstance
	elseif type(soundSource) == "string" then
		return SoundAssets[soundSource]:Clone()
    elseif typeof(soundSource) == "Instance" and soundSource:IsA("Folder") then 
        local children = soundSource:GetChildren()
        local selectedChild = children[math.random(1,#children)]::Sound 
        return selectedChild:Clone() 
	else 
        assert(soundSource:IsA("Sound"), "Valid type not sent for sound")
		return soundSource:Clone()
	end
end

--Don't clone new sounds for this function.
--If soundSource is a...
--Number: it puts that number as the ID into a fresh instance
--Sound object: it clones and plays it 
--String: it looks for a sound with that name under the Sound folder in Assets
--Folder: it clones a random child from the source folder. Make sure there are only sounds in that folder

--i wrote all that for you austin so plz dm me saying thank u
function SoundController:Play(soundSource: number | Sound | string | Folder, extraData : Types.SoundData)
	if not extraData then
		extraData = {} -- for ease
	end

	local soundInstance = GetSoundInstance(soundSource)
	soundInstance.Parent = extraData.Parent or DEFAULT_PARENT
	soundInstance.Volume = extraData.Volume or DEFAULT_VOLUME
	soundInstance.PlaybackSpeed = extraData.PlaybackSpeed or DEFAULT_PLAYBACK_SPEED

	soundInstance:Play()

	soundInstance.Ended:Connect(function()
		soundInstance:Destroy()
	end)

	return soundInstance
end


return SoundController
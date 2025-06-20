--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Data.Types)

local VFXService = Knit.CreateService({ Name = "VFXService", Client = {
    TransmitEffect = Knit.CreateSignal()
}})

function VFXService:KnitInit()

end

function VFXService:KnitStart()

end

function VFXService:DoEffect(vfxType: string, info: Types.VFXInfo)
    self.Client.TransmitEffect:FireAll(vfxType, info)
end

return VFXService
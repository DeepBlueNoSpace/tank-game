local lighting = game:GetService("Lighting")

local config = Instance.new("Configuration")
config.Name = "LightingConfig"
config.Parent = workspace

config:SetAttribute("Ambient", lighting.Ambient)
config:SetAttribute("Brightness", lighting.Brightness)
config:SetAttribute("ColorShift_Bottom", lighting.ColorShift_Bottom)
config:SetAttribute("ColorShift_Top", lighting.ColorShift_Top)
config:SetAttribute("EnvironmentDiffuseScale", lighting.EnvironmentDiffuseScale)
config:SetAttribute("EnvironmentSpecularScale", lighting.EnvironmentSpecularScale)
config:SetAttribute("GlobalShadows", lighting.GlobalShadows)
config:SetAttribute("OutdoorAmbient", lighting.OutdoorAmbient)
config:SetAttribute("ShadowSoftness", lighting.ShadowSoftness)
--config:SetAttribute("Technology", lighting.Technology)
config:SetAttribute("ClockTime", lighting.ClockTime)
config:SetAttribute("GeographicLatitude", lighting.GeographicLatitude)
config:SetAttribute("TimeOfDay", lighting.TimeOfDay)
config:SetAttribute("ExposureCompensation", lighting.ExposureCompensation)

for _, v in pairs(lighting:GetChildren()) do
    v:Clone().Parent = config
end

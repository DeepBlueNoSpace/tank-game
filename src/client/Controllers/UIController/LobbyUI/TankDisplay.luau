local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local TankDisplay = Knit.CreateController { Name = "TankDisplay" }
TankDisplay.CurrentTank = nil

function TankDisplay:SetTank(tank: string)
    if TankDisplay.CurrentTank then
        TankDisplay.CurrentTank:Destroy()
    end

    self.CurrentTank = ReplicatedStorage.Assets.Tanks:FindFirstChild(tank):Clone()    

    if self.CurrentTank:FindFirstChild("Hitbox") then
        for _, part in pairs(self.CurrentTank.Hitbox:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end

    for _, part in pairs(self.CurrentTank:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    
    self.CurrentTank:SetPrimaryPartCFrame(self.TankOrigin.CFrame)
    self.CurrentTank.Parent = self.LobbyScene
end

function TankDisplay:EnableCamera()
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = self.CameraPart.CFrame
end

function TankDisplay:KnitInit()
    self.LobbyScene = workspace:WaitForChild("LobbyScene")
    self.TankOrigin = self.LobbyScene:WaitForChild("TankOrigin")
    self.CameraPart = self.LobbyScene:WaitForChild("CameraPart")
end

function TankDisplay:KnitStart()
    
end


return TankDisplay

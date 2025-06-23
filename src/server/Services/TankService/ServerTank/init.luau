--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local TestConfigs = require(ReplicatedStorage.Shared.TEST_CONFIGS)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local HitboxData = require(ReplicatedStorage.Shared.Data.HitboxData)
local UpgradeTracks = require(ReplicatedStorage.Shared.Data.UpgradeTracks)

local TankPrefabs = Assets.Tanks

local ServerTank = {}
ServerTank.__index = ServerTank

local DESTROY_TIME = 20 

function ServerTank.new(driver: Player, tankType: string, tankUpgrades: {}, spawnCFrame: CFrame) 
    local self = setmetatable({}, ServerTank)

    --Variables
    self.TankService = Knit.GetService("TankService")
    self.DamageService = Knit.GetService("DamageService")
    self.DataService = Knit.GetService("DataService")
    self.VFXService = Knit.GetService("VFXService")

    self.Trove = Trove.new() 

    self.Type = tankType :: string 
    self.Driver = driver :: Player
    self.TankData = TankData[self.Type] :: Types.TankData
    self.Character = driver.Character :: Model
    self.Model = self.Trove:Add(TankPrefabs[tankType]:Clone()) :: Model
    self.Body = self.Model:FindFirstChild("Body") :: Model
    self.Attributes = self:GetAttributes(tankUpgrades) :: Types.TankAttributes
    self.Chassis = self.Model:FindFirstChild("Chassis") :: Model 
    self.FloorPanel = self.Chassis:FindFirstChild("FloorPanel") :: BasePart 

    self.Seat = self.Chassis:FindFirstChild("VehicleSeat") :: VehicleSeat
    self.Constraints = self.Model:FindFirstChild("Constraints") :: Folder 
    
    local hitboxModel = self.Model:FindFirstChild('Hitbox'):: Model
    self.Hitbox = hitboxModel:GetChildren() :: {}

    self.Alive = true :: boolean

    self:WeldWheels()
    self:SetupHitbox()
   
    self.Model.Parent = workspace.Tanks

    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(driver)

    self.Model.Name = driver.Name    
    self.Model:PivotTo(spawnCFrame)
    driver.ReplicationFocus = self.Model.PrimaryPart

    return self
end

local function weldTo(x: BasePart, y: BasePart): Motor6D
	local motor = Instance.new("Motor6D")
	motor.Name = x.Name .. "_Motor"
	motor.Part0 = x
	motor.Part1 = y

	motor.C0 = x.CFrame:ToObjectSpace(y.CFrame)
	motor.C1 = CFrame.new()

	motor.Parent = x
    return motor
end

function ServerTank:WeldWheelSet(wheelSet: Model, namePrefix: string)
    for _, wheel in wheelSet:GetChildren() do 
        local motor = weldTo(self.FloorPanel , wheel)
        motor.Name = string.format("%s%s", namePrefix, tostring(wheel.Name))
        motor.Parent = self.FloorPanel.WheelMotors
    end
end

function ServerTank:WeldWheels()
    self:WeldWheelSet(self.Model.Body.LeftWheels, "L")
    self:WeldWheelSet(self.Model.Body.RightWheels, "R")
end

function ServerTank:SetupHitbox()
    --Make it so it cant collide with itself
    local parts = table.clone(self.Hitbox)
    for i = 1, #parts do
        for j = i + 1, #parts do
            local noc = Instance.new("NoCollisionConstraint")
            noc.Part0 = parts[i]
            noc.Part1 = parts[j]
            noc.Parent = self.Constraints
        end
    end

    local turret = self.Model:FindFirstChild("Turret") :: BasePart
    local rotator = turret:FindFirstChild("Rotator") :: BasePart
    local base = turret:FindFirstChild("Base") :: BasePart

    --Do welds
    for _, instance in self.Hitbox do 
        local basePart = instance :: BasePart
        basePart.Transparency = 1 

        if basePart.Name == "Top" then 
            weldTo(rotator, basePart)
        else
            weldTo(base, basePart)
        end
    end
end

function ServerTank:PullUpgrades(tankUpgrades)
    local attributes = table.clone(self.TankData.BaseAtrributes) :: Types.TankAttributes

    for upgradeName, progress in tankUpgrades do 
        local upgradeTrack = UpgradeTracks[upgradeName]
        if upgradeTrack then -- filter out the wrap upgrade
            if progress > 0 then 
                local effects = upgradeTrack[progress].Effects
                for effectName, value in effects do 
                    attributes[effectName] *= value
                end
            end
        end
    end 

    return attributes
end

--Tank tag is only added once its ready for clients to listen to it
function ServerTank:GetAttributes(tankUpgrades)
    local attributes = self:PullUpgrades(tankUpgrades)
    self.Model:SetAttribute("Health", attributes.Health)
    self.Model:SetAttribute("MaxHealth", attributes.Health)
    self.Model:SetAttribute("OwnerName", self.Driver.Name)

    self.Model:AddTag("Tank")

    return attributes
end

function ServerTank:EndClientPhysics()
    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(nil)
    task.wait()
    primaryPart.AssemblyAngularVelocity = Vector3.zero
    primaryPart.AssemblyLinearVelocity = Vector3.zero
end

function ServerTank:PlayDeathAnimation()
    for _, object in self.Body:GetChildren() do 
        if object:IsA("BasePart") then 
            object.Color = Color3.fromRGB(27,42,53)
            local surfaceAppearence = object:FindFirstChild("SurfaceAppearance")
            if surfaceAppearence then 
                surfaceAppearence:Destroy() -- not ideal
            end
        end
    end

    self.VFXService:DoEffect("TankExplosion", {
        Parent = self.Body.Body,
        SoundSource = ReplicatedStorage.Assets.Sound.TankDestroyed
    })

    for _, object in Assets.VFX.DestroyedTank:GetChildren() do 
        object:Clone().Parent = self.Body.Body
    end
end

function ServerTank:Died()
    --Flow:
    --disabled (so its not alive now) --> wait --> clean
    --Only time disable shouldnt be called first is when the round is over or the player leaves.

    self.TankService.Client.DestroyClientTank:Fire(self.Driver)

    task.wait(DESTROY_TIME) -- a long death is cool
    self:PlayDeathAnimation()

    self.Alive = false
    self.Model:SetAttribute("Alive", false)
    self:EndClientPhysics()


    self:Destroy()
end

function ServerTank:Disable()
    self.TankService.Client.DisableClientTanks:Fire(self.Driver)
end

function ServerTank:Destroy()
    self.TankService:RemovePlayersTankIndex(self.Driver, self)
    self.Trove:Destroy()
end


function ServerTank:TakeDamage(damage: number, sender: Player?, hitbox: string, isDirectHit: boolean)
    if TestConfigs.Is("TANK_DMG") then
        damage = TestConfigs.TANK_DMG
    end

    local hitboxData = HitboxData[hitbox]
    assert(hitboxData, "No hitbox data found for " .. hitbox)

    local adjustedDamage = hitboxData.DamageMultiplier*damage :: number
    local currentHealth = self.Model:GetAttribute("Health") :: number
    local newHealth =  currentHealth - adjustedDamage

    local wasKilled = (self.Alive and newHealth <= 0) :: boolean

    self.DamageService:ReportDamage(sender, self.Driver, adjustedDamage, wasKilled, hitbox, isDirectHit)
    self.Model:SetAttribute("Health", math.max(newHealth, 0))

    if wasKilled then
        self:Died()
    end
end


return ServerTank
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestConfigs = require(ReplicatedStorage.Shared.TEST_CONFIGS)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TankData = require(ReplicatedStorage.Shared.Data.TankData)
local Types = require(ReplicatedStorage.Shared.Data.Types)
local HitboxData = require(ReplicatedStorage.Shared.Data.HitboxData)

local TankPrefabs = ReplicatedStorage.Assets.Tanks

local ServerTank = {}
ServerTank.__index = ServerTank


function ServerTank.new(driver: Player, tankType: string) 
    local self = setmetatable({}, ServerTank)

    --Variables
    self.TankService = Knit.GetService("TankService")
    self.DamageService = Knit.GetService("DamageService")
    
    self.Trove = Trove.new() 

    self.Type = tankType :: string 

    self.TankData = TankData[self.Type] :: Types.TankData
    self.Character = driver.Character :: Model
    self.Model = self.Trove:Add(TankPrefabs[tankType]:Clone()) :: Model
    self.Chassis = self.Model:FindFirstChild("Chassis") :: Model 
    self.Seat = self.Chassis:FindFirstChild("VehicleSeat") :: VehicleSeat
    self.Driver = driver :: Player
    self.Constraints = self.Model:FindFirstChild("Constraints") :: Folder 

    local hitboxModel = self.Model:FindFirstChild('Hitbox'):: Model
    self.Hitbox = hitboxModel:GetChildren() :: {}

    self.Alive = true :: boolean

    self:SetUpAttributes()
    self:SetupHitbox()
   
    self.Model.Parent = workspace:WaitForChild("Tanks")


    --Set up
    local hrp = self.Character:WaitForChild("HumanoidRootPart") :: BasePart
    self.Model.Name = driver.Name
    
    local tankSeat = self.Seat
    local humanoid = self.Character:FindFirstChild("Humanoid") :: Humanoid
    tankSeat:Sit(humanoid)

     self.Trove:Add(humanoid.Died:Connect(function() 
        self:Disable()
    end))

    -- Spawn 5 studs in front of the player
    local spawnCFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
    self.Model:PivotTo(spawnCFrame)

    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(driver)

    return self
end


local function weldTo(x: BasePart, y: BasePart)
	local motor = Instance.new("Motor6D")
	motor.Name = x.Name .. "_Motor"
	motor.Part0 = x
	motor.Part1 = y

	motor.C0 = x.CFrame:ToObjectSpace(y.CFrame)
	motor.C1 = CFrame.new()

	motor.Parent = x
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

    --Do welds
    for _, instance in self.Hitbox do 
        local basePart = instance :: BasePart

        if basePart.Name == "Top" then 
            weldTo(self.Model.Turret.Rotator, basePart)
        else
            weldTo(self.Model.Turret.Base, basePart)
        end
    end
end

--Tank tag is only added once its ready for clients to listen to it
function ServerTank:SetUpAttributes()
    self.Model:SetAttribute("Health", self.TankData.Health)
    self.Model:SetAttribute("MaxHealth", self.TankData.Health)
    self.Model:SetAttribute("OwnerName", self.Driver.Name)

    --Should we break this out to round the ServerTank.new() function?
    self.Model:AddTag("Tank")
end

function ServerTank:EndClientPhysics()
    local primaryPart = self.Model.PrimaryPart :: BasePart
    primaryPart:SetNetworkOwner(nil)
    task.wait()
    primaryPart.AssemblyAngularVelocity = Vector3.zero
    primaryPart.AssemblyLinearVelocity = Vector3.zero
end

function ServerTank:Disable(waitTime: number?)
    --Flow:
    --disabled (so its not alive now) --> wait --> clean
    --Only time disable shouldnt be called first is when the round is over or the player leaves.
    local actualWaitTime = waitTime or 5 :: number

    self.Alive = false
    self.Character:Destroy()
    self.TankService.Client.DestroyClientTank:Fire(self.Driver)

    self:EndClientPhysics()
    
    task.wait(actualWaitTime)
    self.Driver:LoadCharacter()

    task.wait(actualWaitTime*10) -- a long death is cool
    self:Destroy()

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
        self:Disable()
    end
end


return ServerTank
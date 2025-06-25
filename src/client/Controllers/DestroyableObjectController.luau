warn("TODO: delete server DestroyableObjects on map wipe or gonna have memory leak D:")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DestroyableObjectController = Knit.CreateController { Name = "DestroyableObjectController" }
DestroyableObjectController.ServerAssetsInitialized = {} -- [Model] = true
DestroyableObjectController.ClientAssetsInitialized = {} -- [Model] = true
DestroyableObjectController.ServerClientMap = {} -- [Server Model] = [Client Model]
DestroyableObjectController.ClientServerMap = {} -- [Client Model] = [Server Model]

local function mapServerClientModels(serverModel: Model, clientModel: Model)
    DestroyableObjectController.ServerAssetsInitialized[serverModel] = true
    DestroyableObjectController.ClientAssetsInitialized[clientModel] = true
    DestroyableObjectController.ServerClientMap[serverModel] = clientModel
    DestroyableObjectController.ClientServerMap[clientModel] = serverModel

    clientModel.Destroying:Connect(function()
        DestroyableObjectController.ClientAssetsInitialized[clientModel] = nil
        DestroyableObjectController.ClientServerMap[clientModel] = nil
    end)
end

function DestroyableObjectController:InitModel(serverModel: Model)
    if self.ServerAssetsInitialized[serverModel] or self.ClientAssetsInitialized[serverModel] then
        return
    end

    local clone = serverModel:Clone()
    clone:SetPrimaryPartCFrame(serverModel.PrimaryPart.CFrame)
    clone.Parent = serverModel.Parent

    mapServerClientModels(serverModel, clone)

    serverModel:Destroy()

    for i,v in pairs(clone:GetDescendants()) do
        if v:IsA("BasePart") then
            CollectionService:AddTag(v, "DestroyableObjectPart")
            if v == clone.PrimaryPart then
                v.CollisionGroup = "NoTankCollision"
            else
                v.CollisionGroup = "Default"
            end
        end
    end
end

function DestroyableObjectController:ResetModelWithDelay(originalClientModel: Model, delay: number)
    local clientClone = originalClientModel:Clone()
    clientClone:SetPrimaryPartCFrame(originalClientModel.PrimaryPart.CFrame)

    local serverModel = self.ClientServerMap[originalClientModel]

    task.delay(delay, function()
        if not originalClientModel.Parent or not self.ClientAssetsInitialized[originalClientModel] then
            return -- map deleted in intermission?
        end

        self.ClientAssetsInitialized[originalClientModel] = nil
        self.ClientServerMap[clientClone] = nil
        mapServerClientModels(serverModel, clientClone)

        clientClone.Parent = originalClientModel.Parent
        originalClientModel:Destroy()
    end)
end

local FADE_TIME = 2
local FADE_DELAY = 2
local RESET_DELAY = 10

function DestroyableObjectController:KnockOverModel(model: Model, tankOrigin: Vector3)
    if model:GetAttribute("IsKnockedOver") == true then
        return
    end

    DestroyableObjectController:ResetModelWithDelay(model, RESET_DELAY)

    model:SetAttribute("IsKnockedOver", true)

    for i,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CollisionGroup = "NoTankCollision" -- touch ground but not tanks
            v.Anchored = false
            v.CustomPhysicalProperties = PhysicalProperties.new(100, 2, 0.5) -- (Density, Friction, Elasticity)
        end
    end

    -- Apply some force to help the knockover
    if model.PrimaryPart then
        local direction = (model.PrimaryPart.Position - Vector3.new(tankOrigin.X, model.PrimaryPart.Position.Y, tankOrigin.Z)).Unit
        local impulse = direction * model.PrimaryPart.AssemblyMass * 25
        model.PrimaryPart:ApplyImpulseAtPosition(impulse, tankOrigin + Vector3.new(0,20,0))
    end

    task.delay(FADE_DELAY, function()
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                local tween = game:GetService("TweenService"):Create(
                    v,
                    TweenInfo.new(FADE_TIME),
                    { Transparency = 1 }
                )
                tween:Play()
            elseif v:IsA("Decal") or v:IsA("Texture") then
                local tween = game:GetService("TweenService"):Create(
                    v,
                    TweenInfo.new(FADE_TIME),
                    { Transparency = 1 }
                )
                tween:Play()
            end
        end
    end)

    return true
end

function DestroyableObjectController:HandleTankCollision(hitPart: BasePart, tankOrigin: Vector3)
    local model = hitPart.Parent
    while model.Parent and not model:HasTag("DestroyableObject") do
        model = model.Parent
    end

    if not model or not model:HasTag("DestroyableObject") then
        warn("KnockOverModel: No valid model found for hitPart", hitPart)
        return
    end

    local serverModel = self.ClientServerMap[model]

    local succ = self:KnockOverModel(model, tankOrigin)
    if succ then
        self.DestroyableObjectService:RequestReplicateKnockOver(serverModel, tankOrigin)
    end
end

function DestroyableObjectController:KnitInit() 
    self.DestroyableObjectService = Knit.GetService("DestroyableObjectService")
end

function DestroyableObjectController:KnitStart()
    for _, v in pairs(CollectionService:GetTagged("DestroyableObject")) do
        DestroyableObjectController:InitModel(v)
    end

    CollectionService:GetInstanceAddedSignal("DestroyableObject"):Connect(function(model: Model)
        DestroyableObjectController:InitModel(model)
    end)

    -- TODO optimize by checking if this is in viewport or not
    self.DestroyableObjectService.ReplicateKnockOver:Connect(function(serverModel: Model, tankOrigin: Vector3)
        warn("AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
        local clientModel = DestroyableObjectController.ServerClientMap[serverModel]
        if not clientModel then
            warn("DestroyableObjectController:ReplicateKnockOver - No client model found for server model", serverModel)
            return
        end

        self:KnockOverModel(clientModel, tankOrigin)
    end)
end


return DestroyableObjectController

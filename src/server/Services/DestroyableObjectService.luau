-- Trees and other objects that can be knocked over by tanks

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DestroyableObjectService = Knit.CreateService {
    Name = "DestroyableObjectService",
    Client = {
        ReplicateKnockOver = Knit.CreateSignal("ReplicateKnockOver"),
    },

}

function DestroyableObjectService.Client:RequestReplicateKnockOver(player, model: Model, tankOrigin: Vector3)
    warn("DestroyableObjectService.Client:RequestReplicateKnockOver", player, model, tankOrigin)
    if not model or typeof(model) ~= "Instance" or not model:IsA("Model") then
        print("DestroyableObjectService:RequestReplicateKnockOver - Invalid model")
        return
    end

    if typeof(tankOrigin) ~= "Vector3" then
        print("DestroyableObjectService:RequestReplicateKnockOver - Invalid tankOrigin type", typeof(tankOrigin))
        return
    end

    if not model:HasTag("DestroyableObject") then
        print("DestroyableObjectService:RequestReplicateKnockOver - Model does not have 'DestroyableObject' tag")
        return
    end

    if (model.PrimaryPart.Position - tankOrigin).Magnitude > 100 then
        print("DestroyableObjectService:RequestReplicateKnockOver - TankOrigin too far from model")
        return
    end

    local playerTank = DestroyableObjectService.TankService.LiveTanks[player]
    if not playerTank or not playerTank.Model or (playerTank.Model.PrimaryPart.Position - tankOrigin).Magnitude > 100 then
        print("DestroyableObjectService:RequestReplicateKnockOver - Player's tank is too far away or does not exist.")
        return
    end

    if tick() - (model:GetAttribute("LastKnocked") or 0) < 5 then
        print("DestroyableObjectService:RequestReplicateKnockOver - Model was knocked over too recently.")
        return
    end

    model:SetAttribute("LastKnocked", tick())

    DestroyableObjectService.Client.ReplicateKnockOver:FireExcept(player, model, tankOrigin)
end

function DestroyableObjectService:KnitInit()
   self.TankService = Knit.GetService("TankService") 
end


function DestroyableObjectService:KnitStart()
    
end


return DestroyableObjectService

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)


local MunitionData = {} :: {[string]: Types.MunitionData}

MunitionData["Heavy"] = {
    Name = "Heavy",

    BaseDamage = 500;
    BlastRadius = 35;
    RechargeTime = 5;    
}

MunitionData["Heavy"] = {
    Name = "Heavy",

    BaseDamage = 500;
    BlastRadius = 35;
    RechargeTime = 5;    
}


return MunitionData

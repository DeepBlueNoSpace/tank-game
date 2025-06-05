--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)


local MunitionData = {} :: {[string]: Types.MunitionData}

MunitionData["Heavy"] = {
    Name = "Heavy",

    BaseDamage = 500;
    BlastRadius = 50;
    RechargeTime = 5;    
}

MunitionData["Medium"] = {
    Name = "Medium",

    BaseDamage = 300;
    BlastRadius = 20;
    RechargeTime = 3;    
}

MunitionData["Light"] = {
    Name = "Light",

    BaseDamage = 200;
    BlastRadius = 10;
    RechargeTime = 2;   
}


return MunitionData

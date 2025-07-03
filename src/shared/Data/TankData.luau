--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)

local TankData = {} :: {[string]: Types.TankData}

--[[
Health: number,
Torque: number,
Acceleration: number,
MaxSpeed: number,

BlastRadius: number, 
BlastPressure: number,
MuzzleVelocity: number, 

MaxDamage: number,
Cooldown: number,

TurretAngularVelocity: number
]]


TankData["Sdk. Fz. 251"] = {
    Name = "Sdk. Fz. 251",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 4000,

    TankType = "Light", 
    TankCopy = "German half-track carrier.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 300,
        Torque = 150000000, 
        Acceleration = 25,
        MaxSpeed = 55,
        MaxSteer = 2.5, 

        BlastRadius = 0;
        BlastPressure = 0,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 100,
        Cooldown = 0.2,

        TurretAngularVelocity = 100,
    }
} :: Types.TankData


TankData["Type 87"] = {
    Name = "Type 87",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 7500,

    TankType = "Light", 
    TankCopy = "Japanese post-war scout.",

    BaseAtrributes = {
        Health = 1000,
        Torque = 150000000, 
        Acceleration = 15,
        MaxSpeed = 18,
        MaxSteer = 1.5, 

        BlastRadius = 15;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 220,
        Cooldown = 3,

        TurretAngularVelocity = 40,
    }
} :: Types.TankData


TankData["BT-7"] = {
    Name = "BT-7",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 2,

    TankType = "Light", 
    TankCopy = "Soviet speed demon.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 700,
        Torque = 150000000, 
        Acceleration = 10,
        MaxSpeed = 25,
        MaxSteer = 1.5, 

        BlastRadius = 15;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 200,
        Cooldown = 4.5,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["BT-7 L"] = {
    Name = "BT-7 L",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3,

    TankType = "Medium", 
    TankCopy = "Upgunned BT with a bigger bite.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 1400,
        Torque = 150000000, 
        Acceleration = 8,
        MaxSpeed = 18,
        MaxSteer = 1.1, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 350,
        Cooldown = 6,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["T 34-76"] = {
    Name = "T 34-76",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3,

    TankType = "Medium", 
    TankCopy = "The Soviet icon begins.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 2000,
        Torque = 150000000, 
        Acceleration = 7,
        MaxSpeed = 18,
        MaxSteer = 1.1, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 350,
        Cooldown = 7,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["Panzer"] = {
    Name = "Panzer",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1,
 
    TankType = "Medium", 
    TankCopy = "Classic German workhorse.",

    BaseAtrributes = {
        Health = 1200,
        Torque = 150000000, 
        Acceleration = 8,
        MaxSpeed = 25,
        MaxSteer = 1.5, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 400,
        Cooldown = 6.5,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData


TankData["Cromwell"] = {
    Name = "Cromwell",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 4,

    TankType = "Medium", 
    TankCopy = "Fast British cruiser.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 1300,
        Torque = 150000000, 
        Acceleration = 15,
        MaxSpeed = 30,
        MaxSteer = 0.8, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 240,
        Cooldown = 6,

        TurretAngularVelocity = 45,
    }
} :: Types.TankData


TankData["Firefly"] = {
    Name = "Firefly",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 6,

    TankType = "Medium", 
    TankCopy = "British Sherman with punch.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 2500,
        Torque = 150000000, 
        Acceleration = 6,
        MaxSpeed = 18,
        MaxSteer = 1.5, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 350,
        Cooldown = 4.5,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData


TankData["T 34-85"] = {
    Name = "T 34-85",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 7,

    TankType = "Medium", 
    TankCopy = "Refined Soviet classic.",

    BaseAtrributes = {
        SequentialTrackAttachments = true,

        Health = 1900,
        Torque = 150000000, 
        Acceleration = 12,
        MaxSpeed = 22,
        MaxSteer = 1.1, 

        BlastRadius = 19;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 280,
        Cooldown = 4.5,

        TurretAngularVelocity = 34,
    }
} :: Types.TankData




TankData["KV-1"] = {
    Name = "KV-1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5,

    TankType = "Heavy", 
    TankCopy = "Soviet fortress on tracks.",

    BaseAtrributes = {
        Health = 2000,
        Torque = 150000000, 
        Acceleration = 5,
        MaxSpeed = 18,
        MaxSteer = 1.1, 

        BlastRadius = 25;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 220,
        Cooldown = 4.5,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["KV-1 H"] = {
    Name = "KV-1 H",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5,

    TankType = "Heavy", 
    TankCopy = "Ultra heavy variant of KV-1.",

    BaseAtrributes = {
        Health = 2000,
        Torque = 150000000, 
        Acceleration = 3,
        MaxSpeed = 12,
        MaxSteer = 0.8, 

        BlastRadius = 30;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 700,
        Cooldown = 4.5,

        TurretAngularVelocity = 15,
    }
} :: Types.TankData

TankData["Sherman 1"] = {
    Name = "Sherman 1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 1400,
        Torque = 150000000, 
        Acceleration = 10,
        MaxSpeed = 18,
        MaxSteer = 1.1, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 220,
        Cooldown = 4.5,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["Sherman 2"] = {
    Name = "Sherman 2",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 2000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 1600,
        Torque = 150000000, 
        Acceleration = 1.8,
        MaxSpeed = 20,
        MaxSteer = 1.1, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 260,
        Cooldown = 4.2,

        TurretAngularVelocity = 35,
    }
} :: Types.TankData

TankData["Sherman 3"] = {
    Name = "Sherman 3",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 1800,
        Torque = 150000000, 
        Acceleration = 2.1,
        MaxSpeed = 21,
        MaxSteer = 1.3, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 310,
        Cooldown = 3.9,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData

TankData["Sherman 4"] = {
    Name = "Sherman 4",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 4000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 2000,
        Torque = 150000000, 
        Acceleration = 2.4,
        MaxSpeed = 22,
        MaxSteer = 1.3, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 360,
        Cooldown = 3.6,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData

TankData["Sherman 5"] = {
    Name = "Sherman 5",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 2200,
        Torque = 150000000, 
        Acceleration = 2.7,
        MaxSpeed = 23,
        MaxSteer = 1.3, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 410,
        Cooldown = 3.3,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData

TankData["Sherman 6"] = {
    Name = "Sherman 6",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 6000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 2400,
        Torque = 150000000, 
        Acceleration = 3.0,
        MaxSpeed = 24,
        MaxSteer = 1.3, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 460,
        Cooldown = 3.0,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData

TankData["Sherman 7"] = {
    Name = "Sherman 7",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 7000,

    TankType = "Heavy", 
    TankCopy = "this is a panzer",

    BaseAtrributes = {
        Health = 2600,
        Torque = 150000000, 
        Acceleration = 3.3,
        MaxSpeed = 25,
        MaxSteer = 1.3, 

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 600,
        RecoilForce = 15000,

        MaxDamage = 520,
        Cooldown = 2.7,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData


return TankData
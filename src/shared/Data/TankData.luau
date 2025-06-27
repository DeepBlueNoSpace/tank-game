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

--TODO: Add maxturn jfc
TankData["Panzer"] = {
    Name = "Panzer",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1,

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

TankData["BT-7"] = {
    Name = "BT-7",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 2,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 

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

TankData["BT-7 L"] = {
    Name = "BT-7 L",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 
        
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

TankData["T 34-76"] = {
    Name = "T 34-76",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 3,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 

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

TankData["Cromwell"] = {
    Name = "Cromwell",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 4,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 

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

TankData["KV-1 H"] = {
    Name = "KV-1 H",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5,

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

TankData["KV-1"] = {
    Name = "KV-1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 5,

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

TankData["Type 87"] = {
    Name = "Type 87",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 6,

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

TankData["Firefly"] = {
    Name = "Firefly",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 6,

    BaseAtrributes = {        
        SequentialTrackAttachments = true, 

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

TankData["T 34-85"] = {
    Name = "T 34-85",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 7,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 

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

TankData["Sdk. Fz. 251"] = {
    Name = "Sdk. Fz. 251",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 8,

    BaseAtrributes = {
        SequentialTrackAttachments = true, 

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

TankData["Sherman 1"] = {
    Name = "Sherman 1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1000,

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
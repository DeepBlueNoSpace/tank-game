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
TankData["Sherman 1"] = {
    Name = "Sherman 1",
    Image = "rbxassetid://85716504836651",
    CurrencyType = "Cash",
    Cost = 1000,

    BaseAtrributes = {
        Health = 1400,
        Torque = 150000000, 
        Acceleration = 1.5,
        MaxSpeed = 18,

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 20,
        RecoilForce = 15000,

        MaxDamage = 220,
        Cooldown = 4.5,

        TurretAngularVelocity = 30,
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

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 300,
        RecoilForce = 15000,

        MaxDamage = 260,
        Cooldown = 4.2,

        TurretAngularVelocity = 30,
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

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 400,
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

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 500,
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

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 700,
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

        BlastRadius = 20;
        BlastPressure = 300,

        MuzzleVelocity = 800,
        RecoilForce = 15000,

        MaxDamage = 520,
        Cooldown = 2.7,

        TurretAngularVelocity = 30,
    }
} :: Types.TankData


return TankData
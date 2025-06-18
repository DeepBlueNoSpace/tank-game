--!strict
local Types = {}

export type ProjectileData = {
    Origin: Vector3; 
    StartTime: number; 
    Id: string;
    Owner: Player?,
    BarrelEnd: Attachment?,
    MuzzleVelocity: Vector3;
    BlastRadius: number,
}

export type VFXInfo = {
    ScaleSize: number?, -- Times all particles by this flat amount (has no effect on sound)
    Parent: Instance?, --Instead of just putting it in workspace, it will instead parent the items individually under this
    CFrame: CFrame?,
}

export type JoystickThrottle = {
    Z: number, 
    X: number, 
    Braking: boolean
}

export type TankData = {
    Name: string,
    Image: string,
    CurrencyType: string?,
    Cost: number?,
    BaseAtrributes: TankAttributes,

    RequiredLevel: number, 
}

export type UpgradeTrack = {
    [number]: UpgradeData
}

export type UpgradeType = {
    DisplayIcon: string,
    EffectDescription: string,
    HeadlineEffect: string
}

export type UpgradeData = {
    PriceMultiplier: number, 
    Effects: {
        [string]: number
    }
}

export type TankAttributes = { -- damage etc is in MunitionData
    Health: number,
    Torque: number,
    Acceleration: number,
    MaxSpeed: number,

    BlastRadius: number, 
    BlastPressure: number,

    RecoilForce: number,
    MuzzleVelocity: number, 

    MaxDamage: number,
    Cooldown: number,

    TurretAngularVelocity: number
}


export type TankUpgrades = {
    Wrap: string?,
    Armor: number,
    Engine: number,
    Damage: number
}

export type HitboxData = {
    DamageMultiplier: number, 
    Color: Color3
}

export type Trove = {
    Destroy: (...any) -> nil,
    Add: (...any) -> nil
}

return Types 
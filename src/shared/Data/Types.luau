--!strict
local Types = {}

export type ProjectileData = {
    Origin: Vector3; 
    MuzzleVelocity: Vector3;
    StartTime: number; 
    Id: string;
    Owner: Player?,
    BarrelEnd: Attachment?,

    MunitionType: string
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

    Munitions: {[number]: string}
}
export type TankAttributes = { -- damage etc is in MunitionData
    Health: number,
    Torque: number,
    Acceleration: number,
    MaxSpeed: number,
}

export type TankUpgradeData = {
    DisplayName: string,
    CurrencyType: string?,
    Cost: number?,
    RequiredLevel: number?,
    Attributes: TankAttributes?,
    MunitionData: MunitionData,
}
export type MunitionData = {
    Name: string,
    BaseDamage: number,
    BlastRadius: number;
    RechargeTime: number,
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
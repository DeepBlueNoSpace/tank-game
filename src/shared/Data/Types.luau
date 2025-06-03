local Types = {}

export type ProjectileData = {
    Origin: Vector3; 
    MuzzleVelocity: Vector3;
    StartTime: number; 
    Id: string;
    Owner: Player?,
    BarrelEnd: Attachment?,
}

export type VFXInfo = {
    ScaleSize: number?, -- Times all particles by this flat amount (has no effect on sound)
    Parent: Instance?, --Instead of just putting it in workspace, it will instead parent the items individually under this
    CFrame: CFrame?,
}

return Types 
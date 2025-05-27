local Types = {}

export type ProjectileData = {
    Origin: Vector3; 
    MuzzleVelocity: Vector3;
    StartTime: number; 
    Id: string;
    Owner: Player?
}

return Types 
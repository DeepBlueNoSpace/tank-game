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
    MaxDamage: number?
}

export type VFXInfo = {
    ScaleSize: number?, -- Times all particles by this flat amount (has no effect on sound)
    Parent: Instance?, --Instead of just putting it in workspace, it will instead parent the items individually under this
    CFrame: CFrame?,
    SoundSource: Folder? -- a folder with sounds the effect will pull a random sound from
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

    TankType: string, 
    TankCopy: string, 

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
    MaxSteer: number, 

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

export type RewardData = {
    RewardType: string, -- "Currency", ...

    -- Currency RewardType
    CurrencyName: string?, -- If RewardType is "Currency", this is the name of the currency
    Amount: number?, -- If RewardType is "Currency", this is the amount of currency to give
}
export type QuestData = {
    StatName: string, -- The stat that is used to track progress
    StatCountType: string, -- "Total" or "Incremental"; total only looks at raw numbers, incremental looks at the gain since quest started
    StatCount: number, -- The amount of the stat that is required to complete the quest
    Description: string?,
    Reward: RewardData, -- The reward for completing the quest
}

export type EndgamePlayerPackage = {
    PlayerName: string, -- The name of the player, needed for client replication
    Player: Player?,
    Tank: string, -- The last tank player used
    Rank: number, -- The rank of the player in the endgame leaderboard
    IsWinner: boolean, -- Yes/no was player a winner
    Kills: number,
    Team: Team,
}

export type SoundData = {
    Parent: Instance?,
    Volume: number?, 
    PlaybackSpeed:number?
}

return Types 
--[[

    Keeps track of all damage sources and awards kills, assists, killstreaks, etc
    Right now the actual "doing of damage" is handled by the tanks, but it could be abstracted by being moved here

--]]

local KILL_CASH_REWARD = 100
local KILL_XP_REWARD = 100
local ASSIST_REWARD = 20
local ASSIST_XP_REWARD = 20
local ASSIST_WINDOW = 10 -- seconds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--local Signal = require(Knit.Packages.Signal)

local DamageService = Knit.CreateService({ 
    Name = "DamageService",
    Client = {
        Killed = Knit.CreateSignal(), -- tells client to show ui fx
        Assisted = Knit.CreateSignal(), -- tells client to show ui fx
        DidDamage = Knit.CreateSignal(),
        TookDamage = Knit.CreateSignal()
    }
})
DamageService.Log = {}

function DamageService:KnitInit()
	self.TankService = Knit.GetService("TankService")
    self.GameLoopService = Knit.GetService("GameLoopService")
    self.CurrencyService = Knit.GetService("CurrencyService")
    self.XPService = Knit.GetService("XPService")
end

function DamageService:ReportDamage(sender: Player, receiver: Player, damage: number, wasKill: boolean, hitbox: string, directHit: boolean?, hitMarkerLocation: Vector3)
    if sender == receiver then -- dont allow self damage..... for now!
        return
    end

    table.insert(DamageService.Log[receiver], {
        Sender = sender,
        Timestamp = os.time(),
    })

    self.Client.DidDamage:Fire(sender, damage, hitbox, directHit, hitMarkerLocation)
    self.Client.TookDamage:Fire(receiver, sender.Name, damage)
    if wasKill then
        local assists = {}
        for i= #DamageService.Log[receiver], 1, -1 do
            local logEntry = DamageService.Log[receiver][i]
            if logEntry.Timestamp < os.time() - ASSIST_WINDOW then
                break -- stop checking old logs
            end

            if logEntry.Sender ~= sender then -- dont double count kills as assists
                assists[logEntry.Sender] = true
            end
        end

        -- award cash + xp
        self.CurrencyService:IncrementCurrency(sender, "Cash", KILL_CASH_REWARD)
        self.XPService:IncrementXP(sender, KILL_XP_REWARD)
        for assistingPlayer, _ in pairs(assists) do
            self.CurrencyService:IncrementCurrency(assistingPlayer, "Cash", ASSIST_REWARD)
            self.XPService:IncrementXP(sender, ASSIST_XP_REWARD)
        end

        self.Client.Killed:FireAll(sender, receiver, KILL_CASH_REWARD)
        for assistingPlayer, _ in pairs(assists) do
            self.Client.Assisted:Fire(assistingPlayer, assistingPlayer, receiver, ASSIST_REWARD)
        end

        self.Log[receiver] = {}
        self.GameLoopService:ReportKill(sender, receiver) -- respawning etc
        Knit.GetService("StatService"):IncrementStat(sender, "Kills", 1)
        Knit.GetService("StatService"):IncrementStat(receiver, "Deaths", 1)

    end
end

function DamageService:PlayerAdded(player: Player)
    DamageService.Log[player] = {}
end

function DamageService:PlayerRemoving(player: Player)
    DamageService.Log[player] = nil
    
end


return DamageService
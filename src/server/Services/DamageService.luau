--[[

    Keeps track of all damage sources and awards kills, assists, killstreaks, etc
    Right now the actual "doing of damage" is handled by the tanks, but it could be abstracted by being moved here

--]]

local KILL_CASH_REWARD = 100
local ASSIST_REWARD = 20
local ASSIST_WINDOW = 10 -- seconds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--local Signal = require(Knit.Packages.Signal)

local DamageService = Knit.CreateService({ 
    Name = "DamageService",
    Client = {
        Killed = Knit.CreateSignal(), -- tells client to show ui fx
        Assisted = Knit.CreateSignal(), -- tells client to show ui fx
    }
})
DamageService.Log = {}

function DamageService:KnitInit()
	self.TankService = Knit.GetService("TankService")
    self.GameLoopService = Knit.GetService("GameLoopService")
    self.CurrencyService = Knit.GetService("CurrencyService")
end

function DamageService:ReportDamage(sender: Player, receiver: Player, wasKill: boolean)
    warn("DamageService:ReportDamage", sender.Name, "->", receiver.Name, "wasKill:", wasKill)

    table.insert(DamageService.Log[receiver], {
        Sender = sender,
        Timestamp = os.time(),
    })

    if wasKill then
        -- collect assists
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

        -- award cash
        self.CurrencyService:IncrementCurrency(sender, "Cash", KILL_CASH_REWARD)
        for assistingPlayer, _ in pairs(assists) do
            self.CurrencyService:IncrementCurrency(assistingPlayer, "Cash", ASSIST_REWARD)
        end

        -- send UI updates
        self.Client.Killed:FireAll(sender, receiver, KILL_CASH_REWARD)
        for assistingPlayer, _ in pairs(assists) do
            self.Client.Assisted:Fire(assistingPlayer, assistingPlayer, receiver, ASSIST_REWARD)
        end

        self.Log[receiver] = {}
        self.GameLoopService:ReportKill(sender, receiver) -- respawning etc
    end
end

function DamageService:PlayerAdded(player: Player)
    warn("DamageService TODO: VALIDATE PLAYER REMOVING ACTUALLY WORKS SO THERES NO LEAK :D")
    DamageService.Log[player] = {}
end

function DamageService:PlayerRemoving(player: Player)
    warn("WIPING DAMAGE LOG FOR PLAYER", player.Name)
    DamageService.Log[player] = nil
    
end


return DamageService
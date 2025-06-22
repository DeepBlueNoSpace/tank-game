local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Data.Types)
local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalSaveReplica = nil

local GameLoopController = Knit.CreateController { Name = "GameLoopController" }



function GameLoopController:KnitInit()
    self.GameLoopService = Knit.GetService("GameLoopService")

    self.UIController = Knit.GetController("UIController")
    self.GameUI = Knit.GetController("GameUI")
    self.VictoryDefeatPopup = Knit.GetController("VictoryDefeatPopup")
    self.EndgameLeaderboardUI = Knit.GetController("EndgameLeaderboardUI")
    self.KillcamUI = Knit.GetController("KillcamUI")
    self.LobbyMainUI = Knit.GetController("LobbyMainUI")

end


function GameLoopController:KnitStart()
    self.GameLoopService.GameEnding:Connect(function(winners: {Player: boolean}, endgameDataPackage: {Types.EndgamePlayerPackage})
        warn("GameLoopController: Game ending!", winners, endgameDataPackage)
        local localPlayerIsWinner = winners[game.Players.LocalPlayer.Name] == true

        self.GameUI:CloseFrame()
        self.VictoryDefeatPopup:ShowPopup(localPlayerIsWinner)
        self.EndgameLeaderboardUI:PreloadScene(endgameDataPackage)

        task.wait(2)

        self.UIController:AttemptClose(self.VictoryDefeatPopup)
        self.UIController:AttemptOpen(self.EndgameLeaderboardUI)
    end)

    self.GameLoopService.PlayerKilled:Connect(function(killer, victim)
        if victim == game.Players.LocalPlayer then
            self.KillcamUI:OpenFrame(killer)
            task.wait(6)
            self.KillcamUI:CloseFrame()
            self.LobbyMainUI:OpenFrame()
        end
    end)
end


return GameLoopController

local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Execution Blocked", Text = "The Script Is Under Maintenance. We Will Come Back Soon", Duration = 10 })
    end)
    game.Players.LocalPlayer:Kick("Phantom: Bypass Detected. Please use the official Key System.")
    return
end
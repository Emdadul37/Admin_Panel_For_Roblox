local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local targetGui = game:GetService("CoreGui")
pcall(function()
    if not targetGui then
        targetGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomMaintenanceUI"
ScreenGui.Parent = targetGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 90)
Frame.Position = UDim2.new(1, 50, 1, -110) -- স্ক্রিনের বাইরে থেকে শুরু হবে
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Phantom Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Message = Instance.new("TextLabel")
Message.Size = UDim2.new(1, -30, 0, 40)
Message.Position = UDim2.new(0, 15, 0, 40)
Message.BackgroundTransparency = 1
Message.Text = "Script is currently in maintenance. We will be back soon!"
Message.TextColor3 = Color3.fromRGB(200, 200, 200)
Message.TextSize = 14
Message.Font = Enum.Font.Gotham
Message.TextWrapped = true
Message.TextXAlignment = Enum.TextXAlignment.Left
Message.Parent = Frame

local slideIn = TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -340, 1, -110)})
slideIn:Play()

task.wait(5)

local slideOut = TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 1, -110)})
slideOut:Play()

slideOut.Completed:Wait()
ScreenGui:Destroy()
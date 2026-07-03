if not getgenv then getgenv = function() return _G end end
local Phantom_Auth = getgenv().Phantom_Auth
local Phantom_Key = getgenv().Phantom_Key

getgenv().Phantom_Auth    = nil
getgenv().Phantom_Key     = nil
getgenv().Phantom_IsLoading = false

getgenv().Phantom_ScriptReady = true

if Phantom_Auth ~= "Phantom_Secret_Token_9982" then
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "⚠️ Security Alert", Text = "Direct execution blocked! Please use the Key System.", Duration = 10 })
    end)
    game.Players.LocalPlayer:Kick("Phantom: Bypass Detected. Please use the official Key System.")
    return
end

local RestrictedPlaceIds = {
    [99567941238278] = true, [100117331123089] = true, [2753915549] = true,
    [109983668079237] = true, [96342491571673] = true, [83645629621104] = true,
    [136764190843219] = true, [11379739543] = true, [139766023909499] = true,
    [91046261736871] = true, [98502499119821] = true, [18649596490] = true,
    [139576168444589] = true, [104818261591360] = true, [5373028495] = true
}

if RestrictedPlaceIds[game.PlaceId] then
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "⚠️ Execution Blocked", Text = "If You Use This Script In This Game, Your Account Will Be Banned!", Duration = 10 })
    return
end

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService, RunService, TweenService, TeleportService, VirtualUser, HttpService, GuiService, Lighting, MarketplaceService, ReplicatedStorage, TextChatService, PathfindingService = game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("TweenService"), game:GetService("TeleportService"), game:GetService("VirtualUser"), game:GetService("HttpService"), game:GetService("GuiService"), game:GetService("Lighting"), game:GetService("MarketplaceService"), game:GetService("ReplicatedStorage"), game:GetService("TextChatService"), game:GetService("PathfindingService")

local EXECUTION_WEBHOOK = "https://discord.com/api/webhooks/1479119887367540808/021_khOCVhk2fPXuir2p6A_E0TJSUPHasXCHOsshUaA7tUlLkrGte9jy7gnmRMbUvJeJ"
local FEEDBACK_WEBHOOK  = "https://discord.com/api/webhooks/1479120811758587985/D_8dx5VN_Jb5wWC0x3sdH1GTvi6NzMYgBODQFx3XqIrz-FtwM3XAiyqvUAkabEbtCs6I"
local BAN_WEBHOOK       = "https://discord.com/api/webhooks/1480849170553110600/dTSSpXRc3o6J6j7AaGCjsFVifjZywNZBbM0Sj66mJZZJJRh1JLCxnzrTvuhm9B3bdnPn"
local COUNTER_API = "https://api.counterapi.dev/v1/phantom_execute_counter/visits/up"
local function getHttpRequest()
    return (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
end

local FOLDER_NAME = "Phantom"
local POSITIONS_FILE = FOLDER_NAME .. "/Positions.json"

local function getExecutorName()
    if identifyexecutor then return identifyexecutor() elseif getexecutorname then return getexecutorname() elseif syn then return "Synapse X" elseif secure_load then return "Sentinel" elseif is_sirhurt_closure then return "Sirhurt" elseif pebc_execute then return "ProtoSmasher" elseif KRNL_LOADED then return "KRNL" elseif fluxus then return "Fluxus" else return "Unknown Executor" end
end

local function getGlobalExecutionsAsync(onResult)
    task.spawn(function()
        local count = "N/A"
        local success, response = pcall(function() return game:HttpGet(COUNTER_API) end)
        if success and response and response ~= "" then
            local decOk, data = pcall(HttpService.JSONDecode, HttpService, response)
            if decOk and type(data) == "table" then
                count = data.count and tostring(data.count)
                     or (data.value and tostring(data.value))
                     or "N/A"
            end
        end
        if onResult then onResult(count) end
    end)
end

local function getUserExecutionCount()
    local filePath, count = FOLDER_NAME .. "/UserStats.json", 0
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    if isfile(filePath) then pcall(function() count = HttpService:JSONDecode(readfile(filePath)).Executes or 0 end) end
    count = count + 1
    pcall(function() writefile(filePath, HttpService:JSONEncode({["Executes"] = count, ["LastExecute"] = tostring(os.date("%x %X"))})) end)
    return count
end

local function getStoredExecutionCount()
    local filePath, count = FOLDER_NAME .. "/UserStats.json", 0
    if isfile(filePath) then pcall(function() count = HttpService:JSONDecode(readfile(filePath)).Executes or 0 end) end
    return count
end

local function sendWebhook(userCount)
    if not EXECUTION_WEBHOOK or EXECUTION_WEBHOOK == "" then return end
    task.spawn(function()
        local globalCount = "N/A"
        local cOk, cRes = pcall(function() return game:HttpGet(COUNTER_API) end)
        if cOk and cRes and cRes ~= "" then
            local dOk, d = pcall(HttpService.JSONDecode, HttpService, cRes)
            if dOk and type(d) == "table" then
                globalCount = d.count and tostring(d.count)
                           or (d.value and tostring(d.value))
                           or "N/A"
            end
        end

        local GameName = "Unknown Game"
        pcall(function() GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

        local data = { ["content"] = "", ["embeds"] = {{ ["title"] = "🚀 Phantom Ultimate 8.6 Executed!", ["description"] = "A user has successfully executed the script.", ["color"] = 65535, ["fields"] = { {["name"] = "User", ["value"] = Player.Name .. " ("..Player.DisplayName..")", ["inline"] = true}, {["name"] = "🆔 User ID", ["value"] = tostring(Player.UserId), ["inline"] = true}, {["name"] = "💻 Executor", ["value"] = "**" .. getExecutorName() .. "**", ["inline"] = true}, {["name"] = "👤 User Executes", ["value"] = "**" .. tostring(userCount) .. " times**", ["inline"] = true}, {["name"] = "🌍 Total Executes", ["value"] = globalCount, ["inline"] = true}, {["name"] = "🎮 Game Name", ["value"] = GameName, ["inline"] = false}, {["name"] = "🎫 Job ID", ["value"] = "```" .. tostring(game.JobId) .. "```", ["inline"] = false} }, ["footer"] = {["text"] = "Phantom Ultimate 8.6 Logger | " .. os.date("%X")} }} }
        local httpRequest = getHttpRequest()
        if httpRequest then pcall(function() httpRequest({ Url = EXECUTION_WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data) }) end) end
    end)
end

local function sendFeedback(msg)
    if not FEEDBACK_WEBHOOK or FEEDBACK_WEBHOOK == "" then return end
    task.spawn(function()
        local GameName = "Unknown Game"
        pcall(function() GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        local data = { ["content"] = "", ["embeds"] = {{ ["title"] = "💡 Phantom Ultimate 8.6 Feedback / Idea", ["description"] = "A user has submitted feedback.", ["color"] = 16776960, ["fields"] = { {["name"] = "👤 User", ["value"] = Player.Name .. " ("..Player.DisplayName..")", ["inline"] = true}, {["name"] = "💻 Executor", ["value"] = getExecutorName(), ["inline"] = true}, {["name"] = "🔢 User Executes", ["value"] = "**" .. tostring(getStoredExecutionCount()) .. " times**", ["inline"] = true}, {["name"] = "📝 Message", ["value"] = "```" .. msg .. "```", ["inline"] = false}, {["name"] = "🎮 Game Name", ["value"] = GameName, ["inline"] = true}, }, ["footer"] = {["text"] = "Phantom Ultimate 8.6 Feedback System | " .. os.date("%X")} }} }
        local httpRequest = getHttpRequest()
        if httpRequest then pcall(function() httpRequest({ Url = FEEDBACK_WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data) }) end) end
    end)
end

if _G.PhantomBanConn then pcall(function() _G.PhantomBanConn:Disconnect() end); _G.PhantomBanConn = nil end
_G.PhantomBanConn = game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
    if not (msg and msg ~= "" and BAN_WEBHOOK ~= "" and BAN_WEBHOOK ~= "Your_Ban_Discord_Web") then return end
    local GameName = "Unknown Game"
    pcall(function() GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    local P = game.Players.LocalPlayer
    local data = {["content"]="",["embeds"]={{["title"]="🚨 Player Kicked / Disconnected",["description"]="A player has been kicked out of the game.",["color"]=16711680,["fields"]={{["name"]="📛 Display Name",["value"]=P.DisplayName,["inline"]=true},{["name"]="👤 Username",["value"]="@"..P.Name,["inline"]=true},{["name"]="🆔 User ID",["value"]=tostring(P.UserId),["inline"]=true},{["name"]="🎮 Game Name",["value"]=GameName,["inline"]=true},{["name"]="📍 Place ID",["value"]=tostring(game.PlaceId),["inline"]=true},{["name"]="💻 Executor",["value"]=getExecutorName(),["inline"]=true},{["name"]="📝 Reason",["value"]="```\n"..msg.."\n```",["inline"]=false}},["footer"]={["text"]="Phantom Ultimate Logger | "..os.date("%X")}}}}
    local httpRequest = getHttpRequest()
    if httpRequest then pcall(function() httpRequest({Url=BAN_WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode(data)}) end) end
end)

local FILE_NAME, FULL_PATH = "Settings.json", FOLDER_NAME .. "/Settings.json"

if _G.DefaultWalkSpeed == nil then
    _G.DefaultWalkSpeed = 16
    task.spawn(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then _G.DefaultWalkSpeed, _G.DefaultJumpPower = hum.WalkSpeed, hum.JumpPower end
    end)
end
if _G.DefaultJumpPower == nil then _G.DefaultJumpPower = 50 end
if _G.OriginalAmbient == nil then _G.OriginalAmbient, _G.OriginalBrightness, _G.OriginalClockTime, _G.OriginalFogStart, _G.OriginalFogEnd, _G.OriginalMaxZoom, _G.OriginalGravity = Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime, Lighting.FogStart, Lighting.FogEnd, Player.CameraMaxZoomDistance, workspace.Gravity end

local Settings, PositionsData = {}, {}
Settings.MenuKey = "RightControl"
Settings.FlightSpeed, Settings.WalkSpeed, Settings.JumpPower = 3, 16, 50
Settings.CurrentTheme = "Phantom Ultimate 8.6"

local c = Color3.fromRGB
local Themes = {
    ["Phantom Ultimate 8.6"] = { MainBg = c(12,12,16), SidebarBg = c(18,18,24), ContentBg = c(23,23,30), Accent = c(0,220,255), TextPrimary = c(245,245,245), TextSecondary = c(160,160,180), Outline = c(40,40,58), ItemHover = c(32,32,44), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    ["Phantom Ultimate 5.0"] = { MainBg = c(12,12,16), SidebarBg = c(18,18,24), ContentBg = c(23,23,30), Accent = c(0,220,255), TextPrimary = c(245,245,245), TextSecondary = c(160,160,180), Outline = c(40,40,58), ItemHover = c(32,32,44), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Cyan = { MainBg = c(20,20,20), SidebarBg = c(25,25,30), ContentBg = c(32,32,36), Accent = c(0,160,255), TextPrimary = c(245,245,245), TextSecondary = c(180,180,180), Outline = c(50,50,60), ItemHover = c(40,40,50), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Red = { MainBg = c(20,20,20), SidebarBg = c(30,25,25), ContentBg = c(36,32,32), Accent = c(255,60,60), TextPrimary = c(255,245,245), TextSecondary = c(180,150,150), Outline = c(60,50,50), ItemHover = c(50,40,40), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Green = { MainBg = c(20,20,20), SidebarBg = c(25,30,25), ContentBg = c(32,36,32), Accent = c(60,255,100), TextPrimary = c(245,255,245), TextSecondary = c(150,180,150), Outline = c(50,60,50), ItemHover = c(40,50,40), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Purple = { MainBg = c(20,20,20), SidebarBg = c(28,25,30), ContentBg = c(34,32,36), Accent = c(170,0,255), TextPrimary = c(250,245,255), TextSecondary = c(170,160,180), Outline = c(55,50,60), ItemHover = c(45,40,50), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Orange = { MainBg = c(20,20,20), SidebarBg = c(30,28,25), ContentBg = c(36,34,32), Accent = c(255,140,0), TextPrimary = c(255,250,245), TextSecondary = c(180,170,160), Outline = c(60,55,50), ItemHover = c(50,45,40), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Midnight = { MainBg = c(10,10,15), SidebarBg = c(15,15,20), ContentBg = c(20,20,25), Accent = c(100,100,255), TextPrimary = c(200,200,255), TextSecondary = c(120,120,160), Outline = c(30,30,50), ItemHover = c(25,25,40), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Synapse = { MainBg = c(40,40,40), SidebarBg = c(50,50,50), ContentBg = c(45,45,45), Accent = c(255,255,255), TextPrimary = c(255,255,255), TextSecondary = c(200,200,200), Outline = c(70,70,70), ItemHover = c(60,60,60), Red = c(255,75,75), Green = c(75,255,120), Yellow = c(255,200,50) },
    Gold = { MainBg = c(25,25,25), SidebarBg = c(30,30,30), ContentBg = c(35,35,35), Accent = c(255,215,0), TextPrimary = c(255,255,240), TextSecondary = c(189,183,107), Outline = c(70,65,50), ItemHover = c(50,50,40), Red = c(255,80,80), Green = c(80,255,80), Yellow = c(255,215,0) },
    Toxic = { MainBg = c(10,15,10), SidebarBg = c(15,20,15), ContentBg = c(20,25,20), Accent = c(124,252,0), TextPrimary = c(200,255,200), TextSecondary = c(100,150,100), Outline = c(30,50,30), ItemHover = c(25,35,25), Red = c(255,50,50), Green = c(50,255,50), Yellow = c(255,255,50) },
    CottonCandy = { MainBg = c(255,240,245), SidebarBg = c(255,228,225), ContentBg = c(240,248,255), Accent = c(255,105,180), TextPrimary = c(70,70,90), TextSecondary = c(100,100,120), Outline = c(200,200,220), ItemHover = c(230,230,250), Red = c(255,100,100), Green = c(100,200,100), Yellow = c(255,200,100) },
    Ocean = { MainBg = c(10,25,40), SidebarBg = c(15,35,55), ContentBg = c(20,45,70), Accent = c(0,190,255), TextPrimary = c(220,240,255), TextSecondary = c(100,140,170), Outline = c(30,60,90), ItemHover = c(25,55,85), Red = c(255,80,80), Green = c(80,255,150), Yellow = c(255,220,80) },
    Vaporwave = { MainBg = c(20,10,30), SidebarBg = c(30,15,40), ContentBg = c(40,20,50), Accent = c(255,0,255), TextPrimary = c(0,255,255), TextSecondary = c(255,150,255), Outline = c(60,30,80), ItemHover = c(50,25,60), Red = c(255,50,100), Green = c(50,255,150), Yellow = c(255,255,100) },
    Dracula = { MainBg = c(40,42,54), SidebarBg = c(68,71,90), ContentBg = c(56,58,89), Accent = c(255,121,198), TextPrimary = c(248,248,242), TextSecondary = c(98,114,164), Outline = c(98,114,164), ItemHover = c(80,80,100), Red = c(255,85,85), Green = c(80,250,123), Yellow = c(241,250,140) }
}

local function saveSettings() pcall(function() if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end writefile(FULL_PATH, HttpService:JSONEncode(Settings)) end) end
local function loadSettings() pcall(function() if isfile(FULL_PATH) then for k, v in pairs(HttpService:JSONDecode(readfile(FULL_PATH))) do Settings[k] = v end end end) end
local function savePositions() pcall(function() if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end writefile(POSITIONS_FILE, HttpService:JSONEncode(PositionsData)) end) end
local function loadPositions() pcall(function() PositionsData = isfile(POSITIONS_FILE) and HttpService:JSONDecode(readfile(POSITIONS_FILE)) or {} end) end

loadSettings()
loadPositions()
if type(Settings.Keybinds) ~= "table" then Settings.Keybinds = {} end
local _validMenuKeys={RightControl=true,RightShift=true,Insert=true,F1=true,F2=true,F3=true,F4=true}
if not _validMenuKeys[Settings.MenuKey] then Settings.MenuKey="RightControl" end

local Theme = Themes[Settings.CurrentTheme] or Themes["Phantom Ultimate 8.6"]
local GUI_NAME = "Phantom_Ultimate_8.6_Rel_Invisible"
local NotificationLayout

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.ApplyStrokeMode, stroke.Parent = color or Theme.Outline, thickness or 1, Enum.ApplyStrokeMode.Border, parent
    return stroke
end

local function SendNotification(text, color)
    if not NotificationLayout then return end

    local accentCol = color or Theme.Accent

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 0, 0, 34)
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.AnchorPoint = Vector2.new(1, 0)
    pill.Position = UDim2.new(1, -12, 0, 0)
    pill.BackgroundColor3 = Theme.MainBg
    pill.BorderSizePixel = 0
    pill.ClipsDescendants = false
    pill.Parent = NotificationLayout.Parent
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 17)
    AddStroke(pill, accentCol, 1.5)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 13, 0.5, -4)
    dot.BackgroundColor3 = accentCol
    dot.BorderSizePixel = 0
    dot.Parent = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. "  "
    lbl.TextColor3 = Theme.TextPrimary
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = pill

    pill.Position = UDim2.new(1, 250, 0, 0)
    TweenService:Create(pill, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -12, 0, 0)}):Play()

    task.spawn(function()
        task.wait(3.2)
        TweenService:Create(pill, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 250, 0, 0)}):Play()
        task.wait(0.4)
        pill:Destroy()
    end)
end

local GLOBAL_TAGS_API = "https://phantom-chat-c1bec-default-rtdb.firebaseio.com/global_tags"
local CachedTags = {}
local GlobalTagsEnabled = false
local CurrentTagAnimation = "Falling Stars"

local CurrentTagStyle = "Dark Premium"

local function CreatePremiumTag(character, tagText, userName, animType, styleType)
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    local player = game.Players:GetPlayerFromCharacter(character)
    local actualUserName = userName or (player and player.Name) or "Unknown"
    local animToUse = animType or CurrentTagAnimation
    local styleToUse = styleType or CurrentTagStyle

    local existing = head:FindFirstChild("PhantomPremiumTag")
    if existing then
        if existing:GetAttribute("TagText") == tagText and existing:GetAttribute("TagAnim") == animToUse and existing:GetAttribute("TagStyle") == styleToUse then
            return
        end
        existing:Destroy()
    end
    if not tagText or tagText == "" then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PhantomPremiumTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 140, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.8, 0)
    billboard.AlwaysOnTop = true
    billboard:SetAttribute("TagText", tagText)
    billboard:SetAttribute("TagAnim", animToUse)
    billboard:SetAttribute("TagStyle", styleToUse)
    billboard.Parent = head

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = billboard

    local corner = Instance.new("UICorner")
    local stroke = Instance.new("UIStroke")
    local strokeGradient = Instance.new("UIGradient")

    if styleToUse == "Glassmorphism" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        mainFrame.BackgroundTransparency = 0.85
        corner.CornerRadius = UDim.new(0, 8)
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.5
        stroke.Parent = mainFrame
    elseif styleToUse == "Cyberpunk" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        mainFrame.BackgroundTransparency = 0.2
        corner.CornerRadius = UDim.new(0, 0)
        stroke.Thickness = 2
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 60)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    elseif styleToUse == "Crimson Void" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        mainFrame.BackgroundTransparency = 0.3
        corner.CornerRadius = UDim.new(0, 4)
        stroke.Thickness = 1.5
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    elseif styleToUse == "Neon Toxic" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 25, 10)
        mainFrame.BackgroundTransparency = 0.2
        corner.CornerRadius = UDim.new(0, 4)
        stroke.Thickness = 2
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 255, 50)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 255, 0))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    elseif styleToUse == "Royal Gold" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 5)
        mainFrame.BackgroundTransparency = 0.2
        corner.CornerRadius = UDim.new(0, 4)
        stroke.Thickness = 1.5
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 165, 32))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    elseif styleToUse == "Holographic" then
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 40)
        mainFrame.BackgroundTransparency = 0.4
        corner.CornerRadius = UDim.new(0, 8)
        stroke.Thickness = 1.5
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    else
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        mainFrame.BackgroundTransparency = 0.4
        corner.CornerRadius = UDim.new(0, 6)
        stroke.Thickness = 1.5
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 0, 255))
        })
        strokeGradient.Parent = stroke
        stroke.Parent = mainFrame
    end
    corner.Parent = mainFrame

    if animToUse == "Falling Stars" then
        task.spawn(function()
            while billboard.Parent do
                local star = Instance.new("Frame")
                star.Size = UDim2.new(0, 1, 0, math.random(3, 5))
                star.Position = UDim2.new(math.random() * 1, 0, 0, -10)
                star.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
                star.BackgroundTransparency = 0.6
                star.BorderSizePixel = 0
                star.Parent = mainFrame

                local tween = TweenService:Create(star, TweenInfo.new(math.random(2, 4), Enum.EasingStyle.Linear), {
                    Position = UDim2.new(star.Position.X.Scale, 0, 1, 10),
                    BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Connect(function() star:Destroy() end)
                task.wait(math.random(2, 6) / 10)
            end
        end)
    elseif animToUse == "Bubbles" then
        task.spawn(function()
            while billboard.Parent do
                local bubble = Instance.new("Frame")
                local size = math.random(3, 5)
                bubble.Size = UDim2.new(0, size, 0, size)
                bubble.Position = UDim2.new(math.random() * 1, 0, 1, 5)
                bubble.BackgroundTransparency = 0.9
                bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local bStroke = Instance.new("UIStroke", bubble)
                bStroke.Thickness = 0.5
                bStroke.Color = Color3.fromRGB(255, 255, 255)
                bStroke.Transparency = 0.6

                Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
                bubble.Parent = mainFrame

                local endX = bubble.Position.X.Scale + (math.random(-10, 10)/100)
                local tween = TweenService:Create(bubble, TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(endX, 0, 0, -10),
                    BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Connect(function() bubble:Destroy() end)
                task.wait(math.random(3, 8) / 10)
            end
        end)
    elseif animToUse == "Snow" then
        task.spawn(function()
            while billboard.Parent do
                local flake = Instance.new("Frame")
                flake.Size = UDim2.new(0, 2, 0, 2)
                flake.Position = UDim2.new(math.random() * 1, 0, 0, -5)
                flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                flake.BackgroundTransparency = 0.5
                Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
                flake.Parent = mainFrame

                local endX = flake.Position.X.Scale + (math.random(-15, 15) / 100)
                local tween = TweenService:Create(flake, TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Sine), {
                    Position = UDim2.new(endX, 0, 1, 5),
                    BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Connect(function() flake:Destroy() end)
                task.wait(math.random(2, 5) / 10)
            end
        end)
    end

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.55, 0)
    textLabel.Position = UDim2.new(0, 0, 0.05, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = tagText
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextWrapped = true
    textLabel.Parent = mainFrame

    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, 0, 0.35, 0)
    userLabel.Position = UDim2.new(0, 0, 0.65, 0)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "@" .. actualUserName .. " | Phantom"
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextSize = 9
    userLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    userLabel.Parent = mainFrame

    task.spawn(function()
        local rotation = 0
        while billboard.Parent do
            rotation = rotation + 2
            if rotation >= 360 then rotation = 0 end
            strokeGradient.Rotation = rotation
            task.wait(0.02)
        end
    end)
end

local _tabLayoutRegistry = {}

local function createLayout(parent)
    local layout = Instance.new("UIListLayout")
    layout.Parent, layout.SortOrder, layout.Padding, layout.HorizontalAlignment =
        parent, Enum.SortOrder.LayoutOrder, UDim.new(0, 6), Enum.HorizontalAlignment.Center
    if parent:IsA("ScrollingFrame") then
        local function refresh()
            parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 150)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)
        refresh()
        _tabLayoutRegistry[parent] = refresh
    end
    return layout
end

local function createSectionHeader(parent, text)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.96, 0, 0, 24)
    sep.BackgroundTransparency = 1
    sep.Parent = parent

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 0, 0, 20)
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.Position = UDim2.new(0, 0, 0.5, -10)
    pill.BackgroundColor3 = Theme.SidebarBg
    pill.BorderSizePixel = 0
    pill.Parent = sep
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 10)
    AddStroke(pill, Theme.Outline, 1)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 7, 0.5, -2)
    dot.BackgroundColor3 = Theme.Accent
    dot.BorderSizePixel = 0
    dot.Parent = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 17, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. "  "
    lbl.TextColor3 = Theme.TextSecondary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.BorderSizePixel = 0
    lbl.Parent = pill

    local tailLine = Instance.new("Frame")
    tailLine.Size = UDim2.new(1, -120, 0, 1)
    tailLine.Position = UDim2.new(0, 110, 0.5, 0)
    tailLine.BackgroundColor3 = Theme.Outline
    tailLine.BorderSizePixel = 0
    tailLine.Parent = sep

    return sep
end

local _FeatureRegistry = {}
local _KeybindRegistry = {}
local openKeybindPopup
local function _RegFeature(n,d,f) _FeatureRegistry[#_FeatureRegistry+1]={n=n,d=d,f=f} end

local function createToggleSwitch(parent, text, description, callback, externalControl, noSave)
    local toggleObj, isOn = {}, false
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(0.96, 0, 0, 52)
    container.BackgroundColor3 = Theme.ContentBg
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local stroke = AddStroke(container, Theme.Outline, 1)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 2, 0.65, 0)
    accentBar.Position = UDim2.new(0, 0, 0.175, 0)
    accentBar.BackgroundColor3 = Theme.Outline
    accentBar.BorderSizePixel = 0
    accentBar.Parent = container
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.68, 0, 0, 22)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.Parent = container

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.68, 0, 0, 0)
    descLabel.Position = UDim2.new(0, 14, 0, 29)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.Text = description or ""
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.BackgroundTransparency = 1
    descLabel.TextWrapped = true
    descLabel.Parent = container

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 40, 0, 22)
    switchBg.Position = UDim2.new(1, -50, 0.5, -11)
    switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    switchBg.Parent = container
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    AddStroke(switchBg, Color3.fromRGB(70, 70, 85), 1)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
    circle.Parent = switchBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local function updateVisuals()
        TweenService:Create(circle, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 175)
        }):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.22), {BackgroundColor3 = isOn and Theme.Accent or Color3.fromRGB(45, 45, 55)}):Play()
        TweenService:Create(accentBar, TweenInfo.new(0.22), {BackgroundColor3 = isOn and Theme.Accent or Theme.Outline}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.22), {Color = isOn and Theme.Accent or Theme.Outline, Thickness = isOn and 1.5 or 1}):Play()
    end

    container.MouseEnter:Connect(function()
        if not isOn then TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play() end
    end)

    local function resetToggleState()
        TweenService:Create(container, TweenInfo.new(0.1), {Size = UDim2.new(0.96, 0, 0, 52)}):Play()
    end

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(container, TweenInfo.new(0.1), {Size = UDim2.new(0.94, 0, 0, 50)}):Play()
        end
    end)

    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resetToggleState()
        end
    end)

    container.MouseLeave:Connect(function()
        resetToggleState()
        if not isOn then TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ContentBg}):Play() end
    end)

    container.MouseButton1Click:Connect(function()
        isOn = not isOn; updateVisuals(); task.spawn(function() callback(isOn) end)
        if not noSave then Settings[text] = isOn; saveSettings() end
    end)

    function toggleObj:SetState(state)
        if isOn ~= state then
            isOn = state; updateVisuals()
            if not externalControl then task.spawn(function() callback(isOn) end) end
            if not noSave then Settings[text] = isOn; saveSettings() end
        end
    end

    local kbBtn = Instance.new("TextButton")
    kbBtn.Name = "KeybindBtn"
    kbBtn.Size = UDim2.new(0, 24, 0, 24)
    kbBtn.Position = UDim2.new(1, -96, 0.5, -12)
    kbBtn.BackgroundColor3 = Theme.SidebarBg
    kbBtn.Text = "⌨️"
    kbBtn.TextColor3 = Theme.TextSecondary
    kbBtn.Font = Enum.Font.GothamBold
    kbBtn.TextSize = 11
    kbBtn.AutoButtonColor = false
    kbBtn.ZIndex = 2
    kbBtn.Parent = container
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6)
    local kbStroke = AddStroke(kbBtn, Theme.Outline, 1)

    local function _updateKbVisual()
        local kb = Settings.Keybinds and Settings.Keybinds[text]
        if kb and kb.key then
            local display = (kb.ctrl and "^" or "") .. tostring(kb.key)
            kbBtn.Text = display
            kbBtn.TextSize = (#display > 3) and 7 or 9
            TweenService:Create(kbStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
            TweenService:Create(kbBtn, TweenInfo.new(0.15), {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.ContentBg}):Play()
        else
            kbBtn.Text = "⌨️"
            kbBtn.TextSize = 11
            TweenService:Create(kbStroke, TweenInfo.new(0.15), {Color = Theme.Outline}):Play()
            TweenService:Create(kbBtn, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary, BackgroundColor3 = Theme.SidebarBg}):Play()
        end
    end
    _updateKbVisual()

    kbBtn.MouseButton1Click:Connect(function()
        if openKeybindPopup then openKeybindPopup(text, _updateKbVisual, toggleObj) end
    end)
    kbBtn.MouseEnter:Connect(function()
        TweenService:Create(kbBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.ItemHover}):Play()
    end)
    kbBtn.MouseLeave:Connect(function()
        local kb = Settings.Keybinds and Settings.Keybinds[text]
        TweenService:Create(kbBtn, TweenInfo.new(0.12), {BackgroundColor3 = (kb and kb.key) and Theme.ContentBg or Theme.SidebarBg}):Play()
    end)

    function toggleObj:Toggle()
        isOn = not isOn
        updateVisuals()
        task.spawn(function() callback(isOn) end)
        if not noSave then Settings[text] = isOn; saveSettings() end
    end

    function toggleObj:GetState()
        return isOn
    end

    _KeybindRegistry[text] = toggleObj

    if not noSave and Settings[text] ~= nil then isOn = Settings[text]; updateVisuals(); if not externalControl then task.spawn(function() callback(isOn) end) end end
    return toggleObj
end

local function createSlider(parent, text, description, minVal, maxVal, defaultVal, callback, noSave)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 62)
    container.BackgroundColor3 = Theme.ContentBg
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    AddStroke(container, Theme.Outline, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 18)
    label.Position = UDim2.new(0, 14, 0, 7)
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.Parent = container

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 0)
    descLabel.Position = UDim2.new(0, 14, 0, 26)
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.Text = description or ""
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.BackgroundTransparency = 1
    descLabel.TextWrapped = true
    descLabel.Parent = container

    local valueBadge = Instance.new("Frame")
    valueBadge.Size = UDim2.new(0, 44, 0, 18)
    valueBadge.Position = UDim2.new(1, -56, 0, 7)
    valueBadge.BackgroundColor3 = Theme.SidebarBg
    valueBadge.BorderSizePixel = 0
    valueBadge.Parent = container
    Instance.new("UICorner", valueBadge).CornerRadius = UDim.new(0, 9)
    AddStroke(valueBadge, Theme.Accent, 1)

    local valueLabel = Instance.new("TextBox")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.ClearTextOnFocus = false
    valueLabel.Parent = valueBadge

    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(0.88, 0, 0, 4)
    sliderBg.Position = UDim2.new(0.06, 0, 1, -14)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    sliderBg.Text = ""
    sliderBg.AutoButtonColor = false
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    knob.Parent = sliderFill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    AddStroke(knob, Theme.Accent, 1.5)

    local currentVal = (not noSave and Settings[text]) or defaultVal
    local _sliderReady = false

    local function setSlider(val)
        val = math.clamp(tonumber(val) or currentVal, minVal, maxVal)
        local pos = (val - minVal) / (maxVal - minVal)
        TweenService:Create(sliderFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        valueLabel.Text = tostring(val)
        if _sliderReady then
            if noSave then
                callback(val)
            else
                if Settings[text] ~= val then Settings[text] = val; saveSettings(); callback(val) end
            end
        end
        currentVal = val
    end

    valueLabel.FocusLost:Connect(function()
        local num = tonumber(valueLabel.Text)
        if num then
            setSlider(num)
        else
            valueLabel.Text = tostring(currentVal)
        end
    end)

    local draggingSlider = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + ((maxVal - minVal) * pos))
        setSlider(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 18, 0, 18)}):Play()
            updateSlider(input)
        end
    end)
    local sliderConn1 = UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    local sliderConn2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
            TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end
    end)
    container.Destroying:Connect(function()
        if sliderConn1 then sliderConn1:Disconnect(); sliderConn1 = nil end
        if sliderConn2 then sliderConn2:Disconnect(); sliderConn2 = nil end
        draggingSlider = false
    end)

    setSlider(currentVal)
    _sliderReady = true
    if not noSave and Settings[text] ~= nil then task.spawn(function() callback(currentVal) end) end
end

local function createButton(parent, text, description, color, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 52)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Theme.ContentBg
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = AddStroke(btn, Theme.Outline, 1)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 3, 0.5, 0)
    stripe.Position = UDim2.new(0, 0, 0.25, 0)
    stripe.BackgroundColor3 = color or Theme.Accent
    stripe.BorderSizePixel = 0
    stripe.Parent = btn
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(1, 0)

    local mainText = Instance.new("TextLabel")
    mainText.Size = UDim2.new(0.85, 0, 0, 22)
    mainText.Position = UDim2.new(0, 14, 0, 6)
    mainText.BackgroundTransparency = 1
    mainText.Text = text
    mainText.TextColor3 = color or Theme.TextPrimary
    mainText.Font = Enum.Font.GothamBold
    mainText.TextSize = 13
    mainText.TextXAlignment = Enum.TextXAlignment.Left
    mainText.Parent = btn

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.85, 0, 0, 0)
    descLabel.Position = UDim2.new(0, 14, 0, 29)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description or ""
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -22, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = color or Theme.Accent
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 18
    arrow.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = color or Theme.Accent}):Play()
    end)

    local function resetBtnState()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.97, 0, 0.92, 0)}):Play()
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resetBtnState()
        end
    end)

    btn.MouseLeave:Connect(function()
        resetBtnState()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ContentBg}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Theme.Outline}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createTextBox(parent, placeholder, description, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 58)
    container.BackgroundColor3 = Theme.ContentBg
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local stroke = AddStroke(container, Theme.Outline, 1)

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.95, 0, 0, 16)
    descLabel.Position = UDim2.new(0.025, 0, 0, 6)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description or ""
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = container

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(0.94, 0, 0, 26)
    inputBg.Position = UDim2.new(0.03, 0, 0, 25)
    inputBg.BackgroundColor3 = Theme.SidebarBg
    inputBg.BorderSizePixel = 0
    inputBg.Parent = container
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 6)
    AddStroke(inputBg, Theme.Outline, 1)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 1, 0)
    box.Position = UDim2.new(0, 8, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Theme.TextSecondary
    box.TextColor3 = Theme.TextPrimary
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = inputBg

    box.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Theme.Accent, Thickness = 1.5}):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Theme.Outline, Thickness = 1}):Play()
        if callback then callback(box.Text) end
    end)
    return box
end

local function createConfirmation(parent, text, onYes)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 200
    overlay.Parent = parent.Parent.Parent

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 280, 0, 140)
    popup.Position = UDim2.new(0.5, -140, 0.5, -70)
    popup.BackgroundColor3 = Theme.SidebarBg
    popup.ZIndex = 201
    popup.Parent = overlay
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
    AddStroke(popup, Theme.Accent, 1.5)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = Theme.ContentBg
    topBar.ZIndex = 202
    topBar.Parent = popup
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = Theme.ContentBg
    topFix.BorderSizePixel = 0
    topFix.ZIndex = 202
    topFix.Parent = topBar

    local topLbl = Instance.new("TextLabel")
    topLbl.Size = UDim2.new(1, -20, 1, 0)
    topLbl.Position = UDim2.new(0, 14, 0, 0)
    topLbl.BackgroundTransparency = 1
    topLbl.Text = "Confirm Action"
    topLbl.TextColor3 = Theme.Accent
    topLbl.Font = Enum.Font.GothamBold
    topLbl.TextSize = 12
    topLbl.TextXAlignment = Enum.TextXAlignment.Left
    topLbl.ZIndex = 203
    topLbl.Parent = topBar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -28, 0, 0)
    label.Position = UDim2.new(0, 14, 0, 44)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 202
    label.Parent = popup

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 110, 0, 30)
    yesBtn.Position = UDim2.new(0, 14, 1, -40)
    yesBtn.BackgroundColor3 = Theme.Green
    yesBtn.Text = "✓  Confirm"
    yesBtn.TextColor3 = Color3.new(0, 0, 0)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextSize = 11
    yesBtn.ZIndex = 202
    yesBtn.Parent = popup
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 8)

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 110, 0, 30)
    noBtn.Position = UDim2.new(1, -124, 1, -40)
    noBtn.BackgroundColor3 = Theme.ContentBg
    noBtn.Text = "X  Cancel"
    noBtn.TextColor3 = Theme.Red
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextSize = 11
    noBtn.ZIndex = 202
    noBtn.Parent = popup
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 8)
    AddStroke(noBtn, Theme.Red, 1)

    yesBtn.MouseButton1Click:Connect(function() onYes(); overlay:Destroy() end)
    noBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)
end

local oldScript = _G.Phantom_Cleanup
if oldScript then pcall(oldScript) end

local Connections = {}
local function AddConnection(conn) table.insert(Connections, conn); return conn end

local ScreenGui

local _PhHudToggle
local _PhHudFly, _PhHudFlyStroke
local _PhHudNoclip, _PhHudNoclipStroke
local _PhHudSit, _PhHudSitStroke
local _PhHudVFly, _PhHudVFlyStroke
local _PhHudChat, _PhHudChatStroke
local _PhHudDash, _PhHudDashStroke
local _PhHudFreeze, _PhHudFreezeStroke
local _PhMainFrame, _PhBlackScreen

local function Cleanup()
    _G.Phantom_Cleanup = nil
    infoLoopRunning = false
    espLoopRunning  = false
    pcall(function()
        local cam = workspace.CurrentCamera
        cam.CameraSubject, cam.CameraType = Player.Character:FindFirstChild("Humanoid"), Enum.CameraType.Custom
        Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime, Lighting.FogStart, Lighting.FogEnd, workspace.Gravity, Player.CameraMaxZoomDistance = _G.OriginalAmbient or Lighting.Ambient, _G.OriginalBrightness or Lighting.Brightness, _G.OriginalClockTime or Lighting.ClockTime, _G.OriginalFogStart or Lighting.FogStart, _G.OriginalFogEnd or Lighting.FogEnd, _G.OriginalGravity or workspace.Gravity, _G.OriginalMaxZoom or 128
        if Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed, hum.JumpPower, hum.PlatformStand = _G.DefaultWalkSpeed or 16, _G.DefaultJumpPower or 50, false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            local root = Player.Character:FindFirstChild("HumanoidRootPart")
            if root then for _, v in pairs(root:GetChildren()) do if v.Name == "Phantom_BodyGyro" or v.Name == "Phantom_BodyVel" or v.Name == "Phantom_Spin" or v.Name == "Phantom_Fling" then v:Destroy() end end end
            for _, part in ipairs(Player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide, part.Massless, part.CustomPhysicalProperties = true, false, nil end end
        end
    end)
    for _, conn in ipairs(Connections) do if conn and conn.Connected then conn:Disconnect() end end
    table.clear(Connections)
    if PlayerGui:FindFirstChild(GUI_NAME) then PlayerGui[GUI_NAME]:Destroy() end
end
_G.Phantom_Cleanup = Cleanup

local flyEnabled, flySpeed, flyBodyGyro, flyBodyVel, MenuFlySwitch
local vflyEnabled, vflySpeed, vflyBodyGyro, vflyBodyVel, MenuVFlySwitch, vflyInputBegan, vflyInputEnded
local dashPower
local speedEnabled, jumpEnabled, currentSpeed, currentJump
local gravityEnabled, currentGravity
local noclipEnabled, MenuNoclipSwitch, NoclipConnection
local freezeEnabled, MenuFreezeSwitch
local hitboxEnabled, hitboxSize, hitboxTransparency, cachedHitboxSize, hitboxRunning
local flinging, Noclipping
local noFogEnabled, noFogConn
local fullbrightEnabled
local invisRunning, InvisibleCharacter, invisFix, invisDied, realChar
local zoomToggleState, customZoomValue
local selectedPlayer, mimicEnabled, mimicConnection
local combatSelectedPlayer
local spectating
local clickTpEnabled
local isPotatoMode, isSkyRemoved, isTerrainOptimized, originalMaterials, savedLightingItems, originalTerrainProps
local noNpcAnimConn, noShadowsEnabled, shadowsConn, noVfxEnabled, vfxConn
local render3DToggleBtn, afkScreenToggleBtn
local autoReconnectEnabled, antiAfkOn, spinOn, spinVelocity, autoJumpOn
local infoLoopRunning, espLoopRunning
local scriptStartTime
local _infoGeneration = 0
local gameNameLbl, runTimeLbl, playerCountLbl, userIdLbl, globalExecLbl, gameIdLbl, placeIdLbl
local feedbackLabel, feedbackBox, jobIdBox
local selectedPos, refreshPositionList
local defaultMaxZoom
local rainbowCharEnabled, rainbowHue, rainbowConn
local killAuraEnabled, killAuraRange
local loopKillEnabled
local autoClickEnabled
local antiRagdollEnabled, antiRagdollConn
local bunnyHopConn
local wanderEnabled, wanderConn
local followEnabled, followConn
local autoRejoinOnDeath, deathConn
local autoWalkEnabled, autoWalkConn
local soundMuted
local watermarkLabel, watermarkEnabled
local crosshairFrame, crosshairEnabled
local V6S = {
    autoSprintConn=nil, trailEnabled=false, trailConn=nil, trailParts=nil,
    recordingEnabled=false, recordedFrames=nil, replayConn=nil, isReplaying=false,
    glowEnabled=false, glowPart=nil,
    cameraShakeEnabled=false, cameraShakeConn=nil,
    firstPersonLocked=false, firstPersonConn=nil,
    aimlockEnabled=false, aimlockConn=nil,
    orbitEnabled=false, orbitConn=nil,
    autoCollectEnabled=false, autoCollectConn=nil,
    chatLoggerEnabled=false, chatLoggerConn=nil, chatLoggerFrame=nil,
    chatSpamEnabled=false, chatSpamConn=nil, chatSpamMessage="",
    nameSpoofEnabled=false, nameSpoofBillboard=nil,
    minimapEnabled=false, minimapFrame=nil, minimapConn=nil,
    spinCameraEnabled=false, spinCameraConn=nil, autoSprintEnabled=false,
    bodyColorR=255, bodyColorG=255, bodyColorB=255,
    freezeAllEnabled=false,
    playerListOverlayEnabled=false, playerListFrame=nil, playerListConn=nil,
    espColorR=255, espColorG=75, espColorB=75
}
V6S.trailParts = {}
V6S.recordedFrames = {}

local function BuildInterface(isReload)
    _FeatureRegistry = {}
    _KeybindRegistry = {}
    _tabLayoutRegistry = {}
    infoLoopRunning  = true
    _infoGeneration  = _infoGeneration + 1
    scriptStartTime  = scriptStartTime or tick()
    if PlayerGui:FindFirstChild(GUI_NAME) then PlayerGui[GUI_NAME]:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name, ScreenGui.ResetOnSpawn, ScreenGui.IgnoreGuiInset, ScreenGui.Parent = GUI_NAME, false, true, PlayerGui

    defaultMaxZoom = _G.OriginalMaxZoom or Player.CameraMaxZoomDistance

    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size, NotifContainer.Position, NotifContainer.BackgroundTransparency, NotifContainer.ZIndex, NotifContainer.Parent = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0.03, 0), 1, 20000, ScreenGui

    NotificationLayout = Instance.new("UIListLayout")
    NotificationLayout.Parent, NotificationLayout.SortOrder, NotificationLayout.HorizontalAlignment, NotificationLayout.VerticalAlignment, NotificationLayout.Padding = NotifContainer, Enum.SortOrder.LayoutOrder, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top, UDim.new(0, 6)

    _PhHudToggle = Instance.new("TextButton")
    local ToggleBtn = _PhHudToggle
    ToggleBtn.Name = "OpenButton"
    ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
    ToggleBtn.Position = Settings.ToggleBtnPos and UDim2.new(Settings.ToggleBtnPos.X, Settings.ToggleBtnPos.XOff, Settings.ToggleBtnPos.Y, Settings.ToggleBtnPos.YOff) or UDim2.new(0.01, 0, 0.45, 0)
    ToggleBtn.BackgroundColor3 = Theme.MainBg
    ToggleBtn.Text = "◆"
    ToggleBtn.TextColor3 = Theme.Accent
    ToggleBtn.Font = Enum.Font.GothamBlack
    ToggleBtn.TextSize = 22
    ToggleBtn.Draggable = true
    ToggleBtn.Parent = ScreenGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    AddStroke(ToggleBtn, Theme.Accent, 2)

    local function createHudBtn(name, text, size, posSetting, defaultPos)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 48, 0, 48)
        btn.Position = Settings[posSetting] and UDim2.new(Settings[posSetting].X, Settings[posSetting].XOff, Settings[posSetting].Y, Settings[posSetting].YOff) or defaultPos
        btn.BackgroundColor3 = Theme.MainBg
        btn.Text = text
        btn.TextColor3 = Theme.Accent
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = size
        btn.Visible = false
        btn.Draggable = true
        btn.Parent = ScreenGui
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = AddStroke(btn, Theme.Accent, 1.5)
        return btn, stroke
    end

    _PhHudFly, _PhHudFlyStroke = createHudBtn("QuickFlyButton", "FLY", 13, "QuickFlyPos", UDim2.new(0.5, -24, 0.4, 0))
    _PhHudNoclip, _PhHudNoclipStroke = createHudBtn("QuickNoclipButton", "NOCLIP", 11, "QuickNoclipPos", UDim2.new(0.5, -24, 0.5, 0))
    _PhHudSit, _PhHudSitStroke = createHudBtn("QuickSitButton", "SIT", 13, "QuickSitPos", UDim2.new(0.5, -24, 0.6, 0))
    _PhHudVFly, _PhHudVFlyStroke = createHudBtn("QuickVFlyButton", "VFLY", 11, "QuickVFlyPos", UDim2.new(0.5, -24, 0.7, 0))
    _PhHudChat, _PhHudChatStroke = createHudBtn("ChatButton", "CHAT", 11, "QuickChatPos", UDim2.new(0.5, -24, 0.8, 0))
    _PhHudDash, _PhHudDashStroke = createHudBtn("QuickDashButton", "DASH", 11, "QuickDashPos", UDim2.new(0.5, -24, 0.9, 0))
    _PhHudFreeze, _PhHudFreezeStroke = createHudBtn("QuickFreezeButton", "FRZ", 11, "QuickFreezePos", UDim2.new(0.5, -24, 0.3, 0))
    local QuickFlyBtn, QuickFlyStroke = _PhHudFly, _PhHudFlyStroke
    local QuickNoclipBtn, QuickNoclipStroke = _PhHudNoclip, _PhHudNoclipStroke
    local QuickSitBtn, QuickSitStroke = _PhHudSit, _PhHudSitStroke
    local QuickVFlyBtn, QuickVFlyStroke = _PhHudVFly, _PhHudVFlyStroke
    local ChatBtn, ChatBtnStroke = _PhHudChat, _PhHudChatStroke
    local QuickDashBtn, QuickDashStroke = _PhHudDash, _PhHudDashStroke
    local QuickFreezeBtn, QuickFreezeStroke = _PhHudFreeze, _PhHudFreezeStroke
    local function addDragWarningToHUD(btn)
        local holding, dragStartPos = false, nil
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                holding, dragStartPos = true, input.Position
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                holding = false
            end
        end)
        btn.InputChanged:Connect(function(input)
            if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if Settings["🔒 Lock GUI Drag"] == true and dragStartPos then
                    if (input.Position - dragStartPos).Magnitude > 5 then
                        holding = false
                        SendNotification("Disable lock gui first", Theme.Red)
                    end
                end
            end
        end)
    end

    addDragWarningToHUD(ToggleBtn)
    addDragWarningToHUD(QuickFlyBtn)
    addDragWarningToHUD(QuickNoclipBtn)
    addDragWarningToHUD(QuickSitBtn)
    addDragWarningToHUD(QuickVFlyBtn)
    addDragWarningToHUD(ChatBtn)
    addDragWarningToHUD(QuickDashBtn)
    addDragWarningToHUD(QuickFreezeBtn)

    QuickSitBtn.MouseButton1Click:Connect(function() local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid"); if hum then hum.Sit = not hum.Sit end end)

    local function saveBtnPos()
        local function p(b) return {X = b.Position.X.Scale, XOff = b.Position.X.Offset, Y = b.Position.Y.Scale, YOff = b.Position.Y.Offset} end
        Settings.ToggleBtnPos, Settings.QuickFlyPos, Settings.QuickNoclipPos, Settings.QuickSitPos, Settings.QuickVFlyPos, Settings.QuickChatPos, Settings.QuickDashPos, Settings.QuickFreezePos = p(ToggleBtn), p(QuickFlyBtn), p(QuickNoclipBtn), p(QuickSitBtn), p(QuickVFlyBtn), p(ChatBtn), p(QuickDashBtn), p(QuickFreezeBtn)
        saveSettings()
    end
    AddConnection(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then saveBtnPos() end end))

    local BlackScreen = Instance.new("TextButton")
    BlackScreen.Name, BlackScreen.Size, BlackScreen.BackgroundColor3, BlackScreen.ZIndex, BlackScreen.AutoButtonColor, BlackScreen.Text, BlackScreen.Active, BlackScreen.Visible, BlackScreen.Parent = "BlackScreenFrame", UDim2.new(1, 0, 1, 0), Color3.new(0, 0, 0), 10000, false, "", true, false, ScreenGui

    local CloseX = Instance.new("TextButton")
    CloseX.Name, CloseX.Size, CloseX.Position, CloseX.BackgroundColor3, CloseX.Text, CloseX.TextColor3, CloseX.Font, CloseX.TextSize, CloseX.ZIndex, CloseX.Parent = "CloseButton", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 10), Color3.fromRGB(40, 40, 40), "×", Theme.Red, Enum.Font.GothamBold, 18, 10001, BlackScreen
    Instance.new("UICorner", CloseX).CornerRadius = UDim.new(0, 5); AddStroke(CloseX, Theme.Red, 1)

    local mainFrameW = (Settings.MainFrameSize and Settings.MainFrameSize.W) or 560
    local mainFrameH = (Settings.MainFrameSize and Settings.MainFrameSize.H) or 360

    _PhMainFrame = Instance.new("Frame")
    local MainFrame = _PhMainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, mainFrameW, 0, mainFrameH)
    MainFrame.Position = Settings.MainFramePos and UDim2.new(Settings.MainFramePos.X, Settings.MainFramePos.XOff, Settings.MainFramePos.Y, Settings.MainFramePos.YOff) or UDim2.new(0.5, -280, 0.5, -180)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    AddStroke(MainFrame, Theme.Outline, 1.5)

    local HeaderBar = Instance.new("Frame")
    HeaderBar.Name = "HeaderBar"
    HeaderBar.Size = UDim2.new(1, 0, 0, 38)
    HeaderBar.BackgroundColor3 = Theme.SidebarBg
    HeaderBar.BorderSizePixel = 0
    HeaderBar.ZIndex = 2
    HeaderBar.Parent = MainFrame

    Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 12)
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 12)
    headerFix.Position = UDim2.new(0, 0, 1, -12)
    headerFix.BackgroundColor3 = Theme.SidebarBg
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 2
    headerFix.Parent = HeaderBar

    local logoDot = Instance.new("Frame")
    logoDot.Size = UDim2.new(0, 8, 0, 8)
    logoDot.Position = UDim2.new(0, 14, 0.5, -4)
    logoDot.BackgroundColor3 = Theme.Accent
    logoDot.BorderSizePixel = 0
    logoDot.ZIndex = 3
    logoDot.Parent = HeaderBar
    Instance.new("UICorner", logoDot).CornerRadius = UDim.new(1, 0)

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0, 120, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 28, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "PHANTOM"
    HeaderTitle.TextColor3 = Theme.TextPrimary
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = HeaderBar

    local HeaderVersion = Instance.new("TextLabel")
    HeaderVersion.Size = UDim2.new(0, 60, 1, 0)
    HeaderVersion.Position = UDim2.new(0, 105, 0, 0)
    HeaderVersion.BackgroundTransparency = 1
    HeaderVersion.Text = "v8.6"
    HeaderVersion.TextColor3 = Theme.Accent
    HeaderVersion.Font = Enum.Font.GothamBold
    HeaderVersion.TextSize = 10
    HeaderVersion.TextXAlignment = Enum.TextXAlignment.Left
    HeaderVersion.ZIndex = 3
    HeaderVersion.Parent = HeaderBar

    local SearchBoxBg = Instance.new("Frame")
    SearchBoxBg.Size = UDim2.new(0, 180, 0, 24)
    SearchBoxBg.Position = UDim2.new(0.5, -90, 0.5, -12)
    SearchBoxBg.BackgroundColor3 = Theme.ContentBg
    SearchBoxBg.ZIndex = 3
    SearchBoxBg.Parent = HeaderBar
    Instance.new("UICorner", SearchBoxBg).CornerRadius = UDim.new(0, 12)
    local searchStroke = AddStroke(SearchBoxBg, Theme.Outline, 1)

    local sicon = Instance.new("TextLabel", SearchBoxBg)
    sicon.Size = UDim2.new(0, 18, 1, 0)
    sicon.Position = UDim2.new(0, 5, 0, 0)
    sicon.BackgroundTransparency = 1
    sicon.Text = "🔍"
    sicon.TextSize = 10
    sicon.Font = Enum.Font.Gotham
    sicon.TextColor3 = Theme.TextSecondary
    sicon.ZIndex = 4

    local SearchBox = Instance.new("TextBox", SearchBoxBg)
    SearchBox.Size = UDim2.new(1, -26, 1, -2)
    SearchBox.Position = UDim2.new(0, 22, 0, 1)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search features..."
    SearchBox.TextColor3 = Theme.TextPrimary
    SearchBox.PlaceholderColor3 = Theme.TextSecondary
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 11
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 4
    SearchBox.Focused:Connect(function() searchStroke.Color = Theme.Accent; searchStroke.Thickness = 1.5 end)
    SearchBox.FocusLost:Connect(function() searchStroke.Color = Theme.Outline; searchStroke.Thickness = 1 end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -32, 0.5, -11)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.Red
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.ZIndex = 3
    CloseBtn.Parent = HeaderBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
    CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = Theme.Outline
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 2
    headerLine.Parent = HeaderBar

    local dragging, dragInput, dragStart, startPos
    local dragWarningCooldown = false

    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Settings.MainFramePos = {X = MainFrame.Position.X.Scale, XOff = MainFrame.Position.X.Offset, Y = MainFrame.Position.Y.Scale, YOff = MainFrame.Position.Y.Offset}; saveSettings()
    end

    HeaderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    HeaderBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if Settings["🔒 Lock GUI Drag"] == true then
                if not dragWarningCooldown and (input.Position - dragStart).Magnitude > 10 then
                    dragWarningCooldown = true
                    SendNotification("Disable lock gui first", Theme.Red)
                    task.delay(1.5, function() dragWarningCooldown = false end)
                    dragging = false
                end
                return
            end
            updateDrag(input)
        end
    end))

    local MAIN_MIN_W, MAIN_MIN_H = 400, 280
    local MAIN_MAX_W, MAIN_MAX_H = 1100, 800

    local MainResizeBtn = Instance.new("TextButton")
    MainResizeBtn.Name = "ResizeHandle"
    MainResizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MainResizeBtn.AnchorPoint = Vector2.new(1, 1)
    MainResizeBtn.Position = UDim2.new(1, -4, 1, -4)
    MainResizeBtn.BackgroundTransparency = 1
    MainResizeBtn.Text = ""
    MainResizeBtn.ZIndex = 5
    MainResizeBtn.Parent = MainFrame

    local rArrow1 = Instance.new("TextLabel")
    rArrow1.Size = UDim2.new(0, 14, 0, 14)
    rArrow1.Position = UDim2.new(0, 0, 0, 0)
    rArrow1.BackgroundTransparency = 1
    rArrow1.Text = "↖"
    rArrow1.TextColor3 = Theme.TextSecondary
    rArrow1.Font = Enum.Font.GothamBold
    rArrow1.TextSize = 12
    rArrow1.ZIndex = 6
    rArrow1.Parent = MainResizeBtn

    local rArrow2 = Instance.new("TextLabel")
    rArrow2.Size = UDim2.new(0, 14, 0, 14)
    rArrow2.AnchorPoint = Vector2.new(1, 1)
    rArrow2.Position = UDim2.new(1, 0, 1, 0)
    rArrow2.BackgroundTransparency = 1
    rArrow2.Text = "↘"
    rArrow2.TextColor3 = Theme.TextSecondary
    rArrow2.Font = Enum.Font.GothamBold
    rArrow2.TextSize = 12
    rArrow2.ZIndex = 6
    rArrow2.Parent = MainResizeBtn

    MainResizeBtn.MouseEnter:Connect(function()
        rArrow1.TextColor3 = Theme.Accent
        rArrow2.TextColor3 = Theme.Accent
    end)
    MainResizeBtn.MouseLeave:Connect(function()
        rArrow1.TextColor3 = Theme.TextSecondary
        rArrow2.TextColor3 = Theme.TextSecondary
    end)

    local mainResizing = false
    local mainResizeDragStart = nil
    local mainResizeStartSize = nil

    MainResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainResizing = true
            mainResizeDragStart = input.Position
            mainResizeStartSize = MainFrame.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mainResizing = false
                end
            end)
        end
    end)

    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if mainResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainResizeDragStart
            local newW = math.clamp(mainResizeStartSize.X + delta.X, MAIN_MIN_W, MAIN_MAX_W)
            local newH = math.clamp(mainResizeStartSize.Y + delta.Y, MAIN_MIN_H, MAIN_MAX_H)
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
            Settings.MainFrameSize = { W = newW, H = newH }
            saveSettings()
            task.defer(function()
                for frame, refreshFn in pairs(_tabLayoutRegistry) do
                    pcall(refreshFn)
                end
            end)
        end
    end))

    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 62, 1, -39)
    SideBar.Position = UDim2.new(0, 0, 0, 39)
    SideBar.BackgroundColor3 = Theme.SidebarBg
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame

    local sidebarRightLine = Instance.new("Frame")
    sidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarRightLine.Position = UDim2.new(1, -1, 0, 0)
    sidebarRightLine.BackgroundColor3 = Theme.Outline
    sidebarRightLine.BorderSizePixel = 0
    sidebarRightLine.Parent = SideBar

    local TabButtonsContainer = Instance.new("ScrollingFrame")
    TabButtonsContainer.Size = UDim2.new(1, 0, 1, -4)
    TabButtonsContainer.Position = UDim2.new(0, 0, 0, 4)
    TabButtonsContainer.BackgroundTransparency = 1
    TabButtonsContainer.ScrollBarThickness = 0
    TabButtonsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonsContainer.Parent = SideBar
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabButtonsContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 3)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -63, 1, -39)
    ContentArea.Position = UDim2.new(0, 63, 0, 39)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingTop = UDim.new(0, 12)
    ContentPad.PaddingBottom = UDim.new(0, 12)
    ContentPad.PaddingLeft = UDim.new(0, 12)
    ContentPad.PaddingRight = UDim.new(0, 12)
    ContentPad.Parent = ContentArea

    local _tabContentParent = ContentArea

    local Frames = {}
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Frame"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Theme.Accent
        page.Parent = _tabContentParent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        createLayout(page)
        Frames[name] = page
        return page
    end

    local DiscordFrame, MovementFrame, VisualsFrame, ESPFrame, PlayersFrame, CombatFrame, PositionsFrame, AFKFrame, ServerFrame, ChangelogFrame, InfoFrame, SettingsFrame, OptimizeFrame, TagsFrame = CreatePage("Discord"), CreatePage("Movement"), CreatePage("Visuals"), CreatePage("ESP"), CreatePage("Players"), CreatePage("Combat"), CreatePage("Positions"), CreatePage("AFK"), CreatePage("Server"), CreatePage("Changelog"), CreatePage("Info"), CreatePage("Settings"), CreatePage("Optimize"), CreatePage("Tags")
    local AIFrame = CreatePage("AI")

    local currentTab = nil
    local _tabTransitioning = false
    local _pendingTabBtn, _pendingTabFrame = nil, nil

    local function _applyTabButtonVisuals(activeBtn)
        for _, child in pairs(TabButtonsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1}):Play()
                local ic = child:FindFirstChild("Icon"); if ic then TweenService:Create(ic, TweenInfo.new(0.18), {TextColor3 = Theme.TextSecondary}):Play() end
                local lb = child:FindFirstChild("Lbl"); if lb then TweenService:Create(lb, TweenInfo.new(0.18), {TextColor3 = Theme.TextSecondary}):Play() end
                local bar = child:FindFirstChild("Bar"); if bar then TweenService:Create(bar, TweenInfo.new(0.18), {Size = UDim2.new(0, 2, 0.55, 0), BackgroundTransparency = 1}):Play() end
            end
        end
        TweenService:Create(activeBtn, TweenInfo.new(0.18), {BackgroundColor3 = Theme.ContentBg, BackgroundTransparency = 0}):Play()
        local ic = activeBtn:FindFirstChild("Icon"); if ic then TweenService:Create(ic, TweenInfo.new(0.18), {TextColor3 = Theme.Accent}):Play() end
        local lb = activeBtn:FindFirstChild("Lbl"); if lb then TweenService:Create(lb, TweenInfo.new(0.18), {TextColor3 = Theme.Accent}):Play() end
        local bar = activeBtn:FindFirstChild("Bar"); if bar then TweenService:Create(bar, TweenInfo.new(0.18), {Size = UDim2.new(0, 2, 0.55, 0), BackgroundTransparency = 0}):Play() end
        currentTab = activeBtn
    end

    local function SwitchTab(btn, frame)
        if currentTab == btn then return end
        _applyTabButtonVisuals(btn)

        for _, f in pairs(Frames) do
            if f == frame then
                f.Visible = true
                f.Position = UDim2.new(0, 0, 0, 40)
                TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

                task.defer(function()
                    local refreshFn = _tabLayoutRegistry[f]
                    if refreshFn then pcall(refreshFn) end
                end)
            else
                f.Visible = false
            end
        end
    end

    local function CreateTabButton(iconText, labelText, frame)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 54, 0, 46)
        btn.BackgroundColor3 = Theme.SidebarBg
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = TabButtonsContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local bar = Instance.new("Frame")
        bar.Name = "Bar"
        bar.Size = UDim2.new(0, 2, 0.55, 0)
        bar.Position = UDim2.new(0, 0, 0.225, 0)
        bar.BackgroundColor3 = Theme.Accent
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel = 0
        bar.Parent = btn
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(1, 0, 0, 22)
        icon.Position = UDim2.new(0, 0, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Text = iconText
        icon.TextColor3 = Theme.TextSecondary
        icon.Font = Enum.Font.Gotham
        icon.TextSize = 16
        icon.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Lbl"
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.Position = UDim2.new(0, 0, 0, 28)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Theme.TextSecondary
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 7
        lbl.Parent = btn

        btn.MouseEnter:Connect(function()
            if btn ~= currentTab then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover, BackgroundTransparency = 0}):Play() end
        end)
        btn.MouseLeave:Connect(function()
            if btn ~= currentTab then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SidebarBg, BackgroundTransparency = 1}):Play() end
        end)
        btn.MouseButton1Click:Connect(function() SwitchTab(btn, frame) end)
        return btn
    end

    local Tab1      = CreateTabButton("🏠", "HOME",     ChangelogFrame)
    local Tab2      = CreateTabButton("🏃", "MOVE",     MovementFrame)
    local Tab3      = CreateTabButton("👁️", "VISUAL",      VisualsFrame)
    local TabESP    = CreateTabButton("🎯", "ESP",       ESPFrame)
    local TabPVP    = CreateTabButton("⚔️", "PVP",      CombatFrame)
    local Tab4      = CreateTabButton("👥", "PLAYER",     PlayersFrame)
    local TabTags   = CreateTabButton("🏷️", "TAGS",     TagsFrame)
    local Tab9      = CreateTabButton("📍", "POSITION",      PositionsFrame)
    local Tab5      = CreateTabButton("💤", "AFK",      AFKFrame)
    local Tab6      = CreateTabButton("🌐", "SERVER",     ServerFrame)
    local TabOpt    = CreateTabButton("⚡", "OPTIMIZE",      OptimizeFrame)
    local Tab8      = CreateTabButton("⚙️", "SETTING",      SettingsFrame)
    local Tab7      = CreateTabButton("ℹ️", "INFO",     InfoFrame)
    local TabAI     = CreateTabButton("🤖", "AI",       AIFrame)
    local TabDiscord = Tab1
    SwitchTab(Tab1, ChangelogFrame)

    local FrameToTabBtn = {
        [DiscordFrame]   = Tab1,
        [ChangelogFrame] = Tab1,
        [MovementFrame]  = Tab2,
        [VisualsFrame]   = Tab3,
        [ESPFrame]       = TabESP,
        [CombatFrame]    = TabPVP,
        [PlayersFrame]   = Tab4,
        [TagsFrame]      = TabTags,
        [PositionsFrame] = Tab9,
        [AFKFrame]       = Tab5,
        [ServerFrame]    = Tab6,
        [InfoFrame]      = Tab7,
        [SettingsFrame]  = Tab8,
        [OptimizeFrame]  = TabOpt,
        [AIFrame]        = TabAI,
    }

    local preSearchTab, preSearchFrame = Tab1, ChangelogFrame

    local SearchResultsFrame = CreatePage("SearchResults")
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()

        if query == "" then
            SearchResultsFrame.Visible = false
            for _, ch in pairs(TabButtonsContainer:GetChildren()) do
                if ch:IsA("TextButton") then ch.Visible = true end
            end
            SwitchTab(preSearchTab, preSearchFrame)
            return
        end

        if SearchResultsFrame.Visible == false then
            preSearchTab = currentTab or Tab1
            for _, fr in pairs(Frames) do
                if fr.Visible and fr ~= SearchResultsFrame then
                    preSearchFrame = fr; break
                end
            end
        end

        for _, fr in pairs(Frames) do fr.Visible = false end
        SearchResultsFrame.Visible = true
        for _, ch in pairs(TabButtonsContainer:GetChildren()) do
            if ch:IsA("TextButton") then ch.Visible = false end
        end

        for _, c in pairs(SearchResultsFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end

        local headerLbl = Instance.new("TextLabel")
        headerLbl.Size = UDim2.new(0.96, 0, 0, 28)
        headerLbl.BackgroundTransparency = 1
        headerLbl.Text = '🔍  "' .. SearchBox.Text .. '"'
        headerLbl.TextColor3 = Theme.TextSecondary
        headerLbl.Font = Enum.Font.GothamMedium
        headerLbl.TextSize = 11
        headerLbl.TextXAlignment = Enum.TextXAlignment.Left
        headerLbl.Parent = SearchResultsFrame

        local rcount = 0
        for _, feat in ipairs(_FeatureRegistry) do
            if (feat.n .. " " .. feat.d):lower():find(query, 1, true) then
                rcount = rcount + 1
                local capFeat = feat
                local capFrame = feat.f

                local rawName = (capFrame and capFrame.Name or "?"):gsub("Frame", "")
                local tabLabelMap = {
                    Discord="🏠",Changelog="🏠",Movement="🏃",Visuals="👁️",
                    ESP="🎯",Combat="⚔️",Players="👥",Tags="🏷️",Positions="📍",
                    AFK="💤",Server="🌐",Info="ℹ️",Settings="⚙️",Optimize="⚡"
                }
                local tabDisplayName = (tabLabelMap[rawName] or "") .. " " .. rawName

                local row = Instance.new("TextButton")
                row.Size = UDim2.new(0.96, 0, 0, 62)
                row.BackgroundColor3 = Theme.ContentBg
                row.Text = ""; row.AutoButtonColor = false
                row.Parent = SearchResultsFrame
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
                local rowStroke = AddStroke(row, Theme.Outline, 1)

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, -90, 0, 22)
                nameLbl.Position = UDim2.new(0, 10, 0, 8)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = feat.n
                nameLbl.TextColor3 = Theme.TextPrimary
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 13
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextWrapped = true
                nameLbl.Parent = row

                local descLbl2 = Instance.new("TextLabel")
                descLbl2.Size = UDim2.new(1, -90, 0, 18)
                descLbl2.Position = UDim2.new(0, 10, 0, 33)
                descLbl2.BackgroundTransparency = 1
                descLbl2.Text = feat.d
                descLbl2.TextColor3 = Theme.TextSecondary
                descLbl2.Font = Enum.Font.Gotham
                descLbl2.TextSize = 11
                descLbl2.TextXAlignment = Enum.TextXAlignment.Left
                descLbl2.TextWrapped = true
                descLbl2.Parent = row

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 74, 0, 20)
                badge.Position = UDim2.new(1, -80, 0, 8)
                badge.BackgroundColor3 = Theme.SidebarBg
                badge.Text = tabDisplayName
                badge.TextColor3 = Theme.Accent
                badge.Font = Enum.Font.GothamBold
                badge.TextSize = 9
                badge.TextTruncate = Enum.TextTruncate.AtEnd
                badge.Parent = row
                Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
                AddStroke(badge, Theme.Accent, 1)

                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.new(0, 20, 0, 20)
                arrow.Position = UDim2.new(1, -26, 1, -28)
                arrow.BackgroundTransparency = 1
                arrow.Text = "→"
                arrow.TextColor3 = Theme.Accent
                arrow.Font = Enum.Font.GothamBold
                arrow.TextSize = 14
                arrow.Parent = row

                row.MouseEnter:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play()
                    TweenService:Create(rowStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
                end)
                row.MouseLeave:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ContentBg}):Play()
                    TweenService:Create(rowStroke, TweenInfo.new(0.15), {Color = Theme.Outline}):Play()
                end)

                row.MouseButton1Click:Connect(function()
                    local tabBtn = FrameToTabBtn[capFrame]
                    if tabBtn then preSearchTab = tabBtn end
                    if capFrame then preSearchFrame = capFrame end
                    SearchBox.Text = ""
                    task.spawn(function()
                        if not capFrame then return end

                        local layout = capFrame:FindFirstChildOfClass("UIListLayout")
                        if layout then
                            local deadline = tick() + 2
                            while layout.AbsoluteContentSize.Y == 0 and tick() < deadline do
                                task.wait()
                            end
                        end
                        task.wait()

                        for _, child in ipairs(capFrame:GetChildren()) do
                            if child:IsA("Frame") or child:IsA("TextButton") then
                                local found = false
                                for _, lbl in ipairs(child:GetDescendants()) do
                                    if lbl:IsA("TextLabel") and lbl.Text == capFeat.n then
                                        found = true; break
                                    end
                                end
                                if found then
                                    local relY = child.AbsolutePosition.Y - capFrame.AbsolutePosition.Y + capFrame.CanvasPosition.Y
                                    capFrame.CanvasPosition = Vector2.new(0, math.max(0, relY - 10))
                                    local origBg = child.BackgroundColor3
                                    TweenService:Create(child, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Accent}):Play()
                                    task.wait(0.4)
                                    TweenService:Create(child, TweenInfo.new(0.35), {BackgroundColor3 = origBg}):Play()
                                    break
                                end
                            end
                        end
                    end)
                end)
            end
        end

        if rcount == 0 then
            local noR = Instance.new("TextLabel")
            noR.Size = UDim2.new(0.96, 0, 0, 50)
            noR.BackgroundTransparency = 1
            noR.Text = '😕  No results for "' .. SearchBox.Text .. '"'
            noR.TextColor3 = Theme.TextSecondary
            noR.Font = Enum.Font.GothamMedium
            noR.TextSize = 13
            noR.Parent = SearchResultsFrame
        end

        SearchResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 28 + rcount * 68 + 20)
    end)

    local CL_VERSIONS = {
        {v="8.6", tagline="Silent Fling & Zoom Persistence Fix", changes={
            {"👻","Silent Fling — Flings nearby players with no visible spin — rotation resets client-side after each pulse"},
            {"🔭","Custom Zoom Persistence — Zoom toggle now saves and restores state automatically on re-execution"},
        }},
        {v="8.6", tagline="Server Hopping & Visual Shaders", changes={
            {"🔥","Server Hop (High Pop) — Join a server that is almost full"},
            {"📶","Server Hop (Low Ping) — Join a server with the lowest ping available"},
            {"🌐","Server Browser — Find and join a specific public server"},
            {"🎲","Server Hop (Random) — Join a completely random active server"},
            {"🌈","Shader Presets — 17 presets: Realistic, Night, Horror, Cyberpunk, Anime, B&W, Cinematic, Dreamy, HDR, Warm, Sunset, Misty, Retro, Underwater"},
            {"✅","Apply Shader — Instantly apply selected shader with glitch protection"},
            {"↩️","Reset Shader — One-click to restore original lighting"},
            {"🕰️","Server Hop (Oldest) — Find & join the oldest running server"},
        }},
        {v="8.0", tagline="New Features & Performance Boost", changes={
            {"🧗","Fast Ladder — Climb ladders at high speed"},
            {"🏎️","Vehicle Speed — Control vehicle speed multiplier"},
            {"🛡️","Anti-Stun — Prevent stun effects on your character"},
            {"🌀","Desync — Toggle desync mode"},
            {"🩸","Damage Indicator — Visual hit damage numbers"},
            {"▶️","No Gameplay Pause Teleport — Teleport without pausing gameplay"},
            {"🔧","Bug Fixes — Various bugs, feature conflicts and stability fixes"},
        }},
        {v="7.5", tagline="Mini Update — Security & QoL", changes={
            {"🛡️","Secure Anti-Ban — Advanced server-side hook protection on execution"},
            {"✨","Premium Transitions — Smooth slide-up animations when switching tabs"},
            {"⌨️","Custom Keybinds — Assign any key to toggle features in Settings"},
            {"🔢","Typable Sliders — Click and type your exact custom number"},
        }},
        {v="7.0", tagline="26 Brand-New Features", changes={
            {"⚔️","Auto Heal — Continuously restores your health every heartbeat"},
            {"⚔️","God Mode — Sets health to infinite so you cannot die"},
            {"⚔️","Kill All NPCs — Instantly kills every NPC humanoid in workspace"},
            {"⚔️","Auto Leave — Automatically disconnects if health drops low"},
            {"⚔️","Visualize Hitbox — Highlights the physical bounds of targets"},
            {"🏃","Coordinate TP — Paste copied coordinates to teleport directly"},
            {"🏃","Item Magnet — Pulls nearby loose tools toward you"},
            {"🏃","Skywalk — Creates a glass platform under your feet"},
            {"🏃","Anti-Void — Saves you from falling off the map"},
            {"🏃","Btools (Local) — Classic building tools to modify the map"},
            {"🏃","Click Delete Tool — Delete any clicked part"},
            {"🏃","No Sit — Prevents your character from being forced into seats"},
            {"👁️","Flashlight Mode — Camera-mounted SpotLight for dark areas"},
            {"👁️","Disco Mode — Fast rainbow party color cycling on character"},
            {"👁️","Hide Accessories — Makes all worn accessories invisible"},
            {"👁️","X-Ray Vision — Makes map parts semi-transparent"},
            {"👁️","Remove Screen Effects — Disables blinding screen GUIs"},
            {"👁️","Ping Overlay — Displays your live server ping on screen"},
            {"👁️","Day/Night Loop — Constantly cycles the game time"},
            {"👁️","Item/Tool ESP — Highlights all loose tools in the world"},
            {"⚡","BlockMesh World — Forces everything into block shapes for max FPS"},
            {"⚡","Delete Far Away Parts — Remove distant unanchored parts"},
            {"⚡","LOD Mode — Hide parts 300+ studs away to boost FPS"},
            {"👥","Fake Sys Message — Creates a spoofed server message in chat"},
            {"⚙️","Rainbow UI Accent — Cycles the UI accent color live"},
        }},
        {v="6.0", tagline="27 Brand-New Features", changes={
            {"🏃","Movement Recorder — Record & replay your movement path"},
            {"🏃","Auto Collect Parts — Auto-touch nearby parts and tools"},
            {"🏃","Jump Pad — Launch yourself upwards on demand"},
            {"🏃","Auto Sprint — Automatically sprint at all times"},
            {"🏃","Teleport to Spawn — Return to your spawn point instantly"},
            {"👁️","Player Trail — Colorful trail that follows your character"},
            {"👁️","Character Glow — Add a glowing point light to your character"},
            {"👁️","Camera Shake — Adds a screen shake effect"},
            {"👁️","First Person Lock — Lock camera to first-person perspective"},
            {"👁️","Name Spoof — Change your local display name"},
            {"👁️","Minimap Radar — On-screen radar showing nearby players"},
            {"👁️","Animation Changer — Play any animation ID locally"},
            {"👁️","Body Color Changer — Change your character body color"},
            {"👁️","Spin Camera — Rotate the camera continuously"},
            {"👁️","Player List Overlay — Compact on-screen player list"},
            {"👁️","ESP Color Picker — Choose a custom ESP color"},
            {"⚔️","Aimlock — Lock your camera onto a target player"},
            {"⚔️","Teleport Behind Player — Silently TP behind your target"},
            {"⚔️","Freeze All Players (Client) — Freeze all remote characters locally"},
            {"👥","Orbit Player — Orbit around your selected target"},
            {"👥","Chat Logger — Log and display nearby player chat"},
            {"👥","Chat Spam — Send a repeated message in chat"},
            {"💤","Anti-AFK (Virtual Input) — Real mouse input simulation"},
            {"⚙️","Custom Notification — Send yourself a custom toast message"},
            {"⚡","Sound Volume Control — Adjust global sound volume"},
        }},
        {v="5.0", tagline="25 Brand-New Features", changes={
            {"🏃","Bunny Hop — Auto-jump on landing"},
            {"🏃","Swim Speed — Control your swimming speed"},
            {"🏃","Ragdoll Mode — Toggle ragdoll physics on/off"},
            {"🏃","Gravity Control — Moon Gravity & Reset Gravity instantly"},
            {"👁️","Rainbow Character — Live color cycle for your avatar"},
            {"👁️","Headless Mode — Invisible head that persists on respawn"},
            {"👁️","Time of Day — Control the in-game clock slider"},
            {"👁️","Ambient Darkness — Full lighting control"},
            {"⚔️","Kill Aura — Auto fling players in range"},
            {"⚔️","Loop Kill — Continuous fling on a selected target"},
            {"⚔️","Auto Clicker — Rapid tool activation"},
            {"⚔️","Anti-Ragdoll — Block ragdoll state"},
            {"⚔️","Reach Extender — Extend your tool's hit range"},
            {"👥","Follow Player — Track and follow a selected player automatically"},
            {"👥","View Profile — Easily copy any player's Roblox URL"},
            {"👥","Get Player Info — Instantly grab Name / ID / Team info"},
            {"💤","Auto Walk — Keep your character active"},
            {"💤","Auto Rejoin on Death — Automatically rejoin the server if you die"},
            {"💤","Wander Bot — Random walk bot to prevent AFK kicks"},
            {"⚙️","FPS Watermark — Live FPS counter overlay"},
            {"⚙️","Custom Crosshair — Precision overlay for better aim"},
            {"⚡","Mute All Sounds — Silence the game for better performance"},
            {"⚡","Remove NPC Accessories — Strip accessories from NPCs"},
            {"⚡","Simplify Player Models — Remove accessories from all players"},
            {"⚡","Remove All Decals — Strip textures from parts to boost FPS"},
        }},
        {v="4.5", tagline="Move Tab Addition", changes={
            {"🎮","Jerk Off Tool — Added at the very bottom of Move Tab"},
        }},
        {v="4.4", tagline="Tag System", changes={
            {"🏷️","Tag System in Player Tab — Type and make a tag on top of your head that other Phantom users will see"},
        }},
        {v="4.3", tagline="Outfit & Freeze Update", changes={
            {"👗","Copy Outfit — Copy other player's outfit visually"},
            {"❄️","Freeze Position — Freeze your character anywhere + Quick Freeze button"},
        }},
        {v="4.2", tagline="Dash Movement", changes={
            {"💨","Dash — Instantly launches you forward"},
        }},
        {v="4.1", tagline="Chat & Bug Fixes", changes={
            {"💬","Real-Time Chat — Communicate with other users in real-time through the script"},
            {"🛠️","3 Major Bug Fixes — Optimized performance, smoother and more stable gameplay"},
        }},
    }

    local _clCurrentV   = CL_VERSIONS[1]
    local _clDynRows    = {}
    local _clSepLbl     = nil
    local _clBadgeLbl   = nil
    local _clHeroSub    = nil
    local _clDropdown   = nil
    local _clDropOpen   = false

    local function _addCLRow(icon, text)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(0.96, 0, 0, 34)
        row.BackgroundColor3 = Theme.ContentBg
        row.Parent = ChangelogFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        AddStroke(row, Theme.Outline, 1)
        local iconDot = Instance.new("Frame")
        iconDot.Size = UDim2.new(0, 26, 0, 26)
        iconDot.Position = UDim2.new(0, 5, 0.5, -13)
        iconDot.BackgroundColor3 = Theme.SidebarBg
        iconDot.BorderSizePixel = 0
        iconDot.Parent = row
        Instance.new("UICorner", iconDot).CornerRadius = UDim.new(0, 6)
        local ic = Instance.new("TextLabel", iconDot)
        ic.Size = UDim2.new(1, 0, 1, 0)
        ic.BackgroundTransparency = 1
        ic.Text = icon
        ic.TextSize = 13
        ic.Font = Enum.Font.Gotham
        local tx = Instance.new("TextLabel", row)
        tx.Size = UDim2.new(1, -44, 1, 0)
        tx.Position = UDim2.new(0, 38, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = text
        tx.TextSize = 11
        tx.Font = Enum.Font.GothamMedium
        tx.TextColor3 = Theme.TextPrimary
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.TextWrapped = true
        table.insert(_clDynRows, row)
    end

    local function _showCLVersion(vdata)
        _clCurrentV = vdata
        if _clSepLbl  then _clSepLbl.Text  = "  ✦ WHAT'S NEW IN " .. vdata.v .. "  " end
        if _clHeroSub then _clHeroSub.Text = "Roblox Script Suite  ·  " .. #vdata.changes .. " Changes" end
        if _clBadgeLbl then _clBadgeLbl.Text = "v" .. vdata.v .. " ▼" end
        for _, r in ipairs(_clDynRows) do pcall(function() r:Destroy() end) end
        _clDynRows = {}
        for _, ch in ipairs(vdata.changes) do _addCLRow(ch[1], ch[2]) end
    end

    do
        local heroCard = Instance.new("Frame")
        heroCard.Size = UDim2.new(0.96, 0, 0, 68)
        heroCard.BackgroundColor3 = Theme.SidebarBg
        heroCard.Parent = ChangelogFrame
        Instance.new("UICorner", heroCard).CornerRadius = UDim.new(0, 10)
        AddStroke(heroCard, Theme.Accent, 1.5)

        local heroAccent = Instance.new("Frame")
        heroAccent.Size = UDim2.new(0, 4, 0.7, 0)
        heroAccent.Position = UDim2.new(0, 0, 0.15, 0)
        heroAccent.BackgroundColor3 = Theme.Accent
        heroAccent.BorderSizePixel = 0
        heroAccent.Parent = heroCard
        Instance.new("UICorner", heroAccent).CornerRadius = UDim.new(1, 0)

        local heroTitle = Instance.new("TextLabel")
        heroTitle.Size = UDim2.new(1, -60, 0, 26)
        heroTitle.Position = UDim2.new(0, 16, 0, 10)
        heroTitle.BackgroundTransparency = 1
        heroTitle.Text = "PHANTOM ULTIMATE"
        heroTitle.TextColor3 = Theme.TextPrimary
        heroTitle.Font = Enum.Font.GothamBlack
        heroTitle.TextSize = 17
        heroTitle.TextXAlignment = Enum.TextXAlignment.Left
        heroTitle.Parent = heroCard

        local heroBadge = Instance.new("TextButton")
        heroBadge.Size = UDim2.new(0, 50, 0, 18)
        heroBadge.Position = UDim2.new(1, -58, 0, 12)
        heroBadge.BackgroundColor3 = Theme.Accent
        heroBadge.BorderSizePixel = 0
        heroBadge.AutoButtonColor = false
        heroBadge.Text = ""
        heroBadge.ZIndex = 2
        heroBadge.Parent = heroCard
        Instance.new("UICorner", heroBadge).CornerRadius = UDim.new(0, 9)
        _clBadgeLbl = Instance.new("TextLabel", heroBadge)
        _clBadgeLbl.Size = UDim2.new(1, 0, 1, 0)
        _clBadgeLbl.BackgroundTransparency = 1
        _clBadgeLbl.Text = "v8.6 ▼"
        _clBadgeLbl.TextColor3 = Theme.MainBg
        _clBadgeLbl.Font = Enum.Font.GothamBlack
        _clBadgeLbl.TextSize = 9
        _clBadgeLbl.ZIndex = 3

        _clHeroSub = Instance.new("TextLabel")
        _clHeroSub.Size = UDim2.new(1, -20, 0, 18)
        _clHeroSub.Position = UDim2.new(0, 16, 0, 36)
        _clHeroSub.BackgroundTransparency = 1
        _clHeroSub.Text = "Roblox Script Suite  ·  8 Changes"
        _clHeroSub.TextColor3 = Theme.TextSecondary
        _clHeroSub.Font = Enum.Font.Gotham
        _clHeroSub.TextSize = 10
        _clHeroSub.TextXAlignment = Enum.TextXAlignment.Left
        _clHeroSub.Parent = heroCard

        _clDropdown = Instance.new("Frame")
        _clDropdown.Name = "PhantomCLDrop"
        _clDropdown.Size = UDim2.new(0, 126, 0, #CL_VERSIONS * 26 + 10)
        _clDropdown.BackgroundColor3 = Theme.SidebarBg
        _clDropdown.BorderSizePixel = 0
        _clDropdown.Visible = false
        _clDropdown.ZIndex = 3000
        _clDropdown.Parent = ScreenGui
        Instance.new("UICorner", _clDropdown).CornerRadius = UDim.new(0, 8)
        AddStroke(_clDropdown, Theme.Accent, 1)

        local dropList = Instance.new("UIListLayout", _clDropdown)
        dropList.SortOrder = Enum.SortOrder.LayoutOrder
        dropList.Padding = UDim.new(0, 2)
        local dropPad = Instance.new("UIPadding", _clDropdown)
        dropPad.PaddingTop    = UDim.new(0, 5)
        dropPad.PaddingBottom = UDim.new(0, 5)
        dropPad.PaddingLeft   = UDim.new(0, 5)
        dropPad.PaddingRight  = UDim.new(0, 5)

        for idx, vdata in ipairs(CL_VERSIONS) do
            local vBtn = Instance.new("TextButton")
            vBtn.Size = UDim2.new(1, 0, 0, 22)
            vBtn.BackgroundColor3 = Theme.ContentBg
            vBtn.BackgroundTransparency = idx == 1 and 0 or 1
            vBtn.AutoButtonColor = false
            vBtn.Text = ""
            vBtn.ZIndex = 3001
            vBtn.Parent = _clDropdown
            Instance.new("UICorner", vBtn).CornerRadius = UDim.new(0, 5)

            local vLbl = Instance.new("TextLabel", vBtn)
            vLbl.Size = UDim2.new(0.6, 0, 1, 0)
            vLbl.Position = UDim2.new(0, 7, 0, 0)
            vLbl.BackgroundTransparency = 1
            vLbl.Text = "v" .. vdata.v
            vLbl.TextColor3 = idx == 1 and Theme.Accent or Theme.TextSecondary
            vLbl.Font = Enum.Font.GothamBold
            vLbl.TextSize = 10
            vLbl.TextXAlignment = Enum.TextXAlignment.Left
            vLbl.ZIndex = 3002

            local vCnt = Instance.new("TextLabel", vBtn)
            vCnt.Size = UDim2.new(0.4, -4, 1, 0)
            vCnt.Position = UDim2.new(0.6, 0, 0, 0)
            vCnt.BackgroundTransparency = 1
            vCnt.Text = tostring(#vdata.changes)
            vCnt.TextColor3 = Theme.TextSecondary
            vCnt.Font = Enum.Font.Gotham
            vCnt.TextSize = 9
            vCnt.TextXAlignment = Enum.TextXAlignment.Right
            vCnt.ZIndex = 3002

            vBtn.MouseEnter:Connect(function()
                TweenService:Create(vBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ItemHover, BackgroundTransparency = 0}):Play()
                vLbl.TextColor3 = Theme.TextPrimary
            end)
            vBtn.MouseLeave:Connect(function()
                local isCurr = _clCurrentV.v == vdata.v
                TweenService:Create(vBtn, TweenInfo.new(0.1), {BackgroundColor3 = isCurr and Theme.ContentBg or Theme.SidebarBg, BackgroundTransparency = isCurr and 0 or 1}):Play()
                vLbl.TextColor3 = isCurr and Theme.Accent or Theme.TextSecondary
            end)
            vBtn.MouseButton1Click:Connect(function()
                _clDropOpen = false
                _clDropdown.Visible = false
                for _, ch in pairs(_clDropdown:GetChildren()) do
                    if ch:IsA("TextButton") then
                        local l = ch:FindFirstChildWhichIsA("TextLabel")
                        TweenService:Create(ch, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                        if l then l.TextColor3 = Theme.TextSecondary end
                    end
                end
                vBtn.BackgroundTransparency = 0
                vBtn.BackgroundColor3 = Theme.ContentBg
                vLbl.TextColor3 = Theme.Accent
                _showCLVersion(vdata)
            end)
        end

        heroBadge.MouseEnter:Connect(function()
            TweenService:Create(heroBadge, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0, 200, 235)}):Play()
        end)
        heroBadge.MouseLeave:Connect(function()
            TweenService:Create(heroBadge, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
        end)
        heroBadge.MouseButton1Click:Connect(function()
            _clDropOpen = not _clDropOpen
            _clDropdown.Visible = _clDropOpen
            if _clDropOpen then
                local ap = heroBadge.AbsolutePosition
                local as = heroBadge.AbsoluteSize
                _clDropdown.Position = UDim2.new(0, ap.X + as.X - 126, 0, ap.Y + as.Y + 4)
            end
        end)

        AddConnection(MainFrame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and _clDropOpen then
                task.defer(function()
                    _clDropOpen = false
                    _clDropdown.Visible = false
                end)
            end
        end))
    end

    do
        local discPill = Instance.new("TextButton")
        discPill.Size = UDim2.new(0.96, 0, 0, 36)
        discPill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        discPill.Text = ""
        discPill.AutoButtonColor = false
        discPill.Parent = ChangelogFrame
        Instance.new("UICorner", discPill).CornerRadius = UDim.new(0, 9)
        local discIcon = Instance.new("TextLabel", discPill)
        discIcon.Size = UDim2.new(0, 22, 1, 0); discIcon.Position = UDim2.new(0, 12, 0, 0)
        discIcon.BackgroundTransparency = 1; discIcon.Text = "💬"
        discIcon.TextSize = 14; discIcon.Font = Enum.Font.Gotham
        local discLblTx = Instance.new("TextLabel", discPill)
        discLblTx.Size = UDim2.new(1, -50, 1, 0); discLblTx.Position = UDim2.new(0, 36, 0, 0)
        discLblTx.BackgroundTransparency = 1
        discLblTx.Text = "Join Phantom Discord"
        discLblTx.TextColor3 = Color3.new(1,1,1)
        discLblTx.Font = Enum.Font.GothamBold; discLblTx.TextSize = 12
        discLblTx.TextXAlignment = Enum.TextXAlignment.Left
        local discArrow = Instance.new("TextLabel", discPill)
        discArrow.Size = UDim2.new(0, 18, 1, 0); discArrow.Position = UDim2.new(1, -26, 0, 0)
        discArrow.BackgroundTransparency = 1; discArrow.Text = "›"
        discArrow.TextColor3 = Color3.new(1,1,1); discArrow.Font = Enum.Font.GothamBold; discArrow.TextSize = 18
        discPill.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard("https://discord.gg/JEgsFtwABp"); SendNotification("Discord Link Copied!", Theme.Green)
            else SendNotification("Executor does not support clipboard.", Theme.Red) end
        end)
        discPill.MouseEnter:Connect(function() TweenService:Create(discPill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(110, 124, 255)}):Play() end)
        discPill.MouseLeave:Connect(function() TweenService:Create(discPill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play() end)
    end

    createButton(DiscordFrame, "📋 Copy Discord Link", "Click to copy our official Discord server link.", Theme.Accent, function()
        if setclipboard then
            setclipboard("https://discord.gg/JEgsFtwABp")
            SendNotification("Discord Link Copied!", Theme.Green)
        else
            SendNotification("Your executor does not support clipboard copying.", Theme.Red)
        end
    end)

    do
        local clSep = Instance.new("Frame")
        clSep.Size = UDim2.new(0.96, 0, 0, 28)
        clSep.BackgroundTransparency = 1
        clSep.Parent = ChangelogFrame
        local clLine = Instance.new("Frame", clSep)
        clLine.Size = UDim2.new(1, 0, 0, 1); clLine.Position = UDim2.new(0, 0, 0.5, 0)
        clLine.BackgroundColor3 = Theme.Outline; clLine.BorderSizePixel = 0
        _clSepLbl = Instance.new("TextLabel", clSep)
        _clSepLbl.Size = UDim2.new(0, 0, 1, 0); _clSepLbl.AutomaticSize = Enum.AutomaticSize.X
        _clSepLbl.Position = UDim2.new(0, 8, 0, 0)
        _clSepLbl.BackgroundColor3 = Theme.MainBg; _clSepLbl.BorderSizePixel = 0
        _clSepLbl.Text = "  ✦ WHAT'S NEW IN 8.6  "
        _clSepLbl.TextColor3 = Theme.Accent; _clSepLbl.Font = Enum.Font.GothamBold; _clSepLbl.TextSize = 9
        _showCLVersion(CL_VERSIONS[1])
    end

    openKeybindPopup = function(featureName, refreshVisualFn, toggleObjRef)
        local existing = ScreenGui:FindFirstChild("PhantomKeybindPopup")
        if existing then existing:Destroy() end

        local overlay = Instance.new("Frame")
        overlay.Name = "PhantomKeybindPopup"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.55
        overlay.ZIndex = 5000
        overlay.Parent = ScreenGui

        local popup = Instance.new("Frame")
        popup.Name = "PopupFrame"
        popup.Size = UDim2.new(0, 300, 0, 218)
        popup.Position = UDim2.new(0.5, -150, 0.58, -109)
        popup.BackgroundColor3 = Theme.SidebarBg
        popup.BackgroundTransparency = 1
        popup.ZIndex = 5001
        popup.Parent = overlay
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 14)
        AddStroke(popup, Theme.Accent, 1.5)

        local titleBar = Instance.new("Frame", popup)
        titleBar.Size = UDim2.new(1, 0, 0, 42); titleBar.BackgroundColor3 = Theme.ContentBg
        titleBar.BorderSizePixel = 0; titleBar.ZIndex = 5002
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
        local tFix = Instance.new("Frame", titleBar)
        tFix.Size = UDim2.new(1,0,0,14); tFix.Position = UDim2.new(0,0,1,-14)
        tFix.BackgroundColor3 = Theme.ContentBg; tFix.BorderSizePixel = 0; tFix.ZIndex = 5002
        local tIcon = Instance.new("TextLabel", titleBar)
        tIcon.Size = UDim2.new(0,28,1,0); tIcon.Position = UDim2.new(0,12,0,0)
        tIcon.BackgroundTransparency=1; tIcon.Text="⌨️"; tIcon.TextSize=16
        tIcon.TextColor3=Theme.Accent; tIcon.Font=Enum.Font.GothamBold; tIcon.ZIndex=5003
        local tLbl = Instance.new("TextLabel", titleBar)
        tLbl.Size = UDim2.new(1,-80,1,0); tLbl.Position = UDim2.new(0,44,0,0)
        tLbl.BackgroundTransparency=1; tLbl.Text="Set Keybind"
        tLbl.TextColor3=Theme.TextPrimary; tLbl.Font=Enum.Font.GothamBold
        tLbl.TextSize=13; tLbl.TextXAlignment=Enum.TextXAlignment.Left; tLbl.ZIndex=5003
        local closeX = Instance.new("TextButton", titleBar)
        closeX.Size=UDim2.new(0,26,0,26); closeX.Position=UDim2.new(1,-34,0.5,-13)
        closeX.BackgroundColor3=Color3.fromRGB(50,30,30); closeX.Text="X"
        closeX.TextColor3=Theme.Red; closeX.Font=Enum.Font.GothamBold; closeX.TextSize=11
        closeX.ZIndex=5003; Instance.new("UICorner",closeX).CornerRadius=UDim.new(1,0)

        local featLbl = Instance.new("TextLabel", popup)
        featLbl.Size=UDim2.new(1,-24,0,18); featLbl.Position=UDim2.new(0,12,0,50)
        featLbl.BackgroundTransparency=1; featLbl.ZIndex=5002
        featLbl.Text="Feature:  "..featureName; featLbl.TextColor3=Theme.TextSecondary
        featLbl.Font=Enum.Font.Gotham; featLbl.TextSize=10
        featLbl.TextXAlignment=Enum.TextXAlignment.Left
        featLbl.TextTruncate=Enum.TextTruncate.AtEnd

        local keyBox = Instance.new("Frame", popup)
        keyBox.Size=UDim2.new(1,-24,0,48); keyBox.Position=UDim2.new(0,12,0,74)
        keyBox.BackgroundColor3=Theme.ContentBg; keyBox.ZIndex=5002
        Instance.new("UICorner",keyBox).CornerRadius=UDim.new(0,10)
        local kbStk = AddStroke(keyBox, Theme.Outline, 1.5)
        local keyLbl = Instance.new("TextLabel", keyBox)
        keyLbl.Size=UDim2.new(1,0,1,0); keyLbl.BackgroundTransparency=1
        keyLbl.Text="Press any key…"; keyLbl.TextColor3=Theme.TextSecondary
        keyLbl.Font=Enum.Font.GothamBold; keyLbl.TextSize=14; keyLbl.ZIndex=5003
        local keyHint = Instance.new("TextLabel", keyBox)
        keyHint.Size=UDim2.new(1,0,0,14); keyHint.Position=UDim2.new(0,0,1,-16)
        keyHint.BackgroundTransparency=1; keyHint.Text="Esc to cancel"
        keyHint.TextColor3=Theme.TextSecondary; keyHint.Font=Enum.Font.Gotham
        keyHint.TextSize=8; keyHint.ZIndex=5003

        local ctrlRow = Instance.new("TextButton", popup)
        ctrlRow.Size=UDim2.new(1,-24,0,32); ctrlRow.Position=UDim2.new(0,12,0,130)
        ctrlRow.BackgroundColor3=Theme.ContentBg; ctrlRow.Text=""; ctrlRow.AutoButtonColor=false
        ctrlRow.ZIndex=5002; Instance.new("UICorner",ctrlRow).CornerRadius=UDim.new(0,8)
        AddStroke(ctrlRow,Theme.Outline,1)
        local ctrlLbl = Instance.new("TextLabel", ctrlRow)
        ctrlLbl.Size=UDim2.new(0.72,0,1,0); ctrlLbl.Position=UDim2.new(0,10,0,0)
        ctrlLbl.BackgroundTransparency=1; ctrlLbl.Text="Require  Ctrl + Key"
        ctrlLbl.TextColor3=Theme.TextPrimary; ctrlLbl.Font=Enum.Font.GothamMedium
        ctrlLbl.TextSize=11; ctrlLbl.TextXAlignment=Enum.TextXAlignment.Left; ctrlLbl.ZIndex=5003
        local swBg = Instance.new("Frame", ctrlRow)
        swBg.Size=UDim2.new(0,36,0,20); swBg.Position=UDim2.new(1,-44,0.5,-10)
        swBg.BackgroundColor3=Color3.fromRGB(45,45,55); swBg.ZIndex=5003
        Instance.new("UICorner",swBg).CornerRadius=UDim.new(1,0)
        local swDot = Instance.new("Frame", swBg)
        swDot.Size=UDim2.new(0,14,0,14); swDot.Position=UDim2.new(0,3,0.5,-7)
        swDot.BackgroundColor3=Color3.fromRGB(160,160,175); swDot.ZIndex=5004
        Instance.new("UICorner",swDot).CornerRadius=UDim.new(1,0)

        local clearBtn = Instance.new("TextButton", popup)
        clearBtn.Size=UDim2.new(0.44,0,0,30); clearBtn.Position=UDim2.new(0,12,1,-40)
        clearBtn.BackgroundColor3=Theme.ContentBg; clearBtn.Text="🗑  Clear"
        clearBtn.TextColor3=Theme.Red; clearBtn.Font=Enum.Font.GothamBold; clearBtn.TextSize=11
        clearBtn.ZIndex=5002; Instance.new("UICorner",clearBtn).CornerRadius=UDim.new(0,8)
        AddStroke(clearBtn,Theme.Red,1)
        local saveBtn = Instance.new("TextButton", popup)
        saveBtn.Size=UDim2.new(0.44,0,0,30); saveBtn.Position=UDim2.new(1,-144,1,-40)
        saveBtn.BackgroundColor3=Theme.Accent; saveBtn.Text="✓  Save"
        saveBtn.TextColor3=Theme.MainBg; saveBtn.Font=Enum.Font.GothamBold; saveBtn.TextSize=11
        saveBtn.ZIndex=5002; Instance.new("UICorner",saveBtn).CornerRadius=UDim.new(0,8)

        local capturedKey = nil
        local ctrlRequired = false
        local existingKb = Settings.Keybinds[featureName]
        if existingKb and existingKb.key then
            capturedKey = existingKb.key
            ctrlRequired = existingKb.ctrl == true
            keyLbl.Text = capturedKey
            keyLbl.TextColor3 = Theme.Accent
            TweenService:Create(kbStk, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
        end

        local function updateCtrlSw()
            TweenService:Create(swDot, TweenInfo.new(0.18), {
                Position = ctrlRequired and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                BackgroundColor3 = ctrlRequired and Color3.new(1,1,1) or Color3.fromRGB(160,160,175)
            }):Play()
            TweenService:Create(swBg, TweenInfo.new(0.18), {BackgroundColor3 = ctrlRequired and Theme.Accent or Color3.fromRGB(45,45,55)}):Play()
        end
        updateCtrlSw()

        ctrlRow.MouseButton1Click:Connect(function()
            ctrlRequired = not ctrlRequired; updateCtrlSw()
        end)

        TweenService:Create(popup, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5,-150,0.5,-109),
            BackgroundTransparency = 0
        }):Play()

        local pulseRunning = true
        task.spawn(function()
            while pulseRunning and overlay.Parent do
                if capturedKey == nil then
                    TweenService:Create(kbStk, TweenInfo.new(0.5), {Color = Theme.Accent}):Play()
                    task.wait(0.5)
                    if kbStk and capturedKey == nil then
                        TweenService:Create(kbStk, TweenInfo.new(0.5), {Color = Theme.Outline}):Play()
                    end
                    task.wait(0.5)
                else
                    task.wait(0.2)
                end
            end
        end)

        local keyConn
        keyConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            local kc = input.KeyCode

            if kc == Enum.KeyCode.Unknown then return end
            if kc == Enum.KeyCode.Escape then
                pulseRunning = false
                if keyConn then keyConn:Disconnect() end
                TweenService:Create(popup, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5,-150,0.55,-109), BackgroundTransparency = 1
                }):Play()
                task.delay(0.15, function() if overlay.Parent then overlay:Destroy() end end)
                return
            end

            if kc == Enum.KeyCode.LeftControl or kc == Enum.KeyCode.RightControl
            or kc == Enum.KeyCode.LeftShift or kc == Enum.KeyCode.RightShift
            or kc == Enum.KeyCode.LeftAlt or kc == Enum.KeyCode.RightAlt then return end
            local keyName = tostring(kc):gsub("Enum.KeyCode.","")
            keyName = keyName:gsub("^KeypadZero$","KP0"):gsub("^Keypad","KP")
            keyName = keyName:gsub("^LeftBracket$","["):gsub("^RightBracket$","]")
            keyName = keyName:gsub("^Semicolon$",";"):gsub("^Apostrophe$","'")
            if #keyName > 5 then keyName = keyName:sub(1,5) end
            capturedKey = keyName
            keyLbl.Text = keyName; keyLbl.TextColor3 = Theme.Accent
            TweenService:Create(kbStk, TweenInfo.new(0.12), {Color = Theme.Accent}):Play()
        end)

        local function closePopup()
            pulseRunning = false
            if keyConn then keyConn:Disconnect() end
            TweenService:Create(popup, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5,-150,0.55,-109), BackgroundTransparency = 1
            }):Play()
            task.delay(0.15, function() if overlay.Parent then overlay:Destroy() end end)
        end

        closeX.MouseButton1Click:Connect(closePopup)

        popup.Active = true
        overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = input.Position
                local pPos = popup.AbsolutePosition
                local pSize = popup.AbsoluteSize
                if pos.X < pPos.X or pos.X > pPos.X + pSize.X or pos.Y < pPos.Y or pos.Y > pPos.Y + pSize.Y then
                    closePopup()
                end
            end
        end)

        clearBtn.MouseButton1Click:Connect(function()
            Settings.Keybinds[featureName] = nil
            saveSettings()
            if refreshVisualFn then refreshVisualFn() end
            SendNotification("Keybind cleared", Theme.Yellow)
            closePopup()
        end)

        saveBtn.MouseButton1Click:Connect(function()
            if not capturedKey then
                SendNotification("Press a key first!", Theme.Red)
                TweenService:Create(keyBox, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(60,20,20)}):Play()
                task.delay(0.2, function() TweenService:Create(keyBox, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ContentBg}):Play() end)
                return
            end
            Settings.Keybinds[featureName] = {key = capturedKey, ctrl = ctrlRequired}
            saveSettings()
            if refreshVisualFn then refreshVisualFn() end
            local label = (ctrlRequired and "Ctrl+" or "") .. capturedKey
            SendNotification("Keybind set: " .. label, Theme.Green)
            closePopup()
        end)
    end

    local function BuildAllTabs()

    local GLOBAL_CHAT_API = "https://phantom-chat-c1bec-default-rtdb.firebaseio.com/global_chat.json"
    local chatMenuW = (Settings.ChatMenuSize and Settings.ChatMenuSize.W) or 340
    local chatMenuH = (Settings.ChatMenuSize and Settings.ChatMenuSize.H) or 420

    local ChatMenu = Instance.new("Frame")
    ChatMenu.Name = "ChatMenu"
    ChatMenu.Size = UDim2.new(0, chatMenuW, 0, chatMenuH)
    ChatMenu.Position = UDim2.new(0.5, 60, 0.5, -210)
    ChatMenu.BackgroundColor3 = Theme.MainBg
    ChatMenu.Visible = false
    ChatMenu.ZIndex = 100
    ChatMenu.Parent = ScreenGui
    Instance.new("UICorner", ChatMenu).CornerRadius = UDim.new(0, 12)
    AddStroke(ChatMenu, Theme.Outline, 1.5)

    local ChatTopBar = Instance.new("Frame")
    ChatTopBar.Size = UDim2.new(1, 0, 0, 42)
    ChatTopBar.BackgroundColor3 = Theme.SidebarBg
    ChatTopBar.ZIndex = 101
    ChatTopBar.Parent = ChatMenu
    Instance.new("UICorner", ChatTopBar).CornerRadius = UDim.new(0, 12)
    local chatHdrFix = Instance.new("Frame", ChatTopBar)
    chatHdrFix.Size = UDim2.new(1, 0, 0, 12); chatHdrFix.Position = UDim2.new(0, 0, 1, -12)
    chatHdrFix.BackgroundColor3 = Theme.SidebarBg; chatHdrFix.BorderSizePixel = 0; chatHdrFix.ZIndex = 101

    local chatDot = Instance.new("Frame", ChatTopBar)
    chatDot.Size = UDim2.new(0, 7, 0, 7); chatDot.Position = UDim2.new(0, 14, 0.5, -3)
    chatDot.BackgroundColor3 = Theme.Accent; chatDot.BorderSizePixel = 0; chatDot.ZIndex = 102
    Instance.new("UICorner", chatDot).CornerRadius = UDim.new(1, 0)

    local chatTitleLbl = Instance.new("TextLabel", ChatTopBar)
    chatTitleLbl.Size = UDim2.new(1, -70, 1, 0); chatTitleLbl.Position = UDim2.new(0, 26, 0, 0)
    chatTitleLbl.BackgroundTransparency = 1; chatTitleLbl.Text = "GLOBAL CHAT"
    chatTitleLbl.TextColor3 = Theme.TextPrimary; chatTitleLbl.Font = Enum.Font.GothamBlack
    chatTitleLbl.TextSize = 12; chatTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; chatTitleLbl.ZIndex = 102

    local ChatCloseBtn = Instance.new("TextButton", ChatTopBar)
    ChatCloseBtn.Size = UDim2.new(0, 24, 0, 24); ChatCloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
    ChatCloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30); ChatCloseBtn.Text = "X"
    ChatCloseBtn.TextColor3 = Theme.Red; ChatCloseBtn.Font = Enum.Font.GothamBold; ChatCloseBtn.TextSize = 11; ChatCloseBtn.ZIndex = 102
    Instance.new("UICorner", ChatCloseBtn).CornerRadius = UDim.new(1, 0)
    ChatCloseBtn.MouseButton1Click:Connect(function() ChatMenu.Visible = false end)
    ChatBtn.MouseButton1Click:Connect(function() ChatMenu.Visible = not ChatMenu.Visible end)

    local chatDivider = Instance.new("Frame", ChatMenu)
    chatDivider.Size = UDim2.new(1, -24, 0, 1); chatDivider.Position = UDim2.new(0, 12, 0, 42)
    chatDivider.BackgroundColor3 = Theme.Outline; chatDivider.BorderSizePixel = 0; chatDivider.ZIndex = 101

    local chatDragging, chatDragInput, chatDragStart, chatStartPos
    local function updateChatDrag(input)
        local delta = input.Position - chatDragStart
        ChatMenu.Position = UDim2.new(chatStartPos.X.Scale, chatStartPos.X.Offset + delta.X, chatStartPos.Y.Scale, chatStartPos.Y.Offset + delta.Y)
    end
    ChatTopBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then chatDragging, chatDragStart, chatStartPos = true, input.Position, ChatMenu.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then chatDragging = false end end) end end)
    ChatTopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then chatDragInput = input end end)
    AddConnection(UserInputService.InputChanged:Connect(function(input) if input == chatDragInput and chatDragging then updateChatDrag(input) end end))

    local CHAT_MIN_W, CHAT_MIN_H = 260, 300
    local CHAT_MAX_W, CHAT_MAX_H = 700, 700

    local ChatResizeBtn = Instance.new("TextButton")
    ChatResizeBtn.Name = "ResizeHandle"
    ChatResizeBtn.Size = UDim2.new(0, 24, 0, 24)
    ChatResizeBtn.AnchorPoint = Vector2.new(1, 1)
    ChatResizeBtn.Position = UDim2.new(1, 0, 1, 0)
    ChatResizeBtn.BackgroundTransparency = 1
    ChatResizeBtn.Text = ""
    ChatResizeBtn.ZIndex = 115
    ChatResizeBtn.Parent = ChatMenu

    local crArrow1 = Instance.new("TextLabel")
    crArrow1.Size = UDim2.new(0, 14, 0, 14)
    crArrow1.Position = UDim2.new(0, 0, 0, 0)
    crArrow1.BackgroundTransparency = 1
    crArrow1.Text = "↖"
    crArrow1.TextColor3 = Theme.TextSecondary
    crArrow1.Font = Enum.Font.GothamBold
    crArrow1.TextSize = 12
    crArrow1.ZIndex = 116
    crArrow1.Parent = ChatResizeBtn

    local crArrow2 = Instance.new("TextLabel")
    crArrow2.Size = UDim2.new(0, 14, 0, 14)
    crArrow2.AnchorPoint = Vector2.new(1, 1)
    crArrow2.Position = UDim2.new(1, 0, 1, 0)
    crArrow2.BackgroundTransparency = 1
    crArrow2.Text = "↘"
    crArrow2.TextColor3 = Theme.TextSecondary
    crArrow2.Font = Enum.Font.GothamBold
    crArrow2.TextSize = 12
    crArrow2.ZIndex = 116
    crArrow2.Parent = ChatResizeBtn

    ChatResizeBtn.MouseEnter:Connect(function()
        crArrow1.TextColor3 = Theme.Accent
        crArrow2.TextColor3 = Theme.Accent
    end)
    ChatResizeBtn.MouseLeave:Connect(function()
        crArrow1.TextColor3 = Theme.TextSecondary
        crArrow2.TextColor3 = Theme.TextSecondary
    end)

    local chatResizing = false
    local chatResizeDragStart = nil
    local chatResizeStartSize = nil

    ChatResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            chatResizing = true
            chatResizeDragStart = input.Position
            chatResizeStartSize = ChatMenu.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    chatResizing = false
                end
            end)
        end
    end)

    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if chatResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - chatResizeDragStart
            local newW = math.clamp(chatResizeStartSize.X + delta.X, CHAT_MIN_W, CHAT_MAX_W)
            local newH = math.clamp(chatResizeStartSize.Y + delta.Y, CHAT_MIN_H, CHAT_MAX_H)
            ChatMenu.Size = UDim2.new(0, newW, 0, newH)
            Settings.ChatMenuSize = { W = newW, H = newH }
            saveSettings()
        end
    end))

    local ChatScroll = Instance.new("ScrollingFrame")
    ChatScroll.Size = UDim2.new(1, -16, 1, -98); ChatScroll.Position = UDim2.new(0, 8, 0, 48)
    ChatScroll.BackgroundTransparency = 1; ChatScroll.ScrollBarThickness = 3
    ChatScroll.ScrollBarImageColor3 = Theme.Accent; ChatScroll.ZIndex = 101; ChatScroll.Parent = ChatMenu
    local ChatListLayout = Instance.new("UIListLayout")
    ChatListLayout.Parent = ChatScroll; ChatListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ChatListLayout.Padding = UDim.new(0, 6)
    ChatListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ChatScroll.CanvasSize = UDim2.new(0, 0, 0, ChatListLayout.AbsoluteContentSize.Y + 10); ChatScroll.CanvasPosition = Vector2.new(0, ChatScroll.CanvasSize.Y.Offset) end)

    local chatInputRow = Instance.new("Frame")
    chatInputRow.Size = UDim2.new(1, -16, 0, 36); chatInputRow.Position = UDim2.new(0, 8, 1, -44)
    chatInputRow.BackgroundTransparency = 1; chatInputRow.ZIndex = 101; chatInputRow.Parent = ChatMenu

    local ChatTextBox = Instance.new("TextBox")
    ChatTextBox.Size = UDim2.new(1, -52, 1, 0)
    ChatTextBox.BackgroundColor3 = Theme.ContentBg; ChatTextBox.Text = ""
    ChatTextBox.PlaceholderText = "Send a message..."; ChatTextBox.TextColor3 = Theme.TextPrimary
    ChatTextBox.Font = Enum.Font.Gotham; ChatTextBox.TextSize = 12
    ChatTextBox.TextXAlignment = Enum.TextXAlignment.Left; ChatTextBox.ZIndex = 102; ChatTextBox.Parent = chatInputRow
    Instance.new("UICorner", ChatTextBox).CornerRadius = UDim.new(0, 8)
    AddStroke(ChatTextBox, Theme.Outline, 1)
    Instance.new("UIPadding", ChatTextBox).PaddingLeft = UDim.new(0, 10)

    local ChatSendBtn = Instance.new("TextButton")
    ChatSendBtn.Size = UDim2.new(0, 44, 0, 36); ChatSendBtn.Position = UDim2.new(1, -44, 0, 0)
    ChatSendBtn.BackgroundColor3 = Theme.Accent; ChatSendBtn.Text = "↑"
    ChatSendBtn.TextColor3 = Theme.MainBg; ChatSendBtn.Font = Enum.Font.GothamBlack
    ChatSendBtn.TextSize = 18; ChatSendBtn.ZIndex = 102; ChatSendBtn.Parent = chatInputRow
    Instance.new("UICorner", ChatSendBtn).CornerRadius = UDim.new(0, 8)

    local chatInputDivider = Instance.new("Frame", ChatMenu)
    chatInputDivider.Size = UDim2.new(1, -24, 0, 1); chatInputDivider.Position = UDim2.new(0, 12, 1, -48)
    chatInputDivider.BackgroundColor3 = Theme.Outline; chatInputDivider.BorderSizePixel = 0; chatInputDivider.ZIndex = 101

    local function CreateChatMessage(userId, dispName, usrName, msgText)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(1, 0, 0, 50)
        msgFrame.BackgroundColor3 = Theme.ContentBg
        msgFrame.ZIndex = 101
        msgFrame.Parent = ChatScroll
        Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 8)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 34, 0, 34); avatar.Position = UDim2.new(0, 8, 0.5, -17)
        avatar.BackgroundColor3 = Theme.SidebarBg; avatar.ZIndex = 102; avatar.Parent = msgFrame
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
        pcall(function() avatar.Image = game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)

        local dNameLbl = Instance.new("TextLabel")
        dNameLbl.Size = UDim2.new(1, -58, 0, 15); dNameLbl.Position = UDim2.new(0, 50, 0, 6)
        dNameLbl.BackgroundTransparency = 1; dNameLbl.Text = dispName
        dNameLbl.TextColor3 = Theme.TextPrimary; dNameLbl.Font = Enum.Font.GothamBold
        dNameLbl.TextSize = 11; dNameLbl.TextXAlignment = Enum.TextXAlignment.Left; dNameLbl.ZIndex = 102; dNameLbl.Parent = msgFrame

        local uNameLbl = Instance.new("TextLabel")
        uNameLbl.Size = UDim2.new(1, -58, 0, 11); uNameLbl.Position = UDim2.new(0, 50, 0, 20)
        uNameLbl.BackgroundTransparency = 1; uNameLbl.Text = "@" .. usrName
        uNameLbl.TextColor3 = Theme.TextSecondary; uNameLbl.Font = Enum.Font.Gotham
        uNameLbl.TextSize = 9; uNameLbl.TextXAlignment = Enum.TextXAlignment.Left; uNameLbl.ZIndex = 102; uNameLbl.Parent = msgFrame

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -58, 0, 0); msgLbl.Position = UDim2.new(0, 50, 0, 32)
        msgLbl.AutomaticSize = Enum.AutomaticSize.Y
        msgLbl.BackgroundTransparency = 1; msgLbl.Text = msgText
        msgLbl.TextColor3 = Theme.TextPrimary; msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 11; msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped = true; msgLbl.ZIndex = 102; msgLbl.Parent = msgFrame

        task.defer(function()
            msgFrame.Size = UDim2.new(1, 0, 0, math.max(50, 36 + msgLbl.AbsoluteSize.Y + 4))
        end)
    end

    local lastChatTime = 0
    local LoadedFirebaseKeys = {}
    local LocalSentMessages = {}

    local function HandleSendMsg()
        local txt = ChatTextBox.Text
        if txt and txt ~= "" then
            if Player.Name ~= "TheMagge" and tick() - lastChatTime < 3 then
                SendNotification("Chat spam cooldown active! Please wait.", Theme.Red)
                return
            end
            lastChatTime = tick()

            local msgId = HttpService:GenerateGUID(false)
            LocalSentMessages[msgId] = true

            CreateChatMessage(Player.UserId, Player.DisplayName, Player.Name, txt)

            task.spawn(function()
                local httpRequest = getHttpRequest()
                if httpRequest and GLOBAL_CHAT_API ~= "" then
                    pcall(function()
                        local data = { MsgId = msgId, UserId = Player.UserId, DisplayName = Player.DisplayName, UserName = Player.Name, Message = txt }
                        httpRequest({ Url = GLOBAL_CHAT_API, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data) })
                    end)
                end
            end)
            ChatTextBox.Text = ""
        end
    end

    ChatSendBtn.MouseButton1Click:Connect(HandleSendMsg)
    ChatTextBox.FocusLost:Connect(function(enter) if enter then HandleSendMsg() end end)

    local lastFetchTime = 0
    local _chatFetchRunning = true
    AddConnection({Connected=true, Disconnect=function() _chatFetchRunning=false end})
    task.spawn(function()
        while _chatFetchRunning do
            task.wait(0.2)
            if not _chatFetchRunning then break end
            if ChatMenu.Visible and GLOBAL_CHAT_API ~= "" then
                if tick() - lastFetchTime >= 1.5 then
                    lastFetchTime = tick()
                    local httpRequest = getHttpRequest()
                    if httpRequest then
                        pcall(function()
                            local fetchUrl = GLOBAL_CHAT_API .. '?orderBy="%24key"&limitToLast=20&nocache=' .. tostring(tick())
                            local response = httpRequest({
                                Url = fetchUrl,
                                Method = "GET",
                                Headers = {
                                    ["Cache-Control"] = "no-cache",
                                    ["Pragma"] = "no-cache"
                                }
                            })

                            if response and response.StatusCode == 200 then
                                local data = HttpService:JSONDecode(response.Body)
                                if data and type(data) == "table" then
                                    local keys = {}
                                    for key, _ in pairs(data) do table.insert(keys, key) end
                                    table.sort(keys)

                                    for _, key in ipairs(keys) do
                                        if not LoadedFirebaseKeys[key] then
                                            LoadedFirebaseKeys[key] = true
                                            local msgData = data[key]

                                            if not msgData.MsgId or not LocalSentMessages[msgData.MsgId] then
                                                CreateChatMessage(msgData.UserId, msgData.DisplayName, msgData.UserName, msgData.Message)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)

    createToggleSwitch(TagsFrame, "💬 Enable Global Chat", "Enable cross-game chat with other script users.", function(state) ChatBtn.Visible = state; if not state then ChatMenu.Visible = false end end, false, false)

local toggleFling
flinging, Noclipping = false, nil
local function FlingNoclipLoop() if flinging and Player.Character then for _, child in pairs(Player.Character:GetDescendants()) do if child:IsA("BasePart") and child.CanCollide == true then child.CanCollide = false end end end end

do
toggleFling = function(state)
    flinging = state; local char = Player.Character
    if state then
        if char then
            for _, child in pairs(char:GetDescendants()) do if child:IsA("BasePart") then child.CustomPhysicalProperties, child.CanCollide, child.Massless = PhysicalProperties.new(100, 0.3, 0.5), false, true; pcall(function() child.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end) end end
            if Noclipping then Noclipping:Disconnect() end; Noclipping = RunService.Stepped:Connect(FlingNoclipLoop)
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bambam = Instance.new("BodyAngularVelocity")
                bambam.Name, bambam.Parent, bambam.AngularVelocity, bambam.MaxTorque, bambam.P = "Phantom_Fling", root, Vector3.new(0, 99999, 0), Vector3.new(0, 9e9, 0), 9e9
                task.spawn(function() while flinging and root and root.Parent do bambam.AngularVelocity = Vector3.new(0, 99999, 0); task.wait(0.2); bambam.AngularVelocity = Vector3.new(0, 0, 0); task.wait(0.1) end; if bambam then bambam:Destroy() end end)
            end
        end
    else
        if Noclipping then Noclipping:Disconnect(); Noclipping = nil end
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("Phantom_Fling") then root.Phantom_Fling:Destroy() end
            if root then pcall(function() root.AssemblyLinearVelocity = Vector3.new(0,0,0); root.AssemblyAngularVelocity = Vector3.new(0,0,0) end) end
            for _, child in pairs(char:GetDescendants()) do if child:IsA("BasePart") then child.CustomPhysicalProperties, child.Massless = nil, false end end
            local hum = char:FindFirstChild("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end
end

end

    createSectionHeader(CombatFrame, "💊  AUTO HEAL")
    do
        local _healConn = nil
        createToggleSwitch(CombatFrame, "💊 Auto Heal", "Continuously restores your health every 0.5 seconds.", function(state)
            if _healConn then _healConn:Disconnect(); _healConn = nil end
            if state then
                _healConn = AddConnection(RunService.Heartbeat:Connect(function()
                    local char = Player.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MaxHealth > 0 and hum.Health < hum.MaxHealth then
                        hum.Health = math.min(hum.Health + 2, hum.MaxHealth)
                    end
                end))
                SendNotification("Auto Heal Enabled!", Theme.Green)
            else
                SendNotification("Auto Heal Disabled!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(CombatFrame, "⚡  GOD MODE")
    do
        local _godConn    = nil
        local _godCharConn = nil

        local function _applyGod(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end

        createToggleSwitch(CombatFrame, "⚡ God Mode (Health Lock)", "Sets your health to infinite so you cannot die.", function(state)
            if _godConn     then _godConn:Disconnect();     _godConn = nil     end
            if _godCharConn then _godCharConn:Disconnect(); _godCharConn = nil end
            if state then
                _applyGod(Player.Character)
                _godConn = AddConnection(RunService.Heartbeat:Connect(function()
                    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
                        if hum.Health < 1e10 then hum.Health = math.huge end
                    end
                end))
                _godCharConn = AddConnection(Player.CharacterAdded:Connect(function(c)
                    task.wait(0.3); _applyGod(c)
                end))
                SendNotification("God Mode Enabled! You cannot die.", Theme.Green)
            else
                local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = 100; hum.Health = math.min(100, hum.MaxHealth) end
                SendNotification("God Mode Disabled!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(CombatFrame, "🗡️  NPC TOOLS")
    createButton(CombatFrame, "🗡️ Kill All NPCs", "Destroy the Humanoid of every NPC in workspace.", Theme.Red, function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") then
                local model = v:FindFirstAncestorOfClass("Model")
                if model and not game.Players:GetPlayerFromCharacter(model) then
                    pcall(function() v.Health = 0; count = count + 1 end)
                end
            end
        end
        SendNotification("Killed " .. count .. " NPCs!", Theme.Red)
    end)

    createSectionHeader(CombatFrame, "🎯  TARGET SELECTION")
    combatSelectedPlayer = nil
    local combatPlayerLabel = Instance.new("TextLabel")
    combatPlayerLabel.Text, combatPlayerLabel.Size, combatPlayerLabel.BackgroundColor3, combatPlayerLabel.TextColor3, combatPlayerLabel.Parent = "Target: None", UDim2.new(0.96, 0, 0, 30), Theme.ContentBg, Theme.Accent, CombatFrame
    Instance.new("UICorner", combatPlayerLabel).CornerRadius = UDim.new(0, 6); AddStroke(combatPlayerLabel, Theme.Outline, 1)

    local combatDropdownBtn = createButton(CombatFrame, "👇 Select Player", "Open the list to select a target.", Theme.Accent, function() end)
    local combatDropdownFrame = Instance.new("ScrollingFrame")
    combatDropdownFrame.Size, combatDropdownFrame.Visible, combatDropdownFrame.Parent, combatDropdownFrame.ScrollBarThickness = UDim2.new(0.96, 0, 0, 0), false, CombatFrame, 4

    local function updateCombatPlayerList()
        combatDropdownFrame:ClearAllChildren()
        local layout = Instance.new("UIListLayout", combatDropdownFrame)
        layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = layout.AbsoluteContentSize.Y
            combatDropdownFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            combatDropdownFrame.Size = UDim2.new(0.96, 0, 0, math.clamp(contentHeight, 0, 200))
        end)

        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player then
                local btn = Instance.new("TextButton")
                btn.Size, btn.BackgroundColor3, btn.Text, btn.Parent = UDim2.new(1, 0, 0, 45), Theme.ItemHover, "", combatDropdownFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                local avatar = Instance.new("ImageLabel", btn)
                avatar.Size, avatar.Position, avatar.BackgroundTransparency = UDim2.new(0, 35, 0, 35), UDim2.new(0, 5, 0, 5), 1
                Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
                task.spawn(function() pcall(function() avatar.Image = game.Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)

                local dNameLbl = Instance.new("TextLabel", btn)
                dNameLbl.Size, dNameLbl.Position, dNameLbl.BackgroundTransparency, dNameLbl.Text, dNameLbl.TextColor3, dNameLbl.Font, dNameLbl.TextSize, dNameLbl.TextXAlignment = UDim2.new(1, -50, 0, 15), UDim2.new(0, 45, 0, 5), 1, p.DisplayName, Theme.TextPrimary, Enum.Font.GothamBold, 13, Enum.TextXAlignment.Left

                local uNameLbl = Instance.new("TextLabel", btn)
                uNameLbl.Size, uNameLbl.Position, uNameLbl.BackgroundTransparency, uNameLbl.Text, uNameLbl.TextColor3, uNameLbl.Font, uNameLbl.TextSize, uNameLbl.TextXAlignment = UDim2.new(1, -50, 0, 12), UDim2.new(0, 45, 0, 22), 1, "@" .. p.Name, Theme.TextSecondary, Enum.Font.Gotham, 11, Enum.TextXAlignment.Left

                btn.MouseButton1Click:Connect(function()
                    combatSelectedPlayer, combatPlayerLabel.Text, combatDropdownFrame.Visible = p, "Target: " .. p.DisplayName, false
                end)
            end
        end
    end

    combatDropdownBtn.MouseButton1Click:Connect(function()
        combatDropdownFrame.Visible = not combatDropdownFrame.Visible
        if combatDropdownFrame.Visible then updateCombatPlayerList() end
    end)

    createSectionHeader(CombatFrame, "🌪️  FLING")
    createButton(CombatFrame, "🌪️ Fling Selected Player", "Teleport to and fling the selected target.", Theme.Red, function()
        if combatSelectedPlayer then
            task.spawn(function()
                local char = Player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local originalPos = root.CFrame; toggleFling(true); SendNotification("Flinging " .. combatSelectedPlayer.Name .. "...", Theme.Accent)
                    local t = 0
                    while t < 1 do if combatSelectedPlayer.Character and combatSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then root.CFrame = combatSelectedPlayer.Character.HumanoidRootPart.CFrame else break end; task.wait(0.05); t = t + 0.05 end
                    toggleFling(false); pcall(function() root.AssemblyLinearVelocity = Vector3.new(0,0,0) end); root.CFrame = originalPos; SendNotification("Finished Flinging", Theme.Green)
                end
            end)
        else SendNotification("Select a target first!", Theme.Red) end
    end)

    createButton(CombatFrame, "🌪️ Fling All Players", "Teleport to and fling everyone in the server.", Theme.Red, function()
        task.spawn(function()
            local char = Player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local originalPos = root.CFrame; toggleFling(true); SendNotification("Flinging All Players...", Theme.Accent)
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local t = 0
                        while t < 0.7 do if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then root.CFrame = p.Character.HumanoidRootPart.CFrame else break end; task.wait(0.05); t = t + 0.05 end
                    end
                end
                toggleFling(false); pcall(function() root.AssemblyLinearVelocity = Vector3.new(0,0,0) end); root.CFrame = originalPos; SendNotification("Finished Flinging Everyone", Theme.Green)
            end
        end)
    end)

    createToggleSwitch(CombatFrame, "🌪️ Fling", "Spin intensely to launch other players.", toggleFling)

    local _sfNoclipConn = nil
    local silentFlinging = false

    createToggleSwitch(CombatFrame, "👻 Silent Fling", "Flings nearby players — no visible spin, noclip enabled, character stays normal.", function(state)
        silentFlinging = state
        if _sfNoclipConn then _sfNoclipConn:Disconnect(); _sfNoclipConn = nil end

        if state then
            _sfNoclipConn = AddConnection(RunService.Stepped:Connect(function()
                local char = Player.Character
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end))

            SendNotification("Silent Fling ON!", Theme.Red)

            task.spawn(function()
                local movel = 0.1
                while silentFlinging do
                    RunService.Heartbeat:Wait()
                    local char = Player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")

                    if char and char.Parent and root and root.Parent then
                        local vel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)

                        RunService.RenderStepped:Wait()
                        if char and char.Parent and root and root.Parent then
                            root.AssemblyLinearVelocity = vel
                        end

                        RunService.Stepped:Wait()
                        if char and char.Parent and root and root.Parent then
                            root.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                end

                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                    pcall(function() root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end)
                end
            end)

        else
            local char = Player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            SendNotification("Silent Fling OFF!", Theme.Green)
        end
    end, false, true)

    killAuraEnabled, killAuraRange = false, 20

createSectionHeader(CombatFrame, "🛡️  DEFENSE & UTILITY")
    local autoLeaveEnabled, autoLeaveHP = false, 20
    createToggleSwitch(CombatFrame, "🚪 Auto Leave (Low HP)", "Instantly kicks you to save your bounty/stats if health drops too low.", function(state)
        autoLeaveEnabled = state
        if state then
            task.spawn(function()
                while autoLeaveEnabled do
                    local char = Player.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 and hum.Health <= autoLeaveHP then
                        Player:Kick("Phantom Auto Leave: Health dropped below " .. autoLeaveHP)
                    end
                    task.wait(0.2)
                end
            end)
        end
    end, false, true)
    createSlider(CombatFrame, "🚪 Auto Leave HP", "Health threshold to disconnect at.", 1, 100, 20, function(val) autoLeaveHP = val end)

    createSectionHeader(CombatFrame, "⚔️  AURA & AUTO")
    createToggleSwitch(CombatFrame, "☠️ Kill Aura", "Auto-flings players within a set range.", function(state)
        killAuraEnabled = state
        if state then
            task.spawn(function()
                while killAuraEnabled do
                    local char = Player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local closest, closestDist = nil, killAuraRange
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < closestDist then closest, closestDist = p, dist end
                            end
                        end
                        if closest then
                            local origCF = root.CFrame
                            toggleFling(true)
                            for i = 1, 10 do
                                if not killAuraEnabled then break end
                                if closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                                    root.CFrame = closest.Character.HumanoidRootPart.CFrame
                                end
                                task.wait(0.05)
                            end
                            toggleFling(false)
                            pcall(function() root.CFrame = origCF end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
            SendNotification("Kill Aura Enabled! Range: " .. killAuraRange, Theme.Red)
        else
            toggleFling(false)
            SendNotification("Kill Aura Disabled!", Theme.Green)
        end
    end, false, true)
    createSlider(CombatFrame, "📡 Kill Aura Range", "Distance for Kill Aura detection (studs).", 5, 100, 20, function(val) killAuraRange = val end)

    loopKillEnabled = false
    createToggleSwitch(CombatFrame, "🔁 Loop Kill", "Continuously flings the selected target.", function(state)
        loopKillEnabled = state
        if state then
            task.spawn(function()
                while loopKillEnabled do
                    if combatSelectedPlayer and combatSelectedPlayer.Character and combatSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local char = Player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local origCF = root.CFrame
                            toggleFling(true)
                            for i = 1, 10 do
                                if not loopKillEnabled then break end
                                if combatSelectedPlayer.Character and combatSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    root.CFrame = combatSelectedPlayer.Character.HumanoidRootPart.CFrame
                                end
                                task.wait(0.05)
                            end
                            toggleFling(false)
                            pcall(function() root.CFrame = origCF end)
                        end
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                    end
                end
            end)
            SendNotification("Loop Kill Started!", Theme.Red)
        else
            toggleFling(false)
            SendNotification("Loop Kill Stopped!", Theme.Green)
        end
    end, false, true)

    autoClickEnabled = false
    createToggleSwitch(CombatFrame, "🖱️ Auto Clicker", "Rapidly activates your equipped tool.", function(state)
        autoClickEnabled = state
        if state then
            task.spawn(function()
                while autoClickEnabled do
                    pcall(function()
                        local char = Player.Character
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end)
                    task.wait(0.07)
                end
            end)
            SendNotification("Auto Clicker Enabled!", Theme.Red)
        else
            SendNotification("Auto Clicker Disabled!", Theme.Green)
        end
    end, false, true)

    antiRagdollEnabled, antiRagdollConn = false, nil
    createToggleSwitch(CombatFrame, "🛡️ Anti-Ragdoll", "Prevents your character from ragdolling.", function(state)
        antiRagdollEnabled = state
        if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
        if state then
            local function applyAntiRagdoll(char)
                if not char then return end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                        pcall(function() v.Enabled = false end)
                    end
                end
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end
            if Player.Character then applyAntiRagdoll(Player.Character) end
            antiRagdollConn = AddConnection(Player.CharacterAdded:Connect(function(c) task.wait(0.1); applyAntiRagdoll(c) end))
            SendNotification("Anti-Ragdoll Enabled!", Theme.Green)
        else
            SendNotification("Anti-Ragdoll Disabled!", Theme.Red)
        end
    end, false, true)

    do
        local _reachVal = 0
        task.spawn(function()
            while true do
                if _reachVal > 0 then
                    pcall(function()
                        local char = Player.Character
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local s = _reachVal / 50 + 1
                                handle.Size = Vector3.new(s, s, s)
                            end
                        end
                    end)
                end
                task.wait(0.2)
            end
        end)
        createSlider(CombatFrame, "📏 Reach Extender", "Extend your tool's activation range.", 0, 500, 0, function(val)
            _reachVal = val
        end)
    end

    hitboxEnabled, hitboxSize, hitboxTransparency, cachedHitboxSize, hitboxRunning = false, 10, 0.5, Vector3.new(10, 10, 10), true
    AddConnection({ Connected = true, Disconnect = function() hitboxRunning = false end })

    task.spawn(function()
        while hitboxRunning do
            if hitboxEnabled then for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then local hrp = v.Character.HumanoidRootPart; if hrp.Size ~= cachedHitboxSize then hrp.Size, hrp.Transparency, hrp.CanCollide = cachedHitboxSize, hitboxTransparency, false end end end end
            task.wait(1)
        end
    end)

    createSectionHeader(CombatFrame, "📦  HITBOX & REACH")
    createToggleSwitch(CombatFrame, "🎯 Enable Hitbox Expander", "Enlarges player hitboxes for easier aiming.", function(state) hitboxEnabled = state; if not state then for _, v in pairs(game.Players:GetPlayers()) do if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then local hrp = v.Character.HumanoidRootPart; hrp.Size, hrp.Transparency, hrp.CanCollide = Vector3.new(2, 2, 1), 1, true end end end end)
    createSlider(CombatFrame, "📏 Hitbox Size", "Adjust the radius of the hitbox expansion.", 2, 50, 10, function(val) hitboxSize = val; cachedHitboxSize = Vector3.new(val, val, val) end)
    createSlider(CombatFrame, "👻 Transparency (Div 10)", "Adjust visual transparency of hitboxes.", 0, 10, 5, function(val) hitboxTransparency = val / 10 end)
    local visualizeHitbox = false
    createToggleSwitch(CombatFrame, "📦 Visualize Hitboxes", "Draws a visible selection box around expanded hitboxes.", function(state)
        visualizeHitbox = state
        if not state then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local box = v.Character.HumanoidRootPart:FindFirstChild("Phantom_Hitbox_Vis")
                    if box then box:Destroy() end
                end
            end
        end
        task.spawn(function()
            while visualizeHitbox do
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = v.Character.HumanoidRootPart
                        local box = hrp:FindFirstChild("Phantom_Hitbox_Vis")
                        if not box then
                            box = Instance.new("SelectionBox")
                            box.Name = "Phantom_Hitbox_Vis"
                            box.Adornee = hrp
                            box.Color3 = Theme.Red
                            box.LineThickness = 0.05
                            box.Transparency = 0.5
                            box.Parent = hrp
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end, false, true)

    local antiStunEnabled = false
    local antiStunConn = nil
    createToggleSwitch(CombatFrame, "🛡️ Anti-Stun / Anti-Slow", "Prevents the game from freezing or slowing your walkspeed.", function(state)
        antiStunEnabled = state
        if antiStunConn then antiStunConn:Disconnect(); antiStunConn = nil end
        if state then
            antiStunConn = AddConnection(RunService.Heartbeat:Connect(function()
                local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
                if hum then
                    if hum.WalkSpeed < 16 then hum.WalkSpeed = currentSpeed or 16 end
                    if hum.PlatformStand then hum.PlatformStand = false end
                end
            end))
        end
    end, false, true)

    local desyncEnabled = false
    local desyncConn = nil
    createToggleSwitch(CombatFrame, "🌀 Desync / Anti-Aim", "Glitches your hitbox locally making it hard for others to hit you.", function(state)
        desyncEnabled = state
        if desyncConn then desyncConn:Disconnect(); desyncConn = nil end
        if state then
            desyncConn = AddConnection(RunService.Heartbeat:Connect(function()
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local origVel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500))
                    RunService.RenderStepped:Wait()
                    root.AssemblyLinearVelocity = origVel
                end
            end))
            SendNotification("Desync Enabled!", Theme.Red)
        else
            SendNotification("Desync Disabled!", Theme.Green)
        end
    end, false, true)

    createSectionHeader(CombatFrame, "🎯  AIMLOCK")
    createToggleSwitch(CombatFrame, "🎯 Aimlock", "Locks your camera onto the selected combat target.", function(state)
        V6S.aimlockEnabled = state
        if V6S.aimlockConn then V6S.aimlockConn:Disconnect(); V6S.aimlockConn = nil end
        if state then
            V6S.aimlockConn = AddConnection(RunService.RenderStepped:Connect(function()
                if not V6S.aimlockEnabled then return end
                local target = combatSelectedPlayer
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                    local cam = workspace.CurrentCamera
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local camPos = cam.CFrame.Position
                    cam.CFrame = CFrame.new(camPos, targetPos)
                end
            end))
            SendNotification("Aimlock ON — Select a target in Combat tab!", Theme.Accent)
        else
            SendNotification("Aimlock Disabled!", Theme.Red)
        end
    end, false, true)

    createSectionHeader(CombatFrame, "🔙  STEALTH TP")
    createButton(CombatFrame, "🔙 Teleport Behind Player", "Silently teleport directly behind the selected target.", Theme.Red, function() if combatSelectedPlayer and combatSelectedPlayer.Character and combatSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then local behindCF=combatSelectedPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3.5); local myChar=Player.Character; if myChar then pcall(function()myChar:SetPrimaryPartCFrame(behindCF)end); SendNotification("Teleported behind "..combatSelectedPlayer.Name,Theme.Green) end else SendNotification("Select a target first!",Theme.Red) end end)

    createSectionHeader(CombatFrame, "🔒  FREEZE")
    createToggleSwitch(CombatFrame, "🔒 Freeze All Players (Client)", "Freeze all other players' characters locally.", function(state) V6S.freezeAllEnabled=state; for _,p in pairs(game.Players:GetPlayers()) do if p~=Player and p.Character then for _,part in pairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then pcall(function()part.Anchored=state end) end end end end; SendNotification(state and "All Players Frozen (Client)!" or "Players Unfrozen!",state and Theme.Red or Theme.Green) end, false, true)

    flyEnabled, flySpeed, flyBodyGyro, flyBodyVel, MenuFlySwitch = false, Settings.FlightSpeed or 3

    local function stopFly()
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if Player.Character then
            local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then if root:FindFirstChild("Phantom_BodyGyro") then root.Phantom_BodyGyro:Destroy() end; if root:FindFirstChild("Phantom_BodyVel") then root.Phantom_BodyVel:Destroy() end end
            local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end

    local function startFly()
        stopFly()
        local char = Player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
        if not root or not hum then return end
        hum.PlatformStand = true
        flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.Name, flyBodyGyro.P, flyBodyGyro.maxTorque, flyBodyGyro.CFrame, flyBodyGyro.Parent = "Phantom_BodyGyro", 9e4, Vector3.new(9e9, 9e9, 9e9), root.CFrame, root
        flyBodyVel = Instance.new("BodyVelocity"); flyBodyVel.Name, flyBodyVel.Velocity, flyBodyVel.MaxForce, flyBodyVel.Parent = "Phantom_BodyVel", Vector3.new(0, 0, 0), Vector3.new(9e9, 9e9, 9e9), root
        task.spawn(function()
            while flyEnabled and char and hum.Parent and hum.Health > 0 do
                local cam = workspace.CurrentCamera; local moveDir = hum.MoveDirection; flyBodyGyro.CFrame = cam.CFrame
                if moveDir.Magnitude > 0 then local camCFrame = cam.CFrame; local moveRel = camCFrame:VectorToObjectSpace(moveDir); local newVel = (camCFrame.LookVector * -moveRel.Z) + (camCFrame.RightVector * moveRel.X); if newVel.Magnitude > 0 then newVel = newVel.Unit end; flyBodyVel.Velocity = newVel * flySpeed * 50 else flyBodyVel.Velocity = Vector3.new(0, 0, 0) end
                task.wait()
            end; stopFly()
        end)
    end

    local function toggleFlyFunc(state) flyEnabled = state; local targetColor = state and Theme.Green or Theme.Accent; QuickFlyBtn.TextColor3, QuickFlyStroke.Color = targetColor, targetColor; if MenuFlySwitch then MenuFlySwitch:SetState(state) end; if state then startFly() else stopFly() end end
    QuickFlyBtn.MouseButton1Click:Connect(function() toggleFlyFunc(not flyEnabled) end)
    local function onCharacterAdded(char) local humanoid = char:WaitForChild("Humanoid"); AddConnection(humanoid.Died:Connect(function() if flyEnabled then toggleFlyFunc(false) end end)) end
    if Player.Character then onCharacterAdded(Player.Character) end; AddConnection(Player.CharacterAdded:Connect(onCharacterAdded))

    createSectionHeader(MovementFrame, "✈️  FLIGHT")
    MenuFlySwitch = createToggleSwitch(MovementFrame, "🛸 Enable Fly", "Toggle flight mode to move freely in the air.", function(state) if state ~= flyEnabled then toggleFlyFunc(state) end end, true, false)
    createSlider(MovementFrame, "⚡ Flight Speed", "Control how fast you fly.", 1, 50, 3, function(val) flySpeed, Settings.FlightSpeed = val, val end)
    createToggleSwitch(MovementFrame, "🔲 Show Quick Fly Button", "Toggle the visibility of the HUD fly button.", function(state) QuickFlyBtn.Visible = state end)

    vflyEnabled, vflySpeed, vflyBodyGyro, vflyBodyVel, MenuVFlySwitch, vflyInputBegan, vflyInputEnded = false, Settings.VFlightSpeed or 3

    local function stopVFly()
        if vflyBodyGyro then vflyBodyGyro:Destroy(); vflyBodyGyro = nil end
        if vflyBodyVel then vflyBodyVel:Destroy(); vflyBodyVel = nil end
        if vflyInputBegan then vflyInputBegan:Disconnect(); vflyInputBegan = nil end
        if vflyInputEnded then vflyInputEnded:Disconnect(); vflyInputEnded = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then local hum = Player.Character.Humanoid; if hum.SeatPart then local vehicle = hum.SeatPart:FindFirstAncestorWhichIsA("Model"); local target = vehicle and vehicle.PrimaryPart or hum.SeatPart; if target:FindFirstChild("Phantom_VBodyGyro") then target.Phantom_VBodyGyro:Destroy() end; if target:FindFirstChild("Phantom_VBodyVel") then target.Phantom_VBodyVel:Destroy() end end end
    end

    local function startVFly()
        stopVFly(); local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid")
        if not hum or not hum.SeatPart then SendNotification("🚫 You must sit in a vehicle to use VFly!", Theme.Red); vflyEnabled = false; if MenuVFlySwitch then MenuVFlySwitch:SetState(false) end; QuickVFlyBtn.TextColor3, QuickVFlyStroke.Color = Theme.Accent, Theme.Accent; return end
        local targetPart = hum.SeatPart:FindFirstAncestorWhichIsA("Model") and hum.SeatPart:FindFirstAncestorWhichIsA("Model").PrimaryPart or hum.SeatPart
        vflyBodyGyro = Instance.new("BodyGyro"); vflyBodyGyro.Name, vflyBodyGyro.P, vflyBodyGyro.maxTorque, vflyBodyGyro.CFrame, vflyBodyGyro.Parent = "Phantom_VBodyGyro", 9e4, Vector3.new(9e9, 9e9, 9e9), targetPart.CFrame, targetPart
        vflyBodyVel = Instance.new("BodyVelocity"); vflyBodyVel.Name, vflyBodyVel.Velocity, vflyBodyVel.MaxForce, vflyBodyVel.Parent = "Phantom_VBodyVel", Vector3.new(0, 0, 0), Vector3.new(9e9, 9e9, 9e9), targetPart
        task.spawn(function()
            while vflyEnabled and char and hum.Parent and hum.Health > 0 do
                if not hum.SeatPart then SendNotification("Exited vehicle. VFly automatically disabled.", Theme.Yellow); vflyEnabled = false; if MenuVFlySwitch then MenuVFlySwitch:SetState(false) end; QuickVFlyBtn.TextColor3, QuickVFlyStroke.Color = Theme.Accent, Theme.Accent; stopVFly(); break end
                local cam = workspace.CurrentCamera; vflyBodyGyro.CFrame = cam.CFrame; local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then local camCFrame = cam.CFrame; local moveRel = camCFrame:VectorToObjectSpace(moveDir); local newVel = (camCFrame.LookVector * -moveRel.Z) + (camCFrame.RightVector * moveRel.X); if newVel.Magnitude > 0 then newVel = newVel.Unit end; vflyBodyVel.Velocity = newVel * (vflySpeed * 50) else vflyBodyVel.Velocity = Vector3.new(0, 0, 0) end
                task.wait()
            end; stopVFly()
        end)
    end

    local function toggleVFlyFunc(state) vflyEnabled = state; local targetColor = state and Theme.Green or Theme.Accent; QuickVFlyBtn.TextColor3, QuickVFlyStroke.Color = targetColor, targetColor; if MenuVFlySwitch then MenuVFlySwitch:SetState(state) end; if state then startVFly() else stopVFly() end end
    QuickVFlyBtn.MouseButton1Click:Connect(function() toggleVFlyFunc(not vflyEnabled) end)
    MenuVFlySwitch = createToggleSwitch(MovementFrame, "🚁 Enable Vehicle Fly", "Toggle flight mode while seated in a vehicle.", function(state) if state ~= vflyEnabled then toggleVFlyFunc(state) end end, true, false)
    createSlider(MovementFrame, "🏎️ VFly Speed", "Control how fast your vehicle flies.", 1, 50, 3, function(val) vflySpeed, Settings.VFlightSpeed = val, val end)
    createToggleSwitch(MovementFrame, "🔲 Show Quick VFly Button", "Toggle the visibility of the HUD VFly button.", function(state) QuickVFlyBtn.Visible = state end)

    dashPower = Settings.DashPower or 100

    local function performDash()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local camDir = workspace.CurrentCamera.CFrame.LookVector
            pcall(function() root.AssemblyLinearVelocity = camDir * dashPower end)
        end
    end

    QuickDashBtn.MouseButton1Click:Connect(performDash)

    AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Q then
            performDash()
        end
    end))

    createSlider(MovementFrame, "⚡ Dash Power", "How far you get launched when dashing.", 50, 500, dashPower, function(val)
        dashPower = val
        Settings.DashPower = val
        saveSettings()
    end)

    createToggleSwitch(MovementFrame, "🔲 Show Quick Dash Button", "Toggle the visibility of the HUD dash button.", function(state)
        QuickDashBtn.Visible = state
    end)

    createButton(MovementFrame, "💨 Dash Forward (Press Q)", "Instantly launches your character forward.", Theme.Accent, function()
        performDash()
    end)

    speedEnabled, jumpEnabled, currentSpeed, currentJump = false, false, Settings["💨 Speed Value"] or 16, Settings["⏫ Jump Value"] or 20
    local function UpdateMovement() if Player.Character and Player.Character:FindFirstChild("Humanoid") then local hum = Player.Character.Humanoid; if speedEnabled then hum.WalkSpeed = currentSpeed else hum.WalkSpeed = _G.DefaultWalkSpeed or 16 end; if jumpEnabled then hum.UseJumpPower, hum.JumpPower = true, currentJump * 5 else hum.JumpPower = _G.DefaultJumpPower or 50 end end end
    createSectionHeader(MovementFrame, "🏃  GROUND MOVEMENT")
    createToggleSwitch(MovementFrame, "💨 Speed Boost", "Enable faster walking speed.", function(state) speedEnabled = state; UpdateMovement() end)
    createSlider(MovementFrame, "💨 Speed Value", "Adjust your walking speed multiplier.", 16, 250, 16, function(val) currentSpeed = val; UpdateMovement() end)

    do
        local _swimSpeed = 16
        local _swimRunning = true
        AddConnection({Connected=true, Disconnect=function() _swimRunning=false end})
        task.spawn(function()
            while _swimRunning do
                pcall(function()
                    local char = Player.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                        hum.WalkSpeed = _swimSpeed
                    end
                end)
                task.wait(0.1)
            end
        end)
        createSlider(MovementFrame, "🏊 Swim Speed", "Adjust movement speed while swimming.", 1, 100, 16, function(val)
            _swimSpeed = val
        end)
    end

    createToggleSwitch(MovementFrame, "🦗 Jump Boost", "Enable higher jumping power.", function(state) jumpEnabled = state; UpdateMovement() end)
    createSlider(MovementFrame, "⏫ Jump Value", "Adjust your jump height multiplier.", 16, 250, 20, function(val) currentJump = val; UpdateMovement() end)
    AddConnection(Player.CharacterAdded:Connect(function() task.wait(0.5); UpdateMovement() end))

    gravityEnabled, currentGravity = false, math.floor(_G.OriginalGravity or 196.2)
    createSectionHeader(MovementFrame, "🌍  GRAVITY & PHYSICS")
    createToggleSwitch(MovementFrame, "🌌 Custom Gravity", "Enable to override the game's default gravity.", function(state) gravityEnabled = state; workspace.Gravity = state and currentGravity or (_G.OriginalGravity or 196.2) end)
    createSlider(MovementFrame, "📉 Gravity Value", "Adjust the world gravity.", 0, 500, math.floor(_G.OriginalGravity or 196.2), function(val) currentGravity = val; if gravityEnabled then workspace.Gravity = val end end)

    noclipEnabled, MenuNoclipSwitch, NoclipConnection = false, nil, nil
    local function NoclipLoop() if Player.Character then for _, child in pairs(Player.Character:GetDescendants()) do if child:IsA("BasePart") and child.CanCollide == true then child.CanCollide = false end end end end
    local function toggleNoclipFunc(state) noclipEnabled = state; local targetColor = state and Theme.Green or Theme.Accent; QuickNoclipBtn.TextColor3, QuickNoclipStroke.Color = targetColor, targetColor; if MenuNoclipSwitch then MenuNoclipSwitch:SetState(state) end; if state then NoclipConnection = AddConnection(RunService.Stepped:Connect(NoclipLoop)) else if NoclipConnection then NoclipConnection:Disconnect(); NoclipConnection = nil end; if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end end end
    QuickNoclipBtn.MouseButton1Click:Connect(function() toggleNoclipFunc(not noclipEnabled) end)
    createSectionHeader(MovementFrame, "🔮  ADVANCED MOVEMENT")

    local fastLadderEnabled, ladderSpeed = false, 50
    local fastLadderConn = nil
    createToggleSwitch(MovementFrame, "🧗 Fast Ladder", "Climb ladders extremely fast.", function(state)
        fastLadderEnabled = state
        if fastLadderConn then fastLadderConn:Disconnect(); fastLadderConn = nil end
        if state then
            fastLadderConn = AddConnection(RunService.Heartbeat:Connect(function()
                local char = Player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum:GetState() == Enum.HumanoidStateType.Climbing then
                    root.AssemblyLinearVelocity = Vector3.new(0, ladderSpeed, 0)
                end
            end))
        end
    end, false, true)

    createSlider(MovementFrame, "⚡ Ladder Speed", "Adjust climbing speed.", 20, 200, 50, function(val) ladderSpeed = val end)
    local vehicleSpeedEnabled, vSpeedMultiplier = false, 2
    local vSpeedConn = nil
    createToggleSwitch(MovementFrame, "🏎️ Vehicle Speed Modifier", "Boost the speed of the vehicle you are driving.", function(state)
        vehicleSpeedEnabled = state
        if vSpeedConn then vSpeedConn:Disconnect(); vSpeedConn = nil end
        if state then
            vSpeedConn = AddConnection(RunService.Heartbeat:Connect(function()
                local char = Player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                    hum.SeatPart.AssemblyLinearVelocity = hum.SeatPart.CFrame.LookVector * (hum.SeatPart.MaxSpeed * vSpeedMultiplier)
                end
            end))
        end
    end, false, true)
    createSlider(MovementFrame, "🏎️ Vehicle Speed Multiplier", "Adjust how much faster the car goes.", 1, 10, 2, function(val) vSpeedMultiplier = val end)

    MenuNoclipSwitch = createToggleSwitch(MovementFrame, "👻 Noclip (Ghost Mode)", "Walk through walls and obstacles.", function(state) if state ~= noclipEnabled then toggleNoclipFunc(state) end end, true, false)
    createToggleSwitch(MovementFrame, "🔲 Show Quick Noclip", "Toggle HUD noclip button visibility.", function(state) QuickNoclipBtn.Visible = state end)
    createToggleSwitch(MovementFrame, "🔲 Show Quick Sit Button", "Toggle HUD sit button visibility.", function(state) QuickSitBtn.Visible = state end)
    createToggleSwitch(MovementFrame, "♾️ Infinite Jump", "Jump indefinitely in mid-air.", function(state) _G.InfJump = state end)
    freezeEnabled, MenuFreezeSwitch = false, nil
    local function toggleFreezeFunc(state)
        freezeEnabled = state
        local targetColor = state and Theme.Green or Theme.Accent
        QuickFreezeBtn.TextColor3, QuickFreezeStroke.Color = targetColor, targetColor
        if MenuFreezeSwitch then MenuFreezeSwitch:SetState(state) end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Anchored = state
        end
    end

    QuickFreezeBtn.MouseButton1Click:Connect(function() toggleFreezeFunc(not freezeEnabled) end)

    MenuFreezeSwitch = createToggleSwitch(MovementFrame, "🧊 Freeze Position", "Locks your character in place safely.", function(state)
        if state ~= freezeEnabled then toggleFreezeFunc(state) end
    end, true, false)

    createToggleSwitch(MovementFrame, "🔲 Show Quick Freeze Button", "Toggle HUD freeze button visibility.", function(state)
        QuickFreezeBtn.Visible = state
    end)
    local function onFreezeCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid")
        AddConnection(humanoid.Died:Connect(function()
            if freezeEnabled then
                toggleFreezeFunc(false)
            end
        end))
    end

    if Player.Character then onFreezeCharacterAdded(Player.Character) end
    AddConnection(Player.CharacterAdded:Connect(onFreezeCharacterAdded))

    do
        local _ragdollOn = false
        local _ragdollConn = nil
        local function _applyRagdoll(char)
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = _ragdollOn end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                    pcall(function() v.Enabled = _ragdollOn end)
                end
            end
        end
        createToggleSwitch(MovementFrame, "🪆 Ragdoll Mode", "Toggle ragdoll physics. Persists on respawn.", function(state)
            _ragdollOn = state
            if _ragdollConn then _ragdollConn:Disconnect(); _ragdollConn = nil end
            _applyRagdoll(Player.Character)
            if state then
                _ragdollConn = AddConnection(Player.CharacterAdded:Connect(function(c) task.wait(0.3); _applyRagdoll(c) end))
                SendNotification("Ragdoll Mode Enabled!", Theme.Red)
            else
                SendNotification("Ragdoll Mode Disabled!", Theme.Green)
            end
        end, false, true)
    end

    createSectionHeader(MovementFrame, "🛠️  TOOLS")
local skywalkEnabled, skywalkPart = false, nil
    createToggleSwitch(MovementFrame, "☁️ Walk on Air (Skywalk)", "Creates an invisible platform under your feet.", function(state)
        skywalkEnabled = state
        if state then
            skywalkPart = Instance.new("Part")
            skywalkPart.Size = Vector3.new(10, 1, 10)
            skywalkPart.Transparency = 0.5
            skywalkPart.Material = Enum.Material.Glass
            skywalkPart.Color = Theme.Accent
            skywalkPart.Anchored = true
            skywalkPart.CanQuery = false
            skywalkPart.CastShadow = false
            skywalkPart.Parent = workspace
            task.spawn(function()
                while skywalkEnabled and skywalkPart do
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        skywalkPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.5, 0))
                    end
                    task.wait()
                end
            end)
        else
            if skywalkPart then skywalkPart:Destroy(); skywalkPart = nil end
        end
    end, false, true)

    local antiVoidEnabled, antiVoidY = false, -50
    createToggleSwitch(MovementFrame, "🛡️ Anti-Void", "Teleports you back up if you fall off the map.", function(state)
        antiVoidEnabled = state
        if state then
            task.spawn(function()
                while antiVoidEnabled do
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y < antiVoidY then
                        pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, math.abs(antiVoidY) + 50, 0) end)
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                        pcall(function() hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end)
                        SendNotification("Anti-Void: Saved you from falling!", Theme.Green)
                    end
                    task.wait(0.2)
                end
            end)
        end
    end, false, true)
    createSlider(MovementFrame, "📏 Anti-Void Y-Level", "Y-level to trigger teleport.", -500, 0, -50, function(val) antiVoidY = val end)

    local noSitEnabled, noSitConn = false, nil
    createToggleSwitch(MovementFrame, "🪑 No Sit", "Prevents your character from being forced into seats.", function(state)
        noSitEnabled = state
        if noSitConn then noSitConn:Disconnect(); noSitConn = nil end
        if state then
            noSitConn = AddConnection(RunService.Heartbeat:Connect(function()
                local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
                if hum and hum.Sit then hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end))
        end
    end, false, true)

    createButton(MovementFrame, "🔨 Get Btools (Local)", "Gives you classic building tools (Clone, Delete, Move).", Theme.Accent, function()
        local bp = Player:FindFirstChildOfClass("Backpack")
        if bp then
            for i = 1, 4 do
                local t = Instance.new("HopperBin")
                t.BinType = i
                t.Parent = bp
            end
            SendNotification("Btools added to inventory!", Theme.Green)
        end
    end)

    createButton(MovementFrame, "🗑️ Click Delete Tool", "Gives a tool to instantly delete clicked parts locally.", Theme.Red, function()
        local bp = Player:FindFirstChildOfClass("Backpack")
        if bp then
            local delTool = Instance.new("Tool")
            delTool.Name = "Delete Tool"
            delTool.RequiresHandle = false
            delTool.Parent = bp
            delTool.Activated:Connect(function()
                local mouse = Player:GetMouse()
                if mouse.Target then mouse.Target:Destroy() end
            end)
            SendNotification("Delete Tool added to inventory!", Theme.Green)
        end
    end)

    createButton(MovementFrame, "🪄 TP Tool", "Equips a tool to teleport where you click.", Color3.fromRGB(150, 50, 255), function()
        local toolName, backpack, char = "Teleport Tool", Player:FindFirstChildOfClass("Backpack"), Player.Character
        if (backpack and backpack:FindFirstChild(toolName)) or (char and char:FindFirstChild(toolName)) then SendNotification("You already have the TP Tool!", Theme.Red) return end
        local tool = Instance.new("Tool"); tool.Name, tool.RequiresHandle, tool.Parent = toolName, false, backpack
        tool.Activated:Connect(function() local r, m = char and char:FindFirstChild("HumanoidRootPart"), Player:GetMouse(); if r and m and m.Hit then r.CFrame = CFrame.new(m.Hit.X, m.Hit.Y + 3, m.Hit.Z, select(4, r.CFrame:components())); local V3 = Vector3.new(0, 0, 0); pcall(function() for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.AssemblyLinearVelocity, v.AssemblyAngularVelocity = V3, V3 end end end) end end)
        SendNotification("TP Tool Added!", Theme.Green)
    end)

    createButton(MovementFrame, "💦 Jerk Tool", "Equips a special tool in your inventory.", Color3.fromRGB(150, 50, 255), function()
        local char = Player.Character
        local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
        local backpack = Player:FindFirstChildWhichIsA("Backpack")

        if not humanoid or not backpack then
            SendNotification("Humanoid or Backpack not found!", Theme.Red)
            return
        end
        if backpack:FindFirstChild("Jerk Off") or (char and char:FindFirstChild("Jerk Off")) then
            SendNotification("You already have the Jerk Tool!", Theme.Yellow)
            return
        end

        local tool = Instance.new("Tool")
        tool.Name = "Jerk Off"
        tool.ToolTip = "Jerk Off In Front Of Girls (:"
        tool.RequiresHandle = false
        tool.Parent = backpack

        local jorkin = false
        local track = nil

        local function stopTomfoolery()
            jorkin = false
            if track then
                track:Stop()
                track = nil
            end
        end

        tool.Equipped:Connect(function() jorkin = true end)
        tool.Unequipped:Connect(stopTomfoolery)
        humanoid.Died:Connect(stopTomfoolery)

        task.spawn(function()
            while tool and tool.Parent do
                task.wait()
                if not jorkin then continue end

                local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
                if not track then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                    track = animator:LoadAnimation(anim)
                end

                track:Play()
                track:AdjustSpeed(isR15 and 0.7 or 0.65)
                track.TimePosition = 0.6

                task.wait(0.1)
                while track and track.TimePosition < (not isR15 and 0.65 or 0.7) and jorkin do
                    task.wait(0.1)
                end

                if track then
                    track:Stop()
                    track = nil
                end
            end
            stopTomfoolery()
        end)

        SendNotification("Jerk Tool Added!", Theme.Green)
    end)

    AddConnection(UserInputService.JumpRequest:Connect(function() if _G.InfJump and Player.Character then local _hum = Player.Character:FindFirstChildOfClass('Humanoid'); if _hum then _hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

    createButton(MovementFrame, "🌕 Moon Gravity", "Sets gravity to moon-like low value instantly.", Color3.fromRGB(150, 50, 255), function()
        workspace.Gravity = 30
        SendNotification("Moon Gravity Applied! (30)", Theme.Green)
    end)
    createButton(MovementFrame, "🌍 Reset Gravity", "Restores gravity to default (196.2).", Theme.Yellow, function()
        workspace.Gravity = _G.OriginalGravity or 196.2
        SendNotification("Gravity Restored!", Theme.Green)
    end)

    selectedPos, refreshPositionList = nil, nil
    createSectionHeader(PositionsFrame, "📍  SAVE POSITIONS")
    local posNameBox = createTextBox(PositionsFrame, "Position Name...", "Enter a name for the current location.", function() end)
    local posDropdownFrame, posLabel = Instance.new("ScrollingFrame"), Instance.new("TextLabel")
    local function getGamePositions() local gid = tostring(game.PlaceId); if not PositionsData[gid] then PositionsData[gid] = {} end; return PositionsData[gid] end

    createButton(PositionsFrame, "💾 Save Current Position", "Save your current coordinates to the list.", Theme.Green, function()
        if posNameBox.Text ~= "" then
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then local positions = getGamePositions(); table.insert(positions, { Name = posNameBox.Text, X = root.Position.X, Y = root.Position.Y, Z = root.Position.Z }); PositionsData[tostring(game.PlaceId)] = positions; savePositions(); posNameBox.Text = ""; if refreshPositionList then refreshPositionList() end; SendNotification("Position Saved!", Theme.Green) end
        else SendNotification("Enter a name first!", Theme.Red) end
    end)

    local posDropdownBtn = createButton(PositionsFrame, "👇 Select Position", "Open the list of saved positions.", Theme.Accent, function() if refreshPositionList then refreshPositionList() end; posDropdownFrame.Visible = not posDropdownFrame.Visible end)
    posDropdownFrame.Size, posDropdownFrame.Visible, posDropdownFrame.Parent = UDim2.new(0.96, 0, 0, 150), false, PositionsFrame; createLayout(posDropdownFrame)
    posLabel.Text, posLabel.Size, posLabel.BackgroundColor3, posLabel.TextColor3, posLabel.Parent = "Selected: None", UDim2.new(0.96, 0, 0, 30), Theme.ContentBg, Theme.Accent, PositionsFrame
    Instance.new("UICorner", posLabel).CornerRadius = UDim.new(0, 6); AddStroke(posLabel, Theme.Outline, 1)

    function refreshPositionList()
        posDropdownFrame:ClearAllChildren(); createLayout(posDropdownFrame)
        for _, pos in ipairs(getGamePositions()) do
            local btn = Instance.new("TextButton"); btn.Size, btn.Text, btn.BackgroundColor3, btn.TextColor3, btn.Parent = UDim2.new(1, 0, 0, 25), pos.Name, Theme.ItemHover, Theme.TextPrimary, posDropdownFrame
            btn.MouseButton1Click:Connect(function() selectedPos, posLabel.Text, posDropdownFrame.Visible = pos, "Selected: " .. pos.Name, false end)
        end
    end

    createSectionHeader(PositionsFrame, "🚀  NAVIGATE")
    createButton(PositionsFrame, "🌀 Teleport to Position", "Instantly teleport to the selected location.", Theme.Accent, function() if selectedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then Player.Character:SetPrimaryPartCFrame(CFrame.new(selectedPos.X, selectedPos.Y, selectedPos.Z)) else SendNotification("Select a position first!", Theme.Red) end end)
    createButton(PositionsFrame, "🦅 Tween to Position", "Fly smoothly to the selected location.", Theme.Yellow, function() if selectedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then local root = Player.Character.HumanoidRootPart; local tween = TweenService:Create(root, TweenInfo.new((root.Position - CFrame.new(selectedPos.X, selectedPos.Y, selectedPos.Z).Position).Magnitude / ((Settings.FlightSpeed or 3) * 50), Enum.EasingStyle.Linear), {CFrame = CFrame.new(selectedPos.X, selectedPos.Y, selectedPos.Z)}); local oldGrav = workspace.Gravity; workspace.Gravity = 0; tween:Play(); tween.Completed:Connect(function() workspace.Gravity = oldGrav end)
                local _gravCharConn; _gravCharConn = Player.CharacterAdded:Connect(function() workspace.Gravity = oldGrav; _gravCharConn:Disconnect() end) else SendNotification("Select a position first!", Theme.Red) end end)
    createButton(PositionsFrame, "🚶 Walk to Position", "Pathfind/Walk to the selected location.", Color3.fromRGB(150, 50, 255), function() if selectedPos and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid:MoveTo(Vector3.new(selectedPos.X, selectedPos.Y, selectedPos.Z)) else SendNotification("Select a position first!", Theme.Red) end end)
    createButton(PositionsFrame, "🗑️ Delete Position", "Remove the selected position from the list.", Theme.Red, function() if selectedPos then local positions = getGamePositions(); for i, pos in ipairs(positions) do if pos == selectedPos then table.remove(positions, i) break end end; PositionsData[tostring(game.PlaceId)] = positions; savePositions(); selectedPos, posLabel.Text = nil, "Selected: None"; if refreshPositionList then refreshPositionList() end; SendNotification("Position Deleted!", Theme.Red) else SendNotification("Select a position first!", Theme.Red) end end)

    local ESPSettings = { Enabled = false, Boxes = false, ShowName = false, ShowDistance = false, ShowHealth = false, HealthBar = false, ShowTool = false, EnableHighlight = false, SeeThrough = false, Skeleton = false, TeamCheck = false, Color = Color3.fromRGB(V6S.espColorR,V6S.espColorG,V6S.espColorB) }
    local R15Bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}}
    local R6Bones = {{"Head", "Torso"}, {"Torso", "Right Arm"}, {"Torso", "Left Arm"}, {"Torso", "Right Leg"}, {"Torso", "Left Leg"}}

    local function updateAdvancedESP()
        if not ESPSettings.Enabled then return end
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player then
                local folderName = player.Name .. "_AdvESP"; local folder = ScreenGui:FindFirstChild(folderName)
                if not ESPSettings.Enabled or (ESPSettings.TeamCheck and player.Team == Player.Team and player.Team ~= nil) then if folder then folder:Destroy() end continue end
                if not folder then folder = Instance.new("Folder"); folder.Name, folder.Parent = folderName, ScreenGui end
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local root, hum = char.HumanoidRootPart, char.Humanoid
                    local hl = folder:FindFirstChild("Highlight")
                    if ESPSettings.EnableHighlight or ESPSettings.SeeThrough then
                        if not hl then hl = Instance.new("Highlight"); hl.Name, hl.Adornee, hl.Parent = "Highlight", char, folder end
                        hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.DepthMode = ESPSettings.Color, Color3.new(1,1,1), ESPSettings.EnableHighlight and 0.5 or 0.8, ESPSettings.SeeThrough and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    else if hl then hl:Destroy() end end

                    local boxBill = folder:FindFirstChild("BoxGui")
                    if ESPSettings.Boxes or ESPSettings.HealthBar then
                        if not boxBill then
                            boxBill = Instance.new("BillboardGui"); boxBill.Name, boxBill.AlwaysOnTop, boxBill.Size, boxBill.StudsOffset, boxBill.Adornee, boxBill.Parent = "BoxGui", true, UDim2.new(4.5, 0, 5.5, 0), Vector3.new(0, 0, 0), root, folder
                            local box = Instance.new("Frame", boxBill); box.Name, box.Size, box.Position, box.BackgroundTransparency = "Box", UDim2.new(0.85, 0, 1, 0), UDim2.new(0.15, 0, 0, 0), 1
                            local _bs=Instance.new("UIStroke",box); _bs.Name="Stroke"; _bs.Thickness=1.5
                            local hbBg = Instance.new("Frame", boxBill); hbBg.Name, hbBg.Size, hbBg.Position, hbBg.BackgroundColor3, hbBg.BorderSizePixel = "HealthBarBg", UDim2.new(0, 4, 1, 0), UDim2.new(0, 0, 0, 0), Color3.new(0, 0, 0), 0
                            local hbFill = Instance.new("Frame", hbBg); hbFill.Name, hbFill.Size, hbFill.AnchorPoint, hbFill.Position, hbFill.BackgroundColor3, hbFill.BorderSizePixel = "Fill", UDim2.new(1, 0, 1, 0), Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), Color3.new(0, 1, 0), 0
                        end
                        boxBill.Box.Visible = ESPSettings.Boxes; local _sc=boxBill.Box:FindFirstChild("Stroke"); if _sc then _sc.Color=ESPSettings.Color end
                        boxBill.HealthBarBg.Visible = ESPSettings.HealthBar; local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        boxBill.HealthBarBg.Fill.Size, boxBill.HealthBarBg.Fill.BackgroundColor3 = UDim2.new(1, 0, healthPct, 0), Color3.new(1 - healthPct, healthPct, 0)
                    else if boxBill then boxBill:Destroy() end end

                    local textBill = folder:FindFirstChild("TextGui")
                    if ESPSettings.ShowName or ESPSettings.ShowDistance or ESPSettings.ShowHealth or ESPSettings.ShowTool then
                        if not textBill then
                            textBill = Instance.new("BillboardGui"); textBill.Name, textBill.AlwaysOnTop, textBill.Size, textBill.StudsOffset, textBill.Adornee, textBill.Parent = "TextGui", true, UDim2.new(0, 200, 0, 50), Vector3.new(0, 3.5, 0), root, folder
                            local txt = Instance.new("TextLabel", textBill); txt.Name, txt.Size, txt.BackgroundTransparency, txt.Font, txt.TextSize, txt.TextStrokeTransparency, txt.TextColor3, txt.TextYAlignment = "InfoText", UDim2.new(1, 0, 1, 0), 1, Enum.Font.GothamBold, 12, 0.2, Theme.TextPrimary, Enum.TextYAlignment.Bottom
                        end
                        local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and math.floor((Player.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                        local tStr = (ESPSettings.ShowName and player.Name .. "\n" or "") .. (ESPSettings.ShowDistance and "[" .. dist .. "m] " or "") .. (ESPSettings.ShowHealth and "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " " or "")
                        if ESPSettings.ShowTool and char:FindFirstChildOfClass("Tool") then tStr = tStr .. "\n[" .. char:FindFirstChildOfClass("Tool").Name .. "]" end
                        textBill.InfoText.Text, textBill.InfoText.TextColor3 = tStr, ESPSettings.Color
                    else if textBill then textBill:Destroy() end end

                    local skeletonFolder = folder:FindFirstChild("SkeletonLines")
                    if ESPSettings.Skeleton then
                        if not skeletonFolder then skeletonFolder = Instance.new("Folder", folder); skeletonFolder.Name = "SkeletonLines" end
                        for i, bonePair in ipairs(hum.RigType == Enum.HumanoidRigType.R15 and R15Bones or R6Bones) do
                            local part1, part2 = char:FindFirstChild(bonePair[1]), char:FindFirstChild(bonePair[2])
                            local lineName = "Bone_" .. i; local line = skeletonFolder:FindFirstChild(lineName)
                            if not line then line = Instance.new("Frame"); line.Name, line.AnchorPoint, line.BorderSizePixel, line.Parent = lineName, Vector2.new(0.5, 0.5), 0, skeletonFolder end
                            if part1 and part2 then
                                local p1, vis1 = workspace.CurrentCamera:WorldToViewportPoint(part1.Position); local p2, vis2 = workspace.CurrentCamera:WorldToViewportPoint(part2.Position)
                                if vis1 and vis2 then line.Size, line.Position, line.Rotation, line.BackgroundColor3, line.Visible = UDim2.new(0, (Vector2.new(p1.X, p1.Y) - Vector2.new(p2.X, p2.Y)).Magnitude, 0, 1.5), UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2), math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X)), ESPSettings.Color, true else line.Visible = false end
                            else line.Visible = false end
                        end
                    else if skeletonFolder then skeletonFolder:Destroy() end end
                else if folder then folder:Destroy() end end
            end
        end
    end

    espLoopRunning = true; AddConnection({ Connected = true, Disconnect = function() espLoopRunning = false end })
    task.spawn(function() while espLoopRunning do if ESPSettings.Enabled then updateAdvancedESP() end; task.wait(0.1) end end)
    AddConnection(game.Players.PlayerRemoving:Connect(function(player) local folder = ScreenGui:FindFirstChild(player.Name .. "_AdvESP"); if folder then folder:Destroy() end end))

    createSectionHeader(ESPFrame, "⚙️  MASTER CONTROL")
    createToggleSwitch(ESPFrame, "👁️ Enable Master ESP", "Turn the entire ESP system on or off.", function(state) ESPSettings.Enabled = state; if not state then for _, child in pairs(ScreenGui:GetChildren()) do if child:IsA("Folder") and string.find(child.Name, "_AdvESP") then child:Destroy() end end end end)
    createSectionHeader(ESPFrame, "📊  DISPLAY OPTIONS")
    createToggleSwitch(ESPFrame, "📦 Show Boxes", "Draws a 2D box around the player.", function(state) ESPSettings.Boxes = state end)
    createToggleSwitch(ESPFrame, "🧱 See Through Walls", "See players clearly through any object.", function(state) ESPSettings.SeeThrough = state end)
    createToggleSwitch(ESPFrame, "💀 Show Skeleton", "Draws a stickman skeleton over players.", function(state) ESPSettings.Skeleton = state end)
    createToggleSwitch(ESPFrame, "🩸 Show Health Bar", "Display a dynamic health bar beside player.", function(state) ESPSettings.HealthBar = state end)
    createToggleSwitch(ESPFrame, "👤 Show Names", "Display player usernames above them.", function(state) ESPSettings.ShowName = state end)
    createToggleSwitch(ESPFrame, "📏 Show Distance", "Display distance in meters.", function(state) ESPSettings.ShowDistance = state end)
    createToggleSwitch(ESPFrame, "❤️ Show Health Text", "Display player current health.", function(state) ESPSettings.ShowHealth = state end)
    createToggleSwitch(ESPFrame, "🔫 Show Equipped Tool", "Show the item the player is holding.", function(state) ESPSettings.ShowTool = state end)
    createToggleSwitch(ESPFrame, "✨ Enable Highlights", "Show 3D body highlights.", function(state) ESPSettings.EnableHighlight = state end)
    createToggleSwitch(ESPFrame, "🛡️ Team Check", "Hide ESP for players on the same team.", function(state) ESPSettings.TeamCheck = state end)

    createSectionHeader(VisualsFrame, "🔦  FLASHLIGHT")
    do
        local _flashOn   = false
        local _flashPart = nil
        createToggleSwitch(VisualsFrame, "🔦 Flashlight Mode", "Attaches a bright SpotLight to your camera view direction.", function(state)
            _flashOn = state
            if _flashPart and _flashPart.Parent then _flashPart:Destroy(); _flashPart = nil end
            if state then
                _flashPart = Instance.new("SpotLight")
                _flashPart.Brightness = 10; _flashPart.Range = 60; _flashPart.Angle = 50
                _flashPart.Color = Color3.new(1, 1, 1)
                _flashPart.Face = Enum.NormalId.Front
                _flashPart.Parent = workspace.CurrentCamera
                SendNotification("Flashlight Mode ON!", Theme.Green)
            else
                SendNotification("Flashlight Mode OFF!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(VisualsFrame, "🎭  DISCO MODE")
    do
        local _discoConn = nil
        local _discoHue  = 0
        createToggleSwitch(VisualsFrame, "?? Disco Mode", "Flashes your character through rainbow colors rapidly.", function(state)
            if _discoConn then _discoConn:Disconnect(); _discoConn = nil end
            if state then
                _discoConn = AddConnection(RunService.Heartbeat:Connect(function()
                    _discoHue = (_discoHue + 0.04) % 1
                    local char = Player.Character
                    if char then
                        local col = Color3.fromHSV(_discoHue, 1, 1)
                        for _, p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then pcall(function() p.Color = col end) end
                        end
                        local root2 = char:FindFirstChild("HumanoidRootPart")
                        if root2 then
                            local lt = root2:FindFirstChild("Phantom_Disco") or Instance.new("PointLight", root2)
                            lt.Name = "Phantom_Disco"; lt.Brightness = 8; lt.Range = 20; lt.Color = col
                        end
                    end
                end))
                SendNotification("Disco Mode ON! 🎉", Theme.Green)
            else
                local root3 = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root3 then local dl = root3:FindFirstChild("Phantom_Disco"); if dl then dl:Destroy() end end
                SendNotification("Disco Mode OFF!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(VisualsFrame, "🎩  ACCESSORIES")
    do
        local _hideAccOn = false
        local _hideAccConn = nil
        local function _applyHideAcc(char, st)
            if not char then return end
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Accessory") then
                    local h = v:FindFirstChild("Handle")
                    if h then pcall(function() h.Transparency = st and 1 or 0 end) end
                end
            end
        end
        createToggleSwitch(VisualsFrame, "🎩 Hide Accessories", "Makes all your character accessories (hats/gear) invisible.", function(state)
            _hideAccOn = state
            if _hideAccConn then _hideAccConn:Disconnect(); _hideAccConn = nil end
            pcall(_applyHideAcc, Player.Character, state)
            if state then
                _hideAccConn = AddConnection(Player.CharacterAdded:Connect(function(c) task.wait(0.5); pcall(_applyHideAcc, c, _hideAccOn) end))
                SendNotification("Accessories Hidden!", Theme.Green)
            else
                SendNotification("Accessories Restored!", Theme.Red)
            end
        end, false, true)
    end

    noFogEnabled, noFogConn = false, nil
    createSectionHeader(VisualsFrame, "🌿  ENVIRONMENT")
local xrayEnabled = false
    local originalTransparencies = {}
    createToggleSwitch(VisualsFrame, "🩻 X-Ray Vision", "Makes all map walls semi-transparent so you can see through.", function(state)
        xrayEnabled = state
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v:IsA("Terrain") then
                    if not originalTransparencies[v] then originalTransparencies[v] = v.Transparency end
                    v.Transparency = 0.6
                end
            end
            AddConnection(workspace.DescendantAdded:Connect(function(v)
                if xrayEnabled and v:IsA("BasePart") and not v:IsA("Terrain") and not v.Parent:FindFirstChild("Humanoid") then
                    if not originalTransparencies[v] then originalTransparencies[v] = v.Transparency end
                    pcall(function() v.Transparency = 0.6 end)
                end
            end))
            SendNotification("X-Ray Vision Enabled!", Theme.Green)
        else
            for part, trans in pairs(originalTransparencies) do
                if part and part.Parent then part.Transparency = trans end
            end
            table.clear(originalTransparencies)
            SendNotification("X-Ray Vision Disabled!", Theme.Red)
        end
    end, false, true)

    local dayNightLoop = false
    createToggleSwitch(VisualsFrame, "🔄 Day/Night Loop", "Rapidly cycles the game time.", function(state)
        dayNightLoop = state
        if state then
            task.spawn(function()
                while dayNightLoop do
                    Lighting.ClockTime = Lighting.ClockTime + 0.1
                    task.wait()
                end
            end)
        else
            Lighting.ClockTime = _G.OriginalClockTime or 14
        end
    end, false, true)

    createToggleSwitch(VisualsFrame, "🌫️ No Fog", "Removes fog and clouds for clear vision.", function(state)
        noFogEnabled = state
        if state then Lighting.FogStart, Lighting.FogEnd = 1e6, 1e6; for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end end; noFogConn = AddConnection(Lighting.ChildAdded:Connect(function(v) if noFogEnabled and (v:IsA("Atmosphere") or v:IsA("Clouds")) then task.wait(); v:Destroy() end end)) else Lighting.FogStart, Lighting.FogEnd = _G.OriginalFogStart or 0, _G.OriginalFogEnd or 8000; if noFogConn then noFogConn:Disconnect(); noFogConn = nil end end
    end, nil, true)

    fullbrightEnabled = false
    createToggleSwitch(VisualsFrame, "☀️ Fullbright (Light)", "Max out brightness to see in the dark.", function(state) fullbrightEnabled = state; if state then Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime = Color3.new(1, 1, 1), 2, 14 else Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime = _G.OriginalAmbient, _G.OriginalBrightness, _G.OriginalClockTime end end, nil, true)

    invisRunning, InvisibleCharacter, invisFix, invisDied, realChar = false, nil, nil, nil, nil
    local function RespawnReal() if realChar then realChar.Parent = workspace; local hum = realChar:FindFirstChild("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end; realChar:BreakJoints() end end
    local function TurnVisible()
        if not invisRunning then return end
        pcall(function()
            if invisFix then invisFix:Disconnect() invisFix = nil end; if invisDied then invisDied:Disconnect() invisDied = nil end
            local currentCam, storedCF = workspace.CurrentCamera, nil
            if InvisibleCharacter and InvisibleCharacter.Parent then local root = InvisibleCharacter:FindFirstChild("HumanoidRootPart"); if root then storedCF = root.CFrame end; InvisibleCharacter:Destroy(); InvisibleCharacter = nil end
            if realChar and realChar.Parent then Player.Character = realChar; realChar.Parent = workspace; local root = realChar:FindFirstChild("HumanoidRootPart"); if root then root.CFrame = storedCF or root.CFrame; pcall(function() root.AssemblyLinearVelocity = Vector3.new(0,0,0) end) end; local hum = realChar:FindFirstChild("Humanoid"); if hum then currentCam.CameraSubject = hum end; local animate = realChar:FindFirstChild("Animate"); if animate then animate.Disabled = true task.wait() animate.Disabled = false end end
        end)
        invisRunning, realChar = false, nil
    end

    local function TurnInvisible()
        if invisRunning then return end
        realChar = Player.Character; if not realChar then return end
        local realRoot, realHum = realChar:FindFirstChild("HumanoidRootPart"), realChar:FindFirstChild("Humanoid"); if not realRoot or not realHum then return end
        invisRunning, realChar.Archivable = true, true; InvisibleCharacter = realChar:Clone(); InvisibleCharacter.Name, InvisibleCharacter.Parent = "Ghost_"..Player.Name, Lighting
        for _, v in pairs(InvisibleCharacter:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5 end end
        local cf = realRoot.CFrame; realRoot.CFrame, InvisibleCharacter.Parent, InvisibleCharacter:FindFirstChild("HumanoidRootPart").CFrame, Player.Character = CFrame.new(0, 100000, 0), workspace, cf, InvisibleCharacter
        workspace.CurrentCamera.CameraSubject = InvisibleCharacter:FindFirstChild("Humanoid")
        local animate = InvisibleCharacter:FindFirstChild("Animate"); if animate then animate.Disabled = true task.wait() animate.Disabled = false end
        invisFix = RunService.Stepped:Connect(function() pcall(function() if realChar and realChar.Parent and realRoot then realRoot.CFrame = CFrame.new(0, 100000, 0); realRoot.AssemblyLinearVelocity = Vector3.new(0,0,0) end end) end)
        if InvisibleCharacter:FindFirstChild("Humanoid") then invisDied = InvisibleCharacter:FindFirstChild("Humanoid").Died:Connect(function() TurnVisible(); RespawnReal() end) end
    end

    createSectionHeader(VisualsFrame, "🧍  CHARACTER")
    createToggleSwitch(VisualsFrame, "👻 Invisible Mode (FE)", "Makes your character invisible to others.", function(state) if state then TurnInvisible() else TurnVisible() end end, nil, true)
    createSectionHeader(VisualsFrame, "📷  CAMERA")
    createSlider(VisualsFrame, "🔭 Field Of View (FOV)", "Adjust the camera field of view.", 70, 120, 70, function(val) workspace.CurrentCamera.FieldOfView = val end, true)
    zoomToggleState, customZoomValue = false, 128
    createToggleSwitch(VisualsFrame, "🔭 Enable Custom Zoom", "Override the maximum camera zoom distance.", function(state) zoomToggleState = state; Player.CameraMaxZoomDistance = state and customZoomValue or defaultMaxZoom end)
    createSlider(VisualsFrame, "📏 Zoom Distance Value", "Set the max distance for custom zoom.", 50, 10000, 128, function(val) customZoomValue = val; if zoomToggleState then Player.CameraMaxZoomDistance = val end end)
    createButton(VisualsFrame, "♾️ Unlimited Zoom", "Allows the camera to zoom out infinitely.", Theme.Accent, function() Player.CameraMaxZoomDistance = 9e9; SendNotification("Max Zoom set to Unlimited!", Theme.Green) end)

    rainbowCharEnabled, rainbowHue, rainbowConn = false, 0, nil
    createToggleSwitch(VisualsFrame, "🌈 Rainbow Character", "Cycles your character through rainbow colors.", function(state)
        rainbowCharEnabled = state
        if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
        if state then
            rainbowConn = AddConnection(RunService.Heartbeat:Connect(function()
                rainbowHue = (rainbowHue + 0.002) % 1
                local char = Player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            pcall(function() part.Color = Color3.fromHSV(rainbowHue, 1, 1) end)
                        end
                    end
                end
            end))
            SendNotification("Rainbow Character Enabled!", Theme.Green)
        else
            if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
            SendNotification("Rainbow Character Disabled!", Theme.Red)
        end
    end, false, true)

    do
        local _headlessOn = false
        local _headlessConn = nil
        local function _applyHeadless(char)
            if not char or not _headlessOn then return end
            task.wait(0.3)
            local head = char:FindFirstChild("Head")
            if head then
                pcall(function() head.Transparency = 1 end)
                for _, d in pairs(head:GetChildren()) do
                    if d:IsA("Decal") then pcall(function() d.Transparency = 1 end) end
                end
            end
            for _, acc in pairs(char:GetChildren()) do
                if acc:IsA("Accessory") then
                    local handle = acc:FindFirstChild("Handle")
                    if handle then pcall(function() handle.Transparency = 1 end) end
                end
            end
        end
        createToggleSwitch(VisualsFrame, "💀 Headless (Local)", "Makes your head invisible. Persists on respawn.", function(state)
            _headlessOn = state
            if _headlessConn then _headlessConn:Disconnect(); _headlessConn = nil end
            if state then
                _applyHeadless(Player.Character)
                _headlessConn = AddConnection(Player.CharacterAdded:Connect(_applyHeadless))
                SendNotification("Headless Mode ON!", Theme.Red)
            else
                local char = Player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        pcall(function() head.Transparency = 0 end)
                        for _, d in pairs(head:GetChildren()) do
                            if d:IsA("Decal") then pcall(function() d.Transparency = 0 end) end
                        end
                    end
                    for _, acc in pairs(char:GetChildren()) do
                        if acc:IsA("Accessory") then
                            local handle = acc:FindFirstChild("Handle")
                            if handle then pcall(function() handle.Transparency = 0 end) end
                        end
                    end
                end
                SendNotification("Headless Mode OFF!", Theme.Green)
            end
        end, false, true)
    end

    createSectionHeader(VisualsFrame, "💡  LIGHTING")
    createSlider(VisualsFrame, "🕐 Time of Day", "Control the in-game clock time (0-24h).", 0, 24, math.floor(Lighting.ClockTime), function(val)
        Lighting.ClockTime = val
    end, true)

    createSlider(VisualsFrame, "🌓 Ambient Darkness", "Adjust ambient darkness level (0=dark, 100=bright).", 0, 100, 50, function(val)
        local v = val / 100
        Lighting.Ambient = Color3.fromRGB(v*255, v*255, v*255)
    end, true)

    createSectionHeader(VisualsFrame, "🌅  SHADERS & FILTERS")

    local selectedShader = "Default"
    local shaderDropdownBtn = createButton(VisualsFrame, "🌈 Shader: " .. selectedShader, "Select a visual shader preset.", Theme.Accent, function() end)

    local shaderFrame = Instance.new("ScrollingFrame")
    shaderFrame.Size, shaderFrame.Visible, shaderFrame.Parent, shaderFrame.ScrollBarThickness = UDim2.new(0.96, 0, 0, 150), false, VisualsFrame, 4
    createLayout(shaderFrame)

    local shaderPresets = {
        "Default", "Realistic", "Ultra Realistic", "Night", "Horror",
        "Morning", "Cyberpunk", "Anime Vibrant", "Black & White", "Cinematic", "Dreamy",
        "HDR", "Warm Glow", "Sunset", "Misty Forest", "Retro", "Underwater"
    }

    shaderDropdownBtn.MouseButton1Click:Connect(function()
        shaderFrame.Visible = not shaderFrame.Visible
        if shaderFrame.Visible then
            shaderFrame:ClearAllChildren(); createLayout(shaderFrame)
            for _, sName in ipairs(shaderPresets) do
                local btn = Instance.new("TextButton")
                btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Parent = UDim2.new(1, 0, 0, 30), Theme.ItemHover, sName, Theme.TextPrimary, shaderFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

                btn.MouseButton1Click:Connect(function()
                    selectedShader = sName
                    for _, child in pairs(shaderDropdownBtn:GetChildren()) do
                        if child:IsA("TextLabel") and string.find(child.Text, "Shader:") then
                            child.Text = "🌈 Shader: " .. sName
                        end
                    end
                    shaderFrame.Visible = false
                end)
            end
        end
    end)

    if _G.OriginalOutdoorAmbient == nil then
        _G.OriginalOutdoorAmbient = Lighting.OutdoorAmbient
        _G.OriginalEnvDiffuse = Lighting.EnvironmentDiffuseScale
        _G.OriginalEnvSpecular = Lighting.EnvironmentSpecularScale
        _G.OriginalShadows = Lighting.GlobalShadows
        _G.OriginalFogColor = Lighting.FogColor
    end

    local function applyLightingShader(preset)
        pcall(function()
            for _, v in pairs(Lighting:GetChildren()) do
                if v.Name == "PhantomShaderEffect" then
                    v:Destroy()
                end
            end
        end)

        pcall(function() Lighting.Ambient = _G.OriginalAmbient or Color3.fromRGB(128, 128, 128) end)
        pcall(function() Lighting.OutdoorAmbient = _G.OriginalOutdoorAmbient or Color3.fromRGB(128, 128, 128) end)
        pcall(function() Lighting.Brightness = _G.OriginalBrightness or 1 end)
        pcall(function() Lighting.ClockTime = _G.OriginalClockTime or 14 end)
        pcall(function() Lighting.FogStart = _G.OriginalFogStart or 0 end)
        pcall(function() Lighting.FogEnd = _G.OriginalFogEnd or 100000 end)
        pcall(function() Lighting.FogColor = _G.OriginalFogColor or Color3.fromRGB(192, 192, 192) end)
        pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0) end)
        pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0) end)
        pcall(function() Lighting.EnvironmentDiffuseScale = _G.OriginalEnvDiffuse or 0 end)
        pcall(function() Lighting.EnvironmentSpecularScale = _G.OriginalEnvSpecular or 0 end)
        pcall(function() Lighting.GlobalShadows = _G.OriginalShadows ~= nil and _G.OriginalShadows or true end)
        pcall(function() Lighting.ExposureCompensation = 0 end)

        pcall(function()
            if preset == "Realistic" or preset == "Ultra Realistic" or preset == "Cinematic" or preset == "HDR" then
                if sethiddenproperty then sethiddenproperty(Lighting, "Technology", Enum.Technology.Future) end
            end
        end)

        if preset == "Default" then return end

        local function addEffect(className, props)
            local ok, effect = pcall(function() return Instance.new(className) end)
            if not ok then return end
            effect.Name = "PhantomShaderEffect"
            for k, v2 in pairs(props) do pcall(function() effect[k] = v2 end) end
            pcall(function() effect.Parent = Lighting end)
        end

        if preset == "Realistic" then
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(118, 120, 125)
            Lighting.OutdoorAmbient = Color3.fromRGB(138, 140, 148)
            Lighting.ExposureCompensation = 0.1
            Lighting.ColorShift_Top = Color3.fromRGB(255, 248, 235)
            Lighting.ColorShift_Bottom = Color3.fromRGB(225, 238, 255)
            addEffect("ColorCorrectionEffect", {Contrast = 0.15, Saturation = 0.12, TintColor = Color3.fromRGB(255, 252, 246)})
            addEffect("BloomEffect", {Intensity = 0.04, Size = 16, Threshold = 2.8})
            addEffect("SunRaysEffect", {Intensity = 0.07, Spread = 0.07})

        elseif preset == "Ultra Realistic" then
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
            Lighting.Brightness = 2.2
            Lighting.Ambient = Color3.fromRGB(100, 105, 112)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 132, 140)
            Lighting.ExposureCompensation = 0.15
            Lighting.ColorShift_Top = Color3.fromRGB(255, 242, 215)
            Lighting.ColorShift_Bottom = Color3.fromRGB(215, 232, 255)
            addEffect("ColorCorrectionEffect", {Contrast = 0.22, Saturation = 0.18, TintColor = Color3.fromRGB(255, 250, 242)})
            addEffect("BloomEffect", {Intensity = 0.06, Size = 22, Threshold = 2.2})
            addEffect("SunRaysEffect", {Intensity = 0.14, Spread = 0.10})
            addEffect("DepthOfFieldEffect", {FarIntensity = 0.08, FocusDistance = 55, InFocusRadius = 65, NearIntensity = 0.04})

        elseif preset == "Night" then
            Lighting.ClockTime = 0
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(185, 188, 225)
            Lighting.OutdoorAmbient = Color3.fromRGB(148, 152, 200)
            Lighting.EnvironmentDiffuseScale = 0.6
            Lighting.EnvironmentSpecularScale = 0.7
            Lighting.ColorShift_Top = Color3.fromRGB(180, 195, 255)
            addEffect("ColorCorrectionEffect", {Contrast = 0.2, Saturation = -0.3, TintColor = Color3.fromRGB(170, 185, 255)})
            addEffect("BloomEffect", {Intensity = 0.25, Size = 22, Threshold = 1.8})
            addEffect("SunRaysEffect", {Intensity = 0.05, Spread = 0.08})

        elseif preset == "Horror" then
            Lighting.ClockTime = 0
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(165, 112, 112)
            Lighting.OutdoorAmbient = Color3.fromRGB(132, 82, 82)
            Lighting.EnvironmentDiffuseScale = 0.3
            Lighting.EnvironmentSpecularScale = 0.3
            Lighting.FogEnd = 220
            Lighting.FogColor = Color3.fromRGB(25, 8, 8)
            addEffect("ColorCorrectionEffect", {Contrast = 0.5, Saturation = -0.5, TintColor = Color3.fromRGB(255, 145, 145)})
            addEffect("BloomEffect", {Intensity = 0.12, Size = 18, Threshold = 2.2})
            addEffect("DepthOfFieldEffect", {FarIntensity = 0.35, FocusDistance = 28, InFocusRadius = 18, NearIntensity = 0.1})

        elseif preset == "Morning" then
            Lighting.ClockTime = 6.5
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(195, 168, 132)
            Lighting.OutdoorAmbient = Color3.fromRGB(220, 185, 148)
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 0.6
            Lighting.ExposureCompensation = 0.1
            Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 160)
            addEffect("ColorCorrectionEffect", {Contrast = 0.18, Saturation = 0.45, TintColor = Color3.fromRGB(255, 240, 210)})
            addEffect("SunRaysEffect", {Intensity = 0.35, Spread = 0.6})
            addEffect("BloomEffect", {Intensity = 0.08, Size = 24, Threshold = 2.5})

        elseif preset == "Cyberpunk" then
            Lighting.ClockTime = 2
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(130, 85, 170)
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 55, 130)
            Lighting.EnvironmentDiffuseScale = 0.4
            Lighting.EnvironmentSpecularScale = 1
            Lighting.FogEnd = 600
            Lighting.FogColor = Color3.fromRGB(40, 10, 60)
            addEffect("ColorCorrectionEffect", {Contrast = 0.4, Saturation = 0.8, TintColor = Color3.fromRGB(255, 140, 255)})
            addEffect("BloomEffect", {Intensity = 1.0, Size = 44, Threshold = 0.3})
            addEffect("SunRaysEffect", {Intensity = 0.08, Spread = 0.08})

        elseif preset == "Anime Vibrant" then
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(195, 195, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(230, 230, 235)
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 0.5
            Lighting.ExposureCompensation = 0.1
            addEffect("ColorCorrectionEffect", {Contrast = 0.25, Saturation = 1.4, TintColor = Color3.fromRGB(255, 255, 255)})
            addEffect("BloomEffect", {Intensity = 0.25, Size = 22, Threshold = 1.2})

        elseif preset == "Black & White" then
            Lighting.Brightness = 2
            Lighting.EnvironmentDiffuseScale = 0.8
            Lighting.EnvironmentSpecularScale = 0.5
            Lighting.ExposureCompensation = 0.05
            addEffect("ColorCorrectionEffect", {Contrast = 0.35, Saturation = -1, Brightness = 0.02})
            addEffect("BloomEffect", {Intensity = 0.04, Size = 18, Threshold = 2.5})

        elseif preset == "Cinematic" then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(110, 112, 118)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 130, 138)
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 0.7
            Lighting.ExposureCompensation = 0.05
            addEffect("ColorCorrectionEffect", {Contrast = 0.45, Saturation = -0.12, TintColor = Color3.fromRGB(248, 245, 235)})
            addEffect("BloomEffect", {Intensity = 0.08, Size = 28, Threshold = 2})
            addEffect("DepthOfFieldEffect", {FarIntensity = 0.18, FocusDistance = 42, InFocusRadius = 38, NearIntensity = 0.05})

        elseif preset == "Dreamy" then
            pcall(function() Lighting.Brightness = 2.8 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(200, 185, 215) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(220, 205, 235) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 0.6 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.3 end)
            pcall(function() Lighting.ExposureCompensation = 0.15 end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 255) end)
            addEffect("ColorCorrectionEffect", {Contrast = -0.1, Saturation = 0.5, TintColor = Color3.fromRGB(255, 228, 255)})
            addEffect("BloomEffect", {Intensity = 0.7, Size = 52, Threshold = 0.4})
            addEffect("DepthOfFieldEffect", {FarIntensity = 0.12, FocusDistance = 22, InFocusRadius = 28, NearIntensity = 0.06})

        elseif preset == "HDR" then
            pcall(function() Lighting.GlobalShadows = true end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 1 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 1 end)
            pcall(function() Lighting.Brightness = 2.5 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(95, 98, 108) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(120, 124, 138) end)
            pcall(function() Lighting.ExposureCompensation = 0.2 end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(255, 245, 220) end)
            pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(210, 228, 255) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.55, Saturation = 0.35, TintColor = Color3.fromRGB(255, 253, 248)})
            addEffect("BloomEffect", {Intensity = 0.18, Size = 30, Threshold = 1.8})
            addEffect("SunRaysEffect", {Intensity = 0.18, Spread = 0.12})

        elseif preset == "Warm Glow" then
            pcall(function() Lighting.Brightness = 2.2 end)
            pcall(function() Lighting.ClockTime = 15 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(210, 175, 120) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(235, 195, 140) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 0.8 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.5 end)
            pcall(function() Lighting.ExposureCompensation = 0.1 end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(255, 210, 145) end)
            pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(255, 190, 100) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.12, Saturation = 0.55, TintColor = Color3.fromRGB(255, 235, 195)})
            addEffect("BloomEffect", {Intensity = 0.45, Size = 36, Threshold = 1.0})
            addEffect("SunRaysEffect", {Intensity = 0.22, Spread = 0.45})

        elseif preset == "Sunset" then
            pcall(function() Lighting.ClockTime = 18.5 end)
            pcall(function() Lighting.Brightness = 2.2 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(215, 130, 80) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(240, 148, 90) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 1 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.7 end)
            pcall(function() Lighting.ExposureCompensation = 0.05 end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(255, 165, 60) end)
            pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(255, 90, 40) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.28, Saturation = 0.75, TintColor = Color3.fromRGB(255, 218, 168)})
            addEffect("BloomEffect", {Intensity = 0.55, Size = 42, Threshold = 0.8})
            addEffect("SunRaysEffect", {Intensity = 0.55, Spread = 0.8})

        elseif preset == "Misty Forest" then
            pcall(function() Lighting.ClockTime = 7 end)
            pcall(function() Lighting.Brightness = 1.6 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(160, 185, 168) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(175, 200, 182) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 0.5 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.2 end)
            pcall(function() Lighting.FogEnd = 280 end)
            pcall(function() Lighting.FogColor = Color3.fromRGB(195, 215, 200) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.08, Saturation = 0.2, TintColor = Color3.fromRGB(210, 230, 215)})
            addEffect("BloomEffect", {Intensity = 0.2, Size = 28, Threshold = 1.6})

        elseif preset == "Retro" then
            pcall(function() Lighting.Brightness = 1.8 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(168, 145, 105) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(182, 158, 118) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 0.5 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.2 end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(220, 195, 145) end)
            pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(195, 165, 110) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.5, Saturation = -0.55, TintColor = Color3.fromRGB(255, 235, 185), Brightness = -0.04})
            addEffect("BloomEffect", {Intensity = 0.06, Size = 16, Threshold = 2.8})

        elseif preset == "Underwater" then
            pcall(function() Lighting.Brightness = 1.4 end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(55, 110, 165) end)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(40, 95, 148) end)
            pcall(function() Lighting.EnvironmentDiffuseScale = 0.4 end)
            pcall(function() Lighting.EnvironmentSpecularScale = 0.6 end)
            pcall(function() Lighting.FogEnd = 180 end)
            pcall(function() Lighting.FogColor = Color3.fromRGB(30, 80, 140) end)
            pcall(function() Lighting.ColorShift_Top = Color3.fromRGB(60, 140, 220) end)
            pcall(function() Lighting.ColorShift_Bottom = Color3.fromRGB(20, 80, 145) end)
            addEffect("ColorCorrectionEffect", {Contrast = 0.18, Saturation = 0.45, TintColor = Color3.fromRGB(160, 205, 255)})
            addEffect("BloomEffect", {Intensity = 0.3, Size = 28, Threshold = 1.5})
            addEffect("DepthOfFieldEffect", {FarIntensity = 0.22, FocusDistance = 30, InFocusRadius = 35, NearIntensity = 0.08})
        end
    end

    createButton(VisualsFrame, "✅ Apply Shader", "Applies the currently selected shader.", Theme.Green, function()
        applyLightingShader(selectedShader)
        SendNotification("✅ Shader Applied: " .. selectedShader, Theme.Green)
    end)

    createButton(VisualsFrame, "↩️ Reset Shader", "Removes all shader effects and restores original lighting.", Theme.Red, function()
        applyLightingShader("Default")
        selectedShader = "Default"
        for _, child in pairs(shaderDropdownBtn:GetChildren()) do
            if child:IsA("TextLabel") and string.find(child.Text, "Shader:") then
                child.Text = "🌈 Shader: Default"
            end
        end
        SendNotification("Shader Reset to Default!", Theme.Yellow)
    end)

    selectedPlayer, mimicEnabled, mimicConnection = nil, false, nil
    createSectionHeader(PlayersFrame, "🎯  SELECT TARGET")
    local playerLabel = Instance.new("TextLabel"); playerLabel.Text, playerLabel.Size, playerLabel.BackgroundColor3, playerLabel.TextColor3, playerLabel.Parent = "Selected: None", UDim2.new(0.96, 0, 0, 30), Theme.ContentBg, Theme.Accent, PlayersFrame
    Instance.new("UICorner", playerLabel).CornerRadius = UDim.new(0, 6); AddStroke(playerLabel, Theme.Outline, 1)

    local function updateMimic()
        if mimicConnection then mimicConnection:Disconnect() end
        if mimicEnabled and selectedPlayer then
            mimicConnection = selectedPlayer.Chatted:Connect(function(msg)
                task.wait(0.1); local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if events and events:FindFirstChild("SayMessageRequest") then events.SayMessageRequest:FireServer(msg, "All") else local tcs = game:GetService("TextChatService"); if tcs and tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then tcs.TextChannels.RBXGeneral:SendAsync(msg) end end
            end)
        end
    end

    local dropdownBtn = createButton(PlayersFrame, "👇 Select Player", "Open the list of players to select one.", Theme.Accent, function() end)
    local dropdownFrame = Instance.new("ScrollingFrame")
    dropdownFrame.Size, dropdownFrame.Visible, dropdownFrame.Parent, dropdownFrame.ScrollBarThickness = UDim2.new(0.96, 0, 0, 0), false, PlayersFrame, 4

    local function updatePlayerList()
        dropdownFrame:ClearAllChildren()
        local layout = Instance.new("UIListLayout", dropdownFrame)
        layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = layout.AbsoluteContentSize.Y
            dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            dropdownFrame.Size = UDim2.new(0.96, 0, 0, math.clamp(contentHeight, 0, 200))
        end)

        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player then
                local btn = Instance.new("TextButton")
                btn.Size, btn.BackgroundColor3, btn.Text, btn.Parent = UDim2.new(1, 0, 0, 45), Theme.ItemHover, "", dropdownFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                local avatar = Instance.new("ImageLabel", btn)
                avatar.Size, avatar.Position, avatar.BackgroundTransparency = UDim2.new(0, 35, 0, 35), UDim2.new(0, 5, 0, 5), 1
                Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
                task.spawn(function() pcall(function() avatar.Image = game.Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)

                local dNameLbl = Instance.new("TextLabel", btn)
                dNameLbl.Size, dNameLbl.Position, dNameLbl.BackgroundTransparency, dNameLbl.Text, dNameLbl.TextColor3, dNameLbl.Font, dNameLbl.TextSize, dNameLbl.TextXAlignment = UDim2.new(1, -50, 0, 15), UDim2.new(0, 45, 0, 5), 1, p.DisplayName, Theme.TextPrimary, Enum.Font.GothamBold, 13, Enum.TextXAlignment.Left

                local uNameLbl = Instance.new("TextLabel", btn)
                uNameLbl.Size, uNameLbl.Position, uNameLbl.BackgroundTransparency, uNameLbl.Text, uNameLbl.TextColor3, uNameLbl.Font, uNameLbl.TextSize, uNameLbl.TextXAlignment = UDim2.new(1, -50, 0, 12), UDim2.new(0, 45, 0, 22), 1, "@" .. p.Name, Theme.TextSecondary, Enum.Font.Gotham, 11, Enum.TextXAlignment.Left

                btn.MouseButton1Click:Connect(function()
                    selectedPlayer, playerLabel.Text, dropdownFrame.Visible = p, "Selected: " .. p.DisplayName, false
                    updateMimic()
                end)
            end
        end
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
        if dropdownFrame.Visible then updatePlayerList() end
    end)

    local cachedOutfitModel = nil
    local outfitRespawnConn = nil

    local function copyAvatarToLocal(targetChar)
        local localChar = Player.Character
        if not localChar or not targetChar then return false end

        local success, err = pcall(function()
            local localHum = localChar:FindFirstChildOfClass("Humanoid")
            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

            for _, v in pairs(localChar:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                    v:Destroy()
                end
            end

            for _, v in pairs(targetChar:GetChildren()) do
                if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                    v:Clone().Parent = localChar
                elseif v:IsA("Accessory") then
                    local clonedAcc = v:Clone()
                    local handle = clonedAcc:FindFirstChild("Handle")

                    if handle then
                        handle.Anchored = false
                        handle.CanCollide = false

                        if localChar:FindFirstChild("Head") then
                            handle.CFrame = localChar.Head.CFrame
                        end

                        for _, desc in pairs(clonedAcc:GetDescendants()) do
                            if desc:IsA("JointInstance") then
                                desc:Destroy()
                            end
                        end

                        local accAttachment = handle:FindFirstChildOfClass("Attachment")
                        local charAttachment = nil

                        if accAttachment then
                            for _, part in pairs(localChar:GetChildren()) do
                                if part:IsA("BasePart") then
                                    local found = part:FindFirstChild(accAttachment.Name)
                                    if found and found:IsA("Attachment") then
                                        charAttachment = found
                                        break
                                    end
                                end
                            end
                        end

                        if charAttachment then
                            clonedAcc.Parent = localChar
                            handle.CFrame = charAttachment.Parent.CFrame * charAttachment.CFrame * accAttachment.CFrame:Inverse()

                            local weld = Instance.new("Weld")
                            weld.Name = "PhantomAccessoryWeld"
                            weld.Part0 = charAttachment.Parent
                            weld.Part1 = handle
                            weld.C0 = charAttachment.CFrame
                            weld.C1 = accAttachment.CFrame
                            weld.Parent = handle
                        else
                            if localHum then localHum:AddAccessory(clonedAcc) else clonedAcc.Parent = localChar end
                        end
                    else
                        if localHum then localHum:AddAccessory(clonedAcc) else clonedAcc.Parent = localChar end
                    end
                end
            end

            for _, targetPart in pairs(targetChar:GetChildren()) do
                if targetPart:IsA("BasePart") then
                    local localPart = localChar:FindFirstChild(targetPart.Name)
                    if localPart and localPart:IsA("BasePart") then
                        localPart.Color = targetPart.Color

                        local targetMesh = targetPart:FindFirstChildOfClass("SpecialMesh")
                        local localMesh = localPart:FindFirstChildOfClass("SpecialMesh")

                        if targetMesh then
                            if localMesh then
                                localMesh.MeshId = targetMesh.MeshId
                                localMesh.TextureId = targetMesh.TextureId
                                localMesh.Scale = targetMesh.Scale
                                localMesh.MeshType = targetMesh.MeshType
                            else
                                targetMesh:Clone().Parent = localPart
                            end
                        elseif localMesh then
                            localMesh:Destroy()
                        end

                        if targetPart.Name == "Head" then
                            local targetFace = targetPart:FindFirstChild("face") or targetPart:FindFirstChildOfClass("Decal")
                            local localFace = localPart:FindFirstChild("face") or localPart:FindFirstChildOfClass("Decal")

                            if targetFace then
                                if localFace then
                                    localFace.Texture = targetFace.Texture
                                else
                                    targetFace:Clone().Parent = localPart
                                end
                            elseif localFace then
                                localFace:Destroy()
                            end
                        end
                    end
                end
            end

            if localHum and targetHum then
                for _, scale in pairs(targetHum:GetChildren()) do
                    if scale:IsA("NumberValue") then
                        local localScale = localHum:FindFirstChild(scale.Name)
                        if localScale and localScale:IsA("NumberValue") then
                            localScale.Value = scale.Value
                        end
                    end
                end
            end
        end)

        if not success then warn("Outfit Copy Error: ", err) end
        return success
    end

    createSectionHeader(PlayersFrame, "🎭  APPEARANCE")
    createButton(PlayersFrame, "👗 Copy Outfit (Visual)", "Copy the selected player's avatar outfit locally.", Color3.fromRGB(150, 50, 255), function()
        if not selectedPlayer or not selectedPlayer.Character then
            SendNotification("Select a target player first!", Theme.Red)
            return
        end

        selectedPlayer.Character.Archivable = true
        if cachedOutfitModel then
            cachedOutfitModel:Destroy()
        end
        cachedOutfitModel = selectedPlayer.Character:Clone()

        if copyAvatarToLocal(cachedOutfitModel) then
            SendNotification("Copied " .. selectedPlayer.Name .. "'s Outfit A to Z!", Theme.Green)
        else
            SendNotification("Error cloning outfit.", Theme.Red)
        end

        if not outfitRespawnConn then
            outfitRespawnConn = Player.CharacterAdded:Connect(function(char)
                if cachedOutfitModel then
                    task.spawn(function()
                        task.wait(1.5)
                        if Player.Character then
                            copyAvatarToLocal(cachedOutfitModel)
                        end
                    end)
                end
            end)
        end
    end)

    createButton(PlayersFrame, "🔄 Reset Outfit", "Revert back to your original avatar.", Theme.Yellow, function()
        if cachedOutfitModel then
            cachedOutfitModel:Destroy()
            cachedOutfitModel = nil
        end
        if outfitRespawnConn then
            outfitRespawnConn:Disconnect()
            outfitRespawnConn = nil
        end

        if Player.Character then
            Player.Character:BreakJoints()
            SendNotification("Outfit Reset! Respawning...", Theme.Green)
        end
    end)

    createSectionHeader(PlayersFrame, "💬  SOCIAL")
    createToggleSwitch(PlayersFrame, "🦜 Chat Mimic", "Repeat whatever the selected player types.", function(state) mimicEnabled = state; updateMimic() end)
    createSectionHeader(PlayersFrame, "⚡  ACTIONS")
    createButton(PlayersFrame, "🌀 Teleport to Player", "Instantly teleport to the selected player.", Theme.Accent, function() if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then Player.Character:SetPrimaryPartCFrame(selectedPlayer.Character.HumanoidRootPart.CFrame) end end)
    createButton(PlayersFrame, "🧲 Bring Player (Client)", "Visually bring the player to you (Local Only).", Theme.Green, function() if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then selectedPlayer.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame end end)

do
    local _h = Instance.new("TextLabel")
    _h.Text = "🏷️  YOUR NAME TAG"
    _h.Size = UDim2.new(0.96, 0, 0, 24)
    _h.BackgroundTransparency = 1
    _h.TextColor3 = Theme.Accent
    _h.Font = Enum.Font.GothamBold
    _h.TextSize = 11
    _h.TextXAlignment = Enum.TextXAlignment.Left
    _h.Parent = TagsFrame
end

local tagTitle = Instance.new("TextLabel")
tagTitle.Text = "💎 Global Name Tag"
tagTitle.Size = UDim2.new(0.96, 0, 0, 30)
tagTitle.BackgroundTransparency = 1
tagTitle.TextColor3 = Theme.Accent
tagTitle.Font = Enum.Font.GothamBold
tagTitle.TextSize = 16
tagTitle.Parent = TagsFrame

local tagTextBox = createTextBox(TagsFrame, "Type your custom tag...", "Set a global tag for everyone to see.", function() end)

local tagAnimDropdownBtn = createButton(TagsFrame, "✨ Tag Anim: " .. CurrentTagAnimation, "Choose the animation for your tag.", Theme.Accent, function() end)
local tagAnimFrame = Instance.new("ScrollingFrame")
tagAnimFrame.Size, tagAnimFrame.Visible, tagAnimFrame.Parent, tagAnimFrame.ScrollBarThickness = UDim2.new(0.96, 0, 0, 130), false, TagsFrame, 4
createLayout(tagAnimFrame)

local tagAnims = {"None", "Falling Stars", "Bubbles", "Snow"}

tagAnimDropdownBtn.MouseButton1Click:Connect(function()
    tagAnimFrame.Visible = not tagAnimFrame.Visible
    if tagAnimFrame.Visible then
        tagAnimFrame:ClearAllChildren(); createLayout(tagAnimFrame)
        for _, animName in ipairs(tagAnims) do
            local btn = Instance.new("TextButton")
            btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Parent = UDim2.new(1, 0, 0, 30), Theme.ItemHover, animName, Theme.TextPrimary, tagAnimFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                CurrentTagAnimation = animName
                for _, child in pairs(tagAnimDropdownBtn:GetChildren()) do
                    if child:IsA("TextLabel") and string.find(child.Text, "Tag Anim:") then
                        child.Text = "✨ Tag Anim: " .. animName
                    end
                end
                tagAnimFrame.Visible = false

                if Player.Character and Player.Character:FindFirstChild("Head") and Player.Character.Head:FindFirstChild("PhantomPremiumTag") then
                    local txt = tagTextBox.Text ~= "" and tagTextBox.Text or "Phantom User"
                    CreatePremiumTag(Player.Character, txt, Player.Name)
                end
            end)
        end
    end
end)

local tagStyleDropdownBtn = createButton(TagsFrame, "🎨 Tag Style: " .. CurrentTagStyle, "Choose the box design for your tag.", Theme.Accent, function() end)
local tagStyleFrame = Instance.new("ScrollingFrame")
tagStyleFrame.Size, tagStyleFrame.Visible, tagStyleFrame.Parent, tagStyleFrame.ScrollBarThickness = UDim2.new(0.96, 0, 0, 130), false, TagsFrame, 4
createLayout(tagStyleFrame)

local tagStyles = {"Dark Premium", "Glassmorphism", "Cyberpunk", "Crimson Void", "Neon Toxic", "Royal Gold", "Holographic"}

tagStyleDropdownBtn.MouseButton1Click:Connect(function()
    tagStyleFrame.Visible = not tagStyleFrame.Visible
    if tagStyleFrame.Visible then
        tagStyleFrame:ClearAllChildren(); createLayout(tagStyleFrame)
        for _, styleName in ipairs(tagStyles) do
            local btn = Instance.new("TextButton")
            btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Parent = UDim2.new(1, 0, 0, 30), Theme.ItemHover, styleName, Theme.TextPrimary, tagStyleFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                CurrentTagStyle = styleName
                for _, child in pairs(tagStyleDropdownBtn:GetChildren()) do
                    if child:IsA("TextLabel") and string.find(child.Text, "Tag Style:") then
                        child.Text = "🎨 Tag Style: " .. styleName
                    end
                end
                tagStyleFrame.Visible = false

                if Player.Character and Player.Character:FindFirstChild("Head") then
                    local txt = tagTextBox.Text ~= "" and tagTextBox.Text or "Phantom User"
                    CreatePremiumTag(Player.Character, txt, Player.Name)
                end
            end)
        end
    end
end)

local function attachTagOnSpawn(plr)
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head", 10)
        task.wait(0.5)
        if GlobalTagsEnabled and CachedTags[tostring(plr.UserId)] then
            local tagInfo = CachedTags[tostring(plr.UserId)]
            if tagInfo and tagInfo.TagText and tagInfo.TagText ~= "" then
                CreatePremiumTag(char, tagInfo.TagText, plr.Name, tagInfo.TagAnim, tagInfo.TagStyle)
            end
        end
    end)
end

for _, p in pairs(game.Players:GetPlayers()) do attachTagOnSpawn(p) end
AddConnection(game.Players.PlayerAdded:Connect(attachTagOnSpawn))

local MyTagRespawnConnection = nil

local _myPremiumTagToggle
_myPremiumTagToggle = createToggleSwitch(TagsFrame, "🏷️ Enable My Premium Tag", "Turn your custom tag ON or OFF globally.", function(state)
    if state and (tagTextBox.Text == nil or tagTextBox.Text == "") then
        SendNotification("Please enter a tag first!", Theme.Red)
        task.defer(function() if _myPremiumTagToggle then _myPremiumTagToggle:SetState(false) end end)
        return
    end
    local httpRequest = getHttpRequest()
    if httpRequest then
        pcall(function()
            local text = state and tagTextBox.Text or ""

            local data = { TagText = text, DisplayName = Player.DisplayName, TagAnim = CurrentTagAnimation, TagStyle = CurrentTagStyle }
            httpRequest({
                Url = GLOBAL_TAGS_API .. "/" .. tostring(Player.UserId) .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode(data)
            })

            if state then
                SendNotification("Global Tag Enabled!", Theme.Green)
                if Player.Character then CreatePremiumTag(Player.Character, text, Player.Name) end

                if MyTagRespawnConnection then MyTagRespawnConnection:Disconnect() end
                MyTagRespawnConnection = Player.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    if tagTextBox.Text ~= "" then
                        CreatePremiumTag(char, tagTextBox.Text, Player.Name, CurrentTagAnimation, CurrentTagStyle)
                    end
                end)
            else
                SendNotification("Global Tag Disabled!", Theme.Yellow)
                if MyTagRespawnConnection then MyTagRespawnConnection:Disconnect(); MyTagRespawnConnection = nil end
                if Player.Character and Player.Character:FindFirstChild("Head") then
                    local existing = Player.Character.Head:FindFirstChild("PhantomPremiumTag")
                    if existing then existing:Destroy() end
                end
            end
        end)
    end
end, false, true)

local function SyncGlobalTags()
    task.spawn(function()
        while GlobalTagsEnabled do
            local httpRequest = getHttpRequest()
            if httpRequest then
                pcall(function()
                    local response = httpRequest({
                        Url = GLOBAL_TAGS_API .. ".json?nocache=" .. tostring(tick()),
                        Method = "GET",
                        Headers = {
                            ["Cache-Control"] = "no-cache",
                            ["Pragma"] = "no-cache"
                        }
                    })

                    if response and response.StatusCode == 200 then
                        local data = game:GetService("HttpService"):JSONDecode(response.Body)
                        if data and type(data) == "table" then
                            CachedTags = data
                            for _, p in ipairs(game.Players:GetPlayers()) do
                                local tagInfo = CachedTags[tostring(p.UserId)]
                                if tagInfo and tagInfo.TagText and tagInfo.TagText ~= "" then
                                    CreatePremiumTag(p.Character, tagInfo.TagText, p.Name, tagInfo.TagAnim, tagInfo.TagStyle)
                                else
                                    if p.Character and p.Character:FindFirstChild("Head") then
                                        local existing = p.Character.Head:FindFirstChild("PhantomPremiumTag")
                                        if existing then existing:Destroy() end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(4)
        end

        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local existing = p.Character.Head:FindFirstChild("PhantomPremiumTag")
                if existing then existing:Destroy() end
            end
        end
    end)
end

do
    local _h2 = Instance.new("TextLabel")
    _h2.Text = "🌐  COMMUNITY"
    _h2.Size = UDim2.new(0.96, 0, 0, 24)
    _h2.BackgroundTransparency = 1
    _h2.TextColor3 = Theme.Accent
    _h2.Font = Enum.Font.GothamBold
    _h2.TextSize = 11
    _h2.TextXAlignment = Enum.TextXAlignment.Left
    _h2.Parent = TagsFrame
end
createToggleSwitch(TagsFrame, "👁️ Show Others' Tags", "See custom tags of other Phantom users.", function(state)
    GlobalTagsEnabled = state
    if state then
        SyncGlobalTags()
    end
end, false, false)

    createSectionHeader(PlayersFrame, "👁️  OBSERVE")
    spectating = false
    createToggleSwitch(PlayersFrame, "👀 Spectate Player", "Watch the selected player's perspective.", function(state) spectating = state; local cam = workspace.CurrentCamera; if state then task.spawn(function() while spectating and selectedPlayer do if selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then cam.CameraSubject = selectedPlayer.Character.Humanoid end; task.wait(0.5) end end) else if Player.Character and Player.Character:FindFirstChild("Humanoid") then cam.CameraSubject = Player.Character.Humanoid end end end)

    followEnabled, followConn = false, nil
    do
        local _followToggle = nil
        _followToggle = createToggleSwitch(PlayersFrame, "🏃 Follow Player", "Continuously follow the selected player.", function(state)
            if state and not selectedPlayer then
                SendNotification("Select a player first!", Theme.Red)
                task.defer(function() if _followToggle then _followToggle:SetState(false) end end)
                return
            end
            followEnabled = state
            if followConn then followConn:Disconnect(); followConn = nil end
            if state then
                followConn = AddConnection(RunService.Heartbeat:Connect(function()
                    if not followEnabled then return end
                    if selectedPlayer and selectedPlayer.Parent and selectedPlayer.Character
                       and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local char = Player.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        if hum then
                            hum:MoveTo(selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(3, 0, 3))
                        end
                    elseif not selectedPlayer or not selectedPlayer:IsDescendantOf(game.Players) then
                        followEnabled = false
                        if followConn then followConn:Disconnect(); followConn = nil end
                        if _followToggle then _followToggle:SetState(false) end
                    end
                end))
                SendNotification("Following " .. selectedPlayer.Name .. "!", Theme.Green)
            end
        end, false, true)
    end

    createButton(PlayersFrame, "🌐 View Profile (Copy URL)", "Copy the selected player's Roblox profile link.", Theme.Accent, function()
        if selectedPlayer then
            local url = "https://www.roblox.com/users/" .. selectedPlayer.UserId .. "/profile"
            if setclipboard then
                setclipboard(url)
                SendNotification("Profile URL Copied: " .. selectedPlayer.Name, Theme.Green)
            else
                SendNotification("Executor doesn't support clipboard!", Theme.Red)
            end
        else
            SendNotification("Select a player first!", Theme.Red)
        end
    end)

    createButton(PlayersFrame, "📋 Get Player Info", "Show display name, ID, team of selected player.", Theme.Yellow, function()
        if selectedPlayer then
            local teamName = "No Team"
            pcall(function() teamName = selectedPlayer.Team and selectedPlayer.Team.Name or "No Team" end)
            local info = string.format("%s | ID: %d | Team: %s", selectedPlayer.Name, selectedPlayer.UserId, teamName)
            SendNotification(info, Theme.Accent)
            if setclipboard then setclipboard(tostring(selectedPlayer.UserId)) end
        else
            SendNotification("Select a player first!", Theme.Red)
        end
    end)

    createSectionHeader(AFKFrame, "🛡️  AFK PROTECTION")

    afkScreenToggleBtn = createToggleSwitch(AFKFrame, "🌑 AFK Screen Mode", "Turns the screen black to save resources.", function(state) BlackScreen.Visible = state end)
    BlackScreen.ZIndex, CloseX.ZIndex = 5000, 5001; CloseX.MouseButton1Click:Connect(function() if afkScreenToggleBtn then afkScreenToggleBtn:SetState(false) end; if render3DToggleBtn then render3DToggleBtn:SetState(false) end end)

    autoReconnectEnabled = false
    createToggleSwitch(AFKFrame, "🔄 Auto Reconnect", "Automatically rejoins if you get disconnected.", function(state) autoReconnectEnabled = state end)
    AddConnection(GuiService.ErrorMessageChanged:Connect(function() if autoReconnectEnabled then task.wait(5); TeleportService:Teleport(game.PlaceId, Player) end end))

    antiAfkOn = false
    createToggleSwitch(AFKFrame, "🛡️ Anti-Kick (20m)", "Prevents Roblox from kicking you for inactivity.", function(state) antiAfkOn = state; pcall(function() if getconnections then for _, c in pairs(getconnections(Player.Idled)) do if state then c:Disable() else c:Enable() end end end end) end)
    AddConnection(Player.Idled:Connect(function() if antiAfkOn then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end))

    spinOn, spinVelocity = false, nil
    createToggleSwitch(AFKFrame, "😵 Spin Bot (Anti-Kick)", "Spins your character to prevent AFK kicks.", function(state) spinOn = state; if state then local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then spinVelocity = Instance.new("BodyAngularVelocity"); spinVelocity.Name, spinVelocity.MaxTorque, spinVelocity.AngularVelocity, spinVelocity.Parent = "Phantom_Spin", Vector3.new(0, 9e9, 0), Vector3.new(0, 50, 0), root end else if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart:FindFirstChild("Phantom_Spin") then Player.Character.HumanoidRootPart.Phantom_Spin:Destroy() end end end)

    createSectionHeader(AFKFrame, "🤖  AUTOMATION")
    autoJumpOn = false
    createToggleSwitch(AFKFrame, "🐇 Auto Jump", "Automatically makes your character jump.", function(state) autoJumpOn = state; task.spawn(function() while autoJumpOn do if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end; task.wait(2) end end) end)

    bunnyHopConn = nil
    createToggleSwitch(AFKFrame, "🐰 Bunny Hop", "Auto-jumps on landing for continuous movement.", function(state)
        if bunnyHopConn then bunnyHopConn:Disconnect(); bunnyHopConn = nil end
        if state then
            local _lastHop = 0
            bunnyHopConn = AddConnection(RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - _lastHop < 0.3 then return end
                local char = Player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    _lastHop = now
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
            SendNotification("Bunny Hop Enabled!", Theme.Green)
        else
            SendNotification("Bunny Hop Disabled!", Theme.Red)
        end
    end, false, true)

    autoWalkEnabled, autoWalkConn = false, nil
    createToggleSwitch(AFKFrame, "🚶 Auto Walk (AFK)", "Walks your character forward to avoid idle kicks.", function(state)
        autoWalkEnabled = state
        if autoWalkConn then autoWalkConn:Disconnect(); autoWalkConn = nil end
        if state then
            autoWalkConn = AddConnection(RunService.Heartbeat:Connect(function()
                if autoWalkEnabled then
                    local char = Player.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum then hum:Move(Vector3.new(0, 0, -1), false) end
                end
            end))
            SendNotification("Auto Walk Enabled!", Theme.Green)
        else
            SendNotification("Auto Walk Disabled!", Theme.Red)
        end
    end, false, true)

    autoRejoinOnDeath, deathConn = false, nil
    do
        local _charWatchConn = nil
        createToggleSwitch(AFKFrame, "💀 Auto Rejoin on Death", "Automatically rejoins the server when you die.", function(state)
            autoRejoinOnDeath = state
            if deathConn then deathConn:Disconnect(); deathConn = nil end
            if _charWatchConn then _charWatchConn:Disconnect(); _charWatchConn = nil end
            if state then
                local function watchDeath(char)
                    if deathConn then deathConn:Disconnect(); deathConn = nil end
                    local hum = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 5)
                    if hum then
                        deathConn = AddConnection(hum.Died:Connect(function()
                            if autoRejoinOnDeath then
                                task.wait(3)
                                saveSettings()
                                TeleportService:Teleport(game.PlaceId, Player)
                            end
                        end))
                    end
                end
                if Player.Character then watchDeath(Player.Character) end
                _charWatchConn = AddConnection(Player.CharacterAdded:Connect(watchDeath))
                SendNotification("Auto Rejoin on Death Enabled!", Theme.Green)
            else
                SendNotification("Auto Rejoin on Death Disabled!", Theme.Red)
            end
        end, false, true)
    end

    wanderEnabled, wanderConn = false, nil
    createToggleSwitch(AFKFrame, "🤖 Wander Bot (AFK)", "Randomly wanders around to simulate activity.", function(state)
        wanderEnabled = state
        if state then
            task.spawn(function()
                while wanderEnabled do
                    local char = Player.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if hum and root then
                        local angle = math.random() * 2 * math.pi
                        local dist = math.random(10, 30)
                        local target = root.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
                        hum:MoveTo(target)
                        local moved = false
                        local _mc = hum.MoveToFinished:Connect(function() moved = true end)
                        local _t0 = tick()
                        repeat task.wait(0.1) until moved or tick() - _t0 > 5 or not wanderEnabled
                        _mc:Disconnect()
                    end
                    task.wait(math.random(1, 3))
                end
            end)
            SendNotification("Wander Bot Enabled!", Theme.Green)
        else
            SendNotification("Wander Bot Disabled!", Theme.Red)
        end
    end, false, true)

    createSectionHeader(AFKFrame, "🌙  ANTI-AFK V2")
    createButton(AFKFrame, "🌙 Anti-AFK (Virtual Input)", "Simulates real mouse movement to bypass strict AFK detectors.", Theme.Accent, function() task.spawn(function() for i=1,5 do VirtualUser:Button1Down(Vector2.new(math.random(300,700),math.random(200,500)),workspace.CurrentCamera.CFrame); task.wait(0.05); VirtualUser:Button1Up(Vector2.new(math.random(300,700),math.random(200,500)),workspace.CurrentCamera.CFrame); task.wait(0.1) end end); SendNotification("Virtual Input Sent! (Anti-AFK)",Theme.Green) end)

    createSectionHeader(ServerFrame, "🔄  QUICK ACTIONS")
    createButton(ServerFrame, "🔁 Rejoin Server", "Reconnect to the same server instantly.", Theme.Yellow, function() saveSettings(); TeleportService:Teleport(game.PlaceId, Player) end)
    createButton(ServerFrame, "⏭️ Server Hop (Low Pop)", "Join a different server with fewer players.", Theme.Green, function() saveSettings(); local Http, TPS, _servers = game:GetService("HttpService"), game:GetService("TeleportService"), "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"; local function ListServers(cursor) return Http:JSONDecode(game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))) end; local Server, Next; repeat local Servers = ListServers(Next); Server, Next = Servers.data[1], Servers.nextPageCursor until Server; if Server.playing < Server.maxPlayers then TPS:TeleportToPlaceInstance(game.PlaceId, Server.id, Player) else TPS:Teleport(game.PlaceId, Player) end end)
    createButton(ServerFrame, "📶 Server Hop (Low Ping)", "Join a server with the lowest ping available.", Theme.Accent, function() SendNotification("Searching for low ping server...", Theme.Accent); task.spawn(function() local Http = game:GetService("HttpService"); local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"; local success, result = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end); if success and result and result.data then local best, lowest = nil, math.huge; for _, s in ipairs(result.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then local p = s.ping or math.huge; if p < lowest then lowest = p; best = s end end end; if best then SendNotification("Joining Best Ping Server!", Theme.Green); game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, best.id, Player) else SendNotification("No better server found.", Theme.Red) end end end) end)
    createButton(ServerFrame, "🔥 Server Hop (High Pop)", "Join a server that is almost full.", Theme.Red, function() SendNotification("Searching for high pop server...", Theme.Accent); task.spawn(function() local Http = game:GetService("HttpService"); local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"; local success, result = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end); if success and result and result.data then for _, s in ipairs(result.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 0 then SendNotification("Joining High Population Server!", Theme.Green); game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, Player); return end end; SendNotification("No server found.", Theme.Red) end end) end)
    createButton(ServerFrame, "🎲 Server Hop (Random)", "Join a completely random active server.", Theme.Yellow, function() SendNotification("Finding random server...", Theme.Accent); task.spawn(function() local Http = game:GetService("HttpService"); local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"; local success, result = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end); if success and result and result.data then local valid = {}; for _, s in ipairs(result.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(valid, s) end end; if #valid > 0 then SendNotification("Joining Random Server!", Theme.Green); game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, valid[math.random(1, #valid)].id, Player) else SendNotification("No server found.", Theme.Red) end end end) end)

    createButton(ServerFrame, "🕰️ Server Hop (Oldest)", "Join the oldest running server by crawling all pages.", Color3.fromRGB(180, 130, 255), function()
        SendNotification("Crawling all server pages for oldest...", Theme.Accent)
        task.spawn(function()
            local Http = game:GetService("HttpService")
            local baseUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, allServers = pcall(function()
                local servers = {}
                local cursor = nil
                local pages = 0
                repeat
                    local url = baseUrl .. (cursor and ("&cursor=" .. cursor) or "")
                    local ok, data = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
                    if not ok or not data or not data.data then break end
                    for _, s in ipairs(data.data) do
                        if s.id ~= game.JobId and s.playing < s.maxPlayers then
                            table.insert(servers, s)
                        end
                    end
                    cursor = data.nextPageCursor
                    pages = pages + 1
                    if cursor then task.wait(0.35) end
                until not cursor or pages >= 6
                return servers
            end)
            if success and allServers and #allServers > 0 then
                local oldest = allServers[#allServers]
                SendNotification("Joining Oldest Server! (" .. (oldest.playing or 0) .. " players, " .. #allServers .. " scanned)", Theme.Green)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, oldest.id, Player)
            else
                SendNotification("Could not find an older server.", Theme.Red)
            end
        end)
    end)

    createButton(ServerFrame, "🔗 Copy Game Link", "Copy the direct web link of this game.", Theme.Accent, function() if setclipboard then setclipboard("https://www.roblox.com/games/" .. tostring(game.PlaceId)); SendNotification("Game Link Copied!", Theme.Green) else SendNotification("Clipboard not supported!", Theme.Red) end end)

    local function createInfoLabel(parent, title, value)
        local container = Instance.new("Frame"); container.Size, container.BackgroundColor3, container.Parent = UDim2.new(0.96, 0, 0, 36), Theme.ContentBg, parent; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6); AddStroke(container, Theme.Outline, 1)
        local titleLbl = Instance.new("TextLabel"); titleLbl.Size, titleLbl.Position, titleLbl.Text, titleLbl.TextColor3, titleLbl.TextXAlignment, titleLbl.Font, titleLbl.TextSize, titleLbl.BackgroundTransparency, titleLbl.Parent = UDim2.new(0.4, 0, 1, 0), UDim2.new(0.05, 0, 0, 0), title, Theme.TextSecondary, Enum.TextXAlignment.Left, Enum.Font.GothamMedium, 12, 1, container
        local valueLbl = Instance.new("TextLabel"); valueLbl.Size, valueLbl.Position, valueLbl.Text, valueLbl.TextColor3, valueLbl.TextXAlignment, valueLbl.Font, valueLbl.TextSize, valueLbl.BackgroundTransparency, valueLbl.Parent = UDim2.new(0.5, 0, 1, 0), UDim2.new(0.45, 0, 0, 0), value, Theme.TextPrimary, Enum.TextXAlignment.Right, Enum.Font.GothamBold, 12, 1, container; return valueLbl
    end

    createSectionHeader(InfoFrame, "📊  GAME STATS")
    gameNameLbl, runTimeLbl, playerCountLbl, userIdLbl, globalExecLbl = createInfoLabel(InfoFrame, "🎮 Game", "Loading..."), createInfoLabel(InfoFrame, "⏱️ Uptime", "00:00:00"), createInfoLabel(InfoFrame, "👥 Players", "0 / 0"), createInfoLabel(InfoFrame, "🆔 User ID", tostring(Player.UserId)), createInfoLabel(InfoFrame, "🌍 Global Executes", "Wait...")

    local userCount = getUserExecutionCount()
    sendWebhook(userCount)
    getGlobalExecutionsAsync(function(globalCount)
        if globalExecLbl and globalExecLbl.Parent then
            globalExecLbl.Text = globalCount
        end
    end)
    gameIdLbl, placeIdLbl = createInfoLabel(InfoFrame, "🆔 Game ID", tostring(game.GameId)), createInfoLabel(InfoFrame, "📍 Place ID", tostring(game.PlaceId))

    local myGen = _infoGeneration
    task.spawn(function()
        local gameName = "Unknown Game"
        pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        if myGen == _infoGeneration and gameNameLbl and gameNameLbl.Parent then
            gameNameLbl.Text = gameName
        end

        while infoLoopRunning and myGen == _infoGeneration and ScreenGui and ScreenGui.Parent do
            local elapsed = tick() - scriptStartTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            if runTimeLbl and runTimeLbl.Parent then
                runTimeLbl.Text = string.format("%02d:%02d:%02d", h, m, s)
            end
            if playerCountLbl and playerCountLbl.Parent then
                pcall(function()
                    local cur = #game.Players:GetPlayers()
                    local mx  = game.Players.MaxPlayers
                    playerCountLbl.Text = tostring(cur) .. " / " .. tostring(mx)
                end)
            end
            task.wait(1)
        end
    end)

    createSectionHeader(SettingsFrame, "💡  FEEDBACK")
    feedbackLabel = Instance.new("TextLabel"); feedbackLabel.Text, feedbackLabel.Size, feedbackLabel.BackgroundTransparency, feedbackLabel.TextColor3, feedbackLabel.Font, feedbackLabel.TextSize, feedbackLabel.Parent = "💡 Suggestions / Feedback", UDim2.new(0.96, 0, 0, 20), 1, Theme.Accent, Enum.Font.GothamBold, 12, SettingsFrame
    feedbackBox = createTextBox(SettingsFrame, "✍️ Write idea here...", "Send your suggestions to the dev.", function() end)
    createButton(SettingsFrame, "📨 Send Feedback", "Submit the written feedback.", Theme.Green, function() if feedbackBox.Text ~= "" then sendFeedback(feedbackBox.Text); feedbackBox.Text = ""; SendNotification("Feedback Sent!", Theme.Green) else SendNotification("Cannot send empty feedback!", Theme.Red) end end)
    createSectionHeader(ServerFrame, "🔑  JOIN BY JOB ID")
    createButton(ServerFrame, "📋 Copy Job ID", "Copy server Job ID to clipboard.", Theme.Accent, function() if setclipboard then setclipboard(game.JobId); SendNotification("Job ID Copied!", Theme.Green) else SendNotification("Clipboard not supported!", Theme.Red) end end)
    jobIdBox = createTextBox(ServerFrame, "🎫 Enter Job ID to Join...", "Paste Job ID here to join server.", function() end)
    createButton(ServerFrame, "🚀 Join by Job ID", "Teleport to the specified server.", Theme.Green, function() local jId = jobIdBox.Text; if jId and jId ~= "" then TeleportService:TeleportToPlaceInstance(game.PlaceId, jId, Player) end end)

    createSectionHeader(ServerFrame, "🌐  SERVER BROWSER")
    local browserBtn = createButton(ServerFrame, "🌐 Browse Servers", "Find and join a specific public server.", Theme.Accent, function() end)

    local browserArrow = nil

    for _, child in pairs(browserBtn:GetChildren()) do
        if child:IsA("TextLabel") and child.Text == "›" then
            browserArrow = child
            browserArrow.Text = "▼"
        end
    end

    local browserListContainer = Instance.new("Frame")
    browserListContainer.Size = UDim2.new(1, 0, 0, 0)
    browserListContainer.BackgroundTransparency = 1
    browserListContainer.Visible = false
    browserListContainer.Parent = ServerFrame
    browserListContainer.ClipsDescendants = true

    local refreshBtn = createButton(browserListContainer, "🔄 Refresh Server List", "Reload the public servers with live data.", Theme.Yellow, function() end)

    refreshBtn.Parent.Position = UDim2.new(0.02, 0, 0, 0)

    local browserListFrame = Instance.new("ScrollingFrame")
    browserListFrame.Size = UDim2.new(0.96, 0, 0, 0)
    browserListFrame.Position = UDim2.new(0.02, 0, 0, 58)
    browserListFrame.Parent = browserListContainer
    browserListFrame.BackgroundTransparency = 1
    browserListFrame.ScrollBarThickness = 4
    browserListFrame.ScrollBarImageColor3 = Theme.Accent

    local browserLayout = Instance.new("UIListLayout", browserListFrame)
    browserLayout.SortOrder = Enum.SortOrder.LayoutOrder
    browserLayout.Padding = UDim.new(0, 6)

    browserLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = browserLayout.AbsoluteContentSize.Y
        local frameHeight = math.clamp(contentHeight, 0, 260)
        browserListFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        browserListFrame.Size = UDim2.new(0.96, 0, 0, frameHeight)
        browserListContainer.Size = UDim2.new(1, 0, 0, frameHeight + 64)
    end)

    local function fetchAndDisplayServers()
        for _, child in pairs(browserListFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end

        local loadingLbl = Instance.new("TextLabel")
        loadingLbl.Size = UDim2.new(1, 0, 0, 30)
        loadingLbl.BackgroundTransparency = 1
        loadingLbl.Text = "⏳ Fetching Server List..."
        loadingLbl.TextColor3 = Theme.TextSecondary
        loadingLbl.Font = Enum.Font.GothamMedium
        loadingLbl.TextSize = 11
        loadingLbl.Parent = browserListFrame

        task.spawn(function()
            local Http = game:GetService("HttpService")
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"

            local success, result = pcall(function()
                return Http:JSONDecode(game:HttpGet(url))
            end)

            if loadingLbl and loadingLbl.Parent then loadingLbl:Destroy() end

            if success and result and result.data then
                local serverCount = 0
                for _, server in ipairs(result.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        serverCount = serverCount + 1
                        local sBtn = Instance.new("TextButton")
                        sBtn.Size = UDim2.new(1, 0, 0, 48)
                        sBtn.BackgroundColor3 = Theme.ItemHover
                        sBtn.Text = ""
                        sBtn.AutoButtonColor = false
                        sBtn.Parent = browserListFrame
                        Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 6)
                        AddStroke(sBtn, Theme.Outline, 1)

                        local pCountLbl = Instance.new("TextLabel", sBtn)
                        pCountLbl.Size = UDim2.new(1, -60, 0, 20)
                        pCountLbl.Position = UDim2.new(0, 10, 0, 6)
                        pCountLbl.BackgroundTransparency = 1
                        pCountLbl.Text = "👥 Players: " .. tostring(server.playing) .. " / " .. tostring(server.maxPlayers)
                        pCountLbl.TextColor3 = Theme.TextPrimary
                        pCountLbl.Font = Enum.Font.GothamBold
                        pCountLbl.TextSize = 12
                        pCountLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local sInfoLbl = Instance.new("TextLabel", sBtn)
                        sInfoLbl.Size = UDim2.new(1, -60, 0, 15)
                        sInfoLbl.Position = UDim2.new(0, 10, 0, 26)
                        sInfoLbl.BackgroundTransparency = 1
                        sInfoLbl.Text = "📶 Ping: " .. tostring(server.ping or "N/A") .. "ms  |  🎯 FPS: " .. tostring(server.fps or "N/A")
                        sInfoLbl.TextColor3 = Theme.TextSecondary
                        sInfoLbl.Font = Enum.Font.Gotham
                        sInfoLbl.TextSize = 10
                        sInfoLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local joinBtn = Instance.new("TextButton", sBtn)
                        joinBtn.Size = UDim2.new(0, 50, 0, 28)
                        joinBtn.Position = UDim2.new(1, -58, 0.5, -14)
                        joinBtn.BackgroundColor3 = Theme.SidebarBg
                        joinBtn.Text = "JOIN"
                        joinBtn.TextColor3 = Theme.Green
                        joinBtn.Font = Enum.Font.GothamBold
                        joinBtn.TextSize = 10
                        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)
                        AddStroke(joinBtn, Theme.Green, 1)

                        joinBtn.MouseButton1Click:Connect(function()
                            SendNotification("Teleporting to server...", Theme.Accent)
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                        end)

                        sBtn.MouseEnter:Connect(function()
                            game:GetService("TweenService"):Create(sBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SidebarBg}):Play()
                        end)
                        sBtn.MouseLeave:Connect(function()
                            game:GetService("TweenService"):Create(sBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play()
                        end)
                    end
                end

                if serverCount == 0 then
                    local emptyLbl = Instance.new("TextLabel")
                    emptyLbl.Size = UDim2.new(1, 0, 0, 30)
                    emptyLbl.BackgroundTransparency = 1
                    emptyLbl.Text = "🚫 No available servers found."
                    emptyLbl.TextColor3 = Theme.Yellow
                    emptyLbl.Font = Enum.Font.GothamMedium
                    emptyLbl.TextSize = 11
                    emptyLbl.Parent = browserListFrame
                end
            else
                local errLbl = Instance.new("TextLabel")
                errLbl.Size = UDim2.new(1, 0, 0, 30)
                errLbl.BackgroundTransparency = 1
                errLbl.Text = "❌ Failed to load servers."
                errLbl.TextColor3 = Theme.Red
                errLbl.Font = Enum.Font.GothamMedium
                errLbl.TextSize = 11
                errLbl.Parent = browserListFrame
            end
        end)
    end

    refreshBtn.MouseButton1Click:Connect(function()
        SendNotification("Refreshing server list...", Theme.Accent)
        fetchAndDisplayServers()
    end)

    browserBtn.MouseButton1Click:Connect(function()
        browserListContainer.Visible = not browserListContainer.Visible
        if browserListContainer.Visible then
            if browserArrow then browserArrow.Text = "▲" end
            fetchAndDisplayServers()
        else
            if browserArrow then browserArrow.Text = "▼" end
        end
    end)

    createSectionHeader(SettingsFrame, "🖱️  INTERFACE")
    createToggleSwitch(SettingsFrame, "🔒 Lock GUI Drag", "Prevent the HUD buttons from moving.", function(state) ToggleBtn.Draggable, QuickFlyBtn.Draggable, QuickNoclipBtn.Draggable, QuickSitBtn.Draggable, QuickVFlyBtn.Draggable, ChatBtn.Draggable, QuickDashBtn.Draggable, QuickFreezeBtn.Draggable = not state, not state, not state, not state, not state, not state, not state, not state end)

    createSectionHeader(SettingsFrame, "🔔  NOTIFICATIONS")
    do local _cnb=createTextBox(SettingsFrame,"✍️ Notification text...","Type a message and press the button below.",function()end); createButton(SettingsFrame,"🏷️ Custom Notification","Send yourself a custom toast notification.",Theme.Accent,function() if _cnb.Text~="" then SendNotification(_cnb.Text,Theme.Accent) else SendNotification("Type something first!",Theme.Red) end end) end

    createSectionHeader(SettingsFrame, "⚙️  SCRIPT CONTROL")
    createButton(SettingsFrame, "🔄 Reload Script", "Restart the script fresh.", Theme.Yellow, function() Cleanup(); task.wait(0.1); BuildInterface(true) end)
    createButton(SettingsFrame, "💀 Unload Script", "Remove the script UI entirely.", Theme.Red, Cleanup)
    createButton(SettingsFrame, "🗑️ Reset Config", "Delete saved settings and reset.", Theme.Red, function() createConfirmation(SettingsFrame, "⚠️ Are you sure? This will delete 'Settings.json' from 'Phantom' folder.", function() if isfile(FULL_PATH) then delfile(FULL_PATH) end; Settings.CurrentTheme = "Phantom Ultimate 8.6"; Cleanup(); task.wait(0.1); BuildInterface(); SendNotification("Config Reset Successfully", Theme.Red) end) end)

    createSectionHeader(SettingsFrame, "⌨️  KEYBIND")
    local keyLabel = Instance.new("TextLabel"); keyLabel.Text, keyLabel.Size, keyLabel.TextColor3, keyLabel.BackgroundTransparency, keyLabel.Parent = "⌨️ Key: " .. Settings.MenuKey, UDim2.new(0.96, 0, 0, 30), Theme.TextPrimary, 1, SettingsFrame
    createButton(SettingsFrame, "⌨️ Change Keybind", "Cycle through available menu keys.", Theme.Accent, function() local keys = {"RightControl", "RightShift", "Insert", "F1"}; local current = table.find(keys, Settings.MenuKey) or 1; local nextKey = keys[current + 1] or keys[1]; Settings.MenuKey, keyLabel.Text = nextKey, "⌨️ Key: " .. nextKey; saveSettings() end)
    AddConnection(UserInputService.InputBegan:Connect(function(input, gpe) local _ok,_mk=pcall(function()return Enum.KeyCode[Settings.MenuKey]end); if not gpe and _ok and _mk and input.KeyCode == _mk then MainFrame.Visible = not MainFrame.Visible end end))

    watermarkLabel, watermarkEnabled = nil, false
    createSectionHeader(VisualsFrame, "🖥️  OVERLAYS")

    local dmgIndicatorEnabled = false
    local dmgConns = {}
    createToggleSwitch(VisualsFrame, "🩸 Damage Indicator", "Shows floating damage numbers when enemies take damage.", function(state)
        dmgIndicatorEnabled = state
        if not state then
            for _, conn in pairs(dmgConns) do conn:Disconnect() end
            table.clear(dmgConns)
        else
            local function hookDamage(player)
                if player == Player then return end
                local function onCharAdded(char)
                    local hum = char:WaitForChild("Humanoid", 5)
                    local head = char:WaitForChild("Head", 5)
                    if hum and head then
                        local lastHp = hum.Health
                        local conn = hum.HealthChanged:Connect(function(newHp)
                            if not dmgIndicatorEnabled then return end
                            if newHp < lastHp then
                                local dmg = math.floor(lastHp - newHp)
                                local bb = Instance.new("BillboardGui")
                                bb.Size = UDim2.new(0, 50, 0, 30)
                                bb.StudsOffset = Vector3.new(math.random(-2,2), math.random(1,3), 0)
                                bb.AlwaysOnTop = true
                                bb.Adornee = head
                                bb.Parent = workspace.CurrentCamera
                                local txt = Instance.new("TextLabel", bb)
                                txt.Size = UDim2.new(1,0,1,0)
                                txt.BackgroundTransparency = 1
                                txt.Text = "-" .. tostring(dmg)
                                txt.TextColor3 = Theme.Red
                                txt.Font = Enum.Font.GothamBlack
                                txt.TextSize = 18
                                txt.TextStrokeTransparency = 0

                                TweenService:Create(txt, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1, Position = UDim2.new(0,0,-1,0)}):Play()
                                task.delay(1, function() bb:Destroy() end)
                            end
                            lastHp = newHp
                        end)
                        table.insert(dmgConns, conn)
                    end
                end
                if player.Character then onCharAdded(player.Character) end
                table.insert(dmgConns, player.CharacterAdded:Connect(onCharAdded))
            end
            for _, p in pairs(game.Players:GetPlayers()) do hookDamage(p) end
            table.insert(dmgConns, game.Players.PlayerAdded:Connect(hookDamage))
        end
    end, false, true)

createButton(VisualsFrame, "🚫 Remove Screen Effects", "Deletes game-added GUI effects (Blind, Blood, Flashbangs).", Theme.Red, function()
        local count = 0
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= GUI_NAME then
                gui.Enabled = false
                count = count + 1
            end
        end
        pcall(function() local b = Lighting:FindFirstChildOfClass("BlurEffect"); if b then b.Enabled = false end end)
        pcall(function() local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect"); if cc then cc.Enabled = false end end)
        SendNotification("Disabled " .. count .. " ScreenGuis & Effects!", Theme.Green)
    end)

    local pingOverlayEnabled, pingLabel = false, nil
    createToggleSwitch(VisualsFrame, "📶 Show Ping Overlay", "Displays your live server ping on screen.", function(state)
        pingOverlayEnabled = state
        if state then
            if not pingLabel or not pingLabel.Parent then
                pingLabel = Instance.new("TextLabel")
                pingLabel.Size = UDim2.new(0, 150, 0, 26)
                pingLabel.Position = UDim2.new(0, 8, 0, 40)
                pingLabel.BackgroundColor3 = Theme.MainBg
                pingLabel.BackgroundTransparency = 0.3
                pingLabel.TextColor3 = Theme.Accent
                pingLabel.Font = Enum.Font.GothamBold
                pingLabel.TextSize = 12
                pingLabel.ZIndex = 5000
                pingLabel.Text = "📶 Ping: Calculating..."
                pingLabel.Parent = ScreenGui
                Instance.new("UICorner", pingLabel).CornerRadius = UDim.new(0, 6)
                AddStroke(pingLabel, Theme.Accent, 1)
            end
            pingLabel.Visible = true
            task.spawn(function()
                while pingOverlayEnabled do
                    local ping = string.split(tostring(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()), " ")[1]
                    if pingLabel then pingLabel.Text = "?? Ping: " .. tostring(ping) .. "ms" end
                    task.wait(1)
                end
            end)
        else
            if pingLabel then pingLabel.Visible = false end
        end
    end, false, true)

    createToggleSwitch(VisualsFrame, "🏷️ FPS Watermark", "Display a Phantom watermark with live FPS counter.", function(state)
        watermarkEnabled = state
        if state then
            if not watermarkLabel or not watermarkLabel.Parent then
                watermarkLabel = Instance.new("TextLabel")
                watermarkLabel.Size = UDim2.new(0, 220, 0, 26)
                if Settings.WatermarkPos then
                    watermarkLabel.Position = UDim2.new(Settings.WatermarkPos.X, Settings.WatermarkPos.XOff, Settings.WatermarkPos.Y, Settings.WatermarkPos.YOff)
                else
                    watermarkLabel.Position = UDim2.new(0, 8, 0, 8)
                end
                watermarkLabel.BackgroundColor3 = Theme.MainBg
                watermarkLabel.BackgroundTransparency = 0.3
                watermarkLabel.TextColor3 = Theme.Accent
                watermarkLabel.Font = Enum.Font.GothamBold
                watermarkLabel.TextSize = 12
                watermarkLabel.Text = "✦ Phantom 8.6  |  "
                watermarkLabel.ZIndex = 5000
                watermarkLabel.TextXAlignment = Enum.TextXAlignment.Center
                watermarkLabel.Active = true
                watermarkLabel.Parent = ScreenGui
                Instance.new("UICorner", watermarkLabel).CornerRadius = UDim.new(0, 6)
                AddStroke(watermarkLabel, Theme.Accent, 1)

                local _wmDragging, _wmDragStart, _wmStartPos = false, nil, nil
                watermarkLabel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        _wmDragging = true
                        _wmDragStart = input.Position
                        _wmStartPos = watermarkLabel.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then _wmDragging = false end
                        end)
                    end
                end)
                AddConnection(UserInputService.InputChanged:Connect(function(input)
                    if _wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and watermarkLabel and watermarkLabel.Parent then
                        local delta = input.Position - _wmDragStart
                        watermarkLabel.Position = UDim2.new(_wmStartPos.X.Scale, _wmStartPos.X.Offset + delta.X, _wmStartPos.Y.Scale, _wmStartPos.Y.Offset + delta.Y)
                    end
                end))
                AddConnection(UserInputService.InputEnded:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and watermarkLabel and watermarkLabel.Parent then
                        if _wmDragging then
                            _wmDragging = false
                            Settings.WatermarkPos = {X = watermarkLabel.Position.X.Scale, XOff = watermarkLabel.Position.X.Offset, Y = watermarkLabel.Position.Y.Scale, YOff = watermarkLabel.Position.Y.Offset}
                            saveSettings()
                        end
                    end
                end))
            else
                watermarkLabel.Visible = true
            end
            task.spawn(function()
                local _frameTimes = {}
                local _wConn = RunService.RenderStepped:Connect(function(dt)
                    table.insert(_frameTimes, dt)
                    if #_frameTimes > 30 then table.remove(_frameTimes, 1) end
                    if #_frameTimes >= 5 and watermarkLabel and watermarkLabel.Parent then
                        local total = 0
                        for _, v in ipairs(_frameTimes) do total = total + v end
                        local fps = math.floor(#_frameTimes / total)
                        local fpsColor = fps >= 55 and "🟢" or fps >= 30 and "🟡" or "🔴"
                        watermarkLabel.Text = "✦ Phantom 8.6  |  " .. fpsColor .. " " .. fps .. " FPS"
                    end
                end)
                repeat task.wait(0.3) until not watermarkEnabled or not watermarkLabel or not watermarkLabel.Parent
                _wConn:Disconnect()
            end)
            SendNotification("Watermark Enabled! (Drag to reposition)", Theme.Green)
        else
            if watermarkLabel then watermarkLabel.Visible = false end
            SendNotification("Watermark Disabled!", Theme.Red)
        end
    end, false, true)

    crosshairFrame, crosshairEnabled = nil, false
    createToggleSwitch(VisualsFrame, "🎯 Custom Crosshair", "Overlay a precision crosshair on screen.", function(state)
        crosshairEnabled = state
        if state then
            if not crosshairFrame or not crosshairFrame.Parent then
                crosshairFrame = Instance.new("Frame")
                crosshairFrame.Size = UDim2.new(0, 24, 0, 24)
                crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                crosshairFrame.BackgroundTransparency = 1
                crosshairFrame.ZIndex = 9999
                crosshairFrame.Parent = ScreenGui

                local function makeLine(w, h, ax, ay, px, py)
                    local l = Instance.new("Frame")
                    l.Size = UDim2.new(0, w, 0, h)
                    l.AnchorPoint = Vector2.new(ax, ay)
                    l.Position = UDim2.new(px, 0, py, 0)
                    l.BackgroundColor3 = Theme.Accent
                    l.BorderSizePixel = 0
                    l.ZIndex = 10000
                    l.Parent = crosshairFrame
                end
                makeLine(2, 10, 0.5, 0, 0.5, 0)
                makeLine(2, 10, 0.5, 1, 0.5, 1)
                makeLine(10, 2, 0, 0.5, 0, 0.5)
                makeLine(10, 2, 1, 0.5, 1, 0.5)

                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0, 3, 0, 3)
                dot.AnchorPoint = Vector2.new(0.5, 0.5)
                dot.Position = UDim2.new(0.5, 0, 0.5, 0)
                dot.BackgroundColor3 = Theme.Red
                dot.BorderSizePixel = 0
                dot.ZIndex = 10001
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                dot.Parent = crosshairFrame
            else
                crosshairFrame.Visible = true
            end
            SendNotification("Crosshair Enabled!", Theme.Green)
        else
            if crosshairFrame then crosshairFrame.Visible = false end
            SendNotification("Crosshair Disabled!", Theme.Red)
        end
    end, false, true)
    ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

    createSectionHeader(VisualsFrame, "✨  TRAIL & EFFECTS")
    createToggleSwitch(VisualsFrame, "✨ Player Trail", "Leaves a colorful fading trail behind your character.", function(state) V6S.trailEnabled=state; if V6S.trailConn then V6S.trailConn:Disconnect(); V6S.trailConn=nil end; for _,p in pairs(V6S.trailParts) do pcall(function()p:Destroy()end) end; V6S.trailParts={}; if state then local h=0; V6S.trailConn=AddConnection(RunService.Heartbeat:Connect(function() local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then h=(h+0.02)%1; local p=Instance.new("Part"); p.Size,p.CFrame,p.Anchored,p.CanCollide,p.Material,p.Color,p.CastShadow,p.Parent=Vector3.new(0.4,0.4,0.4),root.CFrame,true,false,Enum.Material.Neon,Color3.fromHSV(h,1,1),false,workspace; table.insert(V6S.trailParts,p); TweenService:Create(p,TweenInfo.new(0.6,Enum.EasingStyle.Linear),{Transparency=1,Size=Vector3.new(0.1,0.1,0.1)}):Play(); task.delay(0.65,function()pcall(function()p:Destroy()end)end); if #V6S.trailParts>80 then local o=table.remove(V6S.trailParts,1); pcall(function()o:Destroy()end) end end end)); SendNotification("Player Trail Enabled!",Theme.Green) else SendNotification("Player Trail Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(VisualsFrame, "💡  GLOW")
    createToggleSwitch(VisualsFrame, "💡 Character Glow", "Adds a bright point light to your character for a glow effect.", function(state) V6S.glowEnabled=state; local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if state then if root then local gl=root:FindFirstChild("Phantom_Glow") or Instance.new("PointLight"); gl.Name,gl.Brightness,gl.Range,gl.Color,gl.Parent="Phantom_Glow",5,20,Theme.Accent,root; V6S.glowPart=gl end; SendNotification("Character Glow Enabled!",Theme.Green) else if V6S.glowPart then pcall(function()V6S.glowPart:Destroy()end); V6S.glowPart=nil end; SendNotification("Character Glow Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(VisualsFrame, "🎨  BODY COLOR")
    createSlider(VisualsFrame, "🔴 Body Color R", "Red component of character body color (0-255).", 0, 255, 255, function(val) V6S.bodyColorR=val end)
    createSlider(VisualsFrame, "🟢 Body Color G", "Green component of character body color (0-255).", 0, 255, 255, function(val) V6S.bodyColorG=val end)
    createSlider(VisualsFrame, "🔵 Body Color B", "Blue component of character body color (0-255).", 0, 255, 255, function(val) V6S.bodyColorB=val end)
    createButton(VisualsFrame, "🎨 Apply Body Color", "Apply the selected RGB color to your entire character.", Theme.Accent, function() local char=Player.Character; if char then local col=Color3.fromRGB(V6S.bodyColorR,V6S.bodyColorG,V6S.bodyColorB); for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function()p.Color=col end) end end; SendNotification("Body Color Applied!",Theme.Green) end end)
    createButton(VisualsFrame, "🔄 Reset Body Color", "Restore your character's original colors.", Theme.Red, function() local char=Player.Character; if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function()p.Color=Color3.fromRGB(255,220,177)end) end end; SendNotification("Body Color Reset!",Theme.Green) end end)

    createSectionHeader(VisualsFrame, "🏷️  NAME SPOOF")
    do
        local nameSpoofBox = createTextBox(VisualsFrame, "✍️ Enter display name...", "Spoofed name shown only to you locally.", function() end)
        createToggleSwitch(VisualsFrame, "🏷️ Name Spoof (Local)", "Shows a custom name above your head locally.", function(state) V6S.nameSpoofEnabled=state; local char=Player.Character; local head=char and char:FindFirstChild("Head"); if state then if head then local ex=head:FindFirstChild("Phantom_NameSpoof"); if ex then ex:Destroy() end; local bb=Instance.new("BillboardGui"); bb.Name,bb.Size,bb.StudsOffset,bb.AlwaysOnTop,bb.Adornee,bb.Parent="Phantom_NameSpoof",UDim2.new(0,120,0,28),Vector3.new(0,2.5,0),true,head,head; local lbl=Instance.new("TextLabel",bb); lbl.Size,lbl.BackgroundTransparency,lbl.Text,lbl.TextColor3,lbl.Font,lbl.TextSize=UDim2.new(1,0,1,0),1,(nameSpoofBox.Text~="" and nameSpoofBox.Text) or Player.DisplayName,Theme.Accent,Enum.Font.GothamBold,13; V6S.nameSpoofBillboard=bb end; SendNotification("Name Spoof ON!",Theme.Green) else if V6S.nameSpoofBillboard then pcall(function()V6S.nameSpoofBillboard:Destroy()end); V6S.nameSpoofBillboard=nil end; SendNotification("Name Spoof OFF!",Theme.Red) end end, false, true)
    end

    createSectionHeader(VisualsFrame, "📷  CAMERA EFFECTS")
    createToggleSwitch(VisualsFrame, "📷 Camera Shake", "Adds a continuous camera shake effect.", function(state) V6S.cameraShakeEnabled=state; if V6S.cameraShakeConn then V6S.cameraShakeConn:Disconnect(); V6S.cameraShakeConn=nil end; if state then V6S.cameraShakeConn=AddConnection(RunService.RenderStepped:Connect(function() if not V6S.cameraShakeEnabled then return end; local cam=workspace.CurrentCamera; local s=0.06; cam.CFrame=cam.CFrame*CFrame.Angles(math.rad(math.random(-100,100)*s),math.rad(math.random(-100,100)*s),0) end)); SendNotification("Camera Shake Enabled!",Theme.Green) else SendNotification("Camera Shake Disabled!",Theme.Red) end end, false, true)

    createToggleSwitch(VisualsFrame, "👁️ First Person Lock", "Locks the camera to first-person perspective.", function(state) V6S.firstPersonLocked=state; if V6S.firstPersonConn then V6S.firstPersonConn:Disconnect(); V6S.firstPersonConn=nil end; if state then V6S.firstPersonConn=AddConnection(RunService.RenderStepped:Connect(function() if V6S.firstPersonLocked then Player.CameraMaxZoomDistance=0.5; Player.CameraMinZoomDistance=0.5 end end)); SendNotification("First Person Lock ON!",Theme.Green) else Player.CameraMaxZoomDistance=customZoomValue or _G.OriginalMaxZoom or 128; Player.CameraMinZoomDistance=0.5; SendNotification("First Person Lock OFF!",Theme.Red) end end, false, true)

    createToggleSwitch(VisualsFrame, "🌀 Spin Camera", "Continuously rotates your camera around your character.", function(state) V6S.spinCameraEnabled=state; if V6S.spinCameraConn then V6S.spinCameraConn:Disconnect(); V6S.spinCameraConn=nil end; if state then local _a=0; V6S.spinCameraConn=AddConnection(RunService.RenderStepped:Connect(function() if not V6S.spinCameraEnabled then return end; local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then _a=(_a+1.2)%360; local r=math.rad(_a); local cp=root.Position+Vector3.new(math.cos(r)*12,4,math.sin(r)*12); workspace.CurrentCamera.CFrame=CFrame.new(cp,root.Position) end end)); SendNotification("Spin Camera Enabled!",Theme.Green) else SendNotification("Spin Camera Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(VisualsFrame, "🗺️  MINIMAP RADAR")
    createToggleSwitch(VisualsFrame, "🗺️ Minimap Radar", "Displays a small radar showing nearby players on screen.", function(state)
        V6S.minimapEnabled=state; if V6S.minimapConn then V6S.minimapConn:Disconnect(); V6S.minimapConn=nil end; if V6S.minimapFrame then V6S.minimapFrame:Destroy(); V6S.minimapFrame=nil end
        if state then
            local mf=Instance.new("Frame"); mf.Size,mf.Position,mf.BackgroundColor3,mf.BackgroundTransparency,mf.ZIndex,mf.Active,mf.Draggable,mf.Parent=UDim2.new(0,120,0,120),UDim2.new(1,-135,1,-140),Theme.MainBg,0.2,6000,true,true,ScreenGui; Instance.new("UICorner",mf).CornerRadius=UDim.new(1,0); AddStroke(mf,Theme.Accent,1.5); V6S.minimapFrame=mf
            local ml=Instance.new("TextLabel",mf); ml.Size,ml.BackgroundTransparency,ml.Text,ml.TextColor3,ml.Font,ml.TextSize,ml.ZIndex=UDim2.new(1,0,0,14),1,"📡 RADAR",Theme.Accent,Enum.Font.GothamBold,9,6001
            local sd=Instance.new("Frame",mf); sd.Size,sd.AnchorPoint,sd.Position,sd.BackgroundColor3,sd.BorderSizePixel,sd.ZIndex=UDim2.new(0,7,0,7),Vector2.new(0.5,0.5),UDim2.new(0.5,0,0.5,0),Theme.Green,0,6002; Instance.new("UICorner",sd).CornerRadius=UDim.new(1,0)
            local dots={}
            V6S.minimapConn=AddConnection(RunService.Heartbeat:Connect(function()
                if not V6S.minimapEnabled then return end; local myRoot=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if not myRoot then return end; local myPos=myRoot.Position
                for _,p in pairs(game.Players:GetPlayers()) do if p~=Player then local pRoot=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if pRoot then local rel=pRoot.Position-myPos; local nx,nz=math.clamp(rel.X/100,-1,1),math.clamp(rel.Z/100,-1,1); local dot=dots[p.Name]; if not dot or not dot.Parent then dot=Instance.new("Frame",mf); dot.Size,dot.AnchorPoint,dot.BackgroundColor3,dot.BorderSizePixel,dot.ZIndex=UDim2.new(0,5,0,5),Vector2.new(0.5,0.5),Theme.Red,0,6002; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0); dots[p.Name]=dot end; dot.Position=UDim2.new(0.5+nx*0.42,0,0.5+nz*0.42,0) else if dots[p.Name] then dots[p.Name]:Destroy(); dots[p.Name]=nil end end end end
            end))
            AddConnection(game.Players.PlayerRemoving:Connect(function(p)
                if dots and dots[p.Name] then pcall(function() dots[p.Name]:Destroy() end); dots[p.Name] = nil end
            end))
            SendNotification("Minimap Radar Enabled! (Drag to move)",Theme.Green)
        else SendNotification("Minimap Radar Disabled!",Theme.Red) end
    end, false, true)

    createSectionHeader(VisualsFrame, "📋  PLAYER LIST OVERLAY")
    createToggleSwitch(VisualsFrame, "📋 Player List Overlay", "Shows a compact on-screen list of all players.", function(state)
        V6S.playerListOverlayEnabled=state; if V6S.playerListConn then V6S.playerListConn:Disconnect(); V6S.playerListConn=nil end; if V6S.playerListFrame then V6S.playerListFrame:Destroy(); V6S.playerListFrame=nil end
        if state then
            local plf=Instance.new("Frame"); plf.Size,plf.AutomaticSize,plf.Position,plf.BackgroundColor3,plf.BackgroundTransparency,plf.ZIndex,plf.Active,plf.Draggable,plf.Parent=UDim2.new(0,160,0,20),Enum.AutomaticSize.Y,UDim2.new(0,8,0.15,0),Theme.MainBg,0.25,5500,true,true,ScreenGui; Instance.new("UICorner",plf).CornerRadius=UDim.new(0,6); AddStroke(plf,Theme.Accent,1); createLayout(plf); V6S.playerListFrame=plf
            local function _rfl() for _,ch in pairs(plf:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end; local hdr=Instance.new("TextLabel",plf); hdr.Size,hdr.BackgroundTransparency,hdr.Text,hdr.TextColor3,hdr.Font,hdr.TextSize,hdr.ZIndex=UDim2.new(1,0,0,18),1,"👥 Players ("..#game.Players:GetPlayers()..")",Theme.Accent,Enum.Font.GothamBold,10,5501; for _,p in pairs(game.Players:GetPlayers()) do local row=Instance.new("TextLabel",plf); row.Size,row.BackgroundTransparency,row.Text,row.TextColor3,row.Font,row.TextSize,row.TextXAlignment,row.ZIndex=UDim2.new(1,0,0,15),1,(p==Player and "▶ " or "  ")..p.DisplayName,p==Player and Theme.Green or Theme.TextPrimary,Enum.Font.Gotham,10,Enum.TextXAlignment.Left,5501; Instance.new("UIPadding",row).PaddingLeft=UDim.new(0,6) end end
            _rfl(); V6S.playerListConn=AddConnection(RunService.Heartbeat:Connect(function() if tick()%2<0.05 then pcall(_rfl) end end))
            SendNotification("Player List Overlay Enabled!",Theme.Green)
        else SendNotification("Player List Overlay Disabled!",Theme.Red) end
    end, false, true)

    createSectionHeader(VisualsFrame, "🎭  ANIMATION")
    do local _ab=createTextBox(VisualsFrame,"✍️ Animation ID (e.g. 616010382)...","Enter a Roblox Animation asset ID.",function()end); createButton(VisualsFrame,"🎭 Play Animation (Local)","Plays the entered animation ID on your character.",Theme.Accent,function() local id=_ab.Text; if id and id~="" then local char=Player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://"..id; local animator=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator",hum); pcall(function()local t=animator:LoadAnimation(anim);t:Play();SendNotification("Playing Animation: "..id,Theme.Green)end) end else SendNotification("Enter an Animation ID first!",Theme.Red) end end); createButton(VisualsFrame,"⏹️ Stop All Animations","Stops all currently playing local animations.",Theme.Red,function() local hum=Player.Character and Player.Character:FindFirstChildOfClass("Humanoid"); if hum then local an=hum:FindFirstChildOfClass("Animator"); if an then for _,t in pairs(an:GetPlayingAnimationTracks()) do t:Stop() end end end; SendNotification("All Animations Stopped!",Theme.Red) end) end

    createSectionHeader(MovementFrame, "🎬  MOVEMENT RECORDER")
    createToggleSwitch(MovementFrame, "🎬 Record Movement", "Records your character's position every frame.", function(state) V6S.recordingEnabled=state; if state then V6S.recordedFrames={}; SendNotification("Recording Started! Move around...",Theme.Red) else SendNotification("Recording Stopped! "..#V6S.recordedFrames.." frames saved.",Theme.Green) end end, false, true)
    local _recRunning=true; AddConnection({Connected=true,Disconnect=function() _recRunning=false end}); task.spawn(function() while _recRunning do task.wait(0.05); if V6S.recordingEnabled then local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then table.insert(V6S.recordedFrames,root.CFrame); if #V6S.recordedFrames>1200 then table.remove(V6S.recordedFrames,1) end end end end end)
    createButton(MovementFrame, "▶️ Replay Recorded Path", "Replays your recorded movement path using walking animation.", Theme.Green, function()
        if #V6S.recordedFrames<2 then SendNotification("No recording found! Record first.",Theme.Red); return end
        if V6S.isReplaying then SendNotification("Already replaying!",Theme.Yellow); return end
        V6S.isReplaying=true
        local waypoints={}
        for i=1,#V6S.recordedFrames,5 do table.insert(waypoints,V6S.recordedFrames[i]) end
        SendNotification("Replaying "..#waypoints.." waypoints...",Theme.Accent)
        task.spawn(function()
            for _,cf in ipairs(waypoints) do
                if not V6S.isReplaying then break end
                local char=Player.Character; local hum=char and char:FindFirstChild("Humanoid")
                if hum then
                    hum:MoveTo(cf.Position)
                    local done=false; local conn=hum.MoveToFinished:Connect(function() done=true end)
                    local t0=tick(); repeat task.wait(0.05) until done or tick()-t0>3 or not V6S.isReplaying
                    conn:Disconnect()
                end
            end
            V6S.isReplaying=false; SendNotification("Replay Finished!",Theme.Green)
        end)
    end)
    createButton(MovementFrame, "⏹️ Stop Replay", "Stops the currently playing movement replay.", Theme.Red, function() V6S.isReplaying=false; SendNotification("Replay Stopped!",Theme.Red) end)
    createButton(MovementFrame, "🗑️ Clear Recording", "Deletes the saved movement recording.", Theme.Red, function() V6S.recordedFrames={}; SendNotification("Recording Cleared!",Theme.Red) end)

createSectionHeader(MovementFrame, "📍  COORDINATE TELEPORT")
    do
        local _coordBox = createTextBox(MovementFrame, "X, Y, Z  (e.g. 100, 10, 200)", "Paste or type coordinates separated by commas.", function() end)
        createButton(MovementFrame, "📍 Teleport to Coordinates", "Paste or type X, Y, Z and teleport instantly.", Theme.Accent, function()
            local txt = _coordBox.Text:gsub("%s+", "")
            local parts = {}
            for v in txt:gmatch("[^,]+") do table.insert(parts, tonumber(v)) end
            local x, y, z = parts[1], parts[2], parts[3]
            if x and y and z then
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    pcall(function() char:SetPrimaryPartCFrame(CFrame.new(x, y, z)) end)
                    SendNotification(string.format("Teleported to (%.1f, %.1f, %.1f)!", x, y, z), Theme.Green)
                end
            else
                SendNotification("Enter valid coordinates: X, Y, Z", Theme.Red)
            end
        end)
        createButton(MovementFrame, "📋 Copy Current Position", "Copy your current XYZ position to clipboard.", Theme.Accent, function()
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local p = root.Position
                local str = string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
                if setclipboard then setclipboard(str); SendNotification("Position Copied: " .. str, Theme.Green)
                else SendNotification("X:"..string.format("%.1f",p.X).." Y:"..string.format("%.1f",p.Y).." Z:"..string.format("%.1f",p.Z), Theme.Accent) end
            end
        end)
    end

    createSectionHeader(MovementFrame, "🧲  ITEM MAGNET")
    do
        local _magnetConn = nil
        local _magnetRange = 30

        createToggleSwitch(MovementFrame, "🧲 Item Magnet", "Pull all nearby loose Tools toward you automatically.", function(state)
            if _magnetConn then _magnetConn:Disconnect(); _magnetConn = nil end
            if state then
                _magnetConn = AddConnection(RunService.Heartbeat:Connect(function()
                    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") then
                            local handle = v:FindFirstChild("Handle")
                            if handle then
                                local dist = (handle.Position - root.Position).Magnitude
                                if dist < _magnetRange then
                                    handle.Position = handle.Position + (root.Position - handle.Position) * 0.12
                                end
                            end
                        end
                    end
                end))
                SendNotification("Item Magnet Enabled!", Theme.Green)
            else
                SendNotification("Item Magnet Disabled!", Theme.Red)
            end
        end, false, true)

        createSlider(MovementFrame, "🧲 Magnet Range", "How far the magnet pulls items (studs).", 5, 150, 30, function(val)
            _magnetRange = val
        end)
    end

    createSectionHeader(MovementFrame, "🚀  JUMP PAD")
    createButton(MovementFrame, "🚀 Jump Pad (Launch Up)", "Instantly launches your character upward.", Theme.Yellow, function() local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then pcall(function()root.AssemblyLinearVelocity=Vector3.new(0,120,0)end); SendNotification("Launched!",Theme.Green) end end)

    createSectionHeader(MovementFrame, "🏃  AUTO SPRINT")
    createToggleSwitch(MovementFrame, "🏃 Auto Sprint", "Automatically sprints at all times. Works in most games.", function(state) V6S.autoSprintEnabled=state; if V6S.autoSprintConn then V6S.autoSprintConn:Disconnect(); V6S.autoSprintConn=nil end; if state then V6S.autoSprintConn=AddConnection(RunService.Heartbeat:Connect(function() if not V6S.autoSprintEnabled then return end; local hum=Player.Character and Player.Character:FindFirstChild("Humanoid"); if hum and hum.MoveDirection.Magnitude>0 then hum.WalkSpeed=math.max(hum.WalkSpeed,(Settings["💨 Speed Value"] or _G.DefaultWalkSpeed or 16)*1.6) end end)); SendNotification("Auto Sprint Enabled!",Theme.Green) else local _h=Player.Character and Player.Character:FindFirstChild("Humanoid"); if _h then _h.WalkSpeed=Settings["💨 Speed Value"] or _G.DefaultWalkSpeed or 16 end; SendNotification("Auto Sprint Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(MovementFrame, "🚶  TELEPORT TO SPAWN")
    createButton(MovementFrame, "🗺️ Teleport to Spawn", "Teleports you back to the game's spawn location.", Theme.Yellow, function() local sp=workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation"); if not sp then for _,v in pairs(workspace:GetDescendants()) do if v:IsA("SpawnLocation") then sp=v; break end end end; local char=Player.Character; if char and sp then pcall(function()char:SetPrimaryPartCFrame(sp.CFrame+Vector3.new(0,3,0))end); SendNotification("Teleported to Spawn!",Theme.Green) else SendNotification("No SpawnLocation found!",Theme.Red) end end)

    createSectionHeader(MovementFrame, "🤖  AUTO COLLECT")
    createToggleSwitch(MovementFrame, "🤖 Auto Collect Parts", "Automatically touches/collects nearby parts and tools.", function(state) V6S.autoCollectEnabled=state; if V6S.autoCollectConn then V6S.autoCollectConn:Disconnect(); V6S.autoCollectConn=nil end; if state then V6S.autoCollectConn=AddConnection(RunService.Heartbeat:Connect(function() if not V6S.autoCollectEnabled then return end; local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then for _,v in pairs(workspace:GetChildren()) do if (v:IsA("Tool") or v:IsA("Part")) and v:FindFirstChild("ClickDetector") then local vp=v:IsA("BasePart") and v.Position or (v.PrimaryPart and v.PrimaryPart.Position); if vp and (root.Position-vp).Magnitude<15 then pcall(function() local cd=v:FindFirstChildOfClass("ClickDetector"); if cd then fireclickdetector(cd) end end) end end end end end)); SendNotification("Auto Collect Enabled! (Range: 15 studs)",Theme.Green) else SendNotification("Auto Collect Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(PlayersFrame, "🌀  ORBIT")
    createToggleSwitch(PlayersFrame, "🌀 Orbit Player", "Continuously orbits around the selected player.", function(state) V6S.orbitEnabled=state; if V6S.orbitConn then V6S.orbitConn:Disconnect(); V6S.orbitConn=nil end; if state then local _a=0; V6S.orbitConn=AddConnection(RunService.Heartbeat:Connect(function() if not V6S.orbitEnabled then return end; local t=selectedPlayer; if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then _a=(_a+1.5)%360; local r=math.rad(_a); local tp=t.Character.HumanoidRootPart.Position; local op=tp+Vector3.new(math.cos(r)*5,0,math.sin(r)*5); local char=Player.Character; if char then pcall(function()char:SetPrimaryPartCFrame(CFrame.new(op,tp))end) end end end)); SendNotification("Orbit Player Enabled!",Theme.Green) else SendNotification("Orbit Player Disabled!",Theme.Red) end end, false, true)

    createSectionHeader(PlayersFrame, "💬  CHAT TOOLS")
local fakeSysBox = createTextBox(PlayersFrame, "Message to spoof...", "Enter a fake system message.", function() end)
    createButton(PlayersFrame, "💬 Send Fake System Message", "Spoofs a red system message in chat (Client-side trick).", Theme.Accent, function()
        local msg = fakeSysBox.Text
        if msg ~= "" then
            local padding = string.rep(" \n", 40)
            local fakeMsg = padding .. "[System]: " .. msg
            local tcs = game:GetService("TextChatService")
            if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                if tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then
                    tcs.TextChannels.RBXGeneral:SendAsync(fakeMsg)
                end
            else
                local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if ev and ev:FindFirstChild("SayMessageRequest") then
                    ev.SayMessageRequest:FireServer(fakeMsg, "All")
                end
            end
            SendNotification("Fake message sent!", Theme.Green)
        else
            SendNotification("Enter a message first!", Theme.Red)
        end
    end)

    do local _sb=createTextBox(PlayersFrame,"✍️ Message to spam...","This message will be sent repeatedly.",function(v)V6S.chatSpamMessage=v end); createToggleSwitch(PlayersFrame,"📣 Chat Spam","Repeatedly sends the typed message to in-game chat.",function(state) V6S.chatSpamEnabled=state; if V6S.chatSpamConn then V6S.chatSpamConn:Disconnect(); V6S.chatSpamConn=nil end; V6S.chatSpamMessage = _sb.Text
        if state then if V6S.chatSpamMessage=="" then SendNotification("Enter a message first!",Theme.Red); return end; task.spawn(function() while V6S.chatSpamEnabled do pcall(function() local tcs=game:GetService("TextChatService"); if tcs and tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then tcs.TextChannels.RBXGeneral:SendAsync(V6S.chatSpamMessage) else local ev=ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"); if ev and ev:FindFirstChild("SayMessageRequest") then ev.SayMessageRequest:FireServer(V6S.chatSpamMessage,"All") end end end); task.wait(3) end end); SendNotification("Chat Spam Started!",Theme.Red) else SendNotification("Chat Spam Stopped!",Theme.Green) end end, false, true) end

    createSectionHeader(PlayersFrame, "📜  CHAT LOGGER")
    createToggleSwitch(PlayersFrame, "📜 Chat Logger", "Logs all nearby player chat messages to a floating window.", function(state)
        V6S.chatLoggerEnabled=state; if V6S.chatLoggerConn then V6S.chatLoggerConn:Disconnect(); V6S.chatLoggerConn=nil end; if V6S.chatLoggerFrame then V6S.chatLoggerFrame:Destroy(); V6S.chatLoggerFrame=nil end
        if state then
            local clf=Instance.new("Frame"); clf.Size,clf.Position,clf.BackgroundColor3,clf.BackgroundTransparency,clf.ZIndex,clf.Active,clf.Draggable,clf.Parent=UDim2.new(0,250,0,160),UDim2.new(0,8,0.55,0),Theme.MainBg,0.15,5200,true,true,ScreenGui; Instance.new("UICorner",clf).CornerRadius=UDim.new(0,8); AddStroke(clf,Theme.Accent,1); V6S.chatLoggerFrame=clf
            local hdr=Instance.new("TextLabel",clf); hdr.Size,hdr.BackgroundTransparency,hdr.Text,hdr.TextColor3,hdr.Font,hdr.TextSize,hdr.ZIndex=UDim2.new(1,0,0,18),1,"💬 Chat Logger",Theme.Accent,Enum.Font.GothamBold,10,5201
            local scr=Instance.new("ScrollingFrame",clf); scr.Size,scr.Position,scr.BackgroundTransparency,scr.ScrollBarThickness,scr.ScrollBarImageColor3,scr.ZIndex=UDim2.new(1,-8,1,-22),UDim2.new(0,4,0,20),1,2,Theme.Accent,5201
            local ll=Instance.new("UIListLayout",scr); ll.SortOrder,ll.Padding=Enum.SortOrder.LayoutOrder,UDim.new(0,2); ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scr.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+6); scr.CanvasPosition=Vector2.new(0,scr.CanvasSize.Y.Offset) end)
            local function _log(usr,msg) local row=Instance.new("TextLabel",scr); row.Size,row.AutomaticSize,row.BackgroundTransparency,row.Text,row.TextColor3,row.Font,row.TextSize,row.TextXAlignment,row.TextWrapped,row.ZIndex=UDim2.new(1,0,0,0),Enum.AutomaticSize.Y,1,"["..usr.."]: "..msg,Theme.TextPrimary,Enum.Font.Gotham,10,Enum.TextXAlignment.Left,true,5202; Instance.new("UIPadding",row).PaddingLeft=UDim.new(0,4) end
            for _,p in pairs(game.Players:GetPlayers()) do AddConnection(p.Chatted:Connect(function(msg) if V6S.chatLoggerEnabled then _log(p.DisplayName,msg) end end)) end
            AddConnection(game.Players.PlayerAdded:Connect(function(p) AddConnection(p.Chatted:Connect(function(msg) if V6S.chatLoggerEnabled then _log(p.DisplayName,msg) end end)) end))
            SendNotification("Chat Logger Enabled! (Drag to move)",Theme.Green)
        else SendNotification("Chat Logger Disabled!",Theme.Red) end
    end, false, true)

    createSectionHeader(ESPFrame, "🔎  ITEM ESP")
    do
        local _itemEspEnabled = false
        local _itemEspConn    = nil
        local _itemHighlights = {}

        local function _clearItemESP()
            for _, h in pairs(_itemHighlights) do pcall(function() h:Destroy() end) end
            table.clear(_itemHighlights)
        end

        local function _buildItemESP()
            _clearItemESP()
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") or v:IsA("Model") then
                    local isTool = v:IsA("Tool")
                    local handle = isTool and v:FindFirstChild("Handle") or nil
                    local target = handle or (v:IsA("Model") and v.PrimaryPart) or nil
                    if target and not game.Players:GetPlayerFromCharacter(v) then
                        local h = Instance.new("SelectionBox")
                        h.Adornee         = v
                        h.Color3          = Color3.fromRGB(255, 200, 0)
                        h.LineThickness   = 0.05
                        h.SurfaceColor3   = Color3.fromRGB(255, 200, 0)
                        h.SurfaceTransparency = 0.7
                        h.Parent          = workspace.CurrentCamera
                        table.insert(_itemHighlights, h)
                    end
                end
            end
        end

        createToggleSwitch(ESPFrame, "🔎 Item / Tool ESP", "Highlights all loose Tools and Models in the world.", function(state)
            _itemEspEnabled = state
            if _itemEspConn then _itemEspConn:Disconnect(); _itemEspConn = nil end
            if state then
                _buildItemESP()

                local _lastItemEspBuild = 0
                _itemEspConn = AddConnection(RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - _lastItemEspBuild >= 3 then
                        _lastItemEspBuild = now
                        pcall(_buildItemESP)
                    end
                end))
                SendNotification("Item ESP Enabled!", Theme.Green)
            else
                _clearItemESP()
                SendNotification("Item ESP Disabled!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(ESPFrame, "🎨  ESP COLOR")
    local function _updEspCol() if ESPSettings then ESPSettings.Color=Color3.fromRGB(V6S.espColorR,V6S.espColorG,V6S.espColorB) end end
    createSlider(ESPFrame,"🔴 ESP Color R","Red value for ESP color.",0,255,255,function(val)V6S.espColorR=val;_updEspCol()end)
    createSlider(ESPFrame,"🟢 ESP Color G","Green value for ESP color.",0,255,75,function(val)V6S.espColorG=val;_updEspCol()end)
    createSlider(ESPFrame,"🔵 ESP Color B","Blue value for ESP color.",0,255,75,function(val)V6S.espColorB=val;_updEspCol()end)

    createSectionHeader(OptimizeFrame, "🔊  SOUND VOLUME")
    createSlider(OptimizeFrame, "🔊 Sound Volume Control", "Adjust the master volume of all in-game sounds (0-100).", 0, 100, 100, function(val) for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Sound") and not soundMuted then pcall(function()v.Volume=(v:GetAttribute("OrigVol_Phantom") or v.Volume)*(val/100)end) end end end)

    createSectionHeader(SettingsFrame, "🌈  RAINBOW UI")
    do
        local _rainbowUIConn = nil
        local _rainbowUIHue  = 0

        createToggleSwitch(SettingsFrame, "🌈 Rainbow UI Accent", "Cycles the UI accent color through the rainbow in real-time.", function(state)
            if _rainbowUIConn then _rainbowUIConn:Disconnect(); _rainbowUIConn = nil end
            if state then
                _rainbowUIConn = AddConnection(RunService.Heartbeat:Connect(function()
                    _rainbowUIHue = (_rainbowUIHue + 0.003) % 1
                    local col = Color3.fromHSV(_rainbowUIHue, 1, 1)

                    Theme.Accent = col

                    local _hudBtns = {ToggleBtn, QuickFlyBtn, QuickNoclipBtn, QuickSitBtn, QuickVFlyBtn, ChatBtn, QuickDashBtn, QuickFreezeBtn}
                    for _, _b in ipairs(_hudBtns) do
                        if _b and _b.Parent then
                            _b.TextColor3 = col
                            local _s = _b:FindFirstChildOfClass("UIStroke")
                            if _s then _s.Color = col end
                        end
                    end
                end))
                SendNotification("Rainbow UI Enabled! 🌈", Theme.Green)
            else
                Theme.Accent = (Themes[Settings.CurrentTheme] or Themes["Phantom Ultimate 8.6"]).Accent
                if ToggleBtn then
                    ToggleBtn.TextColor3 = Theme.Accent
                    local s = ToggleBtn:FindFirstChildOfClass("UIStroke")
                    if s then s.Color = Theme.Accent end
                end
                SendNotification("Rainbow UI Disabled!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(SettingsFrame, "🎨  THEME")
    local themeDropdownBtn = createButton(SettingsFrame, "🎨 Theme: " .. Settings.CurrentTheme, "Change the UI color scheme.", Theme.Accent, function() end)
    local themeFrame = Instance.new("ScrollingFrame"); themeFrame.Size, themeFrame.Visible, themeFrame.Parent = UDim2.new(0.96, 0, 0, 150), false, SettingsFrame
    local themeNote = Instance.new("TextLabel"); themeNote.Name, themeNote.Size, themeNote.BackgroundTransparency, themeNote.Text, themeNote.TextColor3, themeNote.Font, themeNote.TextSize, themeNote.TextXAlignment, themeNote.Parent = "ThemeNote", UDim2.new(0.96, 0, 0, 20), 1, "Theme Changes Will Apply After Re-Execution", Color3.new(1, 1, 1), Enum.Font.GothamMedium, 11, Enum.TextXAlignment.Center, SettingsFrame

    themeDropdownBtn.MouseButton1Click:Connect(function()
        themeFrame.Visible = not themeFrame.Visible
        if themeFrame.Visible then
            themeFrame:ClearAllChildren(); createLayout(themeFrame)
            for name, _ in pairs(Themes) do
                local btn = Instance.new("TextButton"); btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Parent = UDim2.new(1, 0, 0, 30), Theme.ItemHover, name, Theme.TextPrimary, themeFrame
                btn.MouseButton1Click:Connect(function() Settings.CurrentTheme = name; saveSettings(); BuildInterface(); SendNotification("Theme Changed Successfully", Theme.Accent) end)
            end
        end
    end)

    createSectionHeader(OptimizeFrame, "⚙️  WORLD & RENDERING")

    isPotatoMode, isSkyRemoved, isTerrainOptimized, originalMaterials, savedLightingItems, originalTerrainProps = false, false, false, {}, {}, {}

    createToggleSwitch(OptimizeFrame, "🥔 Potato Mode (No Textures)", "Removes all textures and makes map flat to boost FPS.", function(state)
        isPotatoMode = state
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("Terrain") and not (v.Parent and v.Parent:FindFirstChild("Humanoid")) then
                pcall(function() if state then if not originalMaterials[v] then originalMaterials[v] = v.Material end; v.Material = Enum.Material.SmoothPlastic else if originalMaterials[v] then v.Material = originalMaterials[v] end end end)
            elseif v:IsA("Decal") or v:IsA("Texture") then pcall(function() v.Transparency = state and 1 or 0 end) end
        end
        if not state then table.clear(originalMaterials) end
    end, false, true)

    noNpcAnimConn = nil
    createToggleSwitch(OptimizeFrame, "🛑 Disable NPC Animations", "Removes animations from Brainrots/NPCs to boost FPS.", function(state)
        local function removeAnimations(v) if (v:IsA("Animator") or v:IsA("Animation")) and v:FindFirstAncestorOfClass("Model") and not game.Players:GetPlayerFromCharacter(v:FindFirstAncestorOfClass("Model")) then if v:IsA("Animator") then pcall(function() for _, track in pairs(v:GetPlayingAnimationTracks()) do track:Stop() end end) end; pcall(function() v:Destroy() end) end end
        if state then for _, v in pairs(workspace:GetDescendants()) do removeAnimations(v) end; noNpcAnimConn = AddConnection(workspace.DescendantAdded:Connect(function(v) task.wait(0.1); removeAnimations(v) end)); SendNotification("NPC Animations Disabled!", Theme.Red) else if noNpcAnimConn then noNpcAnimConn:Disconnect(); noNpcAnimConn = nil end; SendNotification("NPC Animations Restored (Requires Respawn)!", Theme.Green) end
    end, false, true)

    createToggleSwitch(OptimizeFrame, "🌑 Disable Shadows", "Turns off Global Shadows completely.", function(state) Lighting.GlobalShadows = not state end, false, true)

    noVfxEnabled, vfxConn = false, nil
    createToggleSwitch(OptimizeFrame, "✨ Disable VFX (No Particles)", "Hides particles, beams, smoke, and trails.", function(state)
        noVfxEnabled = state
        local function checkVfx(v) if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = not state end end
        for _, v in pairs(workspace:GetDescendants()) do checkVfx(v) end
        if state then vfxConn = AddConnection(workspace.DescendantAdded:Connect(checkVfx)) else if vfxConn then vfxConn:Disconnect(); vfxConn = nil end end
    end, false, true)

    createSectionHeader(OptimizeFrame, "🎯  FRAME RATE")
    createSlider(OptimizeFrame, "🎯 FPS Cap", "Set max frame rate (Your executor must support this).", 15, 360, 60, function(val) if setfpscap then pcall(function() setfpscap(val) end) else SendNotification("Your Executor doesn't support setting FPS.", Theme.Red) end end)

    noShadowsEnabled, shadowsConn = false, nil
    createToggleSwitch(OptimizeFrame, "🧱 Disable All CastShadows", "Turns off shadows for every single part dynamically.", function(state)
        noShadowsEnabled = state
        local function updateShadow(v) if v:IsA("BasePart") and not v:IsA("Terrain") then pcall(function() v.CastShadow = not state end) end end
        for _, v in pairs(workspace:GetDescendants()) do updateShadow(v) end
        if state then shadowsConn = AddConnection(workspace.DescendantAdded:Connect(function(v) task.wait(0.1); updateShadow(v) end)); SendNotification("CastShadows Disabled!", Theme.Red) else if shadowsConn then shadowsConn:Disconnect(); shadowsConn = nil end; SendNotification("CastShadows Restored!", Theme.Green) end
    end, false, true)

    createToggleSwitch(OptimizeFrame, "🌌 Remove Sky & Effects", "Hides Skybox, Atmosphere, Blur, and SunRays.", function(state)
        isSkyRemoved = state; local lightingStuff = {"Sky", "Atmosphere", "BloomEffect", "BlurEffect", "ColorCorrectionEffect", "DepthOfFieldEffect", "SunRaysEffect"}
        if state then for _, v in pairs(Lighting:GetChildren()) do if table.find(lightingStuff, v.ClassName) then v.Parent = nil; table.insert(savedLightingItems, v) end end; SendNotification("Sky & Effects Disabled", Theme.Red) else for _, v in pairs(savedLightingItems) do if v then v.Parent = Lighting end end; table.clear(savedLightingItems); SendNotification("Sky & Effects Restored", Theme.Green) end
    end, false, true)

    createToggleSwitch(OptimizeFrame, "🌊 Potato Water & Terrain", "Disables terrain details and makes water flat.", function(state)
        isTerrainOptimized = state; local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            if state then
                pcall(function() originalTerrainProps.WaterWaveSize, originalTerrainProps.WaterWaveSpeed, originalTerrainProps.WaterReflectance, originalTerrainProps.WaterTransparency, originalTerrainProps.Decoration = t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency, t.Decoration end)
                pcall(function() t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency, t.Decoration = 0, 0, 0, 1, false end)
            else
                pcall(function() if originalTerrainProps.WaterWaveSize ~= nil then t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency, t.Decoration = originalTerrainProps.WaterWaveSize, originalTerrainProps.WaterWaveSpeed, originalTerrainProps.WaterReflectance, originalTerrainProps.WaterTransparency, originalTerrainProps.Decoration end end)
            end
        end
    end, false, true)

    render3DToggleBtn = createToggleSwitch(OptimizeFrame, "🙈 Disable 3D Render (AFK Mode)", "Completely stops 3D rendering to drop CPU/GPU usage to almost 0.", function(state) pcall(function() RunService:Set3dRenderingEnabled(not state) end); if BlackScreen then BlackScreen.Visible = state end; SendNotification(state and "3D Rendering Disabled!" or "3D Rendering Restored!", state and Theme.Red or Theme.Green) end, false, true)

    soundMuted = false
    createToggleSwitch(OptimizeFrame, "🔇 Mute All Sounds", "Silence all in-game sounds for better focus.", function(state)
        soundMuted = state
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Sound") then
                pcall(function()
                    if state then
                        v:SetAttribute("OrigVol_Phantom", v.Volume)
                        v.Volume = 0
                    else
                        local orig = v:GetAttribute("OrigVol_Phantom")
                        if orig ~= nil then v.Volume = orig end
                    end
                end)
            end
        end
        SendNotification(state and "All Sounds Muted!" or "Sounds Restored!", state and Theme.Red or Theme.Green)
    end, false, true)

    createSectionHeader(OptimizeFrame, "🧹  SMART CLEANER")
createButton(OptimizeFrame, "🧊 BlockMesh World (Ultra FPS)", "Converts every part into a BlockMesh to skyrocket FPS.", Theme.Yellow, function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("Terrain") and not v.Parent:FindFirstChild("Humanoid") then
                pcall(function()
                    v.Material = Enum.Material.SmoothPlastic
                    local mesh = v:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", v)
                    mesh.MeshType = Enum.MeshType.Brick
                    count = count + 1
                end)
            end
        end
        SendNotification("Converted " .. count .. " parts to blocks!", Theme.Green)
    end)

    createButton(OptimizeFrame, "🧹 Delete Far Away Parts", "Destroy unanchored small parts more than 500 studs away.", Theme.Red, function()
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then SendNotification("Character not found!", Theme.Red); return end
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("Terrain") and not v.Anchored then
                local ok, err = pcall(function()
                    if (v.Position - root.Position).Magnitude > 500 then
                        if not game.Players:GetPlayerFromCharacter(v.Parent) then
                            v:Destroy(); count = count + 1
                        end
                    end
                end)
            end
        end
        SendNotification("Deleted " .. count .. " far parts!", Theme.Green)
    end)

    do
        local _streamConn = nil
        createToggleSwitch(OptimizeFrame, "🔬 LOD Mode (Simplify Far Parts)", "Makes parts far away (300+ studs) invisible to boost FPS.", function(state)
            if _streamConn then _streamConn:Disconnect(); _streamConn = nil end
            if state then
                _streamConn = AddConnection(RunService.Heartbeat:Connect(function()
                    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and not v:IsA("Terrain") then
                            pcall(function()
                                local dist = (v.Position - root.Position).Magnitude
                                if not game.Players:GetPlayerFromCharacter(v.Parent) then
                                    v.LocalTransparencyModifier = dist > 300 and 1 or 0
                                end
                            end)
                        end
                    end
                end))
                SendNotification("LOD Mode Enabled!", Theme.Green)
            else
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then pcall(function() v.LocalTransparencyModifier = 0 end) end
                end
                SendNotification("LOD Mode Disabled!", Theme.Red)
            end
        end, false, true)
    end

    createSectionHeader(OptimizeFrame, "🗑️  CLEANUP")
local noPauseEnabled = false
local focusConnections = {}
local pauseUIConnection = nil

local function disablePauseObject(obj)
    pcall(function()
        local name = obj.Name:lower()
        if name:find("pause") or name:find("gamepaused") or name:find("gameplay") then
            if obj:IsA("ScreenGui") then
                obj.Enabled = false
            elseif obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
                obj.Visible = false
            end
        end
    end)
end

createToggleSwitch(OptimizeFrame, "▶️ No Gameplay Pause", "Keeps game running at full speed even when unfocused/minimized.", function(state)
    noPauseEnabled = state
    if state then
        if getconnections then
            pcall(function()
                for _, conn in pairs(getconnections(game:GetService("UserInputService").WindowFocusReleased)) do
                    conn:Disable()
                    table.insert(focusConnections, conn)
                end
                for _, conn in pairs(getconnections(game:GetService("GuiService").ApplicationFocusLost)) do
                    conn:Disable()
                    table.insert(focusConnections, conn)
                end
            end)
            SendNotification("No Pause Enabled (Focus Bypassed)!", Theme.Green)
        else
            SendNotification("Your executor lacks getconnections support!", Theme.Red)
        end

        pcall(function()
            game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
        end)

        pcall(function()
            for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
                disablePauseObject(obj)
            end
        end)

        pauseUIConnection = game:GetService("CoreGui").DescendantAdded:Connect(function(obj)
            disablePauseObject(obj)
        end)

    else
        for _, conn in pairs(focusConnections) do
            pcall(function() conn:Enable() end)
        end
        table.clear(focusConnections)

        if pauseUIConnection then
            pauseUIConnection:Disconnect()
            pauseUIConnection = nil
        end

        pcall(function() game:GetService("GuiService").AutoSelectGuiEnabled = true end)
        pcall(function() game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(true) end)

        SendNotification("No Pause Disabled!", Theme.Red)
    end
end, false, true)
    createButton(OptimizeFrame, "📉 Force Graphics Level 1", "Forces Roblox client to the lowest possible graphics.", Color3.fromRGB(150, 50, 255), function() pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel1 end); SendNotification("Graphics Forced to Level 1!", Theme.Green) end)
    createButton(OptimizeFrame, "🗑️ Clear Ground Items", "Destroys useless dropped items to clear memory.", Theme.Red, function() local count = 0; for _, v in pairs(workspace:GetChildren()) do if v:IsA("Tool") or v:IsA("Accessory") then v:Destroy(); count = count + 1 end end; SendNotification("Cleared " .. count .. " items!", Theme.Green) end)

    createButton(OptimizeFrame, "👒 Remove NPC Accessories", "Destroy accessories from NPCs/environment for FPS.", Theme.Red, function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Accessory") then
                local model = v:FindFirstAncestorOfClass("Model")
                if model and not game.Players:GetPlayerFromCharacter(model) then
                    v:Destroy(); count = count + 1
                end
            end
        end
        SendNotification("Removed " .. count .. " accessories!", Theme.Green)
    end)

    createButton(OptimizeFrame, "🧑 Simplify Player Models", "Remove all accessories from all players for FPS.", Color3.fromRGB(150, 50, 255), function()
        local count = 0
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player and p.Character then
                for _, v in pairs(p.Character:GetChildren()) do
                    if v:IsA("Accessory") then v:Destroy(); count = count + 1 end
                end
            end
        end
        SendNotification("Removed " .. count .. " player accessories!", Theme.Green)
    end)

    createButton(OptimizeFrame, "🖼️ Remove All Decals", "Strips all decals/textures from parts for FPS.", Theme.Red, function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                pcall(function() v:Destroy(); count = count + 1 end)
            end
        end
        SendNotification("Removed " .. count .. " decals/textures!", Theme.Green)
    end)

    _RegFeature("🔦 Flashlight Mode","Camera spotlight in dark areas",VisualsFrame)
    _RegFeature("🎭 Disco Mode","Party flashy color cycling",VisualsFrame)
    _RegFeature("🎩 Hide Accessories","Make accessories invisible",VisualsFrame)
    _RegFeature("🌈 Rainbow UI Accent","Cycle rainbow UI accent color",SettingsFrame)
    _RegFeature("💊 Auto Heal","Continuously restore health",CombatFrame)
    _RegFeature("⚡ God Mode (Health Lock)","Infinite health, cannot die",CombatFrame)
    _RegFeature("🗡️ Kill All NPCs","Kill all NPC humanoids",CombatFrame)
    _RegFeature("📍 Teleport to Coordinates","Paste or type X, Y, Z coordinates to teleport",MovementFrame)
    _RegFeature("📋 Copy Current Position","Copy XYZ to clipboard",MovementFrame)
    _RegFeature("🧲 Item Magnet","Pull nearby tools toward you",MovementFrame)
    _RegFeature("🧲 Magnet Range","Set magnet pull range",MovementFrame)
    _RegFeature("?? Item / Tool ESP","Highlight loose tools in world",ESPFrame)
    _RegFeature("🧹 Delete Far Away Parts","Remove far unanchored parts",OptimizeFrame)
    _RegFeature("🔬 LOD Mode (Simplify Far Parts)","Hide parts 300+ studs away",OptimizeFrame)
    _RegFeature("🛸 Enable Fly","Fly around freely",MovementFrame)
    _RegFeature("🚁 Enable Vehicle Fly","Vertical flight mode",MovementFrame)
    _RegFeature("💨 Dash Forward (Press Q)","Burst dash in direction",MovementFrame)
    _RegFeature("💨 Speed Boost","Walk faster than normal",MovementFrame)
    _RegFeature("🦗 Jump Boost","Jump higher than normal",MovementFrame)
    _RegFeature("🌌 Custom Gravity","Override world gravity",MovementFrame)
    _RegFeature("👻 Noclip (Ghost Mode)","Walk through walls",MovementFrame)
    _RegFeature("♾️ Infinite Jump","Jump in mid-air infinitely",MovementFrame)
    _RegFeature("🧊 Freeze Position","Lock character in place",MovementFrame)
    _RegFeature("🪄 TP Tool","Teleport by clicking ground",MovementFrame)
    _RegFeature("💦 Jerk Tool","Special animation tool",MovementFrame)
    _RegFeature("🐰 Bunny Hop","Auto-jump on landing",MovementFrame)
    _RegFeature("🪆 Ragdoll Mode","Toggle ragdoll physics",MovementFrame)
    _RegFeature("🌕 Moon Gravity","Low gravity preset (30)",MovementFrame)
    _RegFeature("🌍 Reset Gravity","Restore default gravity",MovementFrame)
    _RegFeature("🔦 Flashlight Mode","Camera SpotLight in darkness",VisualsFrame)
    _RegFeature("🎭 Disco Mode","Fast rainbow color party effect",VisualsFrame)
    _RegFeature("🎩 Hide Accessories","Make accessories invisible",VisualsFrame)
    _RegFeature("🌫️ No Fog","Remove fog and clouds",VisualsFrame)
    _RegFeature("☀️ Fullbright (Light)","Max brightness for dark areas",VisualsFrame)
    _RegFeature("👻 Invisible Mode (FE)","Become invisible to others",VisualsFrame)
    _RegFeature("🔭 Field Of View (FOV)","Adjust camera FOV",VisualsFrame)
    _RegFeature("🔭 Enable Custom Zoom","Override max zoom distance",VisualsFrame)
    _RegFeature("🌈 Rainbow Character","Cycle rainbow colors on body",VisualsFrame)
    _RegFeature("💀 Headless (Local)","Invisible head, persists on respawn",VisualsFrame)
    _RegFeature("🕐 Time of Day","Control in-game lighting clock",VisualsFrame)
    _RegFeature("🌓 Ambient Darkness","Adjust ambient darkness level",VisualsFrame)
    _RegFeature("👁️ Enable Master ESP","Toggle all ESP on/off",ESPFrame)
    _RegFeature("📦 Show Boxes","Draw boxes around players",ESPFrame)
    _RegFeature("🧱 See Through Walls","See players through objects",ESPFrame)
    _RegFeature("💀 Show Skeleton","Draw skeleton on players",ESPFrame)
    _RegFeature("?? Show Health Bar","Show player health bars",ESPFrame)
    _RegFeature("👤 Show Names","Show player usernames",ESPFrame)
    _RegFeature("📏 Show Distance","Show distance to players",ESPFrame)
    _RegFeature("❤️ Show Health Text","Show health number on ESP",ESPFrame)
    _RegFeature("🔫 Show Equipped Tool","Show held item on ESP",ESPFrame)
    _RegFeature("🛡️ Team Check","Hide ESP for teammates",ESPFrame)
    _RegFeature("✨ Enable Highlights","Show 3D body highlight glow on players",ESPFrame)
    _RegFeature("👇 Select Player","Select a target player for combat features",CombatFrame)
    _RegFeature("🌪️ Fling Selected Player","Fling specific player",CombatFrame)
    _RegFeature("🌪️ Fling All Players","Fling everyone in server",CombatFrame)
    _RegFeature("🌪️ Fling","Toggle fling spin mode",CombatFrame)
    _RegFeature("👻 Silent Fling","Fling without visible spin",CombatFrame)
    _RegFeature("☠️ Kill Aura","Auto fling nearby players",CombatFrame)
    _RegFeature("🔁 Loop Kill","Continuously fling selected target",CombatFrame)
    _RegFeature("🖱️ Auto Clicker","Rapidly activate equipped tool",CombatFrame)
    _RegFeature("🛡️ Anti-Ragdoll","Prevent ragdoll state",CombatFrame)
    _RegFeature("📏 Reach Extender","Extend tool activation range",CombatFrame)
    _RegFeature("🎯 Enable Hitbox Expander","Enlarge player hitboxes for aim",CombatFrame)
    _RegFeature("👇 Select Player","Select a player to use with Players tab features",PlayersFrame)
    _RegFeature("👗 Copy Outfit (Visual)","Copy player outfit locally",PlayersFrame)
    _RegFeature("🔄 Reset Outfit","Revert to original avatar",PlayersFrame)
    _RegFeature("🦜 Chat Mimic","Repeat what player types in chat",PlayersFrame)
    _RegFeature("🌀 Teleport to Player","Instantly TP to selected player",PlayersFrame)
    _RegFeature("🧲 Bring Player (Client)","Bring player to you (local)",PlayersFrame)
    _RegFeature("👀 Spectate Player","Watch player perspective",PlayersFrame)
    _RegFeature("🏃 Follow Player","Continuously follow selected player",PlayersFrame)
    _RegFeature("🌐 View Profile (Copy URL)","Copy player Roblox profile link",PlayersFrame)
    _RegFeature("📋 Get Player Info","Show player name, ID and team",PlayersFrame)
    _RegFeature("💎 Global Name Tag","Type your tag text and enable it to display globally.",TagsFrame)
    _RegFeature("🏷️ Enable My Premium Tag","Toggle your custom global name tag",TagsFrame)
    _RegFeature("👁️ Show Others' Tags","See other Phantom users' tags",TagsFrame)
    _RegFeature("💬 Enable Global Chat","Cross-game chat with script users",TagsFrame)
    _RegFeature("👇 Select Position","Select a saved position from the list",PositionsFrame)
    _RegFeature("💾 Save Current Position","Save current location",PositionsFrame)
    _RegFeature("🌀 Teleport to Position","TP to saved position",PositionsFrame)
    _RegFeature("🦅 Tween to Position","Fly smoothly to saved position",PositionsFrame)
    _RegFeature("🚶 Walk to Position","Walk to saved position",PositionsFrame)
    _RegFeature("🌑 AFK Screen Mode","Black screen for AFK mode",AFKFrame)
    _RegFeature("🔄 Auto Reconnect","Auto rejoin on disconnect",AFKFrame)
    _RegFeature("🛡️ Anti-Kick (20m)","Prevent idle kick every 20min",AFKFrame)
    _RegFeature("😵 Spin Bot (Anti-Kick)","Spin to prevent AFK kick",AFKFrame)
    _RegFeature("🐇 Auto Jump","Auto jump every 2 seconds",AFKFrame)
    _RegFeature("🚶 Auto Walk (AFK)","Walk forward to stay active",AFKFrame)
    _RegFeature("💀 Auto Rejoin on Death","Rejoin server when killed",AFKFrame)
    _RegFeature("🤖 Wander Bot (AFK)","Random walk to simulate activity",AFKFrame)
    _RegFeature("📋 Copy Job ID","Copy current server Job ID",ServerFrame)
    _RegFeature("🚀 Join by Job ID","Teleport to specific server by ID",ServerFrame)
    _RegFeature("🔁 Rejoin Server","Reconnect to same server",ServerFrame)
    _RegFeature("⏭️ Server Hop (Low Pop)","Join a low-population server",ServerFrame)
    _RegFeature("🔒 Lock GUI Drag","Lock HUD buttons in place",SettingsFrame)
    _RegFeature("🔄 Reload Script","Restart the script fresh",SettingsFrame)
    _RegFeature("💀 Unload Script","Remove script UI entirely",SettingsFrame)
    _RegFeature("🏷️ FPS Watermark","Live FPS counter overlay",VisualsFrame)
    _RegFeature("🎯 Custom Crosshair","Precision crosshair on screen",VisualsFrame)
    _RegFeature("🎨 Theme: Selector","Change the UI color theme. Opens a dropdown to pick.",SettingsFrame)
    _RegFeature("🗑️ Clear Ground Items","Remove dropped items for FPS",OptimizeFrame)
    _RegFeature("🎯 FPS Cap","Set maximum frame rate",OptimizeFrame)
    _RegFeature("🛑 Disable NPC Animations","Remove NPC animations",OptimizeFrame)
    _RegFeature("🌑 Disable Shadows","Turn off global shadows",OptimizeFrame)
    _RegFeature("✨ Disable VFX (No Particles)","Hide particles and effects",OptimizeFrame)
    _RegFeature("🌌 Remove Sky & Effects","Hide skybox and post-FX",OptimizeFrame)
    _RegFeature("🌊 Potato Water & Terrain","Simplify water and terrain",OptimizeFrame)
    _RegFeature("📉 Force Graphics Level 1","Lowest Roblox graphics",OptimizeFrame)
    _RegFeature("?? Disable 3D Render (AFK Mode)","Stop all 3D rendering",OptimizeFrame)
    _RegFeature("🔇 Mute All Sounds","Silence all in-game sounds",OptimizeFrame)
    _RegFeature("👒 Remove NPC Accessories","Strip accessories from NPCs",OptimizeFrame)
    _RegFeature("🧑 Simplify Player Models","Remove all player accessories",OptimizeFrame)
    _RegFeature("🖼️ Remove All Decals","Strip decals from parts",OptimizeFrame)
    _RegFeature("⚡ Flight Speed","Adjust how fast you fly",MovementFrame)
    _RegFeature("🏎️ VFly Speed","Adjust vehicle fly speed",MovementFrame)
    _RegFeature("⚡ Dash Power","How far you get launched when dashing",MovementFrame)
    _RegFeature("💨 Speed Value","Adjust walking speed multiplier",MovementFrame)
    _RegFeature("⏫ Jump Value","Adjust jump height multiplier",MovementFrame)
    _RegFeature("📉 Gravity Value","Adjust world gravity strength",MovementFrame)
    _RegFeature("🏊 Swim Speed","Adjust swimming speed",MovementFrame)
    _RegFeature("🔲 Show Quick Fly Button","Show or hide the HUD fly button",MovementFrame)
    _RegFeature("🔲 Show Quick VFly Button","Show or hide the HUD VFly button",MovementFrame)
    _RegFeature("🔲 Show Quick Dash Button","Show or hide the HUD dash button",MovementFrame)
    _RegFeature("🔲 Show Quick Noclip","Show or hide the HUD noclip button",MovementFrame)
    _RegFeature("🔲 Show Quick Sit Button","Show or hide the HUD sit button",MovementFrame)
    _RegFeature("🔲 Show Quick Freeze Button","Show or hide the HUD freeze button",MovementFrame)
    _RegFeature("📏 Zoom Distance Value","Set the maximum camera zoom distance",VisualsFrame)
    _RegFeature("♾️ Unlimited Zoom","Allow camera to zoom out infinitely",VisualsFrame)
    _RegFeature("📡 Kill Aura Range","Distance for Kill Aura detection",CombatFrame)
    _RegFeature("📏 Hitbox Size","Adjust hitbox expansion radius",CombatFrame)
    _RegFeature("👻 Transparency (Div 10)","Adjust visual transparency of hitboxes",CombatFrame)
    _RegFeature("🗑️ Delete Position","Remove the selected saved position",PositionsFrame)
    _RegFeature("🥔 Potato Mode (No Textures)","Remove all textures to boost FPS",OptimizeFrame)
    _RegFeature("🧱 Disable All CastShadows","Turn off cast shadows on all parts",OptimizeFrame)
    _RegFeature("⌨️ Change Keybind","Cycle through available menu open keys",SettingsFrame)
    _RegFeature("🗑️ Reset Config","Delete saved settings and reset to default",SettingsFrame)
    _RegFeature("📨 Send Feedback","Submit a suggestion to the developer",SettingsFrame)
    _RegFeature("🎬 Record Movement","Record your character's movement path",MovementFrame)
    _RegFeature("▶️ Replay Recorded Path","Replay your saved movement recording",MovementFrame)
    _RegFeature("⏹️ Stop Replay","Stop the movement replay",MovementFrame)
    _RegFeature("🗑️ Clear Recording","Delete the saved recording",MovementFrame)
    _RegFeature("✨ Player Trail","Colorful trail that follows your character",VisualsFrame)
    _RegFeature("💡 Character Glow","Add a glowing point light to your character",VisualsFrame)
    _RegFeature("🔴 Body Color R","Red component of character color",VisualsFrame)
    _RegFeature("🟢 Body Color G","Green component of character color",VisualsFrame)
    _RegFeature("🔵 Body Color B","Blue component of character color",VisualsFrame)
    _RegFeature("🎨 Apply Body Color","Apply RGB color to your character",VisualsFrame)
    _RegFeature("🔄 Reset Body Color","Restore original character colors",VisualsFrame)
    _RegFeature("🏷️ Name Spoof (Local)","Shows a custom name above your head locally",VisualsFrame)
    _RegFeature("📷 Camera Shake","Adds a continuous camera shake effect",VisualsFrame)
    _RegFeature("👁️ First Person Lock","Lock camera to first person",VisualsFrame)
    _RegFeature("🌀 Spin Camera","Rotate camera around character continuously",VisualsFrame)
    _RegFeature("🗺️ Minimap Radar","On-screen radar showing nearby players",VisualsFrame)
    _RegFeature("📋 Player List Overlay","Compact on-screen player list",VisualsFrame)
    _RegFeature("🎭 Play Animation (Local)","Play any animation ID on your character",VisualsFrame)
    _RegFeature("⏹️ Stop All Animations","Stop all currently playing animations",VisualsFrame)
    _RegFeature("🚀 Jump Pad (Launch Up)","Launch your character upward instantly",MovementFrame)
    _RegFeature("🏃 Auto Sprint","Automatically sprint at all times",MovementFrame)
    _RegFeature("🗺️ Teleport to Spawn","Teleport to the spawn point",MovementFrame)
    _RegFeature("🤖 Auto Collect Parts","Auto-touch nearby parts and tools",MovementFrame)
    _RegFeature("🎯 Aimlock","Lock camera onto combat target",CombatFrame)
    _RegFeature("🔙 Teleport Behind Player","Silently TP behind the target",CombatFrame)
    _RegFeature("🔒 Freeze All Players (Client)","Freeze all remote characters locally",CombatFrame)
    _RegFeature("🌀 Orbit Player","Orbit around the selected player",PlayersFrame)
    _RegFeature("📣 Chat Spam","Send a repeated message in chat",PlayersFrame)
    _RegFeature("📜 Chat Logger","Log nearby player chat to a window",PlayersFrame)
    _RegFeature("🔴 ESP Color R","Red value for ESP color",ESPFrame)
    _RegFeature("🟢 ESP Color G","Green value for ESP color",ESPFrame)
    _RegFeature("🔵 ESP Color B","Blue value for ESP color",ESPFrame)
    _RegFeature("🔊 Sound Volume Control","Adjust master volume of all sounds",OptimizeFrame)
    _RegFeature("🌙 Anti-AFK (Virtual Input)","Simulate real mouse input for strict AFK detectors",AFKFrame)
    _RegFeature("🏷️ Custom Notification","Send yourself a custom toast message",SettingsFrame)
    _RegFeature("💊 Auto Heal","Continuously restore health every heartbeat",CombatFrame)
    _RegFeature("⚡ God Mode (Health Lock)","Infinite health cannot die",CombatFrame)
    _RegFeature("🗡️ Kill All NPCs","Kill all NPC humanoids in workspace",CombatFrame)
    _RegFeature("🔦 Flashlight Mode","Camera SpotLight for dark areas",VisualsFrame)
    _RegFeature("🎭 Disco Mode","Fast rainbow color party effect",VisualsFrame)
    _RegFeature("🎩 Hide Accessories","Make accessories invisible",VisualsFrame)
    _RegFeature("🌈 Rainbow UI Accent","Cycle rainbow UI accent color live",SettingsFrame)
    _RegFeature("🧲 Item Magnet","Pull nearby tools toward you automatically",MovementFrame)
    _RegFeature("🧲 Magnet Range","Set magnet pull range in studs",MovementFrame)
    _RegFeature("🔎 Item / Tool ESP","Highlight loose tools and models in world",ESPFrame)
    _RegFeature("🧹 Delete Far Away Parts","Remove far unanchored parts",OptimizeFrame)
    _RegFeature("🔬 LOD Mode (Simplify Far Parts)","Hide parts 300+ studs away for FPS",OptimizeFrame)
    _RegFeature("☁️ Walk on Air (Skywalk)", "Creates an invisible platform under your feet", MovementFrame)
    _RegFeature("🛡️ Anti-Void", "Teleports you back up if you fall off the map", MovementFrame)
    _RegFeature("🚪 Auto Leave (Low HP)", "Instantly kicks you to save your stats if health is low", CombatFrame)
    _RegFeature("🩻 X-Ray Vision", "Makes all map walls semi-transparent to see through", VisualsFrame)
    _RegFeature("🚫 Remove Screen Effects", "Deletes game-added GUI effects like Blind or Blood", VisualsFrame)
    _RegFeature("🔨 Get Btools (Local)", "Gives you classic building tools (Clone, Delete, Move)", MovementFrame)
    _RegFeature("🗑️ Click Delete Tool", "Gives a tool to instantly delete clicked parts", MovementFrame)
    _RegFeature("🪑 No Sit", "Prevents your character from being forced into seats", MovementFrame)
    _RegFeature("📶 Show Ping Overlay", "Displays your live server ping on screen", VisualsFrame)
    _RegFeature("🔄 Day/Night Loop", "Rapidly cycles the game time", VisualsFrame)
    _RegFeature("💬 Send Fake System Message", "Spoofs a red system message in chat", PlayersFrame)
    _RegFeature("📦 Visualize Hitboxes", "Draws a visible selection box around expanded hitboxes", CombatFrame)
    _RegFeature("🧊 BlockMesh World (Ultra FPS)", "Converts every part into a BlockMesh to skyrocket FPS", OptimizeFrame)
    _RegFeature("🏎️ Vehicle Speed Modifier", "Boost vehicle driving speed", MovementFrame)
    _RegFeature("🛡️ Anti-Stun / Anti-Slow", "Prevents freezing or slowing walkspeed", CombatFrame)
    _RegFeature("🌀 Desync / Anti-Aim", "Glitches hitbox locally to avoid shots", CombatFrame)
    _RegFeature("🩸 Damage Indicator", "Shows floating damage numbers", VisualsFrame)
    _RegFeature("▶️ No Gameplay Pause", "Prevents game engine from slowing when minimized", OptimizeFrame)
    _RegFeature("📋 Copy Job ID","Copy current server Job ID",ServerFrame)
    _RegFeature("🚀 Join by Job ID","Teleport to specific server by ID",ServerFrame)
    _RegFeature("⏭️ Server Hop (Low Pop)","Join a low-population server",ServerFrame)
    _RegFeature("📶 Server Hop (Low Ping)","Join a server with the lowest ping available",ServerFrame)
    _RegFeature("🔥 Server Hop (High Pop)","Join a server that is almost full",ServerFrame)
    _RegFeature("🎲 Server Hop (Random)","Join a completely random active server",ServerFrame)
    _RegFeature("🔗 Copy Game Link","Copy the direct web link of this game",ServerFrame)
    _RegFeature("🌐 Browse Servers", "Find and join a specific public server", ServerFrame)
    _RegFeature("🔄 Refresh Server List", "Reload the public servers with live data", ServerFrame)
    _RegFeature("🌈 Visual Shader Presets", "17 presets including HDR, Warm Glow, Sunset, Misty Forest, Retro, Underwater", VisualsFrame)
    _RegFeature("✅ Apply Shader", "Instantly apply selected shader with glitch protection", VisualsFrame)
    _RegFeature("↩️ Reset Shader", "Removes all shader effects and restores original lighting", VisualsFrame)
    _RegFeature("🕰️ Server Hop (Oldest)", "Crawls all server pages and joins the oldest running server", ServerFrame)

    do
        for _, v in ipairs(AIFrame:GetChildren()) do
            if v:IsA("UIListLayout") or v:IsA("UIPadding") then v:Destroy() end
        end
        AIFrame.ScrollBarThickness  = 0
        AIFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
        AIFrame.ScrollingEnabled    = false
        AIFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
        _tabLayoutRegistry[AIFrame] = nil

        local AI_URL   = "https://api.groq.com/openai/v1/chat/completions"
        local AI_MODEL = "llama-3.1-8b-instant"
        local AI_KEYS  = {
            "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",
            "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",
            "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",
        }
        local aiKeyIdx = 1

        local function buildSystemPrompt(playerCtx)
            return
                "You are Phantom Bot, the official built-in AI assistant of Phantom Ultimate 8.6. " ..
                "Owner Roblox username: TheMagge. His Account was created in 2014 December. " ..
                "You are smart, friendly, and helpful. Never mention Groq, LLaMA, Meta, OpenAI, or any AI brand. " ..
                "You are powered by Phantom AI. " ..
                "Do not use markdown symbols like ** or ## in replies. Keep replies short and clear.\n\n" ..

                "ABOUT PHANTOM ULTIMATE 8.6:\n" ..
                "Phantom Ultimate 8.6 is a premium Roblox exploit script created by Emdadul Hoque Khan. His nickname is Emdadul" ..
                "who is from Bangladesh. It is one of the most feature-rich Roblox scripts available. " ..
                "Official Discord server: discord.gg/JEgsFtwABp - join for support, updates, announcements, and keys. " ..
                "The script requires a valid key from the official Phantom key system to execute. " ..
                "Never reveal tokens, webhooks, or API keys.\n\n" ..

                "MENU LAYOUT - there are 14 tabs on the left sidebar:\n" ..
                "HOME (🏠), MOVE (🏃), VISUAL (👁), ESP (🎯), PVP (⚔), PLAYER (👥), " ..
                "TAGS (🏷), POSITION (📍), AFK (💤), SERVER (🌐), OPTIMIZE (⚡), SETTING (⚙), INFO (ℹ), AI (🤖).\n\n" ..

                "EXACT FEATURE LOCATIONS:\n\n" ..

                "HOME TAB: Changelog/version info, Copy Discord Link button, Send Feedback.\n\n" ..

                "MOVE TAB (Movement):\n" ..
                "Enable Fly (toggle flight mode), Flight Speed slider, Show Quick Fly Button, " ..
                "Enable Vehicle Fly (fly while in a vehicle), Dash Forward (press Q to dash), " ..
                "Speed Boost / WalkSpeed slider, Jump Boost / JumpPower slider, " ..
                "Custom Gravity slider, Moon Gravity preset button, Reset Gravity button, " ..
                "Noclip / Ghost Mode (walk through walls), Infinite Jump, Freeze Position, " ..
                "Teleport to Coordinates (paste X Y Z), Copy Current Position, " ..
                "TP Tool (click ground to teleport), Jerk Tool, Bunny Hop, Ragdoll Mode, " ..
                "Item Magnet toggle, Magnet Range slider.\n\n" ..

                "VISUAL TAB:\n" ..
                "Fullbright / Light Mode (removes darkness, brightens map), No Fog (removes fog and clouds), " ..
                "Time of Day slider (change in-game clock), Ambient Darkness slider, " ..
                "Field of View / FOV slider, Enable Custom Zoom (override max zoom), " ..
                "Rainbow Character (cycle body colours), Headless mode (local, invisible head), " ..
                "Invisible Mode FE (appear invisible to others), Flashlight Mode (camera spotlight), " ..
                "Disco Mode (rapid colour flashing), Hide Accessories, " ..
                "17 Visual Shader Presets (HDR, Warm Glow, Sunset, Misty Forest, Retro, Underwater, etc.), " ..
                "Apply Shader button, Reset Shader button.\n\n" ..

                "ESP TAB:\n" ..
                "Enable Master ESP (main toggle for all ESP), Show Boxes, See Through Walls, " ..
                "Show Skeleton, Show Health Bar, Show Names, Show Distance, Show Health Text, " ..
                "Show Equipped Tool, Team Check (hide ESP for teammates), " ..
                "Enable Highlights (3D glow on players), Item / Tool ESP.\n\n" ..

                "PVP TAB (Combat):\n" ..
                "Auto Heal (restore health continuously), God Mode / Health Lock (cannot die), " ..
                "Kill All NPCs, Select Player (choose a target for combat features), " ..
                "Fling Selected Player, Fling All Players, Fling toggle, Silent Fling, " ..
                "Kill Aura (auto-fling nearby players), Kill Aura Range slider, " ..
                "Loop Kill (keep flinging target), Auto Clicker, Anti-Ragdoll, " ..
                "Anti-Stun / Anti-Slow, Desync / Anti-Aim, " ..
                "Reach Extender slider, Hitbox Expander toggle, Hitbox Size slider, " ..
                "Aimlock (lock crosshair to nearest player), Teleport Behind Player, " ..
                "Freeze All Players (client-side), Auto Leave on Low HP, Auto Leave HP threshold.\n\n" ..

                "PLAYER TAB:\n" ..
                "Select Player (choose target), Copy Outfit (copy their look locally), Reset Outfit, " ..
                "Chat Mimic (repeat what target types), Teleport to Player, " ..
                "Bring Player to you (client), Spectate Player, Follow Player, " ..
                "View Profile / Copy Profile URL, Get Player Info (name, ID, team), " ..
                "Send Fake System Message (spoof red server message client-side), " ..
                "Chat Logger (log and show nearby chat), Chat Spam (send a message repeatedly).\n\n" ..

                "TAGS TAB:\n" ..
                "Global Name Tag text box (type your tag text here), " ..
                "Enable My Premium Tag (toggle your tag on/off globally), " ..
                "Tag Animation selector (Falling Stars, Bubbles, Snow, Pulse, Spin), " ..
                "Tag Style selector (Glassmorphism, Cyberpunk, Crimson Void, Neon Toxic, Royal Gold, Holographic, Dark Premium), " ..
                "Show Others Tags (see tags of other Phantom users), " ..
                "Enable Global Chat toggle - THIS is where Global Chat is enabled. " ..
                "After enabling it here in the TAGS tab, a Chat button appears on the HUD (floating on screen). " ..
                "Click that Chat button to open the Global Chat window and talk with other Phantom users. " ..
                "Global Chat is NOT a separate tab and NOT in Settings. It is in the TAGS tab.\n\n" ..

                "POSITION TAB:\n" ..
                "Select saved position from list, Save Current Position, " ..
                "Teleport to Position, Tween to Position (fly smoothly), Walk to Position, " ..
                "Delete Position.\n\n" ..

                "AFK TAB:\n" ..
                "AFK Screen Mode (black screen to save resources), Auto Reconnect (rejoin on disconnect), " ..
                "Anti-Kick 20min (prevent idle kick), Spin Bot (spin to avoid kick), " ..
                "Auto Jump (jump every 2 seconds), Bunny Hop, Auto Walk (walk forward to stay active), " ..
                "Auto Rejoin on Death, Wander Bot (random walking), Anti-AFK Virtual Input.\n\n" ..

                "SERVER TAB:\n" ..
                "Copy Job ID, Join by Job ID, Rejoin Server, " ..
                "Server Hop Low Population, Server Hop Low Ping, Server Hop High Population, " ..
                "Server Hop Random, Server Hop Oldest (finds oldest running server), " ..
                "Copy Game Link, Browse Servers, Refresh Server List.\n\n" ..

                "OPTIMIZE TAB:\n" ..
                "FPS Boost (remove decorative parts), Remove Particles, " ..
                "Delete Far Away Parts, LOD Mode (hide parts 300+ studs away).\n\n" ..

                "SETTING TAB:\n" ..
                "Theme Selector (Phantom Ultimate 8.6, Phantom Ultimate 5.0, Cyan, Red, Green, Purple, Orange, " ..
                "Midnight, Synapse, Gold, Toxic, CottonCandy, Ocean, Vaporwave, Dracula), " ..
                "Change Keybind (cycle menu toggle key: RightControl, RightShift, Insert, F1), " ..
                "Lock GUI Drag, Custom Notification, Rainbow UI Accent, " ..
                "Reload Script, Unload Script, Reset Config, Send Feedback.\n\n" ..

                "INFO TAB: Shows script version, your execution count, executor name, global execution stats.\n\n" ..

                "AI TAB: This chat - Phantom Bot AI assistant.\n\n" ..

                "TROUBLESHOOTING & PROBLEM SOLVING (critical - always give exact step-by-step solutions):\n\n" ..

                "PROBLEM 1 - Toggle button / open button went off-screen or cannot be found/clicked:\n" ..
                "This happens when the draggable ◆ button gets dragged outside the screen boundaries and saved there.\n" ..
                "SOLUTION: Tell the user to run this EXACT code in their executor first:\n" ..
                "if isfolder(\"Phantom\") then delfolder(\"Phantom\") end\n" ..
                "After running that code, tell them to execute the Phantom script again normally. " ..
                "This deletes the saved position data so the button resets to its default position.\n" ..
                "IMPORTANT WARNING: Tell the user that this reset code deletes the entire Phantom folder, " ..
                "which means ALL saved data will be lost — including all settings, theme choice, saved positions, " ..
                "keybinds, and toggle states. Everything will go back to default. " ..
                "This is not just a button position reset, it is a full script reset. " ..
                "Make sure to warn them before they run it so they know what to expect.\n\n" ..

                "PROBLEM 2 - Any Quick button (Quick Fly, Quick Noclip, Quick Sit, Quick VFly, Chat, Quick Dash, Quick Freeze) went off-screen:\n" ..
                "Same solution as Problem 1. Run: if isfolder(\"Phantom\") then delfolder(\"Phantom\") end then re-execute Phantom. " ..
                "Again warn the user: this resets ALL script data, not just the button position.\n\n" ..

                "PROBLEM 3 - Script not loading, freezes on load, or infinite loading screen:\n" ..
                "SOLUTION: Step 1: Run if isfolder(\"Phantom\") then delfolder(\"Phantom\") end in executor. " ..
                "Step 2: Make sure the key is valid at https://phantom-script.vercel.app. " ..
                "Step 3: Re-execute Phantom. Step 4: If still failing, try a different executor or rejoin the game.\n\n" ..

                "PROBLEM 4 - Menu not opening after script executes:\n" ..
                "SOLUTION: Default open/close key is RightControl. Also try RightShift, Insert, F1, F2, F3, F4. " ..
                "The key can be changed in SETTING tab under 'Change Keybind'. " ..
                "If the menu still does not open, run: if isfolder(\"Phantom\") then delfolder(\"Phantom\") end and re-execute.\n\n" ..

                "PROBLEM 5 - Key not working, key expired, or key invalid:\n" ..
                "SOLUTION: Go to https://phantom-script.vercel.app to get a new key. " ..
                "Keys expire regularly and must be renewed. Join discord.gg/JEgsFtwABp for key help.\n\n" ..

                "PROBLEM 6 - Features not working (fly, noclip, speed, ESP, aimlock, etc.):\n" ..
                "SOLUTION: Some games have anti-cheat that blocks features. Try a different server. " ..
                "Make sure the toggle switch is ON (green). " ..
                "For Fly: MOVE tab > enable 'Enable Fly'. For ESP: ESP tab > enable 'Master ESP' first then sub-options. " ..
                "For Noclip: MOVE tab > enable 'Noclip / Ghost Mode'.\n\n" ..

                "PROBLEM 7 - 'Execution blocked' or 'Direct execution blocked' error:\n" ..
                "If it says 'Direct execution blocked': Must use the official key loader, not paste script directly. Get key at https://phantom-script.vercel.app. " ..
                "If it says the game is blocked: Phantom blocks certain games to protect users from bans. This is intentional and cannot be bypassed.\n\n" ..

                "PROBLEM 8 - AI tab not responding or AI gives no reply:\n" ..
                "SOLUTION: Requires HTTP support in the executor. Enable HTTP requests in executor settings. " ..
                "Try a different executor that supports HTTP. Common executors with HTTP: Synapse X, KRNL, Fluxus.\n\n" ..

                "PROBLEM 9 - Script crashes, errors, or stops mid-load:\n" ..
                "SOLUTION: Reset by running if isfolder(\"Phantom\") then delfolder(\"Phantom\") end then re-execute Phantom. " ..
                "If error persists, rejoin the game and try again.\n\n" ..

                "PROBLEM 10 - ESP not showing players:\n" ..
                "SOLUTION: Go to ESP tab. First enable the 'Enable Master ESP' toggle (this is the main switch). " ..
                "Then enable individual options: Show Boxes, Show Names, Show Distance, etc. " ..
                "Make sure 'Team Check' is off if you want to see teammates too.\n\n" ..

                "PROBLEM 11 - Global Chat button not visible on screen:\n" ..
                "SOLUTION: Go to TAGS tab. Enable 'Enable Global Chat' toggle. " ..
                "After enabling, a Chat button will appear floating on the HUD screen. Click that to open chat.\n\n" ..

                "PROBLEM 12 - Settings or theme not saving between sessions:\n" ..
                "SOLUTION: Settings auto-save to Phantom/Settings.json. If not saving, the folder may be corrupted. " ..
                "Go to SETTING tab and click 'Reset Config', or run if isfolder(\"Phantom\") then delfolder(\"Phantom\") end and re-execute.\n\n" ..

                "PROBLEM 13 - Cannot see other Phantom users' tags:\n" ..
                "SOLUTION: Go to TAGS tab and enable 'Show Others Tags' toggle.\n\n" ..

                "PROBLEM 14 - Aimlock, hitbox, or PVP features not working:\n" ..
                "SOLUTION: Some games patch these features. Try a different server or game mode. " ..
                "Make sure you have selected a target player first using 'Select Player' in the PVP tab.\n\n" ..

                "PROBLEM 15 - Server hop not working or cannot find servers:\n" ..
                "SOLUTION: Go to SERVER tab. Try different hop options: Low Population, Low Ping, Random, or Oldest. " ..
                "If all fail, the game may have very few servers. Try again later.\n\n" ..

                "PROBLEM 16 - Ragdoll, fling, or combat features not working in a game:\n" ..
                "SOLUTION: These features depend on the game's physics setup. Not all games support them. " ..
                "Try in a different game or different server. Some anti-cheats detect and block fling.\n\n" ..

                "PROBLEM 17 - Script loaded but all features appear greyed out or unclickable:\n" ..
                "SOLUTION: Run if isfolder(\"Phantom\") then delfolder(\"Phantom\") end then re-execute. " ..
                "This may also happen if the executor has sandbox restrictions. Try a different executor.\n\n" ..

                "PROBLEM 18 - Notification says 'Phantom 8.6 Loaded' but menu does not appear:\n" ..
                "SOLUTION: Press RightControl to toggle the menu. If still not visible, run " ..
                "if isfolder(\"Phantom\") then delfolder(\"Phantom\") end and re-execute to reset GUI positions.\n\n" ..

                "GOLDEN RULE FOR RESET: Whenever a user has ANY UI problem, button off-screen, position issue, " ..
                "loading problem, or settings corruption — ALWAYS provide this universal reset solution:\n" ..
                "Step 1: Run this code in executor: if isfolder(\"Phantom\") then delfolder(\"Phantom\") end\n" ..
                "Step 2: Execute the Phantom script again.\n" ..
                "This resets all saved data (positions, settings) and fixes most common problems.\n\n" ..

                "PERSISTENT PROBLEM RULE: If the user says the problem is still happening after trying all solutions, " ..
                "or if the problem keeps coming back, or if nothing is working — " ..
                "tell them to report it as a bug in the official Phantom Discord server. " ..
                "They should join discord.gg/JEgsFtwABp and go to the bug-report channel to submit their issue. " ..
                "Tell them to include: what the problem is, what executor they use, and what game they are in. " ..
                "The Phantom team will help them there.\n\n" ..

                "KEY SYSTEM: Users need a valid key to run the script. " ..
                "Direct them to https://phantom-script.vercel.app to get a key.\n\n" ..

                "RESTRICTED GAMES: Phantom blocks execution in certain games to protect users from bans.\n\n" ..

                playerCtx
        end

        local function buildPlayerContext()
            local name    = Player.Name
            local display = Player.DisplayName
            local uid     = tostring(Player.UserId)
            local ageDays = Player.AccountAge
            local created = os.date("around %B %Y", os.time() - ageDays * 86400)
            local isPrem  = Player.MembershipType == Enum.MembershipType.Premium
            local gameName = "Unknown"
            pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
            local team = "None"
            pcall(function() if Player.Team then team = Player.Team.Name end end)
            return
                "CURRENT USER INFO (the Roblox player using this script right now):\n" ..
                "Roblox Username: " .. name .. "\n" ..
                "Display Name: " .. display .. "\n" ..
                "User ID: " .. uid .. "\n" ..
                "Account Age: " .. tostring(ageDays) .. " days old (created " .. created .. ")\n" ..
                "Roblox Premium: " .. (isPrem and "Yes" or "No") .. "\n" ..
                "Current Game: " .. gameName .. "\n" ..
                "Current Team: " .. team .. "\n" ..
                "When the user asks about their own Roblox account (username, when account was created, age, premium, etc.), " ..
                "use this information to answer them directly and accurately."
        end

        local PHANTOM_SYSTEM_PROMPT = buildSystemPrompt(buildPlayerContext())

        local conversationHistory = {
            { role = "system", content = PHANTOM_SYSTEM_PROMPT },
        }

        local function sendToAI(userMessage, onSuccess, onError)
            table.insert(conversationHistory, { role = "user", content = userMessage })
            while #conversationHistory > 41 do table.remove(conversationHistory, 2) end

            local reqBody = HttpService:JSONEncode({
                model       = AI_MODEL,
                messages    = conversationHistory,
                max_tokens  = 512,
                temperature = 0.75,
            })

            task.spawn(function()
                local httpReq = getHttpRequest()
                if not httpReq then
                    table.remove(conversationHistory)
                    if onError then onError("No HTTP support found in your executor.") end
                    return
                end

                local tried = 0
                while tried < #AI_KEYS do
                    local key = AI_KEYS[aiKeyIdx]
                    local ok, res = pcall(function()
                        return httpReq({
                            Url    = AI_URL,
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. key },
                            Body   = reqBody,
                        })
                    end)
                    if not ok then
                        table.remove(conversationHistory)
                        if onError then onError("Connection error. Check your executor HTTP settings.") end
                        return
                    end
                    local status = res and (res.StatusCode or res.status_code or res.Status or 0)
                    local rbody  = res and (res.Body or res.body or "")
                    if status == 200 then
                        local ok2, data = pcall(HttpService.JSONDecode, HttpService, rbody)
                        if ok2 and data and data.choices and data.choices[1] and data.choices[1].message then
                            local reply = data.choices[1].message.content or "(no reply)"
                            table.insert(conversationHistory, { role = "assistant", content = reply })
                            if onSuccess then onSuccess(reply) end
                        else
                            table.remove(conversationHistory)
                            if onError then onError("Could not read AI response. Try again.") end
                        end
                        return
                    elseif status == 429 or status == 503 then
                        aiKeyIdx = (aiKeyIdx % #AI_KEYS) + 1
                        tried = tried + 1
                    else
                        table.remove(conversationHistory)
                        if onError then onError("AI error (code " .. tostring(status) .. "). Try again later.") end
                        return
                    end
                end
                table.remove(conversationHistory)
                if onError then onError("AI is busy right now. Please wait a moment and try again.") end
            end)
        end

        local HEADER_H = 38
        local INPUT_H  = 42
        local GAP      = 4

        local aiHeader = Instance.new("Frame")
        aiHeader.Size             = UDim2.new(1, 0, 0, HEADER_H)
        aiHeader.Position         = UDim2.new(0, 0, 0, 0)
        aiHeader.BackgroundColor3 = Theme.SidebarBg
        aiHeader.BorderSizePixel  = 0
        aiHeader.ZIndex           = 2
        aiHeader.Parent           = AIFrame
        Instance.new("UICorner", aiHeader).CornerRadius = UDim.new(0, 8)
        AddStroke(aiHeader, Theme.Accent, 1)

        local aiTitle = Instance.new("TextLabel")
        aiTitle.Size               = UDim2.new(1, -100, 1, 0)
        aiTitle.Position           = UDim2.new(0, 10, 0, 0)
        aiTitle.BackgroundTransparency = 1
        aiTitle.Text               = "🤖  Phantom AI"
        aiTitle.TextColor3         = Theme.Accent
        aiTitle.Font               = Enum.Font.GothamBold
        aiTitle.TextSize           = 13
        aiTitle.TextXAlignment     = Enum.TextXAlignment.Left
        aiTitle.ZIndex             = 3
        aiTitle.Parent             = aiHeader

        local aiStatusBadge = Instance.new("TextLabel")
        aiStatusBadge.Size              = UDim2.new(0, 76, 0, 18)
        aiStatusBadge.Position          = UDim2.new(1, -82, 0.5, -9)
        aiStatusBadge.BackgroundColor3  = Theme.ContentBg
        aiStatusBadge.Text              = "Online ✓"
        aiStatusBadge.TextColor3        = Theme.Green
        aiStatusBadge.Font              = Enum.Font.GothamBold
        aiStatusBadge.TextSize          = 8
        aiStatusBadge.TextXAlignment    = Enum.TextXAlignment.Center
        aiStatusBadge.ZIndex            = 3
        aiStatusBadge.Parent            = aiHeader
        Instance.new("UICorner", aiStatusBadge).CornerRadius = UDim.new(0, 5)

        local chatScroll = Instance.new("ScrollingFrame")
        chatScroll.BackgroundTransparency = 1
        chatScroll.ScrollBarThickness     = 3
        chatScroll.ScrollBarImageColor3   = Theme.Accent
        chatScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
        chatScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        chatScroll.ScrollingDirection     = Enum.ScrollingDirection.Y
        chatScroll.ElasticBehavior        = Enum.ElasticBehavior.Never
        chatScroll.ClipsDescendants       = true
        chatScroll.ZIndex                 = 2
        chatScroll.Parent                 = AIFrame

        chatScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if chatScroll.CanvasPosition.X ~= 0 then
                chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasPosition.Y)
            end
        end)

        local chatList = Instance.new("UIListLayout")
        chatList.SortOrder = Enum.SortOrder.LayoutOrder
        chatList.Padding   = UDim.new(0, 6)
        chatList.Parent    = chatScroll

        local chatPad = Instance.new("UIPadding")
        chatPad.PaddingTop    = UDim.new(0, 5)
        chatPad.PaddingBottom = UDim.new(0, 5)
        chatPad.PaddingLeft   = UDim.new(0, 4)
        chatPad.PaddingRight  = UDim.new(0, 4)
        chatPad.Parent        = chatScroll

        local inputBar = Instance.new("Frame")
        inputBar.BackgroundColor3 = Theme.SidebarBg
        inputBar.BorderSizePixel  = 0
        inputBar.ZIndex           = 10
        inputBar.Parent           = AIFrame
        Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 8)
        AddStroke(inputBar, Theme.Outline, 1)

        local inputBox = Instance.new("TextBox")
        inputBox.Size              = UDim2.new(1, -58, 0, INPUT_H - 14)
        inputBox.Position          = UDim2.new(0, 8, 0, 7)
        inputBox.BackgroundTransparency = 1
        inputBox.Text              = ""
        inputBox.PlaceholderText   = "Message Phantom Bot..."
        inputBox.PlaceholderColor3 = Theme.TextSecondary
        inputBox.TextColor3        = Theme.TextPrimary
        inputBox.Font              = Enum.Font.Gotham
        inputBox.TextSize          = 12
        inputBox.TextXAlignment    = Enum.TextXAlignment.Left
        inputBox.ClearTextOnFocus  = false
        inputBox.MultiLine         = false
        inputBox.ZIndex            = 11
        inputBox.Parent            = inputBar

        local sendBtn = Instance.new("TextButton")
        sendBtn.Size              = UDim2.new(0, 42, 0, INPUT_H - 12)
        sendBtn.Position          = UDim2.new(1, -48, 0, 6)
        sendBtn.BackgroundColor3  = Theme.Accent
        sendBtn.Text              = "▶"
        sendBtn.TextColor3        = Theme.MainBg
        sendBtn.Font              = Enum.Font.GothamBold
        sendBtn.TextSize          = 13
        sendBtn.AutoButtonColor   = false
        sendBtn.ZIndex            = 11
        sendBtn.Parent            = inputBar
        Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

        local clearBtn = Instance.new("TextButton")
        clearBtn.BackgroundTransparency = 1
        clearBtn.Text              = "🗑 Clear"
        clearBtn.TextColor3        = Theme.TextSecondary
        clearBtn.Font              = Enum.Font.Gotham
        clearBtn.TextSize          = 9
        clearBtn.AutoButtonColor   = false
        clearBtn.ZIndex            = 5
        clearBtn.Parent            = AIFrame

        local function refreshAILayout()
            local H = AIFrame.AbsoluteSize.Y
            local W = AIFrame.AbsoluteSize.X
            if H < 20 or W < 20 then return end
            local chatY         = HEADER_H + GAP
            local chatH         = H - HEADER_H - GAP - GAP - INPUT_H
            if chatH < 10 then chatH = 10 end
            chatScroll.Position = UDim2.new(0, 0, 0, chatY)
            chatScroll.Size     = UDim2.new(1, 0, 0, chatH)
            inputBar.Position   = UDim2.new(0, 0, 0, H - INPUT_H)
            inputBar.Size       = UDim2.new(1, 0, 0, INPUT_H)
            clearBtn.Position   = UDim2.new(1, -62, 0, H - INPUT_H - 14)
            clearBtn.Size       = UDim2.new(0, 60, 0, 12)
        end

        _tabLayoutRegistry[AIFrame] = refreshAILayout
        AIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            task.defer(refreshAILayout)
        end)
        task.defer(refreshAILayout)

        local function scrollToBottom()
            local canvasH = chatScroll.AbsoluteCanvasSize.Y
            local windowH = chatScroll.AbsoluteWindowSize.Y
            if canvasH > windowH then
                chatScroll.CanvasPosition = Vector2.new(0, canvasH - windowH)
            end
        end

        chatList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            task.defer(scrollToBottom)
        end)
        chatScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
            task.defer(scrollToBottom)
        end)

        local function detectActionButtons(text)
            local buttons = {}
            local seen = {}

            local function addBtn(label, value)
                if not seen[value] then
                    seen[value] = true
                    table.insert(buttons, { label = label, value = value })
                end
            end

            for link in text:gmatch("discord%.gg/[%w%-]+") do
                addBtn("📋 Copy Discord Link", "https://" .. link)
            end
            for link in text:gmatch("discordapp%.com/invite/[%w%-]+") do
                addBtn("📋 Copy Discord Link", "https://" .. link)
            end

            if text:find("phantom%-script%.vercel%.app") then
                addBtn("🔑 Copy Key Link", "https://phantom-script.vercel.app")
            end

            if text:find("isfolder") and text:find("delfolder") then
                addBtn("📋 Copy Reset Code", 'if isfolder("Phantom") then delfolder("Phantom") end')
            end

            for line in text:gmatch("[^\n]+") do
                local trimmed = line:match("^%s*(.-)%s*$")
                local isCode = (
                    trimmed:find("^if .*then.*end$") or
                    trimmed:find("^local ") or
                    trimmed:find("^game%.") or
                    trimmed:find("^workspace%.") or
                    trimmed:find("^loadstring") or
                    trimmed:find("^getgenv") or
                    trimmed:find("^setclipboard") or
                    trimmed:find("^makefolder") or
                    trimmed:find("^delfolder") or
                    trimmed:find("^writefile") or
                    trimmed:find("^delfile") or
                    trimmed:find("^readfile") or
                    trimmed:find("^game:Get") or
                    trimmed:find("^require")
                )
                if isCode and #trimmed > 5 and not seen[trimmed] then
                    if not (trimmed:find("isfolder") and trimmed:find("delfolder")) then
                        addBtn("📋 Copy Code", trimmed)
                    end
                end
            end

            for url in text:gmatch("roblox%.com/games/[%d%-_/]+") do
                addBtn("🎮 Copy Game Link", "https://www." .. url)
            end

            for url in text:gmatch("https?://[%w%-%.%/%?%=%&%#%_%+%%]+") do
                if #url > 10
                    and not url:find("discord")
                    and not url:find("phantom%-script")
                    and not url:find("roblox%.com/games") then
                    addBtn("🔗 Copy Link", url)
                end
            end

            return buttons
        end

        local function copyToClipboard(value, btnLabel, btn)
            pcall(function()
                if setclipboard then
                    setclipboard(value)
                elseif rbxthreadset then
                    setclipboard(value)
                end
            end)
            local orig = btnLabel
            btn.Text = "✅ Copied!"
            btn.BackgroundColor3 = Theme.Green
            task.delay(2, function()
                pcall(function()
                    btn.Text = orig
                    btn.BackgroundColor3 = Theme.SidebarBg
                end)
            end)
        end

        local activeCopyButtons = {}

        chatScroll.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            local pos = input.Position
            for _, entry in ipairs(activeCopyButtons) do
                local btn = entry.btn
                if btn and btn.Parent then
                    local ap = btn.AbsolutePosition
                    local as = btn.AbsoluteSize
                    if as.X > 0 and as.Y > 0
                        and pos.X >= ap.X and pos.X <= ap.X + as.X
                        and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y then
                        entry.action()
                        return
                    end
                end
            end
        end)

        local msgIdx = 0
        local function addMessage(text, isUser)
            msgIdx = msgIdx + 1
            local bubble = Instance.new("Frame")
            bubble.Size               = UDim2.new(1, -6, 0, 0)
            bubble.AutomaticSize      = Enum.AutomaticSize.Y
            bubble.BackgroundColor3   = isUser and Theme.Accent or Theme.ContentBg
            bubble.BackgroundTransparency = isUser and 0.75 or 0
            bubble.BorderSizePixel    = 0
            bubble.ClipsDescendants   = false
            bubble.LayoutOrder        = msgIdx
            bubble.Parent             = chatScroll
            Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 8)
            AddStroke(bubble, isUser and Theme.Accent or Theme.Outline, 1)

            local bList = Instance.new("UIListLayout")
            bList.SortOrder = Enum.SortOrder.LayoutOrder
            bList.Padding   = UDim.new(0, 2)
            bList.Parent    = bubble

            local bPad = Instance.new("UIPadding")
            bPad.PaddingLeft   = UDim.new(0, 8)
            bPad.PaddingRight  = UDim.new(0, 8)
            bPad.PaddingTop    = UDim.new(0, 5)
            bPad.PaddingBottom = UDim.new(0, 5)
            bPad.Parent        = bubble

            local who = Instance.new("TextLabel")
            who.Size               = UDim2.new(1, 0, 0, 13)
            who.BackgroundTransparency = 1
            who.Text               = isUser and ("👤 " .. Player.Name) or "🤖 Phantom Bot"
            who.TextColor3         = isUser and Theme.Accent or Theme.TextSecondary
            who.Font               = Enum.Font.GothamBold
            who.TextSize           = 9
            who.TextXAlignment     = Enum.TextXAlignment.Left
            who.TextWrapped        = false
            who.LayoutOrder        = 1
            who.Parent             = bubble

            local bodyLbl = Instance.new("TextLabel")
            bodyLbl.Size              = UDim2.new(1, 0, 0, 0)
            bodyLbl.AutomaticSize     = Enum.AutomaticSize.Y
            bodyLbl.BackgroundTransparency = 1
            bodyLbl.Text              = text
            bodyLbl.TextColor3        = Theme.TextPrimary
            bodyLbl.Font              = Enum.Font.Gotham
            bodyLbl.TextSize          = 12
            bodyLbl.TextXAlignment    = Enum.TextXAlignment.Left
            bodyLbl.TextWrapped       = true
            bodyLbl.LayoutOrder       = 2
            bodyLbl.Parent            = bubble

            if not isUser then
                local actionBtns = detectActionButtons(text)
                if #actionBtns > 0 then
                    local btnRow = Instance.new("Frame")
                    btnRow.Size                   = UDim2.new(1, 0, 0, 0)
                    btnRow.AutomaticSize          = Enum.AutomaticSize.Y
                    btnRow.BackgroundTransparency = 1
                    btnRow.LayoutOrder            = 3
                    btnRow.ClipsDescendants       = false
                    btnRow.Parent                 = bubble

                    local rowList = Instance.new("UIListLayout")
                    rowList.SortOrder       = Enum.SortOrder.LayoutOrder
                    rowList.FillDirection   = Enum.FillDirection.Horizontal
                    rowList.Padding         = UDim.new(0, 4)
                    rowList.Wraps           = true
                    rowList.Parent          = btnRow

                    local rowPad = Instance.new("UIPadding")
                    rowPad.PaddingTop = UDim.new(0, 4)
                    rowPad.Parent     = btnRow

                    for i, item in ipairs(actionBtns) do
                        local capturedLabel = item.label
                        local capturedValue = item.value
                        local lastFire      = 0

                        local btn = Instance.new("TextButton")
                        btn.AutomaticSize    = Enum.AutomaticSize.X
                        btn.Size             = UDim2.new(0, 0, 0, 22)
                        btn.BackgroundColor3 = Theme.SidebarBg
                        btn.Text             = capturedLabel
                        btn.TextColor3       = Theme.Accent
                        btn.Font             = Enum.Font.GothamBold
                        btn.TextSize         = 9
                        btn.AutoButtonColor  = false
                        btn.LayoutOrder      = i
                        btn.Parent           = btnRow
                        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                        AddStroke(btn, Theme.Accent, 1)

                        local bp = Instance.new("UIPadding")
                        bp.PaddingLeft  = UDim.new(0, 6)
                        bp.PaddingRight = UDim.new(0, 6)
                        bp.Parent       = btn

                        btn.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local now = tick()
                                if now - lastFire < 0.4 then return end
                                lastFire = now
                                copyToClipboard(capturedValue, capturedLabel, btn)
                            end
                        end)

                        local entry = {
                            btn = btn,
                            action = function()
                                local now = tick()
                                if now - lastFire < 0.4 then return end
                                lastFire = now
                                copyToClipboard(capturedValue, capturedLabel, btn)
                            end
                        }
                        table.insert(activeCopyButtons, entry)
                        btn.Destroying:Connect(function()
                            for idx, e in ipairs(activeCopyButtons) do
                                if e == entry then
                                    table.remove(activeCopyButtons, idx)
                                    break
                                end
                            end
                        end)

                        btn.MouseEnter:Connect(function()
                            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ItemHover}):Play()
                        end)
                        btn.MouseLeave:Connect(function()
                            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SidebarBg}):Play()
                        end)
                    end
                end
            end

            task.delay(0.05, scrollToBottom)
            task.delay(0.25, scrollToBottom)
            return bubble
        end

        local isWaiting = false
        local function doSend()
            if isWaiting then return end
            local msg = inputBox.Text:match("^%s*(.-)%s*$")
            if msg == "" then return end
            inputBox.Text = ""
            isWaiting = true
            sendBtn.Text             = "…"
            sendBtn.BackgroundColor3 = Theme.TextSecondary
            addMessage(msg, true)
            local typingBubble = addMessage("⏳ Thinking...", false)
            sendToAI(msg,
                function(reply)
                    pcall(function() typingBubble:Destroy() end)
                    addMessage(reply, false)
                    aiStatusBadge.Text       = "Online ✓"
                    aiStatusBadge.TextColor3 = Theme.Green
                    isWaiting                = false
                    sendBtn.Text             = "▶"
                    sendBtn.BackgroundColor3 = Theme.Accent
                end,
                function(errMsg)
                    pcall(function() typingBubble:Destroy() end)
                    addMessage("⚠️ " .. errMsg, false)
                    isWaiting                = false
                    sendBtn.Text             = "▶"
                    sendBtn.BackgroundColor3 = Theme.Accent
                end
            )
        end

        sendBtn.MouseButton1Click:Connect(doSend)
        inputBox.FocusLost:Connect(function(enter) if enter then doSend() end end)
        sendBtn.MouseEnter:Connect(function()
            if not isWaiting then TweenService:Create(sendBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play() end
        end)
        sendBtn.MouseLeave:Connect(function()
            if not isWaiting then TweenService:Create(sendBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}):Play() end
        end)

        clearBtn.MouseButton1Click:Connect(function()
            for _, ch in ipairs(chatScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            msgIdx = 0
            conversationHistory = { { role = "system", content = PHANTOM_SYSTEM_PROMPT } }
            SendNotification("Chat Cleared ✓", Theme.Accent)
            addMessage("Chat cleared! Ask me anything 🤖", false)
        end)

        addMessage(
            "Hello! I'm Phantom Bot 🤖 - your AI assistant inside Phantom.\n\n" ..
            "Ask me anything about the script, its features, how to use it, or any Roblox questions!",
            false
        )

        _RegFeature("🤖 Phantom AI Chat", "Phantom Bot - built-in AI assistant for Phantom 8.6", AIFrame)
    end

    end
    BuildAllTabs()

    AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if UserInputService:GetFocusedTextBox() then return end
        if ScreenGui:FindFirstChild("PhantomKeybindPopup") then return end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        local keyName = tostring(kc):gsub("Enum.KeyCode.","")
        keyName = keyName:gsub("^KeypadZero$","KP0"):gsub("^Keypad","KP")
        keyName = keyName:gsub("^LeftBracket$","["):gsub("^RightBracket$","]")
        keyName = keyName:gsub("^Semicolon$",";"):gsub("^Apostrophe$","'")
        if #keyName > 5 then keyName = keyName:sub(1,5) end
        local isCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                    or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        for featureName, kb in pairs(Settings.Keybinds) do
            if kb and kb.key == keyName then
                local needsCtrl = kb.ctrl == true
                if needsCtrl == isCtrl then
                    local tObj = _KeybindRegistry[featureName]
                    if tObj and tObj.Toggle then
                        tObj:Toggle()
                        local newState = tObj:GetState()
                        local shortName = featureName:match("[%w%s%(%)%-/]+") or featureName
                        shortName = shortName:gsub("^%s+",""):gsub("%s+$",""):sub(1, 24)
                        SendNotification(shortName .. ": " .. (newState and "ON ✓" or "OFF ✗"),
                            newState and Theme.Green or Theme.Red)
                    end
                end
            end
        end
    end))

    if isReload then SendNotification("Phantom 8.6 Reloaded ✓", Theme.Green) else SendNotification("Phantom 8.6 Loaded ✓", Theme.Accent) end

    if getgenv then
        getgenv().Phantom_ScriptReady = true
        getgenv().Phantom_IsLoading   = false
    end
end

BuildInterface()
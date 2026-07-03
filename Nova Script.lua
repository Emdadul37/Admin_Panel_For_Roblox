local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Players         = game:GetService("Players")

local Camera         = workspace.CurrentCamera
local function VP()  return Camera.ViewportSize end
local function SW()  return VP().X end 
local function SH()  return VP().Y end  

local function CardW()  return math.min(SW() * 0.92, 420) end
local function CardH()  return math.min(SH() * 0.88, 420) end

local function BuyW()   return math.min(SW() * 0.90, 380) end
local function BuyH()   return math.min(SH() * 0.84, 400) end

local function InitW()  return math.min(SW() * 0.88, 370) end
local function InitH()  return math.min(SH() * 0.50, 210) end

local function AmbW()   return CardW() + 28 end
local function AmbH()   return CardH() + 22 end

local function ScaleX(px) return math.floor(px / 418 * CardW()) end
local function ScaleY(px) return math.floor(px / 412 * CardH()) end

local function BScaleX(px) return math.floor(px / 372 * BuyW()) end
local function BScaleY(px) return math.floor(px / 382 * BuyH()) end

local function IScaleX(px) return math.floor(px / 362 * InitW()) end
local function IScaleY(px) return math.floor(px / 200 * InitH()) end

local function TS(base) return math.max(8, math.floor(base * SW() / 418)) end

local KeyFileName = "Phantom_Key.txt"
local ServiceID   = "phantom"
local DiscordLink = "https://discord.gg/JEgsFtwABp"
local ScriptURL   = "https://raw.githubusercontent.com/Emdadul37/Admin_Panel_For_Roblox/refs/heads/main/Phantom%20Ultimate.lua"

local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function TrimKey(key)
    return (tostring(key):gsub("^[%s\n\r\t]+", ""):gsub("[%s\n\r\t]+$", ""))
end

local _cachedHWID
local function GetHWID()
    if _cachedHWID then return _cachedHWID end
    local ok, hwid = pcall(gethwid)
    if ok and hwid and hwid ~= "" then
        _cachedHWID = hwid
        return hwid
    end
    _cachedHWID = tostring(game:GetService("RbxAnalyticsService"):GetClientId()):gsub("-","")
    return _cachedHWID
end

local _reqFnChecked, _cachedReqFn = false, nil
local function GetRequestFunc()
    if _reqFnChecked then return _cachedReqFn end
    local candidates = {
        function() return request end,
        function() return http_request end,
        function() return http and http.request end,
        function() return syn and syn.request end,
        function() return fluxus and fluxus.request end,
        function() return (getgenv or function() return {} end)().request end,
    }
    for _, getter in ipairs(candidates) do
        local ok, fn = pcall(getter)
        if ok and type(fn) == "function" then _cachedReqFn = fn; break end
    end
    _reqFnChecked = true
    return _cachedReqFn
end

local function ValidateKey(key)
    key = TrimKey(key)
    if key == "" then return false, "Key is empty" end

    local reqFn = GetRequestFunc()
    if not reqFn then return false, "HTTP not supported by this executor" end

    local body
    local encOk, encResult = pcall(HttpService.JSONEncode, HttpService, {
        ServiceID = ServiceID,
        HWID      = GetHWID(),
        Key       = key,
    })
    if not encOk then return false, "Failed to encode request" end
    body = encResult

    local reqOk, response = pcall(reqFn, {
        Url     = "https://phantom-script.vercel.app/api/keys/validate",
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    })

    if not reqOk then return false, "Network request failed" end
    if not response or type(response) ~= "table" then return false, "No response received" end
    if not response.Body or response.Body == "" then return false, "Empty server response" end

    local decOk, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
    if not decOk or type(data) ~= "table" then return false, "Could not parse server response" end

    local isValid = (data.Authenticated_Status == "Success")
    local note    = tostring(data.Note or (isValid and "Authenticated" or "Invalid key"))
    return isValid, note
end

local function LoadScript(validKey)
    local genv = getgenv and getgenv()
    if genv and genv.Phantom_IsLoading then return end

    local now = tick()
    if genv and genv.Phantom_LastLoadTime and (now - genv.Phantom_LastLoadTime) < 5 then return end

    if genv then
        genv.Phantom_IsLoading    = true
        genv.Phantom_LastLoadTime = now
        genv.Phantom_Auth         = "Phantom_Secret_Token_9982"
        genv.Phantom_Key          = validKey
        genv.Phantom_ScriptReady  = false
        genv.Phantom_LoadError    = nil
    end

    task.spawn(function()
        local scriptContent
        local dlMsg

        local reqFn = GetRequestFunc()
        if reqFn then
            local ok, res = pcall(reqFn, {
                Url     = ScriptURL,
                Method  = "GET",
                Headers = { ["User-Agent"] = "Phantom/8.6" },
            })
            if ok and res and type(res) == "table" and type(res.Body) == "string" and res.Body ~= "" then
                scriptContent = res.Body
            else
                dlMsg = "request() failed, trying fallback..."
            end
        end

        if not scriptContent then
            local ok, content = pcall(function() return game:HttpGet(ScriptURL) end)
            if ok and type(content) == "string" and content ~= "" then
                scriptContent = content
            else
                dlMsg = tostring(content or "empty response")
            end
        end

        if not scriptContent then
            local msg = "Download failed: " .. tostring(dlMsg or "unknown")
            warn("[Phantom] " .. msg)
            if genv then
                genv.Phantom_LoadError   = msg
                genv.Phantom_IsLoading   = false
                genv.Phantom_ScriptReady = false
            end
            return
        end
        task.wait()

        local fn, compileErr = loadstring(scriptContent)
        scriptContent = nil

        if not fn then
            local msg = "Compile error: " .. tostring(compileErr)
            warn("[Phantom] " .. msg)
            if genv then
                genv.Phantom_LoadError   = msg
                genv.Phantom_IsLoading   = false
                genv.Phantom_ScriptReady = false
            end
            return
        end
        task.wait()

        local ok, err = pcall(fn)
        if not ok then
            local msg = "Execution error: " .. tostring(err)
            warn("[Phantom] " .. msg)
            if genv then
                genv.Phantom_LoadError   = msg
                genv.Phantom_IsLoading   = false
                genv.Phantom_ScriptReady = false
            end
        else
            task.delay(2, function()
                if genv and genv.Phantom_ScriptReady ~= true then
                    genv.Phantom_ScriptReady = true
                    genv.Phantom_IsLoading   = false
                end
            end)
        end

        task.delay(15, function()
            if genv and genv.Phantom_IsLoading then
                genv.Phantom_IsLoading   = false
                genv.Phantom_ScriptReady = true
            end
        end)
    end)
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local uisConn
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    uisConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Sine), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
    frame.Destroying:Connect(function()
        if uisConn then uisConn:Disconnect(); uisConn = nil end
        dragging = false
        dragInput = nil
    end)
end

local function CreateEmberSparks(parent)
    local activeCount = 0
    local MAX_SPARKS  = 12

    task.spawn(function()
        while parent and parent.Parent do
            if activeCount < MAX_SPARKS then
                activeCount = activeCount + 1
                local spark = Create("Frame", {
                    Size             = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5)),
                    Position         = UDim2.new(math.random() * 0.85, 0, math.random() * 0.5 - 0.05, 0),
                    BackgroundColor3 = math.random(2) == 1
                                       and Color3.fromRGB(255, math.random(90, 170), 15)
                                       or  Color3.fromRGB(220, math.random(45, 85), 8),
                    BackgroundTransparency = math.random(2, 5) / 10,
                    BorderSizePixel  = 0,
                    ZIndex           = 1,
                    Parent           = parent,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spark })
                local t = TweenService:Create(spark,
                    TweenInfo.new(math.random(28, 55) / 10, Enum.EasingStyle.Linear), {
                        Position             = UDim2.new(spark.Position.X.Scale + 0.28, 0, 1.12, 0),
                        BackgroundTransparency = 1,
                    })
                t:Play()
                t.Completed:Connect(function()
                    activeCount = activeCount - 1
                    spark:Destroy()
                end)
            end
            task.wait(math.random(30, 55) / 100)
        end
    end)
end

local function AddCornerBrackets(parent, color)
    Create("Frame", { Size=UDim2.new(0,14,0,2), Position=UDim2.new(0,0,0,0),    BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,2,0,14), Position=UDim2.new(0,0,0,0),    BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,14,0,2), Position=UDim2.new(1,-14,0,0),  BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,2,0,14), Position=UDim2.new(1,-2,0,0),   BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,14,0,2), Position=UDim2.new(0,0,1,-2),   BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,2,0,14), Position=UDim2.new(0,0,1,-14),  BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,14,0,2), Position=UDim2.new(1,-14,1,-2), BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
    Create("Frame", { Size=UDim2.new(0,2,0,14), Position=UDim2.new(1,-2,1,-14), BackgroundColor3=color, BorderSizePixel=0, ZIndex=7, Parent=parent })
end

local function ButtonAnimation(button, normalColor, hoverColor)
    local nc = normalColor or button.BackgroundColor3
    local hc = hoverColor or Color3.fromRGB(
        math.clamp(math.floor(nc.R * 255) + 22, 0, 255),
        math.clamp(math.floor(nc.G * 255) + 22, 0, 255),
        math.clamp(math.floor(nc.B * 255) + 22, 0, 255)
    )
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { BackgroundColor3 = hc }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { BackgroundColor3 = nc }):Play()
    end)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.07), { BackgroundTransparency = 0.28 }):Play()
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.14), { BackgroundTransparency = 0 }):Play()
        end
    end)
end

local function StaticWarmAmbient(gui, w, h)
    local box = Create("Frame", {
        Size                   = UDim2.new(0, w, 0, h),
        Position               = UDim2.new(0.5, -w/2, 0.5, -h/2),
        BackgroundColor3       = Color3.fromRGB(160, 55, 0),
        BackgroundTransparency = 0.93,
        BorderSizePixel        = 0,
        ZIndex                 = 1,
        Parent                 = gui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
    return box
end

local function BuildBackground(gui)
    local bg = Create("Frame", {
        Name                   = "Background",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = Color3.fromRGB(5, 3, 2),
        BackgroundTransparency = 0.38,
        BorderSizePixel        = 0,
        ZIndex                 = 0,
        Parent                 = gui,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 5, 2)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5,  3, 2)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  4, 2)),
        },
        Rotation = 45,
        Parent   = bg,
    })
    CreateEmberSparks(bg)
    return bg
end

local function BuildCard(gui, w, h)
    local main = Create("Frame", {
        Name             = "Main",
        Size             = UDim2.new(0, w, 0, h),
        Position         = UDim2.new(0.5, -w/2, 0.5, -h/2),
        BackgroundColor3 = Color3.fromRGB(11, 8, 6),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = gui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = main })
    Create("UIStroke",  { Color = Color3.fromRGB(195, 115, 18), Transparency = 0.42, Thickness = 1.5, Parent = main })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 12, 8)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 8,  6)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(9,  6,  5)),
        },
        Rotation = 120,
        Parent   = main,
    })
    AddCornerBrackets(main, Color3.fromRGB(215, 135, 22))
    return main
end

local function ShowInitializingScreen(validKey)
    if CoreGui:FindFirstChild("PhantomKeySystem") then
        CoreGui.PhantomKeySystem:Destroy()
    end

    local gui = Create("ScreenGui", {
        Name           = "PhantomKeySystem",
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
    })
    gui.Parent = (syn and syn.protect_gui and (syn.protect_gui(gui) or CoreGui))
             or  (gethui and gethui())
             or  CoreGui

    local bg      = BuildBackground(gui)
    local ambient = StaticWarmAmbient(gui, InitW()+18, InitH()+18)
    local main    = BuildCard(gui, InitW(), InitH())

    main.BackgroundTransparency = 1
    main.Position = UDim2.new(0.5, -InitW()/2, 0.6, -InitH()/2)
    TweenService:Create(main, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -InitW()/2, 0.5, -InitH()/2),
    }):Play()

    local strip = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 148, 18),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = main,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(0,   0,   0)),
            ColorSequenceKeypoint.new(0.12, Color3.fromRGB(255, 148, 18)),
            ColorSequenceKeypoint.new(0.88, Color3.fromRGB(215, 65,  8)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(0,   0,   0)),
        },
        Parent = strip,
    })

    local logoLbl = Create("TextLabel", {
        Text                   = "▸  PHANTOM",
        Size                   = UDim2.new(1, 0, 0, IScaleY(42)),
        Position               = UDim2.new(0, 0, 0, IScaleY(6)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(248, 152, 22),
        Font                   = Enum.Font.GothamBold,
        TextSize               = TS(21),
        ZIndex                 = 4,
        Parent                 = main,
    })

    local localPlayerId = Players.LocalPlayer and Players.LocalPlayer.UserId or 1

    local avatarOuter = Create("Frame", {
        Size             = UDim2.new(0, IScaleY(50), 0, IScaleY(50)),
        Position         = UDim2.new(0.5, -IScaleY(25), 0, IScaleY(54)),
        BackgroundColor3 = Color3.fromRGB(20, 13, 9),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = avatarOuter })
    Create("UIStroke", { Color = Color3.fromRGB(195, 115, 18), Transparency = 0.28, Thickness = 2, Parent = avatarOuter })

    local avatarImg = Create("ImageLabel", {
        Size                   = UDim2.new(1, -4, 1, -4),
        Position               = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image                  = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(localPlayerId) .. "&w=150&h=150",
        ZIndex                 = 5,
        Parent                 = avatarOuter,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = avatarImg })

    local spinRing = Create("Frame", {
        Size                   = UDim2.new(0, IScaleY(60), 0, IScaleY(60)),
        Position               = UDim2.new(0.5, -IScaleY(30), 0, IScaleY(49)),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 6,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = spinRing })
    Create("UIStroke", {
        Color        = Color3.fromRGB(255, 148, 18),
        Transparency = 0.18,
        Thickness    = 2.5,
        Parent       = spinRing,
    })
    task.spawn(function()
        local rot = 0
        while spinRing and spinRing.Parent do
            rot = (rot + 3.5) % 360
            spinRing.Rotation = rot
            task.wait()
        end
    end)

    local initLabel = Create("TextLabel", {
        Text                   = "Initializing Script",
        Size                   = UDim2.new(1, 0, 0, IScaleY(24)),
        Position               = UDim2.new(0, 0, 0, IScaleY(118)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(228, 208, 180),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = TS(14),
        ZIndex                 = 4,
        Parent                 = main,
    })

    local progBG = Create("Frame", {
        Size             = UDim2.new(0.72, 0, 0, 2),
        Position         = UDim2.new(0.14, 0, 0, IScaleY(150)),
        BackgroundColor3 = Color3.fromRGB(28, 18, 10),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = main,
    })

    local progFill = Create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(248, 148, 18),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = progBG,
    })

    task.spawn(function()
        while progFill and progFill.Parent do
            TweenService:Create(progFill, TweenInfo.new(0.68, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.72, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.72)
            TweenService:Create(progFill, TweenInfo.new(0.52, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0.04, 0, 1, 0), Position = UDim2.new(0.96, 0, 0, 0)
            }):Play()
            task.wait(0.56)
            progFill.Position = UDim2.new(0, 0, 0, 0)
            progFill.Size     = UDim2.new(0, 0, 1, 0)
            task.wait(0.04)
        end
    end)

    task.spawn(function()
        local dots = { "", ".", "..", "..." }
        local i = 1
        while initLabel and initLabel.Parent do
            initLabel.Text = "Initializing Script" .. dots[i]
            i = (i % #dots) + 1
            task.wait(0.44)
        end
    end)

    local subLabel = Create("TextLabel", {
        Text                   = "Please wait...",
        Size                   = UDim2.new(1, 0, 0, IScaleY(16)),
        Position               = UDim2.new(0, 0, 0, IScaleY(166)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(95, 70, 48),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = TS(10),
        ZIndex                 = 4,
        Parent                 = main,
    })

    Create("TextLabel", {
        Text                   = "PHANTOM  •  SECURE",
        Size                   = UDim2.new(1, -18, 0, 12),
        Position               = UDim2.new(0, 9, 1, -16),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(38, 26, 16),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = 9,
        TextXAlignment         = Enum.TextXAlignment.Right,
        ZIndex                 = 3,
        Parent                 = main,
    })

    task.spawn(function()
        task.wait(0.3)
        LoadScript(validKey)
        task.wait(0.6)

        local maxWait   = 45
        local elapsed   = 0
        local checkStep = 0.15

        while elapsed < maxWait do
            if getgenv and getgenv().Phantom_ScriptReady == true then break end
            if getgenv and getgenv().Phantom_LoadError then
                local errMsg = getgenv().Phantom_LoadError
                getgenv().Phantom_LoadError = nil
                if initLabel and initLabel.Parent then
                    initLabel.Text       = "Load Error"
                    initLabel.TextColor3 = Color3.fromRGB(245, 75, 55)
                end
                if subLabel and subLabel.Parent then
                    subLabel.Text       = tostring(errMsg):sub(1, 60)
                    subLabel.TextColor3 = Color3.fromRGB(200, 65, 48)
                end
                task.wait(6)
                break
            end
            task.wait(checkStep)
            elapsed = elapsed + checkStep
        end

        if gui and gui.Parent then
            TweenService:Create(main, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -InitW()/2, 0.43, -InitH()/2),
            }):Play()
            TweenService:Create(bg,      TweenInfo.new(0.42), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(ambient, TweenInfo.new(0.42), { BackgroundTransparency = 1 }):Play()
            task.wait(0.48)
            gui:Destroy()
        end
    end)
end

local function ShowBuyKeyGUI()
    if CoreGui:FindFirstChild("PhantomBuyKey") then
        CoreGui.PhantomBuyKey:Destroy()
        return
    end

    local gui = Create("ScreenGui", {
        Name           = "PhantomBuyKey",
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
    })
    gui.Parent = (syn and syn.protect_gui and (syn.protect_gui(gui) or CoreGui))
             or  (gethui and gethui())
             or  CoreGui

    local overlay = Create("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel        = 0,
        ZIndex                 = 10,
        Parent                 = gui,
    })

    local card = Create("Frame", {
        Size             = UDim2.new(0, BuyW(), 0, BuyH()),
        Position         = UDim2.new(0.5, -BuyW()/2, 0.5, -BuyH()/2),
        BackgroundColor3 = Color3.fromRGB(9, 8, 7),
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = gui,
    })
    Create("UICorner",  { CornerRadius = UDim.new(0, 6), Parent = card })
    Create("UIStroke",  { Color = Color3.fromRGB(18, 195, 175), Transparency = 0.28, Thickness = 1.5, Parent = card })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(14, 11, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9,  8,  7)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(7,  6,  5)),
        },
        Rotation = 130,
        Parent = card,
    })
    AddCornerBrackets(card, Color3.fromRGB(18, 195, 175))
    MakeDraggable(card)

    card.BackgroundTransparency = 1
    card.Position = UDim2.new(0.5, -BuyW()/2, 0.6, -BuyH()/2)
    TweenService:Create(card, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -BuyW()/2, 0.5, -BuyH()/2),
    }):Play()

    local function CloseGui()
        TweenService:Create(card, TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -BuyW()/2, 0.43, -BuyH()/2),
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.26), { BackgroundTransparency = 1 }):Play()
        task.delay(0.3, function() if gui and gui.Parent then gui:Destroy() end end)
    end

    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then CloseGui() end
    end)

    local buyStrip = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(18, 195, 175),
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = card,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(0,  0,  0)),
            ColorSequenceKeypoint.new(0.12, Color3.fromRGB(18, 195, 175)),
            ColorSequenceKeypoint.new(0.88, Color3.fromRGB(10, 155, 138)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(0,  0,  0)),
        },
        Parent = buyStrip,
    })

    local headerBar = Create("Frame", {
        Size                   = UDim2.new(1, 0, 0, 52),
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.62,
        BorderSizePixel        = 0,
        ZIndex                 = 12,
        Parent                 = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = headerBar })

    local titleLbl = Create("TextLabel", {
        Text                   = "▸  PURCHASE ACCESS",
        Size                   = UDim2.new(1, -98, 1, 0),
        Position               = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(18, 208, 185),
        Font                   = Enum.Font.GothamBold,
        TextSize               = TS(15),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 13,
        Parent                 = headerBar,
    })

    local closeBtn = Create("TextButton", {
        Text             = "✕",
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -40, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(28, 16, 12),
        TextColor3       = Color3.fromRGB(248, 85, 65),
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        ZIndex           = 15,
        Parent           = headerBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = closeBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(195, 55, 42), Transparency = 0.48, Thickness = 1, Parent = closeBtn })
    ButtonAnimation(closeBtn, Color3.fromRGB(28, 16, 12), Color3.fromRGB(48, 22, 16))
    closeBtn.MouseButton1Click:Connect(CloseGui)

    local buyScroll = Instance.new("ScrollingFrame")
    buyScroll.Size                 = UDim2.new(1, 0, 1, -52)
    buyScroll.Position             = UDim2.new(0, 0, 0, 52)
    buyScroll.BackgroundTransparency = 1
    buyScroll.BorderSizePixel      = 0
    buyScroll.ScrollBarThickness   = 3
    buyScroll.ScrollBarImageColor3 = Color3.fromRGB(18, 195, 175)
    buyScroll.ScrollingDirection   = Enum.ScrollingDirection.Y
    buyScroll.ElasticBehavior      = Enum.ElasticBehavior.Never
    buyScroll.ZIndex               = 12
    buyScroll.Parent               = card

    local currentY = 12

    local priceBadge = Create("Frame", {
        Size                   = UDim2.new(0.88, 0, 0, 48),
        Position               = UDim2.new(0.06, 0, 0, currentY),
        BackgroundColor3       = Color3.fromRGB(18, 195, 175),
        BackgroundTransparency = 0.84,
        BorderSizePixel        = 0,
        ZIndex                 = 12,
        Parent                 = buyScroll,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = priceBadge })
    Create("UIStroke",  { Color = Color3.fromRGB(18, 195, 175), Transparency = 0.38, Thickness = 1.5, Parent = priceBadge })

    Create("TextLabel", {
        RichText               = true,
        Text                   = "◆  <b>$3.99 USD / 350 Robux</b>  —  Lifetime Access",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(18, 215, 192),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        ZIndex                 = 13,
        Parent                 = priceBadge,
    })

    currentY = currentY + 48 + 14

    Create("TextLabel", {
        Text                   = "PAYMENT METHODS",
        Size                   = UDim2.new(0.88, 0, 0, 16),
        Position               = UDim2.new(0.06, 0, 0, currentY),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(168, 162, 152),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 9,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 12,
        Parent                 = buyScroll,
    })

    currentY = currentY + 16 + 4

    local paymentMethods = {
        { name = "Binance Pay",   tag = "Instant · Zero Fees",  color = Color3.fromRGB(238, 182, 10) },
        { name = "USDT  ERC20",   tag = "Ethereum Network",      color = Color3.fromRGB(72,  172, 155) },
        { name = "USDT  BEP20",   tag = "BNB Smart Chain",       color = Color3.fromRGB(95,  205, 115) },
        { name = "350 Robux",     tag = "Gamepass / Group Funds", color = Color3.fromRGB(0, 162, 255) },
        { name = "Other Method",  tag = "Open Ticket to Negotiate", color = Color3.fromRGB(215, 100, 50) },
    }

    for i, pm in ipairs(paymentMethods) do
        local pmFrame = Create("Frame", {
            Size             = UDim2.new(0.88, 0, 0, 37),
            Position         = UDim2.new(0.06, 0, 0, currentY),
            BackgroundColor3 = Color3.fromRGB(10, 9, 8),
            BorderSizePixel  = 0,
            ZIndex           = 12,
            Parent           = buyScroll,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = pmFrame })
        Create("UIStroke",  { Color = pm.color, Transparency = 0.62, Thickness = 1, Parent = pmFrame })

        Create("Frame", {
            Size             = UDim2.new(0, 2, 0, 20),
            Position         = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = pm.color,
            BorderSizePixel  = 0,
            ZIndex           = 13,
            Parent           = pmFrame,
        })

        Create("TextLabel", {
            Text                   = pm.name,
            Size                   = UDim2.new(0.55, 0, 1, 0),
            Position               = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3             = Color3.fromRGB(218, 212, 200),
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 13,
            Parent                 = pmFrame,
        })
        Create("TextLabel", {
            Text                   = pm.tag,
            Size                   = UDim2.new(0.42, 0, 1, 0),
            Position               = UDim2.new(0.57, 0, 0, 0),
            BackgroundTransparency = 1,
            TextColor3             = Color3.fromRGB(180, 180, 180),
            Font                   = Enum.Font.GothamMedium,
            TextSize               = 10,
            TextXAlignment         = Enum.TextXAlignment.Right,
            ZIndex                 = 13,
            Parent                 = pmFrame,
        })
        currentY = currentY + 37 + 7
    end

    currentY = currentY - 7 + 14

    Create("TextLabel", {
        Text                   = "HOW TO PURCHASE",
        Size                   = UDim2.new(0.88, 0, 0, 16),
        Position               = UDim2.new(0.06, 0, 0, currentY),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(168, 162, 152),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 9,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 12,
        Parent                 = buyScroll,
    })

    currentY = currentY + 16 + 4

    local steps = {
        { num = "01", text = "Join our Discord server via the button below" },
        { num = "02", text = "Open a purchase ticket inside the server" },
        { num = "03", text = "Send payment and receive your key instantly" },
        { num = "04", text = "No listed method? Tell us what you have in ticket!" },
    }

    for i, step in ipairs(steps) do
        local sFrame = Create("Frame", {
            Size                   = UDim2.new(0.88, 0, 0, 25),
            Position               = UDim2.new(0.06, 0, 0, currentY),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ZIndex                 = 12,
            Parent                 = buyScroll,
        })
        Create("TextLabel", {
            Text                   = step.num,
            Size                   = UDim2.new(0, 26, 1, 0),
            BackgroundTransparency = 1,
            TextColor3             = Color3.fromRGB(18, 200, 175),
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            ZIndex                 = 13,
            Parent                 = sFrame,
        })
        Create("TextLabel", {
            Text                   = step.text,
            Size                   = UDim2.new(1, -32, 1, 0),
            Position               = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            TextColor3             = Color3.fromRGB(158, 150, 138),
            Font                   = Enum.Font.GothamMedium,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 13,
            Parent                 = sFrame,
        })
        currentY = currentY + 25 + 4
    end

    currentY = currentY - 4 + 13

    local discBtn = Create("TextButton", {
        Text             = "JOIN DISCORD  ·  OPEN A TICKET",
        Size             = UDim2.new(0.88, 0, 0, 42),
        Position         = UDim2.new(0.06, 0, 0, currentY),
        BackgroundColor3 = Color3.fromRGB(11, 162, 144),
        TextColor3       = Color3.fromRGB(245, 255, 252),
        Font             = Enum.Font.GothamBlack,
        TextSize         = 13,
        ZIndex           = 12,
        Parent           = buyScroll,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = discBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(28, 215, 192), Transparency = 0.32, Thickness = 1, Parent = discBtn })
    ButtonAnimation(discBtn, Color3.fromRGB(11, 162, 144), Color3.fromRGB(14, 188, 168))

    discBtn.MouseButton1Click:Connect(function()
        if pcall(setclipboard, DiscordLink) then
            discBtn.Text = "LINK COPIED — OPEN IN YOUR BROWSER"
            task.delay(2.5, function()
                if discBtn and discBtn.Parent then
                    discBtn.Text = "JOIN DISCORD  ·  OPEN A TICKET"
                end
            end)
        end
    end)

    currentY = currentY + 42 + 18

    Create("TextLabel", {
        Text                   = "PHANTOM  •  PERMANENT ACCESS",
        Size                   = UDim2.new(1, -18, 0, 13),
        Position               = UDim2.new(0, 9, 0, currentY),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(28, 25, 20),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = 9,
        TextXAlignment         = Enum.TextXAlignment.Right,
        ZIndex                 = 12,
        Parent                 = buyScroll,
    })

    currentY = currentY + 13 + 15
    buyScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(currentY, BScaleY(currentY)))
end

local function BuildGUI()
    if CoreGui:FindFirstChild("PhantomKeySystem") then
        CoreGui.PhantomKeySystem:Destroy()
    end

    local gui = Create("ScreenGui", {
        Name           = "PhantomKeySystem",
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
    })
    gui.Parent = (syn and syn.protect_gui and (syn.protect_gui(gui) or CoreGui))
             or  (gethui and gethui())
             or  CoreGui

    local bg      = BuildBackground(gui)
    local ambient = StaticWarmAmbient(gui, AmbW(), AmbH())
    local main    = BuildCard(gui, CardW(), CardH())
    MakeDraggable(main)

    local topStrip = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 148, 18),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(0,   0,   0)),
            ColorSequenceKeypoint.new(0.12, Color3.fromRGB(255, 148, 18)),
            ColorSequenceKeypoint.new(0.88, Color3.fromRGB(215, 65,  8)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(0,   0,   0)),
        },
        Parent = topStrip,
    })

    local CW = CardW()
    local CH = CardH()
    local P  = 0.05 
    local IW = 1 - P*2 

    local HDR  = math.floor(CH * 0.12)
    local HWID = math.floor(CH * 0.07)
    local INP  = math.floor(CH * 0.11)
    local BIG  = math.floor(CH * 0.12)
    local SML  = math.floor(CH * 0.11)
    local GAP  = math.floor(CH * 0.025)

    local function T(n) return math.max(8, math.floor(n * CW / 418)) end

    local Y = 0

    local topBar = Create("Frame", {
        Size                   = UDim2.new(1, 0, 0, HDR),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.62,
        BorderSizePixel        = 0,
        ZIndex                 = 3,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = topBar })

    Create("TextLabel", {
        Text                   = "▸  PHANTOM",
        Size                   = UDim2.new(0.6, 0, 1, 0),
        Position               = UDim2.new(0, math.floor(CW * 0.04), 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(248, 152, 22),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(17),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
        Parent                 = topBar,
    })

    local verBadge = Create("Frame", {
        Size                   = UDim2.new(0, math.floor(CW * 0.20), 0, math.floor(HDR * 0.52)),
        Position               = UDim2.new(1, -math.floor(CW * 0.23), 0.5, -math.floor(HDR * 0.26)),
        BackgroundColor3       = Color3.fromRGB(26, 17, 8),
        BorderSizePixel        = 0,
        ZIndex                 = 5,
        Parent                 = topBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = verBadge })
    Create("UIStroke",  { Color = Color3.fromRGB(175, 95, 14), Transparency = 0.38, Thickness = 1, Parent = verBadge })
    Create("TextLabel", {
        Text                   = "SECURE  v2",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(175, 115, 18),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(9),
        ZIndex                 = 6,
        Parent                 = verBadge,
    })

    Y = HDR + GAP
    local hwid = GetHWID()
    local hwidStrip = Create("Frame", {
        Size             = UDim2.new(IW, 0, 0, HWID),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(16, 10, 6),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hwidStrip })
    Create("TextLabel", {
        Text                   = "HWID  /  " .. string.sub(hwid, 1, 16) .. "...",
        Size                   = UDim2.new(1, -10, 1, 0),
        Position               = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(88, 62, 38),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(9),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = hwidStrip,
    })

    Y = Y + HWID + GAP
    Create("Frame", {
        Size             = UDim2.new(IW, 0, 0, 1),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(35, 24, 14),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })

    Y = Y + 1 + math.floor(GAP * 0.6)
    Create("TextLabel", {
        Text                   = "KEY",
        Size                   = UDim2.new(IW, 0, 0, math.floor(CH * 0.04)),
        Position               = UDim2.new(P, 0, 0, Y),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(145, 100, 38),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(9),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent           = main,
    })

    Y = Y + math.floor(CH * 0.04) + math.floor(GAP * 0.4)
    local PASTE_W = math.floor(CW * 0.16)
    local inputContainer = Create("Frame", {
        Size             = UDim2.new(IW, 0, 0, INP),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(7, 5, 4),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = inputContainer })
    local inputStroke = Create("UIStroke", {
        Color     = Color3.fromRGB(36, 24, 13),
        Thickness = 1.5,
        Parent    = inputContainer,
    })

    local keyBox = Create("TextBox", {
        Text                   = "",
        Size                   = UDim2.new(1, -(PASTE_W + 12), 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(238, 218, 188),
        PlaceholderText        = "Paste your key here...",
        PlaceholderColor3      = Color3.fromRGB(68, 50, 34),
        Font                   = Enum.Font.Gotham,
        TextSize               = T(11),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ClearTextOnFocus       = false,
        ZIndex                 = 4,
        Parent                 = inputContainer,
    })

    local PASTE_H = math.floor(INP * 0.62)
    local pasteBtn = Create("TextButton", {
        Text             = "PASTE",
        Size             = UDim2.new(0, PASTE_W, 0, PASTE_H),
        Position         = UDim2.new(1, -(PASTE_W + 6), 0.5, -math.floor(PASTE_H / 2)),
        BackgroundColor3 = Color3.fromRGB(22, 15, 8),
        TextColor3       = Color3.fromRGB(195, 135, 38),
        Font             = Enum.Font.GothamBold,
        TextSize         = T(9),
        ZIndex           = 5,
        Parent           = inputContainer,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = pasteBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(145, 90, 15), Transparency = 0.38, Thickness = 1, Parent = pasteBtn })
    ButtonAnimation(pasteBtn, Color3.fromRGB(22, 15, 8), Color3.fromRGB(35, 24, 10))

    keyBox.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.18), { Color = Color3.fromRGB(195, 118, 16) }):Play()
    end)
    keyBox.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.18), { Color = Color3.fromRGB(36, 24, 13) }):Play()
    end)

    Y = Y + INP + GAP
    local checkBtn = Create("TextButton", {
        Text             = "",
        Size             = UDim2.new(IW, 0, 0, BIG),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(212, 118, 14),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = checkBtn })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 158, 24)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(208, 88,  5)),
        },
        Rotation = 90,
        Parent   = checkBtn,
    })

    local IB = math.floor(BIG * 0.70)
    local iconOffX = math.floor(BIG * 0.14)
    local verifyIconBox = Create("Frame", {
        Size                   = UDim2.new(0, IB, 0, IB),
        Position               = UDim2.new(0, iconOffX, 0.5, -math.floor(IB/2)),
        BackgroundColor3       = Color3.fromRGB(12, 7, 2),
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = checkBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = verifyIconBox })
    Create("TextLabel", {
        Text                   = "⚡",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(255, 220, 120),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(14),
        ZIndex                 = 5,
        Parent                 = verifyIconBox,
    })

    local textOffX = iconOffX + IB + math.floor(CW * 0.02)
    local arrowW   = math.floor(IB * 0.90)
    local checkBtnLbl = Create("TextLabel", {
        Text                   = "VERIFY  &  LAUNCH",
        Size                   = UDim2.new(1, -(textOffX + arrowW + math.floor(CW*0.06)), 1, 0),
        Position               = UDim2.new(0, textOffX, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(12, 7, 2),
        Font                   = Enum.Font.GothamBlack,
        TextSize               = T(13),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = checkBtn,
    })

    local verifyArrow = Create("Frame", {
        Size                   = UDim2.new(0, arrowW, 0, arrowW),
        Position               = UDim2.new(1, -(arrowW + math.floor(CW*0.025)), 0.5, -math.floor(arrowW/2)),
        BackgroundColor3       = Color3.fromRGB(12, 7, 2),
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = checkBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = verifyArrow })
    Create("TextLabel", {
        Text                   = "▶",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(255, 220, 120),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(12),
        ZIndex                 = 5,
        Parent                 = verifyArrow,
    })
    ButtonAnimation(checkBtn, Color3.fromRGB(212, 118, 14), Color3.fromRGB(242, 148, 22))

    Y = Y + BIG + GAP
    local HALF_W   = math.floor(CW * IW * 0.478)  
    local HALF_GAP = math.floor(CW * IW * 0.044) 
    local LEFT_X   = math.floor(CW * P)
    local RIGHT_X  = LEFT_X + HALF_W + HALF_GAP

    local SIB     = math.floor(SML * 0.64)
    local sIconX  = math.floor(SML * 0.13)
    local sTextX  = sIconX + SIB + math.floor(HALF_W * 0.05)

    local getKeyBtn = Create("TextButton", {
        Text             = "",
        Size             = UDim2.new(0, HALF_W, 0, SML),
        Position         = UDim2.new(0, LEFT_X, 0, Y),
        BackgroundColor3 = Color3.fromRGB(10, 8, 5),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = getKeyBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(180, 110, 14), Transparency = 0.22, Thickness = 1.5, Parent = getKeyBtn })
    Create("Frame", {
        Size             = UDim2.new(0, 2, 0, math.floor(SML * 0.55)),
        Position         = UDim2.new(0, 0, 0.5, -math.floor(SML * 0.275)),
        BackgroundColor3 = Color3.fromRGB(248, 148, 18),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = getKeyBtn,
    })
    local gkIconBox = Create("Frame", {
        Size                   = UDim2.new(0, SIB, 0, SIB),
        Position               = UDim2.new(0, sIconX, 0.5, -math.floor(SIB/2)),
        BackgroundColor3       = Color3.fromRGB(200, 115, 15),
        BackgroundTransparency = 0.78,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = getKeyBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = gkIconBox })
    Create("TextLabel", {
        Text                   = "🔑",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(13),
        ZIndex                 = 5,
        Parent                 = gkIconBox,
    })
    Create("TextLabel", {
        Text                   = "GET KEY",
        Size                   = UDim2.new(1, -sTextX, 0, math.floor(SML * 0.42)),
        Position               = UDim2.new(0, sTextX, 0, math.floor(SML * 0.10)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(238, 172, 48),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(11),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = getKeyBtn,
    })
    Create("TextLabel", {
        Text                   = "24hr Free",
        Size                   = UDim2.new(1, -sTextX, 0, math.floor(SML * 0.32)),
        Position               = UDim2.new(0, sTextX, 0, math.floor(SML * 0.55)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(112, 82, 40),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(8),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = getKeyBtn,
    })
    ButtonAnimation(getKeyBtn, Color3.fromRGB(10, 8, 5), Color3.fromRGB(18, 13, 7))

    local discordBtn = Create("TextButton", {
        Text             = "",
        Size             = UDim2.new(0, HALF_W, 0, SML),
        Position         = UDim2.new(0, RIGHT_X, 0, Y),
        BackgroundColor3 = Color3.fromRGB(8, 8, 12),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = discordBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(88, 82, 130), Transparency = 0.32, Thickness = 1.5, Parent = discordBtn })
    Create("Frame", {
        Size             = UDim2.new(0, 2, 0, math.floor(SML * 0.55)),
        Position         = UDim2.new(0, 0, 0.5, -math.floor(SML * 0.275)),
        BackgroundColor3 = Color3.fromRGB(130, 120, 210),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = discordBtn,
    })
    local discIconBox = Create("Frame", {
        Size                   = UDim2.new(0, SIB, 0, SIB),
        Position               = UDim2.new(0, sIconX, 0.5, -math.floor(SIB/2)),
        BackgroundColor3       = Color3.fromRGB(88, 101, 210),
        BackgroundTransparency = 0.76,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = discordBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = discIconBox })
    Create("TextLabel", {
        Text                   = "💬",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(13),
        ZIndex                 = 5,
        Parent                 = discIconBox,
    })
    local discordTitleLbl = Create("TextLabel", {
        Text                   = "DISCORD",
        Size                   = UDim2.new(1, -sTextX, 0, math.floor(SML * 0.42)),
        Position               = UDim2.new(0, sTextX, 0, math.floor(SML * 0.10)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(172, 168, 215),
        Font                   = Enum.Font.GothamBold,
        TextSize               = T(11),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = discordBtn,
    })
    Create("TextLabel", {
        Text                   = "Join Server",
        Size                   = UDim2.new(1, -sTextX, 0, math.floor(SML * 0.32)),
        Position               = UDim2.new(0, sTextX, 0, math.floor(SML * 0.55)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(80, 76, 108),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(8),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = discordBtn,
    })
    ButtonAnimation(discordBtn, Color3.fromRGB(8, 8, 12), Color3.fromRGB(14, 13, 22))

    Y = Y + SML + GAP
    local buyPermBtn = Create("TextButton", {
        Text             = "",
        Size             = UDim2.new(IW, 0, 0, BIG),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(9, 148, 132),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = buyPermBtn })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 172, 155)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 125, 112)),
        },
        Rotation = 90,
        Parent   = buyPermBtn,
    })
    Create("UIStroke", { Color = Color3.fromRGB(24, 205, 185), Transparency = 0.28, Thickness = 1, Parent = buyPermBtn })

    local buyIconBox = Create("Frame", {
        Size                   = UDim2.new(0, IB, 0, IB),
        Position               = UDim2.new(0, iconOffX, 0.5, -math.floor(IB/2)),
        BackgroundColor3       = Color3.fromRGB(5, 70, 62),
        BackgroundTransparency = 0.35,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = buyPermBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = buyIconBox })
    Create("TextLabel", {
        Text                   = "◆",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(185, 255, 248),
        Font                   = Enum.Font.GothamBlack,
        TextSize               = T(13),
        ZIndex                 = 5,
        Parent                 = buyIconBox,
    })

    local PRICE_W = math.floor(CW * 0.12)
    Create("TextLabel", {
        Text                   = "BUY PERMANENT ACCESS",
        Size                   = UDim2.new(1, -(textOffX + PRICE_W + math.floor(CW*0.06)), 0, math.floor(BIG * 0.46)),
        Position               = UDim2.new(0, textOffX, 0, math.floor(BIG * 0.10)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(228, 255, 250),
        Font                   = Enum.Font.GothamBlack,
        TextSize               = T(12),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = buyPermBtn,
    })
    Create("TextLabel", {
        Text                   = "$3.99 / 350 Robux  ·  Crypto / Robux",
        Size                   = UDim2.new(1, -(textOffX + PRICE_W + math.floor(CW*0.06)), 0, math.floor(BIG * 0.34)),
        Position               = UDim2.new(0, textOffX, 0, math.floor(BIG * 0.56)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(120, 200, 188),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(8),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
        Parent                 = buyPermBtn,
    })

    local priceBadge = Create("Frame", {
        Size                   = UDim2.new(0, PRICE_W, 0, math.floor(BIG * 0.56)),
        Position               = UDim2.new(1, -(PRICE_W + math.floor(CW*0.025)), 0.5, -math.floor(BIG*0.28)),
        BackgroundColor3       = Color3.fromRGB(5, 70, 62),
        BackgroundTransparency = 0.35,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = buyPermBtn,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = priceBadge })
    Create("TextLabel", {
        Text                   = "OPEN",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(185, 255, 248),
        Font                   = Enum.Font.GothamBlack,
        TextSize               = T(9),
        ZIndex                 = 5,
        Parent                 = priceBadge,
    })
    ButtonAnimation(buyPermBtn, Color3.fromRGB(9, 148, 132), Color3.fromRGB(12, 172, 155))
    buyPermBtn.MouseButton1Click:Connect(ShowBuyKeyGUI)

    Y = Y + BIG + GAP
    local loadBarBG = Create("Frame", {
        Size             = UDim2.new(IW, 0, 0, 2),
        Position         = UDim2.new(P, 0, 0, Y),
        BackgroundColor3 = Color3.fromRGB(22, 14, 8),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = main,
    })
    local loadBarFill = Create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(248, 148, 18),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = loadBarBG,
    })

    Y = Y + 2 + math.floor(GAP * 0.5)
    local status = Create("TextLabel", {
        Text                   = "Awaiting key input...",
        Size                   = UDim2.new(IW, 0, 0, math.floor(CH * 0.05)),
        Position               = UDim2.new(P, 0, 0, Y),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(82, 60, 40),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(9),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent                 = main,
    })

    Create("TextLabel", {
        Text                   = "PHANTOM  •  KEY SYSTEM",
        Size                   = UDim2.new(1, -18, 0, math.floor(CH * 0.04)),
        Position               = UDim2.new(0, 9, 1, -math.floor(CH * 0.05)),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(30, 20, 12),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = T(8),
        TextXAlignment         = Enum.TextXAlignment.Right,
        ZIndex                 = 3,
        Parent                 = main,
    })

    main.BackgroundTransparency = 1
    main.Position = UDim2.new(0.5, -CardW()/2, 0.65, -CardH()/2)
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -CardW()/2, 0.5, -CardH()/2),
    }):Play()

    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(getclipboard)
        if ok and type(clip) == "string" and clip ~= "" then
            keyBox.Text       = clip
            status.Text       = "Key pasted from clipboard."
            status.TextColor3 = Color3.fromRGB(195, 142, 38)
        else
            status.Text       = "Clipboard read failed."
            status.TextColor3 = Color3.fromRGB(228, 68, 50)
        end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        local link = "https://phantom-script.vercel.app"
        if pcall(setclipboard, link) then
            status.Text       = "Link copied — open in your browser."
            status.TextColor3 = Color3.fromRGB(195, 142, 38)
            task.delay(3.5, function()
                if status and status.Parent
                and status.Text == "Link copied — open in your browser." then
                    status.Text       = "Awaiting key input..."
                    status.TextColor3 = Color3.fromRGB(82, 60, 40)
                end
            end)
        end
    end)

    discordBtn.MouseButton1Click:Connect(function()
        if pcall(setclipboard, DiscordLink) then
            discordTitleLbl.Text = "✓  COPIED!"
            task.delay(2, function()
                if discordTitleLbl and discordTitleLbl.Parent then
                    discordTitleLbl.Text = "DISCORD"
                end
            end)
        end
    end)

    local isVerifying = false

    checkBtn.MouseButton1Click:Connect(function()
        if isVerifying then return end

        local key = TrimKey(keyBox.Text)
        if key == "" then
            status.Text       = "Key field cannot be empty."
            status.TextColor3 = Color3.fromRGB(228, 68, 50)
            local origPos = main.Position
            task.spawn(function()
                for _ = 1, 3 do
                    TweenService:Create(main, TweenInfo.new(0.04), {
                        Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 6,
                                             origPos.Y.Scale, origPos.Y.Offset)
                    }):Play()
                    task.wait(0.05)
                    TweenService:Create(main, TweenInfo.new(0.04), {
                        Position = UDim2.new(origPos.X.Scale, origPos.X.Offset - 6,
                                             origPos.Y.Scale, origPos.Y.Offset)
                    }):Play()
                    task.wait(0.05)
                end
                TweenService:Create(main, TweenInfo.new(0.04), { Position = origPos }):Play()
            end)
            return
        end

        isVerifying              = true
        checkBtnLbl.Text         = "AUTHENTICATING..."
        checkBtn.AutoButtonColor = false
        status.Text              = "Connecting to server..."
        status.TextColor3        = Color3.fromRGB(195, 142, 38)
        TweenService:Create(loadBarFill, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.55, 0, 1, 0)
        }):Play()

        task.spawn(function()
            local success, msg = ValidateKey(key)

            if success then
                pcall(writefile, KeyFileName, key)

                status.Text       = "Authenticated — launching..."
                status.TextColor3 = Color3.fromRGB(38, 205, 115)
                TweenService:Create(loadBarFill,
                    TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 1, 0)
                    }):Play()
                task.wait(0.8)

                TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, -CardW()/2, 0.43, -CardH()/2),
                }):Play()
                TweenService:Create(bg,      TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(ambient, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                task.wait(0.46)
                gui:Destroy()

                ShowInitializingScreen(key)

            else
                local lmsg = tostring(msg):lower()
                local displayMsg
                if lmsg:find("hwid mismatch") or lmsg:find("hwid") then
                    displayMsg = "⚠️ HWID Mismatch — This key is locked to another device"
                elseif lmsg:find("expired") then
                    displayMsg = "⏰ Key Expired — Get a new key at phantom-script.vercel.app"
                elseif lmsg:find("disabled") then
                    displayMsg = "🚫 Key Disabled — Contact support"
                elseif lmsg:find("invalid") then
                    displayMsg = "❌ Invalid Key — Check the key and try again"
                else
                    displayMsg = "❌ " .. tostring(msg)
                end
                status.Text              = displayMsg
                status.TextColor3        = Color3.fromRGB(228, 68, 50)
                TweenService:Create(loadBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 0, 1, 0)
                }):Play()
                checkBtnLbl.Text         = "VERIFY  &  LAUNCH"
                checkBtn.AutoButtonColor = true
                isVerifying              = false
            end
        end)
    end)
end

local function Init()
    if _G.PhantomKeyRunning then
        if _G.Phantom_Cleanup then
            pcall(_G.Phantom_Cleanup)
            task.wait(0.15)
        else
            return
        end
        _G.PhantomKeyRunning = false
    end

    _G.PhantomKeyRunning = true
    task.spawn(function()
        local hasSavedKey = isfile and isfile(KeyFileName)
        if hasSavedKey then
            local rawKey = ""
            local readOk = pcall(function() rawKey = readfile(KeyFileName) end)
            if readOk then
                local savedKey = TrimKey(rawKey)
                if savedKey ~= "" then
                    local valid, _ = ValidateKey(savedKey)
                    if valid then
                        ShowInitializingScreen(savedKey)
                        return
                    else
                        pcall(delfile, KeyFileName)
                    end
                end
            end
        end
        BuildGUI()
    end)
end

Init()
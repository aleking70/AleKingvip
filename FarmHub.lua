-- =====================================================================
-- 👑 ALEKING FARM HUB (estilo Genesis) - Script completo de farm y utilidades
-- Instrucciones: Pegar en tu executor. Reemplaza asset id si quieres otro logo.
-- =====================================================================

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Namespace seguro
local AK = (getgenv and getgenv().AleKingFarmHub) or {}
getgenv().AleKingFarmHub = AK

-- Valores por defecto
AK.AutoFarm = AK.AutoFarm or false
AK.FarmSpeed = AK.FarmSpeed or 0.3
AK.AutoRebirth = AK.AutoRebirth or false
AK.AutoEgg = AK.AutoEgg or false
AK.AntiLag = AK.AntiLag or false

AK.StartStr = AK.StartStr or 0
AK.StartDur = AK.StartDur or 0
AK.StartRb = AK.StartRb or 0
AK.FuerzaPorSegundo = AK.FuerzaPorSegundo or 0
AK.DuraPorSegundo = AK.DuraPorSegundo or 0
AK.FarmStartTime = AK.FarmStartTime or os.time()
AK.RebirthStartTime = AK.RebirthStartTime or os.time()

-- Helpers
local function safeFire(remoteName, ...)
    local ok, result = pcall(function()
        local remote = player:FindFirstChild(remoteName) or ReplicatedStorage:FindFirstChild(remoteName)
        if remote and type(remote.FireServer) == "function" then
            remote:FireServer(...)
            return true
        end
        return false
    end)
    if not ok then warn("safeFire error for", remoteName) end
    return ok and result
end

local function Format(v)
    if tonumber(v) == nil then return tostring(v) end
    v = tonumber(v)
    if v >= 1e9 then return string.format("%.2fB", v / 1e9)
    elseif v >= 1e6 then return string.format("%.2fM", v / 1e6)
    elseif v >= 1e3 then return string.format("%.1fK", v / 1e3) end
    return tostring(v)
end

-- Intentar obtener leaderstats (no fatal si no existe)
local function tryGetStats()
    local s = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 10)
    return s
end

AK.Stats = tryGetStats()

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    if player and player.Idled then
        player.Idled:Connect(function()
            pcall(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end
end)

-- UI: root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AleKingFarmHub"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 300)
Main.Position = UDim2.new(0.5, -260, 0.4, -150)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Main.BackgroundTransparency = 0.12
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

local Top = Instance.new("Frame", Main)
Top.Name = "Top"
Top.Size = UDim2.new(1, 0, 0, 36)
Top.Position = UDim2.new(0,0,0,0)
Top.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Top.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Top)
Title.Text = "👑 AleKing Farm Hub"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center

-- Logo (usa tu asset id)
local Logo = Instance.new("ImageLabel", Top)
Logo.Name = "Logo"
Logo.Image = "rbxassetid://121683317664395"
Logo.Size = UDim2.new(0, 28, 0, 28)
Logo.Position = UDim2.new(0, 12, 0, 4)
Logo.BackgroundTransparency = 1
Logo.ScaleType = Enum.ScaleType.Fit
pcall(function() ContentProvider:PreloadAsync({Logo}) end)

-- Close / Minimize buttons
local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.new(0, 28, 0, 20)
MinBtn.Position = UDim2.new(1, -60, 0, 8)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 0.6
MinBtn.BorderSizePixel = 0

local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.new(0, 28, 0, 20)
CloseBtn.Position = UDim2.new(1, -28, 0, 8)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BackgroundTransparency = 0.6
CloseBtn.BorderSizePixel = 0

-- Tabs bar
local Tabs = Instance.new("Frame", Main)
Tabs.Name = "Tabs"
Tabs.Size = UDim2.new(1, 0, 0, 36)
Tabs.Position = UDim2.new(0,0,0,36)
Tabs.BackgroundTransparency = 1

local function MakeTab(name, x)
    local b = Instance.new("TextButton", Tabs)
    b.Size = UDim2.new(0, 110, 1, 0)
    b.Position = UDim2.new(0, x, 0, 0)
    b.Text = name
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.BackgroundTransparency = 0.7
    b.BorderSizePixel = 0
    return b
end

local TabFarm = MakeTab("Farm", 8)
local TabRebirth = MakeTab("Rebirth", 120)
local TabEquip = MakeTab("Equip", 232)
local TabTP = MakeTab("Server Hop", 344)
local TabMisc = MakeTab("Misc", 456)

-- Content area
local ContentFrame = Instance.new("Frame", Main)
ContentFrame.Size = UDim2.new(1, 0, 1, -72)
ContentFrame.Position = UDim2.new(0,0,0,72)
ContentFrame.BackgroundTransparency = 1

-- Simple helper to clear children
local function clearContent()
    for _,c in ipairs(ContentFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then pcall(function() c:Destroy() end) end
    end
end

-- UI element creators
local function makeLabel(txt, y)
    local L = Instance.new("TextLabel", ContentFrame)
    L.Size = UDim2.new(1, -20, 0, 20)
    L.Position = UDim2.new(0, 10, 0, y)
    L.BackgroundTransparency = 1
    L.Text = txt
    L.TextColor3 = Color3.fromRGB(230,230,230)
    L.Font = Enum.Font.SourceSans
    L.TextSize = 14
    L.TextXAlignment = Enum.TextXAlignment.Left
    return L
end

local function makeButton(txt, y, cb, checked)
    local B = Instance.new("TextButton", ContentFrame)
    B.Size = UDim2.new(0, 200, 0, 28)
    B.Position = UDim2.new(0, 10, 0, y)
    B.Text = (checked and "✓ " or "") .. txt
    B.Font = Enum.Font.SourceSansBold
    B.TextSize = 14
    B.TextColor3 = Color3.fromRGB(255,255,255)
    B.BackgroundColor3 = checked and Color3.fromRGB(45,120,45) or Color3.fromRGB(120,30,40)
    B.BorderSizePixel = 0
    B.MouseButton1Click:Connect(function()
        cb(B)
    end)
    return B
end

-- Farm tab implementation
local function showFarm()
    clearContent()
    makeLabel("⚡ Fast Farm", 6)
    local status = makeLabel("Status: Inactive", 32)
    local statsLabel = makeLabel("Strength: 0 | Gained: 0", 56)
    local duraLabel = makeLabel("Durability: 0 | Gained: 0", 76)
    local speedBtn = makeButton("Controlled Speed (0.3s)", 110, function(b)
        AK.AutoFarm = not AK.AutoFarm
        AK.FarmSpeed = 0.3
        if AK.AutoFarm then
            b.Text = "✓ Controlled Speed (0.3s)"
            b.BackgroundColor3 = Color3.fromRGB(45,120,45)
            AK.FarmStartTime = os.time()
            task.spawn(function()
                while AK.AutoFarm and AK.FarmSpeed == 0.3 do
                    safeFire("muscleEvent", "punchClick")
                    task.wait(0.3)
                end
            end)
        else
            b.Text = "Controlled Speed (0.3s)"
            b.BackgroundColor3 = Color3.fromRGB(120,30,40)
        end
    end, AK.AutoFarm and AK.FarmSpeed == 0.3)

    local fastBtn = makeButton("Fast Rep (0.05s)", 150, function(b)
        AK.AutoFarm = not AK.AutoFarm
        AK.FarmSpeed = 0.05
        if AK.AutoFarm then
            b.Text = "✓ Fast Rep (0.05s)"
            b.BackgroundColor3 = Color3.fromRGB(45,120,45)
            AK.FarmStartTime = os.time()
            task.spawn(function()
                while AK.AutoFarm and AK.FarmSpeed == 0.05 do
                    safeFire("muscleEvent", "punchClick")
                    task.wait(0.05)
                end
            end)
        else
            b.Text = "Fast Rep (0.05s)"
            b.BackgroundColor3 = Color3.fromRGB(120,30,40)
        end
    end, AK.AutoFarm and AK.FarmSpeed == 0.05)

    -- Real-time update loop
    task.spawn(function()
        local lastStr = (AK.Stats and AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or 0
        local lastDur = (AK.Stats and AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or 0
        while ContentFrame and ContentFrame.Parent do
            local curStr = (AK.Stats and AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or lastStr
            local curDur = (AK.Stats and AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or lastDur
            AK.FuerzaPorSegundo = math.max(0, curStr - lastStr)
            AK.DuraPorSegundo = math.max(0, curDur - lastDur)
            lastStr, lastDur = curStr, curDur
            statsLabel.Text = "Strength: "..Format(curStr).." | Gained: "..Format(math.max(0, curStr - AK.StartStr))
            duraLabel.Text = "Durability: "..Format(curDur).." | Gained: "..Format(math.max(0, curDur - AK.StartDur))
            if AK.AutoFarm then
                local diff = os.time() - AK.FarmStartTime
                status.Text = string.format("Status: Active - %dh %dm %ds", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else
                status.Text = "Status: Inactive"
            end
            task.wait(0.6)
        end
    end)
end

-- Rebirth tab
local function showRebirth()
    clearContent()
    makeLabel("🔄 Auto Rebirth", 6)
    local status = makeLabel("Status: Inactive", 32)
    local rebLabel = makeLabel("Rebirths: 0 | Gained: 0", 56)

    local rbBtn = makeButton("Fast Rebirth (1s)", 100, function(b)
        AK.AutoRebirth = not AK.AutoRebirth
        if AK.AutoRebirth then
            b.Text = "✓ Fast Rebirth (1s)"
            b.BackgroundColor3 = Color3.fromRGB(45,120,45)
            AK.RebirthStartTime = os.time()
            if AK.Stats and AK.Stats:FindFirstChild("Rebirths") then AK.StartRb = AK.Stats.Rebirths.Value end
            task.spawn(function()
                while AK.AutoRebirth do
                    safeFire("muscleEvent", "rebirthRequest")
                    task.wait(1)
                end
            end)
        else
            b.Text = "Fast Rebirth (1s)"
            b.BackgroundColor3 = Color3.fromRGB(120,30,40)
        end
    end, AK.AutoRebirth)

    task.spawn(function()
        while ContentFrame and ContentFrame.Parent do
            local curRb = (AK.Stats and AK.Stats:FindFirstChild("Rebirths") and AK.Stats.Rebirths.Value) or 0
            rebLabel.Text = "Rebirths: "..Format(curRb).." | Gained: "..Format(math.max(0, curRb - AK.StartRb))
            if AK.AutoRebirth then
                local diff = os.time() - AK.RebirthStartTime
                status.Text = string.format("Status: Rebirthing - %dh %dm %ds", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else
                status.Text = "Status: Inactive"
            end
            task.wait(0.6)
        end
    end)
end

-- Equip tab (intenta equipar todas las Tools del Backpack/StarterPack/Character)
local function showEquip()
    clearContent()
    makeLabel("🧰 Equip / Manage", 6)
    local info = makeLabel("Equipará herramientas encontradas en Backpack/StarterPack/Character.", 34)
    local equipBtn = makeButton("Equip All Tools", 80, function()
        -- Mover herramientas al Character
        local function tryEquip(tool)
            pcall(function()
                if tool and tool.Parent then
                    tool.Parent = char
                end
            end)
        end
        for _,t in ipairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") then tryEquip(t) end
        end
        for _,t in ipairs(player:GetChildren()) do
            if t:IsA("Tool") then tryEquip(t) end
        end
    end)
end

-- Server hop tab (placeholder seguro)
local function showServerHop()
    clearContent()
    makeLabel("🌐 Server Hop (safe placeholder)", 6)
    makeLabel("Nota: Server hop real requiere HttpEnabled y puede usar endpoints públicos; esta función intentará Teleport a otra instancia si es posible.", 34)
    local hopBtn = makeButton("Try Server Hop", 100, function(b)
        -- Intentar obtener lista de servidores públicos (requiere HttpService and Game.PlaceId)
        local placeId = game.PlaceId
        local success, data = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId)
            local res = HttpService:GetAsync(url)
            return res
        end)
        if not success then
            warn("Server hop: HttpService no disponible o petición falló.")
            return
        end
        local ok, parsed = pcall(function() return HttpService:JSONDecode(data) end)
        if not ok or not parsed.data then
            warn("Server hop: No se pudo parsear respuesta.")
            return
        end
        -- encontrar un server distinto del actual
        local cur = game.JobId
        for _,s in ipairs(parsed.data) do
            if s.id and s.id ~= cur and s.maxPlayers and s.playing < s.maxPlayers then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, player)
                end)
                return
            end
        end
        warn("Server hop: no se encontró instancia disponible.")
    end)
end

-- Misc tab
local function showMisc()
    clearContent()
    makeLabel("⚙️ Misc Utilities", 6)
    local antiBtn = makeButton("Anti Lag (Simplified)", 80, function(b)
        AK.AntiLag = not AK.AntiLag
        if AK.AntiLag then
            b.Text = "✓ Anti Lag"
            b.BackgroundColor3 = Color3.fromRGB(45,120,45)
            pcall(function() if workspace:FindFirstChild("Terrain") then workspace.Terrain.WaterWaveSize = 0 end end)
            pcall(function()
                for _,o in pairs(workspace:GetDescendants()) do
                    if o:IsA("BasePart") then
                        o.Material = Enum.Material.SmoothPlastic
                        o.CastShadow = false
                    end
                end
            end)
        else
            b.Text = "Anti Lag (Simplified)"
            b.BackgroundColor3 = Color3.fromRGB(120,30,40)
            warn("AntiLag desactivado: no se restauraron todas las propiedades.")
        end
    end, AK.AntiLag)
    local eggBtn = makeButton("Auto Egg Claim", 120, function(b)
        AK.AutoEgg = not AK.AutoEgg
        if AK.AutoEgg then
            b.Text = "✓ Auto Egg"
            b.BackgroundColor3 = Color3.fromRGB(45,120,45)
            task.spawn(function()
                while AK.AutoEgg do
                    safeFire("muscleEvent", "claimTimeGiftRequest")
                    task.wait(10)
                end
            end)
        else
            b.Text = "Auto Egg Claim"
            b.BackgroundColor3 = Color3.fromRGB(120,30,40)
        end
    end, AK.AutoEgg)
end

-- Hook tab buttons
TabFarm.MouseButton1Click:Connect(showFarm)
TabRebirth.MouseButton1Click:Connect(showRebirth)
TabEquip.MouseButton1Click:Connect(showEquip)
TabTP.MouseButton1Click:Connect(showServerHop)
TabMisc.MouseButton1Click:Connect(showMisc)

-- Minimize / Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        Tabs.Visible = false
        Main.Size = UDim2.new(0, 180, 0, 36)
        Top.Size = UDim2.new(1, 0, 0, 36)
    else
        ContentFrame.Visible = true
        Tabs.Visible = true
        Main.Size = UDim2.new(0, 520, 0, 300)
    end
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Dragging (UserInputService)
do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Mostrar Farm por defecto
showFarm()

-- Exponer AK
getgenv().AleKingFarmHub = AK

-- Fin

-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - PROPIEDAD EXCLUSIVA DE: AleKing
-- ARCHIVO CENTRAL: AleKingHubVIP.lua | VERSIÓN 2026 PRIVADA
-- =====================================================================

local _G = getgenv and getgenv() or _G
_G.AutoFarm = false
_G.AutoRebirth = false
_G.FarmSpeed = 0.3
_G.AntiLagActive = false

-- Huevo de 30 min y zonas reales
_G.AutoEgg30Min = false
_G.JungleLift = false
_G.JungleSquat = false

-- Registro de rendimiento por segundo
_G.FuerzaPorSegundo = 0
_G.DuraPorSegundo = 0
_G.StartStr = 0
_G.StartDur = 0
_G.StartRb = 0
_G.FarmStartTime = os.time()
_G.RebirthStartTime = os.time()

local player = game:GetService("Players").LocalPlayer
local stats = player:WaitForChild("leaderstats", 15)

-- Bucle matemático asíncrono para promedios por hora reales
task.spawn(function()
    if not stats then return end
    local ultStr, ultDur = stats.Strength.Value, stats.Durability.Value
    while true do
        if _G.AutoFarm then
            _G.FuerzaPorSegundo = math.max(0, stats.Strength.Value - ultStr)
            _G.DuraPorSegundo = math.max(0, stats.Durability.Value - ultDur)
        else
            _G.FuerzaPorSegundo, _G.DuraPorSegundo = 0, 0
        end
        ultStr, ultDur = stats.Strength.Value, stats.Durability.Value
        task.wait(1)
    end
end)

-- Compartir servicios básicos
_G.AleKingPlayer = player
_G.AleKingStats = stats
-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - BLOQUE 2: DISEÑO DE LA INTERFAZ
-- =====================================================================

local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Top = Instance.new("TextButton")
local Tabs = Instance.new("Frame")
local Content = Instance.new("Frame")

ScreenGui.Name = "AleKingHubVIP"
ScreenGui.Parent = game:GetService("CoreGui") or _G.AleKingPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Cuadro principal deslizable
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(40, 5, 10)
Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -225, 0.62, 0)
Main.Size = UDim2.new(0, 450, 0, 250)
Main.Active = true
Main.Draggable = true

-- Barra superior con tu propia firma de creador
Top.Name = "Top"
Top.Parent = Main
Top.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
Top.Size = UDim2.new(1, 0, 0, 25)
Top.Text = "👑 AleKing Hub VIP | Fast Farming - Premium Edition"
Top.TextColor3 = Color3.fromRGB(255, 255, 255)
Top.TextSize = 13
Top.Font = Enum.Font.SourceSansBold
Top.BorderSizePixel = 0

-- Ocultar todo el cuerpo inferior al tocar tu barra roja
local visible = true
Top.MouseButton1Click:Connect(function()
    visible = not visible
    Tabs.Visible = visible
    Content.Visible = visible
end)

Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(40, 5, 10)
Tabs.BackgroundTransparency = 0.35
Tabs.Position = UDim2.new(0, 0, 0, 25)
Tabs.Size = UDim2.new(1, 0, 0, 30)
Tabs.BorderSizePixel = 0

Content.Name = "Content"
Content.Parent = Main
Content.BackgroundColor3 = Color3.fromRGB(40, 5, 10)
Content.BackgroundTransparency = 0.35
Content.Position = UDim2.new(0, 0, 0, 55)
Content.Size = UDim2.new(1, 0, 1, -55)
Content.BorderSizePixel = 0

-- Compartir contenedores con los siguientes bloques
_G.AKMain, _G.AKTabs, _G.AKContent = Main, Tabs, Content
-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - BLOQUE 3: HERRAMIENTAS DE INTERFAZ
-- =====================================================================

local Content = _G.AKContent
local elements = {}

local function Clear()
    if _G.AKScroll then _G.AKScroll.Visible = false end
    for _, e in ipairs(elements) do e:Destroy() end
    elements = {}
end

local function CreateTabButton(txt, posX, ancho)
    local B = Instance.new("TextButton")
    B.Parent = _G.AKTabs; B.BackgroundTransparency = 1; B.Position = UDim2.new(0, posX, 0, 0); B.Size = UDim2.new(0, ancho, 1, 0)
    B.Text = txt; B.TextColor3 = Color3.fromRGB(255, 255, 255); B.Font = Enum.Font.SourceSansBold; B.TextSize = 13
    return B
end

local function CreateLabel(parent, txt, posY, font, color)
    local L = Instance.new("TextLabel")
    L.Parent = parent; L.Size = UDim2.new(1, -30, 0, 16); L.Position = UDim2.new(0, 15, 0, posY); L.BackgroundTransparency = 1
    L.Text = txt; L.TextColor3 = color or Color3.fromRGB(255, 255, 255); L.TextSize = 13; L.Font = font or Enum.Font.SourceSans; L.TextXAlignment = Enum.TextXAlignment.Left
    if parent == Content then table.insert(elements, L) end
    return L
end

local function CreateButton(parent, txt, posY, isChecked, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent; B.Size = UDim2.new(0, 160, 0, 24); B.Position = UDim2.new(0, 15, 0, posY); B.Font = Enum.Font.SourceSansBold; B.TextSize = 13; B.TextColor3 = Color3.fromRGB(255, 255, 255); B.BorderSizePixel = 0
    local function up() B.BackgroundColor3 = isChecked and Color3.fromRGB(45, 90, 45) or Color3.fromRGB(130, 25, 30); B.Text = isChecked and "✓ " .. txt or txt end
    B.MouseButton1Click:Connect(function() isChecked = not isChecked; up(); cb(isChecked) end)
    up()
    if parent == Content then table.insert(elements, B) end
    return B
end

local function Format(v)
    if v >= 1e9 then return string.format("%.2fB", v / 1e9)
    elseif v >= 1e6 then return string.format("%.2fM", v / 1e6)
    elseif v >= 1e3 then return string.format("%.1fK", v / 1e3) end
    return tostring(v)
end

_G.AKBtn1, _G.AKBtn2, _G.AKBtn3 = CreateTabButton("Fast Rebirth", 20, 90), CreateTabButton("Fast Farm", 130, 80), CreateTabButton("Misc", 230, 60)
_G.AKClear, _G.AKLabel, _G.AKButton, _G.AKFormat = Clear, CreateLabel, CreateButton, Format
-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - BLOQUE 4: PESTAÑA FAST FARM REAL
-- =====================================================================

local Content = _G.AKContent
local stats = _G.AleKingStats

local function ShowFarm()
    _G.AKClear()
    if not stats then return end
    
    if _G.StartStr == 0 then _G.StartStr = stats.Strength.Value end
    if _G.StartDur == 0 then _G.StartDur = stats.Durability.Value end
    
    local L1 = _G.AKLabel(Content, "Dura: 0/Hour | 0/Day | 0/Week", 5, Enum.Font.SourceSansBold, Color3.fromRGB(255, 140, 0))
    local L2 = _G.AKLabel(Content, "Average Fuerza: 0/Hour", 23, Enum.Font.SourceSansBold, Color3.fromRGB(255, 140, 0))
    
    local LTimer = _G.AKLabel(Content, "0d 0h 0m 0s - Fast Rep Inactive", 45, Enum.Font.SourceSansBold, Color3.fromRGB(235, 120, 30))
    local LRealStr = _G.AKLabel(Content, "Strength: 0 | Gained: 0", 68, Enum.Font.SourceSansBold)
    local LRealDur = _G.AKLabel(Content, "Durability: 0 | Gained: 0", 86, Enum.Font.SourceSansBold)
    
    task.spawn(function()
        while LRealStr and LRealStr.Parent do
            local dH = _G.DuraPorSegundo * 3600
            L1.Text = "Dura: " .. _G.AKFormat(dH) .. "/Hour | " .. _G.AKFormat(dH * 24) .. "/Day | " .. _G.AKFormat(dH * 168) .. "/Week"
            L2.Text = "Average Fuerza: " .. _G.AKFormat(_G.FuerzaPorSegundo * 3600) .. "/Hour"
            LRealStr.Text = "Strength: " .. _G.AKFormat(stats.Strength.Value) .. " | Gained: " .. _G.AKFormat(math.max(0, stats.Strength.Value - _G.StartStr))
            LRealDur.Text = "Durability: " .. _G.AKFormat(stats.Durability.Value) .. " | Gained: " .. _G.AKFormat(math.max(0, stats.Durability.Value - _G.StartDur))
            
            if _G.AutoFarm then
                local diff = os.time() - _G.FarmStartTime
                LTimer.Text = string.format("0d %dh %dm %ds - Fast Rep Active", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else LTimer.Text = "0d 0h 0m 0s - Fast Rep Inactive" end
            task.wait(0.5)
        end
    end)
    
    _G.AKLabel(Content, "⚡ Fast Farm:", 110, Enum.Font.SourceSansBold)
    _G.AKLabel(Content, "Rep Speed:", 128)
    
    _G.AKButton(Content, "Controlled Speed", 148, _G.AutoFarm and _G.FarmSpeed == 0.3, function(st)
        _G.AutoFarm = st; _G.FarmSpeed = 0.3; if st then _G.FarmStartTime = os.time() end
        if st then task.spawn(function() while _G.AutoFarm and _G.FarmSpeed == 0.3 do _G.AleKingPlayer.muscleEvent:FireServer("punchClick") task.wait(0.3) end end) end
    end)
    
    _G.AKButton(Content, "Fast Rep", 176, _G.AutoFarm and _G.FarmSpeed == 0.05, function(st)
        _G.AutoFarm = st; _G.FarmSpeed = 0.05; if st then _G.FarmStartTime = os.time() end
        if st then task.spawn(function() while _G.AutoFarm and _G.FarmSpeed == 0.05 do _G.AleKingPlayer.muscleEvent:FireServer("punchClick") task.wait(0.05) end end) end
    end)
end

_G.AleKingShowFarm = ShowFarm
_G.AKBtn2.MouseButton1Click:Connect(ShowFarm)
-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - BLOQUE 5: REBIRTH, MISC Y ACTIVACIÓN
-- =====================================================================

local Content = _G.AKContent
local Scroll = _G.AleKingScroll or Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"; Scroll.Parent = Content; Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 4; Scroll.Visible = false
_G.AKScroll = Scroll

-- PESTAÑA REBIRTH
_G.AKBtn1.MouseButton1Click:Connect(function()
    _G.AKClear()
    _G.AKLabel(Content, "📊 Stats Rebirth:", 5, Enum.Font.SourceSansBold)
    local LTimer = _G.AKLabel(Content, "0d 0h 0m 0s - Rebirthing", 23, Enum.Font.SourceSansBold, Color3.fromRGB(0, 230, 0))
    local LRb = _G.AKLabel(Content, "Rebirths: 0 | Gained: 0", 45)
    
    task.spawn(function()
        if _G.StartRb == 0 and _G.AleKingStats then _G.StartRb = _G.AleKingStats.Rebirths.Value end
        while LRb and LRb.Parent do
            LRb.Text = "Rebirths: " .. _G.AKFormat(_G.AleKingStats.Rebirths.Value) .. " | Gained: " .. _G.AKFormat(math.max(0, _G.AleKingStats.Rebirths.Value - _G.StartRb))
            if _G.AutoRebirth then
                local diff = os.time() - _G.RebirthStartTime
                LTimer.Text = string.format("0d %dh %dm %ds - Rebirthing", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else LTimer.Text = "0d 0h 0m 0s - Rebirth Inactive" end
            task.wait(0.5)
        end
    end)
    
    _G.AKLabel(Content, "🔄 Rebirth:", 80, Enum.Font.SourceSansBold)
    _G.AKButton(Content, "Fast Rebirth", 102, _G.AutoRebirth, function(st)
        _G.AutoRebirth = st; if st then _G.RebirthStartTime = os.time(); _G.StartRb = _G.AleKingStats.Rebirths.Value end
        if st then task.spawn(function() while _G.AutoRebirth do _G.AleKingPlayer.muscleEvent:FireServer("rebirthRequest") task.wait(1) end end) end
    end)
end)

-- PESTAÑA MISC AVANZADA
_G.AKBtn3.MouseButton1Click:Connect(function()
    _G.AKClear(); Scroll.Visible = true
    for _, c in ipairs(Scroll:GetChildren()) do c:Destroy() end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 280)
    
    _G.AKButton(Scroll, "Lock Position", 5, true, function(st) _G.AKMain.Draggable = not st end)
    
    _G.AKButton(Scroll, "Anti Lag", 33, _G.AntiLagActive, function(st)
        _G.AntiLagActive = st
        if st then
            pcall(function() game:GetService("Lighting").Sky:Destroy() end)
            game:GetService("Lighting").Ambient = Color3.fromRGB(0,0,0)
            for _, o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") then o.Material = Enum.Material.SmoothPlastic end end
        end
    end)
    
    -- Mecánica Real: Auto Egg de regalo cada 30 min (claimTimeGiftRequest)
    _G.AKButton(Scroll, "Auto Egg (30 Min)", 61, _G.AutoEgg30Min, function(st)
        _G.AutoEgg30Min = st
        if st then task.spawn(function() while _G.AutoEgg30Min do _G.AleKingPlayer.muscleEvent:FireServer("claimTimeGiftRequest") task.wait(10) end end) end
    end)
    
    -- Zonas de teletransporte y cultivo real en la Selva
    _G.AKButton(Scroll, "Jungle Lift", 89, _G.JungleLift, function(st)
        _G.JungleLift = st; local hrp = _G.AleKingPlayer.Character:FindFirstChild("HumanoidRootPart")
        if st and hrp then hrp.CFrame = CFrame.new(2000, 250, 1000)
            task.spawn(function() while _G.JungleLift do _G.AleKingPlayer.muscleEvent:FireServer("jungleLiftRequest") task.wait(0.2) end end)
        end
    end)
end)

-- Ejecutar el arranque automático e impecable
_G.AleKingShowFarm()

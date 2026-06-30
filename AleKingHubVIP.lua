-- =====================================================================
-- 👑 ALEKING HUB VIP PREMIUM - BLOQUE 1: CORE Y DESPLAZAMIENTO TWEEN (Refactor estilo Genesis)
-- PROPIEDAD: AleKing | Versión mejorada: seguridad, logo, drag con UserInputService
-- =====================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local stats = nil

-- Namespace seguro en getgenv
local AK = (getgenv and getgenv().AleKingHub) or {}
getgenv().AleKingHub = AK

-- Valores por defecto (si no existen)
AK.AutoFarm = AK.AutoFarm or false
AK.AutoRebirth = AK.AutoRebirth or false
AK.FarmSpeed = AK.FarmSpeed or 0.3
AK.AntiLagActive = AK.AntiLagActive or false
AK.AutoEgg30Min = AK.AutoEgg30Min or false
AK.JungleLift = AK.JungleLift or false

AK.FuerzaPorSegundo = AK.FuerzaPorSegundo or 0
AK.DuraPorSegundo = AK.DuraPorSegundo or 0
AK.StartStr, AK.StartDur, AK.StartRb = AK.StartStr or 0, AK.StartDur or 0, AK.StartRb or 0
AK.FarmStartTime = AK.FarmStartTime or os.time()
AK.RebirthStartTime = AK.RebirthStartTime or os.time()

-- UI elementos
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Top = Instance.new("TextButton")
local Tabs = Instance.new("Frame")
local Content = Instance.new("Frame")
local Scroll = Instance.new("ScrollingFrame")

-- Helper: espera leaderstats y comprueba campos
local function getStats(timeout)
    timeout = timeout or 15
    local root = player:WaitForChild("leaderstats", timeout)
    if not root then return nil end
    -- verificar campos comunes
    if not root:FindFirstChild("Strength") or not root:FindFirstChild("Durability") or not root:FindFirstChild("Rebirths") then
        warn("AleKingHubVIP: leaderstats incompletos (esperando Strength/Durability/Rebirths)")
        return root -- devolvemos root aunque falten campos para no romper UI, pero avisamos
    end
    return root
end

stats = getStats(15)
AK.Player = player
AK.Stats = stats

-- Safe FireServer wrapper (busca en player, ReplicatedStorage y evita errores)
local function safeFire(remoteName, ...)
    if not player then return false end
    local remote = player:FindFirstChild(remoteName) or ReplicatedStorage:FindFirstChild(remoteName) or player:FindFirstChildWhichIsA and player:FindFirstChildWhichIsA(remoteName)
    if not remote then
        -- intentar buscar por instancias con nombre en todo el Player
        remote = player:FindFirstChild(remoteName)
    end
    if not remote then return false end
    if type(remote.FireServer) ~= "function" then return false end
    local ok, _ = pcall(function() remote:FireServer(...) end)
    if not ok then warn("AleKingHubVIP: safeFire failed for", remoteName) end
    return ok
end

-- Anti-AFK (evita desconexión automática)
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

-- INTERFAZ INTEGRADA (Nesting Fijo)
ScreenGui.Name = "AleKingHubVIP"
-- Parent seguro: intentar CoreGui y fallback a PlayerGui
local parent_ok = false
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
    parent_ok = true
end)
if not parent_ok then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
ScreenGui.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(40, 5, 10)
Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -225, 0.55, 0)
Main.Size = UDim2.new(0, 450, 0, 240)
Main.Active = true
-- Main.Draggable = true -- sustituido por sistema de drag hermético abajo
Main.ClipsDescendants = true

Top.Name = "Top"
Top.Parent = Main
Top.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
Top.Size = UDim2.new(1, 0, 0, 25)
Top.Text = "👑 AleKing Hub VIP | Fast Farming - Premium Edition"
Top.TextColor3 = Color3.fromRGB(255, 255, 255)
Top.TextSize = 13
Top.Font = Enum.Font.SourceSansBold
Top.BorderSizePixel = 0
Top.AutoButtonColor = false

-- Logo estilo Genesis (usando asset id proporcionado)
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Parent = Top
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://121683317664395" -- ID provisto por el usuario
Logo.Size = UDim2.new(0, 20, 0, 20)
Logo.Position = UDim2.new(0, 6, 0, 2)
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ZIndex = 2

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 4)
LogoCorner.Parent = Logo

pcall(function() ContentProvider:PreloadAsync({Logo}) end)

-- OCULTADO PREMIUM POR DESPLAZAMIENTO (con Tween)
local visible = true
Top.MouseButton1Click:Connect(function()
    visible = not visible
    if visible then
        Main:TweenSize(UDim2.new(0, 450, 0, 240), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        task.delay(0.05, function() Tabs.Visible = true; Content.Visible = true end)
    else
        Tabs.Visible = false
        Content.Visible = false
        Main:TweenSize(UDim2.new(0, 450, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
    end
end)

-- Implementar drag con UserInputService (arrastre desde Top)
local dragging = false
local dragInput, dragStart, startPos

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

AK.Main, AK.Tabs, AK.Content, AK.Scroll = Main, Tabs, Content, Scroll
AK.Player, AK.Stats = player, stats

-- =====================================================================
-- BLOQUE 2: MOTOR MATEMÁTICO Y BOTONES (Refactor con seguridad)
-- =====================================================================

local Tabs = AK.Tabs
local Content = AK.Content
local Scroll = AK.Scroll

Tabs.Name = "Tabs"; Tabs.Parent = Main; Tabs.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Tabs.BackgroundTransparency = 0.8
Tabs.Position = UDim2.new(0, 0, 0, 25); Tabs.Size = UDim2.new(1, 0, 0, 30); Tabs.BorderSizePixel = 0

Content.Name = "Content"; Content.Parent = Main; Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 55); Content.Size = UDim2.new(1, 0, 1, -55); Content.BorderSizePixel = 0

Scroll.Name = "Scroll"; Scroll.Parent = Content; Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 4; Scroll.Visible = false

local elements = {}
local function Clear()
    Scroll.Visible = false
    for _, e in ipairs(elements) do if e and e.Destroy then pcall(function() e:Destroy() end) end end
    elements = {}
end

local function CreateTab(txt, posX, ancho)
    local B = Instance.new("TextButton")
    B.Parent = Tabs; B.BackgroundTransparency = 1; B.Position = UDim2.new(0, posX, 0, 0); B.Size = UDim2.new(0, ancho, 1, 0)
    B.Text = txt; B.TextColor3 = Color3.fromRGB(255, 255, 255); B.Font = Enum.Font.SourceSansBold; B.TextSize = 13
    return B
end

local Tab1, Tab2, Tab3 = CreateTab("Fast Rebirth", 20, 90), CreateTab("Fast Farm", 130, 80), CreateTab("Misc", 230, 60)

local function CreateLabel(parent, txt, posY, font, color)
    local L = Instance.new("TextLabel")
    L.Parent = parent; L.Size = UDim2.new(1, -30, 0, 16); L.Position = UDim2.new(0, 15, 0, posY); L.BackgroundTransparency = 1
    L.Text = txt; L.TextColor3 = color or Color3.fromRGB(255, 255, 255); L.TextSize = 13; L.Font = font or Enum.Font.SourceSans; L.TextXAlignment = Enum.TextXAlignment.Left
    if parent == Content then table.insert(elements, L) end
    return L
end

local function CreateButton(parent, txt, posY, isChecked, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent; B.Size = UDim2.new(0, 160, 0, 24); B.Position = UDim2.new(0, 15, 0, posY); B.Font = Enum.Font.SourceSansBold; B.TextSize = 13; B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.BackgroundTransparency = 0
    local function up()
        B.BackgroundColor3 = isChecked and Color3.fromRGB(45, 90, 45) or Color3.fromRGB(130, 25, 30)
        B.Text = isChecked and "✓ " .. txt or txt
    end
    B.MouseButton1Click:Connect(function() isChecked = not isChecked; up(); pcall(function() cb(isChecked) end) end)
    up()
    if parent == Content then table.insert(elements, B) end
    return B
end

local function Format(v)
    if tonumber(v) == nil then return tostring(v) end
    v = tonumber(v)
    if v >= 1e9 then return string.format("%.2fB", v / 1e9)
    elseif v >= 1e6 then return string.format("%.2fM", v / 1e6)
    elseif v >= 1e3 then return string.format("%.1fK", v / 1e3) end
    return tostring(v)
end

-- CALCULADOR DE GANANCIAS EN TIEMPO REAL
task.spawn(function()
    if not AK.Stats then return end
    local ultStr = (AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or 0
    local ultDur = (AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or 0
    while true do
        if AK.AutoFarm and AK.Stats and AK.Stats:FindFirstChild("Strength") and AK.Stats:FindFirstChild("Durability") then
            AK.FuerzaPorSegundo = math.max(0, AK.Stats.Strength.Value - ultStr)
            AK.DuraPorSegundo = math.max(0, AK.Stats.Durability.Value - ultDur)
        else AK.FuerzaPorSegundo, AK.DuraPorSegundo = 0, 0 end
        ultStr = (AK.Stats and AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or ultStr
        ultDur = (AK.Stats and AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or ultDur
        task.wait(1)
    end
end)

AK.Tab1, AK.Tab2, AK.Tab3 = Tab1, Tab2, Tab3
AK.Clear, AK.Label, AK.Button, AK.Format = Clear, CreateLabel, CreateButton, Format

-- =====================================================================
-- BLOQUE 3: REBIRTH, FARM Y ACTIVACIÓN
-- =====================================================================

local function ShowFarm()
    AK.Clear()
    if not AK.Stats then AK.Label(Content, "Stats no encontrados", 5, Enum.Font.SourceSansBold, Color3.fromRGB(255, 0, 0)); return end
    if AK.StartStr == 0 and AK.Stats:FindFirstChild("Strength") then AK.StartStr = AK.Stats.Strength.Value end
    if AK.StartDur == 0 and AK.Stats:FindFirstChild("Durability") then AK.StartDur = AK.Stats.Durability.Value end

    local L1 = AK.Label(Content, "Dura: 0/Hour | 0/Day | 0/Week", 5, Enum.Font.SourceSansBold, Color3.fromRGB(255, 140, 0))
    local L2 = AK.Label(Content, "Average Fuerza: 0/Hour", 23, Enum.Font.SourceSansBold, Color3.fromRGB(255, 140, 0))
    local LTimer = AK.Label(Content, "0d 0h 0m 0s - Fast Rep Inactive", 45, Enum.Font.SourceSansBold, Color3.fromRGB(235, 120, 30))
    local LRealStr = AK.Label(Content, "Strength: 0 | Gained: 0", 68, Enum.Font.SourceSansBold)
    local LRealDur = AK.Label(Content, "Durability: 0 | Gained: 0", 86, Enum.Font.SourceSansBold)

    task.spawn(function()
        while LRealStr and LRealStr.Parent do
            local dH = AK.DuraPorSegundo * 3600
            L1.Text = "Dura: " .. AK.Format(dH) .. "/Hour | " .. AK.Format(dH * 24) .. "/Day | " .. AK.Format(dH * 168) .. "/Week"
            L2.Text = "Average Fuerza: " .. AK.Format(AK.FuerzaPorSegundo * 3600) .. "/Hour"
            LRealStr.Text = "Strength: " .. AK.Format((AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or 0) .. " | Gained: " .. AK.Format(math.max(0, ((AK.Stats:FindFirstChild("Strength") and AK.Stats.Strength.Value) or 0) - AK.StartStr))
            LRealDur.Text = "Durability: " .. AK.Format((AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or 0) .. " | Gained: " .. AK.Format(math.max(0, ((AK.Stats:FindFirstChild("Durability") and AK.Stats.Durability.Value) or 0) - AK.StartDur))
            if AK.AutoFarm then
                local diff = os.time() - AK.FarmStartTime
                LTimer.Text = string.format("0d %dh %dm %ds - Fast Rep Active", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else LTimer.Text = "0d 0h 0m 0s - Fast Rep Inactive" end
            task.wait(0.5)
        end
    end)

    AK.Label(Content, "⚡ Fast Farm:", 110, Enum.Font.SourceSansBold)
    AK.Button(Content, "Controlled Speed", 148, AK.AutoFarm and AK.FarmSpeed == 0.3, function(st)
        AK.AutoFarm = st; AK.FarmSpeed = 0.3; if st then AK.FarmStartTime = os.time() end
        if st then task.spawn(function() while AK.AutoFarm and AK.FarmSpeed == 0.3 do safeFire("muscleEvent", "punchClick") task.wait(0.3) end end) end
    end)
    AK.Button(Content, "Fast Rep", 176, AK.AutoFarm and AK.FarmSpeed == 0.05, function(st)
        AK.AutoFarm = st; AK.FarmSpeed = 0.05; if st then AK.FarmStartTime = os.time() end
        if st then task.spawn(function() while AK.AutoFarm and AK.FarmSpeed == 0.05 do safeFire("muscleEvent", "punchClick") task.wait(0.05) end end) end
    end)
end
AK.Tab2.MouseButton1Click:Connect(ShowFarm)

-- PESTAÑA: REBIRTH
AK.Tab1.MouseButton1Click:Connect(function()
    AK.Clear()
    AK.Label(Content, "📊 Stats Rebirth:", 5, Enum.Font.SourceSansBold)
    local LTimer = AK.Label(Content, "0d 0h 0m 0s - Rebirthing", 23, Enum.Font.SourceSansBold, Color3.fromRGB(0, 230, 0))
    local LRb = AK.Label(Content, "Rebirths: 0 | Gained: 0", 45)
    task.spawn(function()
        if AK.StartRb == 0 and AK.Stats and AK.Stats:FindFirstChild("Rebirths") then AK.StartRb = AK.Stats.Rebirths.Value end
        while LRb and LRb.Parent do
            local curRb = (AK.Stats and AK.Stats:FindFirstChild("Rebirths") and AK.Stats.Rebirths.Value) or 0
            LRb.Text = "Rebirths: " .. AK.Format(curRb) .. " | Gained: " .. AK.Format(math.max(0, curRb - AK.StartRb))
            if AK.AutoRebirth then
                local diff = os.time() - AK.RebirthStartTime
                LTimer.Text = string.format("0d %dh %dm %ds - Rebirthing", math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
            else LTimer.Text = "0d 0h 0m 0s - Rebirth Inactive" end
            task.wait(0.5)
        end
    end)
    AK.Label(Content, "🔄 Rebirth:", 80, Enum.Font.SourceSansBold)
    AK.Button(Content, "Fast Rebirth", 102, AK.AutoRebirth, function(st)
        AK.AutoRebirth = st; if st then AK.RebirthStartTime = os.time(); if AK.Stats and AK.Stats:FindFirstChild("Rebirths") then AK.StartRb = AK.Stats.Rebirths.Value end end
        if st then task.spawn(function() while AK.AutoRebirth do safeFire("muscleEvent", "rebirthRequest") task.wait(1) end end) end
    end)
end)

-- PESTAÑA: MISC
AK.Tab3.MouseButton1Click:Connect(function()
    AK.Clear(); Scroll.Visible = true
    for _, c in ipairs(Scroll:GetChildren()) do pcall(function() c:Destroy() end) end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 200)
    AK.Button(Scroll, "Lock Position", 5, true, function(st) -- true = locked
        -- invertir: st = true -> no draggable
        -- para compatibilidad, dejamos el drag pero evitamos cambiar si locked
        if st then
            -- bloquear: mover Top.InputBegan desconectar? Simplificamos: ocultar el logo clicable
            Top.Active = false
        else
            Top.Active = true
        end
    end)
    AK.Button(Scroll, "Anti Lag", 33, AK.AntiLagActive, function(st)
        AK.AntiLagActive = st
        if st then
            pcall(function() if Lighting:FindFirstChild("Sky") then Lighting.Sky:Destroy() end end)
            pcall(function() Lighting.Ambient = Color3.fromRGB(0,0,0) end)
            -- Advertencia: cambiar material de muchos objetos puede ser costoso; aplicamos con pcall
            pcall(function()
                for _, o in pairs(workspace:GetDescendants()) do
                    if o:IsA("BasePart") then
                        o.Material = Enum.Material.SmoothPlastic
                    end
                end
            end)
        else
            -- No se puede restaurar todo fácilmente; avisar
            warn("AleKingHubVIP: AntiLag desactivado. Algunas propiedades no se restauraron automáticamente.")
        end
    end)
    AK.Button(Scroll, "Auto Egg (30 Min)", 61, AK.AutoEgg30Min, function(st)
        AK.AutoEgg30Min = st
        if st then task.spawn(function() while AK.AutoEgg30Min do safeFire("muscleEvent", "claimTimeGiftRequest") task.wait(10) end end) end
    end)
end)

-- Mostrar pestaña de Farm por defecto
ShowFarm()

-- Exponer AK en entorno global para futuras llamadas
getgenv().AleKingHub = AK

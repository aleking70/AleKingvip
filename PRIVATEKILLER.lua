local unpack_fn = unpack or table.unpack
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local LibraryData = { game:HttpGet("https://raw.githubusercontent.com/p4020854-hub/Lb/refs/heads/main/X", true) }
local Library = loadstring(unpack_fn(LibraryData))
local UI = Library()

local Window = UI:AddWindow("AleKing | PRIVATE KILLER", {
    main_color = Color3.fromRGB(0, 0, 0),
    min_size = Vector2.new(680, 870),
    can_resize = true
})

local KillTab = Window:AddTab("Kill")
local TeleportTab = Window:AddTab("Teleport")

-- ============ KILL TAB ============

local KillLabel = KillTab:AddLabel("PvP Kill Functions:")
KillLabel.TextSize = 22

-- Select Pet
local selectedPet = nil
local function onSelectPet(value)
    selectedPet = value
end

local PetDropdown = KillTab:AddDropdown("Select Pet (Damage/Durability)", onSelectPet)
PetDropdown:Add("Swift Samurai")
PetDropdown:Add("Tribal Overlord")
PetDropdown:Add("Wild Wizard")
PetDropdown:Add("None")

-- Auto Whitelist Friends
local autoWhitelistEnabled = false
local function onAutoWhitelist(enabled)
    autoWhitelistEnabled = enabled
end

KillTab:AddSwitch("Auto Whitelist Friends", onAutoWhitelist)

-- Block Touch Egg
local blockEggEnabled = false
local function onBlockEgg(enabled)
    blockEggEnabled = enabled
end

KillTab:AddSwitch("Block touch Egg", onBlockEgg)

-- Auto Kill
local autoKillEnabled = false
local function onAutoKill(enabled)
    autoKillEnabled = enabled
end

KillTab:AddSwitch("Auto Kill", onAutoKill)

-- Select Target
local selectedTarget = nil
local function onSelectTarget(name)
    selectedTarget = name
end

local TargetDropdown = KillTab:AddDropdown("Select Target", onSelectTarget)
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= LocalPlayer then
        TargetDropdown:Add(player.Name)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        TargetDropdown:Add(player.Name)
    end
end)

-- Start Kill Target
local function onStartKillTarget()
    if not selectedTarget then
        StarterGui:SetCore("SendNotification", { Title = "Error", Text = "Select a target first!", Duration = 3 })
        return
    end
    local targetPlayer = game.Players:FindFirstChild(selectedTarget)
    if targetPlayer and targetPlayer.Character then
        StarterGui:SetCore("SendNotification", { Title = "Kill", Text = "Targeting " .. selectedTarget, Duration = 3 })
    end
end

KillTab:AddButton("Start Kill Target", onStartKillTarget)

-- Remove Selected Target
local function onRemoveTarget()
    selectedTarget = nil
    StarterGui:SetCore("SendNotification", { Title = "Target", Text = "Target removed", Duration = 3 })
end

KillTab:AddButton("Remove Selected Target", onRemoveTarget)

-- Select View Target
local selectedViewTarget = nil
local function onSelectViewTarget(name)
    selectedViewTarget = name
end

local ViewTargetDropdown = KillTab:AddDropdown("Select View Target", onSelectViewTarget)
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ViewTargetDropdown:Add(player.Name)
    end
end

-- View Player
local function onViewPlayer()
    if not selectedViewTarget then
        StarterGui:SetCore("SendNotification", { Title = "Error", Text = "Select a player to view!", Duration = 3 })
        return
    end
    StarterGui:SetCore("SendNotification", { Title = "Viewing", Text = "Viewing " .. selectedViewTarget, Duration = 3 })
end

KillTab:AddButton("View Player", onViewPlayer)

-- Size Options
local function onSize30()
    pcall(function()
        ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 30)
        StarterGui:SetCore("SendNotification", { Title = "Size", Text = "Size changed to 30", Duration = 2 })
    end)
end

local function onSize2()
    pcall(function()
        ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 2)
        StarterGui:SetCore("SendNotification", { Title = "Size", Text = "Size changed to 2", Duration = 2 })
    end)
end

KillTab:AddButton("Size 30", onSize30)
KillTab:AddButton("Size 2", onSize2)

-- Teleport Player
local function onTeleportPlayer()
    if not selectedViewTarget then
        StarterGui:SetCore("SendNotification", { Title = "Error", Text = "Select a player to teleport!", Duration = 3 })
        return
    end
    local targetPlayer = game.Players:FindFirstChild(selectedViewTarget)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
            StarterGui:SetCore("SendNotification", { Title = "Teleport", Text = "Teleported to " .. selectedViewTarget, Duration = 3 })
        end
    end
end

KillTab:AddButton("Teleport to Player", onTeleportPlayer)

-- Auto Slams
local autoSlamsEnabled = false
local function onAutoSlams(enabled)
    autoSlamsEnabled = enabled
    if enabled then
        task.spawn(function()
            while autoSlamsEnabled do
                pcall(function()
                    local tool = LocalPlayer.Backpack:FindFirstChild("Ground Slam")
                    if tool then
                        tool.Parent = LocalPlayer.Character
                        local attackTime = tool:FindFirstChild("attackTime")
                        if attackTime then attackTime.Value = 0 end
                        local slam = LocalPlayer.Character:FindFirstChild("Ground Slam")
                        if slam then slam:Activate() end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end

KillTab:AddSwitch("Auto Slams", onAutoSlams)

-- Activate Dead Hit
local deadHitEnabled = false
local function onDeadHit(enabled)
    deadHitEnabled = enabled
end

KillTab:AddSwitch("Activate Dead Hit", onDeadHit)

-- Change Time
local function onChangeTime(value)
    if value == "Night" then
        Lighting.ClockTime = 0
    elseif value == "Day" then
        Lighting.ClockTime = 12
    elseif value == "Midnight" then
        Lighting.ClockTime = 6
    end
end

local TimeDropdown = KillTab:AddDropdown("Change Time", onChangeTime)
TimeDropdown:Add("Night")
TimeDropdown:Add("Day")
TimeDropdown:Add("Midnight")

-- Blacklist Section
local BlacklistLabel = KillTab:AddLabel("Blacklist:")
BlacklistLabel.TextSize = 18

local function onAddBlacklist()
    if not selectedTarget then
        StarterGui:SetCore("SendNotification", { Title = "Error", Text = "Select a target first!", Duration = 3 })
        return
    end
    StarterGui:SetCore("SendNotification", { Title = "Blacklist", Text = selectedTarget .. " added to blacklist", Duration = 3 })
end

local function onRemoveBlacklist()
    StarterGui:SetCore("SendNotification", { Title = "Blacklist", Text = "Removed from blacklist", Duration = 3 })
end

KillTab:AddButton("Add to Blacklist", onAddBlacklist)
KillTab:AddButton("Remove from Blacklist", onRemoveBlacklist)

-- ============ TELEPORT TAB ============

local teleportPoints = {
    { name = "Spawn",          pos = Vector3.new(2, 8, 115) },
    { name = "Secret Area",    pos = Vector3.new(1947, 2, 6191) },
    { name = "Tiny Island",    pos = Vector3.new(-34, 7, 1903) },
    { name = "Frozen Island",  pos = CFrame.new(-2600.00244, 3.67686558, -403.884369, 0.0873617008, 1.0482899e-09, 0.99617666, 3.07204253e-08, 1, -3.7464023e-09, -0.99617666, 3.09302628e-08, 0.0873617262, 0, 0, 1) },
    { name = "Mythical Island", pos = Vector3.new(2255, 7, 1071) },
    { name = "Hell Island",    pos = Vector3.new(-6768, 7, -1287) },
    { name = "Legend Island",  pos = Vector3.new(4604, 991, -3887) },
    { name = "Muscle King",    pos = Vector3.new(-8646, 17, -5738) },
    { name = "Jungle Island",  pos = Vector3.new(-8659, 6, 2384) },
    { name = "Brawl Lava",     pos = Vector3.new(4471, 119, -8836) },
    { name = "Brawl Desert",   pos = Vector3.new(960, 17, -7398) },
    { name = "Brawl Regular",  pos = Vector3.new(-1849, 20, -6335) },
}

local function sendTeleportNotif(text)
    StarterGui:SetCore("SendNotification", { Title = "Teleport", Text = text, Duration = 3 })
end

for _, tp in ipairs(teleportPoints) do
    local tpName = tp.name
    local tpPos = tp.pos
    TeleportTab:AddButton("Teleport to " .. tpName, function()
        local char = LocalPlayer.Character
        if not char then
            LocalPlayer.CharacterAdded:Wait()
            char = LocalPlayer.Character
        end
        local hrp = char:WaitForChild("HumanoidRootPart")
        if typeof(tpPos) == "CFrame" then
            hrp.CFrame = tpPos
        else
            hrp.CFrame = CFrame.new(tpPos)
        end
        sendTeleportNotif("Teleported to " .. tpName)
    end)
end
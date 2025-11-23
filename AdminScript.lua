-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/SynceXxx/SynceHub/refs/heads/main/main.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
_G.AdminPanel = _G.AdminPanel or {}
local AP = _G.AdminPanel

AP.Flying = false
AP.Noclipping = false
AP.InfiniteJumpEnabled = false
AP.FlySpeed = 50
AP.ESPEnabled = false
AP.ESPObjects = {}
AP.ChatSpyEnabled = false
AP.InvisibleEnabled = false
AP.AntiAFKEnabled = false
AP.CustomNametagEnabled = false
AP.NametagColor = Color3.fromRGB(255, 0, 0)
AP.FlingEnabled = false
AP.WalkFlingEnabled = false
AP.AntiKickEnabled = false
AP.SelectedPlayer = nil
AP.CustomNametagGui = nil

-- Helper Functions
function AP.notify(title, message)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = 3,
        Icon = "check-circle"
    })
end

function AP.getPlayer(name)
    if name:lower() == "me" then return LocalPlayer end
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name then
            return player
        end
    end
    return nil
end

-- Create Window
AP.Window = WindUI:CreateWindow({
    Title = "💎 Admin Panel Pro",
    Author = "SynceHub",
    Subtitle = "v2.0 WindUI Edition",
    Icon = "crown",
    IconThemed = true,
    Size = UDim2.fromOffset(580, 480),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Transparent = false,
    Theme = "Dark",
    CanDraggable = true,
    CanMinimize = true,
    CanResize = false,
    UseAcrylic = true,
    Visible = true,
})

-- TAB 1: PLAYER SELECTION
AP.PlayerTab = AP.Window:Tab({
    Title = "Players",
    Icon = "users",
})

local PlayerSection = AP.PlayerTab:Section({
    Title = "👥 Player Selection",
})

local PlayerListFrame = PlayerSection:Container({
    Title = "Online Players",
})

function AP.updatePlayerList()
    PlayerListFrame:Clear()
    for _, player in pairs(Players:GetPlayers()) do
        PlayerListFrame:Button({
            Title = player.Name .. (player == LocalPlayer and " (You)" or ""),
            Icon = "user",
            Variant = AP.SelectedPlayer == player and "Primary" or "Secondary",
            Callback = function()
                AP.SelectedPlayer = player
                AP.notify("✅ Selected", player.Name)
                AP.updatePlayerList()
            end
        })
    end
end

AP.updatePlayerList()
Players.PlayerAdded:Connect(AP.updatePlayerList)
Players.PlayerRemoving:Connect(AP.updatePlayerList)

-- TAB 2: MOVEMENT
AP.MovementTab = AP.Window:Tab({
    Title = "Movement",
    Icon = "move",
})

local FlightSection = AP.MovementTab:Section({
    Title = "✈️ Flight Controls",
})

FlightSection:Toggle({
    Title = "Fly",
    Description = "Press WASD to fly, Space/Shift for up/down",
    Default = false,
    Callback = function(value)
        AP.Flying = value
        local Character = LocalPlayer.Character
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if AP.Flying and RootPart then
            AP.notify("✈️ Flight", "Enabled")
            
            local BV = Instance.new("BodyVelocity")
            BV.Name = "FlyVelocity"
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Parent = RootPart
            
            local BG = Instance.new("BodyGyro")
            BG.Name = "FlyGyro"
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = RootPart.CFrame
            BG.Parent = RootPart
            
            RunService.RenderStepped:Connect(function()
                if AP.Flying and RootPart and BV and BG then
                    local Cam = Camera.CFrame
                    local Direction = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then Direction = Direction + Cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then Direction = Direction - Cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then Direction = Direction - Cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then Direction = Direction + Cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Direction = Direction + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then Direction = Direction - Vector3.new(0, 1, 0) end
                    
                    BV.Velocity = Direction * AP.FlySpeed
                    BG.CFrame = Cam
                else
                    if BV then BV:Destroy() end
                    if BG then BG:Destroy() end
                end
            end)
        else
            AP.notify("✈️ Flight", "Disabled")
            if RootPart then
                for _, obj in pairs(RootPart:GetChildren()) do
                    if obj.Name == "FlyVelocity" or obj.Name == "FlyGyro" then
                        obj:Destroy()
                    end
                end
            end
        end
    end
})

FlightSection:Slider({
    Title = "Fly Speed",
    Description = "Adjust flight speed",
    Min = 10,
    Max = 500,
    Default = 50,
    Callback = function(value)
        AP.FlySpeed = value
    end
})

local PhysicsSection = AP.MovementTab:Section({
    Title = "🌀 Physics",
})

PhysicsSection:Toggle({
    Title = "Noclip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(value)
        AP.Noclipping = value
        if AP.Noclipping then
            AP.notify("👻 Noclip", "Enabled")
            RunService.Stepped:Connect(function()
                if AP.Noclipping and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            AP.notify("👻 Noclip", "Disabled")
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

PhysicsSection:Toggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely high",
    Default = false,
    Callback = function(value)
        AP.InfiniteJumpEnabled = value
        AP.notify("⬆️ Infinite Jump", value and "Enabled" or "Disabled")
    end
})

UserInputService.JumpRequest:Connect(function()
    if AP.InfiniteJumpEnabled and LocalPlayer.Character then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
local AP = _G.AdminPanel
local LocalPlayer = game:GetService("Players").LocalPlayer

-- TAB 3: PLAYER ACTIONS
AP.ActionsTab = AP.Window:Tab({
    Title = "Actions",
    Icon = "zap",
})

local TeleportSection = AP.ActionsTab:Section({
    Title = "📍 Teleportation",
})

TeleportSection:Button({
    Title = "Teleport to Selected",
    Description = "TP yourself to selected player",
    Icon = "arrow-right",
    Callback = function()
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        local Character = LocalPlayer.Character
        local TargetChar = AP.SelectedPlayer.Character
        if Character and TargetChar and TargetChar:FindFirstChild("HumanoidRootPart") then
            Character:MoveTo(TargetChar.HumanoidRootPart.Position)
            AP.notify("✅ Teleported", "To " .. AP.SelectedPlayer.Name)
        end
    end
})

TeleportSection:Button({
    Title = "Bring Selected to You",
    Description = "TP selected player to you",
    Icon = "arrow-left",
    Callback = function()
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        local Character = LocalPlayer.Character
        local TargetChar = AP.SelectedPlayer.Character
        if Character and TargetChar and Character:FindFirstChild("HumanoidRootPart") then
            TargetChar:MoveTo(Character.HumanoidRootPart.Position)
            AP.notify("✅ Brought", AP.SelectedPlayer.Name .. " to you")
        end
    end
})

local CharacterSection = AP.ActionsTab:Section({
    Title = "🎭 Character Mods",
})

CharacterSection:Textbox({
    Title = "Walk Speed",
    Description = "Set player walk speed",
    Placeholder = "16",
    Callback = function(value)
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        local speed = tonumber(value)
        if speed and AP.SelectedPlayer.Character then
            local Humanoid = AP.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = speed
                AP.notify("🏃 Speed", AP.SelectedPlayer.Name .. " = " .. speed)
            end
        end
    end
})

CharacterSection:Textbox({
    Title = "Jump Power",
    Description = "Set player jump power",
    Placeholder = "50",
    Callback = function(value)
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        local power = tonumber(value)
        if power and AP.SelectedPlayer.Character then
            local Humanoid = AP.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.JumpPower = power
                AP.notify("⬆️ Jump", AP.SelectedPlayer.Name .. " = " .. power)
            end
        end
    end
})

CharacterSection:Button({
    Title = "God Mode",
    Description = "Make player invincible",
    Icon = "shield",
    Callback = function()
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        if AP.SelectedPlayer.Character then
            local Humanoid = AP.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.MaxHealth = math.huge
                Humanoid.Health = math.huge
                AP.notify("⭐ God Mode", AP.SelectedPlayer.Name)
            end
        end
    end
})

CharacterSection:Button({
    Title = "Kill Player",
    Description = "Instantly kill player",
    Icon = "skull",
    Callback = function()
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        if AP.SelectedPlayer.Character then
            local Humanoid = AP.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.Health = 0
                AP.notify("💀 Killed", AP.SelectedPlayer.Name)
            end
        end
    end
})

-- TAB 4: VISUAL
AP.VisualTab = AP.Window:Tab({
    Title = "Visual",
    Icon = "eye",
})

local ESPSection = AP.VisualTab:Section({
    Title = "👁️ ESP (Wallhack)",
})

function AP.createESP(player)
    if player == LocalPlayer then return end
    
    local function addESP(character)
        if AP.ESPObjects[player] then
            for _, obj in pairs(AP.ESPObjects[player]) do
                pcall(function() obj:Destroy() end)
            end
        end
        
        AP.ESPObjects[player] = {}
        
        local HRP = character:WaitForChild("HumanoidRootPart", 5)
        if not HRP then return end
        
        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.Adornee = HRP
        BillboardGui.Size = UDim2.new(0, 100, 0, 50)
        BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Parent = HRP
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextSize = 14
        TextLabel.Text = player.Name
        TextLabel.Parent = BillboardGui
        
        table.insert(AP.ESPObjects[player], BillboardGui)
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local BoxHandleAdornment = Instance.new("BoxHandleAdornment")
                BoxHandleAdornment.Adornee = part
                BoxHandleAdornment.Size = part.Size
                BoxHandleAdornment.Color3 = Color3.fromRGB(255, 0, 0)
                BoxHandleAdornment.Transparency = 0.7
                BoxHandleAdornment.AlwaysOnTop = true
                BoxHandleAdornment.ZIndex = 5
                BoxHandleAdornment.Parent = part
                
                table.insert(AP.ESPObjects[player], BoxHandleAdornment)
            end
        end
    end
    
    if player.Character then
        addESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        if AP.ESPEnabled then
            task.wait(0.5)
            addESP(character)
        end
    end)
end

ESPSection:Toggle({
    Title = "Enable ESP",
    Description = "See all players through walls",
    Default = false,
    Callback = function(value)
        AP.ESPEnabled = value
        
        if AP.ESPEnabled then
            AP.notify("👁️ ESP", "Enabled")
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                AP.createESP(player)
            end
            
            game:GetService("Players").PlayerAdded:Connect(function(player)
                if AP.ESPEnabled then
                    AP.createESP(player)
                end
            end)
        else
            AP.notify("👁️ ESP", "Disabled")
            for _, espList in pairs(AP.ESPObjects) do
                for _, obj in pairs(espList) do
                    pcall(function() obj:Destroy() end)
                end
            end
            AP.ESPObjects = {}
        end
    end
})

local AppearanceSection = AP.VisualTab:Section({
    Title = "🎨 Appearance",
})

AppearanceSection:Toggle({
    Title = "Invisible",
    Description = "Make yourself invisible",
    Default = false,
    Callback = function(value)
        AP.InvisibleEnabled = value
        local Character = LocalPlayer.Character
        
        if AP.InvisibleEnabled and Character then
            AP.notify("👻 Invisible", "Enabled")
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    part.Handle.Transparency = 1
                end
            end
            if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("face") then
                Character.Head.face.Transparency = 1
            end
        elseif Character then
            AP.notify("👻 Invisible", "Disabled")
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    part.Handle.Transparency = 0
                end
            end
            if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("face") then
                Character.Head.face.Transparency = 0
            end
        end
    end
})

AppearanceSection:Toggle({
    Title = "Rainbow Nametag",
    Description = "Rainbow colored custom name above head",
    Default = false,
    Callback = function(value)
        AP.CustomNametagEnabled = value
        
        if value then
            local Character = LocalPlayer.Character
            if not Character then return end
            
            local Head = Character:FindFirstChild("Head")
            if not Head then return end
            
            if AP.CustomNametagGui then
                AP.CustomNametagGui:Destroy()
            end
            
            AP.CustomNametagGui = Instance.new("BillboardGui")
            AP.CustomNametagGui.Name = "CustomNametag"
            AP.CustomNametagGui.Parent = Head
            AP.CustomNametagGui.Size = UDim2.new(0, 200, 0, 50)
            AP.CustomNametagGui.StudsOffset = Vector3.new(0, 2, 0)
            AP.CustomNametagGui.AlwaysOnTop = true
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = AP.CustomNametagGui
            TextLabel.BackgroundTransparency = 1
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = LocalPlayer.Name
            TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            TextLabel.TextScaled = true
            TextLabel.TextStrokeTransparency = 0
            
            spawn(function()
                while AP.CustomNametagEnabled and TextLabel do
                    for i = 0, 1, 0.01 do
                        if not AP.CustomNametagEnabled then break end
                        TextLabel.TextColor3 = Color3.fromHSV(i, 1, 1)
                        wait(0.05)
                    end
                end
            end)
            
            AP.notify("🌈 Rainbow Tag", "Enabled")
        else
            if AP.CustomNametagGui then
                AP.CustomNametagGui:Destroy()
            end
            AP.notify("🌈 Rainbow Tag", "Disabled")
        end
    end
})
local AP = _G.AdminPanel
local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")

-- TAB 5: TROLLING
AP.TrollTab = AP.Window:Tab({
    Title = "Trolling",
    Icon = "laugh",
})

local FlingSection = AP.TrollTab:Section({
    Title = "🌪️ Fling Tools",
})

FlingSection:Button({
    Title = "Fling Selected Player",
    Description = "Launch player into space",
    Icon = "rocket",
    Callback = function()
        if not AP.SelectedPlayer then return AP.notify("⚠️ Error", "No player selected!") end
        
        local Character = LocalPlayer.Character
        local Target = AP.SelectedPlayer.Character
        
        if not Character or not Target then return end
        
        local HRP = Character:FindFirstChild("HumanoidRootPart")
        local TargetHRP = Target:FindFirstChild("HumanoidRootPart")
        
        if not HRP or not TargetHRP then return end
        
        AP.notify("🌪️ Flinging", AP.SelectedPlayer.Name .. "...")
        
        local Bambam = Instance.new("BodyAngularVelocity")
        Bambam.Name = "Fling"
        Bambam.Parent = HRP
        Bambam.AngularVelocity = Vector3.new(0, 99999, 0)
        Bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        Bambam.P = math.huge
        
        local originalPos = HRP.CFrame
        
        task.spawn(function()
            for i = 1, 200 do
                if HRP and TargetHRP then
                    HRP.CFrame = TargetHRP.CFrame
                end
                task.wait()
            end
            
            if Bambam then Bambam:Destroy() end
            if HRP then HRP.CFrame = originalPos end
            
            AP.notify("✅ Fling", "Complete!")
        end)
    end
})

FlingSection:Toggle({
    Title = "Walk Fling",
    Description = "Fling anyone you touch while walking",
    Default = false,
    Callback = function(value)
        AP.WalkFlingEnabled = value
        
        if AP.WalkFlingEnabled then
            AP.notify("🌪️ Walk Fling", "Enabled - Touch people to fling!")
            
            local Character = LocalPlayer.Character
            if not Character then return end
            
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
            local Bambam = Instance.new("BodyAngularVelocity")
            Bambam.Name = "WalkFling"
            Bambam.Parent = HRP
            Bambam.AngularVelocity = Vector3.new(0, 99999, 0)
            Bambam.MaxTorque = Vector3.new(0, math.huge, 0)
            Bambam.P = math.huge
        else
            AP.notify("🌪️ Walk Fling", "Disabled")
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                    if obj.Name == "WalkFling" then
                        obj:Destroy()
                    end
                end
            end
        end
    end
})

local SpySection = AP.TrollTab:Section({
    Title = "🕵️ Spy Tools",
})

SpySection:Toggle({
    Title = "Chat Spy",
    Description = "See all player messages",
    Default = false,
    Callback = function(value)
        AP.ChatSpyEnabled = value
        
        if AP.ChatSpyEnabled then
            AP.notify("🕵️ Chat Spy", "Monitoring all messages")
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    player.Chatted:Connect(function(message)
                        if AP.ChatSpyEnabled then
                            print("[CHAT SPY] " .. player.Name .. ": " .. message)
                            AP.notify("[SPY] " .. player.Name, message)
                        end
                    end)
                end
            end
            
            Players.PlayerAdded:Connect(function(player)
                player.Chatted:Connect(function(message)
                    if AP.ChatSpyEnabled then
                        print("[CHAT SPY] " .. player.Name .. ": " .. message)
                        AP.notify("[SPY] " .. player.Name, message)
                    end
                end)
            end)
        else
            AP.notify("🕵️ Chat Spy", "Disabled")
        end
    end
})

-- TAB 6: UTILITIES
AP.UtilityTab = AP.Window:Tab({
    Title = "Utility",
    Icon = "tool",
})

local ProtectionSection = AP.UtilityTab:Section({
    Title = "🛡️ Protection",
})

ProtectionSection:Toggle({
    Title = "Anti-AFK",
    Description = "Prevent auto-kick for being idle",
    Default = false,
    Callback = function(value)
        AP.AntiAFKEnabled = value
        
        if AP.AntiAFKEnabled then
            AP.notify("🛡️ Anti-AFK", "Protected from AFK kick")
            local VirtualUser = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                if AP.AntiAFKEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        else
            AP.notify("🛡️ Anti-AFK", "Disabled")
        end
    end
})

ProtectionSection:Toggle({
    Title = "Anti-Kick",
    Description = "Prevent server kicks (experimental)",
    Default = false,
    Callback = function(value)
        AP.AntiKickEnabled = value
        
        if AP.AntiKickEnabled then
            AP.notify("🛡️ Anti-Kick", "Protection enabled")
            
            local OldNamecall
            OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
                local Method = getnamecallmethod()
                if Method == "Kick" then
                    AP.notify("🛡️ Blocked", "Kick attempt prevented!")
                    return
                end
                return OldNamecall(Self, ...)
            end))
        else
            AP.notify("🛡️ Anti-Kick", "Disabled")
        end
    end
})

-- TAB 7: SETTINGS
AP.SettingsTab = AP.Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local ThemeSection = AP.SettingsTab:Section({
    Title = "🎨 Themes",
})

local themes = {
    {"Dark", "moon"},
    {"Light", "sun"},
    {"Rose", "heart"},
    {"Plant", "leaf"},
    {"Red", "flame"},
    {"Indigo", "droplet"},
    {"Sky", "cloud"},
    {"Violet", "sparkles"},
    {"Amber", "zap"},
    {"Emerald", "clover"},
    {"Midnight", "moon-star"},
    {"Crimson", "heart-pulse"},
    {"MonokaiPro", "code"},
    {"CottonCandy", "candy"},
    {"Rainbow", "rainbow"}
}

for _, themeData in ipairs(themes) do
    local themeName, icon = themeData[1], themeData[2]
    ThemeSection:Button({
        Title = themeName,
        Icon = icon or "palette",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SynceXxx/SynceHub/refs/heads/main/main.lua"))():SetTheme(themeName)
            AP.notify("🎨 Theme", "Changed to " .. themeName)
        end
    })
end

local InfoSection = AP.SettingsTab:Section({
    Title = "ℹ️ Information",
})

InfoSection:Label({
    Title = "🎉 Admin Panel Pro v2.0",
    Description = [[
Powered by WindUI Library
Created by SynceHub

✨ FEATURES:
• Advanced Movement (Fly, Noclip, Jump)
• Player Control (TP, Speed, God Mode)
• ESP & Visual Effects
• Trolling Tools (Fling, Chat Spy)
• Protection (Anti-AFK, Anti-Kick)
• 15+ Premium Themes

📌 HOW TO USE:
1. Select player from Players tab
2. Use action buttons in other tabs
3. Try different themes!
4. Enjoy the blur effects!

🎨 TRY RAINBOW THEME!
It's the coolest one with gradients!
]]
})

-- INITIALIZATION COMPLETE
AP.notify("✅ Loaded", "Admin Panel Pro v2.0 ready!")
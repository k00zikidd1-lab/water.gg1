local players = game:GetService('Players')
local camera = workspace.CurrentCamera
local lp = players.LocalPlayer
local run = game:GetService("RunService")
local coregui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

local repo = "https://raw.githubusercontent.com/k00zikidd1-lab/Obsidian/refs/heads/main/Library.lua"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local functions = {
    wall = false,
    team = false,
    smooth = false,
    fov = false,
    fovsize = 100,
    smoothsize = 0.1,
    aimbot = false,
    flying = false,
    flyspeed = 50
}

local ESP = loadstring(game:HttpGet("https://pastebin.com/raw/2dU36TmL"))()
ESP.Enabled = false
ESP.ShowBox = false
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowTracer = false
ESP.ShowDistance = false
ESP.ShowSkeletons = false
ESP.BoxColor = Color3.new(1, 1, 1)
ESP.TracerColor = Color3.new(1, 1, 1)
ESP.SkeletonsColor = Color3.new(1, 1, 1)
ESP.TeamCheck = false

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Thickness = 1
fovCircle.NumSides = 50
fovCircle.Filled = false
fovCircle.Visible = false

run.RenderStepped:Connect(function()
    fovCircle.Visible = functions.fov
    fovCircle.Radius = functions.fovsize
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end)

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function fly()
    local char = lp.Character
    if not char then return end
    local root = getRoot(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    hum.PlatformStand = true

    while functions.flying and char.Parent and root.Parent do
        local camCF = camera.CFrame
        bg.CFrame = camCF
        local moveDir = hum.MoveDirection
        
        if moveDir.Magnitude > 0 then
            local direction = (camCF.LookVector * -moveDir.Z) + (camCF.RightVector * moveDir.X)
            bv.Velocity = direction.Unit * functions.flyspeed
        else
            bv.Velocity = Vector3.new(0, 0.1, 0)
        end
        run.RenderStepped:Wait()
    end

    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    if hum then hum.PlatformStand = false end
end

local function aimbot()
    while functions.aimbot do 
        local character = lp.Character
        if character and character:FindFirstChild('Head') then
            local targetPart = nil
            local shortestDistance = math.huge
            local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            
            for _, p in pairs(players:GetPlayers()) do
                if functions.team and p.Team == lp.Team then continue end
                if p ~= lp and p.Character and p.Character:FindFirstChild('Head') then
                    local pos, onscreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onscreen then
                        local mousedistance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        if mousedistance <= functions.fovsize then
                            local cansee = true
                            if functions.wall then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {character, camera}
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local rayResult = workspace:Raycast(camera.CFrame.Position, (p.Character.Head.Position - camera.CFrame.Position), rayParams)
                                if rayResult and not rayResult.Instance:IsDescendantOf(p.Character) then cansee = false end
                            end
                            if cansee and mousedistance < shortestDistance then
                                shortestDistance = mousedistance
                                targetPart = p.Character.Head
                            end
                        end
                    end
                end
            end
            if targetPart then
                local goal = CFrame.new(camera.CFrame.Position, targetPart.Position)
                camera.CFrame = functions.smooth and camera.CFrame:Lerp(goal, functions.smoothsize) or goal
            end
        end
        task.wait()
    end
end

local window = Library:CreateWindow({
    Title = "",
    Icon = 128319020082767,
    Footer = "Water.GG ©, 2025.",
    Center = true,
    AutoShow = true
})

local tabs = {
    main = window:AddTab("", "sword"),
    vis = window:AddTab("", "eye"),
    player = window:AddTab("", "user"),
    gun = window:AddTab("", "crosshair"),
    set = window:AddTab('Settings')
}

-- AIMBOT SECTION
local aim = tabs.main:AddLeftGroupbox("Aimbot")
aim:AddToggle("aimbot", { Text = "Aimbot", Default = false, Callback = function(v) functions.aimbot = v if v then task.spawn(aimbot) end end })
aim:AddToggle("wallcheck", { Text = "Wall Check", Default = false, Callback = function(v) functions.wall = v end })
aim:AddToggle("teamcheck", { Text = "Team Check", Default = false, Callback = function(v) functions.team = v end })
aim:AddToggle("smooth", { Text = "Smooth Movement", Default = false, Callback = function(v) functions.smooth = v end })
aim:AddToggle("fov", { Text = "Show FOV Circle", Default = false, Callback = function(v) functions.fov = v end })
aim:AddSlider("smoothsize", { Text = "Smoothness", Default = 0.1, Min = 0.01, Max = 1, Rounding = 2, Callback = function(v) functions.smoothsize = v end })
aim:AddSlider("fovsize", { Text = "FOV Radius", Default = 100, Min = 0, Max = 500, Rounding = 0, Callback = function(v) functions.fovsize = v end })

-- ESP SECTION
local esp = tabs.vis:AddLeftGroupbox("ESP")
esp:AddToggle("esp_enabled", { Text = "Enable ESP", Default = false, Callback = function(v) ESP.Enabled = v end })
esp:AddToggle("esp_box", { Text = "Show Box", Default = false, Callback = function(v) ESP.ShowBox = v end })
esp:AddToggle("esp_health", { Text = "Show Health", Default = false, Callback = function(v) ESP.ShowHealth = v end })
esp:AddToggle("esp_tracer", { Text = "Show Tracer", Default = false, Callback = function(v) ESP.ShowTracer = v end })
esp:AddToggle("esp_name", { Text = "Show Name", Default = false, Callback = function(v) ESP.ShowName = v end })
esp:AddToggle("esp_dist", { Text = "Show Distance", Default = false, Callback = function(v) ESP.ShowDistance = v end })
esp:AddToggle("skeletons", { Text = "Show Skeletons", Default = false, Callback = function(v) ESP.ShowSkeletons = v end })

esp:AddDivider()

-- ARM CHAMS LOGIC
local arm_chams_enabled = false
local arm_color = Color3.fromRGB(0, 255, 255)
local arm_material = Enum.Material.ForceField

esp:AddToggle("armchams", {
    Text = "Arm Chams",
    Default = false,
    Callback = function(v)
        arm_chams_enabled = v
        if v then
            task.spawn(function()
                while arm_chams_enabled do
                    local arms = camera:FindFirstChild("Arms")
                    if arms then
                        for _, part in pairs(arms:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = arm_color
                                part.Material = arm_material
                            elseif part:IsA("SpecialMesh") then
                                part.TextureId = ""
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- GUNS MOD SECTION
local originalValues = { FireRate = {}, ReloadTime = {}, EReloadTime = {}, Auto = {}, Spread = {}, Recoil = {} }
local mod = tabs.gun:AddLeftGroupbox("Guns Mod")

mod:AddToggle("infammo", { Text = "Infinite Ammo", Default = false, Callback = function(v) game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = v and "Infinite Ammo" or "" end })

mod:AddToggle("fastreload", { 
    Text = "Fast Reload", 
    Default = false, 
    Callback = function(x) 
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then
                if x then
                    originalValues.ReloadTime[v] = originalValues.ReloadTime[v] or v.ReloadTime.Value
                    v.ReloadTime.Value = 0.01
                else
                    v.ReloadTime.Value = originalValues.ReloadTime[v] or 0.8
                end
            end
        end
    end 
})

mod:AddToggle("firerate", {
    Text = "Fast Fire Rate", 
    Default = false, 
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "FireRate" or v.Name == "BFireRate" then
                if state then
                    originalValues.FireRate[v] = originalValues.FireRate[v] or v.Value
                    v.Value = 0.02
                else
                    v.Value = originalValues.FireRate[v] or 0.8
                end
            end
        end
    end
})

mod:AddToggle("nospread", { 
    Text = "No Spread", 
    Default = false, 
    Callback = function(state)
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "MaxSpread" or v.Name == "Spread" then
                if state then
                    originalValues.Spread[v] = originalValues.Spread[v] or v.Value
                    v.Value = 0
                else
                    v.Value = originalValues.Spread[v] or 1
                end
            end
        end
    end 
})

mod:AddToggle("norecoil", { 
    Text = "No Recoil", 
    Default = false, 
    Callback = function(state) 
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "RecoilControl" or v.Name == "Recoil" then
                if state then
                    originalValues.Recoil[v] = originalValues.Recoil[v] or v.Value
                    v.Value = 0
                else
                    v.Value = originalValues.Recoil[v] or 1
                end
            end
        end
    end 
})

-- PLAYER SECTION
local moveSection = tabs.player:AddLeftGroupbox("Movement")
moveSection:AddToggle("fly", { Text = "Enable Fly [!]", Default = false, Callback = function(v) functions.flying = v if v then task.spawn(fly) end end })
moveSection:AddSlider("flySpeed", { Text = "Fly Speed", Default = 50, Min = 10, Max = 250, Rounding = 0, Callback = function(v) functions.flyspeed = v end })

-- SETTINGS
-- SETTINGS
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('WaterGG')
SaveManager:SetFolder('WaterGG/configs')

-- Criando a seção de customização de cores da GUI
local SettingsBox = tabs.set:AddLeftGroupbox("Menu Theme")

-- Removi o ":UpdateColors()" para evitar o erro. 
-- A maioria das versões modernas atualiza assim que o valor da tabela é alterado.
SettingsBox:AddLabel('Main Color'):AddColorPicker('MenuColor', { 
    Default = Library.MainColor, 
    Title = 'Menu Primary Color', 
    Callback = function(Value) 
        Library.MainColor = Value 
    end 
})

SettingsBox:AddLabel('Background Color'):AddColorPicker('BackgroundColor', { 
    Default = Library.BackgroundColor, 
    Title = 'Background Color', 
    Callback = function(Value) 
        Library.BackgroundColor = Value 
    end 
})

SettingsBox:AddLabel('Accent Color'):AddColorPicker('AccentColor', { 
    Default = Library.AccentColor, 
    Title = 'Accent Color', 
    Callback = function(Value) 
        Library.AccentColor = Value 
    end 
})

ThemeManager:ApplyToTab(tabs.set)
SaveManager:BuildConfigSection(tabs.set)

Library:Notify("Water.GG Loaded!")

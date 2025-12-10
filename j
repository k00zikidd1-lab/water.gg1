local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local window = Library:CreateWindow({
    Title = "Water.GG",
    Footer = "https://discord.gg/R48ZT6XU7",
    NotifySide = "Right",
    ShowCustomCursor = true
})

local tabs = {
    main = window:AddTab("Combat"),
    vis = window:AddTab("Visuals"),
    plr = window:AddTab("Movement"),
    farm = window:AddTab("Farm"),
    skin = window:AddTab("Skins")
}

local plrsc = tabs.main:AddRightGroupbox("Whitelist")
local silent = tabs.main:AddLeftGroupbox("Silent Aim") 
local aim = tabs.main:AddRightGroupbox("Aimbot") 
local rage = tabs.main:AddLeftGroupbox("Ragebot")
local meele = tabs.main:AddRightGroupbox("Meele Aura") 
local esp = tabs.vis:AddLeftGroupbox("ESP") 
local esp2 = tabs.vis:AddRightGroupbox("ESP Scraps") 
local plrc = tabs.plr:AddLeftGroupbox("Player Changes")
local mod = tabs.main:AddRightGroupbox("Gun Mods")

local ESP = loadstring(game:HttpGet("https://pastebin.com/raw/2dU36TmL"))()
ESP.Enabled = false
ESP.ShowBox = false
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowTracer = false
ESP.ShowDistance = false
ESP.ShowSkeletons = false

ESP_Settings = {
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    TracerPosition = "Bottom"
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local camera = workspace.CurrentCamera
local rp = game:GetService("ReplicatedStorage")
local plrs = Players
local me = Player
local Workspace = game:GetService("Workspace")

local Aiming = false
local Target = nil
local WhiteList = {}

local functions = {
    SilentAim = false,
    FastPickup = false,
    RageBot = false,
    InstantReload = false,
    AutoPickupScraps = false,
    AutoPickupTools = false,
    AutoPickupCrates = false,
    AutoPickupMoney = false,
    NoBarriers = false,
    AutoOpenDoors = false,
    FakeDown = false,
    NoGrinder = false,
    AntiFling = false,
    HideHead = false,
    AdminCheck = false
}

local Settings = {
    InfiniteStamina = false,
    GunMods = {NoRecoil = false}
}

local SectionSettings = {
    SilentAim = {
        Draw = true,
        DrawSize = 130,
        DrawColor = Color3.new(1, 1, 1),
        Transparency = 1,
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false
    },
    RageBot = {
        CheckDowned = false,
        CheckWhiteList = false
    },
    ESP = {
        Highlight = false
    }
}

local cockie = {SilentAimCircle = nil}

silent:AddToggle("silent", {
    Text = "Silent Aim",
    Default = false,

    Callback = function(Value)
        functions.SilentAim = Value

        if Value then
            cockie.SilentAimCircle = Drawing.new("Circle")
            cockie.SilentAimCircle.Color = SectionSettings.SilentAim.DrawColor
            cockie.SilentAimCircle.Thickness = SectionSettings.SilentAim.Thickness
            cockie.SilentAimCircle.NumSides = 50
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
            cockie.SilentAimCircle.Filled = false
            cockie.SilentAimCircle.Visible = SectionSettings.SilentAim.Draw
            cockie.SilentAimCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

            local target = nil

            local function GetClosest()
                target = nil
                local closest = SectionSettings.SilentAim.DrawSize
                for _, v in pairs(plrs:GetPlayers()) do
                    if v ~= me and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if SectionSettings.SilentAim.CheckDowned and downed(v) then continue end
                        if SectionSettings.SilentAim.CheckTeam and v.Team == me.Team then continue end
                        if SectionSettings.SilentAim.CheckWhiteList and table.find(Whitelist, v) then continue end
                        if SectionSettings.SilentAim.CheckFF and v.Character:FindFirstChild("ForceField") then continue end

                        local hrp = v.Character.HumanoidRootPart
                        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y + 36)).Magnitude
                            if dist < closest then
                                target = v
                                closest = dist
                            end
                        end
                    end
                end
            end

            getgenv().SilentAimConn1 = RunService.RenderStepped:Connect(GetClosest)

            local VisualizeEvent = rp.Events2.Visualize
            local DamageEvent = rp.Events["ZFKLF__H"]

            local currentRandomPart = nil
            local lastTick = 0

            getgenv().SilentAimConn2 = RunService.Heartbeat:Connect(function()
                if target and target.Character and SectionSettings.SilentAim.ForceRandom then
                    if tick() - lastTick >= 0.1 then
                        local parts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                        repeat
                            currentRandomPart = target.Character:FindFirstChild(parts[math.random(#parts)])
                        until currentRandomPart
                        lastTick = tick()
                    end
                end
            end)

            getgenv().SilentAimConn3 = VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
                if not functions.SilentAim or not target or not target.Character then return end
                if not me.Character or not me.Character:FindFirstChildOfClass("Tool") then return end

                local hitchance = SectionSettings.SilentAim.HitChance or 100
                if math.random(1,100) > hitchance then return end

                local targetPart = SectionSettings.SilentAim.ForceRandom and currentRandomPart or
                    (target.Character:FindFirstChild(SectionSettings.SilentAim.TargetParts[math.random(#SectionSettings.SilentAim.TargetParts or {"Head"})]) 
                    or target.Character:FindFirstChild("Head"))

                if not targetPart then return end
                local partPos = targetPart.Position

                local Bullets = {}
                for i = 1, math.clamp(#BulletsPerShot, 1, 100) do
                    table.insert(Bullets, (partPos - StartPos).Unit)
                end

                task.wait(0.005)

                for i, dir in pairs(Bullets) do
                    DamageEvent:FireServer("butter", Gun, ShotCode, i, targetPart, partPos, dir)
                end

                if Gun:FindFirstChild("Hitmarker") then
                    Gun.Hitmarker:Fire(targetPart)
                end
            end)

        else
            if cockie.SilentAimCircle then cockie.SilentAimCircle:Remove() cockie.SilentAimCircle = nil end
            if getgenv().SilentAimConn1 then getgenv().SilentAimConn1:Disconnect() getgenv().SilentAimConn1 = nil end
            if getgenv().SilentAimConn2 then getgenv().SilentAimConn2:Disconnect() getgenv().SilentAimConn2 = nil end
            if getgenv().SilentAimConn3 then getgenv().SilentAimConn3:Disconnect() getgenv().SilentAimConn3 = nil end
        end
    end
})
:AddKeyPicker("silentkey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Silent Aim Key",
    NoUI = false,
})

silent:AddToggle("team", {
	Text = "Check Team",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    SectionSettings.SilentAim.CheckTeam = Value
    functions.CheckTeam = Value
end,
})

silent:AddToggle("whitelist", {
	Text = "Check Whitelist",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    SectionSettings.SilentAim.CheckWhitelist = Value
    functions.CheckWhitelist = Value
end,
})

esp:AddToggle("vis1", {
	Text = "Enabled ESP",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.Enabled = Value
end,
})

esp:AddToggle("vis2", {
	Text = "Show Box",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowBox = Value
end,
})

esp:AddToggle("vis3", {
	Text = "Show Name",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowName = Value
end,
})

esp:AddToggle("vis4", {
	Text = "Show Health",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowHealth = Value
end,
})

esp:AddToggle("vis5", {
	Text = "Show Tracer",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowTracer = Value
end,
})

esp:AddToggle("vis6", {
	Text = "Show Distance",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowDistance = Value
end,
})

esp:AddToggle("vis7", {
	Text = "Show Skeletons",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
    ESP.ShowSkeletons = Value
end,
})

esp:AddDivider()

plrc:AddToggle("fastpickup", {
	Text = "Fast Pickup",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
	    functions.FastPickup = Value
	    if Value then
	        for _, obj in ipairs(game:GetDescendants()) do
	            if obj:IsA("ProximityPrompt") then
	                obj.HoldDuration = 0
	            end
	        end
	        getgenv().FastPickupConn = game.DescendantAdded:Connect(function(obj)
	            if obj:IsA("ProximityPrompt") then
	                obj.HoldDuration = 0
	                obj:GetPropertyChangedSignal("HoldDuration"):Connect(function()
	                    if functions.FastPickup then
	                        obj.HoldDuration = 0
	                    end
	                end)
	            end
	        end)
	    else
	        if getgenv().FastPickupConn then
	            getgenv().FastPickupConn:Disconnect()
	        end
	    end
	end,
})
:AddKeyPicker("fastpickupkey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fast Pickup Key",
    NoUI = false,
})

plrc:AddToggle("autopickupmoney", {
	Text = "Auto Pickup Money",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
	    functions.AutoPickupMoney = Value
	    if Value then
	        local remote = rp.Events:FindFirstChild("CZDPZUS")
	        local moneyfolder = workspace.Filter.SpawnedBread
	        local canPickup = true
	        local startTick = tick()
	        getgenv().AutoPickupMoneyConn = RunService.RenderStepped:Connect(function()
	            local function GetMoney()
	                local maxdist = 15
	                local closest = nil
	                for _, a in pairs(moneyfolder:GetChildren()) do
	                    if a and me.Character and me.Character.HumanoidRootPart then
	                        local getdist = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
	                        if getdist < maxdist then
	                            maxdist = getdist
	                            closest = a
	                        end
	                    end
	                end
	                maxdist = 15
	                return closest
	            end
	            local foundmoney = GetMoney()
	            if foundmoney then
	                if canPickup then
	                    remote:FireServer(foundmoney)
	                    canPickup = false
	                end
	            end
	            if canPickup == false and tick() - startTick >= 1 then
	                canPickup = true
	                startTick = tick()
	            end
	        end)
	    else
	        if getgenv().AutoPickupMoneyConn then
	            getgenv().AutoPickupMoneyConn:Disconnect()
	        end
	    end
	end,
})
:AddKeyPicker("autopickupmoneykey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto Pickup Money Key",
    NoUI = false,
})

plrc:AddToggle("autopickupcrates", {
	Text = "Auto Pickup Crates",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
	    functions.AutoPickupCrates = Value
	    if Value then
	        local remote = rp.Events.PIC_CRATE
	        local cratesfolder = workspace.Filter.SpawnedCrates
	        local canPickup = true
	        local startTick = tick()
	        getgenv().AutoPickupCratesConn = RunService.RenderStepped:Connect(function()
	            local function GetClosestCrate()
	                local maxdist = 15
	                local closest = nil
	                for _, a in pairs(cratesfolder:GetChildren()) do
	                    if a and me.Character and me.Character.HumanoidRootPart then
	                        local handle = a:FindFirstChild("Handle")
	                        if handle and (handle:IsA("Part") or handle:IsA("MeshPart")) then
	                            local getdist = (me.Character.HumanoidRootPart.Position - handle.Position).Magnitude
	                            if getdist < maxdist then
	                                maxdist = getdist
	                                closest = a
	                            end
	                        end
	                    end
	                end
	                maxdist = 15
	                return closest
	            end
	            local crate = GetClosestCrate()
	            if crate then
	                local Handle = crate:FindFirstChild("Handle")
	                if Handle then
	                    if canPickup then
	                        remote:FireServer(Handle)
	                        canPickup = false
	                    end
	                end
	            end
	            if canPickup == false and tick() - startTick >= 1.5 then
	                canPickup = true
	                startTick = tick()
	            end
	        end)
	    else
	        if getgenv().AutoPickupCratesConn then
	            getgenv().AutoPickupCratesConn:Disconnect()
	        end
	    end
	end,
})
:AddKeyPicker("autopickupcrateskey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto Pickup Crates Key",
    NoUI = false,
})

silent:AddDropdown("aimp", {
	Values = { "Head", "Torso", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Random" },
	Default = 1, -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected

	Text = "Silent Aim Parts",
	Tooltip = "This is a tooltip", -- Information shown when you hover over the dropdown
	DisabledTooltip = "I am disabled!", -- Information shown when you hover over the dropdown while it's disabled

	Searchable = false, -- true / false, makes the dropdown searchable (great for a long list of values)

	Callback = function(Value)
		SectionSettings.SilentAim.TargetParts = {Value}
	end,

	Disabled = false, -- Will disable the dropdown (true / false)
	Visible = true, -- Will make the dropdown invisible (true / false)
})

silent:AddSlider("fovc", {
	Text = "FOV Circle Change",
	Default = 80,
	Min = 1,
	Max = 200,
	Rounding = 1,
	Compact = false,

	Callback = function(Value)
		SectionSettings.SilentAim.DrawSize = Value
	end,

	Tooltip = "I am a slider!", -- Information shown when you hover over the slider
	DisabledTooltip = "I am disabled!", -- Information shown when you hover over the slider while it's disabled

	Disabled = false, -- Will disable the slider (true / false)
	Visible = true, -- Will make the slider invisible (true / false)
})


mod:AddToggle("nor", {
    Text = "No Recoil",
    Tooltip = "This is a tooltip",
    DisabledTooltip = "I am disabled!",

    Default = false,
    Disabled = false,
    Visible = true,
    Risky = false,

    Callback = function(Value)
        Settings.GunMods.NoRecoil = Value

        if Value then
            local lp = game:GetService("Players").LocalPlayer
            local lpc = lp.Character

            local norecoilConnect = lpc.ChildAdded:Connect(function(Item)
                if Item:IsA("Tool") then
                    for i, v in pairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "EquipTime") then
                            v.Recoil = 0
                            v.CameraRecoilingEnabled = false
                            v.AngleX_Min = 0
                            v.AngleX_Max = 0
                            v.AngleY_Min = 0
                            v.AngleY_Max = 0
                            v.AngleZ_Min = 0
                            v.AngleZ_Max = 0
                        end
                    end
                end
            end)

            getgenv().norecoilConn = norecoilConnect
        end
    end
})


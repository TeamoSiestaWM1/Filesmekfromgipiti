--[[
    ================================================================================
    INTEGRATED SUPER SCRIPT - ULTIMATE EDITION (FULL TWEEN & UI FIX)
    ================================================================================
    - UI POSITION: CENTERED (FIXED)
    - DRAG LOCK: ENABLED ON SCROLLING AREAS
    - AUTO COUNT: DEFAULT ON (FIXED)
    ================================================================================
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

local farmrare = false
local feeding = false
local autoCount = true -- Đã đặt mặc định là TRUE
local uiVisible = false
local currentScale = 0.5

local ClientStatCache = require(ReplicatedStorage:WaitForChild("ClientStatCache"))
local globalCache = nil
local lastUpdateTick = 0

-- [HÀM LẤY ICON TỪ GAME]
local function GetItemIcon(itemName)
    local eggTypes = ReplicatedStorage:FindFirstChild("EggTypes")
    if eggTypes then
        local iconData = eggTypes:FindFirstChild(itemName .. "Icon")
        if iconData then
            if iconData:IsA("Decal") then return iconData.Texture
            elseif iconData:IsA("ImageLabel") then return iconData.Image
            elseif iconData:IsA("StringValue") then return iconData.Value
            end
        end
    end
    return ""
end

-- [DỌN DẸP UI CŨ]
local function CleanOldInterface()
    for _, v in ipairs(playerGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name == "IntegratedUI" or v.Name == "CraftUI" or v.Name == "AutoCraftUI") then
            v:Destroy()
        end
    end
end
CleanOldInterface()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IntegratedUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = playerGui

-- [NÚT MỞ MENU]
local mainToggle = Instance.new("TextButton")
mainToggle.Name = "MainToggle"
mainToggle.Size = UDim2.new(0, 180, 0, 50)
mainToggle.Position = UDim2.new(1, -200, 0, 20)
mainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainToggle.Text = "OPEN MENU"
mainToggle.TextColor3 = Color3.new(1, 1, 1)
mainToggle.Font = Enum.Font.SourceSansBold
mainToggle.TextSize = 24
mainToggle.Parent = screenGui
Instance.new("UICorner", mainToggle).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainToggle).Color = Color3.fromRGB(0, 255, 120)

-- [KHUNG CHÍNH]
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MasterFrame"
mainFrame.Size = UDim2.new(0, 1250, 0, 650)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

local masterScale = Instance.new("UIScale")
masterScale.Scale = currentScale
masterScale.Parent = mainFrame

local function EnableScrollLock(scrollFrame)
    scrollFrame.MouseEnter:Connect(function() mainFrame.Draggable = false end)
    scrollFrame.MouseLeave:Connect(function() mainFrame.Draggable = true end)
end

-- [COL 1: INVENTORY]
local col1 = Instance.new("Frame", mainFrame)
col1.Size = UDim2.new(0, 260, 1, -40)
col1.Position = UDim2.new(0, 20, 0, 20)
col1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", col1)

local invHeader = Instance.new("TextLabel", col1)
invHeader.Size = UDim2.new(1, 0, 0, 45)
invHeader.Text = "INVENTORY"
invHeader.TextSize = 26
invHeader.TextColor3 = Color3.fromRGB(255, 200, 0)
invHeader.BackgroundTransparency = 1

local searchBar = Instance.new("TextBox", col1)
searchBar.Size = UDim2.new(1, -20, 0, 40)
searchBar.Position = UDim2.new(0, 10, 0, 55)
searchBar.PlaceholderText = "Search..."
searchBar.TextSize = 22
searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBar.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", searchBar)

local invScroll = Instance.new("ScrollingFrame", col1)
invScroll.Size = UDim2.new(1, -10, 1, -120)
invScroll.Position = UDim2.new(0, 5, 0, 105)
invScroll.BackgroundTransparency = 1
invScroll.ScrollBarThickness = 6
EnableScrollLock(invScroll)

local invListLayout = Instance.new("UIListLayout", invScroll)
invListLayout.Padding = UDim.new(0, 10)

-- [COL 2: TELEPORT]
local col2 = Instance.new("Frame", mainFrame)
col2.Size = UDim2.new(0, 230, 1, -40)
col2.Position = UDim2.new(0, 300, 0, 20)
col2.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", col2)

local tweenScroll = Instance.new("ScrollingFrame", col2)
tweenScroll.Size = UDim2.new(1, -10, 1, -20)
tweenScroll.Position = UDim2.new(0, 5, 0, 10)
tweenScroll.BackgroundTransparency = 1
tweenScroll.ScrollBarThickness = 6
EnableScrollLock(tweenScroll)
Instance.new("UIListLayout", tweenScroll).Padding = UDim.new(0, 8)

-- [COL 3: MANUAL CONTROLS]
local col3 = Instance.new("Frame", mainFrame)
col3.Size = UDim2.new(0, 320, 1, -40)
col3.Position = UDim2.new(0, 550, 0, 20)
col3.BackgroundTransparency = 1

local manualInput = Instance.new("TextBox", col3)
manualInput.Size = UDim2.new(1, -20, 0, 55)
manualInput.Position = UDim2.new(0, 10, 0, 0)
manualInput.PlaceholderText = "Manual Count"
manualInput.TextSize = 24
manualInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
manualInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", manualInput)

local resLabel = Instance.new("TextLabel", col3)
resLabel.Size = UDim2.new(1, 0, 0, 45)
resLabel.Position = UDim2.new(0, 0, 0, 65)
resLabel.Text = "Result: 0 Mooncharms"
resLabel.TextSize = 22
resLabel.TextColor3 = Color3.new(0, 1, 1)
resLabel.BackgroundTransparency = 1

local feedIn = Instance.new("TextBox", col3)
feedIn.Size = UDim2.new(1, -20, 0, 55)
feedIn.Position = UDim2.new(0, 10, 0, 115)
feedIn.Text = "500"
feedIn.TextSize = 24
feedIn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
feedIn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", feedIn)

-- [COL 4: AUTO CRAFT]
local col4 = Instance.new("Frame", mainFrame)
col4.Size = UDim2.new(0, 310, 1, -40)
col4.Position = UDim2.new(1, -330, 0, 20)
col4.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", col4)

local autoToggle = Instance.new("TextButton", col4)
autoToggle.Size = UDim2.new(1, -20, 0, 55)
autoToggle.Position = UDim2.new(0, 10, 0, 10)
-- Đặt trạng thái ban đầu hiển thị ON
autoToggle.Text = "Auto Count: ON"
autoToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
autoToggle.TextSize = 22
autoToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", autoToggle)

local craftScroll = Instance.new("ScrollingFrame", col4)
craftScroll.Size = UDim2.new(1, -20, 1, -90)
craftScroll.Position = UDim2.new(0, 10, 0, 80)
craftScroll.BackgroundTransparency = 1
craftScroll.ScrollBarThickness = 6
EnableScrollLock(craftScroll)
Instance.new("UIListLayout", craftScroll).Padding = UDim.new(0, 10)

-- [LOGIC TWEEN ENGINE]
local floatPart = Instance.new("Part", workspace)
floatPart.Anchored = true
floatPart.Transparency = 1
local isFloating = false

RunService.Heartbeat:Connect(function()
    if isFloating then
        floatPart.CanCollide = true
        floatPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -3.8, 0)
    else
        floatPart.CanCollide = false
    end
end)

local function TweenTo(cf)
    local dist = (character.HumanoidRootPart.Position - cf.Position).Magnitude
    isFloating = true
    character.HumanoidRootPart.Anchored = true
    local tw = TweenService:Create(character.HumanoidRootPart, TweenInfo.new(dist/100, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play()
    task.delay((dist/100)-0.05, function() isFloating = false end)
    tw.Completed:Wait()
    character.HumanoidRootPart.Anchored = false
end

local function BuildTweenBtn(name, color, func)
    local b = Instance.new("TextButton", tweenScroll)
    b.Size = UDim2.new(1, -10, 0, 42)
    b.Text = name
    b.TextSize = 20
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
    return b
end

-- [ĐĂNG KÝ TWEEN]
BuildTweenBtn("Blender", Color3.fromRGB(70, 130, 180), function() TweenTo(CFrame.new(-424, 69, 37)) end)
BuildTweenBtn("Diamond Mask", Color3.fromRGB(0, 180, 180), function() TweenTo(CFrame.new(-334, 132, -392)) end)
BuildTweenBtn("Royal Jelly Shop", Color3.fromRGB(180, 120, 0), function() TweenTo(CFrame.new(-293.1, 52.2, 68.2)) end)
BuildTweenBtn("Petal Shop", Color3.fromRGB(255, 120, 200), function() TweenTo(CFrame.new(-500.5, 51.5, 466.1)) end)
BuildTweenBtn("Nectar Conserver", Color3.fromRGB(120, 255, 120), function() TweenTo(CFrame.new(-415.5, 101.0, 343.2)) end)
BuildTweenBtn("Dapper Shop", Color3.fromRGB(15, 97, 0), function() TweenTo(CFrame.new(535.4, 137.8, -319.6)) end)
BuildTweenBtn("Star Amulet", Color3.fromRGB(0, 245, 16), function() TweenTo(CFrame.new(169.3, 72.2, 358.0)) end)
BuildTweenBtn("Sticker Printer", Color3.fromRGB(166, 0, 255), function() TweenTo(CFrame.new(205.6, 161.7, -194.6)) end)
BuildTweenBtn("Gifted Bucko Bee", Color3.fromRGB(64, 0, 255), function() TweenTo(CFrame.new(298.5, 61.4, 107.1)) end)

-- [RARE FARM SYSTEM]
local rStart = BuildTweenBtn("START RARE FARM", Color3.fromRGB(80, 0, 150), function()
    farmrare = true
    task.spawn(function()
        local points = {Vector3.new(-54,26,-62), Vector3.new(-168,40,76), Vector3.new(14,11,68), Vector3.new(-436,101,49)}
        while farmrare do
            for _, p in ipairs(points) do
                if not farmrare then break end
                TweenTo(CFrame.new(p))
                task.wait(1)
            end
        end
    end)
end)

local rStop = BuildTweenBtn("STOP RARE FARM", Color3.fromRGB(180, 0, 50), function() farmrare = false end)

-- [CONTROL BUTTONS]
local function BuildControlBtn(text, y, color, func)
    local b = Instance.new("TextButton", col3)
    b.Size = UDim2.new(1, -20, 0, 50)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.TextSize = 22
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

BuildControlBtn("STOP BLENDER", 185, Color3.fromRGB(150, 0, 0), function() ReplicatedStorage.Events.BlenderCommand:InvokeServer("StopOrder") end)
BuildControlBtn("FINISH BY TICKETS", 245, Color3.fromRGB(0, 120, 0), function() ReplicatedStorage.Events.BlenderCommand:InvokeServer("SpeedUpOrder") end)
BuildControlBtn("FEED ALL BEES", 305, Color3.fromRGB(255, 140, 0), function()
    local amt = tonumber(feedIn.Text)
    if not amt or feeding then return end
    feeding = true
    task.spawn(function()
        local r, t = 1, 1
        while feeding do
            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(r, t, "Treat", amt, false)
            if r == 5 and t == 10 then break end
            r = r + 1 if r > 5 then r = 1 t = t + 1 end
            task.wait(0.5)
        end
        feeding = false
    end)
end)
BuildControlBtn("STOP FEEDING", 365, Color3.fromRGB(180, 50, 50), function() feeding = false end)

-- [INVENTORY & CRAFT SYSTEM]
local function GetInv()
    if tick() - lastUpdateTick > 1.2 then
        local s, d = pcall(function() return ClientStatCache:Get() end)
        if s then globalCache = d lastUpdateTick = tick() end
    end
    return globalCache or {}
end

local function Fetch(name)
    local inv = GetInv()
    local eggs = inv.Eggs or {}
    return tonumber(eggs[name]) or 0
end

local items = {"BlueExtract","RedExtract","Oil","Enzymes","Glue","Glitter","MagicBean","Gumdrops","MoonCharm","Blueberry","Strawberry","SunflowerSeed","Pineapple","RoyalJelly","StarJelly","TropicalDrink","PurplePotion","SuperSmoothie"}
local itemRows = {}

for _, name in ipairs(items) do
    local r = Instance.new("Frame", invScroll)
    r.Size = UDim2.new(1, 0, 0, 45)
    r.BackgroundTransparency = 1
    
    local icon = Instance.new("ImageLabel", r)
    icon.Size = UDim2.new(0, 38, 0, 38)
    icon.Position = UDim2.new(0, 5, 0.5, -19)
    icon.Image = GetItemIcon(name)
    icon.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", r)
    l.Size = UDim2.new(1, -55, 1, 0)
    l.Position = UDim2.new(0, 50, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name .. ": 0"
    l.TextSize = 22
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    itemRows[name] = {Frame = r, Label = l}
end

local recipes = {
    BlueExtract = {Blueberry=50, RoyalJelly=10}, RedExtract = {Strawberry=50, RoyalJelly=10}, Oil = {SunflowerSeed=50, RoyalJelly=10}, Enzymes = {Pineapple=50, RoyalJelly=10}, Gumdrops = {Blueberry=3, Strawberry=3, Pineapple=3}, Glue = {Gumdrops=50}, MoonCharm = {Pineapple=5, Gumdrops=5, RoyalJelly=1}, Glitter = {MoonCharm=25, MagicBean=1}, StarJelly = {RoyalJelly=100, Glitter=3}
}

local function CalcMax(name)
    local r = recipes[name]
    if not r then return 0 end
    local m = math.huge
    for ing, req in pairs(r) do m = math.min(m, math.floor(Fetch(ing)/req)) end
    return (m == math.huge) and 0 or m
end

local craftBtns = {}
for name, _ in pairs(recipes) do
    local b = Instance.new("TextButton", craftScroll)
    b.Size = UDim2.new(1, -10, 0, 50)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.Text = "          " .. name .. " (0)"
    b.TextSize = 20
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    
    local icon = Instance.new("ImageLabel", b)
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Position = UDim2.new(0, 8, 0.5, -17.5)
    icon.Image = GetItemIcon(name)
    icon.BackgroundTransparency = 1

    b.MouseButton1Click:Connect(function()
        local amt = autoCount and CalcMax(name) or tonumber(manualInput.Text) or 1
        if amt > 0 then ReplicatedStorage.Events.BlenderCommand:InvokeServer("PlaceOrder", {Recipe = name, Count = amt}) end
    end)
    craftBtns[name] = b
end

-- [STATS & UPDATES]
local statsF = Instance.new("Frame", screenGui)
statsF.Size = UDim2.new(0, 180, 0, 25)
statsF.Position = UDim2.new(1, -200, 0, 75)
statsF.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", statsF)

local statsL = Instance.new("TextLabel", statsF)
statsL.Size = UDim2.new(1, 0, 1, 0)
statsL.Text = "FPS: 0 | PING: 0 ms"
statsL.TextSize = 16
statsL.TextColor3 = Color3.new(0, 1, 0.6)
statsL.BackgroundTransparency = 1

local fC, lC = 0, os.clock()
RunService.RenderStepped:Connect(function()
    fC = fC + 1
    if os.clock() - lC >= 1 then
        local p = math.floor(player:GetNetworkPing() * 1000)
        if p <= 0 then p = math.floor(Stats.Network.ServerTickTag:GetTime() * 100) end
        statsL.Text = string.format("FPS: %d | PING: %d ms", fC, p)
        fC, lC = 0, os.clock()
    end
end)

RunService.Heartbeat:Connect(function()
    if not mainFrame.Visible then return end
    for n, r in pairs(itemRows) do r.Label.Text = n .. ": " .. Fetch(n) end
    for n, b in pairs(craftBtns) do
        local c = CalcMax(n)
        b.Text = "          " .. n .. " (" .. c .. ")"
        b.BackgroundColor3 = (c > 0) and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(50, 50, 50)
    end
    invScroll.CanvasSize = UDim2.new(0, 0, 0, invListLayout.AbsoluteContentSize.Y + 25)
end)

manualInput:GetPropertyChangedSignal("Text"):Connect(function()
    local v = tonumber(manualInput.Text)
    if v then resLabel.Text = "Result: " .. (v/50) .. " or " .. (v/25) .. " Mooncharm" end
end)

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local f = searchBar.Text:lower()
    for n, r in pairs(itemRows) do r.Frame.Visible = (f == "" or n:lower():find(f)) end
end)

autoToggle.MouseButton1Click:Connect(function()
    autoCount = not autoCount
    -- Logic hiển thị chữ và màu khớp với trạng thái
    autoToggle.Text = autoCount and "Auto Count: ON" or "Auto Count: OFF"
    autoToggle.BackgroundColor3 = autoCount and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(60, 60, 60)
end)

mainToggle.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
    mainToggle.Text = uiVisible and "CLOSE MENU" or "OPEN MENU"
end)

-- [FONT & FINAL]
local function applyFont(p)
    local FONT = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    for _, o in ipairs(p:GetDescendants()) do
        if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then o.FontFace = FONT end
    end
end
applyFont(screenGui)
screenGui.DescendantAdded:Connect(function(o) task.wait() if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then o.FontFace = Font.new("rbxassetid://12187365364") end end)

getgenv().Settings = { HideGlitchFX = true, HideOtherBees = true, TRequests = true, PollenTextLarge = false, PollenPopUps = false, MusicMuted = true }
for k, v in pairs(getgenv().Settings) do
    pcall(function() ReplicatedStorage.Events.PlayerSettingsEvent:FireServer(k, v) end)
end

task.spawn(function()
    if setfpscap then setfpscap(15) end
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/1toop/bss/refs/heads/main/pot.lua"))() end)
end)

--[[
    ================================================================================
    INTEGRATED SUPER SCRIPT - ULTIMATE EDITION (FULL BACKGROUND & NOTIFY)
    ================================================================================
    - UI POSITION: CENTERED
    - BLENDER STATUS: BACKGROUND UPDATE (CHẠY NGẦM 24/7)
    - TOY EVENT: TỰ ĐỘNG CẬP NHẬT BLENDER QUA FIRESERVER
    - DATA SOURCE: BlenderState (FIXED)
    ================================================================================
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

local farmrare, feeding, autoCount, uiVisible = false, false, true, false
local currentScale = 0.5
local lastUpdateTick = 0
local globalCache = nil
local notifiedFinish = false 

-- [MODULES CHUẨN TỪ DUMP]
local ClientStatCache = require(ReplicatedStorage:WaitForChild("ClientStatCache"))
local TimeString = require(ReplicatedStorage:WaitForChild("TimeString"))
local BlenderRecipes = require(ReplicatedStorage:WaitForChild("BlenderRecipes"))
local OsTime = require(ReplicatedStorage:WaitForChild("OsTime"))

-- [HÀM THÔNG BÁO]
local function Notify(title, msg)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = msg,
        Duration = 5,
        Icon = "rbxassetid://4458901886"
    })
end

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
if playerGui:FindFirstChild("IntegratedUI") then playerGui.IntegratedUI:Destroy() end

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "IntegratedUI"
screenGui.ResetOnSpawn = false

-- [NÚT MỞ MENU]
local mainToggle = Instance.new("TextButton", screenGui)
mainToggle.Size = UDim2.new(0, 180, 0, 50); mainToggle.Position = UDim2.new(1, -200, 0, 20); mainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mainToggle.Text = "OPEN MENU"; mainToggle.TextColor3 = Color3.new(1, 1, 1); mainToggle.TextSize = 24
Instance.new("UICorner", mainToggle).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainToggle).Color = Color3.fromRGB(0, 255, 120)

-- [KHUNG CHÍNH]
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 1250, 0, 650); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.Visible = false; mainFrame.Active = true; mainFrame.Draggable = true 
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
local masterScale = Instance.new("UIScale", mainFrame); masterScale.Scale = currentScale

local function EnableScrollLock(scrollFrame)
    scrollFrame.MouseEnter:Connect(function() mainFrame.Draggable = false end)
    scrollFrame.MouseLeave:Connect(function() mainFrame.Draggable = true end)
end

-- [COL 1: INVENTORY]
local col1 = Instance.new("Frame", mainFrame)
col1.Size = UDim2.new(0, 260, 1, -40); col1.Position = UDim2.new(0, 20, 0, 20); col1.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", col1)
local invHeader = Instance.new("TextLabel", col1); invHeader.Size = UDim2.new(1, 0, 0, 45); invHeader.Text = "INVENTORY"; invHeader.TextSize = 26; invHeader.TextColor3 = Color3.fromRGB(255, 200, 0); invHeader.BackgroundTransparency = 1
local searchBar = Instance.new("TextBox", col1); searchBar.Size = UDim2.new(1, -20, 0, 40); searchBar.Position = UDim2.new(0, 10, 0, 55); searchBar.PlaceholderText = "Search..."; searchBar.TextSize = 22; searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); searchBar.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", searchBar)
local invScroll = Instance.new("ScrollingFrame", col1); invScroll.Size = UDim2.new(1, -10, 1, -120); invScroll.Position = UDim2.new(0, 5, 0, 105); invScroll.BackgroundTransparency = 1; invScroll.ScrollBarThickness = 6; EnableScrollLock(invScroll); invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local invListLayout = Instance.new("UIListLayout", invScroll); invListLayout.Padding = UDim.new(0, 10)

-- [COL 2: TELEPORT]
local col2 = Instance.new("Frame", mainFrame); col2.Size = UDim2.new(0, 230, 1, -40); col2.Position = UDim2.new(0, 300, 0, 20); col2.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", col2)
local tweenScroll = Instance.new("ScrollingFrame", col2); tweenScroll.Size = UDim2.new(1, -10, 1, -20); tweenScroll.Position = UDim2.new(0, 5, 0, 10); tweenScroll.BackgroundTransparency = 1; tweenScroll.ScrollBarThickness = 6; EnableScrollLock(tweenScroll); Instance.new("UIListLayout", tweenScroll).Padding = UDim.new(0, 8)

-- [COL 3: CONTROLS & CHECK BLENDER]
local col3 = Instance.new("Frame", mainFrame); col3.Size = UDim2.new(0, 320, 1, -40); col3.Position = UDim2.new(0, 550, 0, 20); col3.BackgroundTransparency = 1
local manualInput = Instance.new("TextBox", col3); manualInput.Size = UDim2.new(1, -20, 0, 55); manualInput.PlaceholderText = "Manual Count"; manualInput.TextSize = 24; manualInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50); manualInput.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", manualInput)
local resLabel = Instance.new("TextLabel", col3); resLabel.Size = UDim2.new(1, 0, 0, 45); resLabel.Position = UDim2.new(0, 0, 0, 65); resLabel.Text = "Result: 0 Mooncharms"; resLabel.TextSize = 22; resLabel.TextColor3 = Color3.new(0, 1, 1); resLabel.BackgroundTransparency = 1
local feedIn = Instance.new("TextBox", col3); feedIn.Size = UDim2.new(1, -20, 0, 55); feedIn.Position = UDim2.new(0, 10, 0, 115); feedIn.Text = "500"; feedIn.TextSize = 24; feedIn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", feedIn)

-- [[ UI CHECK BLENDER ]]
local bFrame = Instance.new("Frame", col3); bFrame.Size = UDim2.new(1, -20, 0, 150); bFrame.Position = UDim2.new(0, 10, 0, 440); bFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", bFrame)
local bStroke = Instance.new("UIStroke", bFrame); bStroke.Color = Color3.fromRGB(0, 160, 255); bStroke.Thickness = 2
local bIcon = Instance.new("ImageLabel", bFrame); bIcon.Size = UDim2.new(0, 50, 0, 50); bIcon.Position = UDim2.new(0, 10, 0, 10); bIcon.BackgroundTransparency = 1
local bName = Instance.new("TextLabel", bFrame); bName.Size = UDim2.new(1, -70, 0, 25); bName.Position = UDim2.new(0, 65, 0, 10); bName.Text = "BLENDER: IDLE"; bName.TextColor3 = Color3.new(1,1,1); bName.TextXAlignment = Enum.TextXAlignment.Left; bName.BackgroundTransparency = 1; bName.TextSize = 20
local bProgText = Instance.new("TextLabel", bFrame); bProgText.Size = UDim2.new(1, -70, 0, 20); bProgText.Position = UDim2.new(0, 65, 0, 35); bProgText.Text = "Progress: 0 / 0"; bProgText.TextColor3 = Color3.fromRGB(180, 180, 180); bProgText.TextXAlignment = Enum.TextXAlignment.Left; bProgText.BackgroundTransparency = 1; bProgText.TextSize = 16
local bBarBG = Instance.new("Frame", bFrame); bBarBG.Size = UDim2.new(1, -20, 0, 12); bBarBG.Position = UDim2.new(0, 10, 0, 85); bBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", bBarBG)
local bBarFill = Instance.new("Frame", bBarBG); bBarFill.Size = UDim2.new(0, 0, 1, 0); bBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120); Instance.new("UICorner", bBarFill)
local bTime = Instance.new("TextLabel", bFrame); bTime.Size = UDim2.new(1, -20, 0, 30); bTime.Position = UDim2.new(0, 10, 0, 110); bTime.Text = "Time Left: --:--"; bTime.TextColor3 = Color3.fromRGB(0, 255, 255); bTime.BackgroundTransparency = 1; bTime.TextSize = 18
local bTicketHint = Instance.new("TextLabel", bFrame); bTicketHint.Size = UDim2.new(1, -20, 0, 20); bTicketHint.Position = UDim2.new(0, 10, 0, 70); bTicketHint.Text = ""; bTicketHint.TextColor3 = Color3.fromRGB(255, 255, 100); bTicketHint.BackgroundTransparency = 1; bTicketHint.TextSize = 14; bTicketHint.TextXAlignment = Enum.TextXAlignment.Right

-- [HÀM CẬP NHẬT BLENDER CHÍNH & FIRE SERVER]
local function UpdateBlenderLogic()
    -- Cập nhật dữ liệu từ Server liên tục
    pcall(function()
        ReplicatedStorage.Events.ToyEvent:FireServer("Blender")
    end)

    local fullStats = ClientStatCache:Get()
    local state = fullStats and fullStats.BlenderState 
    
    if not state or not state.Recipe or state.Recipe == "" then
        bName.Text = "BLENDER: EMPTY"; bProgText.Text = "Ready to craft"; bTime.Text = "Status: Idle"; bTicketHint.Text = ""; bBarFill.Size = UDim2.new(0,0,1,0); bIcon.Image = ""; bStroke.Color = Color3.fromRGB(60,60,60)
        notifiedFinish = false
        return
    end

    local recipeData = BlenderRecipes.Get(state.Recipe)
    if not recipeData then return end
    
    local playTimeAtLoad = fullStats.PlaytimeAtLoad or 0
    local loadTime = fullStats.LoadTime or 0
    local offlineTime = fullStats.OfflineProgressTime or 0
    local currentTime = OsTime() - loadTime
    local timeElapsed = (playTimeAtLoad + offlineTime + currentTime) - state.StartTime
    
    local totalReqTime = state.Count * recipeData.Time
    local timeLeft = math.max(0, totalReqTime - timeElapsed)
    local rawProg = math.clamp(timeElapsed / totalReqTime, 0, 1)
    local doneCount = math.floor(rawProg * state.Count)

    local ticketPrice = math.ceil((state.Count - math.floor(math.floor(rawProg * state.Count) / recipeData.AutoCompletePerTicket) * recipeData.AutoCompletePerTicket) / recipeData.AutoCompletePerTicket)
    if ticketPrice < 0 then ticketPrice = 0 end

    bName.Text = "CRAFTING: " .. tostring(state.Recipe)
    bProgText.Text = "Progress: " .. doneCount .. " / " .. state.Count
    bIcon.Image = GetItemIcon(state.Recipe)
    bBarFill.Size = UDim2.new(rawProg, 0, 1, 0)
    bTicketHint.Text = ticketPrice > 0 and ("Speed Up: " .. ticketPrice .. " Tickets") or ""
    bStroke.Color = Color3.fromRGB(0, 160, 255)

    if timeLeft > 0 then
        bTime.Text = "Time Left: " .. TimeString(timeLeft); bTime.TextColor3 = Color3.fromRGB(0, 255, 255)
    else
        bTime.Text = "STATUS: FINISHED!"; bTime.TextColor3 = Color3.fromRGB(0, 255, 0)
        if not notifiedFinish then
            Notify("Blender Done!", "Vật phẩm " .. state.Recipe .. " đã hoàn thành!")
            notifiedFinish = true
        end
    end
end

-- [CRAFTING & INVENTORY DATA]
local function GetInv()
    if tick() - lastUpdateTick > 1.2 then
        local s, d = pcall(function() return ClientStatCache:Get() end)
        if s then globalCache = d lastUpdateTick = tick() end
    end
    return globalCache or {}
end
local function Fetch(name) local inv = GetInv(); local eggs = inv.Eggs or {}; return tonumber(eggs[name]) or 0 end
local recipeOrder = {"RedExtract", "BlueExtract", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharm", "Glitter", "StarJelly", "PurplePotion", "SoftWax", "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "SuperSmoothie", "Turpentine"}
local recipes = { RedExtract = {Strawberry=50, RoyalJelly=10}, BlueExtract = {Blueberry=50, RoyalJelly=10}, Enzymes = {Pineapple=50, RoyalJelly=10}, Oil = {SunflowerSeed=50, RoyalJelly=10}, Glue = {Gumdrops=50, RoyalJelly=10}, TropicalDrink = {Coconut=10, Enzymes=2, Oil=2}, Gumdrops = {Blueberry=3, Strawberry=3, Pineapple=3}, MoonCharm = {Pineapple=5, Gumdrops=5, RoyalJelly=1}, Glitter = {MoonCharm=25, MagicBean=1}, StarJelly = {RoyalJelly=100, Glitter=3}, PurplePotion = {Neonberry=3, RedExtract=3, BlueExtract=3, Glue=3}, SoftWax = {Honeysuckle=5, Oil=1, Enzymes=1, RoyalJelly=10}, HardWax = {SoftWax=3, Enzymes=3, Bitterberry=33, RoyalJelly=33}, SwirledWax = {HardWax=3, SoftWax=9, PurplePotion=6, RoyalJelly=3333}, CausticWax = {HardWax=5, Enzymes=5, Neonberry=25, RoyalJelly=5252}, FieldDice = {SoftWax=1, Whirligig=1, RedExtract=1, BlueExtract=1}, SmoothDice = {FieldDice=3, SoftWax=3, Whirligig=3, Oil=3}, LoadedDice = {SmoothDice=3, HardWax=3, Oil=3, Glue=1}, SuperSmoothie = {Neonberry=3, StarJelly=3, PurplePotion=3, TropicalDrink=6}, Turpentine = {SuperSmoothie=10, CausticWax=10, StarJelly=100, Honeysuckle=1000} }
local inventoryItems = {"RedExtract","BlueExtract","Enzymes","Oil","Glue","TropicalDrink","Gumdrops","MoonCharm","Glitter","StarJelly","PurplePotion","SoftWax","HardWax","SwirledWax","CausticWax","FieldDice","SmoothDice","LoadedDice","SuperSmoothie","Turpentine","Strawberry","Blueberry","Pineapple","SunflowerSeed","RoyalJelly","Coconut","Neonberry","Honeysuckle","Bitterberry","Whirligig","MagicBean"}
local itemRows = {}
for _, name in ipairs(inventoryItems) do
    local r = Instance.new("Frame", invScroll); r.Size = UDim2.new(1, 0, 0, 45); r.BackgroundTransparency = 1
    local icon = Instance.new("ImageLabel", r); icon.Size = UDim2.new(0, 38, 0, 38); icon.Position = UDim2.new(0, 5, 0.5, -19); icon.Image = GetItemIcon(name); icon.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", r); l.Size = UDim2.new(1, -55, 1, 0); l.Position = UDim2.new(0, 50, 0, 0); l.BackgroundTransparency = 1; l.Text = name .. ": 0"; l.TextSize = 22; l.TextColor3 = Color3.new(1, 1, 1); l.TextXAlignment = Enum.TextXAlignment.Left; itemRows[name] = {Frame = r, Label = l}
end

local function CalcMax(name)
    local r = recipes[name]; if not r then return 0 end
    local m = math.huge; for ing, req in pairs(r) do m = math.min(m, math.floor(Fetch(ing)/req)) end
    return (m == math.huge) and 0 or m
end

-- [COL 4: AUTO CRAFT]
local col4 = Instance.new("Frame", mainFrame); col4.Size = UDim2.new(0, 310, 1, -40); col4.Position = UDim2.new(1, -330, 0, 20); col4.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", col4)
local autoToggle = Instance.new("TextButton", col4); autoToggle.Size = UDim2.new(1, -20, 0, 55); autoToggle.Position = UDim2.new(0, 10, 0, 10); autoToggle.Text = "Auto Count: ON"; autoToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100); autoToggle.TextColor3 = Color3.new(1,1,1); autoToggle.TextSize = 22; Instance.new("UICorner", autoToggle)
local craftScroll = Instance.new("ScrollingFrame", col4); craftScroll.Size = UDim2.new(1, -20, 1, -90); craftScroll.Position = UDim2.new(0, 10, 0, 80); craftScroll.BackgroundTransparency = 1; craftScroll.ScrollBarThickness = 6; EnableScrollLock(craftScroll); Instance.new("UIListLayout", craftScroll).Padding = UDim.new(0, 10)

local craftBtns = {}
for _, name in ipairs(recipeOrder) do
    local b = Instance.new("TextButton", craftScroll); b.Size = UDim2.new(1, -10, 0, 50); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.Text = "          " .. name .. " (0)"; b.TextSize = 20; b.TextColor3 = Color3.new(1, 1, 1); b.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", b)
    local icon = Instance.new("ImageLabel", b); icon.Size = UDim2.new(0, 35, 0, 35); icon.Position = UDim2.new(0, 8, 0.5, -17.5); icon.Image = GetItemIcon(name); icon.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function()
        local amt = autoCount and CalcMax(name) or tonumber(manualInput.Text) or 1
        if amt > 0 then ReplicatedStorage.Events.BlenderCommand:InvokeServer("PlaceOrder", {Recipe = name, Count = amt}) end
    end)
    craftBtns[name] = b
end

-- [VÒNG LẶP CẬP NHẬT NGẦM (BACKGROUND)]
task.spawn(function()
    while task.wait(1) do
        UpdateBlenderLogic() -- Luôn cập nhật ngầm & FireServer "Blender"
        if mainFrame.Visible then
            for n, r in pairs(itemRows) do r.Label.Text = n .. ": " .. Fetch(n) end
            for n, b in pairs(craftBtns) do
                local c = CalcMax(n); b.Text = "          " .. n .. " (" .. c .. ")"; b.BackgroundColor3 = (c > 0) and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(50, 50, 50)
            end
            invScroll.CanvasSize = UDim2.new(0, 0, 0, invListLayout.AbsoluteContentSize.Y + 25)
        end
    end
end)

-- [TWEEN & CONTROLS]
local function TweenTo(cf)
    local dist = (character.HumanoidRootPart.Position - cf.Position).Magnitude
    character.HumanoidRootPart.Anchored = true
    local tw = TweenService:Create(character.HumanoidRootPart, TweenInfo.new(dist/100, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play(); tw.Completed:Wait(); character.HumanoidRootPart.Anchored = false
end

local function BuildTweenBtn(name, color, func)
    local b = Instance.new("TextButton", tweenScroll); b.Size = UDim2.new(1, -10, 0, 42); b.Text = name; b.TextSize = 20; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b); b.MouseButton1Click:Connect(func); return b
end

BuildTweenBtn("Blender", Color3.fromRGB(70, 130, 180), function() TweenTo(CFrame.new(-424, 69, 37)) end)
BuildTweenBtn("Diamond Mask", Color3.fromRGB(0, 180, 180), function() TweenTo(CFrame.new(-334, 132, -392)) end)
BuildTweenBtn("Royal Jelly Shop", Color3.fromRGB(180, 120, 0), function() TweenTo(CFrame.new(-293.1, 52.2, 68.2)) end)
BuildTweenBtn("Petal Shop", Color3.fromRGB(255, 120, 200), function() TweenTo(CFrame.new(-500.5, 51.5, 466.1)) end)
BuildTweenBtn("Nectar Conserver", Color3.fromRGB(120, 255, 120), function() TweenTo(CFrame.new(-415.5, 101.0, 343.2)) end)
BuildTweenBtn("Dapper Shop", Color3.fromRGB(15, 97, 0), function() TweenTo(CFrame.new(535.4, 137.8, -319.6)) end)
BuildTweenBtn("Star Amulet", Color3.fromRGB(0, 245, 16), function() TweenTo(CFrame.new(169.3, 72.2, 358.0)) end)
BuildTweenBtn("Sticker Printer", Color3.fromRGB(166, 0, 255), function() TweenTo(CFrame.new(205.6, 161.7, -194.6)) end)
BuildTweenBtn("Gifted Bucko Bee", Color3.fromRGB(64, 0, 255), function() TweenTo(CFrame.new(298.5, 61.4, 107.1)) end)

local function BuildControlBtn(text, y, color, func)
    local b = Instance.new("TextButton", col3); b.Size = UDim2.new(1, -20, 0, 50); b.Position = UDim2.new(0, 10, 0, y); b.Text = text; b.TextSize = 22; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b); b.MouseButton1Click:Connect(func)
end
BuildControlBtn("STOP BLENDER", 185, Color3.fromRGB(150, 0, 0), function() ReplicatedStorage.Events.BlenderCommand:InvokeServer("StopOrder") end)
BuildControlBtn("FINISH BY TICKETS", 245, Color3.fromRGB(0, 120, 0), function() ReplicatedStorage.Events.BlenderCommand:InvokeServer("SpeedUpOrder") end)
BuildControlBtn("FEED ALL BEES", 305, Color3.fromRGB(255, 140, 0), function()
    local amt = tonumber(feedIn.Text); if not amt or feeding then return end
    feeding = true; task.spawn(function()
        local r, t = 1, 1
        while feeding do
            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(r, t, "Treat", amt, false)
            if r == 5 and t == 10 then break end
            r = r + 1; if r > 5 then r = 1; t = t + 1 end
            task.wait(0.5)
        end
        feeding = false
    end)
end)
BuildControlBtn("STOP FEEDING", 365, Color3.fromRGB(180, 50, 50), function() feeding = false end)

-- [STATS FPS/PING]
local statsF = Instance.new("Frame", screenGui); statsF.Size = UDim2.new(0, 180, 0, 25); statsF.Position = UDim2.new(1, -200, 0, 75); statsF.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", statsF)
local statsL = Instance.new("TextLabel", statsF); statsL.Size = UDim2.new(1, 0, 1, 0); statsL.TextSize = 16; statsL.TextColor3 = Color3.new(0, 1, 0.6); statsL.BackgroundTransparency = 1
local fC, lC = 0, os.clock()
RunService.RenderStepped:Connect(function()
    fC = fC + 1
    if os.clock() - lC >= 1 then
        statsL.Text = string.format("FPS: %d | PING: %d ms", fC, math.floor(player:GetNetworkPing() * 1000))
        fC, lC = 0, os.clock()
    end
end)

-- [SỰ KIỆN KHÁC]
mainToggle.MouseButton1Click:Connect(function() uiVisible = not uiVisible; mainFrame.Visible = uiVisible; mainToggle.Text = uiVisible and "CLOSE MENU" or "OPEN MENU" end)
autoToggle.MouseButton1Click:Connect(function() autoCount = not autoCount; autoToggle.Text = autoCount and "Auto Count: ON" or "Auto Count: OFF"; autoToggle.BackgroundColor3 = autoCount and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(60, 60, 60) end)
manualInput:GetPropertyChangedSignal("Text"):Connect(function() local v = tonumber(manualInput.Text); if v then resLabel.Text = "Result: " .. (v/50) .. " or " .. (v/25) .. " Mooncharm" end end)
searchBar:GetPropertyChangedSignal("Text"):Connect(function() local f = searchBar.Text:lower(); for n, r in pairs(itemRows) do r.Frame.Visible = (f == "" or n:lower():find(f)) end end)

-- [FONT & FINAL SETTINGS]
local function applyFont(p)
    local FONT = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    for _, o in ipairs(p:GetDescendants()) do if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then o.FontFace = FONT end end
end
applyFont(screenGui)


getgenv().Settings = { HideGlitchFX = true, HideOtherBees = true, TRequests = true, PollenTextLarge = false, PollenPopUps = false, MusicMuted = true }
for k, v in pairs(getgenv().Settings) do
    pcall(function() ReplicatedStorage.Events.PlayerSettingsEvent:FireServer(k, v) end)
end

task.spawn(function()
    if setfpscap then setfpscap(15) end
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/1toop/bss/refs/heads/main/pot.lua"))() end)
end)

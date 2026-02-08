getgenv().api = loadstring(game:HttpGet("https://raw.githubusercontent.com/Boxking776/kocmoc/main/api.lua"))()
local bssapi = loadstring(game:HttpGet("https://raw.githubusercontent.com/Boxking776/kocmoc/main/bssapi.lua"))()
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
   Name = "Bee swarm simulator+",
   LoadingTitle = "",
   LoadingSubtitle = "",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "ABCD", -- The Discord invite code, do not include discord.gg/
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Sirius Hub",
      Subtitle = "Key System",
      Note = "Join the discord (discord.gg/sirius)",
      FileName = "SiriusKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = "Hello"
   }
})

-- string item
local item = {
    RedExtract = "RedExtract",
    BlueExtract = "Blue Extract",
    Enzymes = "Enzymes",
    Oil = "Oil",
    TropicalDrink = "TropicalDrink",
    Glitter = "Glitter",
    Glue = "Glue",
    Gumdrop = "Gumdrop",
    MoonCharm = "MoonCharm",
    StarJelly = "StarJelly",
    PurplePotion = "PurplePotion",
    SoftWax = "SoftWax",
    HardWax = "HardWax",
    SwirledWax = "SwirledWax",
    CausticWax = "CausticWax",
    FieldDice = "FieldDice",
    SmoothDice = "SmoothDice",
    LoadedDice = "LoadedDice",
    SuperSmoothie = "SuperSmoothie",
}
--while magic bean

--boolean
local countitem = 1
-- float
float = false
local floatpad = Instance.new("Part", game:GetService("Workspace"))
floatpad.CanCollide = false
floatpad.Anchored = true
floatpad.Transparency = 1
floatpad.Name = "FloatPad"

game:GetService('RunService').Heartbeat:connect(function() 
    if float == true then
         game.Players.LocalPlayer.Character.Humanoid.BodyTypeScale.Value = 0 
         floatpad.CanCollide = true 
         floatpad.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.X, game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Y-3.75, game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Z) task.wait(0)  
        else 
            floatpad.CanCollide = false 
        end
end)

function Notify(Text)
    Rayfield:Notify({
        Title = "Bee Swam Simulator",
        Content = Text,
        Duration = 3.0,
        Image = 0,
     })    
end
function Endcraft()
    game:GetService("ReplicatedStorage").Events.BlenderCommand.InvokeServer("StopOrder")
end
function Craft(name,count)
    local craftitem = 
    {
        ["Recipe"] = name,
        ["Count"] = count
    }
    local Event = game:GetService("ReplicatedStorage").Events.BlenderCommand
    float = true
    api.tween(5,CFrame.new(-429, 69, 39))
    float = false
    Endcraft()
    Event:InvokeServer("PlaceOrder", craftitem)
    Notify("Crafting Successfuly "..count..""..name)
end
function Usemagicbean()
    local args = 
    {  
	[1]={
	   ["Name"] = "Magic Bean"
	   	}
    }
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerActivesCommand"):FireServer(unpack(args))
end
local main = Window:CreateTab("Main", 0) -- Title, Image
AutoMagicBean = false
local Button = main:CreateButton({
    Name = "Turn on auto drop magic bean",
    Callback = function()
        AutoMagicBean = true
        Notify("Auto drop magicbean toogle: ON")
        while AutoMagicBean == true do
            Usemagicbean()
            wait(2)
        end
    end,
 })
 local Button = main:CreateButton({
    Name = "Turn off auto drop magic bean",
    Callback = function()
        AutoMagicBean = false
        Notify("Auto drop magicbean toogle: OFF")
        while AutoMagicBean == true do
            Usemagicbean()
            wait(2)
        end
    end,
 })

local Toggle = main:CreateToggle({
    Name = "Enabled WhiteScreen",
    CurrentValue = false,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        local WhiteScreen = true
        if Value == true then WhiteScreen = false else WhiteScreen = true end
        if WhiteScreen == false then
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end,
 })

 local Button = main:CreateButton({
    Name = "Dataloss",
    Callback = function()
	AutoMagicBean = false 
        local args = {
            [1] = "Black Bear",
            [2] = "f\255",
            [3] = "Finish"
         }
        game:GetService("ReplicatedStorage").Events.UpdatePlayerNPCState:FireServer(unpack(args))
        Notify("Successfuly dataloss please wait 60 seaconds before out")
        wait(60)
	Notify("You can exit")
    end,
 })
 
--Crafting
local Tab = Window:CreateTab("Crafting", 0) -- Title, Image
local Input = Tab:CreateInput({
   Name = "Count",
   PlaceholderText = "Count",
   RemoveTextAfterFocusLost = false,
   Callback = function(input)
        countitem = input
   end,
})
local Button = Tab:CreateButton({
    Name = "Teleport Blender",
    Callback = function()
        float = true
        api.tween(4,CFrame.new(-429, 69, 39))
        float = false
    end,
 })
 local Button = Tab:CreateButton({
    Name = "End craft",
    Callback = function()
        float = true
        api.tween(4,CFrame.new(-429, 69, 39))
        float = false
        Endcraft()
    end,
 })
local Button = Tab:CreateButton({
   Name = "Craft Blue Extract",
   Callback = function()
         Craft(item.BlueExtract, countitem)
   end,
})
local Button = Tab:CreateButton({
    Name = "Craft Red Extract",
    Callback = function()
         Craft(item.RedExtract, countitem)
     end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Enzymes",
    Callback = function()
         Craft(item.Enzymes,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Oil",
    Callback = function()
        Craft(item.Oil,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Tropical Drink",
    Callback = function()
        Craft(item.TropicalDrink,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Glitter",
    Callback = function()
        Craft(item.Glitter,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Glue",
    Callback = function()
        Craft(item.Glue,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Gumdrop",
    Callback = function()
        Craft(item.Gumdrop,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Star Jelly",
    Callback = function()
        Craft(item.StarJelly,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Purple Potion",
    Callback = function()
        Craft(item.PurplePotion,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Purple Potion",
    Callback = function()
        Craft(item.PurplePotion,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Soft Wax",
    Callback = function()
        Craft(item.SoftWax,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Hard Wax",
    Callback = function()
        Craft(item.HardWax,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Swirled Wax",
    Callback = function()
        Craft(item.SwirledWax,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft CausticWax",
    Callback = function()
        Craft(item.CausticWax,countitem)
    end,
 })
local Button = Tab:CreateButton({
    Name = "Craft Field Dice",
    Callback = function()
        Craft(item.FieldDice,councountitemt)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Smooth Dice",
    Callback = function()
        Craft(item.SmoothDice,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft LoadedDice",
    Callback = function()
        Craft(item.LoadedDice,countitem)
    end,
 })
 local Button = Tab:CreateButton({
    Name = "Craft Super Smoothie",
    Callback = function()
        Craft(item.SuperSmoothie,countitem)
    end,
 })
 local OtherTab = Window:CreateTab("Other Hub", 4483362458) -- Title, Image
 local Button = OtherTab:CreateButton({
    Name = "Macrov2",
    Callback = function()
        loadstring(game:HttpGet("https://www.macrov2-script.xyz/macrov2.lua"))()
    end,
 })
 local Button = OtherTab:CreateButton({
    Name = "Starlight Free",
    Callback = function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/68546fbccd3694a8996b434dea8597ff.lua"))()
    end,
 })

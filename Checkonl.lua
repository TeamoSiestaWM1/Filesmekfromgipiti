
-- [THIẾT LẬP TỐI ƯU HỆ THỐNG]
settings().Rendering.QualityLevel = "Level01"
UserSettings().GameSettings.MasterVolume = 0

local s = UserSettings():GetService("UserGameSettings")
pcall(function() s.ReducedMotion = true end)
pcall(function() s.ReduceMotion = true end)
pcall(function() s.CameraShakesEnabled = false end)
pcall(function() s.UiAnimationSpeed = 0 end)

-- [KHỞI TẠO DỊCH VỤ]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--================= PHẦN: KILL OLD UI (MỚI) =================--
-- Đoạn mã này sẽ quét qua PlayerGui và xóa bất kỳ UI nào có tên "OnlineIndexUI" cũ
local function KillOldUI()
    local existingUIs = PlayerGui:GetChildren()
    for i = 1, #existingUIs do
        local ui = existingUIs[i]
        if ui:IsA("ScreenGui") and ui.Name == "OnlineIndexUI" then
            ui:Destroy()
        end
    end
end
KillOldUI() -- Chạy hàm xóa trước khi tạo UI mới

--================= FONT (ĐỒNG BỘ) =================--

local BUNGEE_FONT = Font.new(
	"rbxassetid://12187365364",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

--================= TẠO GUI MỚI =================--

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OnlineIndexUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = PlayerGui

--================= LABEL FRAME (STYLE FPS) =================--

local labelFrame = Instance.new("Frame")
labelFrame.Name = "IndexFrame"
labelFrame.Size = UDim2.new(0, 180, 0, 25)
labelFrame.Position = UDim2.new(1, -200, 0, 105)
labelFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
labelFrame.BorderSizePixel = 0
labelFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = labelFrame

--================= LABEL HIỂN THỊ =================--

local label = Instance.new("TextLabel")
label.Name = "StatusLabel"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 120)
label.FontFace = BUNGEE_FONT
label.TextSize = 16
label.TextScaled = false
label.Text = "Online: 0"
label.Parent = labelFrame

--================= LOGIC XỬ LÝ FILE & USERNAME =================--

local filePath = "usernames.txt" -- Đường dẫn file trong Workspace
local fileIndex = nil

-- Kiểm tra và đọc file usernames.txt
if isfile(filePath) then
    local content = readfile(filePath)
    -- Tách dòng để tìm kiếm username của người chơi hiện tại
    local lines = string.split(content, "\n")
    for i, line in ipairs(lines) do
        -- Loại bỏ khoảng trắng thừa nếu có
        local cleanLine = string.gsub(line, "%s+", "")
        if cleanLine == player.Name then
            fileIndex = i
            break
        end
    end
end

-- [XỬ LÝ KẾT QUẢ]
if fileIndex ~= nil then
    -- Cập nhật Label với định dạng: [Username]: [Index]
    label.Text = player.Name .. ": " .. fileIndex

    -- Vòng lặp Ghi File Autorejoin (Chạy ngầm)
    local updateActive = true
    
    -- Lắng nghe lỗi game để ngừng cập nhật file nếu bị kick/crash
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        updateActive = false
    end)
    
    -- Chạy task spawn để không làm treo script chính
    task.spawn(function()
        while updateActive do
            -- Ghi thời gian hiện tại vào file autorejoin của riêng index này
            local fileName = "autorejoin" .. fileIndex .. ".txt"
            pcall(function()
                writefile(fileName, tostring(os.time()))
            end)
            task.wait(1)
        end
    end)
else
    -- Nếu không tìm thấy tên trong file
    label.Text = "Online: 0"
end

print(">>> OnlineIndexUI Loaded | Old UI Killed Successfully <<<")

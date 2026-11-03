-- Delta Executor | Instant Auto Collect World Lock
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- SETTING: Ganti nama di bawah kalau nama asli item di game bukan "World Lock"
local ITEM_NAME = "World Lock" 

local running = true

-- ==========================================
-- UI PANEL
-- ==========================================
local oldGui = CoreGui:FindFirstChild("WorldLockUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WorldLockUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 80)
MainFrame.Position = UDim2.new(0, 20, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Instant Collect: " .. ITEM_NAME
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "STATUS: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        ToggleBtn.Text = "STATUS: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleBtn.Text = "STATUS: OFF"
    end
end)

-- ==========================================
-- LOGIKA AUTO COLLECT
-- ==========================================
local function teleportAndTouch(targetPart, hrp)
    -- Simpan posisi asli (opsional, kalau mau balik lagi)
    -- local oldPos = hrp.CFrame
    
    -- Teleport instan ke posisi item
    hrp.CFrame = targetPart.CFrame
    
    -- Paksa sentuhan (FireTouchInterest) bolak-balik
    pcall(function()
        firetouchinterest(hrp, targetPart, 0)
        task.wait(0.05)
        firetouchinterest(hrp, targetPart, 1)
    end)
end

local function scanLoop()
    while task.wait(0.1) do
        if not running then continue end
        
        local char = LocalPlayer.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Cari item di seluruh Workspace
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == ITEM_NAME then
                -- Jangan collect punya sendiri
                if not obj:IsDescendantOf(char) then
                    teleportAndTouch(obj, hrp)
                    -- Cukup satu per satu biar gak kena kick anti-cheat
                    task.wait(0.1) 
                    break 
                end
            end
        end
    end
end

task.spawn(scanLoop)

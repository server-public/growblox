-- Delta Executor | Universal Auto Collect World Lock (Force)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ITEM_NAME = "World Lock" 
local running = true

-- UI Panel
local oldGui = CoreGui:FindFirstChild("WorldLockUI")
if oldGui then oldGui:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WorldLockUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 85)
MainFrame.Position = UDim2.new(0, 20, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Force Collect: " .. ITEM_NAME
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "STATUS: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local isDragging = false
ToggleBtn.MouseButton1Down:Connect(function() isDragging = false end)
ToggleBtn.MouseButton1Click:Connect(function()
    if isDragging then return end
    running = not running
    ToggleBtn.BackgroundColor3 = running and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    ToggleBtn.Text = running and "STATUS: ON" or "STATUS: OFF"
end)

-- Logika Deteksi & Eksekusi
local function processObject(obj)
    if not obj or not obj:IsA("BasePart") then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    -- 1. Cek jarak (kalau jauh, teleport)
    if (hrp.Position - obj.Position).Magnitude > 15 then
        hrp.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.1)
    end

    -- 2. Paksa Klik (ClickDetector)
    local cd = obj:FindFirstChildOfClass("ClickDetector") or obj.Parent:FindFirstChildOfClass("ClickDetector")
    if cd then
        pcall(function() fireclickdetector(cd) end)
    end

    -- 3. Paksa Pencet E (ProximityPrompt)
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
    end

    -- 4. Paksa Sentuh (TouchInterest)
    local touch = obj:FindFirstChildOfClass("TouchTransmitter")
    if touch then
        pcall(function()
            firetouchinterest(hrp, obj, 0)
            task.wait(0.05)
            firetouchinterest(hrp, obj, 1)
        end)
    end
end

local function scanLoop()
    while task.wait(0.15) do
        if not running then continue end
        
        -- Scan isi workspace
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("BasePart") and obj.Name == ITEM_NAME) or (obj:IsA("Model") and obj.Name == ITEM_NAME) then
                local targetPart = obj:IsA("Model") and obj.PrimaryPart or obj
                if not targetPart then
                    targetPart = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or nil
                end
                
                if targetPart and not obj:IsDescendantOf(LocalPlayer.Character) then
                    processObject(targetPart)
                    task.wait(0.1) -- jeda biar gak kena kick anti-cheat
                    break
                end
            end
        end
    end
end

task.spawn(scanLoop)

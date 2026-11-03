-- Delta Executor | Noclip + Touch Auto Collect
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ITEM_NAME = "World Lock" 
local running = true
local noclipEnabled = true

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
MainFrame.Size = UDim2.new(0, 220, 0, 115)
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
Title.Text = "Noclip Collect: " .. ITEM_NAME
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.075, 0, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "AUTO COLLECT: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.85, 0, 0, 30)
NoclipBtn.Position = UDim2.new(0.075, 0, 0, 75)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
NoclipBtn.Text = "NOCLIP: ON"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 12
NoclipBtn.Parent = MainFrame
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 6)

-- Fungsi klik tombol (anti-drag)
local function bindBtn(btn, callback)
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = false end)
    btn.MouseButton1Click:Connect(function()
        if not dragging then callback() end
    end)
end

bindBtn(ToggleBtn, function()
    running = not running
    ToggleBtn.BackgroundColor3 = running and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    ToggleBtn.Text = running and "AUTO COLLECT: ON" or "AUTO COLLECT: OFF"
end)

bindBtn(NoclipBtn, function()
    noclipEnabled = not noclipEnabled
    NoclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(40, 100, 200) or Color3.fromRGB(180, 40, 40)
    NoclipBtn.Text = noclipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
end)

-- ==========================================
-- LOGIKA NOCLIP
-- ==========================================
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- LOGIKA AUTO COLLECT
-- ==========================================
local function processObject(obj)
    if not obj or not obj:IsA("BasePart") then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Visualizer: Bikin bola biru transparan di posisi item
    if not obj:FindFirstChild("WL_Visualizer") then
        local vis = Instance.new("Part")
        vis.Name = "WL_Visualizer"
        vis.Shape = Enum.PartType.Ball
        vis.Size = Vector3.new(2, 2, 2)
        vis.Color = Color3.fromRGB(0, 255, 255)
        vis.Material = Enum.Material.Neon
        vis.CanCollide = false
        vis.Anchored = true
        vis.Transparency = 0.5
        vis.CFrame = obj.CFrame
        vis.Parent = obj
    end

    -- Teleport instan ke posisi item (tembus dinding karena noclip)
    hrp.CFrame = obj.CFrame

    -- Maksa sentuhan bolak-balik
    pcall(function()
        firetouchinterest(hrp, obj, 0)
        task.wait(0.1)
        firetouchinterest(hrp, obj, 1)
    end)
    
    -- Coba pencet ClickDetector / ProximityPrompt kalau ada
    local cd = obj:FindFirstChildOfClass("ClickDetector") or obj.Parent:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(function() fireclickdetector(cd) end) end
    
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
    if prompt then pcall(function() fireproximityprompt(prompt) end) end
end

local function scanLoop()
    while task.wait(0.2) do
        if not running then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == ITEM_NAME then
                if not obj:IsDescendantOf(char) then
                    processObject(obj)
                    task.wait(0.15) -- Jeda antar collect
                    break 
                end
            end
        end
    end
end

task.spawn(scanLoop)

-- Delta Executor | Auto Punch & Noclip World Lock
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local ITEM_NAME = "World Lock" 
local running = true
local noclipEnabled = true

-- UI Panel
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
Title.Text = "Auto Punch: " .. ITEM_NAME
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.075, 0, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "AUTO PUNCH: ON"
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

local function bindBtn(btn, callback)
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = false end)
    btn.MouseButton1Click:Connect(function() if not dragging then callback() end end)
end

bindBtn(ToggleBtn, function()
    running = not running
    ToggleBtn.BackgroundColor3 = running and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    ToggleBtn.Text = running and "AUTO PUNCH: ON" or "AUTO PUNCH: OFF"
end)

bindBtn(NoclipBtn, function()
    noclipEnabled = not noclipEnabled
    NoclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(40, 100, 200) or Color3.fromRGB(180, 40, 40)
    NoclipBtn.Text = noclipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
end)

-- Noclip
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

-- Paksa Klik Kiri (Simulasi Pukulan)
local function forcePunch()
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

local function processObject(obj)
    if not obj or not obj:IsA("BasePart") then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Visualizer
    if not obj:FindFirstChild("WL_Visualizer") then
        local vis = Instance.new("Part")
        vis.Name = "WL_Visualizer"
        vis.Shape = Enum.PartType.Ball
        vis.Size = Vector3.new(3, 3, 3)
        vis.Color = Color3.fromRGB(0, 255, 255)
        vis.Material = Enum.Material.Neon
        vis.CanCollide = false
        vis.Anchored = true
        vis.Transparency = 0.5
        vis.CFrame = obj.CFrame
        vis.Parent = obj
    end

    -- Teleport menghadap ke block
    if (hrp.Position - obj.Position).Magnitude > 5 then
        hrp.CFrame = obj.CFrame * CFrame.new(0, 0, -3) -- Berdiri 3 stud di depan block
        task.wait(0.1)
    end

    -- Arahkan kamera ke block (wajib biar pukulan kena)
    local camera = Workspace.CurrentCamera
    camera.CFrame = CFrame.new(hrp.Position, obj.Position)

    -- Pukul terus menerus
    forcePunch()
    
    -- Fallback kalau game pakai ClickDetector atau ProximityPrompt
    local cd = obj:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(function() fireclickdetector(cd) end) end
    
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
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
                    break 
                end
            end
        end
    end
end

task.spawn(scanLoop)

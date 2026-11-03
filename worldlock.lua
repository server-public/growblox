-- Delta Executor | Auto Collect World Lock + GUI Panel
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    SCAN_INTERVAL = 0.35,
    TOUCH_RADIUS = 6,
    ITEM_NAME = "World Lock",
}

local activeTargets = {}
local targetIndex = 1
local running = true

local function getCharacterParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return nil, nil end
    return hrp, humanoid
end

local function isWorldLock(instance)
    if not instance or not instance:IsA("BasePart") then return false end
    if instance.Name ~= CONFIG.ITEM_NAME then return false end
    if LocalPlayer.Character and instance:IsDescendantOf(LocalPlayer.Character) then return false end
    return true
end

local function collectExisting()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isWorldLock(obj) then activeTargets[obj] = true end
    end
end

local function watchNewDrops()
    Workspace.DescendantAdded:Connect(function(descendant)
        if isWorldLock(descendant) then activeTargets[descendant] = true end
    end)
end

local function pruneTargets()
    for part in pairs(activeTargets) do
        if not part or not part.Parent or not isWorldLock(part) then
            activeTargets[part] = nil
        end
    end
end

local function getNextTarget()
    local keys = {}
    for part in pairs(activeTargets) do table.insert(keys, part) end
    if #keys == 0 then return nil end
    if targetIndex > #keys then targetIndex = 1 end
    local target = keys[targetIndex]
    targetIndex = targetIndex + 1
    return target
end

local function moveToward(target, hrp, humanoid)
    if not target or not target.Parent then return end
    local distance = (target.Position - hrp.Position).Magnitude
    if distance <= CONFIG.TOUCH_RADIUS then
        pcall(function()
            firetouchinterest(hrp, target, 0)
            task.wait(0.05)
            firetouchinterest(hrp, target, 1)
        end)
        return
    end
    local direction = (target.Position - hrp.Position).Unit
    humanoid:Move(direction, false)
    task.wait(CONFIG.SCAN_INTERVAL / 2)
    humanoid:Move(Vector3.zero, false)
end

local function loop()
    collectExisting()
    watchNewDrops()

    while true do
        if running then
            pruneTargets()
            local hrp, humanoid = getCharacterParts()
            if hrp and humanoid then
                local target = getNextTarget()
                if target then moveToward(target, hrp, humanoid) end
            end
        end
        task.wait(CONFIG.SCAN_INTERVAL)
    end
end

task.spawn(loop)

-- ==========================================
-- UI PANEL CREATION
-- ==========================================
local oldGui = CoreGui:FindFirstChild("WorldLockUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WorldLockUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 80)
MainFrame.Position = UDim2.new(0, 20, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
Title.Text = "Auto World Lock"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
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
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 180, 80)}):Play()
        ToggleBtn.Text = "STATUS: ON"
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 40, 40)}):Play()
        ToggleBtn.Text = "STATUS: OFF"
    end
end)

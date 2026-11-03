-- Delta Executor | Auto Collect World Lock
-- Memantau workspace untuk item bernama "World Lock" yang di-drop pemain lain.
-- Mendekat ke item, menyentuhnya, lalu lanjut ke item berikutnya.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    SCAN_INTERVAL = 0.35,
    TOUCH_RADIUS = 6,
    MOVE_SPEED = 120,
    ITEM_NAME = "World Lock",
    MAX_ACTIVE_TARGETS = 8,
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
    if not instance then return false end
    if not instance:IsA("BasePart") then return false end
    if instance.Name ~= CONFIG.ITEM_NAME then return false end
    if instance:IsDescendantOf(LocalPlayer.Character) then return false end
    return true
end

local function collectExisting()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isWorldLock(obj) then
            activeTargets[obj] = true
        end
    end
end

local function watchNewDrops()
    Workspace.DescendantAdded:Connect(function(descendant)
        if isWorldLock(descendant) then
            activeTargets[descendant] = true
        end
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
    for part in pairs(activeTargets) do
        table.insert(keys, part)
    end
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
        firetouchinterest(hrp, target, 0)
        task.wait(0.05)
        firetouchinterest(hrp, target, 1)
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

    while running do
        pruneTargets()
        local hrp, humanoid = getCharacterParts()
        if hrp and humanoid then
            local target = getNextTarget()
            if target then
                moveToward(target, hrp, humanoid)
            end
        end
        task.wait(CONFIG.SCAN_INTERVAL)
    end
end

task.spawn(loop)

-- Stop function kalau mau dimatikan dari console:
-- running = false

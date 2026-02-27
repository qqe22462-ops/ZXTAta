-- [[ WARUN-STYLE THAI VERSION ]]
-- 1. เปิด/ปิด การมองเห็น (บน)
-- 2. ตีไข่ทั้งหมด (กลาง)
-- 3. เสกบล็อกโชคดี (ล่าง)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local espEnabled = false

---------------------------------------------------------
-- [ ระบบ 1: ESP มองเห็นผู้เล่น (สีขาว) ]
---------------------------------------------------------
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if char:FindFirstChild("ESPHighlight") then
                char.ESPHighlight.Enabled = espEnabled
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("ESPNameTag") then
                root.ESPNameTag.Enabled = espEnabled
            end
        end
    end
end

local function applyESP(player)
    local function setup(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not rootPart then return end

        local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = espEnabled

        if not rootPart:FindFirstChild("ESPNameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPNameTag"
            billboard.Parent = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.Enabled = espEnabled

            local label = Instance.new("TextLabel")
            label.Parent = billboard
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = player.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0.2
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
        end
    end
    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then applyESP(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then applyESP(player) end
end)

---------------------------------------------------------
-- [ สร้างปุ่มเมนู (ภาษาไทย) ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarunThaiHub"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local function createBtn(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = screenGui
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = (color == Color3.new(1,1,1)) and Color3.new(0,0,0) or Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    return btn
end

-- 1. ปุ่ม ESP (บนสุด)
local espBtn = createBtn("ESPToggle", "เปิดมองเห็น: ปิดอยู่", UDim2.new(1, -200, 0.5, -80), Color3.fromRGB(255, 50, 50))

-- 2. ปุ่มตีไข่ (กลาง)
local eggBtn = createBtn("EggBtn", "ตีไข่ทั้งหมดอัตโนมัติ", UDim2.new(1, -200, 0.5, -25), Color3.fromRGB(80, 80, 255))

-- 3. ปุ่มเสกบล็อก (ล่างสุด)
local spawnBtn = createBtn("SpawnBtn", "เสก Lucky Block", UDim2.new(1, -200, 0.5, 30), Color3.new(1, 1, 1))

---------------------------------------------------------
-- [ การทำงานของแต่ละปุ่ม ]
---------------------------------------------------------

-- คลิกเปิด/ปิดมองเห็น
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "เปิดมองเห็น: เปิดอยู่" or "เปิดมองเห็น: ปิดอยู่"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    updateESP()
end)

-- คลิกตีไข่
eggBtn.MouseButton1Click:Connect(function()
    local knitPath = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit")
    if knitPath then
        local eggRemote = knitPath:WaitForChild("Services"):WaitForChild("EggSpawnerService"):WaitForChild("RF"):WaitForChild("RequestHitEgg")
        
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj:FindFirstChild("ID")) then
                local eggID = obj:FindFirstChild("ID") and obj.ID.Value or obj.Name
                task.spawn(function()
                    eggRemote:InvokeServer({{"RenderModel", eggID}})
                end)
            end
        end
        eggBtn.Text = "กำลังตีไข่รัวๆ! ⚡"
        task.wait(1)
        eggBtn.Text = "ตีไข่ทั้งหมดอัตโนมัติ"
    else
        eggBtn.Text = "❌ ไม่พบระบบตีไข่"
    end
end)

-- คลิกเสกของ
spawnBtn.MouseButton1Click:Connect(function()
    local remote = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if remote then
        remote:FireServer()
        spawnBtn.Text = "✅ เสกสำเร็จ!"
        task.wait(0.5)
        spawnBtn.Text = "เสก Lucky Block"
    else
        spawnBtn.Text = "❌ เสกไม่ได้ (ไม่พบ Remote)"
    end
end)

print("--- [Warun Thai Hub] โหลดเสร็จสิ้นแล้ว! ---")

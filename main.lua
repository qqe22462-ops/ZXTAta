-- [[ TWO-BUTTONS SYSTEM: ESP TOGGLE & LUCKY SPAWNER ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local espEnabled = false -- สถานะเริ่มต้นของ ESP

---------------------------------------------------------
-- 1. ระบบ ESP (ฟังก์ชันเหมือนเดิม)
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
-- 2. สร้าง GUI (มี 2 ปุ่มเรียงกัน)
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarunStyleGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- ฟังก์ชันช่วยสร้างปุ่มให้หน้าตาเหมือนกัน
local function createButton(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = screenGui
    btn.Size = UDim2.new(0, 160, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    return btn
end

-- ปุ่มบน: ESP Toggle (สีแดง/เขียว)
local espBtn = createButton("ESPToggle", "ESP: OFF", UDim2.new(1, -180, 0.5, -60), Color3.fromRGB(255, 50, 50))

-- ปุ่มล่าง: Spawn Lucky Block (สีขาว)
local spawnBtn = createButton("SpawnButton", "Spawn Lucky Block", UDim2.new(1, -180, 0.5, 5), Color3.fromRGB(255, 255, 255))
spawnBtn.TextColor3 = Color3.new(0, 0, 0)

---------------------------------------------------------
-- 3. การทำงานของปุ่ม
---------------------------------------------------------

-- คลิกเปิด/ปิด ESP
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
    updateESP()
end)

-- คลิกเสกของ
spawnBtn.MouseButton1Click:Connect(function()
    local remote = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if remote then
        remote:FireServer()
        spawnBtn.Text = "✅ Success!"
        task.wait(0.5)
        spawnBtn.Text = "Spawn Lucky Block"
    else
        spawnBtn.Text = "❌ No Remote"
        task.wait(1)
        spawnBtn.Text = "Spawn Lucky Block"
    end
end)

print("--- Two-Button Script Loaded Successfully ---")

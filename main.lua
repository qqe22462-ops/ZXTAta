-- [[ WARUN-STYLE MULTI-FUNCTION SCRIPT ]]
-- รวม ESP สีขาว + ปุ่มเสก Lucky Block ฝั่งขวา

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- 1. ฟังก์ชัน ESP (มองเห็นตัวสีขาว + ชื่อสีขาว)
---------------------------------------------------------
local function applyWhiteESP(player)
    local function setupVisuals(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not rootPart then return end

        -- สร้าง Highlight (ตัวสีขาวทะลุกำแพง)
        local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(200, 200, 200)
        highlight.FillTransparency = 0.4
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        -- สร้าง Name Tag (ชื่อสีขาว)
        if not rootPart:FindFirstChild("ESPNameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPNameTag"
            billboard.Parent = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)

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

    if player.Character then setupVisuals(player.Character) end
    player.CharacterAdded:Connect(setupVisuals)
end

-- รัน ESP ให้ทุกคน
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then applyWhiteESP(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then applyWhiteESP(player) end
end)

---------------------------------------------------------
-- 2. ฟังก์ชันปุ่มกดเสก Lucky Block (ฝั่งขวา)
---------------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyToolsGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local spawnButton = Instance.new("TextButton")
spawnButton.Name = "SpawnButton"
spawnButton.Parent = screenGui
spawnButton.Size = UDim2.new(0, 160, 0, 50)
spawnButton.Position = UDim2.new(1, -180, 0.5, -25) -- ฝั่งขวาตรงกลาง
spawnButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- ปุ่มสีขาวเพื่อให้เข้ากับ ESP
spawnButton.Text = "Spawn Lucky Block"
spawnButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- ตัวหนังสือดำให้ตัดกับปุ่มขาว
spawnButton.Font = Enum.Font.SourceSansBold
spawnButton.TextSize = 16

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = spawnButton

-- คลิกปุ่มแล้วส่งคำสั่ง
spawnButton.MouseButton1Click:Connect(function()
    local remote = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if remote then
        remote:FireServer()
        -- เอฟเฟกต์ปุ่มเมื่อกดสำเร็จ
        spawnButton.Text = "✅ Success!"
        spawnButton.BackgroundColor3 = Color3.fromRGB(150, 255, 150)
        task.wait(0.5)
        spawnButton.Text = "Spawn Lucky Block"
        spawnButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        spawnButton.Text = "❌ Remote Not Found"
        spawnButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1)
        spawnButton.Text = "Spawn Lucky Block"
        spawnButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

print("--- Script Loaded Successfully ---")

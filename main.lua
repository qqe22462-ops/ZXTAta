-- [[ WARUN THAI HUB: DRAGGABLE MENU VERSION ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local espEnabled = false
local menuVisible = false

---------------------------------------------------------
-- [ ระบบ ESP มองเห็นสีขาว ]
---------------------------------------------------------
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if char:FindFirstChild("ESPHighlight") then char.ESPHighlight.Enabled = espEnabled end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("ESPNameTag") then root.ESPNameTag.Enabled = espEnabled end
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

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then applyESP(player) end end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then applyESP(player) end end)

---------------------------------------------------------
-- [ สร้าง GUI และปุ่มลากได้ ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarunDraggableHub"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- 1. สร้างปุ่มหลัก (ปุ่มที่ลากได้)
local mainButton = Instance.new("TextButton")
mainButton.Name = "MainButton"
mainButton.Parent = screenGui
mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Text = "W" -- ย่อมาจาก Warun
mainButton.TextColor3 = Color3.new(0,0,0)
mainButton.Font = Enum.Font.SourceSansBold
mainButton.TextSize = 30
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0) -- ปุ่มวงกลม

-- 2. สร้างเฟรมเมนู (ที่จะโผล่ออกมา)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Parent = screenGui
menuFrame.Size = UDim2.new(0, 200, 0, 180)
menuFrame.Position = UDim2.new(0, 70, 0, 0) -- อยู่ข้างๆ ปุ่มหลัก
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false
menuFrame.Parent = mainButton -- ให้เมนูติดไปกับปุ่มหลักเวลาลาก
Instance.new("UICorner", menuFrame)

local layout = Instance.new("UIListLayout", menuFrame)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- ฟังก์ชันสร้างปุ่มในเมนู
local function createSubBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = (color == Color3.new(1,1,1)) and Color3.new(0,0,0) or Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = menuFrame
    Instance.new("UICorner", btn)
    return btn
end

local espBtn = createSubBtn("เปิดมองเห็น: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local eggBtn = createSubBtn("ตีไข่ทั้งหมดอัตโนมัติ", Color3.fromRGB(80, 80, 255))
local spawnBtn = createSubBtn("เสก Lucky Block", Color3.new(1, 1, 1))

---------------------------------------------------------
-- [ ระบบลากปุ่ม (Drag System) ]
---------------------------------------------------------
local dragging, dragInput, dragStart, startPos
mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainButton.Position
    end
end)
mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

---------------------------------------------------------
-- [ การทำงานของปุ่ม ]
---------------------------------------------------------
-- คลิกปุ่มหลักเพื่อ เปิด/ปิด เมนู
mainButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)

-- ปุ่มในเมนู
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "เปิดมองเห็น: เปิดอยู่" or "เปิดมองเห็น: ปิดอยู่"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    updateESP()
end)

eggBtn.MouseButton1Click:Connect(function()
    local knit = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit")
    if knit then
        local remote = knit.Services.EggSpawnerService.RF.RequestHitEgg
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj:FindFirstChild("ID")) then
                local id = obj:FindFirstChild("ID") and obj.ID.Value or obj.Name
                task.spawn(function() remote:InvokeServer({{"RenderModel", id}}) end)
            end
        end
        eggBtn.Text = "⚡ กำลังตี!" task.wait(0.5) eggBtn.Text = "ตีไข่ทั้งหมดอัตโนมัติ"
    else eggBtn.Text = "❌ ไม่พบระบบ" end
end)

spawnBtn.MouseButton1Click:Connect(function()
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer() spawnBtn.Text = "✅ สำเร็จ" task.wait(0.5) spawnBtn.Text = "เสก Lucky Block"
    else spawnBtn.Text = "❌ ไม่พบ Remote" end
end)

-- [[ WARUN THAI HUB: ESP & NOCLIP VERSION ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local espEnabled = false
local noclipEnabled = false
local menuVisible = false

---------------------------------------------------------
-- [ ระบบ 1: ESP มองเห็นสีขาว ]
---------------------------------------------------------
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("ESPHighlight")
            if highlight then highlight.Enabled = espEnabled end
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
        highlight.Enabled = espEnabled
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        if not rootPart:FindFirstChild("ESPNameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPNameTag"
            billboard.Parent = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Enabled = espEnabled
            local label = Instance.new("TextLabel")
            label.Parent = billboard
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = player.Name
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
        end
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then applyESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then applyESP(p) end end)

---------------------------------------------------------
-- [ ระบบ 2: เดินทะลุกำแพง (NoClip) ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

---------------------------------------------------------
-- [ สร้าง GUI ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarunNoclipHub"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
mainButton.Text = "W"
mainButton.Font = "SourceSansBold"
mainButton.TextSize = 30
mainButton.Parent = screenGui
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 200, 0, 180)
menuFrame.Position = UDim2.new(1, 10, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.Visible = false
menuFrame.Parent = mainButton
Instance.new("UICorner", menuFrame)

local layout = Instance.new("UIListLayout", menuFrame)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = "Center"
layout.VerticalAlignment = "Center"

local function createBtn(txt, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 180, 0, 40)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = (color == Color3.new(1,1,1)) and Color3.new(0,0,0) or Color3.new(1,1,1)
    b.Font = "SourceSansBold"
    b.TextSize = 16
    b.Parent = menuFrame
    Instance.new("UICorner", b)
    return b
end

local espBtn = createBtn("เปิดมองเห็น: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local noclipBtn = createBtn("ทะลุกำแพง: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local spawnBtn = createBtn("เสก Lucky Block", Color3.new(1, 1, 1))

---------------------------------------------------------
-- [ การทำงานของปุ่ม ]
---------------------------------------------------------

mainButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "เปิดมองเห็น: เปิดอยู่" or "เปิดมองเห็น: ปิดอยู่"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    updateESP()
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "ทะลุกำแพง: เปิดอยู่" or "ทะลุกำแพง: ปิดอยู่"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

spawnBtn.MouseButton1Click:Connect(function()
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer() end
end)

---------------------------------------------------------
-- [ ระบบลาก (Drag) ]
---------------------------------------------------------
local dragStart, startPos, dragging
mainButton.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = mainButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- [[ KRAISORN HUB V.13: SCROLLING MENU VERSION ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local menuVisible = false
local isStickyTP = false
local flySpeed = 30 

---------------------------------------------------------
-- [ ระบบ ESP (ฉบับเสถียร V.12) ]
---------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(character)
        if not character then return end
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not rootPart then return end
        if character:FindFirstChild("ESPHighlight") then character.ESPHighlight:Destroy() end
        local highlight = Instance.new("Highlight", character)
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.Enabled = espEnabled
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

---------------------------------------------------------
-- [ ระบบบิน & ทะลุกำแพง ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if (noclipEnabled or isStickyTP or flyEnabled) and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local bg, bv
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    bg = Instance.new("BodyGyro", root)
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv = Instance.new("BodyVelocity", root)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    char.Humanoid.PlatformStand = true
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            local camera = workspace.CurrentCamera
            bg.cframe = camera.CFrame
            if char.Humanoid.MoveDirection.Magnitude > 0 then
                bv.velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(
                    (UserInputService:IsKeyDown(Enum.KeyCode.D) and flySpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and flySpeed or 0),
                    0,
                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and flySpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and flySpeed or 0)
                ))
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
        end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        char.Humanoid.PlatformStand = false
    end)
end

---------------------------------------------------------
-- [ สร้าง GUI แบบเลื่อนได้ (Scrolling) ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KraisornScrollHub"
screenGui.ResetOnSpawn = false

local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
mainButton.Text = "W"
mainButton.Font = "SourceSansBold"
mainButton.TextSize = 30
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

-- เมนูหลัก (ล็อคความสูงไว้ที่ 200 หรือประมาณ 2 นิ้ว)
local menuFrame = Instance.new("Frame", mainButton)
menuFrame.Size = UDim2.new(0, 210, 0, 220) 
menuFrame.Position = UDim2.new(1, 10, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.Visible = false
menuFrame.ClipsDescendants = true
Instance.new("UICorner", menuFrame)

-- ส่วนที่ทำให้เลื่อนได้ (ScrollingFrame)
local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, -45) -- เว้นที่ให้ชื่อข้างบน
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 350) -- ขนาดพื้นที่ด้านในที่เลื่อนได้
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = "Center"

-- ชื่อสายรุ้ง ไกรสร พิสิษฐ์ 🫡 (อยู่กับที่ ไม่เลื่อนตามปุ่ม)
local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 45)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"
nameLabel.Font = "SourceSansBold"
nameLabel.TextSize = 20
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            nameLabel.TextColor3 = Color3.fromHSV(i, 0.8, 1)
            task.wait()
        end
    end
end)

---------------------------------------------------------
-- [ ฟังก์ชันสร้างปุ่มใน Scroll ]
---------------------------------------------------------
local function createBtn(txt, color)
    local b = Instance.new("TextButton", scrollFrame)
    b.Size = UDim2.new(0, 180, 0, 40)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = "SourceSansBold"
    Instance.new("UICorner", b)
    return b
end

local espBtn = createBtn("เปิดมองเห็น: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local flyBtn = createBtn("ระบบบิน: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local speedBtn = createBtn("ความเร็วบิน: " .. flySpeed, Color3.fromRGB(100, 100, 255))
local noclipBtn = createBtn("ทะลุกำแพง: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local tpBtn = createBtn("สิงร่างคนใกล้ (1 วิ)", Color3.fromRGB(255, 170, 0))
local spawnBtn = createBtn("เสก Lucky Block", Color3.new(1, 1, 1))

-- การทำงานปุ่ม
mainButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "เปิดมองเห็น: เปิดอยู่" or "เปิดมองเห็น: ปิดอยู่"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    -- อัปเดต ESP ทันที
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESPHighlight") then
            p.Character.ESPHighlight.Enabled = espEnabled
        end
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "ระบบบิน: เปิดอยู่" or "ระบบบิน: ปิดอยู่"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    if flyEnabled then startFly() end
end)

speedBtn.MouseButton1Click:Connect(function()
    flySpeed = (flySpeed >= 60) and 10 or flySpeed + 10
    speedBtn.Text = "ความเร็วบิน: " .. flySpeed
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "ทะลุกำแพง: เปิดอยู่" or "ทะลุกำแพง: ปิดอยู่"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

tpBtn.MouseButton1Click:Connect(function()
    -- ระบบสิงร่าง 1 วิ (โค้ดเดิม)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = character.HumanoidRootPart
    local originalPos = myRoot.CFrame
    local targetRoot = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then shortestDistance = dist; targetRoot = player.Character.HumanoidRootPart end
        end
    end
    if targetRoot then
        isStickyTP = true
        local st = tick()
        while tick() - st < 1 do
            if targetRoot and myRoot then myRoot.CFrame = targetRoot.CFrame end
            RunService.RenderStepped:Wait()
        end
        isStickyTP = false
        myRoot.CFrame = originalPos
    end
end)

spawnBtn.MouseButton1Click:Connect(function()
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer() end
end)

-- ระบบลาก (Drag)
local dS, sP, dG
mainButton.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dG = true dS = i.Position sP = mainButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dG and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dS
        mainButton.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dG = false end end)

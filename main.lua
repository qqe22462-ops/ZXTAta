-- [[ WARUN THAI HUB: RAINBOW OWNER NAME VERSION ]]

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

---------------------------------------------------------
-- [ ระบบ 2: เดินทะลุกำแพง (NoClip) ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if (noclipEnabled or isStickyTP or flyEnabled) and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

---------------------------------------------------------
-- [ ระบบ 3: บินแบบ 360 องศา + ปรับความเร็ว ]
---------------------------------------------------------
local bg, bv
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local camera = workspace.CurrentCamera
    
    bg = Instance.new("BodyGyro", root)
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = root.CFrame
    bv = Instance.new("BodyVelocity", root)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    char.Humanoid.PlatformStand = true
    
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            local moveDir = char.Humanoid.MoveDirection
            bg.cframe = camera.CFrame
            
            if moveDir.Magnitude > 0 then
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
-- [ ระบบ 4: สิงร่าง 1 วินาที ]
---------------------------------------------------------
local function tpToNearestPlayer()
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
end

---------------------------------------------------------
-- [ สร้าง GUI (ขนาด 320 เพื่อรองรับชื่อ) ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KraisornHub"
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
menuFrame.Size = UDim2.new(0, 210, 0, 330) -- ปรับขนาดเพิ่มพื้นที่ให้ชื่อ
menuFrame.Position = UDim2.new(1, 10, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.Visible = false
menuFrame.Parent = mainButton
Instance.new("UICorner", menuFrame)

local layout = Instance.new("UIListLayout", menuFrame)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = "Center"
layout.VerticalAlignment = "Top" -- จัดให้เริ่มจากข้างบนสุด

-- [ ส่วนที่เพิ่มเข้ามา: ชื่อสายรุ้ง ]
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 190, 0, 45)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"
nameLabel.Font = "SourceSansBold"
nameLabel.TextSize = 22
nameLabel.Parent = menuFrame

-- ระบบเปลี่ยนสีสายรุ้ง (Rainbow Effect)
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            nameLabel.TextColor3 = Color3.fromHSV(i, 0.8, 1)
            task.wait()
        end
    end
end)

---------------------------------------------------------
-- [ ฟังก์ชันสร้างปุ่ม ]
---------------------------------------------------------
local function createBtn(txt, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 190, 0, 40)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = (color == Color3.new(1,1,1)) and Color3.new(0,0,0) or Color3.new(1,1,1)
    b.Font = "SourceSansBold"
    b.TextSize = 14
    b.Parent = menuFrame
    Instance.new("UICorner", b)
    return b
end

local espBtn = createBtn("เปิดมองเห็น: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local flyBtn = createBtn("ระบบบิน: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local speedBtn = createBtn("ความเร็วบิน: " .. flySpeed, Color3.fromRGB(100, 100, 255))
local noclipBtn = createBtn("ทะลุกำแพง: ปิดอยู่", Color3.fromRGB(255, 50, 50))
local tpBtn = createBtn("สิงร่างคนใกล้ (1 วิ)", Color3.fromRGB(255, 170, 0))
local spawnBtn = createBtn("เสก Lucky Block", Color3.new(1, 1, 1))

-- การทำงานปุ่ม (เหมือนเดิม)
mainButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "ระบบบิน: เปิดอยู่" or "ระบบบิน: ปิดอยู่"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    if flyEnabled then startFly() end
end)

speedBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
    if flySpeed > 60 then flySpeed = 10 end
    speedBtn.Text = "ความเร็วบิน: " .. flySpeed
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

tpBtn.MouseButton1Click:Connect(function()
    tpToNearestPlayer()
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
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dG = false end
end)

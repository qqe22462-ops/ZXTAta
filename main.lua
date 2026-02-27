-- [[ KRAISORN HUB V.16: FIXED FLY & NOCLIP + LUCKY BLOCK RETURN ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local speedEnabled = false
local infJumpEnabled = false
local flySpeed = 50 
local walkSpeedValue = 100

---------------------------------------------------------
-- [ ระบบบินใหม่: แบบ CFrame (ป้องกันจอดำ) ]
---------------------------------------------------------
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            local camera = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            
            -- ปิดแรงโน้มถ่วงชั่วคราวขณะบิน
            root.Velocity = Vector3.new(0, 0.1, 0) 
            
            if moveDir.Magnitude > 0 then
                local direction = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                
                if direction.Magnitude > 0 then
                    root.CFrame = root.CFrame + (direction.Unit * (flySpeed / 10))
                end
            end
        end
    end)
end

---------------------------------------------------------
-- [ ระบบทะลุ (NoClip) & เดินเร็ว & กระโดด ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
    end
end)

---------------------------------------------------------
-- [ ระบบ ESP ]
---------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(character)
        local highlight = Instance.new("Highlight", character)
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = espEnabled
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

---------------------------------------------------------
-- [ สร้าง GUI เมนูเลื่อนได้ ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KraisornV16"
screenGui.ResetOnSpawn = false

local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.1, 0, 0.4, 0)
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
mainButton.Text = "W"
mainButton.Font = "SourceSansBold"
mainButton.TextSize = 40
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainButton)
menuFrame.Size = UDim2.new(0, 240, 0, 280)
menuFrame.Position = UDim2.new(1, 15, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

-- ชื่อสายรุ้ง ไกรสร พิสิษฐ์ 🫡
local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 50)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"
nameLabel.Font = "SourceSansBold"
nameLabel.TextSize = 22
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            nameLabel.TextColor3 = Color3.fromHSV(i, 0.8, 1)
            task.wait()
        end
    end
end)

local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, -55)
scrollFrame.Position = UDim2.new(0, 0, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 480) 
scrollFrame.ScrollBarThickness = 5

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = "Center"

local function createBtn(txt, color)
    local b = Instance.new("TextButton", scrollFrame)
    b.Size = UDim2.new(0, 210, 0, 50)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(0, 0, 0) -- ตัวอักษรสีดำ
    b.Font = "SourceSansBold"
    b.TextSize = 22 -- ตัวอักษรใหญ่
    Instance.new("UICorner", b)
    return b
end

local flyBtn = createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 80, 80))
local noclipBtn = createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200))
local spawnBtn = createBtn("เสก Lucky Block", Color3.new(1, 1, 1)) -- คืนชีพฟังก์ชันนี้
local speedBtn = createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 200, 0))
local jumpBtn = createBtn("กระโดดไม่จำกัด: ปิด", Color3.fromRGB(0, 255, 255))
local espBtn = createBtn("มองเห็นผู้เล่น: ปิด", Color3.fromRGB(255, 255, 255))

mainButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 80, 80)
    if flyEnabled then startFly() end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(200, 200, 200)
end)

spawnBtn.MouseButton1Click:Connect(function()
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then 
        r:FireServer() 
        spawnBtn.Text = "✅ เสกสำเร็จ!"
        task.wait(1)
        spawnBtn.Text = "เสก Lucky Block"
    else
        spawnBtn.Text = "❌ ไม่พบระบบเสก"
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 200, 0)
end)

jumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    jumpBtn.Text = infJumpEnabled and "กระโดดไม่จำกัด: เปิด" or "กระโดดไม่จำกัด: ปิด"
    jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(0, 255, 255)
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "มองเห็นผู้เล่น: เปิด" or "มองเห็นผู้เล่น: ปิด"
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESPHighlight") then
            p.Character.ESPHighlight.Enabled = espEnabled
        end
    end
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

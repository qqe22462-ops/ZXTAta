-- [[ KRAISORN HUB V.15: BIG FONT + FLY FIX + SPEED + JUMP ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local speedEnabled = false
local infJumpEnabled = false
local menuVisible = false
local flySpeed = 50 
local walkSpeedValue = 100

---------------------------------------------------------
-- [ ระบบบิน: แก้ไขใหม่ให้ไม่ค้าง ]
---------------------------------------------------------
local bg, bv
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local camera = workspace.CurrentCamera
    
    bg = Instance.new("BodyGyro", root)
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv = Instance.new("BodyVelocity", root)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    char.Humanoid.PlatformStand = true
    
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            bg.cframe = camera.CFrame
            local moveDir = char.Humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                -- คำนวณทิศทางบินตามการกดปุ่มและมุมกล้อง
                local direction = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                bv.velocity = direction.Unit * flySpeed
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
-- [ ระบบกระโดดไม่จำกัด & เดินเร็ว ]
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
    elseif not speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

---------------------------------------------------------
-- [ ระบบ ESP & NoClip ]
---------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if not root then return end
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
-- [ สร้าง GUI เมนูเลื่อนได้ ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KraisornV15"
screenGui.ResetOnSpawn = false

local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.1, 0, 0.4, 0)
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
mainButton.Text = "W"
mainButton.Font = "SourceSansBold"
mainButton.TextSize = 40 -- ตัว W ใหญ่ขึ้น
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainButton)
menuFrame.Size = UDim2.new(0, 240, 0, 280) -- ขยายเมนูให้กว้างขึ้นเล็กน้อย
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
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450) -- เพิ่มพื้นที่เลื่อน
scrollFrame.ScrollBarThickness = 5

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = "Center"

-- ฟังก์ชันสร้างปุ่ม (ตัวอักษรสีดำและตัวใหญ่)
local function createBtn(txt, color)
    local b = Instance.new("TextButton", scrollFrame)
    b.Size = UDim2.new(0, 210, 0, 50) -- ปุ่มใหญ่ขึ้น
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(0, 0, 0) -- ตัวอักษรสีดำ
    b.Font = "SourceSansBold"
    b.TextSize = 22 -- ตัวอักษรใหญ่ชัดเจน
    Instance.new("UICorner", b)
    return b
end

local speedBtn = createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 200, 0))
local jumpBtn = createBtn("กระโดดไม่จำกัด: ปิด", Color3.fromRGB(0, 255, 255))
local flyBtn = createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 80, 80))
local espBtn = createBtn("มองเห็นผู้เล่น: ปิด", Color3.fromRGB(255, 255, 255))
local noclipBtn = createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200))

mainButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

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

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 80, 80)
    if flyEnabled then startFly() end
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

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
end)

-- ระบบลากปุ่ม (Drag)
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

-- [[ KRAISORN HUB: COMPLETE & FINAL VERSION ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [ ตั้งค่าสถานะเริ่มต้น ]
local Toggle = {
    Fly = false,
    NoClip = false,
    Speed = false,
    InfJump = false,
    ESP = false
}
local flySpeed = 50
local walkSpeedValue = 100

---------------------------------------------------------
-- [ ฟังก์ชันระบบบิน (Anti-Black Screen) ]
---------------------------------------------------------
local function HandleFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0.1, 0)
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while Toggle.Fly do
            RunService.RenderStepped:Wait()
            bv.Parent = root
            bg.Parent = root
            bg.CFrame = workspace.CurrentCamera.CFrame
            hum.PlatformStand = true
            
            local dir = Vector3.new(0,0,0)
            local cam = workspace.CurrentCamera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
            
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
        end
        bv:Destroy()
        bg:Destroy()
        hum.PlatformStand = false
    end)
end

---------------------------------------------------------
-- [ ระบบ Loop ตรวจสอบสถานะ (NoClip / Speed / Jump) ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggle.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Toggle.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

---------------------------------------------------------
-- [ สร้าง GUI ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KraisornFinal"
screenGui.ResetOnSpawn = false

-- ปุ่มเปิด/ปิดหลัก
local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 70, 0, 70)
mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainBtn.Text = "W"
mainBtn.Font = "SourceSansBold"
mainBtn.TextSize = 40
mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

-- เฟรมเมนู
local menuFrame = Instance.new("Frame", mainBtn)
menuFrame.Size = UDim2.new(0, 260, 0, 300)
menuFrame.Position = UDim2.new(1, 20, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

-- ชื่อสายรุ้ง: ไกรสร พิสิษฐ์ 🫡
local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 60)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"
nameLabel.Font = "SourceSansBold"
nameLabel.TextSize = 25
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            nameLabel.TextColor3 = Color3.fromHSV(i, 0.8, 1)
            task.wait()
        end
    end
end)

-- ScrollingFrame สำหรับปุ่มต่างๆ
local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -65)
scroll.Position = UDim2.new(0, 0, 0, 65)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 400) -- พื้นที่เลื่อน
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = "Center"

-- ฟังก์ชันสร้างปุ่ม
local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(0, 230, 0, 50)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(0, 0, 0) -- ตัวหนังสือสีดำ
    b.Font = "SourceSansBold"
    b.TextSize = 24 -- ตัวหนังสือใหญ่
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    return b
end

---------------------------------------------------------
-- [ เพิ่มปุ่มฟังก์ชัน ]
---------------------------------------------------------

-- 1. ปุ่มเสก Lucky Block
createBtn("เสก Lucky Block", Color3.new(1, 1, 1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then 
        r:FireServer() 
        self.Text = "✅ เสกสำเร็จ!"
        task.wait(0.5)
        self.Text = "เสก Lucky Block"
    else
        self.Text = "❌ ไม่พบระบบ"
    end
end)

-- 2. ปุ่มระบบบิน
createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly
    self.Text = Toggle.Fly and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then HandleFly() end
end)

-- 3. ปุ่มทะลุกำแพง
createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200), function(self)
    Toggle.NoClip = not Toggle.NoClip
    self.Text = Toggle.NoClip and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    self.BackgroundColor3 = Toggle.NoClip and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 200, 200)
end)

-- 4. ปุ่มเดินเร็ว
createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed
    self.Text = Toggle.Speed and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)

-- 5. ปุ่มกระโดด INFINITY
createBtn("กระโดด INF: ปิด", Color3.fromRGB(100, 220, 255), function(self)
    Toggle.InfJump = not Toggle.InfJump
    self.Text = Toggle.InfJump and "กระโดด INF: เปิด" or "กระโดด INF: ปิด"
    self.BackgroundColor3 = Toggle.InfJump and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(100, 220, 255)
end)

-- [ ระบบเปิด/ปิดเมนู & ลากปุ่ม ]
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

local dragging, dragInput, dragStart, startPos
mainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

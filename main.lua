-- [[ ᴘɪꜱɪᴛ  𝟢𝟢𝟣ꜰʀᴇᴇ ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡
-- KEY: PISIT112

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CORRECT_KEY = "PISIT112"
local Toggle = { 
    Fly = false, NoClip = false, Speed = false, InfJump = false, 
    ESP = false, FullBright = false, VisibleLock = false, 
    AutoClick = false, AutoEat = false, CCTV = false
}
local flySpeed = 50
local walkSpeedValue = 100
local ClickPoints = {}

---------------------------------------------------------
-- [ New Fly System (จากสคริปต์ที่คุณต้องการ) ]
---------------------------------------------------------
local function HandleFly()
    local bg = Instance.new("BodyGyro")
    local bv = Instance.new("BodyVelocity")
    
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    task.spawn(function()
        while Toggle.Fly do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if root and hum then
                bg.Parent = root
                bv.Parent = root
                
                hum.PlatformStand = true
                bg.CFrame = Camera.CFrame
                
                local dir = Vector3.new(0, 0.1, 0)
                local camCFrame = Camera.CFrame
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    dir = dir + camCFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    dir = dir - camCFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + camCFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - camCFrame.RightVector
                end
                
                bv.Velocity = dir * flySpeed
            end
            RunService.RenderStepped:Wait()
        end
        -- Cleanup เมื่อปิด Fly
        bg:Destroy()
        bv:Destroy()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end)
end

---------------------------------------------------------
-- [ UI Construction ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "Pisit001FreeMenu"; screenGui.ResetOnSpawn = false

-- [[ หน้าต่างใส่คีย์ ]]
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 180); keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90); keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", keyFrame)

local closeKey = Instance.new("TextButton", keyFrame)
closeKey.Size = UDim2.new(0, 30, 0, 30); closeKey.Position = UDim2.new(1, -35, 0, 5); closeKey.Text = "X"; closeKey.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeKey.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeKey)
closeKey.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local keyTitle = Instance.new("TextLabel", keyFrame); keyTitle.Size = UDim2.new(1, 0, 0, 40); keyTitle.Text = "ᴘɪꜱɪᴛ  𝟢𝟢𝟣ꜰʀᴇᴇ"; keyTitle.TextColor3 = Color3.new(1,1,1); keyTitle.BackgroundTransparency = 1; keyTitle.Font = "SourceSansBold"; keyTitle.TextSize = 22
local keyInput = Instance.new("TextBox", keyFrame); keyInput.Size = UDim2.new(0, 240, 0, 40); keyInput.Position = UDim2.new(0.5, -120, 0.4, 0); keyInput.PlaceholderText = "กรอกรหัสคีย์..."; keyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); keyInput.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", keyInput)
local submitBtn = Instance.new("TextButton", keyFrame); submitBtn.Size = UDim2.new(0, 240, 0, 40); submitBtn.Position = UDim2.new(0.5, -120, 0.7, 0); submitBtn.Text = "ตรวจสอบ"; submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255); submitBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", submitBtn)

-- [[ เมนูหลัก ]]
local mainBtn = Instance.new("TextButton", screenGui); mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0); mainBtn.BackgroundColor3 = Color3.new(1,1,1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.Visible = false; Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)
local menuFrame = Instance.new("Frame", screenGui); menuFrame.Size = UDim2.new(0, 280, 0, 480); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0); menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)
local scroll = Instance.new("ScrollingFrame", menuFrame); scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1200); scroll.ScrollBarThickness = 3; Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.Font = "SourceSansBold"; b.TextSize = 16; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

submitBtn.MouseButton1Click:Connect(function() if keyInput.Text == CORRECT_KEY then keyFrame:Destroy(); mainBtn.Visible = true else submitBtn.Text = "คีย์ผิด!"; task.wait(1); submitBtn.Text = "ตรวจสอบ" end end)

---------------------------------------------------------
-- [ รายการปุ่มฟังก์ชัน ]
---------------------------------------------------------
createBtn("ระบบบิน (New Fly): ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly
    self.Text = Toggle.Fly and "ระบบบิน: เปิด (พริ้ว)" or "ระบบบิน (New Fly): ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then HandleFly() end
end)

createBtn("มุมกล้องแอบดู: ปิด", Color3.fromRGB(130, 130, 130), function(self)
    Toggle.CCTV = not Toggle.CCTV
    if Toggle.CCTV then
        self.Text = "มุมกล้องแอบดู: ล็อคหน้าจอ"; self.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        self.Text = "มุมกล้องแอบดู: ปิด"; self.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200), function(self)
    Toggle.NoClip = not Toggle.NoClip
    self.Text = Toggle.NoClip and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    self.BackgroundColor3 = Toggle.NoClip and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 200, 200)
end)

createBtn("ESP มองคน: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "ESP มองคน: เปิด" or "ESP มองคน: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
end)

createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed
    self.Text = Toggle.Speed and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)

-- [[ ปุ่มอื่นๆ จากสคริปต์เดิมของคุณ ]]
createBtn("กินอัตโนมัติ (Auto): ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.AutoEat = not Toggle.AutoEat
    self.Text = Toggle.AutoEat and "กินอัตโนมัติ: เปิด" or "กินอัตโนมัติ (Auto): ปิด"
    self.BackgroundColor3 = Toggle.AutoEat and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)

---------------------------------------------------------
-- [ Loops & Events ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then 
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end 
    end
    if Toggle.ESP then 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer and p.Character then 
                local h = p.Character:FindFirstChild("PisitESP") or Instance.new("Highlight", p.Character)
                h.Name = "PisitESP"; h.FillColor = Color3.new(1,1,1); h.Enabled = true 
            end 
        end 
    end
end)

RunService.Heartbeat:Connect(function() 
    if Toggle.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue 
    end 
end)

-- [ ลากเมนู ]
local dragging, dragStart, startPos
mainBtn.MouseButton1Click:Connect(function() 
    menuFrame.Visible = not menuFrame.Visible
    menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset)
end)
mainBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging then local delta = input.Position - dragStart; mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y); if menuFrame.Visible then menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset) end end end)
UserInputService.InputEnded:Connect(function() dragging = false end)

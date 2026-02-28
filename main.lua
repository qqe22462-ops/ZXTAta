-- [[ KRAISORN HUB V.30: THE FINAL COMPLETE VERSION ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡 (รวมทุกอย่างที่เคยมี ไม่หายแน่นอน!)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ State Configuration ]
local Toggle = { 
    Fly = false, 
    NoClip = false, 
    Speed = false, 
    InfJump = false, 
    ESP = false, 
    FullBright = false, 
    VisibleLock = false 
}
local flySpeed, walkSpeedValue = 50, 100

---------------------------------------------------------
-- [ Core Functions ]
---------------------------------------------------------

-- 1. วาร์ป 0.6s (กดทีเดียวจบ)
local function TriggerFlashWarp(btn)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetRoot = nil
    local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then shortestDist = dist; targetRoot = p.Character.HumanoidRootPart end
        end
    end
    if targetRoot then
        btn.Text = "⚡ วาร์ปอยู่..."; btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        local originalPos = root.CFrame
        local startTime = tick()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if tick() - startTime < 0.6 and targetRoot and targetRoot.Parent then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
            else
                root.CFrame = originalPos
                connection:Disconnect()
                btn.Text = "วาร์ป 0.6s (Flash)"; btn.BackgroundColor3 = Color3.fromRGB(255, 80, 255)
            end
        end)
    end
end

-- 2. ระบบบิน
local function HandleFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local bv = Instance.new("BodyVelocity", root)
    local bg = Instance.new("BodyGyro", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        while Toggle.Fly do
            RunService.RenderStepped:Wait()
            bg.CFrame = Camera.CFrame
            hum.PlatformStand = true
            local dir = Vector3.new(0,0,0); local cam = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0, 0.1, 0)
        end
        bv:Destroy(); bg:Destroy(); hum.PlatformStand = false
    end)
end

-- 3. ESP
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("KraisornESP") or Instance.new("Highlight", p.Character)
            highlight.Name = "KraisornESP"; highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.Enabled = Toggle.ESP; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-- [ Main Loops ]
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Toggle.ESP then updateESP() end
    if Toggle.FullBright then
        Lighting.ClockTime = 14; Lighting.Brightness = 3; Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255); Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.GlobalShadows = false
    end
    if Toggle.VisibleLock and LocalPlayer.Character then
        local target = nil; local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local r = p.Character.HumanoidRootPart
                local _, onScreen = Camera:WorldToViewportPoint(r.Position)
                if onScreen then
                    local mag = (r.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if mag < dist then dist = mag; target = r end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggle.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue end
end)

UserInputService.JumpRequest:Connect(function()
    if Toggle.InfJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

---------------------------------------------------------
-- [ GUI Construction ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KraisornFinal"; screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1, 1, 1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 280, 0, 420); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)

local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 60); nameLabel.BackgroundTransparency = 1; nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"; nameLabel.Font = "SourceSansBold"; nameLabel.TextSize = 25
task.spawn(function() while true do for i=0,1,0.005 do nameLabel.TextColor3 = Color3.fromHSV(i,0.8,1) task.wait() end end end)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -70); scroll.Position = UDim2.new(0, 0, 0, 70)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1000); scroll.ScrollBarThickness = 4
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 45); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(0,0,0); b.Font = "SourceSansBold"; b.TextSize = 18; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
end

-- [[ ปุ่มทั้งหมด เรียงตามนี้ครับ ]]
createBtn("เสก Lucky Block", Color3.new(1, 1, 1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ เสกแล้ว"; task.wait(0.5); self.Text = "เสก Lucky Block" end
end)

createBtn("วาร์ป 0.6s (Flash)", Color3.fromRGB(255, 80, 255), function(self)
    TriggerFlashWarp(self)
end)

createBtn("ล็อคเป้าหน้าจอ: ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock
    self.Text = Toggle.VisibleLock and "ล็อคเป้าหน้าจอ: เปิด" or "ล็อคเป้าหน้าจอ: ปิด"
    self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)

createBtn("ตาแมวสว่าง: ปิด", Color3.fromRGB(255, 255, 0), function(self)
    Toggle.FullBright = not Toggle.FullBright
    self.Text = Toggle.FullBright and "ตาแมวสว่าง: เปิด" or "ตาแมวสว่าง: ปิด"
    self.BackgroundColor3 = Toggle.FullBright and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 0)
end)

createBtn("ESP มองคน: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "ESP มองคน: เปิด" or "ESP มองคน: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
end)

createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly
    self.Text = Toggle.Fly and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then HandleFly() end
end)

createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200), function(self)
    Toggle.NoClip = not Toggle.NoClip
    self.Text = Toggle.NoClip and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    self.BackgroundColor3 = Toggle.NoClip and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 200, 200)
end)

createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed
    self.Text = Toggle.Speed and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)

createBtn("กระโดด INF: ปิด", Color3.fromRGB(100, 220, 255), function(self)
    Toggle.InfJump = not Toggle.InfJump
    self.Text = Toggle.InfJump and "กระโดด INF: เปิด" or "กระโดด INF: ปิด"
    self.BackgroundColor3 = Toggle.InfJump and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(100, 220, 255)
end)

-- [ Drag & Menu Toggle ]
mainBtn.MouseButton1Click:Connect(function() 
    menuFrame.Visible = not menuFrame.Visible 
    menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 90, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset)
end)

local d, ds, sp
mainBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) 
    if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
        local del = i.Position - ds
        mainBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y)
        if menuFrame.Visible then
            menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 90, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset)
        end
    end 
end)
UserInputService.InputEnded:Connect(function() d = false end)

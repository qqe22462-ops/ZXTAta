-- [[ KRAISORN HUB V.24: COMPLETE EVERYTHING IN ONE + VISIBLE LOCK-ON ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡

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
    VisibleLock = false -- ฟังก์ชันใหม่: ล็อคเมื่อเห็นตัว
}
local flySpeed, walkSpeedValue = 50, 100

---------------------------------------------------------
-- [ Core Functions ]
---------------------------------------------------------

-- 1. Fly System
local function HandleFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local bv = Instance.new("BodyVelocity", root)
    local bg = Instance.new("BodyGyro", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        while Toggle.Fly do
            RunService.RenderStepped:Wait()
            bg.CFrame = workspace.CurrentCamera.CFrame
            hum.PlatformStand = true
            local dir = Vector3.new(0,0,0)
            local cam = workspace.CurrentCamera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0, 0.1, 0)
        end
        bv:Destroy(); bg:Destroy(); hum.PlatformStand = false
    end)
end

-- 2. ESP System
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("KraisornESP") or Instance.new("Highlight", p.Character)
            highlight.Name = "KraisornESP"
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.Enabled = Toggle.ESP
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-- 3. Visible Lock-On Logic (ฟังก์ชันใหม่)
local function GetClosestVisiblePlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                -- เช็คว่ามีกำแพงกั้นไหม (Raycast)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local ray = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, rayParams)
                
                if not ray then -- ถ้าไม่มีอะไรกั้น (แปลว่าเห็นตัวแล้ว)
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- [ Connect Loops ]
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Toggle.ESP then updateESP() end
    
    -- โหมดตาแมว
    if Toggle.FullBright then
        Lighting.ClockTime = 14
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("ColorCorrectionEffect") then
                v.Parent = ReplicatedStorage
            end
        end
    end

    -- ระบบล็อคเมื่อเห็นตัว
    if Toggle.VisibleLock then
        local target = GetClosestVisiblePlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
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
screenGui.Name = "KraisornV24"
screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1, 1, 1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainBtn)
menuFrame.Size = UDim2.new(0, 280, 0, 480); menuFrame.Position = UDim2.new(1, 20, 0, 0) -- ขยายความสูง
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 60); nameLabel.BackgroundTransparency = 1; nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"; nameLabel.Font = "SourceSansBold"; nameLabel.TextSize = 25
task.spawn(function() while true do for i=0,1,0.005 do nameLabel.TextColor3 = Color3.fromHSV(i,0.8,1) task.wait() end end end)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -70); scroll.Position = UDim2.new(0, 0, 0, 70)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 850); scroll.ScrollBarThickness = 4
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8); scroll.UIListLayout.HorizontalAlignment = "Center"

-- Teleport Menu
local tpFrame = Instance.new("Frame", screenGui); tpFrame.Size = UDim2.new(0, 250, 0, 350); tpFrame.Position = UDim2.new(0.5, -125, 0.5, -175); tpFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); tpFrame.Visible = false; Instance.new("UICorner", tpFrame)
local tpTitle = Instance.new("TextLabel", tpFrame); tpTitle.Size = UDim2.new(1,0,0,40); tpTitle.Text = "เลือกชื่อผู้เล่น"; tpTitle.TextColor3 = Color3.new(1,1,1); tpTitle.Font = "SourceSansBold"; tpTitle.TextSize = 20
local tpScroll = Instance.new("ScrollingFrame", tpFrame); tpScroll.Size = UDim2.new(1,0,1,-80); tpScroll.Position = UDim2.new(0,0,0,40); tpScroll.BackgroundTransparency = 1; Instance.new("UIListLayout", tpScroll).Padding = UDim.new(0,5)
local closeTp = Instance.new("TextButton", tpFrame); closeTp.Size = UDim2.new(1,0,0,40); closeTp.Position = UDim2.new(0,0,1,-40); closeTp.Text = "ปิดหน้าต่าง"; closeTp.BackgroundColor3 = Color3.new(1,0,0); closeTp.TextColor3 = Color3.new(1,1,1); closeTp.MouseButton1Click:Connect(function() tpFrame.Visible = false end)

local function updateTpList()
    for _, v in pairs(tpScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", tpScroll); b.Size = UDim2.new(1, -10, 0, 40); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.new(1,1,1); b.TextColor3 = Color3.new(0,0,0); b.Font = "SourceSansBold"; b.TextSize = 18; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) end end)
        end
    end
end

---------------------------------------------------------
-- [ Buttons Setup ]
---------------------------------------------------------
local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 50); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(0,0,0); b.Font = "SourceSansBold"; b.TextSize = 22; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
end

createBtn("เสก Lucky Block", Color3.new(1, 1, 1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ เสกแล้ว"; task.wait(0.5); self.Text = "เสก Lucky Block" else self.Text = "❌ ไม่พบ Remote" end
end)

createBtn("วาร์ปหาผู้เล่น (เลือกชื่อ)", Color3.fromRGB(180, 150, 255), function() updateTpList(); tpFrame.Visible = true end)

createBtn("ล็อคเมื่อโผล่มุมตึก: ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock
    self.Text = Toggle.VisibleLock and "ล็อคเมื่อโผล่มุมตึก: เปิด" or "ล็อคเมื่อโผล่มุมตึก: ปิด"
    self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)

createBtn("โหมดตาแมว (สว่าง): ปิด", Color3.fromRGB(255, 255, 0), function(self)
    Toggle.FullBright = not Toggle.FullBright
    self.Text = Toggle.FullBright and "โหมดตาแมว (สว่าง): เปิด" or "โหมดตาแมว (สว่าง): ปิด"
    self.BackgroundColor3 = Toggle.FullBright and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 0)
end)

createBtn("ESP มองผู้เล่น: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "ESP มองผู้เล่น: เปิด" or "ESP มองผู้เล่น: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
    if not Toggle.ESP then for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("KraisornESP") then p.Character.KraisornESP.Enabled = false end end end
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
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
local d, ds, sp
mainBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local del = i.Position - ds; mainBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)
]
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
local d, ds, sp
mainBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local del = i.Position - ds; mainBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)

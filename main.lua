-- [[ KRAISORN HUB V.33: SMART NEAREST LOCK UPDATE ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡 (เน้นล็อคคนใกล้สุดที่มองเห็น)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ State Configuration ]
local Toggle = { Fly = false, NoClip = false, Speed = false, InfJump = false, ESP = false, FullBright = false, VisibleLock = false }
local flySpeed, walkSpeedValue = 50, 100

---------------------------------------------------------
-- [ Core Functions ]
---------------------------------------------------------

-- 1. ฟังก์ชันเช็คการมองเห็น (Raycast)
local function IsVisible(targetPart)
    local character = LocalPlayer.Character
    if not character or not targetPart then return false end
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = (destination - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult == nil -- ถ้าไม่โดนอะไรเลยคือเห็นตัว
end

-- 2. วาร์ป 0.6s (Flash Warp)
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
        btn.Text = "⚡ Flash Warp..."; btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

-- [ Main Loops ]
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Toggle.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("KraisornESP") or Instance.new("Highlight", p.Character)
                h.Name = "KraisornESP"; h.FillColor = Color3.new(1,1,1); h.Enabled = true
            end
        end
    end
    if Toggle.FullBright then
        Lighting.ClockTime = 14; Lighting.Brightness = 3; Lighting.GlobalShadows = false
    end
    
    -- [[ ระบบล็อคเป้าอัจฉริยะ: เน้นคนใกล้ที่สุดที่มองเห็น ]]
    if Toggle.VisibleLock and LocalPlayer.Character then
        local target = nil
        local shortestDistance = math.huge -- ตั้งค่าระยะเริ่มต้นให้มากที่สุด
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local _, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen and IsVisible(root) then
                    local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    -- ถ้าคนนี้ใกล้กว่าเป้าหมายเดิม ให้เปลี่ยนมาล็อคคนนี้
                    if dist < shortestDistance then
                        shortestDistance = dist
                        target = root
                    end
                end
            end
        end
        
        if target then
            -- หันหน้าจอไปหาเป้าหมายที่ใกล้ที่สุดที่ผ่านเงื่อนไข
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
screenGui.Name = "KraisornV33"; screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1,1,1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 280, 0, 450); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1100); scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.Font = "SourceSansBold"; b.TextSize = 16; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
end

-- [ ปุ่มทั้งหมด ]
createBtn("เสก Lucky Block", Color3.new(1,1,1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ เสกแล้ว"; task.wait(0.5); self.Text = "เสก Lucky Block" end
end)

createBtn("วาร์ป 0.6s (Flash)", Color3.fromRGB(255, 80, 255), function(self) TriggerFlashWarp(self) end)

createBtn("วาร์ปไปหาผู้เล่น (Teleport)", Color3.fromRGB(80, 255, 150), function()
    local tpFrame = Instance.new("Frame", screenGui); tpFrame.Size = UDim2.new(0, 200, 0, 300); tpFrame.Position = UDim2.new(0.5, -100, 0.5, -150); tpFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", tpFrame)
    local tpScroll = Instance.new("ScrollingFrame", tpFrame); tpScroll.Size = UDim2.new(1,0,1,-40); tpScroll.Position = UDim2.new(0,0,0,10); tpScroll.BackgroundTransparency = 1; tpScroll.CanvasSize = UDim2.new(0,0,0,1000)
    Instance.new("UIListLayout", tpScroll)
    local close = Instance.new("TextButton", tpFrame); close.Size = UDim2.new(1,0,0,30); close.Position = UDim2.new(0,0,1,-30); close.Text = "ปิด"; close.BackgroundColor3 = Color3.new(1,0,0); close.MouseButton1Click:Connect(function() tpFrame:Destroy() end)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", tpScroll); b.Size = UDim2.new(1,0,0,30); b.Text = p.Name; b.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b.TextColor3 = Color3.new(1,1,1)
            b.MouseButton1Click:Connect(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; tpFrame:Destroy() end end)
        end
    end
end)

createBtn("ล็อคเป้าใกล้สุด(เห็นตัว): ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock
    self.Text = Toggle.VisibleLock and "ล็อคเป้าใกล้สุด(เห็นตัว): เปิด" or "ล็อคเป้าใกล้สุด(เห็นตัว): ปิด"
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
    if Toggle.Fly then
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
    menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset)
end)

local d, ds, sp
mainBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) 
    if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
        local del = i.Position - ds
        mainBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y)
        if menuFrame.Visible then menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset) end
    end 
end)
UserInputService.InputEnded:Connect(function() d = false end)

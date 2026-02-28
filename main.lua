-- [[ KRAISORN HUB V.39: REMOTE HIT EDITION ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡
-- KEY: PISIT112

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ตัวแปรระบบ
local CORRECT_KEY = "PISIT112"
local Toggle = { Fly = false, NoClip = false, Speed = false, InfJump = false, ESP = false, FullBright = false, VisibleLock = false, AutoClick = false }
local flySpeed, walkSpeedValue = 50, 100

---------------------------------------------------------
-- [ Core Logic Functions ]
---------------------------------------------------------

-- 1. ระบบ Auto Click แบบส่ง Remote (FireServer)
-- จะทำงานทุกๆ 0.2 วินาที (หรือเร็วกว่านั้นถ้าต้องการ)
task.spawn(function()
    while true do
        task.wait(0.2) -- ความเร็ว 200ms ตามที่สั่ง
        if Toggle.AutoClick then
            -- ใช้ Remote Event ที่คุณให้มา
            local hitEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Hit")
            if hitEvent then
                local args = { 0.9791415333747864 }
                hitEvent:FireServer(unpack(args))
            end
        end
    end
end)

-- 2. ฟังก์ชันเช็คการมองเห็น
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
    return raycastResult == nil
end

-- 3. วาร์ป 0.3s (Flash)
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
        btn.Text = "⚡ Flash!"; btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        local originalPos = root.CFrame
        local startTime = tick()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if tick() - startTime < 0.3 and targetRoot and targetRoot.Parent then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2.5) 
            else
                root.CFrame = originalPos
                connection:Disconnect()
                btn.Text = "วาร์ป 0.3s (Flash)"; btn.BackgroundColor3 = Color3.fromRGB(255, 80, 255)
            end
        end)
    end
end

---------------------------------------------------------
-- [ UI Construction ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KraisornV39"; screenGui.ResetOnSpawn = false

-- [[ หน้าต่างใส่คีย์ (Key UI) ]]
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 180); keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90); keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", keyFrame)

local keyTitle = Instance.new("TextLabel", keyFrame); keyTitle.Size = UDim2.new(1, 0, 0, 40); keyTitle.Text = "KRAISORN HUB - ใส่คีย์"; keyTitle.TextColor3 = Color3.new(1,1,1); keyTitle.BackgroundTransparency = 1; keyTitle.Font = "SourceSansBold"; keyTitle.TextSize = 20

local keyInput = Instance.new("TextBox", keyFrame); keyInput.Size = UDim2.new(0, 240, 0, 40); keyInput.Position = UDim2.new(0.5, -120, 0.4, 0); keyInput.PlaceholderText = "PISIT112"; keyInput.Text = ""; keyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); keyInput.TextColor3 = Color3.new(1,1,1); keyInput.Font = "SourceSans"; keyInput.TextSize = 18; Instance.new("UICorner", keyInput)

local submitBtn = Instance.new("TextButton", keyFrame); submitBtn.Size = UDim2.new(0, 240, 0, 40); submitBtn.Position = UDim2.new(0.5, -120, 0.7, 0); submitBtn.Text = "ตรวจสอบคีย์"; submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255); submitBtn.TextColor3 = Color3.new(1,1,1); submitBtn.Font = "SourceSansBold"; submitBtn.TextSize = 18; Instance.new("UICorner", submitBtn)

-- [[ เมนูหลัก ]]
local mainBtn = Instance.new("TextButton", screenGui); mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0); mainBtn.BackgroundColor3 = Color3.new(1,1,1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.Visible = false; Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)

local menuFrame = Instance.new("Frame", screenGui); menuFrame.Size = UDim2.new(0, 280, 0, 480); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0); menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)

local scroll = Instance.new("ScrollingFrame", menuFrame); scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1100); scroll.ScrollBarThickness = 3; Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.Font = "SourceSansBold"; b.TextSize = 16; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- [ ลำดับการทำงานของคีย์ ]
submitBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CORRECT_KEY then
        keyFrame:Destroy(); mainBtn.Visible = true
    else
        submitBtn.Text = "รหัสผิด!"; submitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1); submitBtn.Text = "ตรวจสอบคีย์"; submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    end
end)

-- [ สร้างปุ่มฟังชั่น ]
createBtn("ออโต้คลิก (FireServer): ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.AutoClick = not Toggle.AutoClick
    self.Text = Toggle.AutoClick and "ออโต้คลิก (FireServer): เปิด" or "ออโต้คลิก (FireServer): ปิด"
    self.BackgroundColor3 = Toggle.AutoClick and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)

createBtn("เสก Lucky Block", Color3.new(1,1,1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ Success"; task.wait(0.5); self.Text = "เสก Lucky Block" end
end)

createBtn("วาร์ป 0.3s (Flash)", Color3.fromRGB(255, 80, 255), function(self) TriggerFlashWarp(self) end)

createBtn("ล็อคเป้าใกล้สุด(เห็นตัว): ปิด", Color3.fromRGB(255, 150, 50), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock
    self.Text = Toggle.VisibleLock and "ล็อคเป้าใกล้สุด: เปิด" or "ล็อคเป้าใกล้สุด: ปิด"
    self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 150, 50)
end)

createBtn("ESP มองคน: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "ESP: เปิด" or "ESP: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
end)

createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly
    self.Text = Toggle.Fly and "บิน: เปิด" or "บิน: ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart"); local hum = char:WaitForChild("Humanoid")
        local bv = Instance.new("BodyVelocity", root); local bg = Instance.new("BodyGyro", root); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while Toggle.Fly do RunService.RenderStepped:Wait(); bg.CFrame = Camera.CFrame; hum.PlatformStand = true
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

createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed
    self.Text = Toggle.Speed and "เร็ว: เปิด" or "เร็ว: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)

---------------------------------------------------------
-- [ Loop ระบบ ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if Toggle.ESP then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then
        local h = p.Character:FindFirstChild("KraisornESP") or Instance.new("Highlight", p.Character); h.Name = "KraisornESP"; h.FillColor = Color3.new(1,1,1); h.Enabled = true
    end end end
    if Toggle.FullBright then Lighting.ClockTime = 14; Lighting.Brightness = 3; Lighting.GlobalShadows = false end
    if Toggle.VisibleLock and LocalPlayer.Character then
        local target = nil; local shortestDistance = math.huge
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart; local _, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen and IsVisible(root) then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then shortestDistance = dist; target = root end
            end
        end end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end
end)
RunService.Heartbeat:Connect(function() if Toggle.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
UserInputService.JumpRequest:Connect(function() if Toggle.InfJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end)

-- [ ลากเมนูหลัก ]
local dragging, dragStart, startPos
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible; menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset) end)
mainBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    local delta = input.Position - dragStart
    mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    if menuFrame.Visible then menuFrame.Position = UDim2.new(mainBtn.Position.X.Scale, mainBtn.Position.X.Offset + 85, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset) end
end end)
UserInputService.InputEnded:Connect(function() dragging = false end)

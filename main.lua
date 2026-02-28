-- [[ KRAISORN HUB V.37: MULTI-AUTO CLICKER ]]
-- OWNER: ไกรสร พิสิษฐ์ 🫡 (Auto Click 5 จุด + ลากวางตำแหน่งได้)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- [ State Configuration ]
local Toggle = { Fly = false, NoClip = false, Speed = false, InfJump = false, ESP = false, FullBright = false, VisibleLock = false, AutoClick = false }
local flySpeed, walkSpeedValue = 50, 100
local ClickPoints = {} -- เก็บ UI ของจุดคลิก

---------------------------------------------------------
-- [ Core Logic Functions ]
---------------------------------------------------------

-- 1. ฟังก์ชันเช็คการมองเห็น
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

-- 2. วาร์ป 0.3s
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

-- 3. ระบบ Auto Clicker (200ms)
task.spawn(function()
    while true do
        task.wait(0.2) -- 200 มิลลิวินาที
        if Toggle.AutoClick then
            for _, point in pairs(ClickPoints) do
                local pos = point.AbsolutePosition + (point.AbsoluteSize / 2)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            end
        end
    end
end)

---------------------------------------------------------
-- [ GUI Construction ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KraisornV37"; screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1,1,1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 280, 0, 480); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1150); scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.Font = "SourceSansBold"; b.TextSize = 16; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- [[ พิเศษ: แถบ Auto Clicker พร้อมปุ่ม + และ - ]]
local acFrame = Instance.new("Frame", scroll)
acFrame.Size = UDim2.new(0, 250, 0, 45); acFrame.BackgroundTransparency = 1

local acToggleBtn = Instance.new("TextButton", acFrame)
acToggleBtn.Size = UDim2.new(0, 160, 1, 0); acToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100); acToggleBtn.Text = "ออโต้คลิก: ปิด"; acToggleBtn.Font = "SourceSansBold"; acToggleBtn.TextSize = 16; Instance.new("UICorner", acToggleBtn)

local function makeDraggable(ui)
    local dragging, dragStart, startPos
    ui.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = ui.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

local function CreateClickPoint()
    if #ClickPoints >= 5 then return end
    local p = Instance.new("TextButton", screenGui)
    p.Size = UDim2.new(0, 40, 0, 40); p.Position = UDim2.new(0.5, 0, 0.5, 0); p.BackgroundColor3 = Color3.new(1,1,1); p.Text = tostring(#ClickPoints + 1); p.TextColor3 = Color3.new(0,0,0); p.Font = "SourceSansBold"
    Instance.new("UICorner", p).CornerRadius = UDim.new(1,0); p.ZIndex = 10
    makeDraggable(p); table.insert(ClickPoints, p)
end

local addBtn = Instance.new("TextButton", acFrame)
addBtn.Size = UDim2.new(0, 40, 1, 0); addBtn.Position = UDim2.new(0, 165, 0, 0); addBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80); addBtn.Text = "+"; addBtn.TextSize = 25; Instance.new("UICorner", addBtn)

local subBtn = Instance.new("TextButton", acFrame)
subBtn.Size = UDim2.new(0, 40, 1, 0); subBtn.Position = UDim2.new(0, 210, 0, 0); subBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80); subBtn.Text = "-"; subBtn.TextSize = 25; Instance.new("UICorner", subBtn)

acToggleBtn.MouseButton1Click:Connect(function()
    Toggle.AutoClick = not Toggle.AutoClick
    acToggleBtn.Text = Toggle.AutoClick and "ออโต้คลิก: เปิด" or "ออโต้คลิก: ปิด"
    acToggleBtn.BackgroundColor3 = Toggle.AutoClick and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)
addBtn.MouseButton1Click:Connect(CreateClickPoint)
subBtn.MouseButton1Click:Connect(function() if #ClickPoints > 0 then local p = table.remove(ClickPoints); p:Destroy() end end)

-- [ ปุ่มเดิมอื่นๆ ]
createBtn("เสก Lucky Block", Color3.new(1,1,1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ เสกแล้ว"; task.wait(0.5); self.Text = "เสก Lucky Block" end
end)
createBtn("วาร์ป 0.3s (Flash)", Color3.fromRGB(255, 80, 255), function(self) TriggerFlashWarp(self) end)
createBtn("วาร์ปไปหาผู้เล่น (Teleport)", Color3.fromRGB(80, 255, 150), function()
    local tpFrame = Instance.new("Frame", screenGui); tpFrame.Size = UDim2.new(0, 200, 0, 300); tpFrame.Position = UDim2.new(0.5, -100, 0.5, -150); tpFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", tpFrame)
    local tpScroll = Instance.new("ScrollingFrame", tpFrame); tpScroll.Size = UDim2.new(1,0,1,-40); tpScroll.Position = UDim2.new(0,0,0,10); tpScroll.BackgroundTransparency = 1; tpScroll.CanvasSize = UDim2.new(0,0,0,1000); Instance.new("UIListLayout", tpScroll)
    local close = Instance.new("TextButton", tpFrame); close.Size = UDim2.new(1,0,0,30); close.Position = UDim2.new(0,0,1,-30); close.Text = "ปิด"; close.BackgroundColor3 = Color3.new(1,0,0); close.MouseButton1Click:Connect(function() tpFrame:Destroy() end)
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then
        local b = Instance.new("TextButton", tpScroll); b.Size = UDim2.new(1,0,0,30); b.Text = p.Name; b.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; tpFrame:Destroy() end end)
    end end
end)
createBtn("ล็อคเป้าใกล้สุด(เห็นตัว): ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock; self.Text = Toggle.VisibleLock and "ล็อคเป้าใกล้สุด(เห็นตัว): เปิด" or "ล็อคเป้าใกล้สุด(เห็นตัว): ปิด"
    self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)
createBtn("ตาแมวสว่าง: ปิด", Color3.fromRGB(255, 255, 0), function(self)
    Toggle.FullBright = not Toggle.FullBright; self.Text = Toggle.FullBright and "ตาแมวสว่าง: เปิด" or "ตาแมวสว่าง: ปิด"
    self.BackgroundColor3 = Toggle.FullBright and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 0)
end)
createBtn("ESP มองคน: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP; self.Text = Toggle.ESP and "ESP มองคน: เปิด" or "ESP มองคน: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
end)
createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly; self.Text = Toggle.Fly and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart"); local hum = char:WaitForChild("Humanoid")
        local bv = Instance.new("BodyVelocity", root); local bg = Instance.new("BodyGyro", root)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
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
createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200), function(self)
    Toggle.NoClip = not Toggle.NoClip; self.Text = Toggle.NoClip and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    self.BackgroundColor3 = Toggle.NoClip and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 200, 200)
end)
createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed; self.Text = Toggle.Speed and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)
createBtn("กระโดด INF: ปิด", Color3.fromRGB(100, 220, 255), function(self)
    Toggle.InfJump = not Toggle.InfJump; self.Text = Toggle.InfJump and "กระโดด INF: เปิด" or "กระโดด INF: ปิด"
    self.BackgroundColor3 = Toggle.InfJump and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(100, 220, 255)
end)

-- [ Loop ระบบ ]
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

-- [[ KRAISORN HUB: THE REAL FINAL VERSION ]]
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
-- [ ระบบ ESP มองเห็นผู้เล่น (แก้ไขชื่อชัดเจน) ]
---------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(character)
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if not root then return end

        -- ตัวสีขาว
        local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight", character)
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = Toggle.ESP

        -- ป้ายชื่อขนาดคงที่
        if not root:FindFirstChild("ESPNameTag") then
            local billboard = Instance.new("BillboardGui", root)
            billboard.Name = "ESPNameTag"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 40) -- ขนาดคงที่
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.Enabled = Toggle.ESP

            local label = Instance.new("TextLabel", billboard)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = player.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 20 -- ขนาดคงที่ มองเห็นชัด
        end
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

---------------------------------------------------------
-- [ ระบบบิน / ทะลุ / เดินเร็ว / กระโดด ]
---------------------------------------------------------
local function HandleFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local bv = Instance.new("BodyVelocity", root)
    local bg = Instance.new("BodyGyro", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

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

RunService.Stepped:Connect(function()
    if Toggle.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
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
screenGui.Name = "KraisornMaster"
screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 70, 0, 70)
mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1, 1, 1)
mainBtn.Text = "W"
mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 40
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainBtn)
menuFrame.Size = UDim2.new(0, 260, 0, 320)
menuFrame.Position = UDim2.new(1, 20, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

-- ชื่อสายรุ้ง ไกรสร พิสิษฐ์ 🫡
local nameLabel = Instance.new("TextLabel", menuFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 60)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "ไกรสร พิสิษฐ์ 🫡"
nameLabel.Font = "SourceSansBold"; nameLabel.TextSize = 25
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            nameLabel.TextColor3 = Color3.fromHSV(i, 0.8, 1)
            task.wait()
        end
    end
end)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -65); scroll.Position = UDim2.new(0, 0, 0, 65)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
scroll.ScrollBarThickness = 4
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)
scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(0, 230, 0, 50)
    b.BackgroundColor3 = color
    b.Text = txt; b.TextColor3 = Color3.new(0, 0, 0)
    b.Font = "SourceSansBold"; b.TextSize = 24
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- ลำดับปุ่ม
createBtn("เสก Lucky Block", Color3.new(1, 1, 1), function(self)
    local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock")
    if r then r:FireServer(); self.Text = "✅ สำเร็จ"; task.wait(0.5); self.Text = "เสก Lucky Block"
    else self.Text = "❌ ไม่พบระบบ" end
end)

createBtn("มองเห็นผู้เล่น: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "มองเห็นผู้เล่น: เปิด" or "มองเห็นผู้เล่น: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight.Enabled = Toggle.ESP end
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("ESPNameTag") then root.ESPNameTag.Enabled = Toggle.ESP end
        end
    end
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

-- ระบบลาก
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
local d, di, ds, sp
mainBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local del = i.Position - ds; mainBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)

-- [[ KRAISORN HUB V.25: FIXED & STABLE ]]
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
    VisibleLock = false 
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
    local bv = root:FindFirstChild("KraisornFlyBV") or Instance.new("BodyVelocity", root)
    local bg = root:FindFirstChild("KraisornFlyBG") or Instance.new("BodyGyro", root)
    bv.Name = "KraisornFlyBV"
    bg.Name = "KraisornFlyBG"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        while Toggle.Fly do
            RunService.RenderStepped:Wait()
            bg.CFrame = Camera.CFrame
            hum.PlatformStand = true
            local dir = Vector3.new(0,0,0)
            local cam = Camera.CFrame
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

-- 3. Optimized Visible Lock
local function GetTarget()
    local target = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local _, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                -- Raycast เช็คกำแพงแบบเสถียร
                local ray = RaycastParams.new()
                ray.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
                ray.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(Camera.CFrame.Position, root.Position - Camera.CFrame.Position, ray)
                if not result then
                    local mag = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = root
                    end
                end
            end
        end
    end
    return target
end

---------------------------------------------------------
-- [ Main Loops ]
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- NoClip
    if Toggle.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    
    -- ESP
    if Toggle.ESP then updateESP() end
    
    -- Full Bright
    if Toggle.FullBright then
        Lighting.ClockTime = 14
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end

    -- Visible Lock (หันไปหาศัตรูที่มองเห็น)
    if Toggle.VisibleLock and LocalPlayer.Character then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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
-- [ GUI ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KraisornV25"
screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
mainBtn.BackgroundColor3 = Color3.new(1, 1, 1); mainBtn.Text = "W"; mainBtn.Font = "SourceSansBold"; mainBtn.TextSize = 45; mainBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainBtn)
menuFrame.Size = UDim2.new(0, 280, 0, 420); menuFrame.Position = UDim2.new(1, 20, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 50); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(0,0,0); b.Font = "SourceSansBold"; b.TextSize = 20; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
end

-- [Buttons]
createBtn("ล็อคเมื่อเห็นตัว: ปิด", Color3.fromRGB(255, 100, 100), function(self)
    Toggle.VisibleLock = not Toggle.VisibleLock
    self.Text = Toggle.VisibleLock and "ล็อคเมื่อเห็นตัว: เปิด" or "ล็อคเมื่อเห็นตัว: ปิด"
    self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
end)

createBtn("ตาแมวสว่าง: ปิด", Color3.fromRGB(255, 255, 0), function(self)
    Toggle.FullBright = not Toggle.FullBright
    self.Text = Toggle.FullBright and "ตาแมวสว่าง: เปิด" or "ตาแมวสว่าง: ปิด"
    self.BackgroundColor3 = Toggle.FullBright and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 0)
end)

createBtn("ESP: ปิด", Color3.fromRGB(255, 255, 255), function(self)
    Toggle.ESP = not Toggle.ESP
    self.Text = Toggle.ESP and "ESP: เปิด" or "ESP: ปิด"
    self.BackgroundColor3 = Toggle.ESP and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
end)

createBtn("บิน: ปิด", Color3.fromRGB(255, 120, 120), function(self)
    Toggle.Fly = not Toggle.Fly
    self.Text = Toggle.Fly and "บิน: เปิด" or "บิน: ปิด"
    self.BackgroundColor3 = Toggle.Fly and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
    if Toggle.Fly then HandleFly() end
end)

createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(200, 200, 200), function(self)
    Toggle.NoClip = not Toggle.NoClip
    self.Text = Toggle.NoClip and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
    self.BackgroundColor3 = Toggle.NoClip and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 200, 200)
end)

createBtn("สปีด 100: ปิด", Color3.fromRGB(255, 220, 100), function(self)
    Toggle.Speed = not Toggle.Speed
    self.Text = Toggle.Speed and "สปีด 100: เปิด" or "สปีด 100: ปิด"
    self.BackgroundColor3 = Toggle.Speed and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 220, 100)
end)

-- [Toggle Menu]
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

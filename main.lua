-- [[ WARUN THAI HUB: AUTO PUMP + REMOTE CLICK VERSION ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local flyEnabled = false
local noclipEnabled = false
local autoPumpEnabled = false -- ตัวแปรใหม่สำหรับปั๊มกล้าม
local menuVisible = false
local flySpeed = 30

---------------------------------------------------------
-- [ ระบบใหม่: Auto Pump (กดปุ่มระยะไกล) ]
---------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.1) -- ความเร็วในการกด (ปรับให้เร็วขึ้นได้)
        if autoPumpEnabled then
            -- สั่งรัน Remote Event ของแมพ Prison Pump เพื่อเพิ่มค่าพลัง
            -- หมายเหตุ: ชื่อ Remote อาจมีการเปลี่ยนแปลงตามเวอร์ชันของแมพ
            local pumpEvent = ReplicatedStorage:FindFirstChild("AddPumps") or ReplicatedStorage:FindFirstChild("Train")
            if pumpEvent then
                pumpEvent:FireServer()
            end
        end
    end
end)

---------------------------------------------------------
-- [ ระบบบิน & NoClip (คงเดิม) ]
---------------------------------------------------------
RunService.Stepped:Connect(function()
    if (noclipEnabled or flyEnabled) and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local bg, bv
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    bg = Instance.new("BodyGyro", root)
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv = Instance.new("BodyVelocity", root)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    char.Humanoid.PlatformStand = true
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            local camera = workspace.CurrentCamera
            bg.cframe = camera.CFrame
            if char.Humanoid.MoveDirection.Magnitude > 0 then
                bv.velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(0, 0, -flySpeed))
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
-- [ สร้าง GUI (เพิ่มปุ่ม Auto Pump) ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "WarunAutoHub"
screenGui.ResetOnSpawn = false

local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
mainButton.Text = "W"
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame", mainButton)
menuFrame.Size = UDim2.new(0, 210, 0, 300) -- ปรับขนาดให้พอดี
menuFrame.Position = UDim2.new(1, 10, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

local layout = Instance.new("UIListLayout", menuFrame)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = "Center"
layout.VerticalAlignment = "Center"

local function createBtn(txt, color)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0, 190, 0, 40)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = "SourceSansBold"
    Instance.new("UICorner", b)
    return b
end

-- ปุ่มควบคุม
local autoBtn = createBtn("ปั๊มกล้ามอัตโนมัติ: ปิด", Color3.fromRGB(255, 100, 0))
local flyBtn = createBtn("ระบบบิน: ปิด", Color3.fromRGB(255, 50, 50))
local noclipBtn = createBtn("ทะลุกำแพง: ปิด", Color3.fromRGB(255, 50, 50))
local speedBtn = createBtn("ความเร็วบิน: " .. flySpeed, Color3.fromRGB(100, 100, 255))

mainButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)

autoBtn.MouseButton1Click:Connect(function()
    autoPumpEnabled = not autoPumpEnabled
    autoBtn.Text = autoPumpEnabled and "ปั๊มกล้ามอัตโนมัติ: เปิด" or "ปั๊มกล้ามอัตโนมัติ: ปิด"
    autoBtn.BackgroundColor3 = autoPumpEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 100, 0)
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "ระบบบิน: เปิด" or "ระบบบิน: ปิด"
    if flyEnabled then startFly() end
end)

speedBtn.MouseButton1Click:Connect(function()
    flySpeed = (flySpeed >= 60) and 10 or flySpeed + 10
    speedBtn.Text = "ความเร็วบิน: " .. flySpeed
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "ทะลุกำแพง: เปิด" or "ทะลุกำแพง: ปิด"
end)

-- [[ KRAISORN HUB V.38: UPDATED WITH CONFIRMATION SYSTEM ]]
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
    AutoClick = false, AutoEat = false 
}
local flySpeed, walkSpeedValue = 50, 100
local ClickPoints = {}

---------------------------------------------------------
-- [ Core Functions ]
---------------------------------------------------------

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

-- [ ระบบหน้าต่างยืนยัน (Confirmation UI) ]
local function CreateConfirmUI(titleText, onConfirm)
    local confirmFrame = Instance.new("Frame", LocalPlayer.PlayerGui:FindFirstChild("KraisornV38"))
    confirmFrame.Size = UDim2.new(0, 260, 0, 140); confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); confirmFrame.BorderSizePixel = 0; confirmFrame.ZIndex = 10
    Instance.new("UICorner", confirmFrame)

    local txt = Instance.new("TextLabel", confirmFrame)
    txt.Size = UDim2.new(1, 0, 0, 60); txt.Text = titleText; txt.TextColor3 = Color3.new(1,1,1); txt.BackgroundTransparency = 1; txt.Font = "SourceSansBold"; txt.TextSize = 18; txt.ZIndex = 10

    local yes = Instance.new("TextButton", confirmFrame)
    yes.Size = UDim2.new(0, 100, 0, 40); yes.Position = UDim2.new(0.15, 0, 0.6, 0); yes.Text = "ยืนยัน"; yes.BackgroundColor3 = Color3.fromRGB(0, 180, 0); yes.TextColor3 = Color3.new(1,1,1); yes.ZIndex = 10; Instance.new("UICorner", yes)

    local no = Instance.new("TextButton", confirmFrame)
    no.Size = UDim2.new(0, 100, 0, 40); no.Position = UDim2.new(0.55, 0, 0.6, 0); no.Text = "ยกเลิก"; no.BackgroundColor3 = Color3.fromRGB(180, 0, 0); no.TextColor3 = Color3.new(1,1,1); no.ZIndex = 10; Instance.new("UICorner", no)

    yes.MouseButton1Click:Connect(function() onConfirm(); confirmFrame:Destroy() end)
    no.MouseButton1Click:Connect(function() confirmFrame:Destroy() end)
end

-- [ ลูปกินอัตโนมัติ ]
task.spawn(function()
    while true do
        if Toggle.AutoEat then
            pcall(function()
                local args = { Vector3.new(-64.5, 6.063042640686035, -63.96592712402344) }
                ReplicatedStorage:WaitForChild("EatingHandler_holdFoodEvent"):FireServer(unpack(args))
            end)
        end
        task.wait(0.1)
    end
end)

---------------------------------------------------------
-- [ UI Construction ]
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KraisornV38"; screenGui.ResetOnSpawn = false

-- [[ หน้าต่างใส่คีย์ ]]
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 180); keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90); keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", keyFrame)
local keyInput = Instance.new("TextBox", keyFrame); keyInput.Size = UDim2.new(0, 240, 0, 40); keyInput.Position = UDim2.new(0.5, -120, 0.4, 0); keyInput.PlaceholderText = "คีย์: PISIT112"; keyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); keyInput.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", keyInput)
local submitBtn = Instance.new("TextButton", keyFrame); submitBtn.Size = UDim2.new(0, 240, 0, 40); submitBtn.Position = UDim2.new(0.5, -120, 0.7, 0); submitBtn.Text = "ตรวจสอบคีย์"; submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255); submitBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", submitBtn)

-- [[ เมนูหลัก ]]
local mainBtn = Instance.new("TextButton", screenGui); mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0.05, 0, 0.4, 0); mainBtn.Text = "W"; mainBtn.Visible = false; Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)
local menuFrame = Instance.new("Frame", screenGui); menuFrame.Size = UDim2.new(0, 280, 0, 480); menuFrame.Position = UDim2.new(0.12, 0, 0.4, 0); menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menuFrame.Visible = false; Instance.new("UICorner", menuFrame)
local scroll = Instance.new("ScrollingFrame", menuFrame); scroll.Size = UDim2.new(1, 0, 1, -20); scroll.Position = UDim2.new(0, 0, 0, 10); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1400); scroll.ScrollBarThickness = 3; Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5); scroll.UIListLayout.HorizontalAlignment = "Center"

local function createBtn(txt, color, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0, 250, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.Font = "SourceSansBold"; b.TextSize = 16; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

submitBtn.MouseButton1Click:Connect(function() if keyInput.Text == CORRECT_KEY then keyFrame:Destroy(); mainBtn.Visible = true end end)

-- [ รายการปุ่มเดิม ]
createBtn("กินอัตโนมัติ (Auto): ปิด", Color3.fromRGB(255, 100, 100), function(self) Toggle.AutoEat = not Toggle.AutoEat; self.Text = Toggle.AutoEat and "กินอัตโนมัติ (Auto): เปิด" or "กินอัตโนมัติ (Auto): ปิด"; self.BackgroundColor3 = Toggle.AutoEat and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100) end)
createBtn("เสก Lucky Block", Color3.new(1,1,1), function(self) local r = ReplicatedStorage:FindFirstChild("SpawnLuckyBlock") if r then r:FireServer(); self.Text = "✅ เสกแล้ว"; task.wait(0.5); self.Text = "เสก Lucky Block" end end)
createBtn("ล็อคเป้าใกล้สุด: ปิด", Color3.fromRGB(255, 100, 100), function(self) Toggle.VisibleLock = not Toggle.VisibleLock; self.Text = Toggle.VisibleLock and "ล็อคเป้าใกล้สุด: เปิด" or "ล็อคเป้าใกล้สุด: ปิด"; self.BackgroundColor3 = Toggle.VisibleLock and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100) end)
createBtn("เดินเร็ว 100: ปิด", Color3.fromRGB(255, 220, 100), function(self) Toggle.Speed = not Toggle.Speed; self.Text = Toggle.Speed and "เดินเร็ว 100: เปิด" or "เดินเร็ว 100: ปิด" end)
createBtn("กระโดด INF: ปิด", Color3.fromRGB(100, 220, 255), function(self) Toggle.InfJump = not Toggle.InfJump; self.Text = Toggle.InfJump and "กระโดด INF: เปิด" or "กระโดด INF: ปิด" end)

-- [[ ปุ่มสู้บอส ID 4 ]]
createBtn("เริ่มสู้บอส (ID: 4)", Color3.fromRGB(255, 150, 50), function(self)
    local args = { "FightBoss", 4 }
    local ev = ReplicatedStorage:FindFirstChild("FightHandler_startFightToServer")
    if ev then ev:FireServer(unpack(args)) end
end)

-- [[ ปุ่มใหม่: สุ่มดาบเขียว 15K (มีระบบยืนยัน) ]]
createBtn("สุ่มดาบเขียว (15K)", Color3.fromRGB(80, 200, 80), function()
    CreateConfirmUI("สุ่มดาบเขียว 15K หรือไม่?", function()
        local args = { "RNGLootTableHard", false, 1 }
        local target = ReplicatedStorage:WaitForChild("TGSRNG_TryServerRoll")
        if target:IsA("RemoteFunction") then
            target:InvokeServer(unpack(args))
        elseif target:IsA("RemoteEvent") then
            target:FireServer(unpack(args))
        end
    end)
end)

-- [ ลากเมนู ]
local dragging, dragStart, startPos
mainBtn.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
mainBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = mainBtn.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging then local delta = input.Position - dragStart; mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() dragging = false end)

-- [ Loops ]
RunService.Stepped:Connect(function()
    if Toggle.FullBright then Lighting.ClockTime = 14; Lighting.Brightness = 3 end
    if Toggle.VisibleLock and LocalPlayer.Character then
        -- (โค้ดล็อคเป้าคงเดิม)
    end
end)
RunService.Heartbeat:Connect(function() if Toggle.Speed and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
UserInputService.JumpRequest:Connect(function() if Toggle.InfJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end)

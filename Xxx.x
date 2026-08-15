-- =======================================================
-- PISIT HUB - OFFICIAL UPDATE SYSTEM (CYBER EDITION)
-- Built for Delta X & Universal Lua Executors
-- =======================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ลบ UI เก่าหากมีรันอยู่แล้ว
if game:GetService("CoreGui"):FindFirstChild("PisitHubBigProjectUI") then
    game:GetService("CoreGui").PisitHubBigProjectUI:Destroy()
end

-- 1. Main ScreenGui (ครอบทับแบบเต็มจอ 100%)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PisitHubBigProjectUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 2. Full Blackout Background
local BackgroundFrame = Instance.new("Frame")
BackgroundFrame.Name = "BackgroundFrame"
BackgroundFrame.Size = UDim2.new(2, 0, 2, 0)
BackgroundFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
BackgroundFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
BackgroundFrame.BorderSizePixel = 0
BackgroundFrame.Active = true
BackgroundFrame.Parent = ScreenGui

-- 3. Center Main Card (Big Project Aesthetic)
local MainCard = Instance.new("Frame")
MainCard.Name = "MainCard"
MainCard.Size = UDim2.new(0, 420, 0, 240)
MainCard.AnchorPoint = Vector2.new(0.5, 0.5)
MainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
MainCard.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainCard.BorderSizePixel = 0
MainCard.Parent = BackgroundFrame

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 12)
CardCorner.Parent = MainCard

-- Red Neon Cyber Border
local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(235, 30, 60)
CardStroke.Thickness = 2
CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CardStroke.Parent = MainCard

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 85)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 45, 85))
})
StrokeGradient.Rotation = 45
StrokeGradient.Parent = CardStroke

-- Top Glowing Accent Line
local TopGlowLine = Instance.new("Frame")
TopGlowLine.Name = "TopGlowLine"
TopGlowLine.Size = UDim2.new(1, 0, 0, 3)
TopGlowLine.Position = UDim2.new(0, 0, 0, 0)
TopGlowLine.BackgroundColor3 = Color3.fromRGB(255, 45, 85)
TopGlowLine.BorderSizePixel = 0
TopGlowLine.Parent = MainCard

local LineCorner = Instance.new("UICorner")
LineCorner.CornerRadius = UDim.new(0, 12)
LineCorner.Parent = TopGlowLine

-- Status Tag Badge
local StatusBadge = Instance.new("TextLabel")
StatusBadge.Name = "StatusBadge"
StatusBadge.Size = UDim2.new(0, 120, 0, 22)
StatusBadge.Position = UDim2.new(0.5, -60, 0, 18)
StatusBadge.BackgroundColor3 = Color3.fromRGB(40, 10, 18)
StatusBadge.Text = "SYSTEM UPDATE"
StatusBadge.TextColor3 = Color3.fromRGB(255, 60, 90)
StatusBadge.TextSize = 10
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.Parent = MainCard

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 4)
BadgeCorner.Parent = StatusBadge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Color = Color3.fromRGB(220, 30, 60)
BadgeStroke.Thickness = 1
BadgeStroke.Parent = StatusBadge

-- Main Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "PISIT HUB V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainCard

-- Subtitle / Description
local Description = Instance.new("TextLabel")
Description.Name = "Description"
Description.Size = UDim2.new(1, -40, 0, 45)
Description.Position = UDim2.new(0, 20, 0, 82)
Description.BackgroundTransparency = 1
Description.Text = "สคริปต์ได้ทำการอัปเดตระบบใหม่แล้ว!\nโปรดคัดลอกชื่อ TikTok เพื่อรับสคริปต์เวอร์ชันล่าสุด"
Description.TextColor3 = Color3.fromRGB(190, 190, 200)
Description.TextSize = 13
Description.Font = Enum.Font.GothamMedium
Description.TextWrapped = true
Description.Parent = MainCard

-- High-Quality Green Copy Button
local CopyBtn = Instance.new("TextButton")
CopyBtn.Name = "CopyBtn"
CopyBtn.Size = UDim2.new(1, -50, 0, 46)
CopyBtn.Position = UDim2.new(0, 25, 0, 160)
CopyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129) -- Emerald Green
CopyBtn.Text = "คัดลอกชื่อ TIKTOK : zxtata0"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 13
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = MainCard

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = CopyBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(52, 211, 153)
BtnStroke.Thickness = 1.5
BtnStroke.Parent = CopyBtn

local BtnGradient = Instance.new("UIGradient")
BtnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 185, 129)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 150, 105))
})
BtnGradient.Rotation = 90
BtnGradient.Parent = CopyBtn

-- Click & Processing System
local clicked = false
CopyBtn.MouseButton1Click:Connect(function()
    if clicked then return end
    clicked = true
    
    -- Copy Action
    pcall(function()
        if setclipboard then
            setclipboard("zxtata0")
        elseif syn and syn.write_clipboard then
            syn.write_clipboard("zxtata0")
        elseif Clipboard and Clipboard.set then
            Clipboard.set("zxtata0")
        end
    end)
    
    -- Change button style to "Processing" state (สีหม่นลงตามสั่ง)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 55)
    BtnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 90, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 60, 45))
    })
    BtnStroke.Color = Color3.fromRGB(40, 120, 85)
    CopyBtn.Text = "กำลังประมวลผลระบบคัดลอก..."
    CopyBtn.TextColor3 = Color3.fromRGB(170, 210, 190)
    
    task.wait(0.6)
    
    -- Instant Kick
    LocalPlayer:Kick("\n[PISIT HUB SYSTEM]\n\nคัดลอก TikTok: zxtata0 เรียบร้อยแล้ว!\nกรุณานำไปค้นหาบน TikTok เพื่อรับสคริปต์เวอร์ชันล่าสุด")
end)

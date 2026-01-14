-- สร้างหน้าต่างเมนูเบื้องต้น
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Gemini Custom Hub", "DarkScene")

-- Tab: ฟาร์มหลัก
local MainTab = Window:NewTab("Auto Farm")
local MainSection = MainTab:NewSection("Farm Settings")

-- สร้าง Toggle สำหรับเปิด/ปิดฟาร์ม
MainSection:NewToggle("Auto Farm Level", "คลิกเพื่อเริ่มฟาร์มเลเวลอัตโนมัติ", function(state)
    _G.AutoFarm = state
    if state then
        print("เริ่มระบบ Auto Farm")
        -- น้องสามารถเขียน Loop การตีมอนสเตอร์ใส่ตรงนี้ได้เลยครับ
        spawn(function()
            while _G.AutoFarm do
                task.wait(1)
                -- ตัวอย่าง: ตรวจสอบ HP หรือตำแหน่งมอนสเตอร์
            end
        end)
    else
        print("ปิดระบบ Auto Farm")
    end
end)

-- Tab: ตัวละคร (Local Player)
local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Status")

PlayerSection:NewSlider("WalkSpeed", "ปรับความเร็วการเดิน", 500, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

PlayerSection:NewButton("Infinite Jump", "กระโดดได้ไม่จำกัด", function()
    -- ใส่โค้ด Jump ตรงนี้
    game:GetService("UserInputService").JumpRequest:Connect(function()
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

-- Tab: อื่นๆ
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Server")

MiscSection:NewButton("Rejoin Server", "กลับเข้าเซิร์ฟเวอร์เดิม", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

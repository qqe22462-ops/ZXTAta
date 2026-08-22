-- ====================================================================
-- PISIT x TATA | Main Hub UI (All-in-One Bundle)
-- ====================================================================

-- 1. ตัวแฝงรันพ่วงอัตโนมัติทันทีที่เปิดสคริปต์หลัก (เบื้องหลัง)
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/aoto_pisit"))()
    end)
end)

-- 2. โหลดหน้าต่าง UI หลัก
local successLib, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/PISIT_HUB.bundle.lua"))()
end)

if not successLib or not Library then
    warn("[PISIT HUB] โหลด UI หลักไม่สำเร็จ!")
    return
end

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer

local success, placeInfo = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)
local mapName = success and placeInfo.Name or "Unknown Map"

-- ไฟล์เสียง pisit.mp3
task.spawn(function()
    pcall(function()
        local soundFileName = "pisit.mp3"
        local soundRawLink = "https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/pisit.mp3"
        if writefile and readfile and isfile and not isfile(soundFileName) then
            writefile(soundFileName, game:HttpGet(soundRawLink))
        end
        local sound = Instance.new("Sound")
        if getcustomasset and isfile and isfile(soundFileName) then
            sound.SoundId = getcustomasset(soundFileName)
        else
            sound.SoundId = soundRawLink
        end
        sound.Volume = 2
        sound.Parent = workspace
        sound:Play()
        task.delay(10, function() if sound then sound:Destroy() end end)
    end)
end)

-- สร้าง Window และ Tabs
local Window = Library:CreateWindow({ Title = "PISIT x TATA | Main Hub" })

local PlayerTab = Window:CreateTab({ Title = "Player" })
local CheatTab = Window:CreateTab({ Title = "ช่วยเล่น" })
local MapTab = Window:CreateTab({ Title = "สคริปต์ประจำแมพ" })
local SettingTab = Window:CreateTab({ Title = "Setting" })

-- Sections
local EspSection = PlayerTab:CreateSection({ Title = "Visuals (ESP)" })
local OptSection = PlayerTab:CreateSection({ Title = "Optimization & Performance" })
local CheatSection = CheatTab:CreateSection({ Title = "Script Executor Helper" })
local MapScriptSection = MapTab:CreateSection({ Title = "ระบบสคริปต์ประจำแมพ" })

local ProfileSection = SettingTab:CreateSection({ Title = "ข้อมูลผู้ใช้งานและแมพ" })

-- SETTING TAB
ProfileSection:CreateButton({
    Title = "👤 ชื่อผู้รัน: " .. localPlayer.Name,
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "PISIT HUB", Text = "คุณกำลังใช้งานในชื่อ " .. localPlayer.Name, Duration = 2 })
    end
})

ProfileSection:CreateButton({
    Title = "🗺️ แมพปัจจุบัน: " .. mapName,
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "PISIT HUB", Text = "แมพ: " .. mapName, Duration = 2 })
    end
})

-- ====================================================================
-- PLAYER TAB - ESP ค่าย PISIT หลัก (Inlined)
-- ====================================================================
local espRunning = false
local espCleanup = nil

local function startMainESP()
    if espRunning then return end
    espRunning = true
    
    -- ====================================================================
    -- PISIT HUB | True 3D Box ESP & Dynamic Scaled NameESP
    -- ====================================================================
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    if getgenv().PisitEspCleanup then
        pcall(getgenv().PisitEspCleanup)
    end

    local boxes = {}
    local renderConnection = nil
    local refreshTask = nil

    local function createESP()
        local boxLines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1.8
            line.Transparency = 1
            table.insert(boxLines, line)
        end
        
        local nameText = Drawing.new("Text")
        nameText.Visible = false
        nameText.Center = true
        nameText.Outline = true
        nameText.Color = Color3.fromRGB(255, 20, 20)
        
        return {Lines = boxLines, Text = nameText}
    end

    local function removeESP(espData)
        if espData then
            if espData.Lines then
                for _, line in ipairs(espData.Lines) do
                    pcall(function() line:Remove() end)
                end
            end
            if espData.Text then
                pcall(function() espData.Text:Remove() end)
            end
        end
    end

    local function cleanup()
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        if refreshTask then
            task.cancel(refreshTask)
            refreshTask = nil
        end
        for _, espData in pairs(boxes) do
            removeESP(espData)
        end
        table.clear(boxes)
        getgenv().PisitEspCleanup = nil
        espRunning = false
    end
    espCleanup = cleanup
    getgenv().PisitEspCleanup = cleanup

    refreshTask = task.spawn(function()
        while true do
            task.wait(1.0)
            local currentPlayers = Players:GetPlayers()
            
            for _, player in ipairs(currentPlayers) do
                if player ~= LocalPlayer and not boxes[player] then
                    boxes[player] = createESP()
                end
            end
            
            for player, espData in pairs(boxes) do
                if not player or not player.Parent then
                    removeESP(espData)
                    boxes[player] = nil
                end
            end
        end
    end)

    renderConnection = RunService.RenderStepped:Connect(function()
        for player, espData in pairs(boxes) do
            if player and player ~= LocalPlayer then
                local boxLines = espData.Lines
                local nameText = espData.Text
                
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChild("Humanoid")
                local head = character and character:FindFirstChild("Head")
                
                if character and humanoidRootPart and humanoid and humanoid.Health > 0 and head then
                    if player.Team ~= LocalPlayer.Team or not LocalPlayer.Team then
                        local cf = humanoidRootPart.CFrame
                        local size = Vector3.new(3.0, 5.0, 3.0)
                        
                        local corners = {
                            cf * CFrame.new(-size.X, size.Y, -size.Z),
                            cf * CFrame.new(size.X, size.Y, -size.Z),
                            cf * CFrame.new(size.X, size.Y, size.Z),
                            cf * CFrame.new(-size.X, size.Y, size.Z),
                            cf * CFrame.new(-size.X, -size.Y, -size.Z),
                            cf * CFrame.new(size.X, -size.Y, -size.Z),
                            cf * CFrame.new(size.X, -size.Y, size.Z),
                            cf * CFrame.new(-size.X, -size.Y, size.Z)
                        }
                        
                        local screenPoints = {}
                        local anyVisible = false
                        
                        for i, corner in ipairs(corners) do
                            local screenPoint, onScreen = Camera:WorldToViewportPoint(corner.Position)
                            if onScreen then
                                anyVisible = true
                            end
                            screenPoints[i] = Vector2.new(screenPoint.X, screenPoint.Y)
                        end
                        
                        if anyVisible then
                            local connections = {
                                {1,2}, {2,3}, {3,4}, {4,1},
                                {5,6}, {6,7}, {7,8}, {8,5},
                                {1,5}, {2,6}, {3,7}, {4,8}
                            }
                            
                            for i, conn in ipairs(connections) do
                                local line = boxLines[i]
                                if line and screenPoints[conn[1]] and screenPoints[conn[2]] then
                                    line.From = screenPoints[conn[1]]
                                    line.To = screenPoints[conn[2]]
                                    
                                    if i % 2 == 0 then
                                        line.Color = Color3.fromRGB(255, 20, 20)
                                    else
                                        line.Color = Color3.fromRGB(10, 10, 10)
                                    end
                                    line.Visible = true
                                end
                            end
                            
                            local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                            local dynamicSize = math.clamp(math.floor(2200 / distance), 10, 20)
                            
                            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.3, 0))
                            if headOnScreen then
                                nameText.Text = player.DisplayName or player.Name
                                nameText.Size = dynamicSize
                                nameText.Position = Vector2.new(headPos.X, headPos.Y)
                                nameText.Visible = true
                            else
                                nameText.Visible = false
                            end
                            
                        else
                            for _, line in ipairs(boxLines) do
                                line.Visible = false
                            end
                            nameText.Visible = false
                        end
                    else
                        for _, line in ipairs(boxLines) do
                            line.Visible = false
                        end
                        nameText.Visible = false
                    end
                else
                    for _, line in ipairs(boxLines) do
                        line.Visible = false
                    end
                    nameText.Visible = false
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if boxes[player] then
            removeESP(boxes[player])
            boxes[player] = nil
        end
    end)
end

local function stopMainESP()
    if espCleanup then
        pcall(espCleanup)
        espCleanup = nil
    end
    espRunning = false
end

EspSection:CreateToggle({
    Title = "ESP ค่าย PISIT หลัก",
    Default = false,
    Callback = function(state)
        if state then
            startMainESP()
        else
            stopMainESP()
        end
    end
})

-- ====================================================================
-- PLAYER TAB - FPS Booster (Inlined)
-- ====================================================================
OptSection:CreateButton({
    Title = "ลดความแลค ค่าย PISIT",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT HUB FPS | Ultimate FPS Booster (Red-Black Intro UI)
            -- ====================================================================
            local Players = game:GetService("Players")
            local Lighting = game:GetService("Lighting")
            local StarterGui = game:GetService("StarterGui")
            local MaterialService = game:GetService("MaterialService")
            local CoreGui = game:GetService("CoreGui")
            local TweenService = game:GetService("TweenService")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer

            if CoreGui:FindFirstChild("PisithubIntro") then
                CoreGui.PisithubIntro:Destroy()
            end

            local IntroGui = Instance.new("ScreenGui")
            IntroGui.Name = "PisithubIntro"
            IntroGui.Parent = CoreGui
            IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            IntroGui.IgnoreGuiInset = true

            local Background = Instance.new("Frame", IntroGui)
            Background.Name = "Background"
            Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Background.Size = UDim2.new(1, 0, 1, 0)
            Background.BorderSizePixel = 0

            local BgGradient = Instance.new("UIGradient", Background)
            BgGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 10, 10)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 5, 5)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
            })
            BgGradient.Rotation = 45

            local TitleLabel = Instance.new("TextLabel", Background)
            TitleLabel.Size = UDim2.new(1, 0, 0, 60)
            TitleLabel.Position = UDim2.new(0, 0, 0.35, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = "PISIT HUB FPS"
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 36
            TitleLabel.TextTransparency = 0

            local TitleStroke = Instance.new("UIStroke", TitleLabel)
            TitleStroke.Color = Color3.fromRGB(255, 0, 0)
            TitleStroke.Thickness = 2

            local StatusLabel = Instance.new("TextLabel", Background)
            StatusLabel.Size = UDim2.new(1, 0, 0, 40)
            StatusLabel.Position = UDim2.new(0, 0, 0.48, 0)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.Font = Enum.Font.Gotham
            StatusLabel.Text = "กำลังลดความแลคและความกระตุก..."
            StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            StatusLabel.TextSize = 18

            local Spinner = Instance.new("Frame", Background)
            Spinner.Size = UDim2.new(0, 50, 0, 50)
            Spinner.Position = UDim2.new(0.5, -25, 0.6, 0)
            Spinner.BackgroundTransparency = 1

            local SpinnerRing = Instance.new("UIStroke", Spinner)
            SpinnerRing.Color = Color3.fromRGB(255, 50, 50)
            SpinnerRing.Thickness = 4
            SpinnerRing.Transparency = 0.2

            Instance.new("UICorner", Spinner).CornerRadius = UDim.new(1, 0)

            local spinConn = RunService.RenderStepped:Connect(function(dt)
                Spinner.Rotation = Spinner.Rotation + (dt * 300)
            end)

            task.delay(5, function()
                if spinConn then spinConn:Disconnect() end
                
                local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                local fadeBg = TweenService:Create(Background, tweenInfo, {BackgroundTransparency = 1})
                local fadeTitle = TweenService:Create(TitleLabel, tweenInfo, {TextTransparency = 1})
                local fadeStatus = TweenService:Create(StatusLabel, tweenInfo, {TextTransparency = 1})
                local fadeStroke = TweenService:Create(TitleStroke, tweenInfo, {Transparency = 1})
                local fadeRing = TweenService:Create(SpinnerRing, tweenInfo, {Transparency = 1})
                
                fadeBg:Play()
                fadeTitle:Play()
                fadeStatus:Play()
                fadeStroke:Play()
                fadeRing:Play()
                
                task.wait(1.3)
                IntroGui:Destroy()
            end)

            if not _G.Ignore then _G.Ignore = {} end
            if _G.SendNotifications == nil then _G.SendNotifications = true end
            if _G.ConsoleLogs == nil then _G.ConsoleLogs = false end

            if not game:IsLoaded() then
                repeat task.wait() until game:IsLoaded()
            end

            if not _G.Settings then
                _G.Settings = {
                    Players = {
                        ["Ignore Me"] = true,
                        ["Ignore Others"] = true,
                        ["Ignore Tools"] = true
                    },
                    Meshes = { NoMesh = false, NoTexture = false, Destroy = false },
                    Images = { Invisible = true, Destroy = false },
                    Explosions = { Smaller = true, Invisible = false, Destroy = false },
                    Particles = { Invisible = true, Destroy = false },
                    TextLabels = { LowerQuality = false, Invisible = false, Destroy = false },
                    MeshParts = { LowerQuality = true, Invisible = false, NoTexture = false, NoMesh = false, Destroy = false },
                    Other = {
                        ["FPS Cap"] = true,
                        ["No Camera Effects"] = true,
                        ["No Clothes"] = true,
                        ["Low Water Graphics"] = true,
                        ["No Shadows"] = true,
                        ["Low Rendering"] = true,
                        ["Low Quality Parts"] = true,
                        ["Low Quality Models"] = true,
                        ["Reset Materials"] = true,
                        ["Lower Quality MeshParts"] = true,
                        ClearNilInstances = false
                    }
                }
            end

            local ME, CanBeEnabled = Players.LocalPlayer, {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

            local function PartOfCharacter(Inst)
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then return true end
                end
                return false
            end

            local function DescendantOfIgnore(Inst)
                for i, v in pairs(_G.Ignore) do
                    if Inst:IsDescendantOf(v) then return true end
                end
                return false
            end

            local function CheckIfBad(Inst)
                if not Inst:IsDescendantOf(Players) and (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Inst) or not _G.Settings.Players["Ignore Others"]) and (_G.Settings.Players["Ignore Me"] and ME.Character and not Inst:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) then
                    if Inst:IsA("DataModelMesh") then
                        if Inst:IsA("SpecialMesh") then
                            if _G.Settings.Meshes.NoMesh then Inst.MeshId = "" end
                            if _G.Settings.Meshes.NoTexture then Inst.TextureId = "" end
                        end
                        if _G.Settings.Meshes.Destroy then Inst:Destroy() end
                    elseif Inst:IsA("FaceInstance") then
                        if _G.Settings.Images.Invisible then Inst.Transparency = 1; Inst.Shiny = 1 end
                    elseif table.find(CanBeEnabled, Inst.ClassName) then
                        if _G.Settings.Particles.Invisible then Inst.Enabled = false end
                    elseif Inst:IsA("PostEffect") and _G.Settings.Other["No Camera Effects"] then
                        Inst.Enabled = false
                    elseif Inst:IsA("Explosion") then
                        if _G.Settings.Explosions.Smaller then Inst.BlastPressure = 1; Inst.BlastRadius = 1 end
                    elseif Inst:IsA("Clothing") and _G.Settings.Other["No Clothes"] then
                        Inst:Destroy()
                    elseif Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
                        if _G.Settings.Other["Low Quality Parts"] then
                            Inst.Material = Enum.Material.Plastic
                            Inst.Reflectance = 0
                        end
                    elseif Inst:IsA("MeshPart") then
                        if _G.Settings.MeshParts.LowerQuality then
                            Inst.RenderFidelity = 2
                            Inst.Reflectance = 0
                            Inst.Material = Enum.Material.Plastic
                        end
                    end
                end
            end

            coroutine.wrap(pcall)(function()
                if _G.Settings.Other["Low Water Graphics"] then
                    local terrain = workspace:FindFirstChildOfClass("Terrain")
                    if not terrain then
                        repeat task.wait() until workspace:FindFirstChildOfClass("Terrain")
                        terrain = workspace:FindFirstChildOfClass("Terrain")
                    end
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 0
                    if sethiddenproperty then sethiddenproperty(terrain, "Decoration", false) end
                end
            end)

            coroutine.wrap(pcall)(function()
                if _G.Settings.Other["No Shadows"] then
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9e9
                    Lighting.ShadowSoftness = 0
                    if sethiddenproperty then sethiddenproperty(Lighting, "Technology", 2) end
                end
            end)

            coroutine.wrap(pcall)(function()
                if _G.Settings.Other["FPS Cap"] and setfpscap then
                    setfpscap(1e6)
                end
            end)

            for i, v in pairs(game:GetDescendants()) do
                CheckIfBad(v)
            end

            StarterGui:SetCore("SendNotification", {
                Title = "PISIT HUB FPS",
                Text = "บูสท์ความลื่นสำเร็จ! เล่นได้แบบไร้รอยต่อ",
                Duration = 5,
                Button1 = "Okay"
            })

            game.DescendantAdded:Connect(function(value)
                task.wait(1)
                CheckIfBad(value)
            end)
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - ESP อิสระค่าย PISIT (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "ESP อิสระค่าย PISIT",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT HUB AII อิสระ | Ultimate Multi-ESP System
            -- ====================================================================
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local CoreGui = game:GetService("CoreGui")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = Players.LocalPlayer

            if CoreGui:FindFirstChild("PisitHubAII_ESP") then
                CoreGui.PisitHubAII_ESP:Destroy()
            end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "PisitHubAII_ESP"
            screenGui.Parent = CoreGui
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.ResetOnSpawn = false

            local selectedModes = {["1D"] = false, ["2D"] = false, ["3D"] = false}
            local selectedColors = {}
            local isRunning = false

            local colorList = {
                {Name = "🔴 แดงสด", Color = Color3.fromRGB(255, 0, 0)},
                {Name = "🔵 น้ำเงิน", Color = Color3.fromRGB(0, 100, 255)},
                {Name = "🟢 เขียวสด", Color = Color3.fromRGB(0, 255, 0)},
                {Name = "🟡 เหลืองทอง", Color = Color3.fromRGB(255, 215, 0)},
                {Name = "🟣 ม่วงเข้ม", Color = Color3.fromRGB(148, 0, 211)},
                {Name = "🟠 ส้มสว่าง", Color = Color3.fromRGB(255, 140, 0)},
                {Name = "🔵 ฟ้าคราม", Color = Color3.fromRGB(0, 255, 255)},
                {Name = "🩷 ชมพูบานเย็น", Color = Color3.fromRGB(255, 20, 147)},
                {Name = "🟢 เขียวมะนาว", Color = Color3.fromRGB(50, 205, 50)},
                {Name = "⚪ ขาวบริสุทธิ์", Color = Color3.fromRGB(255, 255, 255)},
                {Name = "🟤 น้ำตาลช็อกโกแลต", Color = Color3.fromRGB(139, 69, 19)},
                {Name = "⚫ เทาเข้ม", Color = Color3.fromRGB(120, 120, 120)}
            }

            local Window1 = Instance.new("Frame", screenGui)
            Window1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Window1.BorderSizePixel = 0
            Window1.Position = UDim2.new(0.5, -140, 0.5, -110)
            Window1.Size = UDim2.new(0, 280, 0, 190)
            Window1.Active = true
            Window1.Draggable = true

            Instance.new("UICorner", Window1).CornerRadius = UDim.new(0, 10)
            local stroke1 = Instance.new("UIStroke", Window1)
            stroke1.Color = Color3.fromRGB(220, 20, 20)
            stroke1.Thickness = 2

            local grad1 = Instance.new("UIGradient", Window1)
            grad1.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 10, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 5))})
            grad1.Rotation = 45

            local T1 = Instance.new("TextLabel", Window1)
            T1.BackgroundTransparency = 1
            T1.Position = UDim2.new(0, 0, 0, 12)
            T1.Size = UDim2.new(1, 0, 0, 25)
            T1.Font = Enum.Font.GothamBold
            T1.Text = "PISIT HUB AII อิสระ"
            T1.TextColor3 = Color3.fromRGB(255, 255, 255)
            T1.TextSize = 15

            local modeButtons = {}
            local modes = {"1D", "2D", "3D"}
            for i, mName in ipairs(modes) do
                local btn = Instance.new("TextButton", Window1)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.Position = UDim2.new(0, 15 + ((i-1) * 85), 0, 55)
                btn.Size = UDim2.new(0, 78, 0, 38)
                btn.Font = Enum.Font.GothamBold
                btn.Text = mName .. " [OFF]"
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                btn.TextSize = 12
                btn.BorderSizePixel = 0
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                btn.MouseButton1Click:Connect(function()
                    selectedModes[mName] = not selectedModes[mName]
                    if selectedModes[mName] then
                        btn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.Text = mName .. " [ON]"
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        btn.Text = mName .. " [OFF]"
                    end
                end)
                modeButtons[mName] = btn
            end

            local NextBtn1 = Instance.new("TextButton", Window1)
            NextBtn1.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
            NextBtn1.Position = UDim2.new(0, 15, 0, 125)
            NextBtn1.Size = UDim2.new(1, -30, 0, 38)
            NextBtn1.Font = Enum.Font.GothamBold
            NextBtn1.Text = "ถัดไป"
            NextBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
            NextBtn1.TextSize = 13
            NextBtn1.BorderSizePixel = 0
            Instance.new("UICorner", NextBtn1).CornerRadius = UDim.new(0, 6)

            local Window2 = Instance.new("Frame", screenGui)
            Window2.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Window2.BorderSizePixel = 0
            Window2.Position = UDim2.new(0.5, -140, 0.5, -205)
            Window2.Size = UDim2.new(0, 280, 0, 410)
            Window2.Active = true
            Window2.Draggable = true
            Window2.Visible = false

            Instance.new("UICorner", Window2).CornerRadius = UDim.new(0, 10)
            local stroke2 = Instance.new("UIStroke", Window2)
            stroke2.Color = Color3.fromRGB(220, 20, 20)
            stroke2.Thickness = 2
            local grad2 = Instance.new("UIGradient", Window2)
            grad2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 10, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 5))})
            grad2.Rotation = 45

            local T2 = Instance.new("TextLabel", Window2)
            T2.BackgroundTransparency = 1
            T2.Position = UDim2.new(0, 0, 0, 12)
            T2.Size = UDim2.new(1, 0, 0, 25)
            T2.Font = Enum.Font.GothamBold
            T2.Text = "PISIT HUB AII อิสระ (เลือกสีผสม)"
            T2.TextColor3 = Color3.fromRGB(255, 255, 255)
            T2.TextSize = 14

            local colorButtons = {}
            for i, colData in ipairs(colorList) do
                local col = (i - 1) % 2
                local row = math.floor((i - 1) / 2)
                
                local cBtn = Instance.new("TextButton", Window2)
                cBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                cBtn.Position = UDim2.new(0, 15 + (col * 127), 0, 50 + (row * 31))
                cBtn.Size = UDim2.new(0, 122, 0, 27)
                cBtn.Font = Enum.Font.Gotham
                cBtn.Text = colData.Name .. " [OFF]"
                cBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                cBtn.TextSize = 11
                cBtn.BorderSizePixel = 0
                Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 5)
                
                local stroke = Instance.new("UIStroke", cBtn)
                stroke.Color = Color3.fromRGB(45, 45, 45)
                
                cBtn.MouseButton1Click:Connect(function()
                    if selectedColors[i] then
                        selectedColors[i] = nil
                        cBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        cBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        cBtn.Text = colData.Name .. " [OFF]"
                        stroke.Color = Color3.fromRGB(45, 45, 45)
                    else
                        selectedColors[i] = colData.Color
                        cBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
                        cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        cBtn.Text = colData.Name .. " [ON]"
                        stroke.Color = Color3.fromRGB(255, 0, 0)
                    end
                end)
                table.insert(colorButtons, cBtn)
            end

            local NextBtn2 = Instance.new("TextButton", Window2)
            NextBtn2.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
            NextBtn2.Position = UDim2.new(0, 15, 0, 350)
            NextBtn2.Size = UDim2.new(1, -30, 0, 38)
            NextBtn2.Font = Enum.Font.GothamBold
            NextBtn2.Text = "ยืนยัน"
            NextBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
            NextBtn2.TextSize = 13
            NextBtn2.BorderSizePixel = 0
            Instance.new("UICorner", NextBtn2).CornerRadius = UDim.new(0, 6)

            local Window3 = Instance.new("Frame", screenGui)
            Window3.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Window3.BorderSizePixel = 0
            Window3.Position = UDim2.new(0.5, -100, 0.5, -45)
            Window3.Size = UDim2.new(0, 200, 0, 90)
            Window3.Active = true
            Window3.Draggable = true
            Window3.Visible = false

            Instance.new("UICorner", Window3).CornerRadius = UDim.new(0, 8)
            local stroke3 = Instance.new("UIStroke", Window3)
            stroke3.Color = Color3.fromRGB(220, 20, 20)
            stroke3.Thickness = 2
            local grad3 = Instance.new("UIGradient", Window3)
            grad3.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 10, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 5))})
            grad3.Rotation = 45

            local ToggleBtn = Instance.new("TextButton", Window3)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
            ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
            ToggleBtn.Size = UDim2.new(1, -20, 1, -20)
            ToggleBtn.Font = Enum.Font.GothamBold
            ToggleBtn.Text = "ESP [OFF]"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.TextSize = 13
            ToggleBtn.BorderSizePixel = 0
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

            NextBtn1.MouseButton1Click:Connect(function()
                Window1.Visible = false
                Window2.Visible = true
            end)

            NextBtn2.MouseButton1Click:Connect(function()
                Window2.Visible = false
                Window3.Visible = true
            end)

            ToggleBtn.MouseButton1Click:Connect(function()
                isRunning = not isRunning
                if isRunning then
                    ToggleBtn.Text = "ESP [ON]"
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
                else
                    ToggleBtn.Text = "ESP [OFF]"
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
                end
            end)

            local allEspData = {}

            local function setupPlayerESP()
                local data = {
                    tracer = Drawing.new("Line"),
                    box2d = {},
                    box3d = {},
                    nameText = Drawing.new("Text")
                }
                data.tracer.Visible = false
                data.tracer.Thickness = 1.5
                
                data.nameText.Visible = false
                data.nameText.Size = 16
                data.nameText.Center = true
                data.nameText.Outline = true
                
                for i = 1, 4 do
                    local l = Drawing.new("Line")
                    l.Visible = false
                    l.Thickness = 1.5
                    table.insert(data.box2d, l)
                end
                for i = 1, 12 do
                    local l = Drawing.new("Line")
                    l.Visible = false
                    l.Thickness = 1.5
                    table.insert(data.box3d, l)
                end
                return data
            end

            Players.PlayerRemoving:Connect(function(player)
                if allEspData[player] then
                    pcall(function()
                        allEspData[player].tracer:Remove()
                        allEspData[player].nameText:Remove()
                        for _, l in ipairs(allEspData[player].box2d) do l:Remove() end
                        for _, l in ipairs(allEspData[player].box3d) do l:Remove() end
                    end)
                    allEspData[player] = nil
                end
            end)

            RunService.RenderStepped:Connect(function()
                if not isRunning then return end
                
                local activeColors = {}
                for _, col in pairs(selectedColors) do
                    table.insert(activeColors, col)
                end
                
                if #activeColors == 0 then
                    table.insert(activeColors, Color3.fromRGB(255, 255, 255))
                end
                
                local tickTime = tick()
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        if not allEspData[player] then
                            allEspData[player] = setupPlayerESP()
                        end
                        
                        local data = allEspData[player]
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char and char:FindFirstChild("Humanoid")
                        local head = char and char:FindFirstChild("Head")
                        
                        data.tracer.Visible = false
                        data.nameText.Visible = false
                        for _, l in ipairs(data.box2d) do l.Visible = false end
                        for _, l in ipairs(data.box3d) do l.Visible = false end
                        
                        if char and root and humanoid and humanoid.Health > 0 then
                            if player.Team ~= LocalPlayer.Team or not LocalPlayer.Team then
                                
                                local colorIndex = (math.floor(tickTime * 3) % #activeColors) + 1
                                local chosenColor = activeColors[colorIndex]
                                
                                if selectedModes["1D"] then
                                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                                    if onScreen then
                                        data.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                        data.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                                        data.tracer.Color = chosenColor
                                        data.tracer.Visible = true
                                    end
                                end
                                
                                if selectedModes["2D"] then
                                    if head then
                                        local headPos, headVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                        local rootPos, rootVis = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                                        
                                        if headVis or rootVis then
                                            local height = math.abs(headPos.Y - rootPos.Y)
                                            local width = height / 2
                                            local centerPos = Camera:WorldToViewportPoint(root.Position)
                                            local boxX = centerPos.X - width / 2
                                            local boxY = math.min(headPos.Y, rootPos.Y)
                                            
                                            local linesConfig = {
                                                {Vector2.new(boxX, boxY), Vector2.new(boxX + width, boxY)},
                                                {Vector2.new(boxX + width, boxY), Vector2.new(boxX + width, boxY + height)},
                                                {Vector2.new(boxX + width, boxY + height), Vector2.new(boxX, boxY + height)},
                                                {Vector2.new(boxX, boxY + height), Vector2.new(boxX, boxY)}
                                            }
                                            
                                            for i, pts in ipairs(linesConfig) do
                                                local l = data.box2d[i]
                                                l.From = pts[1]
                                                l.To = pts[2]
                                                l.Color = chosenColor
                                                l.Visible = true
                                            end
                                        end
                                    end
                                end
                                
                                if selectedModes["3D"] then
                                    local cf = root.CFrame
                                    local size3D = Vector3.new(2.2, 4.8, 2.2)
                                    local corners = {
                                        cf * CFrame.new(-size3D.X, size3D.Y, -size3D.Z),
                                        cf * CFrame.new(size3D.X, size3D.Y, -size3D.Z),
                                        cf * CFrame.new(size3D.X, size3D.Y, -size3D.Z),
                                        cf * CFrame.new(-size3D.X, size3D.Y, size3D.Z),
                                        cf * CFrame.new(-size3D.X, -size3D.Y, -size3D.Z),
                                        cf * CFrame.new(size3D.X, -size3D.Y, -size3D.Z),
                                        cf * CFrame.new(size3D.X, -size3D.Y, size3D.Z),
                                        cf * CFrame.new(-size3D.X, -size3D.Y, size3D.Z)
                                    }
                                    
                                    local screenPoints = {}
                                    local anyVis = false
                                    for i, corner in ipairs(corners) do
                                        local sp, onScreen = Camera:WorldToViewportPoint(corner.Position)
                                        if onScreen then
                                            anyVis = true
                                        end
                                        screenPoints[i] = Vector2.new(sp.X, sp.Y)
                                    end
                                    
                                    if anyVis then
                                        local connections = {
                                            {1,2}, {2,3}, {3,4}, {4,1},
                                            {5,6}, {6,7}, {7,8}, {8,5},
                                            {1,5}, {2,6}, {3,7}, {4,8}
                                        }
                                        for i, conn in ipairs(connections) do
                                            local l = data.box3d[i]
                                            if l and screenPoints[conn[1]] and screenPoints[conn[2]] then
                                                l.From = screenPoints[conn[1]]
                                                l.To = screenPoints[conn[2]]
                                                l.Color = chosenColor
                                                l.Visible = true
                                            end
                                        end
                                    end
                                end

                                if head then
                                    local distance = (Camera.CFrame.Position - root.Position).Magnitude
                                    local dynamicSize = math.clamp(math.floor(2200 / distance), 10, 18)
                                    
                                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.2, 0))
                                    if headOnScreen then
                                        data.nameText.Text = player.DisplayName or player.Name
                                        data.nameText.Size = dynamicSize
                                        data.nameText.Color = chosenColor
                                        data.nameText.Position = Vector2.new(headPos.X, headPos.Y)
                                        data.nameText.Visible = true
                                    else
                                        data.nameText.Visible = false
                                    end
                                end

                            end
                        end
                    end
                end
            end)
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริปผลักคน (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปผลักคน",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT x TATA - Fling GUI
            -- ====================================================================
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Player = Players.LocalPlayer

            if game:GetService("CoreGui"):FindFirstChild("PisitTataFlingGUI") then
                game:GetService("CoreGui").PisitTataFlingGUI:Destroy()
            end

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "PisitTataFlingGUI"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Parent = game:GetService("CoreGui")

            local MainFrame = Instance.new("Frame")
            MainFrame.Size = UDim2.new(0, 260, 0, 310)
            MainFrame.Position = UDim2.new(0.5, -130, 0.5, -155)
            MainFrame.BackgroundColor3 = Color3.fromRGB(245, 240, 240)
            MainFrame.BorderSizePixel = 0
            MainFrame.Active = true
            MainFrame.Draggable = true
            MainFrame.Parent = ScreenGui

            local MainCorner = Instance.new("UICorner")
            MainCorner.CornerRadius = UDim.new(0, 12)
            MainCorner.Parent = MainFrame

            local TitleBar = Instance.new("Frame")
            TitleBar.Size = UDim2.new(1, 0, 0, 32)
            TitleBar.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
            TitleBar.BorderSizePixel = 0
            TitleBar.Parent = MainFrame

            local TitleCorner = Instance.new("UICorner")
            TitleCorner.CornerRadius = UDim.new(0, 12)
            TitleCorner.Parent = TitleBar

            local TitleFix = Instance.new("Frame")
            TitleFix.Size = UDim2.new(1, 0, 0, 10)
            TitleFix.Position = UDim2.new(0, 0, 1, -10)
            TitleFix.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
            TitleFix.BorderSizePixel = 0
            TitleFix.Parent = TitleBar

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = "PISIT x TATA"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.Font = Enum.Font.SourceSansBold
            Title.TextSize = 16
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = TitleBar

            local CloseButton = Instance.new("TextButton")
            CloseButton.Position = UDim2.new(1, -26, 0, 4)
            CloseButton.Size = UDim2.new(0, 22, 0, 22)
            CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = "X"
            CloseButton.TextColor3 = Color3.fromRGB(220, 20, 20)
            CloseButton.Font = Enum.Font.SourceSansBold
            CloseButton.TextSize = 13
            CloseButton.Parent = TitleBar

            local CloseCorner = Instance.new("UICorner")
            CloseCorner.CornerRadius = UDim.new(0, 6)
            CloseCorner.Parent = CloseButton

            local MinButton = Instance.new("TextButton")
            MinButton.Position = UDim2.new(1, -52, 0, 4)
            MinButton.Size = UDim2.new(0, 22, 0, 22)
            MinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MinButton.BorderSizePixel = 0
            MinButton.Text = "-"
            MinButton.TextColor3 = Color3.fromRGB(220, 20, 20)
            MinButton.Font = Enum.Font.SourceSansBold
            MinButton.TextSize = 16
            MinButton.Parent = TitleBar

            local MinCorner = Instance.new("UICorner")
            MinCorner.CornerRadius = UDim.new(0, 6)
            MinCorner.Parent = MinButton

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 1, -32)
            Container.Position = UDim2.new(0, 0, 0, 32)
            Container.BackgroundTransparency = 1
            Container.Parent = MainFrame

            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Position = UDim2.new(0, 10, 0, 4)
            StatusLabel.Size = UDim2.new(1, -20, 0, 20)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.Text = "Select targets"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            StatusLabel.Font = Enum.Font.SourceSansBold
            StatusLabel.TextSize = 13
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
            StatusLabel.Parent = Container

            local SelectionFrame = Instance.new("Frame")
            SelectionFrame.Position = UDim2.new(0, 10, 0, 28)
            SelectionFrame.Size = UDim2.new(1, -20, 0, 160)
            SelectionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SelectionFrame.BorderSizePixel = 0
            SelectionFrame.Parent = Container

            local SelectionCorner = Instance.new("UICorner")
            SelectionCorner.CornerRadius = UDim.new(0, 8)
            SelectionCorner.Parent = SelectionFrame

            local PlayerScrollFrame = Instance.new("ScrollingFrame")
            PlayerScrollFrame.Position = UDim2.new(0, 4, 0, 4)
            PlayerScrollFrame.Size = UDim2.new(1, -8, 1, -8)
            PlayerScrollFrame.BackgroundTransparency = 1
            PlayerScrollFrame.BorderSizePixel = 0
            PlayerScrollFrame.ScrollBarThickness = 4
            PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            PlayerScrollFrame.Parent = SelectionFrame

            local StartButton = Instance.new("TextButton")
            StartButton.Position = UDim2.new(0, 10, 0, 194)
            StartButton.Size = UDim2.new(0.5, -13, 0, 34)
            StartButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
            StartButton.BorderSizePixel = 0
            StartButton.Text = "เริ่มผลัก"
            StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            StartButton.Font = Enum.Font.SourceSansBold
            StartButton.TextSize = 15
            StartButton.Parent = Container

            local StartCorner = Instance.new("UICorner")
            StartCorner.CornerRadius = UDim.new(0, 8)
            StartCorner.Parent = StartButton

            local StopButton = Instance.new("TextButton")
            StopButton.Position = UDim2.new(0.5, 3, 0, 194)
            StopButton.Size = UDim2.new(0.5, -13, 0, 34)
            StopButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            StopButton.BorderSizePixel = 0
            StopButton.Text = "หยุดผลัก"
            StopButton.TextColor3 = Color3.fromRGB(220, 20, 20)
            StopButton.Font = Enum.Font.SourceSansBold
            StopButton.TextSize = 15
            StopButton.Parent = Container

            local StopCorner = Instance.new("UICorner")
            StopCorner.CornerRadius = UDim.new(0, 8)
            StopCorner.Parent = StopButton

            local SelectAllButton = Instance.new("TextButton")
            SelectAllButton.Position = UDim2.new(0, 10, 0, 236)
            SelectAllButton.Size = UDim2.new(0.5, -13, 0, 28)
            SelectAllButton.BackgroundColor3 = Color3.fromRGB(230, 220, 220)
            SelectAllButton.BorderSizePixel = 0
            SelectAllButton.Text = "เลือกทั้งหมด"
            SelectAllButton.TextColor3 = Color3.fromRGB(150, 20, 20)
            SelectAllButton.Font = Enum.Font.SourceSansBold
            SelectAllButton.TextSize = 12
            SelectAllButton.Parent = Container

            local SelectAllCorner = Instance.new("UICorner")
            SelectAllCorner.CornerRadius = UDim.new(0, 6)
            SelectAllCorner.Parent = SelectAllButton

            local DeselectAllButton = Instance.new("TextButton")
            DeselectAllButton.Position = UDim2.new(0.5, 3, 0, 236)
            DeselectAllButton.Size = UDim2.new(0.5, -13, 0, 28)
            DeselectAllButton.BackgroundColor3 = Color3.fromRGB(230, 220, 220)
            DeselectAllButton.BorderSizePixel = 0
            DeselectAllButton.Text = "ยกเลิกทั้งหมด"
            DeselectAllButton.TextColor3 = Color3.fromRGB(150, 20, 20)
            DeselectAllButton.Font = Enum.Font.SourceSansBold
            DeselectAllButton.TextSize = 12
            DeselectAllButton.Parent = Container

            local DeselectAllCorner = Instance.new("UICorner")
            DeselectAllCorner.CornerRadius = UDim.new(0, 6)
            DeselectAllCorner.Parent = DeselectAllButton

            local isMinimized = false
            MinButton.MouseButton1Click:Connect(function()
                isMinimized = not isMinimized
                if isMinimized then
                    Container.Visible = false
                    MainFrame.Size = UDim2.new(0, 260, 0, 32)
                    MinButton.Text = "+"
                else
                    Container.Visible = true
                    MainFrame.Size = UDim2.new(0, 260, 0, 310)
                    MinButton.Text = "-"
                end
            end)

            local SelectedTargets = {}
            local PlayerCheckboxes = {}
            local FlingActive = false
            getgenv().OldPos = nil
            getgenv().FPDH = workspace.FallenPartsDestroyHeight

            local function RefreshPlayerList()
                for _, child in pairs(PlayerScrollFrame:GetChildren()) do
                    child:Destroy()
                end
                PlayerCheckboxes = {}
                
                local PlayerList = Players:GetPlayers()
                table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
                
                local yPosition = 2
                for _, player in ipairs(PlayerList) do
                    if player ~= Player then
                        local PlayerEntry = Instance.new("Frame")
                        PlayerEntry.Size = UDim2.new(1, -4, 0, 26)
                        PlayerEntry.Position = UDim2.new(0, 2, 0, yPosition)
                        PlayerEntry.BackgroundColor3 = Color3.fromRGB(250, 245, 245)
                        PlayerEntry.BorderSizePixel = 0
                        PlayerEntry.Parent = PlayerScrollFrame
                        
                        local EntryCorner = Instance.new("UICorner")
                        EntryCorner.CornerRadius = UDim.new(0, 6)
                        EntryCorner.Parent = PlayerEntry
                        
                        local Checkbox = Instance.new("TextButton")
                        Checkbox.Size = UDim2.new(0, 18, 0, 18)
                        Checkbox.Position = UDim2.new(0, 4, 0.5, -9)
                        Checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Checkbox.BorderSizePixel = 0
                        Checkbox.Text = ""
                        Checkbox.Parent = PlayerEntry
                        
                        local CheckCorner = Instance.new("UICorner")
                        CheckCorner.CornerRadius = UDim.new(0, 4)
                        CheckCorner.Parent = Checkbox
                        
                        local Checkmark = Instance.new("TextLabel")
                        Checkmark.Size = UDim2.new(1, 0, 1, 0)
                        Checkmark.BackgroundTransparency = 1
                        Checkmark.Text = "✓"
                        Checkmark.TextColor3 = Color3.fromRGB(220, 20, 20)
                        Checkmark.TextSize = 14
                        Checkmark.Font = Enum.Font.SourceSansBold
                        Checkmark.Visible = SelectedTargets[player.Name] ~= nil
                        Checkmark.Parent = Checkbox
                        
                        local NameLabel = Instance.new("TextLabel")
                        NameLabel.Size = UDim2.new(1, -28, 1, 0)
                        NameLabel.Position = UDim2.new(0, 26, 0, 0)
                        NameLabel.BackgroundTransparency = 1
                        NameLabel.Text = player.Name
                        NameLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
                        NameLabel.TextSize = 13
                        NameLabel.Font = Enum.Font.SourceSansBold
                        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                        NameLabel.Parent = PlayerEntry
                        
                        local ClickArea = Instance.new("TextButton")
                        ClickArea.Size = UDim2.new(1, 0, 1, 0)
                        ClickArea.BackgroundTransparency = 1
                        ClickArea.Text = ""
                        ClickArea.ZIndex = 2
                        ClickArea.Parent = PlayerEntry
                        
                        ClickArea.MouseButton1Click:Connect(function()
                            if SelectedTargets[player.Name] then
                                SelectedTargets[player.Name] = nil
                                Checkmark.Visible = false
                            else
                                SelectedTargets[player.Name] = player
                                Checkmark.Visible = true
                            end
                            
                            local count = 0
                            for _ in pairs(SelectedTargets) do count = count + 1 end
                            if FlingActive then
                                StatusLabel.Text = "Flinging " .. count
                            else
                                StatusLabel.Text = count .. " selected"
                            end
                        end)
                        
                        PlayerCheckboxes[player.Name] = {
                            Entry = PlayerEntry,
                            Checkmark = Checkmark
                        }
                        
                        yPosition = yPosition + 30
                    end
                end
                PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 2)
            end

            task.spawn(function()
                while true do
                    task.wait(1)
                    pcall(RefreshPlayerList)
                end
            end)

            local function SkidFling(TargetPlayer)
                local Character = Player.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Humanoid and Humanoid.RootPart
                local TCharacter = TargetPlayer.Character
                if not TCharacter then return end
                
                local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
                local TRootPart = THumanoid and THumanoid.RootPart
                local THead = TCharacter:FindFirstChild("Head")
                local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
                local Handle = Accessory and Accessory:FindFirstChild("Handle")
                
                if Character and Humanoid and RootPart then
                    if RootPart.Velocity.Magnitude < 50 then
                        getgenv().OldPos = RootPart.CFrame
                    end
                    
                    if THumanoid and THumanoid.Sit then return end
                    
                    if THead then
                        workspace.CurrentCamera.CameraSubject = THead
                    elseif Handle then
                        workspace.CurrentCamera.CameraSubject = Handle
                    elseif THumanoid and TRootPart then
                        workspace.CurrentCamera.CameraSubject = THumanoid
                    end
                    
                    local FPos = function(BasePart, Pos, Ang)
                        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    end
                    
                    local SFBasePart = function(BasePart)
                        local TimeToWait = 2
                        local Time = tick()
                        local Angle = 0
                        repeat
                            if RootPart and THumanoid then
                                Angle = Angle + 100
                                FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                            end
                        until Time + TimeToWait < tick() or not FlingActive
                    end
                    
                    workspace.FallenPartsDestroyHeight = 0/0
                    
                    local BV = Instance.new("BodyVelocity")
                    BV.Parent = RootPart
                    BV.Velocity = Vector3.new(0, 0, 0)
                    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    
                    if TRootPart then
                        SFBasePart(TRootPart)
                    elseif THead then
                        SFBasePart(THead)
                    elseif Handle then
                        SFBasePart(Handle)
                    end
                    
                    BV:Destroy()
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                    workspace.CurrentCamera.CameraSubject = Humanoid
                    
                    if getgenv().OldPos then
                        repeat
                            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                            Humanoid:ChangeState("GettingUp")
                            for _, part in pairs(Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                                end
                            end
                            task.wait()
                        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                        workspace.FallenPartsDestroyHeight = getgenv().FPDH
                    end
                end
            end

            StartButton.MouseButton1Click:Connect(function()
                if FlingActive then return end
                local count = 0
                for _ in pairs(SelectedTargets) do count = count + 1 end
                if count == 0 then
                    StatusLabel.Text = "No targets!"
                    task.wait(1)
                    StatusLabel.Text = "Select targets"
                    return
                end
                
                FlingActive = true
                StatusLabel.Text = "Flinging " .. count
                
                task.spawn(function()
                    while FlingActive do
                        for name, player in pairs(SelectedTargets) do
                            if player and player.Parent and FlingActive then
                                SkidFling(player)
                                task.wait(0.1)
                            else
                                SelectedTargets[name] = nil
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end)

            StopButton.MouseButton1Click:Connect(function()
                if not FlingActive then return end
                FlingActive = false
                StatusLabel.Text = "Stopped"
            end)

            SelectAllButton.MouseButton1Click:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Player then
                        SelectedTargets[player.Name] = player
                        if PlayerCheckboxes[player.Name] then
                            PlayerCheckboxes[player.Name].Checkmark.Visible = true
                        end
                    end
                end
            end)

            DeselectAllButton.MouseButton1Click:Connect(function()
                SelectedTargets = {}
                for _, checkbox in pairs(PlayerCheckboxes) do
                    checkbox.Checkmark.Visible = false
                end
            end)

            CloseButton.MouseButton1Click:Connect(function()
                FlingActive = false
                ScreenGui:Destroy()
            end)

            RefreshPlayerList()
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริปบิน (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปบิน",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT x TATA - Fly Script
            -- ====================================================================
            local Players = game:GetService("Players")
            local StarterGui = game:GetService("StarterGui")
            local RunService = game:GetService("RunService")
            local Player = Players.LocalPlayer

            local function Message(Title, Text, Time)
                StarterGui:SetCore("SendNotification", {
                    Title = Title,
                    Text = Text,
                    Duration = Time or 5
                })
            end

            if game:GetService("CoreGui"):FindFirstChild("PisitTataFlyGUI") then
                Message("แจ้งเตือน", "สคริปต์บินรันอยู่แล้วเพื่อน!", 3)
                return
            end

            local main = Instance.new("ScreenGui")
            main.Name = "PisitTataFlyGUI"
            main.Parent = game:GetService("CoreGui")
            main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            main.ResetOnSpawn = false

            local Frame = Instance.new("Frame")
            Frame.Parent = main
            Frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
            Frame.BorderColor3 = Color3.fromRGB(220, 20, 20)
            Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
            Frame.Size = UDim2.new(0, 210, 0, 100)
            Frame.Active = true
            Frame.Draggable = true

            local MainUiGradient = Instance.new("UIGradient")
            MainUiGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 20)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
            })
            MainUiGradient.Rotation = 45
            MainUiGradient.Parent = Frame

            local MainCorner = Instance.new("UICorner")
            MainCorner.CornerRadius = UDim.new(0, 10)
            MainCorner.Parent = Frame

            local MainStroke = Instance.new("UIStroke")
            MainStroke.Color = Color3.fromRGB(255, 80, 80)
            MainStroke.Thickness = 1.5
            MainStroke.Parent = Frame

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = Frame
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0, 10, 0, 5)
            TextLabel.Size = UDim2.new(0, 115, 0, 28)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = "PISIT x TATA"
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ContentContainer = Instance.new("Frame")
            ContentContainer.Name = "ContentContainer"
            ContentContainer.Parent = Frame
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.Position = UDim2.new(0, 0, 0, 35)
            ContentContainer.Size = UDim2.new(1, 0, 1, -35)

            local up = Instance.new("TextButton")
            up.Name = "up"
            up.Parent = ContentContainer
            up.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
            up.TextColor3 = Color3.fromRGB(255, 255, 255)
            up.Position = UDim2.new(0, 10, 0, 5)
            up.Size = UDim2.new(0, 42, 0, 26)
            up.Font = Enum.Font.GothamBold
            up.Text = "UP"
            up.TextSize = 12

            local UpCorner = Instance.new("UICorner")
            UpCorner.CornerRadius = UDim.new(0, 6)
            UpCorner.Parent = up

            local down = Instance.new("TextButton")
            down.Name = "down"
            down.Parent = ContentContainer
            down.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
            down.Position = UDim2.new(0, 10, 0, 35)
            down.Size = UDim2.new(0, 42, 0, 26)
            down.Font = Enum.Font.GothamBold
            down.Text = "DOWN"
            down.TextColor3 = Color3.fromRGB(255, 255, 255)
            down.TextSize = 11

            local DownCorner = Instance.new("UICorner")
            DownCorner.CornerRadius = UDim.new(0, 6)
            DownCorner.Parent = down

            local plus = Instance.new("TextButton")
            plus.Name = "plus"
            plus.Parent = ContentContainer
            plus.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
            plus.Position = UDim2.new(0, 58, 0, 5)
            plus.Size = UDim2.new(0, 42, 0, 26)
            plus.Font = Enum.Font.GothamBold
            plus.Text = "+"
            plus.TextColor3 = Color3.fromRGB(255, 255, 255)
            plus.TextSize = 14

            local PlusCorner = Instance.new("UICorner")
            PlusCorner.CornerRadius = UDim.new(0, 6)
            PlusCorner.Parent = plus

            local mine = Instance.new("TextButton")
            mine.Name = "mine"
            mine.Parent = ContentContainer
            mine.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
            mine.Position = UDim2.new(0, 58, 0, 35)
            mine.Size = UDim2.new(0, 42, 0, 26)
            mine.Font = Enum.Font.GothamBold
            mine.Text = "-"
            mine.TextColor3 = Color3.fromRGB(255, 255, 255)
            mine.TextSize = 14

            local MineCorner = Instance.new("UICorner")
            MineCorner.CornerRadius = UDim.new(0, 6)
            MineCorner.Parent = mine

            local speed = Instance.new("TextBox")
            speed.Name = "speed"
            speed.Parent = ContentContainer
            speed.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
            speed.Position = UDim2.new(0, 106, 0, 35)
            speed.Size = UDim2.new(0, 42, 0, 26)
            speed.Font = Enum.Font.GothamBold
            speed.Text = "1"
            speed.TextColor3 = Color3.fromRGB(255, 255, 255)
            speed.TextSize = 13
            speed.ClearTextOnFocus = false

            local SpeedCorner = Instance.new("UICorner")
            SpeedCorner.CornerRadius = UDim.new(0, 6)
            SpeedCorner.Parent = speed

            local onof = Instance.new("TextButton")
            onof.Name = "onof"
            onof.Parent = ContentContainer
            onof.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
            onof.Position = UDim2.new(0, 106, 0, 5)
            onof.Size = UDim2.new(0, 92, 0, 26)
            onof.Font = Enum.Font.GothamBold
            onof.Text = "FLY : OFF"
            onof.TextColor3 = Color3.fromRGB(255, 255, 255)
            onof.TextSize = 12

            local OnOfCorner = Instance.new("UICorner")
            OnOfCorner.CornerRadius = UDim.new(0, 6)
            OnOfCorner.Parent = onof

            local TopButtonsHolder = Instance.new("Frame")
            TopButtonsHolder.Parent = Frame
            TopButtonsHolder.BackgroundTransparency = 1
            TopButtonsHolder.Position = UDim2.new(1, -85, 0, 5)
            TopButtonsHolder.Size = UDim2.new(0, 80, 0, 25)

            local closebutton = Instance.new("TextButton")
            closebutton.Name = "Close"
            closebutton.Parent = TopButtonsHolder
            closebutton.BackgroundColor3 = Color3.fromRGB(255, 25, 0)
            closebutton.BackgroundTransparency = 1
            closebutton.Font = Enum.Font.GothamBold
            closebutton.Size = UDim2.new(0, 20, 0, 20)
            closebutton.Position = UDim2.new(1, -20, 0, 2)
            closebutton.Text = "X"
            closebutton.TextColor3 = Color3.fromRGB(255, 120, 120)
            closebutton.TextSize = 14

            local mini = Instance.new("TextButton")
            mini.Name = "minimize"
            mini.Parent = TopButtonsHolder
            mini.BackgroundTransparency = 1
            mini.Font = Enum.Font.GothamBold
            mini.Size = UDim2.new(0, 20, 0, 20)
            mini.Position = UDim2.new(1, -44, 0, 2)
            mini.Text = "-"
            mini.TextColor3 = Color3.fromRGB(255, 255, 255)
            mini.TextSize = 18

            local logoBtn = Instance.new("ImageButton")
            logoBtn.Name = "LogoButton"
            logoBtn.Parent = TopButtonsHolder
            logoBtn.BackgroundTransparency = 1
            logoBtn.Position = UDim2.new(1, -68, 0, 2)
            logoBtn.Size = UDim2.new(0, 20, 0, 20)
            logoBtn.Image = "https://i.postimg.cc/hP39YjVY/logo.png"

            speeds = 1
            local speaker = game:GetService("Players").LocalPlayer
            local nowe = false

            Message("PISIT x TATA", "FLY Loaded!", 3)

            local isMinimized = false
            local function ToggleMinimize()
                isMinimized = not isMinimized
                if isMinimized then
                    Frame.Size = UDim2.new(0, 210, 0, 35)
                    ContentContainer.Visible = false
                    mini.Text = "+"
                else
                    Frame.Size = UDim2.new(0, 210, 0, 100)
                    ContentContainer.Visible = true
                    mini.Text = "-"
                end
            end

            mini.MouseButton1Click:Connect(ToggleMinimize)
            logoBtn.MouseButton1Click:Connect(ToggleMinimize)

            closebutton.MouseButton1Click:Connect(function()
                main:Destroy()
            end)

            local function applySpeedLayers(targetSpeed)
                for i = 1, targetSpeed do
                    spawn(function()
                        local hb = game:GetService("RunService").Heartbeat	
                        tpwalking = true
                        local chr = game.Players.LocalPlayer.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        local currentTag = targetSpeed
                        while nowe and speeds >= currentTag and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
                    end)
                end
            end

            onof.MouseButton1Down:connect(function()
                if nowe == true then
                    nowe = false
                    onof.Text = "FLY : OFF"
                    onof.BackgroundColor3 = Color3.fromRGB(200, 20, 20)

                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
                    speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                else 
                    nowe = true
                    onof.Text = "FLY : ON"
                    onof.BackgroundColor3 = Color3.fromRGB(40, 180, 40)

                    applySpeedLayers(speeds)
                    
                    local Char = game.Players.LocalPlayer.Character
                    if Char:FindFirstChild("Animate") then
                        Char.Animate.Disabled = true
                    end
                    local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

                    for i,v in next, Hum:GetPlayingAnimationTracks() do
                        v:AdjustSpeed(0)
                    end
                    
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
                    speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
                    speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                end

                if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
                    local plr = game.Players.LocalPlayer
                    local torso = plr.Character:FindFirstChild("Torso")
                    if not torso then return end
                    local bg = Instance.new("BodyGyro", torso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.cframe = torso.CFrame
                    local bv = Instance.new("BodyVelocity", torso)
                    bv.velocity = Vector3.new(0,0.1,0)
                    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                    if nowe == true then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    
                    local ctrl = {f = 0, b = 0, l = 0, r = 0}
                    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                    local maxspeed = 50
                    local flyspeed = 0

                    while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                        game:GetService("RunService").RenderStepped:Wait()
                        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                            flyspeed = flyspeed + .5 + (flyspeed / maxspeed)
                            if flyspeed > maxspeed then flyspeed = maxspeed end
                        elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and flyspeed ~= 0 then
                            flyspeed = flyspeed - 1
                            if flyspeed < 0 then flyspeed = 0 end
                        end
                        bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    if plr.Character:FindFirstChild("Animate") then
                        plr.Character.Animate.Disabled = false
                    end
                    tpwalking = false
                else
                    local plr = game.Players.LocalPlayer
                    local UpperTorso = plr.Character:FindFirstChild("UpperTorso")
                    if not UpperTorso then return end
                    local bg = Instance.new("BodyGyro", UpperTorso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.cframe = UpperTorso.CFrame
                    local bv = Instance.new("BodyVelocity", UpperTorso)
                    bv.velocity = Vector3.new(0,0.1,0)
                    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                    if nowe == true then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    
                    while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                        task.wait()
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    if plr.Character:FindFirstChild("Animate") then
                        plr.Character.Animate.Disabled = false
                    end
                    tpwalking = false
                end
            end)

            local tis
            up.MouseButton1Down:connect(function()
                tis = up.MouseEnter:connect(function()
                    while tis do
                        task.wait()
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
                        end
                    end
                end)
            end)

            up.MouseLeave:connect(function()
                if tis then
                    tis:Disconnect()
                    tis = nil
                end
            end)

            local dis
            down.MouseButton1Down:connect(function()
                dis = down.MouseEnter:connect(function()
                    while dis do
                        task.wait()
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0)
                        end
                    end
                end)
            end)

            down.MouseLeave:connect(function()
                if dis then
                    dis:Disconnect()
                    dis = nil
                end
            end)

            plus.MouseButton1Down:connect(function()
                speeds = speeds + 1
                speed.Text = tostring(speeds)
                
                if nowe then
                    applySpeedLayers(speeds)
                end
            end)

            mine.MouseButton1Down:connect(function()
                if speeds <= 1 then
                    speeds = 1
                    speed.Text = '1'
                else
                    speeds = speeds - 1
                    speed.Text = tostring(speeds)
                end
            end)

            speed.FocusLost:Connect(function(enterPressed)
                local num = tonumber(speed.Text)
                if num and num > 0 then
                    speeds = math.floor(num)
                    speed.Text = tostring(speeds)
                    if nowe then
                        applySpeedLayers(speeds)
                    end
                else
                    speed.Text = tostring(speeds)
                end
            end)
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริปต์หยุดเวลา (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปต์หยุดเวลา",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT HUB - DIO Time Stop Script
            -- ====================================================================
            local Players = game:GetService("Players")
            local StarterGui = game:GetService("StarterGui")
            local TweenService = game:GetService("TweenService")
            local Lighting = game:GetService("Lighting")

            local player = Players.LocalPlayer

            if game:GetService("CoreGui"):FindFirstChild("PisitHubTimeStopGUI") then
                StarterGui:SetCore("SendNotification", {
                    Title = "แจ้งเตือน",
                    Text = "คุณรันไปแล้ว",
                    Duration = 3
                })
                return
            end

            local char = player.Character or player.CharacterAdded:Wait()
            local head = char:WaitForChild("Head")
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            local root = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            local mouse = player:GetMouse()

            local frozenobjectstable = {}
            local stoppedtime = false

            local timestopeffect = Instance.new("ColorCorrectionEffect")
            timestopeffect.Parent = Lighting
            timestopeffect.Saturation = 0
            timestopeffect.Contrast = 0
            timestopeffect.Enabled = true

            local function createSphere()
                local sphere = Instance.new("Part")
                sphere.Parent = torso
                sphere.Material = Enum.Material.ForceField
                sphere.Size = Vector3.new(0, 0, 0)
                sphere.Shape = Enum.PartType.Ball
                sphere.CanCollide = false
                sphere.Massless = true
                sphere.Color = Color3.new(1, 1, 1)
                sphere.CastShadow = false

                local weld = Instance.new("Weld")
                weld.Part0 = sphere
                weld.Part1 = torso
                weld.C0 = torso.CFrame
                weld.C1 = torso.CFrame
                weld.Parent = sphere
                return sphere
            end

            local timestopsphere1 = createSphere()
            local timestopsphere2 = createSphere()
            local timestopsphere3 = createSphere()

            local function createSound(parent, id, vol)
                local s = Instance.new("Sound", parent)
                s.SoundId = "rbxassetid://"..id
                s.Volume = vol
                return s
            end

            local timestopvoiceline = createSound(head, "7514417921", 5)
            local injuredtimestopvoiceline = createSound(head, "6043864223", 5)
            local tssfx = createSound(head, "5679636294", 5)
            local timeresumevoiceline = createSound(head, "4329802996", 5)
            local injuredtimeresumevoiceline = createSound(head, "6043853981", 5)

            local function timestop()
                if stoppedtime == true then return end
                if humanoid.Health < 50 then
                    injuredtimestopvoiceline:Play()
                    task.wait(1)
                    tssfx:Play()
                elseif humanoid.Health > 50 then
                    timestopvoiceline:Play()
                    task.wait(1.6)
                end
                settings().Network.IncomingReplicationLag = math.huge
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if not v.Anchored == true then
                            if not v:IsDescendantOf(char) then
                                v.Anchored = true
                                table.insert(frozenobjectstable, v)
                            end
                        end
                    end
                end
                coroutine.resume(coroutine.create(function()
                    coroutine.resume(coroutine.create(function()
                        timestopeffect.Enabled = true
                        TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {FieldOfView = 250}):Play();
                        coroutine.resume(coroutine.create(function()
                            while stoppedtime == false do
                                TweenService:Create(timestopeffect, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Contrast = -2}):Play();
                                task.wait(0.3)
                                TweenService:Create(timestopeffect, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Saturation = -1}):Play();
                                task.wait(0.2)
                                TweenService:Create(timestopeffect, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Saturation = -2}):Play();
                                task.wait()
                                TweenService:Create(timestopeffect, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Contrast = -2.4}):Play();
                                task.wait(0.3)
                                TweenService:Create(timestopeffect, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Saturation = 1}):Play();
                                task.wait(0.2)
                                TweenService:Create(timestopeffect, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Saturation = -2}):Play();
                            end
                        end))
                        task.wait(1.7)
                        TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Quart), {FieldOfView = 70}):Play();
                        TweenService:Create(timestopeffect, TweenInfo.new(1, Enum.EasingStyle.Quart), {Contrast = 0}):Play();
                        TweenService:Create(timestopeffect, TweenInfo.new(1, Enum.EasingStyle.Quart), {Saturation = -0.8}):Play();
                    end))
                    coroutine.resume(coroutine.create(function()
                        for _ = 1, 65 do
                            task.wait()
                            local offset1 = math.random(-650, 650) / 700
                            local offset2 = math.random(-650, 650) / 700
                            local offset3 = math.random(-650, 650) / 700
                            TweenService:Create(humanoid, TweenInfo.new(0.1), {CameraOffset = Vector3.new(offset1, offset2, offset3)}):Play();
                        end
                        TweenService:Create(humanoid, TweenInfo.new(0.1), {CameraOffset = Vector3.new(0, 0, 0)}):Play();
                    end))
                    coroutine.resume(coroutine.create(function()
                        TweenService:Create(timestopsphere1, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(45, 45, 45)}):Play();
                        TweenService:Create(timestopsphere2, TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(40, 40, 40)}):Play();
                        TweenService:Create(timestopsphere3, TweenInfo.new(1.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(35, 35, 35)}):Play();
                        task.wait(1.7)
                        TweenService:Create(timestopsphere1, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(0, 0, 0)}):Play();
                        TweenService:Create(timestopsphere2, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(0, 0, 0)}):Play();
                        TweenService:Create(timestopsphere3, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {Size = Vector3.new(0, 0, 0)}):Play();
                    end))
                    coroutine.resume(coroutine.create(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("ParticleEmitter") or v:IsA("Fire") then
                                TweenService:Create(v, TweenInfo.new(3), {TimeScale = 0}):Play();
                            end
                        end
                    end))
                    coroutine.resume(coroutine.create(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Sound") and not v:IsDescendantOf(char) then
                                TweenService:Create(v, TweenInfo.new(4), {PlaybackSpeed = 0}):Play();
                            end
                        end
                    end))
                end))
                stoppedtime = true
            end

            local function timeresume()
                if stoppedtime == false then return end
                if humanoid.Health < 50 then
                    injuredtimeresumevoiceline:Play()
                    task.wait(0.6)
                elseif humanoid.Health > 50 then
                    timeresumevoiceline:Play()
                    task.wait(0.9)
                end
                settings().Network.IncomingReplicationLag = 0
                for _, v in pairs(frozenobjectstable) do
                    if v:IsA("BasePart") then
                        v.Anchored = false
                    end
                end
                coroutine.resume(coroutine.create(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ParticleEmitter") or v:IsA("Fire") then
                            TweenService:Create(v, TweenInfo.new(3), {TimeScale = 1}):Play();
                        end
                    end
                end))
                coroutine.resume(coroutine.create(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Sound") and not v:IsDescendantOf(char) then
                            TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 1}):Play();
                        end
                    end
                end))
                TweenService:Create(timestopeffect, TweenInfo.new(2, Enum.EasingStyle.Quart), {Saturation = 0}):Play();
                stoppedtime = false
                frozenobjectstable = {}
            end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "PisitHubTimeStopGUI"
            screenGui.Parent = player:WaitForChild("PlayerGui")
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.ResetOnSpawn = false

            local Frame = Instance.new("Frame")
            Frame.Parent = screenGui
            Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Frame.BorderColor3 = Color3.fromRGB(255, 100, 100)
            Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
            Frame.Size = UDim2.new(0, 160, 0, 85)
            Frame.Active = true
            Frame.Draggable = true

            local MainUiGradient = Instance.new("UIGradient")
            MainUiGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 20, 20)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 5, 5))
            })
            MainUiGradient.Rotation = 45
            MainUiGradient.Parent = Frame

            local MainCorner = Instance.new("UICorner")
            MainCorner.CornerRadius = UDim.new(0, 10)
            MainCorner.Parent = Frame

            local MainStroke = Instance.new("UIStroke")
            MainStroke.Color = Color3.fromRGB(255, 100, 100)
            MainStroke.Thickness = 1.5
            MainStroke.Parent = Frame

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = Frame
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0, 10, 0, 5)
            TextLabel.Size = UDim2.new(0, 90, 0, 25)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = "PISIT DIO"
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 12
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ContentContainer = Instance.new("Frame")
            ContentContainer.Name = "ContentContainer"
            ContentContainer.Parent = Frame
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.Position = UDim2.new(0, 0, 0, 30)
            ContentContainer.Size = UDim2.new(1, 0, 1, -30)

            local timeStopButton = Instance.new("TextButton")
            timeStopButton.Parent = ContentContainer
            timeStopButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
            timeStopButton.Position = UDim2.new(0, 10, 0, 6)
            timeStopButton.Size = UDim2.new(0, 140, 0, 38)
            timeStopButton.Font = Enum.Font.GothamBold
            timeStopButton.Text = "เปิดหยุดเวลา"
            timeStopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            timeStopButton.TextSize = 13

            local timeStopCorner = Instance.new("UICorner")
            timeStopCorner.CornerRadius = UDim.new(0, 6)
            timeStopCorner.Parent = timeStopButton

            local TopButtonsHolder = Instance.new("Frame")
            TopButtonsHolder.Parent = Frame
            TopButtonsHolder.BackgroundTransparency = 1
            TopButtonsHolder.Position = UDim2.new(1, -85, 0, 5)
            TopButtonsHolder.Size = UDim2.new(0, 80, 0, 25)

            local closebutton = Instance.new("TextButton")
            closebutton.Name = "Close"
            closebutton.Parent = TopButtonsHolder
            closebutton.BackgroundTransparency = 1
            closebutton.Font = Enum.Font.GothamBold
            closebutton.Size = UDim2.new(0, 20, 0, 20)
            closebutton.Position = UDim2.new(1, -20, 0, 2)
            closebutton.Text = "X"
            closebutton.TextColor3 = Color3.fromRGB(255, 120, 120)
            closebutton.TextSize = 14

            local mini = Instance.new("TextButton")
            mini.Name = "minimize"
            mini.Parent = TopButtonsHolder
            mini.BackgroundTransparency = 1
            mini.Font = Enum.Font.GothamBold
            mini.Size = UDim2.new(0, 20, 0, 20)
            mini.Position = UDim2.new(1, -44, 0, 2)
            mini.Text = "-"
            mini.TextColor3 = Color3.fromRGB(200, 200, 200)
            mini.TextSize = 18

            local logoBtn = Instance.new("ImageButton")
            logoBtn.Name = "LogoButton"
            logoBtn.Parent = TopButtonsHolder
            logoBtn.BackgroundTransparency = 1
            logoBtn.Position = UDim2.new(1, -68, 0, 2)
            logoBtn.Size = UDim2.new(0, 20, 0, 20)
            logoBtn.Image = "https://i.postimg.cc/hP39YjVY/logo.png"

            local isMinimized = false
            local function ToggleMinimize()
                isMinimized = not isMinimized
                if isMinimized then
                    Frame.Size = UDim2.new(0, 160, 0, 32)
                    ContentContainer.Visible = false
                    mini.Text = "+"
                else
                    Frame.Size = UDim2.new(0, 160, 0, 85)
                    ContentContainer.Visible = true
                    mini.Text = "-"
                end
            end

            mini.MouseButton1Click:Connect(ToggleMinimize)
            logoBtn.MouseButton1Click:Connect(ToggleMinimize)

            closebutton.MouseButton1Click:Connect(function()
                screenGui:Destroy()
            end)

            timeStopButton.MouseButton1Click:Connect(function()
                if stoppedtime == false then
                    timestop()
                    timeStopButton.Text = "เลิกหยุดเวลา"
                    timeStopButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
                else
                    timeresume()
                    timeStopButton.Text = "เปิดหยุดเวลา"
                    timeStopButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
                end
            end)

            mouse.KeyDown:Connect(function(key)
                if key == "f" then
                    if stoppedtime == false then
                        timestop()
                        timeStopButton.Text = "เลิกหยุดเวลา"
                        timeStopButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
                    else
                        timeresume()
                        timeStopButton.Text = "เปิดหยุดเวลา"
                        timeStopButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
                    end
                end
            end)

            StarterGui:SetCore("SendNotification", {
                Title = "PISIT HUB",
                Text = "DIO Loaded!",
                Duration = 3
            })
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริป สุคุนะ x PISIT (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริป สุคุนะ x PISIT",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT HUB x Sukuna (Infinite Domain Expansion Edition)
            -- ====================================================================
            if game:GetService("CoreGui"):FindFirstChild("PisitSukunaUI") then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "แจ้งเตือนเว้ย",
                    Text = "สคริปต์นี้ถูกรันไปแล้ว",
                    Duration = 3,
                    Button1 = "เออกูรู้"
                })
                return
            end

            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Lighting = game:GetService("Lighting")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local CoreGui = game:GetService("CoreGui")
            local TweenService = game:GetService("TweenService")
            local StarterGui = game:GetService("StarterGui")
            local TextChatService = game:GetService("TextChatService")
            local Chat = game:GetService("Chat")

            local player = Players.LocalPlayer

            task.spawn(function()
                task.wait(3)
                pcall(function()
                    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                        local channels = TextChatService:WaitForChild("TextChannels", 2)
                        if channels then
                            local general = channels:FindFirstChild("RBXGeneral")
                            if general then
                                general:SendAsync("-r6")
                                return
                            end
                        end
                    end
                    Chat:Chat(player.Character or player.CharacterAdded:Wait(), "-r6", Enum.ChatColor.Red)
                end)
            end)

            task.wait(2)

            pcall(function()
                if not isfile("Sukuna.rbxmx") then
                    writefile("Sukuna.rbxmx", game:HttpGet("https://github.com/ian49972/RBXMS/raw/refs/heads/main/Sukuna.rbxmx"))
                end
            end)

            pcall(function() writefile("SUKUNA.mp3", game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/ZXTAta/refs/heads/main/Sukuna.v1.mp3")) end)
            pcall(function() writefile("LAUGH.mp3", game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/ZXTAta/refs/heads/main/LAUGH.mp3")) end)
            pcall(function() writefile("ArrowExplode.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/ArrowExplode.mp3")) end)
            pcall(function() writefile("Furnance.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/Furnance.mp3")) end)
            pcall(function() writefile("HAHAHA.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/HAHAHA.mp3")) end)
            pcall(function() writefile("SLASH.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/SLASH.mp3")) end)

            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local humanoid = character:WaitForChild("Humanoid")
            local camera = workspace.CurrentCamera

            local EasingStyleMap = {
                [Enum.PoseEasingStyle.Linear]   = Enum.EasingStyle.Linear,
                [Enum.PoseEasingStyle.Bounce]   = Enum.EasingStyle.Bounce,
                [Enum.PoseEasingStyle.Cubic]    = Enum.EasingStyle.Cubic,
                [Enum.PoseEasingStyle.Elastic]  = Enum.EasingStyle.Elastic,
                [Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
            }

            local EasingDirectionMap = {
                [Enum.PoseEasingDirection.In]    = Enum.EasingDirection.In,
                [Enum.PoseEasingDirection.Out]   = Enum.EasingDirection.Out,
                [Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
            }

            local function PlayKeyframeSequence(Model, KeyframeSequence, SpeedMult)
                SpeedMult = SpeedMult or 1
                local keyframes = {}
                for _, kf in ipairs(KeyframeSequence:GetKeyframes()) do
                    table.insert(keyframes, {Time = kf.Time, KF = kf})
                end
                table.sort(keyframes, function(a,b) return a.Time < b.Time end)
                if #keyframes == 0 then return end

                local motorMap, boneMap, valueMap, tweenList = {}, {}, {}, {}

                local function ResolveInstance(pose)
                    local name = pose.Name
                    if motorMap[name] then return motorMap[name], "Motor6D" end
                    if boneMap[name] then return boneMap[name], "Bone" end

                    for _, motor in ipairs(Model:GetDescendants()) do
                        if motor:IsA("Motor6D") and motor.Part1 and motor.Part0 then
                            if motor.Part1.Name == name and motor.Part0.Name == pose.Parent.Name then
                                motorMap[name] = motor
                                return motor, "Motor6D"
                            end
                        end
                    end
                    for _, bone in ipairs(Model:GetDescendants()) do
                        if bone:IsA("Bone") and bone.Name == name and bone.Parent and bone.Parent.Name == pose.Parent.Name then
                            boneMap[name] = bone
                            return bone, "Bone"
                        end
                    end
                    return nil, nil
                end

                local poseTables = {}
                for i, entry in ipairs(keyframes) do
                    local tab = {Time = entry.Time, Poses = {}}
                    for _, pose in ipairs(entry.KF:GetDescendants()) do
                        if pose:IsA("Pose") and pose.Weight > 0 then
                            local instance, typ = ResolveInstance(pose)
                            if instance then
                                if not valueMap[pose.Name] then
                                    local val = Instance.new("CFrameValue")
                                    val.Name = "AnimValue"
                                    val.Parent = instance
                                    valueMap[pose.Name] = val
                                end
                                tab.Poses[pose.Name] = { Instance = instance, Type = typ, CFrame = pose.CFrame, Style = pose.EasingStyle, Dir = pose.EasingDirection }
                            end
                        end
                    end
                    poseTables[i] = tab
                end

                for i = 1, #poseTables-1 do
                    local kf1, kf2 = poseTables[i], poseTables[i+1]
                    local duration = (kf2.Time - kf1.Time) / SpeedMult
                    local group = {Duration = duration, Tweens = {}}
                    for name, data2 in pairs(kf2.Poses) do
                        local data1 = kf1.Poses[name] or poseTables[1].Poses[name]
                        if data1 then
                            local ti = TweenInfo.new(duration, EasingStyleMap[data2.Style] or Enum.EasingStyle.Linear, EasingDirectionMap[data2.Dir] or Enum.EasingDirection.InOut)
                            group.Tweens[name] = TweenService:Create(valueMap[name], ti, {Value = data2.CFrame})
                        end
                    end
                    table.insert(tweenList, group)
                end

                local heartbeatConn = RunService.Heartbeat:Connect(function()
                    for name, valObj in pairs(valueMap) do
                        local entry = poseTables[1].Poses[name]
                        if entry then entry.Instance.Transform = valObj.Value end
                    end
                end)

                local playing = true
                local function PlayOnce()
                    for _, group in ipairs(tweenList) do
                        for _, tween in pairs(group.Tweens) do tween:Play() end
                        task.wait(group.Duration)
                    end
                end

                task.spawn(function()
                    while playing and Model and Model.Parent do
                        PlayOnce()
                        task.wait()
                    end
                end)

                return {
                    Stop = function()
                        playing = false
                        if heartbeatConn then heartbeatConn:Disconnect() end
                        for _, group in ipairs(tweenList) do
                            for _, tween in pairs(group.Tweens) do tween:Cancel() end
                        end
                        for _, v in pairs(valueMap) do v:Destroy() end
                    end
                }
            end

            local animModel = game:GetObjects(getcustomasset("Sukuna.rbxmx"))[1]
            animModel.Parent = ReplicatedStorage
            local AnimsFolder = animModel:WaitForChild("Anims")
            local EffectsFolder = animModel:WaitForChild("Effects")
            local DomainFolder = EffectsFolder:WaitForChild("Domain")
            local FurnanceFolder = EffectsFolder:WaitForChild("Furnance")

            local malevolentShrine = DomainFolder:FindFirstChild("MalevolentShrine", true)
            local awakenKeyframe = AnimsFolder:FindFirstChild("Awaken", true)
            local shrineKeyframe = AnimsFolder:FindFirstChild("Shrine", true)

            local FX = DomainFolder:FindFirstChild("FX", true)
            local GroundFX = DomainFolder:FindFirstChild("GroundFX", true)
            local Attachment1 = DomainFolder:FindFirstChild("Attachment", true)
            local Attachment2 = DomainFolder:FindFirstChild("Attachment2", true)
            local RedAttachment = FurnanceFolder:FindFirstChild("Red")
            local BlackAttachment = FurnanceFolder:FindFirstChild("Black")

            local leftHandle, rightHandle, leftFingerMotor, rightFingerMotor

            local function startEffects()
                local shakeConn = RunService.RenderStepped:Connect(function()
                    local rx = (math.random() - 0.5) * 0.08
                    local ry = (math.random() - 0.5) * 0.08
                    local rz = (math.random() - 0.5) * 0.06
                    camera.CFrame = camera.CFrame * CFrame.Angles(rx, ry, rz)
                end)
                return shakeConn
            end

            local function hideFingers()
                if leftHandle then
                    for _, part in ipairs(leftHandle:GetDescendants()) do
                        if part:IsA("BasePart") then part.Transparency = 1 part.CanCollide = false end
                    end
                end
                if rightHandle then
                    for _, part in ipairs(rightHandle:GetDescendants()) do
                        if part:IsA("BasePart") then part.Transparency = 1 part.CanCollide = false end
                    end
                end
            end

            local function destroyFingers()
                if leftFingerMotor then leftFingerMotor:Destroy() leftFingerMotor = nil end
                if rightFingerMotor then rightFingerMotor:Destroy() rightFingerMotor = nil end
                if leftHandle then leftHandle:Destroy() leftHandle = nil end
                if rightHandle then rightHandle:Destroy() rightHandle = nil end
            end

            local function spawnFingers(assetId)
                destroyFingers()
                local ok, model = pcall(function() return game:GetObjects(assetId)[1] end)
                if not ok or not model then return end
                leftHandle = model:FindFirstChild("LeftHandle")
                rightHandle = model:FindFirstChild("RightHandle")
                if not (leftHandle and rightHandle) then model:Destroy() return end

                local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
                local skinColor = (leftArm and leftArm.Color) or (rightArm and rightArm.Color) or Color3.fromRGB(255, 204, 153)
                local handOffset = CFrame.new(0, -0.85, 0)

                for _, part in pairs(leftHandle:GetDescendants()) do if part:IsA("BasePart") then part.Color = skinColor end end
                leftFingerMotor = Instance.new("Motor6D")
                leftFingerMotor.Name = "LeftFingerJoint"
                leftFingerMotor.Part0 = leftArm
                leftFingerMotor.Part1 = leftHandle:FindFirstChildWhichIsA("BasePart") or leftHandle
                leftFingerMotor.C0 = handOffset
                leftFingerMotor.Parent = leftArm
                leftHandle.Parent = character

                for _, part in pairs(rightHandle:GetDescendants()) do if part:IsA("BasePart") then part.Color = skinColor end end
                rightFingerMotor = Instance.new("Motor6D")
                rightFingerMotor.Name = "RightFingerJoint"
                rightFingerMotor.Part0 = rightArm
                rightFingerMotor.Part1 = rightHandle:FindFirstChildWhichIsA("BasePart") or rightHandle
                rightFingerMotor.C0 = handOffset
                rightFingerMotor.Parent = rightArm
                rightHandle.Parent = character
                model:Destroy()
            end

            local function tweenShrine(fromCF, toCF, time, onDone)
                local startTime = tick()
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    local alpha = math.clamp((tick() - startTime) / time, 0, 1)
                    malevolentShrine:PivotTo(fromCF:Lerp(toCF, alpha))
                    if alpha >= 1 then
                        conn:Disconnect()
                        if onDone then onDone() end
                    end
                end)
            end

            local function resetShrine()
                if FX then FX.Parent = nil end
                if GroundFX then GroundFX.Parent = nil end
                TweenService:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), {ClockTime = 14}):Play()
                if malevolentShrine.Parent == workspace then
                    local current = malevolentShrine:GetPivot()
                    local down = current * CFrame.new(0, -60, 0)
                    tweenShrine(current, down, 2, function()
                        malevolentShrine.Parent = ReplicatedStorage
                    end)
                end
            end

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "PisitSukunaUI"
            ScreenGui.Parent = CoreGui
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.ResetOnSpawn = false

            local MainFrame = Instance.new("Frame", ScreenGui)
            MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            MainFrame.BorderSizePixel = 0
            MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
            MainFrame.Size = UDim2.new(0, 220, 0, 100)
            MainFrame.Active = true
            MainFrame.Draggable = true

            Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

            local Stroke = Instance.new("UIStroke", MainFrame)
            Stroke.Color = Color3.fromRGB(200, 15, 15)
            Stroke.Thickness = 2

            local Grad = Instance.new("UIGradient", MainFrame)
            Grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 10, 10)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
            })
            Grad.Rotation = 45

            local Title = Instance.new("TextLabel", MainFrame)
            Title.Size = UDim2.new(1, 0, 0, 35)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamBold
            Title.Text = "PISIT HUB x Sukuna"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextSize = 15

            local ActionBtn = Instance.new("TextButton", MainFrame)
            ActionBtn.Size = UDim2.new(1, -20, 0, 40)
            ActionBtn.Position = UDim2.new(0, 10, 0, 45)
            ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
            ActionBtn.Font = Enum.Font.GothamBold
            ActionBtn.Text = "แปลงร่าง"
            ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ActionBtn.TextSize = 14
            ActionBtn.BorderSizePixel = 0
            Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

            local step = 1

            ActionBtn.MouseButton1Click:Connect(function()
                if step == 1 then
                    step = 2
                    ActionBtn.Text = "กำลังแปลงร่าง"
                    ActionBtn.BackgroundColor3 = Color3.fromRGB(100, 10, 10)
                    ActionBtn.Active = false

                    local head = character:FindFirstChild("Head")
                    if head and not head:FindFirstChild("SukunaFace") then
                        local decal = Instance.new("Decal")
                        decal.Name = "SukunaFace"
                        decal.Texture = "rbxassetid://16324571117"
                        decal.Face = Enum.NormalId.Front
                        decal.Parent = head
                        decal.Transparency = 1
                        TweenService:Create(decal, TweenInfo.new(1), {Transparency = 0}):Play()
                    end

                    local laughSound = Instance.new("Sound")
                    pcall(function() laughSound.SoundId = getcustomasset("LAUGH.mp3") end)
                    laughSound.Volume = 1
                    laughSound.Parent = workspace
                    laughSound:Play()

                    hrp.Anchored = true
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if animator then animator:Destroy() end

                    local animPlayer = awakenKeyframe and PlayKeyframeSequence(character, awakenKeyframe, 1.1)

                    task.spawn(function()
                        task.wait(13)
                        local shirt = character:FindFirstChildOfClass("Shirt")
                        if shirt then shirt:Destroy() end
                    end)

                    task.wait(14)
                    if animPlayer then animPlayer.Stop() end
                    if not humanoid:FindFirstChildOfClass("Animator") then
                        Instance.new("Animator", humanoid)
                    end
                    hrp.Anchored = false

                    ActionBtn.Text = "กางอาณาเขต"
                    ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
                    ActionBtn.Active = true

                elseif step == 2 then
                    step = 3
                    ActionBtn.Text = "กำลังกางอาณาเขต"
                    ActionBtn.BackgroundColor3 = Color3.fromRGB(100, 10, 10)
                    ActionBtn.Active = false

                    local sfx = Instance.new("Sound")
                    pcall(function() sfx.SoundId = getcustomasset("SUKUNA.mp3") end)
                    sfx.Volume = 1
                    sfx.Parent = workspace
                    sfx:Play()

                    spawnFingers("rbxassetid://18637374258")

                    if shrineKeyframe then
                        local animator = humanoid:FindFirstChildOfClass("Animator")
                        if animator then animator:Destroy() end
                        hrp.Anchored = true
                        local domainAnimPlayer = PlayKeyframeSequence(character, shrineKeyframe, 1)

                        task.delay(4, function()
                            if domainAnimPlayer then domainAnimPlayer.Stop() end
                            local red = RedAttachment and RedAttachment:Clone()
                            if red then red.Parent = hrp task.delay(3, function() if red then red:Destroy() end end) end

                            task.delay(3, function()
                                local black = BlackAttachment and BlackAttachment:Clone()
                                if black then
                                    black.Parent = hrp
                                    task.delay(2, function()
                                        if black then black:Destroy() end
                                        if Attachment1 then Attachment1.Parent = hrp end
                                        if Attachment2 then Attachment2.Parent = hrp end
                                        for _, att in pairs({Attachment1, Attachment2}) do
                                            if att then
                                                for _, p in ipairs(att:GetChildren()) do
                                                    if p:IsA("ParticleEmitter") then
                                                        p.Enabled = true
                                                        task.delay(0.5, function() if p and p.Parent then p.Enabled = false end end)
                                                    end
                                                end
                                            end
                                        end
                                    end)
                                end
                            end)
                        end)
                    end

                    task.delay(20, function()
                        if not humanoid:FindFirstChildOfClass("Animator") then Instance.new("Animator", humanoid) end
                        hrp.Anchored = false
                        hideFingers()
                        destroyFingers()
                        for _, att in pairs({Attachment1, Attachment2}) do
                            if att then
                                for _, p in ipairs(att:GetChildren()) do
                                    if p:IsA("ParticleEmitter") then p.Enabled = false end
                                end
                            end
                        end
                    end)

                    task.wait(7)
                    if malevolentShrine.Parent ~= workspace then malevolentShrine.Parent = workspace end
                    TweenService:Create(Lighting, TweenInfo.new(2), {ClockTime = 0}):Play()

                    local back = hrp.CFrame - hrp.CFrame.LookVector * 25
                    local endPos = back.Position + Vector3.new(0, 1, 0)
                    local targetCF = CFrame.new(endPos, endPos + hrp.CFrame.LookVector)
                    local startCF = targetCF * CFrame.new(0, -100, 0)

                    malevolentShrine:PivotTo(startCF)
                    local rockPart = malevolentShrine:FindFirstChild("Rock2", true) or malevolentShrine:FindFirstChild("Rocks2", true)
                    local beam = rockPart and rockPart:FindFirstChildWhichIsA("Beam")
                    if beam then beam.Enabled = true end

                    task.wait(2)
                    tweenShrine(startCF, targetCF, 3, function()
                        task.wait(2)
                        local shakeConn = startEffects()
                        local shrine2 = malevolentShrine:FindFirstChild("Shrine2", true)
                        if shrine2 and shrine2:IsA("MeshPart") then
                            local centerCF = shrine2.CFrame
                            if FX then FX.Parent = workspace FX.CFrame = centerCF end
                            if GroundFX then GroundFX.Parent = workspace GroundFX.CFrame = centerCF * CFrame.new(0, -35, 0) end
                        end
                        if beam then beam.Enabled = false end

                        task.delay(32, function()
                            if shakeConn then shakeConn:Disconnect() end
                            resetShrine()
                        end)
                    end)

                    task.wait(3)
                    ActionBtn.Text = "กางอาณาเขต"
                    ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
                    ActionBtn.Active = true
                    step = 2
                end
            end)

            StarterGui:SetCore("SendNotification", {
                Title = "PISIT HUB x Sukuna",
                Text = "ระบบกลางอาณาเขตสุคุนะ",
                Duration = 4,
                Button1 = "เออไอ่เหี้ย"
            })
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริป โกโจ x PISIT (Inlined)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริป โกโจ x PISIT",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- PISIT HUB x Gojo / Murasaki (Extreme Ragdoll Knockback Edition)
            -- ====================================================================
            if game:GetService("CoreGui"):FindFirstChild("PisitGojoRagdollUI") then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "แจ้งเตือน",
                    Text = "สคริปต์นี้ถูกรันไปแล้ว!",
                    Duration = 3,
                    Button1 = "รับทราบ"
                })
                return
            end

            if not isfile("Gojo.rbxmx") then
                writefile("Gojo.rbxmx", game:HttpGet("https://github.com/ian49972/RBXMS/raw/refs/heads/main/Gojo.rbxmx"))
            end

            writefile("Purple.mp3", game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/ZXTAta/refs/heads/main/gojomarrsrgi.mp3"))
            writefile("UnlimitedPurple.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/UnlimitedPurple.mp3"))
            writefile("ImaginaryPurple.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/ImaginaryPurple.mp3"))
            writefile("Domain.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/Domain.mp3"))
            writefile("Honored.mp3", game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/ZXTAta/refs/heads/main/gojo.mp3"))

            local Players = game:GetService("Players")
            local TS = game:GetService("TweenService")
            local RunService = game:GetService("RunService")
            local Lighting = game:GetService("Lighting")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local CoreGui = game:GetService("CoreGui")
            local StarterGui = game:GetService("StarterGui")
            local TextChatService = game:GetService("TextChatService")
            local Chat = game:GetService("Chat")
            local Debris = game:GetService("Debris")

            local player = Players.LocalPlayer
            local playerGui = player:WaitForChild("PlayerGui")

            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channels = TextChatService:WaitForChild("TextChannels", 2)
                    if channels then
                        local general = channels:FindFirstChild("RBXGeneral")
                        if general then
                            general:SendAsync("-r6")
                        end
                    end
                else
                    Chat:Chat(player.Character or player.CharacterAdded:Wait(), "-r6", Enum.ChatColor.Blue)
                end
            end)

            local EasingStyleMap = {
                [Enum.PoseEasingStyle.Linear]   = Enum.EasingStyle.Linear,
                [Enum.PoseEasingStyle.Bounce]   = Enum.EasingStyle.Bounce,
                [Enum.PoseEasingStyle.Cubic]    = Enum.EasingStyle.Cubic,
                [Enum.PoseEasingStyle.Elastic]  = Enum.EasingStyle.Elastic,
                [Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
            }

            local EasingDirectionMap = {
                [Enum.PoseEasingDirection.In]    = Enum.EasingDirection.In,
                [Enum.PoseEasingDirection.Out]   = Enum.EasingDirection.Out,
                [Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
            }

            local function PlayKeyframeSequence(Model, KeyframeSequence, SpeedMult)
                SpeedMult = SpeedMult or 1
                local keyframes = {}
                for _, kf in ipairs(KeyframeSequence:GetKeyframes()) do
                    table.insert(keyframes, {Time = kf.Time, KF = kf})
                end
                table.sort(keyframes, function(a,b) return a.Time < b.Time end)

                if #keyframes == 0 then return end

                local jointData = {}     
                local motorMap = {}
                local boneMap = {}

                local function ResolveJoint(pose)
                    local name = pose.Name
                    if motorMap[name] then return motorMap[name], "Motor6D" end
                    if boneMap[name] then return boneMap[name], "Bone" end

                    for _, v in ipairs(Model:GetDescendants()) do
                        if v:IsA("Motor6D") and v.Part1 and v.Part1.Name == name then
                            motorMap[name] = v
                            return v, "Motor6D"
                        elseif v:IsA("Bone") and v.Name == name then
                            boneMap[name] = v
                            return v, "Bone"
                        end
                    end
                    return nil, nil
                end

                for _, entry in ipairs(keyframes) do
                    for _, pose in ipairs(entry.KF:GetDescendants()) do
                        if pose:IsA("Pose") and pose.Weight > 0 then
                            local joint, jtype = ResolveJoint(pose)
                            if joint then
                                if not jointData[pose.Name] then jointData[pose.Name] = {} end
                                table.insert(jointData[pose.Name], {
                                    time = entry.Time,
                                    cframe = pose.CFrame,
                                    style = pose.EasingStyle,
                                    dir = pose.EasingDirection,
                                    joint = joint,
                                    jtype = jtype
                                })
                            end
                        end
                    end
                end

                local totalLength = keyframes[#keyframes].Time / SpeedMult
                local isPlaying = true
                local startTime = os.clock()
                local connection

                connection = RunService.Heartbeat:Connect(function()
                    if not isPlaying or not Model or not Model.Parent then
                        if connection then connection:Disconnect() end
                        return
                    end

                    local elapsed = (os.clock() - startTime) * SpeedMult
                    local timePos = elapsed % totalLength

                    for jointName, poses in pairs(jointData) do
                        if #poses < 1 then continue end
                        local lastPose = poses[1]
                        local nextPose = poses[1]

                        for i = 1, #poses - 1 do
                            if timePos >= poses[i].time and timePos < poses[i+1].time then
                                lastPose = poses[i]
                                nextPose = poses[i+1]
                                break
                            end
                        end

                        if timePos >= poses[#poses].time then
                            lastPose = poses[#poses]
                            nextPose = poses[#poses]
                        end

                        local alpha = (nextPose.time > lastPose.time) and 
                            (timePos - lastPose.time) / (nextPose.time - lastPose.time) or 0

                        local style = EasingStyleMap[nextPose.style] or EasingStyleMap[lastPose.style] or Enum.EasingStyle.Linear
                        local dir = EasingDirectionMap[nextPose.dir] or EasingDirectionMap[lastPose.dir] or Enum.EasingDirection.InOut

                        local easedAlpha = TS:GetValue(alpha, style, dir)
                        local finalCF = lastPose.cframe:Lerp(nextPose.cframe, easedAlpha)

                        if lastPose.jtype == "Motor6D" then
                            lastPose.joint.Transform = finalCF
                        else
                            lastPose.joint.Transform = finalCF
                        end
                    end
                end)

                return {
                    Length = totalLength,
                    Stop = function() 
                        isPlaying = false 
                        if connection then connection:Disconnect() end 
                    end,
                    Play = function() startTime = os.clock() end
                }
            end

            task.spawn(function()
                task.wait(3)

                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "PisitGojoRagdollUI"
                ScreenGui.Parent = CoreGui
                ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                ScreenGui.ResetOnSpawn = false

                local MainFrame = Instance.new("Frame", ScreenGui)
                MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                MainFrame.BorderSizePixel = 0
                MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
                MainFrame.Size = UDim2.new(0, 220, 0, 100)
                MainFrame.Active = true
                MainFrame.Draggable = true

                Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

                local Stroke = Instance.new("UIStroke", MainFrame)
                Stroke.Color = Color3.fromRGB(50, 150, 255)
                Stroke.Thickness = 2

                local Grad = Instance.new("UIGradient", MainFrame)
                Grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 100, 200)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
                })
                Grad.Rotation = 45

                local Title = Instance.new("TextLabel", MainFrame)
                Title.Size = UDim2.new(1, 0, 0, 35)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.Text = "PISIT HUB x Gojo"
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextSize = 15

                local ActionBtn = Instance.new("TextButton", MainFrame)
                ActionBtn.Size = UDim2.new(1, -20, 0, 40)
                ActionBtn.Position = UDim2.new(0, 10, 0, 45)
                ActionBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 220)
                ActionBtn.Font = Enum.Font.GothamBold
                ActionBtn.Text = "1. แปลงร่าง"
                ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ActionBtn.TextSize = 14
                ActionBtn.BorderSizePixel = 0
                Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

                StarterGui:SetCore("SendNotification", {
                    Title = "PISIT HUB",
                    Text = "UI เปิดใช้งานแล้ว (โหมดสีฟ้า)",
                    Duration = 3,
                    Button1 = "ลุย"
                })

                local step = 1
                local asset = nil

                local originalLighting = {}
                for _, v in pairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
                        originalLighting[v.ClassName] = v:Clone()
                    end
                end
                local originalBrightness = Lighting.Brightness
                local originalAmbient = Lighting.Ambient
                local originalClockTime = Lighting.ClockTime
                local originalLightingStyle = Lighting.LightingStyle or Enum.LightingStyle.Soft

                ActionBtn.MouseButton1Click:Connect(function()
                    local char = player.Character or player.CharacterAdded:Wait()
                    local humanoid = char:WaitForChild("Humanoid")
                    local root = char:WaitForChild("HumanoidRootPart")

                    if step == 1 then
                        step = 2
                        ActionBtn.Text = "กำลังแปลงร่าง..."
                        ActionBtn.Active = false

                        local originalAnimator = humanoid:FindFirstChildOfClass("Animator")
                        if originalAnimator then originalAnimator:Destroy() end

                        local originalSpeed = humanoid.WalkSpeed
                        local originalHipHeight = humanoid.HipHeight
                        humanoid.WalkSpeed = 0

                        asset = game:GetObjects(getcustomasset("Gojo.rbxmx"))[1]
                        asset.Parent = ReplicatedStorage

                        local keyframe = asset:FindFirstChild("Anims", true):FindFirstChild("HonoredOne")
                        if not keyframe then return end

                        local sound = Instance.new("Sound", workspace)
                        sound.SoundId = getcustomasset("Honored.mp3")
                        sound.Volume = 1
                        sound:Play()

                        local controller = PlayKeyframeSequence(char, keyframe, 0.4)
                        controller.Play()

                        TS:Create(humanoid, TweenInfo.new(3, Enum.EasingStyle.Quad), {HipHeight = originalHipHeight + 100}):Play()

                        for _, v in pairs(Lighting:GetChildren()) do v:Destroy() end
                        local Bloom = Instance.new("BloomEffect", Lighting)
                        local Blur = Instance.new("BlurEffect", Lighting)
                        local ColorCor = Instance.new("ColorCorrectionEffect", Lighting)
                        local SunRays = Instance.new("SunRaysEffect", Lighting)
                        local Sky = Instance.new("Sky", Lighting)
                        local Atm = Instance.new("Atmosphere", Lighting)

                        Bloom.Intensity = 0.3 Bloom.Size = 10 Bloom.Threshold = 0.8
                        Blur.Size = 5
                        ColorCor.Brightness = 0.1 ColorCor.Contrast = 0.5 ColorCor.Saturation = -0.3 ColorCor.TintColor = Color3.fromRGB(255, 235, 203)
                        SunRays.Intensity = 0.075 SunRays.Spread = 0.727
                        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=151165214"
                        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=151165197"
                        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=151165224"
                        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=151165191"
                        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=151165206"
                        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=151165227"
                        Sky.SunAngularSize = 10

                        Lighting.Ambient = Color3.fromRGB(2,2,2)
                        Lighting.Brightness = 2.25
                        Lighting.ClockTime = 17

                        sound.Ended:Wait()
                        controller.Stop()

                        TS:Create(humanoid, TweenInfo.new(2, Enum.EasingStyle.Quad), {HipHeight = originalHipHeight}):Play()
                        humanoid.WalkSpeed = originalSpeed

                        for _, v in pairs(Lighting:GetChildren()) do v:Destroy() end
                        for _, original in pairs(originalLighting) do original:Clone().Parent = Lighting end
                        Lighting.ClockTime = originalClockTime
                        Lighting.Brightness = originalBrightness
                        Lighting.Ambient = originalAmbient

                        if humanoid and humanoid.Parent then
                            local newAnimator = Instance.new("Animator")
                            newAnimator.Parent = humanoid
                        end

                        Stroke.Color = Color3.fromRGB(150, 50, 255)
                        Grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 20, 200)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
                        })
                        ActionBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 220)
                        ActionBtn.Text = "2. ปล่อยมุราซากิ"
                        ActionBtn.Active = true
                        step = 2

                    elseif step == 2 then
                        ActionBtn.Text = "กำลังปล่อยมุราซากิ..."
                        ActionBtn.Active = false

                        local originalSpeed = humanoid.WalkSpeed
                        local originalAnimator = humanoid:FindFirstChild("Animator")
                        if originalAnimator then 
                            originalAnimator.Parent = nil 
                        end

                        Lighting.LightingStyle = Enum.LightingStyle.Realistic
                        TS:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                            ClockTime = 0,
                            Brightness = 0.3,
                            Ambient = Color3.fromRGB(10, 10, 20)
                        }):Play()

                        local screenGuiMsg = Instance.new("ScreenGui")
                        screenGuiMsg.Name = "GojoYapping"
                        screenGuiMsg.IgnoreGuiInset = true
                        screenGuiMsg.ResetOnSpawn = false
                        screenGuiMsg.Parent = playerGui

                        local blackFrame = Instance.new("Frame", screenGuiMsg)
                        blackFrame.Size = UDim2.new(1, 0, 1, 0)
                        blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
                        blackFrame.BorderSizePixel = 0

                        local gradient = Instance.new("UIGradient", blackFrame)
                        gradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 30)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                        }
                        gradient.Rotation = 90

                        local textLabel = Instance.new("TextLabel", blackFrame)
                        textLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
                        textLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.SciFi
                        textLabel.Text = "Oh, Well."
                        textLabel.TextColor3 = Color3.fromRGB(100, 160, 255)

                        local textGradient = Instance.new("UIGradient", textLabel)
                        textGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 170, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 230, 255))
                        }

                        task.spawn(function()
                            task.wait(3)
                            textLabel.Text = "Guess I'll be a little rough."
                            textLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
                            local tg = textLabel:FindFirstChildWhichIsA("UIGradient")
                            if tg then
                                tg.Color = ColorSequence.new{
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 110)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 180))
                                }
                            end
                            task.wait(2)
                            screenGuiMsg:Destroy()
                        end)

                        local hpFolder = asset:WaitForChild("Effects"):WaitForChild("HollowPurple"):Clone()
                        local blueOrb = hpFolder:FindFirstChild("BlueOrb") or hpFolder:FindFirstChild("Blue Orb")
                        local redOrb = hpFolder:FindFirstChild("RedOrb") or hpFolder:FindFirstChild("Red Orb")
                        local purple = hpFolder:FindFirstChild("Purple")
                        local purple2 = hpFolder:FindFirstChild("Purple2")

                        local blueWeld, redWeld, purpleWeld

                        if blueOrb then
                            blueOrb.CFrame = root.CFrame * CFrame.new(-5, 0, 8)
                            blueOrb.Anchored = true
                            blueOrb.Parent = workspace
                            
                            blueWeld = Instance.new("WeldConstraint", blueOrb)
                            blueWeld.Part0 = root
                            blueWeld.Part1 = blueOrb
                        end

                        local sound = Instance.new("Sound", workspace)
                        sound.SoundId = getcustomasset("Purple.mp3")
                        sound.Volume = 1
                        sound:Play()

                        humanoid.WalkSpeed = 0
                        task.wait(4)

                        local animPlayer = PlayKeyframeSequence(char, asset:WaitForChild("Anims"):WaitForChild("Purple"), 0.59)
                        animPlayer.Play()

                        task.wait(4)
                        if blueOrb then
                            local summon = blueOrb:FindFirstChild("Summon")
                            if summon then
                                for _, p in ipairs(summon:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end
                                task.wait(0.2)
                                for _, p in ipairs(summon:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = false end end
                            end

                            local attA = blueOrb:FindFirstChild("AttachmentA")
                            if attA then
                                for _, obj in ipairs(attA:GetDescendants()) do
                                    if obj:IsA("ParticleEmitter") then obj.Enabled = true
                                    elseif obj:IsA("PointLight") then obj.Brightness = 1 end
                                end
                            end

                            local BGround = blueOrb:FindFirstChild("Ground")
                            if BGround then
                                for _, p in ipairs(BGround:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end
                            end
                        end

                        if redOrb then
                            redOrb.CFrame = root.CFrame * CFrame.new(5, 0, 8)
                            redOrb.Anchored = true
                            redOrb.Parent = workspace
                            
                            redWeld = Instance.new("WeldConstraint", redOrb)
                            redWeld.Part0 = root
                            redWeld.Part1 = redOrb
                        end

                        task.wait(2)
                        if redOrb then
                            local summon = redOrb:FindFirstChild("Summon")
                            if summon then
                                for _, p in ipairs(summon:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end
                                task.wait(0.2)
                                for _, p in ipairs(summon:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = false end end
                            end

                            local attA = redOrb:FindFirstChild("AttachmentA")
                            if attA then
                                for _, obj in ipairs(attA:GetDescendants()) do
                                    if obj:IsA("ParticleEmitter") then obj.Enabled = true
                                    elseif obj:IsA("PointLight") then obj.Brightness = 1 end
                                end
                            end

                            local Ground = redOrb:FindFirstChild("Ground")
                            if Ground then
                                for _, p in ipairs(Ground:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end
                            end
                        end

                        task.wait(1)
                        if blueWeld then blueWeld:Destroy() end
                        if redWeld then redWeld:Destroy() end

                        if blueOrb and redOrb then
                            TS:Create(blueOrb, TweenInfo.new(6.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = root.CFrame * CFrame.new(0.5, 1, 8)}):Play()
                            TS:Create(redOrb, TweenInfo.new(6.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = root.CFrame * CFrame.new(-0.5, 1, 8)}):Play()
                        end

                        task.wait(3.8)
                        if blueOrb then blueOrb:Destroy() end
                        if redOrb then redOrb:Destroy() end

                        if purple then
                            purple.CFrame = root.CFrame * CFrame.new(0, 10, -20)
                            purple.Anchored = true
                            purple.Parent = workspace
                            
                            purpleWeld = Instance.new("WeldConstraint", purple)
                            purpleWeld.Part0 = root
                            purpleWeld.Part1 = purple
                        end

                        task.wait(7)
                        if purple then 
                            if purpleWeld then purpleWeld:Destroy() end
                            purple:Destroy() 
                        end

                        if purple2 then
                            purple2.Anchored = true
                            for _, v in ipairs(purple2:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    v.Anchored = true
                                    v.CanCollide = false
                                end
                            end

                            local lookDirection = root.CFrame.LookVector
                            local spawnCFrame = root.CFrame * CFrame.new(0, 10, -8)
                            
                            purple2.CFrame = spawnCFrame
                            purple2.Rotation = Vector3.new(0, math.deg(math.atan2(lookDirection.X, lookDirection.Z)), 0)
                            purple2.Parent = workspace

                            task.spawn(function()
                                local ragdollDuration = 3
                                local startTime = os.clock()
                                
                                pcall(function()
                                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                                end)
                                
                                local attachment = Instance.new("Attachment", root)
                                local linearForce = Instance.new("LinearVelocity", root)
                                local angularVelocity = Instance.new("AngularVelocity", root)
                                
                                linearForce.Attachment0 = attachment
                                linearForce.MaxForce = math.huge
                                linearForce.VectorVelocity = (-lookDirection * 55) + Vector3.new(0, 35, 0)
                                
                                angularVelocity.Attachment0 = attachment
                                angularVelocity.MaxTorque = math.huge
                                angularVelocity.AngularVelocity = Vector3.new(math.random(-15, 15), math.random(-20, 20), math.random(-15, 15))
                                
                                task.wait(ragdollDuration)
                                
                                linearForce:Destroy()
                                angularVelocity:Destroy()
                                attachment:Destroy()
                                
                                pcall(function()
                                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end)
                            end)

                            local currentCFrame = purple2.CFrame
                            local startTime = os.clock()
                            local duration = 15

                            local connection
                            connection = RunService.Heartbeat:Connect(function()
                                local elapsed = os.clock() - startTime
                                if elapsed >= duration or not purple2.Parent then
                                    connection:Disconnect()
                                    return
                                end
                                currentCFrame = currentCFrame + (lookDirection * 280 * 0.016)
                                purple2.CFrame = currentCFrame
                            end)

                            Debris:AddItem(purple2, duration)

                            task.wait(0.5)
                            TS:Create(Lighting, TweenInfo.new(3, Enum.EasingStyle.Quad), {
                                ClockTime = originalClockTime,
                                Brightness = originalBrightness,
                                Ambient = originalAmbient
                            }):Play()
                            Lighting.LightingStyle = originalLightingStyle
                        end

                        task.wait(1)
                        if animPlayer then animPlayer.Stop() end
                        if originalAnimator then 
                            originalAnimator.Parent = humanoid 
                        end
                        humanoid.WalkSpeed = originalSpeed
                        hpFolder:Destroy()

                        ActionBtn.Text = "2. ปล่อยมุราซากิ"
                        ActionBtn.Active = true
                    end
                end)
            end)
        end)
    end
})

-- ====================================================================
-- CHEAT TAB - สคริปต์ นมใหญ่
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปต์ นมใหญ่",
    Callback = function()
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/clemonlang/clemon_roclothes/refs/heads/main/ClemonRC.lua"))()
        end)
    end
})

-- ====================================================================
-- MAP TAB - สคริปต์ตรวจสอบประจำแมพ
-- ====================================================================
MapScriptSection:CreateButton({
    Title = "🟢 รันสคริปต์ตรวจสอบประจำแมพ",
    Callback = function()
        task.spawn(function()
            -- ====================================================================
            -- Auto Map Script Detector
            -- ====================================================================
            local MarketplaceService = game:GetService("MarketplaceService")
            local success, placeInfo = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)
            local mapName = success and placeInfo.Name or ""
            local lowerMapName = string.lower(mapName)

            if string.find(lowerMapName, "strongest") or game.PlaceId == 10449761463 or game.PlaceId == 2534724415 then
                task.spawn(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/TSB.PISIT"))()
                end)
            elseif string.find(lowerMapName, "murder mystery 2") or string.find(lowerMapName, "mm2") or game.PlaceId == 142823291 then
                task.spawn(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-HUB/refs/heads/main/MM2_PISIT_HUB.VIP"))()
                end)
            else
                warn("[PISIT HUB] แมพนี้ไม่รองรับระบบออโต้สคริปต์!")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "PISIT HUB",
                    Text = "แมพนี้ไม่รองรับสคริปต์อัตโนมัติ",
                    Duration = 2
                })
            end
        end)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "PISIT HUB",
            Text = "กำลังโหลดระบบตรวจสอบและรันสคริปต์ประจำแมพ...",
            Duration = 2
        })
    end
})
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local SetClipboard = setclipboard or toclipboard or print

-- ================================================================= --
-- 1. ป้องกันการรันซ้ำ (หากเปิดอยู่แล้วจะไม่สร้างเพิ่ม)
-- ================================================================= --
if CoreGui:FindFirstChild("X_WACK_STORE_GUI") then
    -- แจ้งเตือนผู้ใช้ว่าเมนูเปิดอยู่แล้ว
    local oldGui = CoreGui.X_WACK_STORE_GUI
    local function MiniNotify(msg)
        local NotifFrame = Instance.new("Frame", oldGui)
        NotifFrame.Size = UDim2.new(0, 260, 0, 45)
        NotifFrame.Position = UDim2.new(0.5, -130, 0.85, 0)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ClipsDescendants = true
        Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke", NotifFrame)
        Stroke.Thickness = 1.5
        Stroke.Color = Color3.fromRGB(255, 180, 0)
        
        local Msg = Instance.new("TextLabel", NotifFrame)
        Msg.Size = UDim2.new(1, 0, 1, 0)
        Msg.BackgroundTransparency = 1
        Msg.Text = msg
        Msg.TextColor3 = Color3.fromRGB(255, 220, 100)
        Msg.Font = Enum.Font.GothamBold
        Msg.TextSize = 12
        
        task.delay(2, function()
            NotifFrame:Destroy()
        end)
    end
    MiniNotify("⚠️ เมนูนี้เปิดใช้งานอยู่แล้ว!")
    return -- หยุดการรันสคริปต์ทันที
end

-- ================================================================= --
-- 2. สร้าง ScreenGui หลัก
-- ================================================================= --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "X_WACK_STORE_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ฟังก์ชันแจ้งเตือน (Notification)
local function Notify(titleText, msgText)
    local NotifFrame = Instance.new("Frame", ScreenGui)
    NotifFrame.Size = UDim2.new(0, 260, 0, 50)
    NotifFrame.Position = UDim2.new(0.5, -130, 1, 80)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true

    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", NotifFrame)
    Stroke.Thickness = 1.5
    Stroke.Color = Color3.fromRGB(0, 255, 200)

    local Title = Instance.new("TextLabel", NotifFrame)
    Title.Position = UDim2.new(0, 12, 0, 6)
    Title.Size = UDim2.new(1, -24, 0, 18)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Msg = Instance.new("TextLabel", NotifFrame)
    Msg.Position = UDim2.new(0, 12, 0, 24)
    Msg.Size = UDim2.new(1, -24, 0, 18)
    Msg.BackgroundTransparency = 1
    Msg.Text = msgText
    Msg.TextColor3 = Color3.fromRGB(220, 220, 220)
    Msg.Font = Enum.Font.Gotham
    Msg.TextSize = 11
    Msg.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -130, 0.85, 0)}):Play()
    
    task.delay(3, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -130, 1, 80)}):Play()
        task.wait(0.4)
        NotifFrame:Destroy()
    end)
end

SetClipboard("https://discord.gg/y3SESh44C8")
Notify("⚡ Luarun", "คัดลอกลิงก์ Discord เข้าคลิปบอร์ดแล้ว!")

-- ================================================================= --
-- 3. หน้าต่างหลัก (ปรับขนาดลงเหลือ 380 x 260)
-- ================================================================= --
local Main = Instance.new("Frame", ScreenGui)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(380, 260) -- ปรับขนาดให้เล็กลงเรียบหรู
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.ClipsDescendants = false

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local Glow = Instance.new("ImageLabel", Main)
Glow.Name = "Glow"
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.5)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857472"
Glow.ImageColor3 = Color3.fromRGB(0, 180, 255)
Glow.ImageTransparency = 0.4
Glow.ZIndex = 0

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local UIGradient = Instance.new("UIGradient", UIStroke)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 230, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 128)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 230, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
})

task.spawn(function()
    local rot = 0
    while task.wait() do
        rot = (rot + 1.5) % 360
        UIGradient.Rotation = rot
        Glow.ImageColor3 = Color3.fromHSV((rot / 360), 0.8, 1)
    end
end)

-- ระบบ Drag (ลากหน้าต่าง)
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ปุ่มปิด
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.fromOffset(24, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- หัวข้อ และ ข้อความ
local Title = Instance.new("TextLabel", Main)
Title.Position = UDim2.fromOffset(0, 16)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundTransparency = 1
Title.Text = "RUNLUA HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22

local Subtitle = Instance.new("TextLabel", Main)
Subtitle.Position = UDim2.fromOffset(0, 42)
Subtitle.Size = UDim2.new(1, 0, 0, 18)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "✨ ระบบสคริปต์ ภาษาไทยเต็มรูปแบบ ✨"
Subtitle.TextColor3 = Color3.fromRGB(0, 230, 255)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 11

local Desc = Instance.new("TextLabel", Main)
Desc.Position = UDim2.fromOffset(0, 62)
Desc.Size = UDim2.new(1, 0, 0, 18)
Desc.BackgroundTransparency = 1
Desc.Text = "กรุณาเลือกเวอร์ชันเมนูที่คุณต้องการใช้งานด้านล่าง"
Desc.TextColor3 = Color3.fromRGB(160, 160, 175)
Desc.Font = Enum.Font.Gotham
Desc.TextSize = 11

-- ================================================================= --
-- 4. ปุ่มเลือกเวอร์ชัน (ย่อขนาดให้เข้ากับ UI ใหม่)
-- ================================================================= --
local function createButton(text, subText, yPos, mainColor)
    local Btn = Instance.new("TextButton", Main)
    Btn.Position = UDim2.new(0.5, -165, 0, yPos)
    Btn.Size = UDim2.new(0, 330, 0, 52)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    Btn.Text = ""
    Btn.AutoButtonColor = false

    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 10)

    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 1.5
    BtnStroke.Color = mainColor
    BtnStroke.Transparency = 0.3

    local BtnTitle = Instance.new("TextLabel", Btn)
    BtnTitle.Position = UDim2.new(0, 15, 0, 8)
    BtnTitle.Size = UDim2.new(1, -30, 0, 18)
    BtnTitle.BackgroundTransparency = 1
    BtnTitle.Text = text
    BtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnTitle.Font = Enum.Font.GothamBold
    BtnTitle.TextSize = 14
    BtnTitle.TextXAlignment = Enum.TextXAlignment.Left

    local BtnSub = Instance.new("TextLabel", Btn)
    BtnSub.Position = UDim2.new(0, 15, 0, 26)
    BtnSub.Size = UDim2.new(1, -30, 0, 16)
    BtnSub.BackgroundTransparency = 1
    BtnSub.Text = subText
    BtnSub.TextColor3 = Color3.fromRGB(150, 150, 170)
    BtnSub.Font = Enum.Font.Gotham
    BtnSub.TextSize = 10
    BtnSub.TextXAlignment = Enum.TextXAlignment.Left

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(32, 32, 48),
            Size = UDim2.new(0, 336, 0, 54),
            Position = UDim2.new(0.5, -168, 0, yPos - 1)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0, Color = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(BtnTitle, TweenInfo.new(0.2), {TextColor3 = mainColor}):Play()
    end)

    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(22, 22, 32),
            Size = UDim2.new(0, 330, 0, 52),
            Position = UDim2.new(0.5, -165, 0, yPos)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0.3, Color = mainColor}):Play()
        TweenService:Create(BtnTitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    return Btn
end

local oldBtn = createButton("🔥 GUI เวอร์ชั่นเก่า (Classic)", "ใช้งานฟังก์ชันดั้งเดิม เสถียรและเรียบง่าย", 92, Color3.fromRGB(255, 140, 0))
local newBtn = createButton("🚀 GUI เวอร์ชั่นใหม่ (V2 Premium)", "ฟังก์ชันจัดเต็ม อัปเดตใหม่ล่าสุด ลื่นไหลกว่าเดิม", 152, Color3.fromRGB(0, 225, 255))

-- Footer ด้านล่าง
local Footer = Instance.new("TextLabel", Main)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.Size = UDim2.new(1, 0, 0, 16)
Footer.BackgroundTransparency = 1
Footer.Text = "พัฒนาและดูแลระบบโดย : X-WACK STORE"
Footer.TextColor3 = Color3.fromRGB(100, 100, 120)
Footer.Font = Enum.Font.GothamMedium
Footer.TextSize = 10

-- ================================================================= --
-- 5. ระบบรันสคริปต์
-- ================================================================= --
local function runScript(url, verName)
    Notify("🚀 กำลังโหลด...", "กำลังเปิดใช้งาน " .. verName)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
    loadstring(game:HttpGet(url))()
end

oldBtn.MouseButton1Click:Connect(function()
    runScript("https://raw.githubusercontent.com/runluahub-create/script-all/refs/heads/main/Gui-Old.lua", "GUI เวอร์ชั่นเก่า")
end)

newBtn.MouseButton1Click:Connect(function()
    runScript("https://raw.githubusercontent.com/runluahub-create/script-all/refs/heads/main/Gui-New.lua", "GUI เวอร์ชั่นใหม่")
end)

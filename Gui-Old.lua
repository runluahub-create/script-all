if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--==================================================
-- CLEANUP
--==================================================
pcall(function()
    local old = CoreGui:FindFirstChild("RUNLUA-HUB_STORE")
    if old then old:Destroy() end
end)

local Connections = {}
local function Track(c)
    table.insert(Connections, c)
    return c
end

local function DisconnectAll()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
end

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "RUNLUA HUB",
            Text = text,
            Duration = 3
        })
    end)
end

local function Character()
    return Player.Character
end

local function Humanoid()
    local c = Character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function Root()
    local c = Character()
    return c and c:FindFirstChild("HumanoidRootPart")
end


local RUNLUA_UI = (function()
local Modules = {}

Modules.Utility = (function()
local UserInputService = game:GetService("UserInputService")
local Utility = {}

function Utility.New(className, props, children)
	local inst = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			if key ~= "Parent" then inst[key] = value end
		end
	end
	if children then
		for _, child in ipairs(children) do child.Parent = inst end
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

function Utility.SafeCall(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[RUNLUA HUB] Error: " .. tostring(err)) end
end

function Utility.MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Utility.Round(val, dec)
	local mult = 10 ^ (dec or 0)
	return math.floor(val * mult + 0.5) / mult
end

function Utility.Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end


return Utility
end)()

Modules.Icon = (function()
local Utility = Modules.Utility
local Icon = {}

local ACCENT = Color3.fromRGB(0,191,255)

local function base(parent, size, position, anchor)
    local holder = Utility.New("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size or 16, size or 16),
        Position = position or UDim2.fromOffset(0,0),
        AnchorPoint = anchor or Vector2.new(0,0),
        Parent = parent,
    })
    return holder
end

local function line(parent, x1,y1,x2,y2, thick, color)
    local dx, dy = x2-x1, y2-y1
    local len = math.sqrt(dx*dx + dy*dy)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.Position = UDim2.fromScale((x1+x2)/2,(y1+y2)/2)
    f.Size = UDim2.new(len,0,0,thick or 2)
    f.BackgroundColor3 = color or ACCENT
    f.BorderSizePixel = 0
    f.Rotation = math.deg(math.atan2(dy,dx))
    f.Parent = parent
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=f
    return f
end

local function rect(parent,x,y,w,h,thick,color)
    line(parent,x,y,x+w,y,thick,color); line(parent,x+w,y,x+w,y+h,thick,color)
    line(parent,x+w,y+h,x,y+h,thick,color); line(parent,x,y+h,x,y,thick,color)
end

local function dot(parent,x,y,r,color)
    local f=Instance.new("Frame")
    f.AnchorPoint=Vector2.new(.5,.5)
    f.Position=UDim2.fromScale(x,y)
    f.Size=UDim2.fromScale(r*2,r*2)
    f.BackgroundColor3=color or ACCENT
    f.BorderSizePixel=0
    f.Parent=parent
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=f
    return f
end

local function ring(parent,x,y,r,thick,color)
    local f=Instance.new("Frame")
    f.AnchorPoint=Vector2.new(.5,.5)
    f.Position=UDim2.fromScale(x,y)
    f.Size=UDim2.fromScale(r*2,r*2)
    f.BackgroundTransparency=1
    f.Parent=parent
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=f
    local st=Instance.new("UIStroke"); st.Color=color or ACCENT; st.Thickness=thick or 2; st.Parent=f
    return f
end

local function draw(holder,name)
    name=tostring(name or "circle")
    local t=1.6

    if name=="x" then
        line(holder,.25,.25,.75,.75,t); line(holder,.75,.25,.25,.75,t)
    elseif name=="minus" then
        line(holder,.22,.5,.78,.5,t)
    elseif name=="grip" then
        dot(holder,.3,.32,.07); dot(holder,.7,.32,.07); dot(holder,.3,.68,.07); dot(holder,.7,.68,.07)
    elseif name:find("eye") then
        line(holder,.12,.5,.3,.32,t); line(holder,.3,.32,.5,.25,t); line(holder,.5,.25,.7,.32,t); line(holder,.7,.32,.88,.5,t)
        line(holder,.88,.5,.7,.68,t); line(holder,.7,.68,.5,.75,t); line(holder,.5,.75,.3,.68,t); line(holder,.3,.68,.12,.5,t)
        dot(holder,.5,.5,.105)
        if name=="eye-off" then line(holder,.18,.18,.82,.82,t+0.3) end
    elseif name=="settings" then
        ring(holder,.5,.5,.18,t); dot(holder,.5,.18,.07); dot(holder,.5,.82,.07); dot(holder,.18,.5,.07); dot(holder,.82,.5,.07)
    elseif name=="users" then
        ring(holder,.38,.35,.14,t); ring(holder,.68,.4,.11,t); line(holder,.16,.8,.24,.64,t); line(holder,.24,.64,.5,.64,t); line(holder,.5,.64,.58,.8,t); line(holder,.56,.78,.84,.78,t)
    elseif name=="user" then
        ring(holder,.5,.34,.15,t); line(holder,.22,.82,.3,.62,t); line(holder,.3,.62,.7,.62,t); line(holder,.7,.62,.78,.82,t)
    elseif name=="plane" then
        line(holder,.12,.55,.88,.28,t); line(holder,.88,.28,.62,.72,t); line(holder,.62,.72,.5,.57,t); line(holder,.5,.57,.32,.78,t); line(holder,.32,.78,.35,.53,t); line(holder,.35,.53,.12,.55,t)
    elseif name=="move-up" then
        line(holder,.5,.82,.5,.2,t); line(holder,.5,.2,.28,.42,t); line(holder,.5,.2,.72,.42,t)
    elseif name=="gauge" then
        ring(holder,.5,.58,.32,t); line(holder,.5,.58,.72,.42,t); dot(holder,.5,.58,.055)
    elseif name:find("mouse%-pointer") then
        line(holder,.25,.18,.25,.82,t); line(holder,.25,.18,.72,.56,t); line(holder,.72,.56,.48,.6,t); line(holder,.48,.6,.62,.82,t)
    elseif name=="door-open" then
        rect(holder,.2,.16,.5,.68,t); line(holder,.5,.16,.78,.28,t); line(holder,.78,.28,.78,.82,t); line(holder,.78,.82,.5,.84,t); dot(holder,.68,.55,.04)
    elseif name=="shield" then
        line(holder,.5,.12,.78,.24,t); line(holder,.78,.24,.72,.62,t); line(holder,.72,.62,.5,.86,t); line(holder,.5,.86,.28,.62,t); line(holder,.28,.62,.22,.24,t); line(holder,.22,.24,.5,.12,t)
    elseif name=="crosshair" then
        ring(holder,.5,.5,.28,t); line(holder,.5,.08,.5,.3,t); line(holder,.5,.7,.5,.92,t); line(holder,.08,.5,.3,.5,t); line(holder,.7,.5,.92,.5,t)
    elseif name=="skull" then
        ring(holder,.5,.43,.27,t); dot(holder,.4,.4,.055); dot(holder,.6,.4,.055); line(holder,.4,.65,.4,.82,t); line(holder,.5,.67,.5,.82,t); line(holder,.6,.65,.6,.82,t)
    elseif name=="box" or name=="package-plus" then
        rect(holder,.2,.25,.6,.5,t); line(holder,.2,.25,.5,.42,t); line(holder,.8,.25,.5,.42,t); line(holder,.5,.42,.5,.75,t)
        if name=="package-plus" then line(holder,.68,.58,.68,.78,t); line(holder,.58,.68,.78,.68,t) end
    elseif name=="rocket" then
        line(holder,.3,.72,.62,.22,t); line(holder,.62,.22,.82,.18,t); line(holder,.82,.18,.78,.38,t); line(holder,.78,.38,.46,.74,t); line(holder,.46,.74,.3,.72,t); dot(holder,.64,.4,.07); line(holder,.3,.72,.18,.82,t)
    elseif name=="sun" then
        ring(holder,.5,.5,.17,t); line(holder,.5,.08,.5,.22,t); line(holder,.5,.78,.5,.92,t); line(holder,.08,.5,.22,.5,t); line(holder,.78,.5,.92,.5,t); line(holder,.2,.2,.3,.3,t); line(holder,.7,.7,.8,.8,t); line(holder,.7,.3,.8,.2,t); line(holder,.2,.8,.3,.7,t)
    elseif name=="car" then
        rect(holder,.18,.42,.64,.28,t); line(holder,.3,.42,.4,.26,t); line(holder,.4,.26,.65,.26,t); line(holder,.65,.26,.75,.42,t); ring(holder,.32,.73,.09,t); ring(holder,.68,.73,.09,t)
    elseif name=="hand" then
        line(holder,.3,.75,.28,.42,t); line(holder,.28,.42,.36,.4,t); line(holder,.36,.4,.42,.6,t); line(holder,.42,.6,.42,.25,t); line(holder,.42,.25,.5,.24,t); line(holder,.5,.24,.52,.58,t); line(holder,.52,.58,.58,.3,t); line(holder,.58,.3,.66,.32,t); line(holder,.66,.32,.64,.66,t); line(holder,.64,.66,.54,.82,t); line(holder,.54,.82,.3,.75,t)
    elseif name:find("scan") then
        line(holder,.18,.38,.18,.18,t); line(holder,.18,.18,.38,.18,t); line(holder,.62,.18,.82,.18,t); line(holder,.82,.18,.82,.38,t); line(holder,.18,.62,.18,.82,t); line(holder,.18,.82,.38,.82,t); line(holder,.62,.82,.82,.82,t); line(holder,.82,.82,.82,.62,t); ring(holder,.48,.48,.15,t); line(holder,.6,.6,.76,.76,t)
    elseif name=="bot" then
        rect(holder,.2,.28,.6,.48,t); line(holder,.5,.12,.5,.28,t); dot(holder,.5,.12,.05); dot(holder,.38,.49,.055); dot(holder,.62,.49,.055); line(holder,.35,.65,.65,.65,t)
    elseif name=="magnet" then
        line(holder,.25,.2,.25,.62,t+1); line(holder,.75,.2,.75,.62,t+1); line(holder,.25,.62,.35,.78,t+1); line(holder,.35,.78,.65,.78,t+1); line(holder,.65,.78,.75,.62,t+1); line(holder,.25,.2,.4,.2,t+1); line(holder,.6,.2,.75,.2,t+1)
    elseif name:find("circle") then
        ring(holder,.5,.5,.28,t); if name:find("dot") then dot(holder,.5,.5,.06) end
    elseif name=="bomb" then
        ring(holder,.45,.58,.25,t); line(holder,.62,.36,.76,.22,t); line(holder,.74,.18,.8,.12,t); line(holder,.78,.2,.88,.2,t)
    elseif name=="shirt" then
        line(holder,.2,.28,.35,.18,t); line(holder,.35,.18,.42,.28,t); line(holder,.42,.28,.58,.28,t); line(holder,.58,.28,.65,.18,t); line(holder,.65,.18,.8,.28,t); line(holder,.8,.28,.7,.46,t); line(holder,.7,.46,.66,.4,t); line(holder,.66,.4,.66,.82,t); line(holder,.66,.82,.34,.82,t); line(holder,.34,.82,.34,.4,t); line(holder,.34,.4,.3,.46,t); line(holder,.3,.46,.2,.28,t)
    elseif name=="blocks" then
        rect(holder,.12,.18,.3,.3,t); rect(holder,.58,.18,.3,.3,t); rect(holder,.35,.55,.3,.3,t)
    elseif name=="keyboard" then
        rect(holder,.12,.25,.76,.5,t); for i=.25,.75,.125 do dot(holder,i,.43,.035); dot(holder,i,.58,.035) end
    elseif name=="server" then
        rect(holder,.15,.18,.7,.25,t); rect(holder,.15,.57,.7,.25,t); dot(holder,.25,.305,.04); dot(holder,.25,.695,.04); line(holder,.38,.305,.72,.305,t); line(holder,.38,.695,.72,.695,t)
    elseif name=="terminal" or name=="square-terminal" then
        rect(holder,.14,.18,.72,.64,t); line(holder,.28,.38,.4,.5,t); line(holder,.4,.5,.28,.62,t); line(holder,.48,.62,.68,.62,t)
    elseif name=="sliders-horizontal" then
        line(holder,.15,.3,.85,.3,t); line(holder,.15,.7,.85,.7,t); dot(holder,.38,.3,.08); dot(holder,.65,.7,.08)
    elseif name=="panel-top" then
        rect(holder,.14,.16,.72,.68,t); line(holder,.14,.34,.86,.34,t); dot(holder,.24,.25,.035); dot(holder,.34,.25,.035)
    elseif name=="house" then
        line(holder,.15,.48,.5,.18,t); line(holder,.5,.18,.85,.48,t); line(holder,.24,.42,.24,.82,t); line(holder,.76,.42,.76,.82,t); line(holder,.24,.82,.76,.82,t); rect(holder,.44,.57,.16,.25,t)
    elseif name=="swords" then
        line(holder,.2,.2,.78,.78,t+0.3); line(holder,.8,.2,.22,.78,t+0.3); line(holder,.14,.7,.3,.86,t); line(holder,.7,.86,.86,.7,t)
    elseif name=="wrench" then
        line(holder,.25,.75,.68,.32,t+1.3); ring(holder,.72,.28,.11,t); ring(holder,.22,.78,.08,t)
    elseif name=="sparkles" then
        line(holder,.5,.12,.5,.42,t); line(holder,.35,.27,.65,.27,t); line(holder,.72,.52,.72,.78,t); line(holder,.59,.65,.85,.65,t)
    elseif name=="folder" then
        line(holder,.15,.32,.36,.32,t); line(holder,.36,.32,.43,.22,t); line(holder,.43,.22,.62,.22,t); line(holder,.62,.22,.68,.32,t); rect(holder,.15,.32,.7,.46,t)
    elseif name=="toggle-right" then
        local f=Instance.new("Frame"); f.AnchorPoint=Vector2.new(.5,.5); f.Position=UDim2.fromScale(.5,.5); f.Size=UDim2.fromScale(.78,.42); f.BackgroundTransparency=1; f.Parent=holder
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=f
        local st=Instance.new("UIStroke"); st.Color=ACCENT; st.Thickness=t; st.Parent=f
        dot(holder,.66,.5,.13)
    else
        ring(holder,.5,.5,.28,t); dot(holder,.5,.5,.06)
    end
end

function Icon.Resolve(name)
    -- Compatibility: no external asset is required anymore.
    return tostring(name or "circle")
end

function Icon.New(parent, name, size, position, anchor)
    local holder = base(parent,size,position,anchor)
    draw(holder,name)
    return holder
end

return Icon
end)()

Modules.Theme = (function()
local Theme = {}
local function newSignal()
	local signal = { _listeners = {} }
	function signal:Connect(fn)
		table.insert(signal._listeners, fn)
		return { Disconnect = function()
			for i, l in ipairs(signal._listeners) do if l == fn then table.remove(signal._listeners, i) break end end
		end }
	end
	function signal:Fire(...) for _, fn in ipairs(signal._listeners) do task.spawn(fn, ...) end end
	return signal
end

Theme.Palettes = {
	Red = {
		Accent = Color3.fromHex("#DC1E1E"),
		AccentDim = Color3.fromHex("#8C1414"),
		Background = Color3.fromHex("#0F0F0F"),
		SecondaryBackground = Color3.fromHex("#171717"),
		ElementBackground = Color3.fromHex("#1B1B1B"),
		Border = Color3.fromHex("#DC1E1E"),
		Text = Color3.fromHex("#FFFFFF"),
		SubText = Color3.fromHex("#B5B5B5"),
		Success = Color3.fromHex("#3ED17B"),
		Warning = Color3.fromHex("#E1B33D"),
		Error = Color3.fromHex("#E14848"),
	},
	Blue = {
		Accent = Color3.fromHex("#00BFFF"),
		AccentDim = Color3.fromHex("#063B66"),
		Background = Color3.fromHex("#05070D"),
		SecondaryBackground = Color3.fromHex("#09111D"),
		ElementBackground = Color3.fromHex("#0B1726"),
		Border = Color3.fromHex("#00BFFF"),
		Text = Color3.fromHex("#FFFFFF"),
		SubText = Color3.fromHex("#B5B5B5"),
		Success = Color3.fromHex("#3ED17B"),
		Warning = Color3.fromHex("#E1B33D"),
		Error = Color3.fromHex("#E14848"),
	},
	Green = {
		Accent = Color3.fromHex("#1EDC6E"),
		AccentDim = Color3.fromHex("#148C46"),
		Background = Color3.fromHex("#0D110E"),
		SecondaryBackground = Color3.fromHex("#141914"),
		ElementBackground = Color3.fromHex("#191F19"),
		Border = Color3.fromHex("#1EDC6E"),
		Text = Color3.fromHex("#FFFFFF"),
		SubText = Color3.fromHex("#B5B5B5"),
		Success = Color3.fromHex("#3ED17B"),
		Warning = Color3.fromHex("#E1B33D"),
		Error = Color3.fromHex("#E14848"),
	},
	Purple = {
		Accent = Color3.fromHex("#9A1EDC"),
		AccentDim = Color3.fromHex("#5F148C"),
		Background = Color3.fromHex("#100E14"),
		SecondaryBackground = Color3.fromHex("#18151C"),
		ElementBackground = Color3.fromHex("#1D1922"),
		Border = Color3.fromHex("#9A1EDC"),
		Text = Color3.fromHex("#FFFFFF"),
		SubText = Color3.fromHex("#B5B5B5"),
		Success = Color3.fromHex("#3ED17B"),
		Warning = Color3.fromHex("#E1B33D"),
		Error = Color3.fromHex("#E14848"),
	},
	Light = {
		Accent = Color3.fromHex("#DC1E1E"),
		AccentDim = Color3.fromHex("#F0A5A5"),
		Background = Color3.fromHex("#F2F2F2"),
		SecondaryBackground = Color3.fromHex("#E6E6E6"),
		ElementBackground = Color3.fromHex("#FFFFFF"),
		Border = Color3.fromHex("#DC1E1E"),
		Text = Color3.fromHex("#101010"),
		SubText = Color3.fromHex("#5A5A5A"),
		Success = Color3.fromHex("#2FA860"),
		Warning = Color3.fromHex("#B98A1F"),
		Error = Color3.fromHex("#C23A3A"),
	},
}

Theme.Order = { "Red", "Blue", "Green", "Purple", "Light" }
Theme.OnChanged = newSignal()
Theme.Current = "Blue"
Theme.Active = Theme.Palettes.Blue

function Theme.Get(key) return Theme.Active[key] end

function Theme.Set(name)
	local palette = Theme.Palettes[name]
	if not palette then return false, "ไม่พบธีม: " .. tostring(name) end
	Theme.Current = name
	Theme.Active = palette
	Theme.OnChanged:Fire(palette)
	return true
end

return Theme
end)()

Modules.Animation = (function()
local TweenService = game:GetService("TweenService")
local Animation = {}
Animation.Easing = {
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

function Animation.Tween(inst, info, props)
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

function Animation.OpenWindow(frame)
	frame.Visible = true
	local goalSize = frame:GetAttribute("TargetSize") or frame.Size
	frame.Size = UDim2.new(goalSize.X.Scale, goalSize.X.Offset, 0, 0)
	frame.BackgroundTransparency = 1
	Animation.Tween(frame, Animation.Easing.Bounce, { Size = goalSize })
	Animation.Tween(frame, Animation.Easing.Normal, { BackgroundTransparency = 0 })
end

function Animation.CloseWindow(frame, onComplete)
	frame:SetAttribute("TargetSize", frame.Size)
	local tw = Animation.Tween(frame, Animation.Easing.Fast, { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0), BackgroundTransparency = 1 })
	tw.Completed:Connect(function()
		frame.Visible = false
		if onComplete then onComplete() end
	end)
end

function Animation.Hover(inst, hoverCol, normCol)
	inst.MouseEnter:Connect(function() Animation.Tween(inst, Animation.Easing.Fast, { BackgroundColor3 = hoverCol }) end)
	inst.MouseLeave:Connect(function() Animation.Tween(inst, Animation.Easing.Fast, { BackgroundColor3 = normCol }) end)
end

function Animation.Click(inst)
	local orig = inst.Size
	Animation.Tween(inst, TweenInfo.new(0.08), { Size = UDim2.new(orig.X.Scale, orig.X.Offset - 4, orig.Y.Scale, orig.Y.Offset - 2) })
	task.delay(0.08, function() Animation.Tween(inst, Animation.Easing.Bounce, { Size = orig }) end)
end

function Animation.Glow(stroke, active)
	Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = active and 0 or 0.6 })
end

return Animation
end)()

Modules.Config = (function()
	local HttpService = game:GetService("HttpService")
	local Config = {}
	Config._flags = {}
	Config._folder = "RUNLUA-HUB/configs"
	Config._autoSaveEnabled = false

	local function fsAvailable()
		return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
	end
	local function ensureFolder()
		if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
			if not isfolder(Config._folder) then makefolder(Config._folder) end
		end
	end

	function Config.Register(flag, getSet) Config._flags[flag] = getSet end

	function Config.Save(name)
		name = name or "default"
		if not fsAvailable() then return false, "File IO ใช้ไม่ได้บนแพลตฟอร์มนี้" end
		ensureFolder()
		local data = {}
		for flag, gs in pairs(Config._flags) do
			local ok, v = pcall(gs.Get)
			if ok then data[flag] = v end
		end
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
		if not ok then return false, "เข้ารหัส config ไม่สำเร็จ" end
		local path = Config._folder .. "/" .. name .. ".json"
		local writeOk, writeErr = pcall(writefile, path, encoded)
		if not writeOk then return false, "เขียนไฟล์ไม่สำเร็จ: " .. tostring(writeErr) end
		return true, "บันทึกที่ " .. path
	end

	function Config.Load(name)
		name = name or "default"
		if not fsAvailable() then return false, "File IO ใช้ไม่ได้บนแพลตฟอร์มนี้" end
		local path = Config._folder .. "/" .. name .. ".json"
		if not isfile(path) then return false, "ไม่พบไฟล์ config: " .. path end
		local ok, raw = pcall(readfile, path)
		if not ok then return false, "อ่านไฟล์ไม่สำเร็จ" end
		local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
		if not decodeOk then return false, "ถอดรหัส config ไม่สำเร็จ" end
		for flag, value in pairs(data) do
			local gs = Config._flags[flag]
			if gs then pcall(gs.Set, value) end
		end
		return true, "โหลดจาก " .. path
	end

	function Config.EnableAutoSave(name, interval)
		Config._autoSaveEnabled = true
		task.spawn(function()
			while Config._autoSaveEnabled do
				task.wait(interval or 15)
				if Config._autoSaveEnabled then Config.Save(name) end
			end
		end)
	end
	function Config.DisableAutoSave() Config._autoSaveEnabled = false end

	return Config
end)()

Modules.Notification = (function()
	local Theme = Modules.Theme
	local Utility = Modules.Utility
	local Animation = Modules.Animation
	local Notification = {}
	local container

	function Notification.Init(screenGui)
		container = Utility.New("Frame", {
			Name = "RUNLUA_Notifications", BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
			Size = UDim2.new(0, 220, 1, -24), Parent = screenGui
		})
		Utility.New("UIListLayout", {
			Parent = container, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 6),
		})
	end

	function Notification.Notify(data)
		if not container then return end
		data = data or {}
		local card = Utility.New("Frame", {
			BackgroundColor3 = Theme.Get("SecondaryBackground"), BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = container
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
		local stroke = Utility.New("UIStroke", { Color = Theme.Get("Accent"), Thickness = 1, Transparency = 1, Parent = card })
		Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = card })
		Utility.New("UIListLayout", { Padding = UDim.new(0, 2), Parent = card })

		Utility.New("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
			Text = data.Title or "แจ้งเตือน", Font = Enum.Font.GothamBold, TextSize = 13,
			TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = card
		})
		Utility.New("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = data.Content or "", Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
			TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = card
		})

		Animation.Tween(card, Animation.Easing.Smooth, { BackgroundTransparency = 0 })
		Animation.Tween(stroke, Animation.Easing.Smooth, { Transparency = 0.3 })

		task.delay(data.Duration or 4, function()
			if not card.Parent then return end
			local tw = Animation.Tween(card, Animation.Easing.Normal, { BackgroundTransparency = 1 })
			Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = 1 })
			tw.Completed:Connect(function() card:Destroy() end)
		end)
	end

	return Notification
end)()

-- ============================================
-- Modules.Button 
-- ============================================
Modules.Button = (function()
    local Theme = Modules.Theme
    local Utility = Modules.Utility
    local Animation = Modules.Animation
    local Button = {}
    Button.__index = Button

    function Button.new(parent, config)
        config = config or {}
        local self = setmetatable({}, Button)
        self.Instance = Utility.New("TextButton", {
            Name = "Button", Text = "", AutoButtonColor = false,
            BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 36),
            Parent = parent
        })
        Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
        local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
        Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = self.Instance })

        Modules.Icon.New(self.Instance, config.Icon or "circle-dot", 17, UDim2.new(0, 2, 0.5, 0), Vector2.new(0,0.5))
        local label = Utility.New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(28,0), Size = UDim2.new(1, -28, 1, 0),
            Text = config.Title or "Button", Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance
        })

        Animation.Hover(self.Instance, Theme.Get("ElementBackground"):Lerp(Theme.Get("Accent"), 0.15), Theme.Get("ElementBackground"))
        self.Instance.MouseButton1Click:Connect(function()
            Animation.Click(self.Instance)
            Utility.SafeCall(config.Callback)
        end)

        Theme.OnChanged:Connect(function()
            self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
            stroke.Color = Theme.Get("Border")
            label.TextColor3 = Theme.Get("Text")
        end)

        return self
    end
    return Button
end)()

-- ============================================
-- Modules.SplitButton (ซ้ายข้อความ / ขวา RUN)
-- ============================================
Modules.SplitButton = (function()
    local Theme = Modules.Theme
    local Utility = Modules.Utility
    local Animation = Modules.Animation
    local SplitButton = {}
    SplitButton.__index = SplitButton

    function SplitButton.new(parent, config)
        config = config or {}
        local self = setmetatable({}, SplitButton)
        
        local MainFrame = Utility.New("Frame", {
            Name = "SplitButton",
            BackgroundColor3 = Theme.Get("ElementBackground"),
            Size = UDim2.new(1, 0, 0, 36),
            Parent = parent
        })
        Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MainFrame })
        
        local MainStroke = Utility.New("UIStroke", {
            Color = Theme.Get("Border"),
            Transparency = 0.75,
            Thickness = 1,
            Parent = MainFrame
        })
        
        local Label = Utility.New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = config.Title or "Button",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Get("Text"),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = MainFrame
        })
        Utility.New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = Label
        })
        
        local RunButton = Utility.New("TextButton", {
            Name = "RunButton",
            Text = "▶ RUN",
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Get("Accent"),
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Theme.Get("Text"),
            Parent = MainFrame
        })
        Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = RunButton })
        
        Animation.Hover(RunButton, Theme.Get("Accent"):Lerp(Color3.fromRGB(255, 255, 255), 0.2), Theme.Get("Accent"))
        
        RunButton.MouseButton1Click:Connect(function()
            Animation.Click(RunButton)
            Utility.SafeCall(config.Callback)
        end)
        
        Theme.OnChanged:Connect(function()
            MainFrame.BackgroundColor3 = Theme.Get("ElementBackground")
            MainStroke.Color = Theme.Get("Border")
            Label.TextColor3 = Theme.Get("Text")
            RunButton.BackgroundColor3 = Theme.Get("Accent")
            RunButton.TextColor3 = Theme.Get("Text")
        end)
        
        function self.SetTitle(text)
            Label.Text = text
        end
        
        function self.SetRunText(text)
            RunButton.Text = text
        end
        
        return self
    end
    
    return SplitButton
end)()

Modules.Toggle = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Toggle)
	self.Value = config.Default or false

	self.Instance = Utility.New("Frame", {
		Name = "Toggle", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 36), Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8), Parent = self.Instance })

	-- ช่องไอคอนแบบคงที่: ทำให้ทุกไอคอนอยู่กึ่งกลางตรงกันทุกแถว
	local iconSlot = Utility.New("Frame", {
		Name = "IconSlot", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(24, 36), Parent = self.Instance
	})
	Modules.Icon.New(iconSlot, config.Icon or "toggle-right", 17, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5,0.5))

	local label = Utility.New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(30,0), Size = UDim2.new(1, -86, 1, 0),
		Text = config.Title or "Toggle", Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance
	})

	-- Switch จริง: ไม่มีข้อความ ON/OFF ใช้ราง + ปุ่มเลื่อน
	local switch = Utility.New("TextButton", {
		Name = "Switch", Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = self.Value and Theme.Get("Accent") or Color3.fromRGB(31, 40, 52),
		Parent = self.Instance
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
	local boxStroke = Utility.New("UIStroke", {
		Color = self.Value and Theme.Get("Accent") or Color3.fromRGB(63, 78, 96),
		Transparency = self.Value and 0.18 or 0.35, Thickness = 1, Parent = switch
	})

	local knob = Utility.New("Frame", {
		Name = "Knob", AnchorPoint = Vector2.new(0.5,0.5),
		Position = self.Value and UDim2.new(1,-12,0.5,0) or UDim2.new(0,12,0.5,0),
		Size = UDim2.fromOffset(18,18),
		BackgroundColor3 = self.Value and Color3.fromRGB(235,250,255) or Color3.fromRGB(145,156,170),
		BorderSizePixel = 0, Parent = switch
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local knobStroke = Utility.New("UIStroke", {
		Color = self.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,200,214),
		Transparency = 0.45, Thickness = 1, Parent = knob
	})

	local function render(anim)
		local trackColor = self.Value and Theme.Get("Accent") or Color3.fromRGB(31, 40, 52)
		local strokeColor = self.Value and Theme.Get("Accent") or Color3.fromRGB(63, 78, 96)
		local knobColor = self.Value and Color3.fromRGB(235,250,255) or Color3.fromRGB(145,156,170)
		local knobPos = self.Value and UDim2.new(1,-12,0.5,0) or UDim2.new(0,12,0.5,0)

		if anim then
			Animation.Tween(switch, Animation.Easing.Fast, {BackgroundColor3 = trackColor})
			Animation.Tween(knob, Animation.Easing.Fast, {Position = knobPos, BackgroundColor3 = knobColor})
		else
			switch.BackgroundColor3 = trackColor
			knob.Position = knobPos
			knob.BackgroundColor3 = knobColor
		end

		boxStroke.Color = strokeColor
		boxStroke.Transparency = self.Value and 0.18 or 0.35
		knobStroke.Color = self.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,200,214)
	end

	local function toggleValue()
		self.Value = not self.Value
		render(true)
		Utility.SafeCall(config.Callback, self.Value)
	end

	switch.MouseButton1Click:Connect(toggleValue)

	-- กดพื้นที่แถวได้ด้วย (ยกเว้นตรง switch เพื่อไม่ให้เด้งสองครั้ง)
	local rowClick = Utility.New("TextButton", {
		Name = "RowClick", Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
		Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,-54,1,0), ZIndex = 2, Parent = self.Instance
	})
	rowClick.MouseButton1Click:Connect(toggleValue)
	render(false)

	if config.Flag then
		Modules.Config.Register(config.Flag, {
			Get = function() return self.Value end,
			Set = function(v) self.Value = v and true or false; render(false) end,
		})
	end
	
	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		label.TextColor3 = Theme.Get("Text")
		render(false)
	end)

	return self
end
return Toggle
end)()

Modules.Slider = (function()
local UserInputService = game:GetService("UserInputService")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Slider = {}
Slider.__index = Slider

function Slider.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Slider)
	self.Min = config.Min or 0
	self.Max = config.Max or 100
	self.Value = Utility.Clamp(config.Default or self.Min, self.Min, self.Max)
	self.Dragging = false

	self.Instance = Utility.New("Frame", {
		Name = "Slider", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 46), Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), Parent = self.Instance })

	local header = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = self.Instance })
	Modules.Icon.New(header, config.Icon or "sliders-horizontal", 15, UDim2.new(0,0,0.5,0), Vector2.new(0,0.5))
	local titleLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(24,0), Size = UDim2.new(1, -74, 1, 0), Text = config.Title or "Slider", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	local valLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(50, 16), Text = tostring(self.Value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Right, Parent = header })

	local bar = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = Theme.Get("AccentDim"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
	local fill = Utility.New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Get("Accent"), Parent = bar })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local function update(xPos)
		local rel = Utility.Clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local raw = self.Min + rel * (self.Max - self.Min)
		local stepped = Utility.Round(raw / (config.Increment or 1)) * (config.Increment or 1)
		self.Value = Utility.Clamp(stepped, self.Min, self.Max)
		valLbl.Text = tostring(self.Value)
		fill.Size = UDim2.new((self.Value - self.Min)/(self.Max - self.Min), 0, 1, 0)
		Utility.SafeCall(config.Callback, self.Value)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			update(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then self.Dragging = false end
	end)

	fill.Size = UDim2.new((self.Value - self.Min)/(self.Max - self.Min), 0, 1, 0)

	if config.Flag then
		Modules.Config.Register(config.Flag, {
			Get = function() return self.Value end,
			Set = function(v)
				self.Value = Utility.Clamp(v, self.Min, self.Max)
				valLbl.Text = tostring(self.Value)
				fill.Size = UDim2.new((self.Value - self.Min)/(self.Max - self.Min), 0, 1, 0)
			end,
		})
	end

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		titleLbl.TextColor3 = Theme.Get("Text")
		valLbl.TextColor3 = Theme.Get("Accent")
		bar.BackgroundColor3 = Theme.Get("AccentDim")
		fill.BackgroundColor3 = Theme.Get("Accent")
	end)

	return self
end
return Slider
end)()

Modules.Dropdown = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Dropdown)
	self.Options = config.Options or {}
	self.Selected = config.Default or self.Options[1] or ""
	self.Open = false

	self.Instance = Utility.New("Frame", {
		Name = "Dropdown", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true, Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })

	local header = Utility.New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = header })
	local lbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Text = (config.Title or "Dropdown") .. ": " .. tostring(self.Selected), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

	local holder = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2), Parent = holder })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = holder })

	local function refresh()
		for _, c in ipairs(holder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for _, opt in ipairs(self.Options) do
			local optBtn = Utility.New("TextButton", { Text = opt, AutoButtonColor = false, BackgroundColor3 = Theme.Get("Background"), Size = UDim2.new(1, 0, 0, 26), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), Parent = holder })
			Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
			optBtn.MouseButton1Click:Connect(function()
				self.Selected = opt
				lbl.Text = (config.Title or "Dropdown") .. ": " .. tostring(opt)
				self.Open = false
				Animation.Tween(self.Instance, Animation.Easing.Fast, { Size = UDim2.new(1, 0, 0, 36) })
				Utility.SafeCall(config.Callback, opt)
			end)
		end
	end

	header.MouseButton1Click:Connect(function()
		self.Open = not self.Open
		local targetH = 36 + (#self.Options * 28) + 8
		Animation.Tween(self.Instance, Animation.Easing.Smooth, { Size = UDim2.new(1, 0, 0, self.Open and math.min(targetH, 160) or 36) })
	end)

	refresh()
	function self:Refresh(list) self.Options = list; refresh() end

	if config.Flag then
		Modules.Config.Register(config.Flag, {
			Get = function() return self.Selected end,
			Set = function(v)
				self.Selected = v
				lbl.Text = (config.Title or "Dropdown") .. ": " .. tostring(v)
			end,
		})
	end

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		lbl.TextColor3 = Theme.Get("Text")
		refresh()
	end)

	return self
end
return Dropdown
end)()

Modules.ColorPicker = (function()
local UserInputService = game:GetService("UserInputService")
local Theme = Modules.Theme
local Utility = Modules.Utility
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent, config)
	config = config or {}
	local self = setmetatable({}, ColorPicker)
	self.Value = config.Default or Color3.fromRGB(220, 30, 30)

	self.Instance = Utility.New("Frame", {
		Name = "ColorPicker", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 100), Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), Parent = self.Instance })

	local header = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = self.Instance })
	local titleLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Text = config.Title or "Color Picker", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	local preview = Utility.New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundColor3 = self.Value, Parent = header })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = preview })
	local previewStroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1, Parent = preview })

	local r, g, b = math.floor(self.Value.R * 255), math.floor(self.Value.G * 255), math.floor(self.Value.B * 255)
	local fills = {}

	local function makeSlider(name, val, col)
		local row = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = self.Instance })
		Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(15, 20), Text = name, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = col, Parent = row })
		local bar = Utility.New("Frame", { Position = UDim2.new(0, 18, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(1, -18, 0, 4), BackgroundColor3 = Theme.Get("AccentDim"), Parent = row })
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		local fill = Utility.New("Frame", { Size = UDim2.new(val/255, 0, 1, 0), BackgroundColor3 = col, Parent = bar })
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
		fills[name] = { bar = bar, fill = fill }

		local dragging = false
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local rel = Utility.Clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				if name == "R" then r = math.floor(rel * 255 + 0.5)
				elseif name == "G" then g = math.floor(rel * 255 + 0.5)
				elseif name == "B" then b = math.floor(rel * 255 + 0.5) end
				self.Value = Color3.fromRGB(r, g, b)
				preview.BackgroundColor3 = self.Value
				Utility.SafeCall(config.Callback, self.Value)
			end
		end)
	end

	makeSlider("R", r, Color3.fromRGB(255, 80, 80))
	makeSlider("G", g, Color3.fromRGB(80, 255, 100))
	makeSlider("B", b, Color3.fromRGB(80, 150, 255))

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		titleLbl.TextColor3 = Theme.Get("Text")
		previewStroke.Color = Theme.Get("Border")
		for _, s in pairs(fills) do s.bar.BackgroundColor3 = Theme.Get("AccentDim") end
	end)

	if config.Flag then
		Modules.Config.Register(config.Flag, {
			Get = function() return { r = r, g = g, b = b } end,
			Set = function(v)
				if typeof(v) ~= "table" then return end
				r, g, b = v.r or r, v.g or g, v.b or b
				self.Value = Color3.fromRGB(r, g, b)
				preview.BackgroundColor3 = self.Value
				if fills.R then fills.R.fill.Size = UDim2.new(r/255, 0, 1, 0) end
				if fills.G then fills.G.fill.Size = UDim2.new(g/255, 0, 1, 0) end
				if fills.B then fills.B.fill.Size = UDim2.new(b/255, 0, 1, 0) end
			end,
		})
	end

return self
end
return ColorPicker
end)()

Modules.Textbox = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Textbox = {}
Textbox.__index = Textbox
function Textbox.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Textbox)
	self.Value = config.Default or ""
	self.Instance = Utility.New("Frame", { Name = "Textbox", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 50), Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), Parent = self.Instance })

	local titleLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title or "Textbox", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	local boxBg = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Theme.Get("Background"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = boxBg })
	local box = Utility.New("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = self.Value, PlaceholderText = config.Placeholder or "Type...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("Text"), Parent = boxBg })
	box.FocusLost:Connect(function()
		self.Value = box.Text
		Utility.SafeCall(config.Callback, self.Value)
	end)

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		titleLbl.TextColor3 = Theme.Get("Text")
		boxBg.BackgroundColor3 = Theme.Get("Background")
		box.TextColor3 = Theme.Get("Text")
	end)

	if config.Flag then
		Modules.Config.Register(config.Flag, {
			Get = function() return self.Value end,
			Set = function(v) self.Value = tostring(v); box.Text = self.Value end,
		})
	end
	
	return self
end
return Textbox
end)()

Modules.Paragraph = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Paragraph = {}
Paragraph.__index = Paragraph
function Paragraph.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Paragraph)
	self.Instance = Utility.New("Frame", { Name = "Paragraph", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = self.Instance })

	local titleLbl
	if config.Title and config.Title ~= "" then
		titleLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	end
	local contentLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = config.Content or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
		if titleLbl then titleLbl.TextColor3 = Theme.Get("Text") end
		contentLbl.TextColor3 = Theme.Get("SubText")
	end)

	return self
end
return Paragraph
end)()

Modules.Label = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Label = {}
Label.__index = Label
function Label.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Label)
	self.Instance = Utility.New("TextLabel", { Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = config.Text or "Label", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
	Theme.OnChanged:Connect(function() self.Instance.TextColor3 = Theme.Get("SubText") end)
	return self
end
return Label
end)()

Modules.Section = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Section = {}
Section.__index = Section

function Section.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Section)
	self.Instance = Utility.New("Frame", { Name = "Section", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Instance })
	local sectionIconSlot = Utility.New("Frame", {Name="SectionIconSlot", BackgroundTransparency=1, Position=UDim2.fromOffset(0,0), Size=UDim2.fromOffset(20,16), Parent=self.Instance})
	Modules.Icon.New(sectionIconSlot, config.Icon or "folder", 15, UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5))
	local titleLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(24,0), Size = UDim2.new(1, -24, 0, 16), Text = config.Title or "Section", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })

	self.Content = Utility.New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 6), Parent = self.Content })

	Theme.OnChanged:Connect(function()
		self.Instance.BackgroundColor3 = Theme.Get("SecondaryBackground")
		stroke.Color = Theme.Get("Border")
		titleLbl.TextColor3 = Theme.Get("Accent")
	end)

	return self
end

function Section:CreateButton(cfg) return Modules.Button.new(self.Content, cfg) end
function Section:CreateToggle(cfg) return Modules.Toggle.new(self.Content, cfg) end
function Section:CreateSplitButton(cfg) return Modules.SplitButton.new(self.Content, cfg) end
function Section:CreateSlider(cfg) return Modules.Slider.new(self.Content, cfg) end
function Section:CreateDropdown(cfg) return Modules.Dropdown.new(self.Content, cfg) end
function Section:CreateTextbox(cfg) return Modules.Textbox.new(self.Content, cfg) end
function Section:CreateParagraph(cfg) return Modules.Paragraph.new(self.Content, cfg) end
function Section:CreateLabel(cfg) return Modules.Label.new(self.Content, cfg) end
function Section:CreateColorPicker(cfg) return Modules.ColorPicker.new(self.Content, cfg) end

function Section:CreateDivider()
	local line = Utility.New("Frame", { Name = "Divider", BackgroundColor3 = Theme.Get("Border"), BackgroundTransparency = 0.75, Size = UDim2.new(1, 0, 0, 1), Parent = self.Content })
	Theme.OnChanged:Connect(function() line.BackgroundColor3 = Theme.Get("Border") end)
	return line
end

function Section:CreateImage(cfg)
	cfg = cfg or {}
	local frame = Utility.New("Frame", { Name = "Image", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, cfg.Height or 120), ClipsDescendants = true, Parent = self.Content })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = frame })
	local img = Utility.New("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = cfg.Image or "", ScaleType = Enum.ScaleType.Crop, Parent = frame })
	Theme.OnChanged:Connect(function()
		frame.BackgroundColor3 = Theme.Get("ElementBackground")
		stroke.Color = Theme.Get("Border")
	end)
	return { Instance = frame, Image = img }
end

function Section:CreateThemeDropdown(cfg)
	cfg = cfg or {}
	return self:CreateDropdown({
		Title = cfg.Title or "ธีม",
		Options = Theme.Order,
		Default = Theme.Current,
		Callback = function(name) Theme.Set(name) end,
	})
end

function Section:CreateKeybind(cfg)
	cfg = cfg or {}
	local UserInputService = game:GetService("UserInputService")
	local keybind = { Value = cfg.Default or Enum.KeyCode.Unknown, Listening = false }

	local inst = Utility.New("Frame", {
		Name = "Keybind", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 36), Parent = self.Content
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = inst })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = inst })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = inst })

	Utility.New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0),
		Text = cfg.Title or "Keybind", Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = inst
	})

	local keyBtn = Utility.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(60, 22), BackgroundColor3 = Theme.Get("Background"),
		Text = keybind.Value.Name, Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = Theme.Get("Accent"), AutoButtonColor = false, Parent = inst
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = keyBtn })

	keyBtn.MouseButton1Click:Connect(function()
		keybind.Listening = true
		keyBtn.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
			keybind.Value = input.KeyCode
			keyBtn.Text = input.KeyCode.Name
			keybind.Listening = false
			return
		end
		if not processed and not keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == keybind.Value then
			Utility.SafeCall(cfg.Callback)
		end
	end)

	if cfg.Flag then
		Modules.Config.Register(cfg.Flag, {
			Get = function() return keybind.Value.Name end,
			Set = function(name)
				local ok, item = pcall(function() return Enum.KeyCode[name] end)
				if ok and item then keybind.Value = item; keyBtn.Text = item.Name end
			end,
		})
	end

	return keybind
end

return Section
end)()

Modules.Tab = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Tab = {}
Tab.__index = Tab

function Tab.new(window, tabListParent, pageParent, config)
	config = config or {}
	local self = setmetatable({}, Tab)
	self.Window = window

	self.Button = Utility.New("TextButton", { Name = "TabBtn", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Parent = tabListParent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Button })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.Button })

	self.Indicator = Utility.New("Frame", { Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Get("Accent"), BackgroundTransparency = 1, Parent = self.Button })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })

	self.IconGlow = Utility.New("Frame", {
		Name="IconGlow", BackgroundColor3=Theme.Get("Accent"), BackgroundTransparency=1,
		Position=UDim2.new(0,6,0.5,0), AnchorPoint=Vector2.new(0,0.5), Size=UDim2.fromOffset(28,28), Parent=self.Button
	})
	Utility.New("UICorner", {CornerRadius=UDim.new(0,7), Parent=self.IconGlow})
	local iconSlot = Utility.New("Frame", {Name="TabIconSlot", BackgroundTransparency=1, Position=UDim2.new(0,6,0.5,0), AnchorPoint=Vector2.new(0,0.5), Size=UDim2.fromOffset(28,28), Parent=self.Button})
	self.Icon = Modules.Icon.New(iconSlot, config.Icon or "circle", 16, UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5))

	self.Label = Utility.New("TextLabel", { Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = config.Title or "Tab", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Button })

	self.Page = Utility.New("ScrollingFrame", { Name = "Page", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Visible = false, Parent = pageParent })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = self.Page })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2), Parent = self.Page })

	self.Button.MouseButton1Click:Connect(function() self.Window:SelectTab(self) end)

	Theme.OnChanged:Connect(function()
		self.Indicator.BackgroundColor3 = Theme.Get("Accent")
		if self.IconGlow then self.IconGlow.BackgroundColor3 = Theme.Get("Accent") end
		self.Label.TextColor3 = self.Active and Theme.Get("Text") or Theme.Get("SubText")
	end)

	return self
end

function Tab:CreateSection(cfg) return Modules.Section.new(self.Page, cfg) end

function Tab:SetActive(active)
	self.Active = active
	self.Page.Visible = active
	Animation.Tween(self.Indicator, Animation.Easing.Normal, { BackgroundTransparency = active and 0 or 1 })
	if self.IconGlow then
		Animation.Tween(self.IconGlow, Animation.Easing.Normal, { BackgroundTransparency = active and 0.88 or 1 })
	end
	Animation.Tween(self.Label, Animation.Easing.Normal, { TextColor3 = active and Theme.Get("Text") or Theme.Get("SubText") })
end

return Tab
end)()

Modules.Window = (function()
local Players = game:GetService("Players")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Window = {}
Window.__index = Window

function Window.new(config)
    config = config or {}
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false

    local coreGui = game:GetService("CoreGui")
    
    self.ScreenGui = Utility.New("ScreenGui", { 
        Name = "RUNLUA-HUB", 
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = coreGui
    })

-- ====================================================================
-- RESPONSIVE AUTO-SIZE (ปรับขนาดตามอุปกรณ์อัตโนมัติ)
-- ====================================================================
local viewportSize = workspace.CurrentCamera.ViewportSize
local screenWidth = viewportSize.X
local screenHeight = viewportSize.Y

-- ตรวจจับประเภทอุปกรณ์
local isMobile = screenWidth < 600
local isTablet = screenWidth >= 600 and screenWidth < 1024
local isPC = screenWidth >= 1024

-- คำนวณขนาด UI แบบอัตโนมัติ
local uiWidth, uiHeight
if isMobile then
    uiWidth = math.min(screenWidth * 0.85, 380)
    uiHeight = math.min(screenHeight * 0.75, 300)
elseif isTablet then
    uiWidth = math.min(screenWidth * 0.7, 500)
    uiHeight = math.min(screenHeight * 0.7, 400)
else
    uiWidth = config.Width or 420
    uiHeight = config.Height or 340
end

uiWidth = math.round(uiWidth / 10) * 10
uiHeight = math.round(uiHeight / 10) * 10
uiWidth = math.max(uiWidth, 280)
uiHeight = math.max(uiHeight, 200)

self.Main = Utility.New("Frame", { 
    Name = "Main", 
    AnchorPoint = Vector2.new(0.5, 0.5), 
    Position = UDim2.fromScale(0.5, 0.5), 
    Size = UDim2.fromOffset(uiWidth, uiHeight),
    BackgroundColor3 = Theme.Get("Background"), 
    ClipsDescendants = true, 
    Parent = self.ScreenGui 
})
Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Main })
self.MainStroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1.2, Transparency = 0.2, Parent = self.Main })
	self:_buildTopBar(config.Title or "RUNLUA-HUB")
	self:_buildBody()
	self:_buildResize()
	self:_buildTogglePill()
	Modules.Notification.Init(self.ScreenGui)
	Utility.MakeDraggable(self.Main, self.TopBar)
	Animation.OpenWindow(self.Main)

	Theme.OnChanged:Connect(function()
		self.Main.BackgroundColor3 = Theme.Get("Background")
		self.MainStroke.Color = Theme.Get("Border")
		self.TopBar.BackgroundColor3 = Theme.Get("SecondaryBackground")
		self.TitleLabel.TextColor3 = Theme.Get("Accent")
		self.CloseBtn.BackgroundColor3 = Theme.Get("ElementBackground")
		self.CloseBtn.TextColor3 = Theme.Get("Text")
		self.MinBtn.BackgroundColor3 = Theme.Get("ElementBackground")
		self.MinBtn.TextColor3 = Theme.Get("Text")
		self.Sidebar.BackgroundColor3 = Theme.Get("SecondaryBackground")
		-- ปุ่มวงกลม TogglePill (ปรับสีตาม Theme)
		if self.TogglePill and self.PillStroke then
			self.PillStroke.Color = Theme.Get("Accent")
		end
	end)

	return self
end

function Window:_buildTopBar(titleText)
	self.TopBar = Utility.New("Frame", { Name = "TopBar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 40), Parent = self.Main })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.TopBar })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8), Parent = self.TopBar })

	self.TitleLabel = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -65, 1, 0), Text = titleText, Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TopBar })

	self.CloseBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.CloseBtn })
    Modules.Icon.New(self.CloseBtn, "x", 14, UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5))
self.CloseBtn.MouseButton1Click:Connect(function()
    -- ปิด Popup เก่าถ้ามี
    if self.ScreenGui:FindFirstChild("CloseConfirmPopup") then
        self.ScreenGui.CloseConfirmPopup:Destroy()
    end
    
    -- สร้าง Popup สีดำแดง
    local popup = Instance.new("Frame")
    popup.Name = "CloseConfirmPopup"
    popup.Size = UDim2.new(0, 340, 0, 150)
    popup.Position = UDim2.new(0.5, -170, 0.5, -75)
    popup.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    popup.BorderSizePixel = 0
    popup.ZIndex = 9999  -- <<< สำคัญ! ให้อยู่หน้าสุด
    popup.Parent = self.ScreenGui  -- <<< ต้องเป็น ScreenGui ไม่ใช่ Main
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 12)
    popupCorner.Parent = popup
    
    local popupStroke = Instance.new("UIStroke")
    popupStroke.Color = Color3.fromRGB(0, 191, 255)
    popupStroke.Thickness = 2.5
    popupStroke.Parent = popup
    
    -- ข้อความถาม
    local question = Instance.new("TextLabel")
    question.Size = UDim2.new(1, -20, 0, 44)
    question.Position = UDim2.new(0, 10, 0, 18)
    question.BackgroundTransparency = 1
    question.Text = "คุณจะปิดสคริป RUNLUA-HUB หรือไม่?"
    question.TextColor3 = Color3.fromRGB(255, 255, 255)
    question.Font = Enum.Font.GothamBold
    question.TextSize = 16
    question.TextWrapped = true
    question.ZIndex = 9999
    question.Parent = popup
    
    -- ปุ่ม "ใช่" (สีแดง)
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 120, 0, 40)
    yesBtn.Position = UDim2.new(0.5, -135, 0, 82)
    yesBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    yesBtn.BorderSizePixel = 0
    yesBtn.Text = "ใช่ ปิดเลย"
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextSize = 14
    yesBtn.ZIndex = 9999
    yesBtn.Parent = popup
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yesBtn
    
    -- ปุ่ม "ไม่ใช่" (สีเทา)
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 120, 0, 40)
    noBtn.Position = UDim2.new(0.5, 15, 0, 82)
    noBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    noBtn.BorderSizePixel = 0
    noBtn.Text = "ไม่ใช่"
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextSize = 14
    noBtn.ZIndex = 9999
    noBtn.Parent = popup
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noBtn
    
    -- เอฟเฟกต์ Hover
    yesBtn.MouseEnter:Connect(function()
        yesBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)
    yesBtn.MouseLeave:Connect(function()
        yesBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    end)
    
    noBtn.MouseEnter:Connect(function()
        noBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    noBtn.MouseLeave:Connect(function()
        noBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
yesBtn.MouseButton1Click:Connect(function()
    getgenv().RUNLUA_HUB_RUNNING = nil
    self.ScreenGui:Destroy()
end)
    
    -- กด "ไม่ใช่" = ปิด Popup
    noBtn.MouseButton1Click:Connect(function()
        popup:Destroy()
    end)
end)

	self.MinBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -28, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.MinBtn })
    Modules.Icon.New(self.MinBtn, "minus", 14, UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5))
	self.MinBtn.MouseButton1Click:Connect(function()
		self.Minimized = true
		Animation.CloseWindow(self.Main, function()
			self.TogglePill.Visible = true
		end)
	end)
end

function Window:_buildBody()
	self.Body = Utility.New("Frame", { Name = "Body", Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -40), BackgroundTransparency = 1, Parent = self.Main })
	self.Sidebar = Utility.New("ScrollingFrame", { Name = "Sidebar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(0, 132, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = self.Body })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = self.Sidebar })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 3), Parent = self.Sidebar })

	self.PageContainer = Utility.New("Frame", { Name = "PageContainer", Position = UDim2.new(0, 132, 0, 0), Size = UDim2.new(1, -132, 1, 0), BackgroundTransparency = 1, Parent = self.Body })
end

function Window:_buildResize()
    local UIS = game:GetService("UserInputService")
    self.MinSize = Vector2.new(360, 240)
    self.MaxSize = Vector2.new(900, 650)
    self.ResizeHandle = Utility.New("TextButton", {
        Name = "ResizeHandle", Text = "", AutoButtonColor = false,
        AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,-6,1,-6),
        Size = UDim2.fromOffset(22,22), BackgroundTransparency = 1, ZIndex = 50,
        Parent = self.Main
    })
    Modules.Icon.New(self.ResizeHandle, "grip", 17, UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5))
    local dragging, activeInput, startMouse, startSize = false, nil, nil, nil
    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeInput = input
            startMouse = input.Position
            startSize = self.Main.AbsoluteSize
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startMouse
            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
            local maxX = math.min(self.MaxSize.X, vp.X - 20)
            local maxY = math.min(self.MaxSize.Y, vp.Y - 20)
            self.Main.Size = UDim2.fromOffset(
                math.clamp(startSize.X + d.X, self.MinSize.X, maxX),
                math.clamp(startSize.Y + d.Y, self.MinSize.Y, maxY)
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            activeInput = nil
        end
    end)
end

function Window:SetUIScale(value)
    value = math.clamp(tonumber(value) or 1, 0.75, 1.35)
    if not self.UIScale then
        self.UIScale = Utility.New("UIScale", { Scale = 1, Parent = self.Main })
    end
    self.UIScale.Scale = value
end

function Window:SetTransparency(percent)
    local p = math.clamp(tonumber(percent) or 0, 0, 55) / 100
    self.Main.BackgroundTransparency = p
    self.TopBar.BackgroundTransparency = p * 0.65
    self.Sidebar.BackgroundTransparency = p * 0.65
end

function Window:SetSidebarWidth(width)
    width = math.clamp(tonumber(width) or 132, 104, 190)
    self.Sidebar.Size = UDim2.new(0, width, 1, 0)
    self.PageContainer.Position = UDim2.new(0, width, 0, 0)
    self.PageContainer.Size = UDim2.new(1, -width, 1, 0)
end

function Window:SetGlow(enabled)
    self.GlowEnabled = enabled ~= false
    self.MainStroke.Transparency = self.GlowEnabled and 0.08 or 0.78
    self.MainStroke.Thickness = self.GlowEnabled and 1.8 or 1
end

function Window:SetTogglePillSize(size)
    size = math.clamp(tonumber(size) or 54, 38, 80)
    if self.TogglePill then
        self.TogglePill.Size = UDim2.fromOffset(size, size)
    end
end

function Window:ResetTogglePill()
    if self.TogglePill then
        self.TogglePill.Position = UDim2.new(0.1, 20, 0.25, 25)
        self.TogglePill.Size = UDim2.fromOffset(54,54)
    end
end

function Window:ResetLayout()
    self.Main.AnchorPoint = Vector2.new(0.5,0.5)
    self.Main.Position = UDim2.fromScale(0.5,0.5)
    self.Main.Size = UDim2.fromOffset(500,330)
    self:SetUIScale(1)
    self:SetTransparency(0)
    self:SetSidebarWidth(132)
    self:SetGlow(true)
end


			function Window:_buildTogglePill()
    -- ====================================================================
    -- RUNLUA-HUB - PERFECT TOUCH TOGGLE PILL (PRESS ANIMATION + DRAG)
    -- ====================================================================
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    -- ลบปุ่มเก่าถ้ามี
    if self.ScreenGui:FindFirstChild("TogglePill") then
        self.ScreenGui.TogglePill:Destroy()
    end

    self.TogglePill = Instance.new("ImageButton")
    self.TogglePill.Name = "TogglePill"
    self.TogglePill.BackgroundTransparency = 1
    self.TogglePill.BorderSizePixel = 0
    self.TogglePill.ClipsDescendants = false
    self.TogglePill.ZIndex = 10
    self.TogglePill.AutoButtonColor = false
    self.TogglePill.AnchorPoint = Vector2.new(0.5, 0.5)
    self.TogglePill.Position = UDim2.new(0.1, 20, 0.25, 25)
    self.TogglePill.Size = UDim2.fromOffset(54, 54)
    self.TogglePill.Visible = true
    self.TogglePill.Parent = self.ScreenGui
    self.TogglePill.ImageTransparency = 0.05
    self.TogglePill.ScaleType = Enum.ScaleType.Crop

    -- มุมโค้งมน
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.TogglePill

    -- ขอบสีแดง
    self.PillStroke = Instance.new("UIStroke")
    self.PillStroke.Color = Color3.fromRGB(0, 191, 255)
    self.PillStroke.Thickness = 2.5
    self.PillStroke.Parent = self.TogglePill

    -- โหลดรูปภาพ
    task.spawn(function()
        pcall(function()
            local imageUrl = "https://i.postimg.cc/cJKhRc1r/IMG-20260904-201616-447.png"
            local fileName = "RUNLUA.png"
            
            if isfile and writefile and readfile and getcustomasset then
                if not isfile(fileName) then
                    local imgData = game:HttpGet(imageUrl)
                    if imgData and #imgData > 0 then
                        writefile(fileName, imgData)
                    end
                end
                if isfile(fileName) then
                    self.TogglePill.Image = getcustomasset(fileName)
                else
                    self.TogglePill.Image = imageUrl
                end
            else
                self.TogglePill.Image = imageUrl
            end
        end)
    end)

    -- ====================================================================
    -- ระบบลากปุ่ม + เอฟเฟคกดยุบตัว
    -- ====================================================================
    local dragging = false
    local activeInput = nil
    local dragStart = nil
    local startPos = nil
    local dragStartPos = Vector2.new(0, 0)
    local isDraggingHappened = false

    local function isInBounds(guiObject, pos)
        local absPos = guiObject.AbsolutePosition
        local absSize = guiObject.AbsoluteSize
        return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and
               pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
    end

    -- กดคลิกธรรมดา (เปิด/ปิดหน้าต่าง UI)
    self.TogglePill.MouseButton1Click:Connect(function()
        if not isDraggingHappened then
            if self.Main.Visible then
                self.Minimized = true
                Animation.CloseWindow(self.Main)
            else
                self.Minimized = false
                Animation.OpenWindow(self.Main)
            end
        end
    end)

    -- เริ่มจิ้ม
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging and isInBounds(self.TogglePill, input.Position) then
                dragging = true
                activeInput = input
                dragStart = input.Position
                startPos = self.TogglePill.Position
                dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
                isDraggingHappened = false

                TweenService:Create(self.TogglePill, TweenInfo.new(0.1), {Size = UDim2.fromOffset(46, 46)}):Play()
            end
        end
    end)

    -- กำลังลาก
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local deltaMove = (currentPos - dragStartPos).Magnitude

            if deltaMove > 5 then
                isDraggingHappened = true
            end

            local delta = input.Position - dragStart
            self.TogglePill.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ปล่อยนิ้ว
    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput then
            dragging = false
            activeInput = nil

            TweenService:Create(self.TogglePill, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(54, 54)}):Play()
        end
    end)

    -- ป้องกันการหาย
    task.spawn(function()
        while self.ScreenGui and self.ScreenGui.Parent do
            task.wait(1)
            if self.TogglePill and self.TogglePill.Parent ~= self.ScreenGui then
                self.TogglePill.Parent = self.ScreenGui
            end
        end
    end)

    print("[RUNLUA] TogglePill Loaded! ")
end   -- <<< end เดียวนี้จบ function

-- ลบ 2 บรรทัดนี้ทิ้ง!!!
-- print("[RUNLUA] Circle Button Loaded Successfully! ")
-- end

function Window:CreateTab(config)
	local tab = Modules.Tab.new(self, self.Sidebar, self.PageContainer, config)
	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then self.ActiveTab:SetActive(false) end
	self.ActiveTab = tab
	tab:SetActive(true)
end

return Window
end)()

local Library = {}
Library._version = "2.2.0"
function Library:CreateWindow(config) return Modules.Window.new(config) end

function Library:Notify(data) Modules.Notification.Notify(data) end
function Library:SaveConfig(name) return Modules.Config.Save(name) end
function Library:LoadConfig(name) return Modules.Config.Load(name) end
function Library:EnableAutoSave(name, interval) return Modules.Config.EnableAutoSave(name, interval) end
function Library:DisableAutoSave() return Modules.Config.DisableAutoSave() end

function Library:SetTheme(name) return Modules.Theme.Set(name) end
function Library:GetThemes() return Modules.Theme.Order end

return Library
end)()


--==================================================
-- RUNLUA COMPATIBILITY ADAPTER
-- ใช้หน้าตา UI แบบไฟล์ 2 แต่คง API/ฟังก์ชันจากไฟล์แรก
--==================================================
local Library = {}

local ICON_RULES = {
    {"บิน", "plane"}, {"กระโดด", "move-up"}, {"วิ่งเร็ว", "gauge"}, {"วาร์ป", "mouse-pointer-2"},
    {"ทะลุกำแพง", "door-open"}, {"หายตัว", "eye-off"}, {"อมตะ", "shield"},
    {"ล็อคหัว", "crosshair"}, {"ฆ่า", "skull"}, {"Hitbox", "box"}, {"กราฟิก", "rocket"},
    {"สว่าง", "sun"}, {"รถ", "car"}, {"หยิบของ", "hand"}, {"สแกน", "scan-search"},
    {"เสก", "package-plus"}, {"มองทะลุ", "eye"}, {"NPC", "bot"}, {"ดึงผู้เล่น", "magnet"},
    {"หลุมดำ", "circle-dot-dashed"}, {"ชนผู้เล่น", "bomb"}, {"ถอดเสื้อ", "shirt"},
    {"ชักว่าว", "hand"}, {"F3X", "blocks"}, {"แป้นพิมพ์", "keyboard"}, {"เซิร์ฟเวอร์", "server"},
    {"Infinite", "terminal"}, {"CMD", "square-terminal"}, {"ปรับ", "sliders-horizontal"},
    {"ตั้งค่า", "settings"}, {"UI", "panel-top"}, {"หลัก", "house"}, {"โจมตี", "swords"},
    {"เครื่องมือ", "wrench"}, {"แกล้ง", "sparkles"}, {"ดวงตาเทพ", "eye"}, {"ผู้เล่น", "users"},
}

local EMOJI_TOKENS = {"✈️","✈","⬆️","⬆","⚡","🖱️","🖱","🚪","👻","🛡️","🛡","🎯","💀","📦","🚀","☀️","☀","🚗","🤚","🔍","👁️","👁","🤖","🧲","⚫","💣","👕","🧱","⌨️","⌨","🖥️","🖥","💻","⚙️","⚙","🏠","⚔️","⚔","🔧","✨","👥","🥅","🎒","🔄","🟡","🔵","🔴","🟢","🟣","❌","✅","▶️","▶","⏩","🪄","🎮","🛠️","🛠","📡","🌀","🧰","🎭","🦶","😱","🔥","⭐","💡","📌","📍","🎨","📁","📂","🔒","🔓","🔔","🔊","🔇"}

local function CleanTitle(text)
    local out = tostring(text or "")
    for _, token in ipairs(EMOJI_TOKENS) do
        out = out:gsub(token, "")
    end
    out = out:gsub("^%s+", ""):gsub("%s+$", "")
    return out
end

local function InferIcon(text, fallback)
    local clean = CleanTitle(text)
    for _, rule in ipairs(ICON_RULES) do
        if string.find(clean, rule[1], 1, true) then return rule[2] end
    end
    return fallback or "circle-dot"
end

function Library:NewWindow(title)
    local RawWindow = RUNLUA_UI:CreateWindow({
        Title = title,
        Width = 500,
        Height = 330,
    })

    RUNLUA_UI:SetTheme("Blue")

    local Window = {Raw = RawWindow}

    function Window:NewTab(name, icon)
        local cleanName = CleanTitle(name)
        local iconName = (icon and not string.find(icon, "[^%w%-_]")) and icon or InferIcon(cleanName, "circle")
        local RawTab = RawWindow:CreateTab({
            Title = cleanName,
            Icon = iconName,
        })

        local Tab = {}
        local CurrentSection = RawTab:CreateSection({Title = cleanName, Icon = iconName})

        function Tab:NewLabel(text)
            local clean = CleanTitle(text)
            CurrentSection = RawTab:CreateSection({Title = clean, Icon = InferIcon(clean, "folder")})
            return CurrentSection
        end

        function Tab:NewButton(text, callback, helpText)
            local clean = CleanTitle(text)
            local obj = CurrentSection:CreateButton({
                Title = clean,
                Icon = InferIcon(clean, "circle-dot"),
                Callback = callback,
            })

            -- เก็บคำอธิบายเดิมไว้บน Attribute เพื่อไม่ให้ข้อมูลจากไฟล์แรกหาย
            if obj and obj.Instance and helpText then
                obj.Instance:SetAttribute("RUNLUA_Help", tostring(helpText))
            end
            return obj
        end

        function Tab:NewToggle(text, default, callback, helpText, sliderConfig)
            local sliderObj

            local clean = CleanTitle(text)
            local obj = CurrentSection:CreateToggle({
                Title = clean,
                Icon = InferIcon(clean, "toggle-right"),
                Default = default == true,
                Callback = function(v)
                    if sliderObj and sliderObj.Instance then
                        sliderObj.Instance.Visible = (v == true)
                    end
                    if callback then callback(v) end
                end,
            })

            if obj and obj.Instance and helpText then
                obj.Instance:SetAttribute("RUNLUA_Help", tostring(helpText))
            end

            if sliderConfig then
                local sliderTitle = CleanTitle(sliderConfig.text or "ปรับค่า")
                sliderObj = CurrentSection:CreateSlider({
                    Title = sliderTitle,
                    Icon = InferIcon(sliderTitle, "sliders-horizontal"),
                    Min = tonumber(sliderConfig.min) or 0,
                    Max = tonumber(sliderConfig.max) or 100,
                    Default = tonumber(sliderConfig.default) or tonumber(sliderConfig.min) or 0,
                    Increment = 1,
                    Callback = sliderConfig.callback,
                })
                if sliderObj and sliderObj.Instance then
                    sliderObj.Instance.Visible = default == true
                end
            end

            return obj
        end

        function Tab:NewSlider(text, minValue, maxValue, defaultValue, callback, increment)
            local clean = CleanTitle(text)
            return CurrentSection:CreateSlider({
                Title = clean,
                Icon = InferIcon(clean, "sliders-horizontal"),
                Min = minValue or 0,
                Max = maxValue or 100,
                Default = defaultValue or minValue or 0,
                Increment = increment or 1,
                Callback = callback,
            })
        end

        return Tab
    end

    return Window
end

--==================================================
-- FEATURE STATE
--==================================================
local State = {
    Fly = false,
    FlySpeed = 60,
    InfiniteJump = false,
    Speed = false,
    WalkSpeed = 100,
    ClickTP = false,
    Noclip = false,
    Invisible = false,
    God = false,
    Aimbot = false,
    FOV = 20,
    KillAura = false,
    KillRange = 100,
    Hitbox = false,
    HitboxSize = 20,
    FPSBoost = false,
    Fullbright = false,
    Brightness = 2,
    ClockTime = 13,
    ESPPlayers = false,
    ESPNPC = false,
    CarSpeed = 150,
    CarSpeedEnabled = false,
    PullPlayers = false,
    Blackhole = false
}

--==================================================
-- BACKUPS
--==================================================
local OriginalCollision = {}
local OriginalTransparency = {}
local OriginalHitbox = {}
local LightingBackup = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

--==================================================
-- FLY - บินตามทิศทางกล้อง
-- หันขึ้น = บินขึ้น / หันลง = บินลง
-- รองรับทั้ง PC + มือถือ
--==================================================
local FlyBV, FlyBG

local function StopFly()
    if FlyBV then
        FlyBV:Destroy()
        FlyBV = nil
    end

    if FlyBG then
        FlyBG:Destroy()
        FlyBG = nil
    end

    local h = Humanoid()
    if h then
        h.PlatformStand = false
    end
end

local function StartFly()
    StopFly()

    local root, hum = Root(), Humanoid()
    if not root or not hum then return end

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "XWACK_FlyVelocity"
    FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBV.P = 10000
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = root

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "XWACK_FlyGyro"
    FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyBG.P = 50000
    FlyBG.D = 1000
    FlyBG.CFrame = root.CFrame
    FlyBG.Parent = root

    hum.PlatformStand = true
end

Track(RunService.RenderStepped:Connect(function()
    if not State.Fly then
        return
    end

    local root, hum = Root(), Humanoid()
    if not root or not hum or not Camera then
        return
    end

    if not FlyBV or FlyBV.Parent ~= root or
       not FlyBG or FlyBG.Parent ~= root then
        StartFly()
        return
    end

    hum.PlatformStand = true

    local move = hum.MoveDirection
    local speed = State.FlySpeed or 50

    -- ทิศของกล้องแบบ 3D
    -- LookVector มีแกน Y อยู่ด้วย
    -- เพราะงั้นหันขึ้น/ลงแล้วบินตามได้
    local camCF = Camera.CFrame
    local look = camCF.LookVector
    local right = camCF.RightVector

    -- ตรวจว่ากำลังเดินไปข้างหน้า/หลัง/ซ้าย/ขวา
    -- แปลง MoveDirection เป็น local direction ของกล้อง
    local flatLook = Vector3.new(look.X, 0, look.Z)
    local flatRight = Vector3.new(right.X, 0, right.Z)

    if flatLook.Magnitude > 0.001 then
        flatLook = flatLook.Unit
    end

    if flatRight.Magnitude > 0.001 then
        flatRight = flatRight.Unit
    end

    local forwardAmount = 0
    local rightAmount = 0

    if move.Magnitude > 0.01 then
        forwardAmount = move:Dot(flatLook)
        rightAmount = move:Dot(flatRight)
    end

    -- บินตามมุมกล้องจริง
    local flyDirection =
        (look * forwardAmount) +
        (right * rightAmount)

    -- PC: Space บินขึ้นตรงๆ เพิ่มเติม
    if UIS:IsKeyDown(Enum.KeyCode.Space) then
        flyDirection += Vector3.new(0, 1, 0)
    end

    -- PC: Ctrl / C บินลงตรงๆ เพิ่มเติม
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
    or UIS:IsKeyDown(Enum.KeyCode.RightControl)
    or UIS:IsKeyDown(Enum.KeyCode.C) then
        flyDirection += Vector3.new(0, -1, 0)
    end

    -- ป้องกันแนวทแยงเร็วเกิน FlySpeed
    if flyDirection.Magnitude > 1 then
        flyDirection = flyDirection.Unit
    end

    FlyBV.Velocity = flyDirection * speed

    -- ตัวละครหันตามกล้อง
    FlyBG.CFrame = camCF
end))

--==================================================
-- INFINITE JUMP
--==================================================
Track(UIS.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = Humanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

--==================================================
-- SPEED + NOCLIP + GOD
--==================================================
Track(RunService.Stepped:Connect(function()
    local char = Character()
    local hum = Humanoid()

    if hum and State.Speed then
        hum.WalkSpeed = State.WalkSpeed
    end

    if char and State.Noclip then
        for _,obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                if OriginalCollision[obj] == nil then
                    OriginalCollision[obj] = obj.CanCollide
                end
                obj.CanCollide = false
            end
        end
    end

    if hum and State.God then
        pcall(function()
            hum.BreakJointsOnDeath = false
            hum.RequiresNeck = false
            if hum.MaxHealth < 1e9 then hum.MaxHealth = 1e9 end
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end)
    end
end))

local function RestoreCollision()
    for obj,v in pairs(OriginalCollision) do
        if obj and obj.Parent then pcall(function() obj.CanCollide=v end) end
    end
    table.clear(OriginalCollision)
end

--==================================================
-- CLICK TP TOOL
--==================================================
local ClickTool

local function RemoveClickTool()
    if ClickTool then pcall(function() ClickTool:Destroy() end) end
    ClickTool=nil
    local backpack = Player:FindFirstChildOfClass("Backpack")
    if backpack then
        local t = backpack:FindFirstChild("RUNLUA-HUB Click TP")
        if t then t:Destroy() end
    end
    local char = Character()
    if char then
        local t = char:FindFirstChild(" Click TP")
        if t then t:Destroy() end
    end
end

local function GiveClickTool()
    RemoveClickTool()
    local t = Instance.new("Tool")
    t.Name = "RUNLUA-HUB Click TP"
    t.RequiresHandle = false
    t.CanBeDropped = false

    Track(t.Activated:Connect(function()
        if not State.ClickTP then return end
        local root = Root()
        if root and Mouse and Mouse.Hit then
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0))
        end
    end))

    t.Parent = Player:WaitForChild("Backpack")
    ClickTool=t
end

--==================================================
-- INVISIBLE (LOCAL VISUAL)
--==================================================
local function SetInvisible(on)
    local char = Character()
    if not char then return end

    if on then
        for _,obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                if OriginalTransparency[obj] == nil then
                    OriginalTransparency[obj] = obj.Transparency
                end
                obj.Transparency = 1
            end
        end
    else
        for obj,v in pairs(OriginalTransparency) do
            if obj and obj.Parent then pcall(function() obj.Transparency=v end) end
        end
        table.clear(OriginalTransparency)
    end
end

--==================================================
-- AIMBOT
--==================================================
local AimCircle
pcall(function()
    if Drawing then
        AimCircle = Drawing.new("Circle")
        AimCircle.Thickness = 1.5
        AimCircle.NumSides = 45
        AimCircle.Filled = false
        AimCircle.Transparency = 0.8
        AimCircle.Color = Color3.fromRGB(0,170,255)
        AimCircle.Visible = false
    end
end)

local function FOVRadius()
    local vp = Camera.ViewportSize
    return math.min(vp.X,vp.Y)/2*(State.FOV/100)
end

local function GetAimTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2,vp.Y/2)
    local best,bestDist=nil,math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos,onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if dist <= FOVRadius() and dist < bestDist then
                        best=head
                        bestDist=dist
                    end
                end
            end
        end
    end
    return best
end

Track(RunService.RenderStepped:Connect(function()
    if AimCircle then
        AimCircle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        AimCircle.Radius = FOVRadius()
        AimCircle.Visible = State.Aimbot
    end

    if State.Aimbot then
        local target=GetAimTarget()
        if target then
            Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,target.Position)
        end
    end
end))

--==================================================
-- KILL AURA NPC
--==================================================
local function IsPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

Track(RunService.Heartbeat:Connect(function()
    if not State.KillAura then return end
    local myRoot = Root()
    if not myRoot then return end

    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model=obj.Parent
            if model and model:IsA("Model") and not IsPlayerCharacter(model) then
                local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
                if root and (root.Position-myRoot.Position).Magnitude <= State.KillRange then
                    pcall(function()
                        obj.Health=0
                    end)
                end
            end
        end
    end
end))

--==================================================
-- HITBOX
--==================================================
local function ResetHitbox()
    for part,data in pairs(OriginalHitbox) do
        if part and part.Parent then
            pcall(function()
                part.Size=data.Size
                part.Transparency=data.Transparency
                part.CanCollide=data.CanCollide
                part.Material=data.Material
            end)
        end
    end
    table.clear(OriginalHitbox)
end

Track(RunService.Heartbeat:Connect(function()
    if not State.Hitbox then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not OriginalHitbox[hrp] then
                    OriginalHitbox[hrp]={
                        Size=hrp.Size,
                        Transparency=hrp.Transparency,
                        CanCollide=hrp.CanCollide,
                        Material=hrp.Material
                    }
                end
                hrp.Size=Vector3.new(State.HitboxSize,State.HitboxSize,State.HitboxSize)
                hrp.Transparency=.65
                hrp.CanCollide=false
                hrp.Material=Enum.Material.Neon
            end
        end
    end
end))

--==================================================
-- FPS BOOST
--==================================================
local FPSBackup={}
local function ApplyFPSBoost(on)
    if on then
        for _,v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                if not FPSBackup[v] then
                    FPSBackup[v]={Material=v.Material,CastShadow=v.CastShadow}
                end
                v.Material=Enum.Material.SmoothPlastic
                v.CastShadow=false
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
            or v:IsA("Fire") or v:IsA("Sparkles") then
                if FPSBackup[v]==nil then FPSBackup[v]=v.Enabled end
                v.Enabled=false
            end
        end
        Lighting.GlobalShadows=false
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    else
        for v,data in pairs(FPSBackup) do
            if v and v.Parent then
                pcall(function()
                    if v:IsA("BasePart") then
                        v.Material=data.Material
                        v.CastShadow=data.CastShadow
                    elseif typeof(data)=="boolean" then
                        v.Enabled=data
                    end
                end)
            end
        end
        table.clear(FPSBackup)
        Lighting.GlobalShadows=LightingBackup.GlobalShadows
    end
end

--==================================================
-- FULLBRIGHT
--==================================================
local function ApplyLighting()
    if State.Fullbright then
        Lighting.FogStart=100000
        Lighting.FogEnd=100000
        Lighting.Brightness=State.Brightness
        Lighting.ClockTime=State.ClockTime
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
    else
        for k,v in pairs(LightingBackup) do
            pcall(function() Lighting[k]=v end)
        end
    end
end

--==================================================
-- ESP
--==================================================
local function ClearESP(tag)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name==tag and (v:IsA("Highlight") or v:IsA("BillboardGui")) then
            v:Destroy()
        end
    end
end

local function AddHighlight(model,tag,outlineColor)
    if not model or model:FindFirstChild(tag) then return end
    local h=Instance.new("Highlight")
    h.Name=tag
    h.Adornee=model
    h.FillTransparency=.72
    h.OutlineTransparency=0
    h.OutlineColor=outlineColor or Color3.new(1,1,1)
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent=model
end

local function EnsureBillboard(model, adornee, tag, text, color)
    if not model or not adornee then return nil end
    local bb = model:FindFirstChild(tag)
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = tag
        bb.Size = UDim2.fromOffset(190,36)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = math.huge
        bb.Adornee = adornee
        bb.Parent = model

        local label = Instance.new("TextLabel")
        label.Name = "ข้อความ"
        label.Size = UDim2.fromScale(1,1)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0.25
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.Parent = bb
    end
    local label = bb:FindFirstChild("ข้อความ")
    if label then
        label.Text = text or ""
        label.TextColor3 = color or Color3.new(1,1,1)
    end
    return bb
end

Track(RunService.Heartbeat:Connect(function()
    local myRoot = Root()

    if State.ESPPlayers then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=Player and p.Character then
                local head = p.Character:FindFirstChild("Head")
                local proot = p.Character:FindFirstChild("HumanoidRootPart")
                AddHighlight(p.Character,"XWACK_ESP_PLAYER",Color3.fromRGB(255,220,0))
                EnsureBillboard(
                    p.Character,
                    head or proot,
                    "XWACK_ESP_PLAYER_LABEL",
                    p.Name,
                    Color3.fromRGB(255,220,0)
                )
            end
        end
    end

    if State.ESPNPC then
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
                local nroot = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso")
                local hum = m:FindFirstChildOfClass("Humanoid")
                if nroot and hum and hum.Health > 0 then
                    AddHighlight(m,"XWACK_ESP_NPC",Color3.fromRGB(255,255,255))
                    local dist = myRoot and math.floor((nroot.Position-myRoot.Position).Magnitude) or 0
                    EnsureBillboard(
                        m,
                        nroot,
                        "XWACK_ESP_NPC_LABEL",
                        (m.Name ~= "" and m.Name or "NPC").."  ["..dist.." เมตร]",
                        Color3.fromRGB(255,255,255)
                    )
                end
            end
        end
    end
end))

--==================================================
-- TOOL GIVER IN SAME UI
--==================================================
local FoundToolNames={}
local function FindTools()
    local list={}
    local seen={}
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Tool") and not seen[v.Name] then
            seen[v.Name]=true
            table.insert(list,v)
        end
    end
    table.sort(list,function(a,b) return a.Name:lower()<b.Name:lower() end)
    return list
end

local function CloneTool(tool)
    if not tool then return end
    local ok,clone=pcall(function() return tool:Clone() end)
    if ok and clone then
        clone.Parent=Player:WaitForChild("Backpack")
        Notify("เสก "..tool.Name.." แล้ว")
    end
end

--==================================================
-- CAR SPEED
--==================================================
local LastVehicle, OriginalVehicleMaxSpeed

local function StopCarSpeed()
    if LastVehicle and LastVehicle.Parent and OriginalVehicleMaxSpeed then
        pcall(function() LastVehicle.MaxSpeed = OriginalVehicleMaxSpeed end)
    end
    LastVehicle = nil
    OriginalVehicleMaxSpeed = nil
end

Track(RunService.Heartbeat:Connect(function()
    if not State.CarSpeedEnabled then return end
    local hum = Humanoid()
    if not hum then return end
    local seat = hum.SeatPart

    if seat and seat:IsA("VehicleSeat") then
        if LastVehicle ~= seat then
            StopCarSpeed()
            LastVehicle = seat
            OriginalVehicleMaxSpeed = seat.MaxSpeed
        end

        pcall(function()
            seat.MaxSpeed = State.CarSpeed
            if seat.Throttle ~= 0 then
                local y = seat.AssemblyLinearVelocity.Y
                local dir = seat.CFrame.LookVector * (seat.Throttle * State.CarSpeed)
                seat.AssemblyLinearVelocity = Vector3.new(dir.X,y,dir.Z)
            end
        end)
    end
end))

--==================================================
-- PULL PLAYERS
--==================================================
local SpawnTimes = {}
local PULL_SPAWN_DELAY = 6

local function TrackSpawn(plr)
    plr.CharacterAdded:Connect(function()
        SpawnTimes[plr] = tick()
    end)
end

for _,p in ipairs(Players:GetPlayers()) do TrackSpawn(p) end
Track(Players.PlayerAdded:Connect(TrackSpawn))

Track(RunService.RenderStepped:Connect(function()
    if not State.PullPlayers then return end
    local root = Root()
    if not root then return end

    local destination = root.Position + root.CFrame.LookVector * 5
    for _,other in ipairs(Players:GetPlayers()) do
        if other ~= Player and other.Character then
            local oroot = other.Character:FindFirstChild("HumanoidRootPart")
            local ohum = other.Character:FindFirstChildOfClass("Humanoid")
            if oroot and ohum and ohum.Health > 0 then
                local spawned = SpawnTimes[other]
                if not spawned or tick() - spawned >= PULL_SPAWN_DELAY then
                    pcall(function()
                        other.Character:PivotTo(CFrame.new(destination))
                    end)
                end
            end
        end
    end
end))

--==================================================
-- BLACKHOLE
--==================================================
local BHFolder, BHPart, BHTarget
local BHDescConnection
local BHControlled = {}

local function StopBlackhole()
    if BHDescConnection then
        BHDescConnection:Disconnect()
        BHDescConnection = nil
    end
    for part,data in pairs(BHControlled) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = data.CanCollide
                part.CustomPhysicalProperties = data.CustomPhysicalProperties
                for _,name in ipairs({"XWACK_BH_Torque","XWACK_BH_Align","XWACK_BH_Att"}) do
                    local x = part:FindFirstChild(name)
                    if x then x:Destroy() end
                end
            end)
        end
    end
    table.clear(BHControlled)
    if BHFolder then BHFolder:Destroy() end
    BHFolder,BHPart,BHTarget = nil,nil,nil
end

local function ForceBlackholePart(v)
    if not State.Blackhole then return end
    if not v:IsA("BasePart") or v.Anchored or BHControlled[v] then return end
    if v:IsDescendantOf(Character() or workspace) then
        if Character() and v:IsDescendantOf(Character()) then return end
    end
    if v.Parent and (v.Parent:FindFirstChildOfClass("Humanoid") or v.Name == "Handle") then return end

    BHControlled[v] = {
        CanCollide = v.CanCollide,
        CustomPhysicalProperties = v.CustomPhysicalProperties
    }

    pcall(function()
        v.CanCollide = false
        v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)

        local att = Instance.new("Attachment")
        att.Name = "XWACK_BH_Att"
        att.Parent = v

        local torque = Instance.new("Torque")
        torque.Name = "XWACK_BH_Torque"
        torque.Torque = Vector3.new(100000,100000,100000)
        torque.Attachment0 = att
        torque.Parent = v

        local align = Instance.new("AlignPosition")
        align.Name = "XWACK_BH_Align"
        align.MaxForce = 9e15
        align.MaxVelocity = math.huge
        align.Responsiveness = 200
        align.Attachment0 = att
        align.Attachment1 = BHTarget
        align.Parent = v
    end)
end

local function StartBlackhole()
    StopBlackhole()
    local root = Root()
    if not root then return end

    BHFolder = Instance.new("Folder")
    BHFolder.Name = "XWACK_BLACKHOLE"
    BHFolder.Parent = workspace

    BHPart = Instance.new("Part")
    BHPart.Name = "Target"
    BHPart.Anchored = true
    BHPart.CanCollide = false
    BHPart.Transparency = 1
    BHPart.Size = Vector3.new(1,1,1)
    BHPart.Parent = BHFolder

    BHTarget = Instance.new("Attachment")
    BHTarget.Parent = BHPart

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Player,"SimulationRadius",math.huge)
        end
    end)

    for _,v in ipairs(workspace:GetDescendants()) do
        ForceBlackholePart(v)
    end

    BHDescConnection = workspace.DescendantAdded:Connect(function(v)
        if State.Blackhole then ForceBlackholePart(v) end
    end)
end

Track(RunService.RenderStepped:Connect(function()
    if State.Blackhole and BHPart then
        local root = Root()
        if root then
            BHPart.CFrame = root.CFrame * CFrame.new(0,0,-50)
        end
    end
end))

--==================================================
-- CHARACTER RESPAWN
--==================================================
Track(Player.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then StartFly() end
    if State.ClickTP then GiveClickTool() end
    if State.Invisible then SetInvisible(true) end
end))

--==================================================
-- BUILD UI
--==================================================
local Window=Library:NewWindow("RUNLUA-HUB STORE  |  SINGLE UI V4")

local MainTab=Window:NewTab("หลัก","house")
local AttackTab=Window:NewTab("โจมตี","swords")
local ToolTab=Window:NewTab("เครื่องมือ","wrench")
local FunTab=Window:NewTab("แกล้ง","sparkles")
local EyeTab=Window:NewTab("ดวงตาเทพ","eye")
local SettingsTab=Window:NewTab("ตั้งค่า UI","settings")

SettingsTab:NewLabel("หน้าตาและขนาด")
SettingsTab:NewSlider("ขนาด UI", 75, 135, 100, function(v)
    Window.Raw:SetUIScale(v / 100)
end, 5)

SettingsTab:NewSlider("ความโปร่งใสพื้นหลัง", 0, 55, 0, function(v)
    Window.Raw:SetTransparency(v)
end, 5)

SettingsTab:NewSlider("ความกว้างเมนูด้านซ้าย", 104, 190, 132, function(v)
    Window.Raw:SetSidebarWidth(v)
end, 2)

SettingsTab:NewToggle("ขอบเรืองแสง", true, function(v)
    Window.Raw:SetGlow(v)
end, "เปิด/ปิดเส้นขอบเรืองแสงของหน้าต่าง")

SettingsTab:NewSlider("ขนาดปุ่มโลโกลอย", 38, 80, 54, function(v)
    Window.Raw:SetTogglePillSize(v)
end, 2)

SettingsTab:NewLabel("การจัดวาง")
SettingsTab:NewButton("ขนาดกะทัดรัด", function()
    Window.Raw.Main.Size = UDim2.fromOffset(420, 290)
end, "ตั้งขนาดหน้าต่างเป็นแบบเล็ก")

SettingsTab:NewButton("ขนาดมาตรฐาน", function()
    Window.Raw.Main.Size = UDim2.fromOffset(500, 330)
end, "ตั้งขนาดหน้าต่างเป็นค่ามาตรฐาน")

SettingsTab:NewButton("ขนาดใหญ่", function()
    Window.Raw.Main.Size = UDim2.fromOffset(650, 430)
end, "ตั้งขนาดหน้าต่างให้ใหญ่ขึ้น")

SettingsTab:NewButton("รีเซ็ตตำแหน่งและขนาด", function()
    Window.Raw:ResetLayout()
end, "นำ UI กลับไปกลางจอและคืนค่าหน้าตาเดิม")

SettingsTab:NewButton("รีเซ็ตตำแหน่งปุ่มโลโก้", function()
    Window.Raw:ResetTogglePill()
end, "นำปุ่มโลโกลอยกลับไปตำแหน่งเริ่มต้น")

MainTab:NewLabel("การเคลื่อนที่ / ตัวละคร")

MainTab:NewToggle("บิน",false,function(v)
    State.Fly=v
    if v then StartFly() else StopFly() end
end,"เปิดแล้วใช้ปุ่มเดินเพื่อบังคับทิศทาง กด Space เพื่อบินขึ้น และ Ctrl/C เพื่อบินลง ปรับความเร็วได้จากแถบด้านล่าง", {
    text = "ความเร็วบิน", min = 20, max = 300, default = 60,
    callback = function(v) State.FlySpeed = v end
})

MainTab:NewToggle("กระโดดไม่จำกัด",false,function(v)
    State.InfiniteJump=v
end,"เมื่อเปิด สามารถกดกระโดดซ้ำกลางอากาศได้")

MainTab:NewToggle("วิ่งเร็ว",false,function(v)
    State.Speed=v
    if not v then
        local h=Humanoid()
        if h then h.WalkSpeed=16 end
    end
end,"เปิดเพื่อบังคับความเร็วเดินตามค่าที่ตั้งในแถบ ความเร็วเดิน ด้านล่าง", {
    text = "ความเร็วเดิน", min = 16, max = 500, default = 100,
    callback = function(v) State.WalkSpeed = v end
})

MainTab:NewToggle("วาร์ปตามจุดที่กด",false,function(v)
    State.ClickTP=v
    if v then GiveClickTool() else RemoveClickTool() end
end,"เปิดแล้วจะมี Tool ชื่อ RUNLUA-HUB Click TP ในกระเป๋า ถือ Tool แล้วแตะ/คลิกจุดที่ต้องการวาร์ป")

MainTab:NewToggle("เดินทะลุกำแพง",false,function(v)
    State.Noclip=v
    if not v then RestoreCollision() end
end,"เปิดเพื่อปิดการชนของชิ้นส่วนตัวละคร ทำให้เดินผ่านกำแพงหรือวัตถุบางชนิดได้")

MainTab:NewToggle("หายตัว",false,function(v)
    State.Invisible=v
    SetInvisible(v)
end,"ซ่อนชิ้นส่วนตัวละครฝั่งเครื่องคุณ เหมาะกับการซ่อนภาพตัวละครในหน้าจอของคุณ บางเกมอาจไม่ซิงก์ให้คนอื่นเห็น")

MainTab:NewToggle("โหมดอมตะ บางแมพ",false,function(v)
    State.God=v
end,"พยายามรักษาเลือดไว้สูงสุดและป้องกันการตายแบบ Humanoid บางเกมใช้ระบบเลือดฝั่งเซิร์ฟเวอร์จึงอาจไม่สำเร็จ")

AttackTab:NewLabel("ระบบต่อสู้")

AttackTab:NewToggle("ล็อคหัวผู้เล่น",false,function(v)
    State.Aimbot=v
end,"เมื่อเปิด กล้องจะหันไปยังศีรษะผู้เล่นที่อยู่ใกล้กลางจอที่สุดภายในขอบเขต FOV", {
    text = "ขอบเขตล็อคหัว (FOV)", min = 5, max = 100, default = 20,
    callback = function(v) State.FOV = v end
})

AttackTab:NewToggle("ฆ่าบอทใกล้ตัว",false,function(v)
    State.KillAura=v
end,"พยายามตั้งเลือด NPC ที่อยู่ในระยะให้เป็น 0 ใช้ได้เฉพาะเกมที่ยอมให้ฝั่ง Client เปลี่ยนค่า Humanoid", {
    text = "ระยะฆ่าบอท", min = 10, max = 500, default = 100,
    callback = function(v) State.KillRange = v end
})

AttackTab:NewToggle("ขยาย Hitbox ผู้เล่น",false,function(v)
    State.Hitbox=v
    if not v then ResetHitbox() end
end,"ขยาย HumanoidRootPart ของผู้เล่นอื่น เพื่อทำให้พื้นที่โดนกว้างขึ้น ปิดแล้วจะพยายามคืนค่าขนาดเดิม", {
    text = "ขนาด Hitbox", min = 2, max = 100, default = 20,
    callback = function(v) State.HitboxSize = v end
})

ToolTab:NewLabel("ประสิทธิภาพ / แสง")

ToolTab:NewToggle("ลดกราฟิก เพิ่ม FPS",false,function(v)
    State.FPSBoost=v
    ApplyFPSBoost(v)
end,"ลด Material เงา Particle และเอฟเฟกต์บางส่วนเพื่อช่วยลดภาระการเรนเดอร์ ปิดแล้วจะพยายามคืนค่าที่บันทึกไว้")

ToolTab:NewToggle("ทำแมพสว่าง",false,function(v)
    State.Fullbright=v
    ApplyLighting()
end,"เปิดเพื่อใช้ค่าความสว่างและเวลาที่ตั้งด้านล่าง พร้อมลดหมอก", {
    text = "ความสว่าง", min = 0, max = 10, default = 2,
    callback = function(v)
        State.Brightness = v
        ApplyLighting()
    end
})

ToolTab:NewLabel("รถ")

ToolTab:NewToggle("เพิ่มความเร็วรถ",false,function(v)
    State.CarSpeedEnabled=v
    if not v then StopCarSpeed() end
end,"นั่ง VehicleSeat แล้วเปิด ระบบจะบังคับ MaxSpeed และความเร็วรถต่อเนื่องตามค่าด้านล่าง", {
    text = "ความเร็วรถ", min = 20, max = 500, default = 150,
    callback = function(v) State.CarSpeed = v end
})

ToolTab:NewLabel("หยิบของเร็ว | E")

local InstantPromptEnabled = false
local OriginalHoldDuration = {}

ToolTab:NewToggle("หยิบของเร็ว | E", false, function(state)
    InstantPromptEnabled = state

    if state then
        -- เปิด: ทำ ProximityPrompt ที่มีอยู่ทั้งหมดให้กดทันที
        for _, prompt in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if OriginalHoldDuration[prompt] == nil then
                    OriginalHoldDuration[prompt] = prompt.HoldDuration
                end

                prompt.HoldDuration = 0
            end
        end
    else
        -- ปิด: คืนค่า HoldDuration เดิม
        for prompt, oldDuration in pairs(OriginalHoldDuration) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = oldDuration
            end
        end

        table.clear(OriginalHoldDuration)
    end
end, "เปิดแล้วสิ่งที่ต้องกด E หรือกดค้าง จะกดได้ทันที / ปิดแล้วคืนค่าดีเลย์เดิม")


ToolTab:NewLabel("เสกของ / Tool Giver")
ToolTab:NewButton("สแกนของในแมพ",function()
    local tools=FindTools()
    local added=0
    for _,tool in ipairs(tools) do
        if not FoundToolNames[tool.Name] then
            FoundToolNames[tool.Name]=true
            added+=1
            ToolTab:NewButton("เสก "..tool.Name,function()
                CloneTool(tool)
            end,"กดเพื่อ Clone Tool ชื่อนี้เข้า Backpack ของคุณ ใช้ได้เฉพาะ Tool ที่มีอยู่และ Clone ได้จากฝั่ง Client")
        end
    end
    Notify("พบของใหม่ "..added.." รายการ")
end,"สแกน Tool ที่มีอยู่ในเกม แล้วเพิ่มรายการของไว้ในแท็บนี้โดยตรง ไม่สร้าง UI แยก")

EyeTab:NewLabel("มองผู้เล่น / NPC")

EyeTab:NewToggle("มองทะลุ ผู้เล่น",false,function(v)
    State.ESPPlayers=v
    if not v then
        ClearESP("XWACK_ESP_PLAYER")
        ClearESP("XWACK_ESP_PLAYER_LABEL")
    end
end,"แสดงเส้นขอบสีเหลืองและชื่อผู้เล่น แม้มีสิ่งกีดขวาง")

EyeTab:NewToggle("มองทะลุ NPC ",false,function(v)
    State.ESPNPC=v
    if not v then
        ClearESP("XWACK_ESP_NPC")
        ClearESP("XWACK_ESP_NPC_LABEL")
    end
end,"ค้นหา Model ที่มี Humanoid แต่ไม่ใช่ผู้เล่น แล้วแสดงเส้นขอบ ชื่อ และระยะทาง")

FunTab:NewLabel("ระบบแกล้ง")

FunTab:NewToggle("ดึงผู้เล่นมาใกล้ตัว",false,function(v)
    State.PullPlayers=v
end,"พยายามย้ายตัวละครผู้เล่นอื่นมาไว้ด้านหน้าคุณประมาณ 5 Stud ระบบจะข้ามผู้เล่นที่เพิ่งเกิดประมาณ 6 วินาที")

FunTab:NewToggle("หลุมดำดูดของ",false,function(v)
    State.Blackhole=v
    if v then StartBlackhole() else StopBlackhole() end
end,"ดึงชิ้นส่วนฟิสิกส์ที่ไม่ Anchored และไม่ใช่ตัวละครเข้าหาจุดด้านหน้าคุณประมาณ 50 Stud บางเกมอาจไม่ซิงก์เพราะ Network Ownership")

--==================================================
-- ฟังก์ชันที่ต้องเรียกต้นฉบับโดยตรง
--==================================================
local function SafeLoad(url)
    local ok,err=pcall(function()
        local src=game:HttpGet(url)
        local fn=loadstring(src)
        if fn then fn() end
    end)
    if not ok then
        Notify("โหลดไม่สำเร็จ")
        warn(err)
    end
end

FunTab:NewButton("ชนผู้เล่นกระเด็น",function()
    SafeLoad("https://raw.githubusercontent.com/wackshopr-tech/script-roblox-all/refs/heads/main/SCRIPT-ALL-BY-WACK-SHOP/FLINGCORE/FLINGCORE.lua")
end,"ต้นฉบับไฟล์นี้ถูกเข้ารหัส/Obfuscate จึงเรียกต้นฉบับโดยตรงเมื่อกด")

FunTab:NewToggle("ถอดเสื้อผ้า หีนมใหญ่", false, function(v)
    if v then
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/clemonlang/clemon_roclothes/refs/heads/main/ClemonRC.lua"
        ))()
    end
end, "เปิด Clemon RoClothes")

FunTab:NewToggle("ชักว่าว", false, function(v)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    if v then
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- ตรวจว่าเป็น R6 หรือยัง
        if hum.RigType ~= Enum.HumanoidRigType.R6 then
            warn("กำลังเปลี่ยนเป็น R6...")

            -- พยายามเปลี่ยน Avatar เป็น R6
            local desc = hum:GetAppliedDescription()

            local success = pcall(function()
                player:LoadCharacterWithHumanoidDescription(
                    desc,
                    Enum.HumanoidRigType.R6
                )
            end)

            if not success then
                warn("ไม่สามารถเปลี่ยนเป็น R6 จากฝั่ง Client ได้")
                return
            end

            -- รอตัวละครใหม่
            char = player.CharacterAdded:Wait()
            hum = char:WaitForChild("Humanoid")
        end

        -- ตอนนี้ต้องเป็น R6 แล้วค่อยเล่น Animation
        if hum.RigType == Enum.HumanoidRigType.R6 then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://72042024"

            getgenv().FunTrack = hum:LoadAnimation(anim)
            getgenv().FunTrack.Looped = true
            getgenv().FunTrack:Play()
        end

    else
        if getgenv().FunTrack then
            getgenv().FunTrack:Stop()
            getgenv().FunTrack = nil
        end
    end
end, "เปิด = เช็ก R6 แล้วเล่นว่าว / ปิด = หยุด")

FunTab:NewButton("เครื่องมือ F3X",function()
    SafeLoad("https://pastebin.com/raw/FZmTykdY")
end,"กดเพื่อโหลดเครื่องมือ F3X จากแหล่งเดิม")

ToolTab:NewLabel("เครื่องมือคำสั่ง")

ToolTab:NewButton("แป้นพิมพ์บนหน้าจอ",function()
    SafeLoad("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt")
end,"เปิดแป้นพิมพ์เสริมของสคริปต์ต้นฉบับ ฟังก์ชันนี้จำเป็นต้องมีหน้าต่างของตัวเองเพื่อใช้เป็นคีย์บอร์ด")

ToolTab:NewButton("เข้าเซิร์ฟเวอร์คนน้อย",function()
    SafeLoad("https://raw.githubusercontent.com/runluahub-create/All-map/refs/heads/main/Low%20Population%20Server%20Finder")
end,"จะเข้าเซิฟเวอร์ทีีมีคนน้อยใช้งานได้ทุกแมพ")

ToolTab:NewButton("Infinite Yield",function()
    SafeLoad("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
end,"กดแล้วเปิด Infinite Yield ของเดิมทันที ตามที่กำหนดไว้ ไม่ถูกย้ายคำสั่งเข้ามาใน UI หลัก")

ToolTab:NewButton("Quirky CMD",function()
    SafeLoad("https://gist.github.com/someunknowndude/38cecea5be9d75cb743eac8b1eaf6758/raw")
end,"กดแล้วเปิด Quirky CMD ของเดิมทันที ตามที่กำหนดไว้")

Notify("RUNLUA-HUB UI โหลดเสร็จแล้ว!")
print("RUNLUA-HUB UI READY")

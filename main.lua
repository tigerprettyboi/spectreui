--[[
    ███████╗██████╗ ███████╗ ██████╗████████╗██████╗ ███████╗
    ██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝
    ███████╗██████╔╝█████╗  ██║        ██║   ██████╔╝█████╗  
    ╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██╔══██╗██╔══╝  
    ███████║██║     ███████╗╚██████╗   ██║   ██║  ██║███████╗
    ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
    
    SPECTRE UI Library v1.0.0
    Modern Minimal UI Framework for Roblox Executors
    
    Usage:
    local Library = loadstring(game:HttpGet("YOUR_RAW_URL/SPECTRE.lua"))()
    
    local Window = Library:CreateWindow({
        Title = "SPECTRE",
        Subtitle = "v1.0.0"
    })
    
    local Tab = Window:CreateTab({Name = "Main", Icon = "rbxassetid://7733960981"})
    Tab:CreateButton({Name = "Hello", Callback = function() print("World") end})
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════
-- LIBRARY
-- ═══════════════════════════════════════════════════════════════
local Library = {}
Library.__index = Library
Library.Windows = {}
Library.ScreenGui = nil
Library.Toggled = true
Library.ToggleKey = Enum.KeyCode.RightControl

-- ═══════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════
Library.Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Secondary = Color3.fromRGB(25, 25, 32),
    Tertiary = Color3.fromRGB(35, 35, 45),
    Border = Color3.fromRGB(55, 55, 65),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 160),
    Accent = Color3.fromRGB(0, 255, 136),
    AccentDim = Color3.fromRGB(0, 204, 106),
    Error = Color3.fromRGB(255, 85, 100),
    Warning = Color3.fromRGB(255, 190, 80),
    
    -- Glass effect settings
    GlassTransparency = 0.15,
    GlassTransparencySecondary = 0.25
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(inst, props, dur)
    local tween = TweenService:Create(inst, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {Color = color or Library.Theme.Border, Thickness = thickness or 1, Parent = parent})
end

-- ═══════════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════════
function Library:Init()
    if self.ScreenGui then return self.ScreenGui end
    
    local success, gui = pcall(function()
        return Create("ScreenGui", {
            Name = "SPECTRE",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui
        })
    end)
    
    if not success then
        gui = Create("ScreenGui", {
            Name = "SPECTRE",
            ResetOnSpawn = false,
            Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        })
    end
    
    self.ScreenGui = gui
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            self:ToggleUI()
        end
    end)
    
    return gui
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE UI
-- ═══════════════════════════════════════════════════════════════
function Library:ToggleUI()
    self.Toggled = not self.Toggled
    for _, window in pairs(self.Windows) do
        if window.Frame then
            if self.Toggled then
                -- Restore to last position
                window.Frame.Visible = true
                Tween(window.Frame, {
                    Position = window.LastPosition or window.Frame.Position
                }, 0.35)
            else
                -- Save current position and hide
                window.LastPosition = window.Frame.Position
                local hidePos = UDim2.new(window.Frame.Position.X.Scale, window.Frame.Position.X.Offset, 1.5, 0)
                local tween = Tween(window.Frame, {Position = hidePos}, 0.35)
                tween.Completed:Connect(function()
                    if not self.Toggled then
                        window.Frame.Visible = false
                    end
                end)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SET ACCENT
-- ═══════════════════════════════════════════════════════════════
function Library:SetAccent(color)
    self.Theme.Accent = color
    local h, s, v = Color3.toHSV(color)
    self.Theme.AccentDim = Color3.fromHSV(h, s, v * 0.8)
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "SPECTRE"
    local subtitle = options.Subtitle or "v1.0.0"
    local size = options.Size or UDim2.new(0, 550, 0, 400)
    
    self:Init()
    
    local Window = {Tabs = {}, ActiveTab = nil, Minimized = false, FullSize = size}
    
    -- Main Frame with Glass Effect
    Window.Frame = Create("Frame", {
        Name = "Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = self.Theme.GlassTransparency,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    AddCorner(Window.Frame, 12)
    AddStroke(Window.Frame, self.Theme.Border, 1.5)
    
    Window.OriginalPos = Window.Frame.Position
    
    -- Shadow
    Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 30, 1, 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = Window.Frame
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = Window.Frame
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Frame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Tween(Window.Frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
        end
    end)
    
    -- Title & Subtitle
    Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 20),
        Size = UDim2.new(0, 200, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = self.Theme.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close Button
    local CloseBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = self.Theme.Tertiary,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.TextDim,
        TextSize = 18,
        Parent = TitleBar
    })
    AddCorner(CloseBtn, 6)
    
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self.Theme.Error, TextColor3 = self.Theme.Text}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self.Theme.Tertiary, TextColor3 = self.Theme.TextDim}) end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window.Frame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.35)
        task.wait(0.4)
        self.ScreenGui:Destroy()
        if options.CloseCallback then options.CloseCallback() end
    end)
    
    -- Minimize Button (collapse to title bar)
    local MinBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -42, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = self.Theme.Tertiary,
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = self.Theme.TextDim,
        TextSize = 18,
        Parent = TitleBar
    })
    AddCorner(MinBtn, 6)
    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = self.Theme.Secondary}) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = self.Theme.Tertiary}) end)
    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            -- Collapse to title bar only
            Tween(Window.Frame, {Size = UDim2.new(0, size.X.Offset, 0, 41)}, 0.25)
            MinBtn.Text = "+"
        else
            -- Restore full size
            Tween(Window.Frame, {Size = Window.FullSize}, 0.25)
            MinBtn.Text = "−"
        end
    end)
    
    -- Divider
    Create("Frame", {
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    -- Sidebar with Glass Effect
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 0, 0, 41),
        Size = UDim2.new(0, 140, 1, -41),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = self.Theme.GlassTransparencySecondary,
        BorderSizePixel = 0,
        Parent = Window.Frame
    })
    AddCorner(Sidebar, 12)
    Create("Frame", {Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0, 12, 1, 0), BackgroundColor3 = self.Theme.Secondary, BackgroundTransparency = self.Theme.GlassTransparencySecondary, BorderSizePixel = 0, Parent = Sidebar})
    Create("Frame", {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = self.Theme.Secondary, BackgroundTransparency = self.Theme.GlassTransparencySecondary, BorderSizePixel = 0, Parent = Sidebar})
    
    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabContainer})
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Position = UDim2.new(0, 148, 0, 49),
        Size = UDim2.new(1, -156, 1, -57),
        BackgroundTransparency = 1,
        Parent = Window.Frame
    })
    
    table.insert(self.Windows, Window)
    
    -- ═══════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ═══════════════════════════════════════════════════════════════
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon
        
        local Tab = {Elements = {}}
        local lib = Library -- capture reference
        
        -- Tab Button
        Tab.Button = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = lib.Theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabContainer
        })
        AddCorner(Tab.Button, 6)
        
        if tabIcon then
            Tab.Icon = Create("ImageLabel", {
                Position = UDim2.new(0, 10, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                BackgroundTransparency = 1,
                Image = tabIcon,
                ImageColor3 = lib.Theme.TextDim,
                Parent = Tab.Button
            })
        end
        
        Tab.Label = Create("TextLabel", {
            Position = UDim2.new(0, tabIcon and 34 or 10, 0, 0),
            Size = UDim2.new(1, tabIcon and -44 or -20, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = lib.Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Tab.Button
        })
        
        -- Content
        Tab.Content = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = lib.Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentArea
        })
        Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Tab.Content})
        Create("UIPadding", {PaddingRight = UDim.new(0, 6), Parent = Tab.Content})
        
        Tab.Content.ChildAdded:Connect(function()
            task.wait()
            local layout = Tab.Content:FindFirstChild("UIListLayout")
            if layout then Tab.Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end
        end)
        
        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1})
                if t.Label then Tween(t.Label, {TextColor3 = lib.Theme.TextDim}) end
                if t.Icon then Tween(t.Icon, {ImageColor3 = lib.Theme.TextDim}) end
            end
            Tab.Content.Visible = true
            Tween(Tab.Button, {BackgroundTransparency = 0})
            if Tab.Label then Tween(Tab.Label, {TextColor3 = lib.Theme.Text}) end
            if Tab.Icon then Tween(Tab.Icon, {ImageColor3 = lib.Theme.Accent}) end
            Window.ActiveTab = Tab
        end
        
        Tab.Button.MouseButton1Click:Connect(SelectTab)
        Tab.Button.MouseEnter:Connect(function() if Window.ActiveTab ~= Tab then Tween(Tab.Button, {BackgroundTransparency = 0.5}) end end)
        Tab.Button.MouseLeave:Connect(function() if Window.ActiveTab ~= Tab then Tween(Tab.Button, {BackgroundTransparency = 1}) end end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then SelectTab() end
        
        -- Update canvas
        task.spawn(function()
            task.wait()
            local layout = TabContainer:FindFirstChild("UIListLayout")
            if layout then TabContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y) end
        end)
        
        -- ═══════════════════════════════════════════════════════════════
        -- TAB ELEMENTS
        -- ═══════════════════════════════════════════════════════════════
        
        function Tab:CreateSection(opts)
            opts = opts or {}
            local Section = Create("Frame", {Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = Tab.Content})
            Create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = opts.Name or "Section", TextColor3 = lib.Theme.TextDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Section})
            return Section
        end
        
        function Tab:CreateLabel(opts)
            opts = opts or {}
            local Label = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Text or "Label", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = Tab.Content})
            return {Set = function(_, text) Label.Text = text end}
        end
        
        function Tab:CreateButton(opts)
            opts = opts or {}
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, Parent = Tab.Content})
            AddCorner(Container, 8)
            local Btn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Container})
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Button", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            Btn.MouseEnter:Connect(function() Tween(Container, {BackgroundColor3 = lib.Theme.Tertiary}) end)
            Btn.MouseLeave:Connect(function() Tween(Container, {BackgroundColor3 = lib.Theme.Secondary}) end)
            Btn.MouseButton1Click:Connect(function()
                Tween(Container, {BackgroundColor3 = lib.Theme.AccentDim}, 0.1)
                task.wait(0.1)
                Tween(Container, {BackgroundColor3 = lib.Theme.Secondary})
                if opts.Callback then opts.Callback() end
            end)
            return Container
        end
        
        function Tab:CreateToggle(opts)
            opts = opts or {}
            local toggled = opts.Default or false
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Toggle", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local ToggleFrame = Create("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 40, 0, 22), BackgroundColor3 = toggled and lib.Theme.Accent or lib.Theme.Tertiary, Parent = Container})
            AddCorner(ToggleFrame, 11)
            local Knob = Create("Frame", {Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = lib.Theme.Text, Parent = ToggleFrame})
            AddCorner(Knob, 9)
            local Btn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Container})
            local function Update()
                Tween(ToggleFrame, {BackgroundColor3 = toggled and lib.Theme.Accent or lib.Theme.Tertiary})
                Tween(Knob, {Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                if opts.Callback then opts.Callback(toggled) end
            end
            Btn.MouseButton1Click:Connect(function() toggled = not toggled; Update() end)
            return {Set = function(_, state) toggled = state; Update() end, Get = function() return toggled end}
        end
        
        function Tab:CreateSlider(opts)
            opts = opts or {}
            local min, max, default = opts.Min or 0, opts.Max or 100, opts.Default or opts.Min or 0
            local increment = opts.Increment or 1
            local value = default
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -80, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Slider", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local ValueLabel = Create("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.new(0, 60, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = tostring(value), TextColor3 = lib.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = Container})
            local SliderBG = Create("Frame", {Position = UDim2.new(0, 12, 0, 32), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = lib.Theme.Tertiary, Parent = Container})
            AddCorner(SliderBG, 3)
            local SliderFill = Create("Frame", {Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = lib.Theme.Accent, Parent = SliderBG})
            AddCorner(SliderFill, 3)
            local SliderKnob = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0), Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = lib.Theme.Text, Parent = SliderBG})
            AddCorner(SliderKnob, 7)
            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                local displayPos = (value - min) / (max - min)
                Tween(SliderFill, {Size = UDim2.new(displayPos, 0, 1, 0)}, 0.1)
                Tween(SliderKnob, {Position = UDim2.new(displayPos, 0, 0.5, 0)}, 0.1)
                ValueLabel.Text = tostring(value)
                if opts.Callback then opts.Callback(value) end
            end
            SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(input) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            return {Set = function(_, val) value = math.clamp(val, min, max); local displayPos = (value - min) / (max - min); SliderFill.Size = UDim2.new(displayPos, 0, 1, 0); SliderKnob.Position = UDim2.new(displayPos, 0, 0.5, 0); ValueLabel.Text = tostring(value); if opts.Callback then opts.Callback(value) end end, Get = function() return value end}
        end
        
        function Tab:CreateTextBox(opts)
            opts = opts or {}
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Input", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local InputBG = Create("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.5, -8, 0, 26), BackgroundColor3 = lib.Theme.Tertiary, Parent = Container})
            AddCorner(InputBG, 4)
            local Input = Create("TextBox", {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Default or "", PlaceholderText = opts.Placeholder or "Enter...", PlaceholderColor3 = lib.Theme.TextDim, TextColor3 = lib.Theme.Text, TextSize = 12, ClearTextOnFocus = opts.ClearOnFocus or false, Parent = InputBG})
            Input.FocusLost:Connect(function(enter) if opts.Callback then opts.Callback(Input.Text, enter) end end)
            return {Set = function(_, text) Input.Text = text end, Get = function() return Input.Text end}
        end
        
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local items = opts.Options or {}
            local selected = opts.Default or (items[1] or "Select...")
            local opened = false
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, ClipsDescendants = true, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.4, 0, 0, 36), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Dropdown", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local DropBG = Create("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 5), Size = UDim2.new(0.5, -8, 0, 26), BackgroundColor3 = lib.Theme.Tertiary, Parent = Container})
            AddCorner(DropBG, 4)
            local SelectedLabel = Create("TextLabel", {Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = selected, TextColor3 = lib.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = DropBG})
            local Arrow = Create("TextLabel", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "▼", TextColor3 = lib.Theme.TextDim, TextSize = 10, Parent = DropBG})
            local DropList = Create("Frame", {Position = UDim2.new(0, 8, 0, 40), Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Container})
            Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = DropList})
            local function Toggle() opened = not opened; local listHeight = #items * 28; Tween(Container, {Size = UDim2.new(1, 0, 0, opened and (44 + listHeight) or 36)}); Tween(DropList, {Size = UDim2.new(1, -16, 0, opened and listHeight or 0)}); Arrow.Text = opened and "▲" or "▼" end
            local DropBtn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = DropBG})
            DropBtn.MouseButton1Click:Connect(Toggle)
            local function CreateOption(item)
                local Opt = Create("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = lib.Theme.Tertiary, Font = Enum.Font.GothamMedium, Text = item, TextColor3 = lib.Theme.Text, TextSize = 12, Parent = DropList})
                AddCorner(Opt, 4)
                Opt.MouseEnter:Connect(function() Tween(Opt, {BackgroundColor3 = lib.Theme.AccentDim}) end)
                Opt.MouseLeave:Connect(function() Tween(Opt, {BackgroundColor3 = lib.Theme.Tertiary}) end)
                Opt.MouseButton1Click:Connect(function() selected = item; SelectedLabel.Text = item; Toggle(); if opts.Callback then opts.Callback(item) end end)
                return Opt
            end
            for _, item in ipairs(items) do CreateOption(item) end
            return {Set = function(_, item) if table.find(items, item) then selected = item; SelectedLabel.Text = item; if opts.Callback then opts.Callback(item) end end end, Get = function() return selected end, Refresh = function(_, newItems) items = newItems; for _, child in pairs(DropList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end; for _, item in ipairs(items) do CreateOption(item) end end}
        end
        
        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local keyCode = opts.Default or Enum.KeyCode.Unknown
            local listening = false
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Keybind", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local KeyBtn = Create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 70, 0, 26), BackgroundColor3 = lib.Theme.Tertiary, Font = Enum.Font.GothamMedium, Text = keyCode ~= Enum.KeyCode.Unknown and keyCode.Name or "None", TextColor3 = lib.Theme.Text, TextSize = 11, Parent = Container})
            AddCorner(KeyBtn, 4)
            KeyBtn.MouseButton1Click:Connect(function() listening = true; KeyBtn.Text = "..."; Tween(KeyBtn, {BackgroundColor3 = lib.Theme.Accent}, 0.1) end)
            UserInputService.InputBegan:Connect(function(input, gp)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then keyCode = input.KeyCode; KeyBtn.Text = keyCode.Name; listening = false; Tween(KeyBtn, {BackgroundColor3 = lib.Theme.Tertiary}, 0.1); if opts.Callback then opts.Callback(keyCode) end end
                elseif input.KeyCode == keyCode and not gp then
                    if opts.Callback then opts.Callback(keyCode) end
                end
            end)
            return {Set = function(_, key) keyCode = key; KeyBtn.Text = key.Name end, Get = function() return keyCode end}
        end
        
        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Color3.fromRGB(0, 255, 136)
            local expanded = false
            local hue, sat, val = Color3.toHSV(color)
            local Container = Create("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = lib.Theme.Secondary, BackgroundTransparency = lib.Theme.GlassTransparencySecondary, ClipsDescendants = true, Parent = Tab.Content})
            AddCorner(Container, 8)
            Create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.6, 0, 0, 36), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = opts.Name or "Color", TextColor3 = lib.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container})
            local ColorBtn = Create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0, 18), Size = UDim2.new(0, 50, 0, 22), BackgroundColor3 = color, Text = "", Parent = Container})
            AddCorner(ColorBtn, 4)
            Create("UIStroke", {Color = lib.Theme.Border, Parent = ColorBtn})
            local PickerArea = Create("Frame", {Position = UDim2.new(0, 8, 0, 44), Size = UDim2.new(1, -16, 0, 120), BackgroundTransparency = 1, Parent = Container})
            local SVPicker = Create("ImageLabel", {Size = UDim2.new(1, -30, 1, 0), BackgroundColor3 = Color3.fromHSV(hue, 1, 1), Image = "rbxassetid://4155801252", Parent = PickerArea})
            AddCorner(SVPicker, 4)
            local SVCursor = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(sat, 0, 1 - val, 0), Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.new(1, 1, 1), Parent = SVPicker})
            AddCorner(SVCursor, 6)
            Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 2, Parent = SVCursor})
            local HuePicker = Create("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 20, 1, 0), Parent = PickerArea})
            AddCorner(HuePicker, 4)
            Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)), ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)), ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)), ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))}), Rotation = 90, Parent = HuePicker})
            local HueCursor = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, hue, 0), Size = UDim2.new(1, 4, 0, 6), BackgroundColor3 = Color3.new(1, 1, 1), Parent = HuePicker})
            AddCorner(HueCursor, 2)
            local function UpdateColor() color = Color3.fromHSV(hue, sat, val); ColorBtn.BackgroundColor3 = color; SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1); if opts.Callback then opts.Callback(color) end end
            local function Toggle() expanded = not expanded; Tween(Container, {Size = UDim2.new(1, 0, 0, expanded and 170 or 36)}) end
            ColorBtn.MouseButton1Click:Connect(Toggle)
            local svDragging, hueDragging = false, false
            SVPicker.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end end)
            HuePicker.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end end)
            UserInputService.InputChanged:Connect(function(input)
                if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    sat = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                    val = 1 - math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                    SVCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    UpdateColor()
                elseif hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    hue = math.clamp((input.Position.Y - HuePicker.AbsolutePosition.Y) / HuePicker.AbsoluteSize.Y, 0, 1)
                    HueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                    UpdateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging, hueDragging = false, false end end)
            return {Set = function(_, newColor) color = newColor; hue, sat, val = Color3.toHSV(color); ColorBtn.BackgroundColor3 = color; SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1); SVCursor.Position = UDim2.new(sat, 0, 1 - val, 0); HueCursor.Position = UDim2.new(0.5, 0, hue, 0) end, Get = function() return color end}
        end
        
        return Tab
    end
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFY
-- ═══════════════════════════════════════════════════════════════
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "info"
    
    self:Init()
    
    local typeColors = {success = self.Theme.Accent, error = self.Theme.Error, warning = self.Theme.Warning, info = Color3.fromRGB(70, 180, 255)}
    local accentColor = typeColors[notifType] or typeColors.info
    
    local NotifContainer = self.ScreenGui:FindFirstChild("Notifications")
    if not NotifContainer then
        NotifContainer = Create("Frame", {Name = "Notifications", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 20), Size = UDim2.new(0, 280, 1, -40), BackgroundTransparency = 1, Parent = self.ScreenGui})
        Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifContainer})
    end
    
    local Notif = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 1, ClipsDescendants = true, Parent = NotifContainer})
    AddCorner(Notif, 10)
    AddStroke(Notif, self.Theme.Border, 1)
    
    -- Accent bar with glow effect
    local AccentBar = Create("Frame", {Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = accentColor, BorderSizePixel = 0, Parent = Notif})
    AddCorner(AccentBar, 2)
    
    Create("TextLabel", {Position = UDim2.new(0, 16, 0, 12), Size = UDim2.new(1, -26, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = title, TextColor3 = self.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Notif})
    if content ~= "" then Create("TextLabel", {Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(1, -26, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = content, TextColor3 = self.Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = Notif}) end
    
    local textHeight = content ~= "" and 22 or 0
    local totalHeight = 52 + textHeight
    
    local ProgressBG = Create("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -10), Size = UDim2.new(1, -32, 0, 3), BackgroundColor3 = self.Theme.Tertiary, BackgroundTransparency = 0.5, Parent = Notif})
    AddCorner(ProgressBG, 2)
    local Progress = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = accentColor, Parent = ProgressBG})
    AddCorner(Progress, 2)
    
    -- Animate with glass transparency
    Tween(Notif, {Size = UDim2.new(1, 0, 0, totalHeight), BackgroundTransparency = self.Theme.GlassTransparency}, 0.3)
    task.delay(0.3, function() TweenService:Create(Progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play() end)
    task.delay(duration + 0.3, function()
        local hideTween = Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        hideTween.Completed:Wait()
        Notif:Destroy()
    end)
    
    return Notif
end

return Library

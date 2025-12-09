--[[
    ███████╗██████╗ ███████╗ ██████╗████████╗██████╗ ███████╗
    ██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝
    ███████╗██████╔╝█████╗  ██║        ██║   ██████╔╝█████╗  
    ╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██╔══██╗██╔══╝  
    ███████║██║     ███████╗╚██████╗   ██║   ██║  ██║███████╗
    ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
    
    SPECTRE UI Library v2.0.0
    Spotify-Inspired Modern UI for Roblox Executors
    
    Features:
    - Pure black Spotify-style theme
    - Search bar to filter features
    - Card-based component design
    - Smooth premium animations
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
-- SPOTIFY-INSPIRED THEME
-- ═══════════════════════════════════════════════════════════════
Library.Theme = {
    -- Core colors (Spotify-inspired)
    Background = Color3.fromRGB(0, 0, 0),           -- Pure black
    Surface = Color3.fromRGB(18, 18, 18),           -- Dark surface
    Card = Color3.fromRGB(24, 24, 24),              -- Card background
    CardHover = Color3.fromRGB(40, 40, 40),         -- Card hover
    Border = Color3.fromRGB(40, 40, 40),            -- Subtle borders
    
    -- Text colors
    Text = Color3.fromRGB(255, 255, 255),           -- Primary white
    TextSecondary = Color3.fromRGB(179, 179, 179),  -- Gray text
    TextTertiary = Color3.fromRGB(114, 114, 114),   -- Dim gray
    
    -- Accent colors (Spotify green)
    Accent = Color3.fromRGB(29, 185, 84),           -- Spotify green
    AccentHover = Color3.fromRGB(30, 215, 96),      -- Bright green
    AccentDim = Color3.fromRGB(22, 140, 63),        -- Dim green
    
    -- Status colors
    Error = Color3.fromRGB(255, 75, 85),
    Warning = Color3.fromRGB(255, 180, 60),
    
    -- Glass effect
    GlassEnabled = true
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
    local tween = TweenService:Create(inst, TweenInfo.new(dur or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {Color = color or Library.Theme.Border, Thickness = thickness or 1, Transparency = 0.5, Parent = parent})
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
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
                window.Frame.Visible = true
                Tween(window.Frame, {Position = window.LastPosition or window.Frame.Position}, 0.35)
            else
                window.LastPosition = window.Frame.Position
                local hidePos = UDim2.new(window.Frame.Position.X.Scale, window.Frame.Position.X.Offset, 1.5, 0)
                local tween = Tween(window.Frame, {Position = hidePos}, 0.35)
                tween.Completed:Connect(function()
                    if not self.Toggled then window.Frame.Visible = false end
                end)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SET ACCENT COLOR
-- ═══════════════════════════════════════════════════════════════
function Library:SetAccent(color)
    self.Theme.Accent = color
    local h, s, v = Color3.toHSV(color)
    self.Theme.AccentHover = Color3.fromHSV(h, s, math.min(v * 1.15, 1))
    self.Theme.AccentDim = Color3.fromHSV(h, s, v * 0.75)
end

-- ═══════════════════════════════════════════════════════════════
-- SET GLASS EFFECT
-- ═══════════════════════════════════════════════════════════════
function Library:SetGlassEnabled(enabled)
    self.Theme.GlassEnabled = enabled
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW (SPOTIFY STYLE)
-- ═══════════════════════════════════════════════════════════════
function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "SPECTRE"
    local subtitle = options.Subtitle or "v2.0.0"
    local size = options.Size or UDim2.new(0, 600, 0, 450)
    
    self:Init()
    
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        FullSize = size,
        AllElements = {} -- For search
    }
    
    -- Main Frame
    Window.Frame = Create("Frame", {
        Name = "Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    AddCorner(Window.Frame, 12)
    AddStroke(Window.Frame, self.Theme.Border, 1)
    
    -- Shadow
    Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 6),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = Window.Frame
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- HEADER (with Search Bar)
    -- ═══════════════════════════════════════════════════════════
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Parent = Window.Frame
    })
    
    -- Header corner fix
    Create("Frame", {
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Parent = Header
    })
    AddCorner(Header, 12)
    
    -- Dragging
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Frame.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Tween(Window.Frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
    
    -- Title
    Create("TextLabel", {
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Search Bar Container
    local SearchContainer = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 280, 0, 34),
        BackgroundColor3 = self.Theme.Card,
        Parent = Header
    })
    AddCorner(SearchContainer, 17)
    
    -- Search Icon
    Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "🔍",
        TextColor3 = self.Theme.TextTertiary,
        TextSize = 14,
        Parent = SearchContainer
    })
    
    -- Search Input
    local SearchInput = Create("TextBox", {
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = self.Theme.TextTertiary,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchContainer
    })
    
    -- Window Controls
    local ControlsContainer = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 90, 0, 30),
        BackgroundTransparency = 1,
        Parent = Header
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = ControlsContainer
    })
    
    -- Minimize Button
    local MinBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = self.Theme.Card,
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 16,
        Parent = ControlsContainer
    })
    AddCorner(MinBtn, 6)
    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = self.Theme.CardHover}) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = self.Theme.Card}) end)
    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(Window.Frame, {Size = UDim2.new(0, size.X.Offset, 0, 50)}, 0.25)
            MinBtn.Text = "+"
        else
            Tween(Window.Frame, {Size = Window.FullSize}, 0.25)
            MinBtn.Text = "−"
        end
    end)
    
    -- Close Button
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = self.Theme.Card,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 18,
        Parent = ControlsContainer
    })
    AddCorner(CloseBtn, 6)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self.Theme.Error, TextColor3 = self.Theme.Text}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self.Theme.Card, TextColor3 = self.Theme.TextSecondary}) end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window.Frame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.35)
        task.wait(0.4)
        self.ScreenGui:Destroy()
        if options.CloseCallback then options.CloseCallback() end
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- SIDEBAR (Spotify Style)
    -- ═══════════════════════════════════════════════════════════
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 160, 1, -50),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = Window.Frame
    })
    
    -- Sidebar Nav Container
    local NavContainer = Create("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, 12),
        Size = UDim2.new(1, -16, 1, -24),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NavContainer})
    
    -- ═══════════════════════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════════════════════
    local ContentArea = Create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 168, 0, 58),
        Size = UDim2.new(1, -176, 1, -66),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Parent = Window.Frame
    })
    AddCorner(ContentArea, 10)
    
    table.insert(self.Windows, Window)
    
    -- ═══════════════════════════════════════════════════════════
    -- SEARCH FUNCTIONALITY
    -- ═══════════════════════════════════════════════════════════
    local function FilterElements(query)
        query = string.lower(query)
        for _, tab in pairs(Window.Tabs) do
            for _, element in pairs(tab.Elements) do
                if element.Container and element.Name then
                    local matchName = string.find(string.lower(element.Name), query, 1, true)
                    local matchTab = string.find(string.lower(tab.Name), query, 1, true)
                    element.Container.Visible = query == "" or matchName or matchTab
                end
            end
        end
    end
    
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        FilterElements(SearchInput.Text)
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- CREATE TAB (Spotify Style)
    -- ═══════════════════════════════════════════════════════════
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon
        
        local Tab = {
            Name = tabName,
            Elements = {}
        }
        local lib = Library
        
        -- Tab Button Container
        Tab.Button = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            Parent = NavContainer
        })
        
        -- Active Indicator (Green bar)
        Tab.ActiveIndicator = Create("Frame", {
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 3, 0, 20),
            BackgroundColor3 = lib.Theme.Accent,
            BackgroundTransparency = 1,
            Parent = Tab.Button
        })
        AddCorner(Tab.ActiveIndicator, 2)
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -8, 1, 0),
            BackgroundColor3 = lib.Theme.Card,
            BackgroundTransparency = 1,
            Text = "",
            Parent = Tab.Button
        })
        AddCorner(TabBtn, 8)
        
        -- Icon
        local iconOffset = 0
        if tabIcon then
            Tab.Icon = Create("ImageLabel", {
                Position = UDim2.new(0, 12, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 1,
                Image = tabIcon,
                ImageColor3 = lib.Theme.TextSecondary,
                Parent = TabBtn
            })
            iconOffset = 28
        end
        
        -- Label
        Tab.Label = Create("TextLabel", {
            Position = UDim2.new(0, 12 + iconOffset, 0, 0),
            Size = UDim2.new(1, -20 - iconOffset, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = lib.Theme.TextSecondary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })
        
        -- Content ScrollFrame
        Tab.Content = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = lib.Theme.CardHover,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentArea
        })
        Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Tab.Content})
        Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12), Parent = Tab.Content})
        
        Tab.Content.ChildAdded:Connect(function()
            task.wait()
            local layout = Tab.Content:FindFirstChild("UIListLayout")
            if layout then Tab.Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20) end
        end)
        
        -- Tab Selection
        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.ActiveIndicator, {BackgroundTransparency = 1})
                if t.Label then Tween(t.Label, {TextColor3 = lib.Theme.TextSecondary}) end
                if t.Icon then Tween(t.Icon, {ImageColor3 = lib.Theme.TextSecondary}) end
            end
            Tab.Content.Visible = true
            Tween(Tab.ActiveIndicator, {BackgroundTransparency = 0})
            if Tab.Label then Tween(Tab.Label, {TextColor3 = lib.Theme.Text}) end
            if Tab.Icon then Tween(Tab.Icon, {ImageColor3 = lib.Theme.Accent}) end
            Window.ActiveTab = Tab
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1})
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then SelectTab() end
        
        -- Update nav canvas
        task.spawn(function()
            task.wait()
            local layout = NavContainer:FindFirstChild("UIListLayout")
            if layout then NavContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y) end
        end)
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: SECTION
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateSection(opts)
            opts = opts or {}
            local Section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = Tab.Content
            })
            Create("TextLabel", {
                Position = UDim2.new(0, 4, 0, 8),
                Size = UDim2.new(1, -8, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = string.upper(opts.Name or "Section"),
                TextColor3 = lib.Theme.TextTertiary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })
            return Section
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: LABEL
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateLabel(opts)
            opts = opts or {}
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = opts.Text or "Label",
                TextColor3 = lib.Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = Tab.Content
            })
            return {Set = function(_, text) Label.Text = text end}
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: BUTTON (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateButton(opts)
            opts = opts or {}
            local elementName = opts.Name or "Button"
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            local Btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Container
            })
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -68, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            -- Action indicator
            local Arrow = Create("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "→",
                TextColor3 = lib.Theme.TextTertiary,
                TextSize = 16,
                Parent = Container
            })
            
            Btn.MouseEnter:Connect(function()
                Tween(Container, {BackgroundColor3 = lib.Theme.CardHover})
                Tween(Arrow, {TextColor3 = lib.Theme.Accent})
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Container, {BackgroundColor3 = lib.Theme.Card})
                Tween(Arrow, {TextColor3 = lib.Theme.TextTertiary})
            end)
            Btn.MouseButton1Click:Connect(function()
                Tween(Container, {BackgroundColor3 = lib.Theme.AccentDim}, 0.1)
                task.wait(0.1)
                Tween(Container, {BackgroundColor3 = lib.Theme.Card})
                if opts.Callback then opts.Callback() end
            end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return Container
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: TOGGLE (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateToggle(opts)
            opts = opts or {}
            local elementName = opts.Name or "Toggle"
            local toggled = opts.Default or false
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            -- Toggle Switch
            local ToggleFrame = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0),
                Size = UDim2.new(0, 44, 0, 24),
                BackgroundColor3 = toggled and lib.Theme.Accent or lib.Theme.CardHover,
                Parent = Container
            })
            AddCorner(ToggleFrame, 12)
            
            local Knob = Create("Frame", {
                Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundColor3 = lib.Theme.Text,
                Parent = ToggleFrame
            })
            AddCorner(Knob, 10)
            
            local Btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Container
            })
            
            local function Update()
                Tween(ToggleFrame, {BackgroundColor3 = toggled and lib.Theme.Accent or lib.Theme.CardHover})
                Tween(Knob, {Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)})
                if opts.Callback then opts.Callback(toggled) end
            end
            
            Btn.MouseEnter:Connect(function() Tween(Container, {BackgroundColor3 = lib.Theme.CardHover}) end)
            Btn.MouseLeave:Connect(function() Tween(Container, {BackgroundColor3 = lib.Theme.Card}) end)
            Btn.MouseButton1Click:Connect(function() toggled = not toggled; Update() end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {Set = function(_, state) toggled = state; Update() end, Get = function() return toggled end}
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: SLIDER (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateSlider(opts)
            opts = opts or {}
            local elementName = opts.Name or "Slider"
            local min, max, default = opts.Min or 0, opts.Max or 100, opts.Default or opts.Min or 0
            local increment = opts.Increment or 1
            local value = default
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = lib.Theme.Card,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(1, -90, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            local ValueLabel = Create("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 10),
                Size = UDim2.new(0, 60, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = tostring(value),
                TextColor3 = lib.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Container
            })
            
            local SliderBG = Create("Frame", {
                Position = UDim2.new(0, 14, 0, 36),
                Size = UDim2.new(1, -28, 0, 6),
                BackgroundColor3 = lib.Theme.CardHover,
                Parent = Container
            })
            AddCorner(SliderBG, 3)
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = lib.Theme.Accent,
                Parent = SliderBG
            })
            AddCorner(SliderFill, 3)
            
            local SliderKnob = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = lib.Theme.Text,
                Parent = SliderBG
            })
            AddCorner(SliderKnob, 8)
            
            local dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                local displayPos = (value - min) / (max - min)
                Tween(SliderFill, {Size = UDim2.new(displayPos, 0, 1, 0)}, 0.08)
                Tween(SliderKnob, {Position = UDim2.new(displayPos, 0, 0.5, 0)}, 0.08)
                ValueLabel.Text = tostring(value)
                if opts.Callback then opts.Callback(value) end
            end
            
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {
                Set = function(_, val)
                    value = math.clamp(val, min, max)
                    local displayPos = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(displayPos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(displayPos, 0, 0.5, 0)
                    ValueLabel.Text = tostring(value)
                    if opts.Callback then opts.Callback(value) end
                end,
                Get = function() return value end
            }
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: TEXTBOX (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateTextBox(opts)
            opts = opts or {}
            local elementName = opts.Name or "Input"
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            local InputBG = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0.5, -10, 0, 30),
                BackgroundColor3 = lib.Theme.Surface,
                Parent = Container
            })
            AddCorner(InputBG, 6)
            
            local Input = Create("TextBox", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = opts.Default or "",
                PlaceholderText = opts.Placeholder or "Enter...",
                PlaceholderColor3 = lib.Theme.TextTertiary,
                TextColor3 = lib.Theme.Text,
                TextSize = 13,
                ClearTextOnFocus = opts.ClearOnFocus or false,
                Parent = InputBG
            })
            
            Input.FocusLost:Connect(function(enter)
                if opts.Callback then opts.Callback(Input.Text, enter) end
            end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {Set = function(_, text) Input.Text = text end, Get = function() return Input.Text end}
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: DROPDOWN (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local elementName = opts.Name or "Dropdown"
            local items = opts.Options or {}
            local selected = opts.Default or (items[1] or "Select...")
            local opened = false
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                ClipsDescendants = true,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.4, 0, 0, 44),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            local DropBG = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 7),
                Size = UDim2.new(0.5, -10, 0, 30),
                BackgroundColor3 = lib.Theme.Surface,
                Parent = Container
            })
            AddCorner(DropBG, 6)
            
            local SelectedLabel = Create("TextLabel", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -35, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = selected,
                TextColor3 = lib.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = DropBG
            })
            
            local Arrow = Create("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = lib.Theme.TextTertiary,
                TextSize = 10,
                Parent = DropBG
            })
            
            local DropList = Create("Frame", {
                Position = UDim2.new(0, 10, 0, 48),
                Size = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Parent = Container
            })
            Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = DropList})
            
            local function Toggle()
                opened = not opened
                local listHeight = #items * 32 + (#items - 1) * 4
                Tween(Container, {Size = UDim2.new(1, 0, 0, opened and (52 + listHeight) or 44)})
                Tween(DropList, {Size = UDim2.new(1, -20, 0, opened and listHeight or 0)})
                Arrow.Text = opened and "▲" or "▼"
            end
            
            local DropBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropBG
            })
            DropBtn.MouseButton1Click:Connect(Toggle)
            
            local function CreateOption(item)
                local Opt = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = lib.Theme.CardHover,
                    Font = Enum.Font.GothamMedium,
                    Text = item,
                    TextColor3 = lib.Theme.Text,
                    TextSize = 13,
                    Parent = DropList
                })
                AddCorner(Opt, 6)
                Opt.MouseEnter:Connect(function() Tween(Opt, {BackgroundColor3 = lib.Theme.Accent}) end)
                Opt.MouseLeave:Connect(function() Tween(Opt, {BackgroundColor3 = lib.Theme.CardHover}) end)
                Opt.MouseButton1Click:Connect(function()
                    selected = item
                    SelectedLabel.Text = item
                    Toggle()
                    if opts.Callback then opts.Callback(item) end
                end)
                return Opt
            end
            
            for _, item in ipairs(items) do CreateOption(item) end
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {
                Set = function(_, item)
                    if table.find(items, item) then
                        selected = item
                        SelectedLabel.Text = item
                        if opts.Callback then opts.Callback(item) end
                    end
                end,
                Get = function() return selected end,
                Refresh = function(_, newItems)
                    items = newItems
                    for _, child in pairs(DropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, item in ipairs(items) do CreateOption(item) end
                end
            }
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: KEYBIND (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local elementName = opts.Name or "Keybind"
            local keyCode = opts.Default or Enum.KeyCode.Unknown
            local listening = false
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            local KeyBtn = Create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 80, 0, 30),
                BackgroundColor3 = lib.Theme.Surface,
                Font = Enum.Font.GothamMedium,
                Text = keyCode ~= Enum.KeyCode.Unknown and keyCode.Name or "None",
                TextColor3 = lib.Theme.Text,
                TextSize = 12,
                Parent = Container
            })
            AddCorner(KeyBtn, 6)
            
            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Tween(KeyBtn, {BackgroundColor3 = lib.Theme.Accent}, 0.1)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keyCode = input.KeyCode
                        KeyBtn.Text = keyCode.Name
                        listening = false
                        Tween(KeyBtn, {BackgroundColor3 = lib.Theme.Surface}, 0.1)
                        if opts.Callback then opts.Callback(keyCode) end
                    end
                elseif input.KeyCode == keyCode and not gp then
                    if opts.Callback then opts.Callback(keyCode) end
                end
            end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {Set = function(_, key) keyCode = key; KeyBtn.Text = key.Name end, Get = function() return keyCode end}
        end
        
        -- ═══════════════════════════════════════════════════════
        -- COMPONENT: COLORPICKER (Card Style)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local elementName = opts.Name or "Color"
            local color = opts.Default or Color3.fromRGB(29, 185, 84)
            local expanded = false
            local hue, sat, val = Color3.toHSV(color)
            
            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = lib.Theme.Card,
                ClipsDescendants = true,
                Parent = Tab.Content
            })
            AddCorner(Container, 8)
            
            Create("TextLabel", {
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.6, 0, 0, 44),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = elementName,
                TextColor3 = lib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })
            
            local ColorBtn = Create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0, 22),
                Size = UDim2.new(0, 60, 0, 28),
                BackgroundColor3 = color,
                Text = "",
                Parent = Container
            })
            AddCorner(ColorBtn, 6)
            AddStroke(ColorBtn, lib.Theme.Border, 1)
            
            local PickerArea = Create("Frame", {
                Position = UDim2.new(0, 10, 0, 52),
                Size = UDim2.new(1, -20, 0, 130),
                BackgroundTransparency = 1,
                Parent = Container
            })
            
            local SVPicker = Create("ImageLabel", {
                Size = UDim2.new(1, -35, 1, 0),
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                Image = "rbxassetid://4155801252",
                Parent = PickerArea
            })
            AddCorner(SVPicker, 6)
            
            local SVCursor = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(sat, 0, 1 - val, 0),
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = SVPicker
            })
            AddCorner(SVCursor, 7)
            Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 2, Parent = SVCursor})
            
            local HuePicker = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 25, 1, 0),
                Parent = PickerArea
            })
            AddCorner(HuePicker, 6)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                }),
                Rotation = 90,
                Parent = HuePicker
            })
            
            local HueCursor = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, hue, 0),
                Size = UDim2.new(1, 6, 0, 8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = HuePicker
            })
            AddCorner(HueCursor, 3)
            
            local function UpdateColor()
                color = Color3.fromHSV(hue, sat, val)
                ColorBtn.BackgroundColor3 = color
                SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                if opts.Callback then opts.Callback(color) end
            end
            
            local function Toggle()
                expanded = not expanded
                Tween(Container, {Size = UDim2.new(1, 0, 0, expanded and 190 or 44)})
            end
            
            ColorBtn.MouseButton1Click:Connect(Toggle)
            
            local svDragging, hueDragging = false, false
            SVPicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
            end)
            HuePicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
            end)
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
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDragging, hueDragging = false, false
                end
            end)
            
            table.insert(Tab.Elements, {Container = Container, Name = elementName})
            return {
                Set = function(_, newColor)
                    color = newColor
                    hue, sat, val = Color3.toHSV(color)
                    ColorBtn.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    SVCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    HueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                end,
                Get = function() return color end
            }
        end
        
        return Tab
    end
    
    return Window
end

return Library

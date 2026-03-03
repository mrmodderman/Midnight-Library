-- NovaLib UI Library v1.0
-- A beginner-friendly Roblox exploit UI library
-- Inspired by Seere, CheatX, Vozoid, and Vigil UI styles

local NovaLib = {}
NovaLib.__index = NovaLib

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Default Theme (Dark with Purple accent - matching the reference UIs)
local Theme = {
    Background      = Color3.fromRGB(20, 20, 25),
    TopBar          = Color3.fromRGB(15, 15, 20),
    Section         = Color3.fromRGB(28, 28, 35),
    Element         = Color3.fromRGB(35, 35, 43),
    ElementHover    = Color3.fromRGB(45, 45, 55),
    Accent          = Color3.fromRGB(100, 60, 200),   -- Purple
    AccentDark      = Color3.fromRGB(70, 40, 150),
    Text            = Color3.fromRGB(220, 220, 230),
    TextDim         = Color3.fromRGB(140, 140, 160),
    Border          = Color3.fromRGB(55, 55, 70),
    Toggle_ON       = Color3.fromRGB(100, 60, 200),
    Toggle_OFF      = Color3.fromRGB(50, 50, 65),
    Slider          = Color3.fromRGB(100, 60, 200),
    SliderBack      = Color3.fromRGB(40, 40, 55),
    Dropdown        = Color3.fromRGB(30, 30, 40),
    Separator       = Color3.fromRGB(55, 55, 75),
}

-- Utility Functions
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj, props, t)
    t = t or 0.15
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- =============================================
--  WINDOW
-- =============================================

function NovaLib:CreateWindow(config)
    config = config or {}
    local title     = config.Title or "NovaLib"
    local subtitle  = config.Subtitle or "v1.0"
    local key       = config.ToggleKey or Enum.KeyCode.RightShift

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name            = "NovaLib_" .. title,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = (gethui and gethui()) or game:GetService("CoreGui"),
    })

    -- Main Frame
    local Main = Create("Frame", {
        Name            = "Main",
        Size            = UDim2.new(0, 580, 0, 400),
        Position        = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent          = ScreenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Main })
    Create("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Parent = Main })

    -- Top Bar
    local TopBar = Create("Frame", {
        Name            = "TopBar",
        Size            = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent          = Main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TopBar })

    -- Fix bottom corners of topbar
    Create("Frame", {
        Size            = UDim2.new(1, 0, 0.5, 0),
        Position        = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent          = TopBar,
    })

    -- Title
    Create("TextLabel", {
        Text            = title .. "  " .. subtitle,
        Size            = UDim2.new(1, -60, 1, 0),
        Position        = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        TextSize        = 14,
        TextColor3      = Theme.Text,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = TopBar,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Text            = "✕",
        Size            = UDim2.new(0, 30, 0, 30),
        Position        = UDim2.new(1, -34, 0, 3),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        TextSize        = 14,
        TextColor3      = Theme.TextDim,
        Parent          = TopBar,
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)
    CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80) end)
    CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Theme.TextDim end)

    -- Tab bar
    local TabBar = Create("Frame", {
        Name            = "TabBar",
        Size            = UDim2.new(0, 140, 1, -36),
        Position        = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent          = Main,
    })
    Create("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Padding         = UDim.new(0, 2),
        Parent          = TabBar,
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = TabBar })

    -- Content area
    local ContentArea = Create("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, -140, 1, -36),
        Position        = UDim2.new(0, 140, 0, 36),
        BackgroundTransparency = 1,
        Parent          = Main,
    })

    -- Separator line between tab bar and content
    Create("Frame", {
        Size            = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent          = ContentArea,
    })

    MakeDraggable(Main, TopBar)

    -- Toggle visibility with key
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == key then
            Main.Visible = not Main.Visible
        end
    end)

    -- =============================================
    --  TAB
    -- =============================================
    function Window:AddTab(tabName)
        local Tab = {}
        Tab.Name = tabName
        Tab.Sections = {}

        -- Tab button
        local TabBtn = Create("TextButton", {
            Text            = tabName,
            Size            = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Font            = Enum.Font.Gotham,
            TextSize        = 13,
            TextColor3      = Theme.TextDim,
            Parent          = TabBar,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = TabBtn })

        -- Tab content frame
        local TabFrame = Create("ScrollingFrame", {
            Name            = tabName,
            Size            = UDim2.new(1, -8, 1, -8),
            Position        = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            CanvasSize      = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible         = false,
            Parent          = ContentArea,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = TabFrame,
        })
        Create("UIPadding", { PaddingTop = UDim.new(0, 4), Parent = TabFrame })

        Tab.Frame = TabFrame
        Tab.Button = TabBtn

        -- Tab click logic
        TabBtn.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, t in pairs(Window.Tabs) do
                t.Frame.Visible = false
                Tween(t.Button, { BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDim })
            end
            -- Show this tab
            TabFrame.Visible = true
            Tween(TabBtn, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
            Window.ActiveTab = Tab
        end)

        -- Activate first tab by default
        if #Window.Tabs == 0 then
            TabFrame.Visible = true
            TabBtn.BackgroundColor3 = Theme.Accent
            TabBtn.TextColor3 = Theme.Text
            Window.ActiveTab = Tab
        end

        table.insert(Window.Tabs, Tab)

        -- =============================================
        --  SECTION
        -- =============================================
        function Tab:AddSection(sectionName)
            local Section = {}

            local SectionFrame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0,
                Parent          = TabFrame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SectionFrame })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = SectionFrame })

            local SectionList = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position        = UDim2.new(0, 0, 0, 0),
                Parent          = SectionFrame,
            })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
                Parent = SectionList,
            })

            -- Section header
            local SectionHeader = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Theme.AccentDark,
                BorderSizePixel = 0,
                Parent          = SectionList,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SectionHeader })
            Create("Frame", { -- Remove bottom radius
                Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0),
                BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, Parent = SectionHeader
            })
            Create("TextLabel", {
                Text            = sectionName,
                Size            = UDim2.new(1, -10, 1, 0),
                Position        = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Font            = Enum.Font.GothamBold,
                TextSize        = 12,
                TextColor3      = Theme.Text,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = SectionHeader,
            })

            -- Elements container
            local ElementList = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent          = SectionList,
            })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 1),
                Parent = ElementList,
            })
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6), PaddingTop = UDim.new(0, 4),
                Parent = ElementList,
            })

            Section.Frame = ElementList

            -- =============================================
            --  LABEL
            -- =============================================
            function Section:AddLabel(text)
                Create("TextLabel", {
                    Text            = text,
                    Size            = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 12,
                    TextColor3      = Theme.TextDim,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = ElementList,
                })
            end

            -- =============================================
            --  SEPARATOR
            -- =============================================
            function Section:AddSeparator()
                Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Separator,
                    BorderSizePixel = 0,
                    Parent          = ElementList,
                })
            end

            -- =============================================
            --  BUTTON
            -- =============================================
            function Section:AddButton(text, callback)
                callback = callback or function() end

                local Btn = Create("TextButton", {
                    Text            = text,
                    Size            = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    Parent          = ElementList,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
                Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Btn })

                Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Accent }) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Element }) end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, { BackgroundColor3 = Theme.AccentDark })
                    task.delay(0.1, function() Tween(Btn, { BackgroundColor3 = Theme.Accent }) end)
                    callback()
                end)
            end

            -- =============================================
            --  TOGGLE
            -- =============================================
            function Section:AddToggle(text, default, callback)
                default = default or false
                callback = callback or function() end
                local state = default

                local Row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent          = ElementList,
                })

                Create("TextLabel", {
                    Text            = text,
                    Size            = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = Row,
                })

                local ToggleBack = Create("Frame", {
                    Size            = UDim2.new(0, 36, 0, 18),
                    Position        = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF,
                    BorderSizePixel = 0,
                    Parent          = Row,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleBack })

                local ToggleKnob = Create("Frame", {
                    Size            = UDim2.new(0, 12, 0, 12),
                    Position        = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Parent          = ToggleBack,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleKnob })

                local Btn = Create("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, Parent = Row,
                })

                local function UpdateToggle()
                    Tween(ToggleBack, { BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF })
                    Tween(ToggleKnob, { Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) })
                end

                Btn.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateToggle()
                    callback(state)
                end)

                -- Return toggle object so user can set it externally
                local Toggle = {}
                function Toggle:Set(val)
                    state = val
                    UpdateToggle()
                    callback(state)
                end
                function Toggle:Get() return state end
                return Toggle
            end

            -- =============================================
            --  SLIDER
            -- =============================================
            function Section:AddSlider(text, min, max, default, callback)
                min = min or 0; max = max or 100; default = default or min
                callback = callback or function() end
                local value = default

                local Container = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 46),
                    BackgroundTransparency = 1,
                    Parent          = ElementList,
                })

                local Label = Create("TextLabel", {
                    Text            = text .. ": " .. tostring(value),
                    Size            = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = Container,
                })

                local SliderBack = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 8),
                    Position        = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Theme.SliderBack,
                    BorderSizePixel = 0,
                    Parent          = Container,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBack })

                local fill = math.clamp((default - min) / (max - min), 0, 1)
                local SliderFill = Create("Frame", {
                    Size            = UDim2.new(fill, 0, 1, 0),
                    BackgroundColor3 = Theme.Slider,
                    BorderSizePixel = 0,
                    Parent          = SliderBack,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFill })

                -- Drag logic
                local dragging = false
                local InputFrame = Create("TextButton", {
                    Text = "", Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundTransparency = 1, Parent = Container,
                })

                local function UpdateSlider(input)
                    local pos = SliderBack.AbsolutePosition.X
                    local size = SliderBack.AbsoluteSize.X
                    local rel = math.clamp((input.Position.X - pos) / size, 0, 1)
                    value = math.floor(min + (max - min) * rel)
                    SliderFill.Size = UDim2.new(rel, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    callback(value)
                end

                InputFrame.InputBegan:Connect(function(input)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)

                local Slider = {}
                function Slider:Set(val)
                    value = math.clamp(val, min, max)
                    local rel = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(rel, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    callback(value)
                end
                function Slider:Get() return value end
                return Slider
            end

            -- =============================================
            --  DROPDOWN
            -- =============================================
            function Section:AddDropdown(text, options, default, callback)
                callback = callback or function() end
                local selected = default or options[1] or "None"
                local open = false

                local Container = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent          = ElementList,
                })

                Create("TextLabel", {
                    Text            = text,
                    Size            = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = Container,
                })

                local DropBtn = Create("TextButton", {
                    Text            = selected .. "  ▼",
                    Size            = UDim2.new(1, 0, 0, 28),
                    Position        = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Theme.Dropdown,
                    BorderSizePixel = 0,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 12,
                    TextColor3      = Theme.Text,
                    ZIndex          = 5,
                    Parent          = Container,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropBtn })
                Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = DropBtn })

                local OptionFrame = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    Position        = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Theme.Dropdown,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex          = 10,
                    Visible         = false,
                    Parent          = DropBtn,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptionFrame })
                Create("UIStroke", { Color = Theme.Accent, Thickness = 1, Parent = OptionFrame })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionFrame })

                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Text            = opt,
                        Size            = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.Dropdown,
                        BorderSizePixel = 0,
                        Font            = Enum.Font.Gotham,
                        TextSize        = 12,
                        TextColor3      = Theme.Text,
                        ZIndex          = 11,
                        Parent          = OptionFrame,
                    })
                    OptBtn.MouseEnter:Connect(function() Tween(OptBtn, { BackgroundColor3 = Theme.AccentDark }) end)
                    OptBtn.MouseLeave:Connect(function() Tween(OptBtn, { BackgroundColor3 = Theme.Dropdown }) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        DropBtn.Text = selected .. "  ▼"
                        open = false
                        OptionFrame.Visible = false
                        Container.Size = UDim2.new(1, 0, 0, 52)
                        callback(selected)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    OptionFrame.Visible = open
                    if open then
                        OptionFrame.Size = UDim2.new(1, 0, 0, #options * 26)
                        Container.Size = UDim2.new(1, 0, 0, 52 + #options * 26 + 4)
                    else
                        Container.Size = UDim2.new(1, 0, 0, 52)
                    end
                end)

                local Dropdown = {}
                function Dropdown:Set(val)
                    selected = val
                    DropBtn.Text = selected .. "  ▼"
                    callback(selected)
                end
                function Dropdown:Get() return selected end
                return Dropdown
            end

            -- =============================================
            --  TEXTBOX
            -- =============================================
            function Section:AddTextBox(placeholder, callback)
                callback = callback or function() end

                local Box = Create("TextBox", {
                    PlaceholderText = placeholder,
                    Text            = "",
                    Size            = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    PlaceholderColor3 = Theme.TextDim,
                    ClearTextOnFocus = false,
                    Parent          = ElementList,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })
                Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Box })
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = Box })

                Box.Focused:Connect(function() Tween(Box, { BackgroundColor3 = Theme.ElementHover }) end)
                Box.FocusLost:Connect(function(enter)
                    Tween(Box, { BackgroundColor3 = Theme.Element })
                    callback(Box.Text, enter)
                end)

                local TextBox = {}
                function TextBox:Set(val) Box.Text = val end
                function TextBox:Get() return Box.Text end
                return TextBox
            end

            -- =============================================
            --  KEYBIND
            -- =============================================
            function Section:AddKeybind(text, default, callback)
                default = default or Enum.KeyCode.Unknown
                callback = callback or function() end
                local bound = default
                local listening = false

                local Row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = ElementList,
                })
                Create("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, -80, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, TextSize = 13,
                    TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })

                local KeyBtn = Create("TextButton", {
                    Text = "[" .. bound.Name .. "]",
                    Size = UDim2.new(0, 74, 0, 24),
                    Position = UDim2.new(1, -74, 0.5, -12),
                    BackgroundColor3 = Theme.Element, BorderSizePixel = 0,
                    Font = Enum.Font.Gotham, TextSize = 11,
                    TextColor3 = Theme.Text, Parent = Row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeyBtn })

                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "[...]"
                    KeyBtn.TextColor3 = Theme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        bound = input.KeyCode
                        KeyBtn.Text = "[" .. bound.Name .. "]"
                        KeyBtn.TextColor3 = Theme.Text
                    elseif not processed and input.KeyCode == bound and not listening then
                        callback(bound)
                    end
                end)

                local Keybind = {}
                function Keybind:Get() return bound end
                return Keybind
            end

            return Section
        end

        return Tab
    end

    return Window
end

return NovaLib

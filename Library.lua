-- ============================================================
--  NovaLib UI Library v2.0
--  Style: Dark rectangular (uwuware / xsx / bitchbot inspired)
--  Sharp edges · dense layout · Code font · animated
-- ============================================================

local NovaLib = {}
NovaLib.__index = NovaLib

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ── Theme ────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10,  10,  12),
    BG2         = Color3.fromRGB(16,  16,  20),
    BG3         = Color3.fromRGB(22,  22,  28),
    BG4         = Color3.fromRGB(30,  30,  38),
    TopBar      = Color3.fromRGB(8,   8,   10),
    Accent      = Color3.fromRGB(140, 80, 255),
    AccentDim   = Color3.fromRGB(80,  45, 160),
    AccentLine  = Color3.fromRGB(100, 55, 200),
    Text        = Color3.fromRGB(210, 210, 220),
    TextDim     = Color3.fromRGB(100, 100, 115),
    TextAccent  = Color3.fromRGB(160, 110, 255),
    Border      = Color3.fromRGB(38,  38,  50),
    BorderBright= Color3.fromRGB(60,  60,  80),
    Slider      = Color3.fromRGB(120, 65, 230),
    SliderBack  = Color3.fromRGB(20,  20,  28),
    ToggleON    = Color3.fromRGB(120, 65, 230),
    ToggleOFF   = Color3.fromRGB(25,  25,  35),
    Red         = Color3.fromRGB(200, 50,  50),
}

-- ── Utilities ────────────────────────────────────────────────
local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj, props, t)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Stroke(parent, color, thick)
    return New("UIStroke", { Parent = parent, Color = color or T.Border, Thickness = thick or 1 })
end

local function Pad(parent, top, right, bottom, left)
    return New("UIPadding", {
        Parent = parent,
        PaddingTop    = UDim.new(0, top    or 0),
        PaddingRight  = UDim.new(0, right  or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left   or 0),
    })
end

local function List(parent, gap)
    return New("UIListLayout", {
        Parent = parent,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or 0),
    })
end

local function MakeDraggable(win, handle)
    local drag, start, origin
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; origin = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            win.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

local function SlideIn(frame, origPos)
    local startY = origPos.Y.Offset - 20
    frame.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset, origPos.Y.Scale, startY)
    frame.BackgroundTransparency = 1
    Tween(frame, {
        BackgroundTransparency = 0,
        Position = origPos,
    }, 0.20)
end

local function SlideOut(frame, origPos, cb)
    Tween(frame, {
        BackgroundTransparency = 1,
        Position = UDim2.new(origPos.X.Scale, origPos.X.Offset, origPos.Y.Scale, origPos.Y.Offset - 16),
    }, 0.16)
    task.delay(0.17, function()
        frame.Visible = false
        frame.BackgroundTransparency = 0
        frame.Position = origPos
        if cb then cb() end
    end)
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function NovaLib:CreateWindow(cfg)
    cfg = cfg or {}
    local title    = cfg.Title     or "NovaLib"
    local subtitle = cfg.Subtitle  or ""
    local key      = cfg.ToggleKey or Enum.KeyCode.RightShift
    local W        = cfg.Width     or 560
    local H        = cfg.Height    or 380

    local Win = { Tabs = {}, _activeTab = nil }

    local Gui = New("ScreenGui", {
        Name = "NovaLib_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = (pcall(function() return gethui() end) and gethui()) or game:GetService("CoreGui"),
    })

    local origPos = UDim2.new(0.5, -W/2, 0.5, -H/2)

    -- ── Main frame (zero corner radius = sharp/rectangular) ──
    local Main = New("Frame", {
        Name = "Main",
        Size = UDim2.new(0, W, 0, H),
        Position = origPos,
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Gui,
    })
    Stroke(Main, T.AccentLine, 1)

    -- 1px accent top strip
    New("Frame", {
        Size = UDim2.new(1,0,0,1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = Main,
    })

    -- ── Top bar ──────────────────────────────────────────────
    local TopBar = New("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1,0,0,30),
        Position = UDim2.new(0,0,0,1),
        BackgroundColor3 = T.TopBar,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = Main,
    })
    New("Frame", {  -- bottom border
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 6, Parent = TopBar,
    })

    -- Title label
    New("TextLabel", {
        Text = title,
        Size = UDim2.new(0,150,1,0), Position = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code, TextSize = 13,
        TextColor3 = T.TextAccent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6, Parent = TopBar,
    })
    if subtitle ~= "" then
        New("TextLabel", {
            Text = subtitle,
            Size = UDim2.new(0,200,1,0), Position = UDim2.new(0,164,0,0),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 11,
            TextColor3 = T.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6, Parent = TopBar,
        })
    end

    -- ── Close button ─────────────────────────────────────────
    local CloseBtn = New("TextButton", {
        Text = "✕",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundColor3 = T.TopBar,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = T.TextDim,
        ZIndex = 7,
        Parent = TopBar,
    })
    New("Frame", {  -- left border line on close btn
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0, ZIndex = 7, Parent = CloseBtn,
    })
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = T.Red, TextColor3 = Color3.fromRGB(255,255,255) }, 0.1)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = T.TopBar, TextColor3 = T.TextDim }, 0.1)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        SlideOut(Main, origPos)
    end)

    -- ── Sidebar ───────────────────────────────────────────────
    local Sidebar = New("Frame", {
        Size = UDim2.new(0, 108, 1, -31),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
        Parent = Main,
    })
    New("Frame", {  -- right border
        Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = Sidebar,
    })
    local SidebarList = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Parent = Sidebar,
    })
    List(SidebarList, 0)

    -- ── Content area ──────────────────────────────────────────
    local ContentArea = New("Frame", {
        Size = UDim2.new(1,-109,1,-31),
        Position = UDim2.new(0,109,0,31),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    MakeDraggable(Main, TopBar)
    SlideIn(Main, origPos)

    UserInputService.InputBegan:Connect(function(i, p)
        if not p and i.KeyCode == key then
            if Main.Visible then
                SlideOut(Main, origPos)
            else
                Main.Visible = true
                SlideIn(Main, origPos)
            end
        end
    end)

    -- ============================================================
    --  ADD TAB
    -- ============================================================
    function Win:AddTab(name)
        local Tab = {}

        local TBtn = New("TextButton", {
            Text = name,
            Size = UDim2.new(1,-1,0,28),
            BackgroundColor3 = T.BG2,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = T.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            Parent = SidebarList,
        })
        Pad(TBtn, 0,0,0,12)
        New("Frame", {  -- bottom border
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 3, Parent = TBtn,
        })
        -- Active indicator (2px left bar)
        local Bar = New("Frame", {
            Size = UDim2.new(0,2,1,0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 4, Parent = TBtn,
        })

        -- Scroll frame for this tab's content
        local TFrame = New("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea,
        })
        List(TFrame, 4)
        Pad(TFrame, 5,5,5,5)

        Tab.Frame = TFrame; Tab.Button = TBtn; Tab._bar = Bar

        -- Auto-select first tab
        if #Win.Tabs == 0 then
            TFrame.Visible = true
            TBtn.BackgroundColor3 = T.BG3
            TBtn.TextColor3 = T.TextAccent
            Bar.BackgroundTransparency = 0
            Win._activeTab = Tab
        end

        TBtn.MouseButton1Click:Connect(function()
            if Win._activeTab == Tab then return end
            for _, t in pairs(Win.Tabs) do
                t.Frame.Visible = false
                Tween(t.Button, { BackgroundColor3 = T.BG2, TextColor3 = T.TextDim })
                t._bar.BackgroundTransparency = 1
            end
            TFrame.Visible = true
            Tween(TBtn, { BackgroundColor3 = T.BG3, TextColor3 = T.TextAccent })
            Bar.BackgroundTransparency = 0
            Win._activeTab = Tab
        end)
        TBtn.MouseEnter:Connect(function()
            if Win._activeTab ~= Tab then Tween(TBtn, { BackgroundColor3 = T.BG4 }) end
        end)
        TBtn.MouseLeave:Connect(function()
            if Win._activeTab ~= Tab then Tween(TBtn, { BackgroundColor3 = T.BG2 }) end
        end)

        table.insert(Win.Tabs, Tab)

        -- ============================================================
        --  ADD SECTION
        -- ============================================================
        function Tab:AddSection(secName)
            local Sec = {}

            local SFrame = New("Frame", {
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                Parent = TFrame,
            })
            Stroke(SFrame, T.Border)

            -- Header
            local Header = New("Frame", {
                Size = UDim2.new(1,0,0,22),
                BackgroundColor3 = T.BG,
                BorderSizePixel = 0,
                Parent = SFrame,
            })
            New("Frame", {  -- accent left stripe
                Size = UDim2.new(0,2,1,0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0, Parent = Header,
            })
            New("TextLabel", {
                Text = secName:upper(),
                Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,10,0,0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code, TextSize = 10,
                TextColor3 = T.TextAccent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header,
            })
            New("Frame", {  -- header bottom border
                Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
                BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = Header,
            })

            -- Elements container
            local EList = New("Frame", {
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0,0,0,22),
                BackgroundTransparency = 1,
                Parent = SFrame,
            })
            List(EList, 1)
            Pad(EList, 3, 5, 5, 5)
            Sec.Frame = EList

            -- ────────────────────────────────────────────────────────
            --  LABEL
            -- ────────────────────────────────────────────────────────
            function Sec:AddLabel(txt)
                New("TextLabel", {
                    Text = txt,
                    Size = UDim2.new(1,0,0,20),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = T.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = EList,
                })
            end

            -- ────────────────────────────────────────────────────────
            --  SEPARATOR
            -- ────────────────────────────────────────────────────────
            function Sec:AddSeparator()
                New("Frame", {
                    Size = UDim2.new(1,0,0,1),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0,
                    Parent = EList,
                })
            end

            -- ────────────────────────────────────────────────────────
            --  BUTTON
            -- ────────────────────────────────────────────────────────
            function Sec:AddButton(txt, cb)
                cb = cb or function() end
                local Btn = New("TextButton", {
                    Text = txt,
                    Size = UDim2.new(1,0,0,26),
                    BackgroundColor3 = T.BG3,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Code, TextSize = 12,
                    TextColor3 = T.TextDim,
                    Parent = EList,
                })
                local s = Stroke(Btn, T.Border)
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.BG4, TextColor3 = T.TextAccent })
                    Tween(s, { Color = T.AccentLine })
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.BG3, TextColor3 = T.TextDim })
                    Tween(s, { Color = T.Border })
                end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.AccentDim }, 0.05)
                    task.delay(0.06, function() Tween(Btn, { BackgroundColor3 = T.BG4 }, 0.1) end)
                    cb()
                end)
            end

            -- ────────────────────────────────────────────────────────
            --  TOGGLE
            -- ────────────────────────────────────────────────────────
            function Sec:AddToggle(txt, default, cb)
                default = default or false
                cb = cb or function() end
                local state = default

                local Row = New("Frame", {
                    Size = UDim2.new(1,0,0,26),
                    BackgroundColor3 = T.BG3,
                    BorderSizePixel = 0,
                    Parent = EList,
                })
                local s = Stroke(Row, T.Border)

                local TLabel = New("TextLabel", {
                    Text = txt,
                    Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,8,0,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 12,
                    TextColor3 = state and T.Text or T.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })

                -- Rectangular toggle box
                local TBack = New("Frame", {
                    Size = UDim2.new(0,32,0,13),
                    Position = UDim2.new(1,-38,0.5,-6),
                    BackgroundColor3 = state and T.ToggleON or T.ToggleOFF,
                    BorderSizePixel = 0, Parent = Row,
                })
                local ts = Stroke(TBack, state and T.Accent or T.Border)
                local Knob = New("Frame", {
                    Size = UDim2.new(0,9,0,9),
                    Position = state and UDim2.new(1,-12,0.5,-4) or UDim2.new(0,3,0.5,-4),
                    BackgroundColor3 = state and T.TextAccent or T.TextDim,
                    BorderSizePixel = 0, Parent = TBack,
                })
                local StatusLbl = New("TextLabel", {
                    Text = state and "ON" or "OFF",
                    Size = UDim2.new(0,28,0,13), Position = UDim2.new(1,-68,0.5,-6),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 9,
                    TextColor3 = state and T.Accent or T.TextDim,
                    Parent = Row,
                })

                local HB = New("TextButton", {
                    Text = "", Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, ZIndex = 3, Parent = Row,
                })

                local function Refresh()
                    Tween(TBack, { BackgroundColor3 = state and T.ToggleON or T.ToggleOFF })
                    Tween(Knob, {
                        Position = state and UDim2.new(1,-12,0.5,-4) or UDim2.new(0,3,0.5,-4),
                        BackgroundColor3 = state and T.TextAccent or T.TextDim
                    })
                    Tween(TLabel, { TextColor3 = state and T.Text or T.TextDim })
                    Tween(StatusLbl, { TextColor3 = state and T.Accent or T.TextDim })
                    StatusLbl.Text = state and "ON" or "OFF"
                    Tween(ts, { Color = state and T.Accent or T.Border })
                end

                HB.MouseButton1Click:Connect(function()
                    state = not state; Refresh(); cb(state)
                end)
                HB.MouseEnter:Connect(function()
                    Tween(Row, { BackgroundColor3 = T.BG4 })
                    Tween(s, { Color = T.BorderBright })
                end)
                HB.MouseLeave:Connect(function()
                    Tween(Row, { BackgroundColor3 = T.BG3 })
                    Tween(s, { Color = T.Border })
                end)

                local Obj = {}
                function Obj:Set(v) state = v; Refresh(); cb(state) end
                function Obj:Get() return state end
                return Obj
            end

            -- ────────────────────────────────────────────────────────
            --  SLIDER
            -- ────────────────────────────────────────────────────────
            function Sec:AddSlider(txt, min, max, default, cb)
                min = min or 0; max = max or 100
                default = math.clamp(default or min, min, max)
                cb = cb or function() end
                local val = default

                local Container = New("Frame", {
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = T.BG3,
                    BorderSizePixel = 0,
                    Parent = EList,
                })
                local s = Stroke(Container, T.Border)
                Pad(Container, 5,8,5,8)

                local TopRow = New("Frame", {
                    Size = UDim2.new(1,0,0,14),
                    BackgroundTransparency = 1, Parent = Container,
                })
                New("TextLabel", {
                    Text = txt, Size = UDim2.new(1,-44,1,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TopRow,
                })
                local ValLbl = New("TextLabel", {
                    Text = tostring(val),
                    Size = UDim2.new(0,40,1,0), Position = UDim2.new(1,-40,0,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = T.TextAccent, TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = TopRow,
                })

                local Track = New("Frame", {
                    Size = UDim2.new(1,0,0,5), Position = UDim2.new(0,0,0,22),
                    BackgroundColor3 = T.SliderBack, BorderSizePixel = 0, Parent = Container,
                })
                Stroke(Track, T.Border)

                local pct = (val - min) / (max - min)
                local Fill = New("Frame", {
                    Size = UDim2.new(pct,0,1,0),
                    BackgroundColor3 = T.Slider, BorderSizePixel = 0, Parent = Track,
                })
                local Nub = New("Frame", {
                    Size = UDim2.new(0,3,0,13),
                    Position = UDim2.new(pct,-1,0.5,-6),
                    BackgroundColor3 = T.TextAccent, BorderSizePixel = 0, ZIndex = 2, Parent = Track,
                })

                local drag = false
                local function Calc(input)
                    local rx = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * rx)
                    Fill.Size = UDim2.new(rx,0,1,0)
                    Nub.Position = UDim2.new(rx,-1,0.5,-6)
                    ValLbl.Text = tostring(val)
                    cb(val)
                end

                local HB = New("TextButton", {
                    Text = "", Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,16),
                    BackgroundTransparency = 1, ZIndex = 5, Parent = Container,
                })
                HB.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; Calc(i) end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then Calc(i) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
                end)

                Container.MouseEnter:Connect(function()
                    Tween(Container, { BackgroundColor3 = T.BG4 })
                    Tween(s, { Color = T.BorderBright })
                end)
                Container.MouseLeave:Connect(function()
                    Tween(Container, { BackgroundColor3 = T.BG3 })
                    Tween(s, { Color = T.Border })
                end)

                local Obj = {}
                function Obj:Set(v)
                    val = math.clamp(v, min, max)
                    local rx = (val - min)/(max - min)
                    Fill.Size = UDim2.new(rx,0,1,0)
                    Nub.Position = UDim2.new(rx,-1,0.5,-6)
                    ValLbl.Text = tostring(val)
                    cb(val)
                end
                function Obj:Get() return val end
                return Obj
            end

            -- ────────────────────────────────────────────────────────
            --  DROPDOWN
            -- ────────────────────────────────────────────────────────
            function Sec:AddDropdown(txt, opts, default, cb)
                cb = cb or function() end
                local sel = default or opts[1] or "none"
                local open = false
                local OPT_H = 22

                local Wrap = New("Frame", {
                    Size = UDim2.new(1,0,0,42),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 5, Parent = EList,
                })
                New("TextLabel", {
                    Text = txt,
                    Size = UDim2.new(1,0,0,16),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = T.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Wrap,
                })

                local DBtn = New("TextButton", {
                    Text = "",
                    Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,0,18),
                    BackgroundColor3 = T.BG3, BorderSizePixel = 0,
                    ZIndex = 6, Parent = Wrap,
                })
                local ds = Stroke(DBtn, T.Border)

                local SelLbl = New("TextLabel", {
                    Text = sel, Size = UDim2.new(1,-26,1,0), Position = UDim2.new(0,8,0,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7, Parent = DBtn,
                })
                local ArrowLbl = New("TextLabel", {
                    Text = "▾", Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-22,0,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 10,
                    TextColor3 = T.TextAccent,
                    ZIndex = 7, Parent = DBtn,
                })

                local OptFrame = New("Frame", {
                    Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,1,0),
                    BackgroundColor3 = T.BG, BorderSizePixel = 0,
                    ClipsDescendants = true, ZIndex = 10, Visible = false, Parent = DBtn,
                })
                Stroke(OptFrame, T.AccentLine)
                List(OptFrame, 0)

                for _, o in ipairs(opts) do
                    local OBtn = New("TextButton", {
                        Text = o, Size = UDim2.new(1,0,0,OPT_H),
                        BackgroundColor3 = T.BG, BorderSizePixel = 0,
                        Font = Enum.Font.Code, TextSize = 12,
                        TextColor3 = T.TextDim,
                        ZIndex = 11, Parent = OptFrame,
                    })
                    Pad(OBtn,0,0,0,8)
                    New("Frame", {
                        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
                        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 11, Parent = OBtn,
                    })
                    OBtn.MouseEnter:Connect(function()
                        Tween(OBtn, { BackgroundColor3 = T.BG3, TextColor3 = T.TextAccent })
                    end)
                    OBtn.MouseLeave:Connect(function()
                        Tween(OBtn, { BackgroundColor3 = T.BG, TextColor3 = T.TextDim })
                    end)
                    OBtn.MouseButton1Click:Connect(function()
                        sel = o; SelLbl.Text = o
                        open = false
                        Tween(OptFrame, { Size = UDim2.new(1,0,0,0) }, 0.1)
                        task.delay(0.11, function() OptFrame.Visible = false end)
                        Tween(ArrowLbl, { Rotation = 0 })
                        Wrap.Size = UDim2.new(1,0,0,42)
                        cb(sel)
                    end)
                end

                DBtn.MouseEnter:Connect(function()
                    Tween(DBtn, { BackgroundColor3 = T.BG4 })
                    Tween(ds, { Color = T.BorderBright })
                end)
                DBtn.MouseLeave:Connect(function()
                    Tween(DBtn, { BackgroundColor3 = T.BG3 })
                    Tween(ds, { Color = T.Border })
                end)
                DBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        OptFrame.Visible = true
                        OptFrame.Size = UDim2.new(1,0,0,0)
                        Tween(OptFrame, { Size = UDim2.new(1,0,0,#opts*OPT_H) }, 0.14)
                        Tween(ArrowLbl, { Rotation = 180 }, 0.14)
                        Wrap.Size = UDim2.new(1,0,0,42 + #opts*OPT_H)
                    else
                        Tween(OptFrame, { Size = UDim2.new(1,0,0,0) }, 0.1)
                        task.delay(0.11, function() OptFrame.Visible = false end)
                        Tween(ArrowLbl, { Rotation = 0 }, 0.1)
                        Wrap.Size = UDim2.new(1,0,0,42)
                    end
                end)

                local Obj = {}
                function Obj:Set(v) sel = v; SelLbl.Text = v; cb(sel) end
                function Obj:Get() return sel end
                return Obj
            end

            -- ────────────────────────────────────────────────────────
            --  TEXTBOX
            -- ────────────────────────────────────────────────────────
            function Sec:AddTextBox(placeholder, cb)
                cb = cb or function() end
                local Box = New("TextBox", {
                    PlaceholderText = "> " .. placeholder,
                    Text = "",
                    Size = UDim2.new(1,0,0,26),
                    BackgroundColor3 = T.BG3, BorderSizePixel = 0,
                    Font = Enum.Font.Code, TextSize = 12,
                    TextColor3 = T.Text, PlaceholderColor3 = T.TextDim,
                    ClearTextOnFocus = false, Parent = EList,
                })
                local s = Stroke(Box, T.Border)
                Pad(Box, 0,6,0,8)
                Box.Focused:Connect(function()
                    Tween(Box, { BackgroundColor3 = T.BG4 })
                    Tween(s, { Color = T.AccentLine })
                end)
                Box.FocusLost:Connect(function(enter)
                    Tween(Box, { BackgroundColor3 = T.BG3 })
                    Tween(s, { Color = T.Border })
                    cb(Box.Text, enter)
                end)
                local Obj = {}
                function Obj:Set(v) Box.Text = v end
                function Obj:Get() return Box.Text end
                return Obj
            end

            -- ────────────────────────────────────────────────────────
            --  KEYBIND
            -- ────────────────────────────────────────────────────────
            function Sec:AddKeybind(txt, default, cb)
                default = default or Enum.KeyCode.Unknown
                cb = cb or function() end
                local bound = default
                local listening = false

                local Row = New("Frame", {
                    Size = UDim2.new(1,0,0,26),
                    BackgroundColor3 = T.BG3, BorderSizePixel = 0, Parent = EList,
                })
                local s = Stroke(Row, T.Border)
                New("TextLabel", {
                    Text = txt, Size = UDim2.new(1,-90,1,0), Position = UDim2.new(0,8,0,0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })
                local KBtn = New("TextButton", {
                    Text = "[" .. bound.Name .. "]",
                    Size = UDim2.new(0,80,0,18), Position = UDim2.new(1,-84,0.5,-9),
                    BackgroundColor3 = T.BG, BorderSizePixel = 0,
                    Font = Enum.Font.Code, TextSize = 10,
                    TextColor3 = T.TextAccent, Parent = Row,
                })
                Stroke(KBtn, T.Border)

                KBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KBtn.Text = "[ ... ]"
                    Tween(KBtn, { TextColor3 = T.Accent })
                end)
                UserInputService.InputBegan:Connect(function(i, p)
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        bound = i.KeyCode
                        KBtn.Text = "[" .. bound.Name .. "]"
                        Tween(KBtn, { TextColor3 = T.TextAccent })
                    elseif not p and not listening and i.KeyCode == bound then
                        cb(bound)
                    end
                end)
                Row.MouseEnter:Connect(function()
                    Tween(Row, { BackgroundColor3 = T.BG4 })
                    Tween(s, { Color = T.BorderBright })
                end)
                Row.MouseLeave:Connect(function()
                    Tween(Row, { BackgroundColor3 = T.BG3 })
                    Tween(s, { Color = T.Border })
                end)

                local Obj = {}
                function Obj:Get() return bound end
                return Obj
            end

            return Sec
        end -- AddSection

        return Tab
    end -- AddTab

    return Win
end -- CreateWindow

return NovaLib

-- TAME ANIMAL HUB ULTRA V2.0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Input = game:GetService("UserInputService")
local Tags = game:GetService("CollectionService")
local Storage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Config = {
    AutoFarm = false,
    AutoAttack = false,
    AutoTame = false,
    AutoBoss = false,
    AutoDungeon = false,
    AutoCollect = false,
    AutoRewards = false,
    AutoQuest = false,
    AutoUpgrade = false,
    ESP = false,
    Fly = false,
    Speed = 16,
    Jump = 50,
    FlySpeed = 60,
    Distance = 100,
    Interval = 1
}

local Alive = true
local Connections = {}
local Highlights = {}
local FlightVelocity
local FlightAttachment

local OldGui = PlayerGui:FindFirstChild("TameAnimalUltra")

if OldGui then
    OldGui:Destroy()
end

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function Character()
    return Player.Character
end

local function Root(model)
    return model and (
        model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
    )
end

local function Position(object)
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        return object:GetPivot().Position
    end
end

local function Nearest(tag)
    local root = Root(Character())
    if not root then return end

    local closest
    local distance = Config.Distance

    for _, object in ipairs(Tags:GetTagged(tag)) do
        local pos = Position(object)

        if pos and object:IsDescendantOf(workspace) then
            local d = (pos - root.Position).Magnitude

            if d < distance then
                closest = object
                distance = d
            end
        end
    end

    return closest
end

-- Interface com o servidor do projeto

local function Action(name, target)
    local folder = Storage:FindFirstChild(
        "TameAnimalActions"
    )

    local remote = folder and folder:FindFirstChild(name)

    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(target)
        return true
    end

    return false
end

-- Interface principal

local Gui = Instance.new("ScreenGui")
Gui.Name = "TameAnimalUltra"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.fromOffset(440, 460)
Frame.Position = UDim2.new(0.5, -220, 0.5, -230)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius =
    UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(200, 0, 0)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -85, 0, 45)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "TAME ANIMAL | ULTRA V2"
Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold

local function Button(parent, text)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, 0, 0, 34)
    B.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    B.TextColor3 = Color3.new(1, 1, 1)
    B.Text = text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13

    Instance.new("UICorner", B).CornerRadius =
        UDim.new(0, 6)

    return B
end

local Close = Button(Frame, "X")
Close.Size = UDim2.fromOffset(32, 30)
Close.Position = UDim2.new(1, -38, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(180, 0, 0)

local Minimize = Button(Frame, "-")
Minimize.Size = UDim2.fromOffset(32, 30)
Minimize.Position = UDim2.new(1, -76, 0, 7)

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -16, 0, 35)
TabBar.Position = UDim2.fromOffset(8, 48)
TabBar.BackgroundTransparency = 1

local Pages = {}
local Tabs = {"Farm", "ESP", "Movement", "Settings"}

for i, name in ipairs(Tabs) do
    local Tab = Button(TabBar, name)
    Tab.Size = UDim2.new(0.25, -4, 1, 0)
    Tab.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)

    local Page = Instance.new("ScrollingFrame", Frame)
    Page.Size = UDim2.new(1, -20, 1, -125)
    Page.Position = UDim2.fromOffset(10, 88)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(220, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new()
    Page.Visible = i == 1

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 5)

    Pages[name] = Page

    Connect(Tab.Activated, function()
        for pageName, page in pairs(Pages) do
            page.Visible = pageName == name
        end
    end)
end

local RefreshButtons = {}

local function Toggle(page, label, key)
    local B = Button(Pages[page], label)

    local function Refresh()
        B.Text = label .. (Config[key] and " [ON]" or " [OFF]")

        B.BackgroundColor3 = Config[key]
            and Color3.fromRGB(170, 0, 0)
            or Color3.fromRGB(35, 35, 35)
    end

    table.insert(RefreshButtons, Refresh)

    Connect(B.Activated, function()
        Config[key] = not Config[key]
        Refresh()
    end)

    Refresh()
end

local function NumberSetting(page, label, key, min, max)
    local Box = Instance.new("TextBox", Pages[page])
    Box.Size = UDim2.new(1, 0, 0, 38)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.TextColor3 = Color3.new(1, 1, 1)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.ClearTextOnFocus = false
    Box.Text = label .. ": " .. Config[key]

    Connect(Box.Focused, function()
        Box.Text = tostring(Config[key])
    end)

    Connect(Box.FocusLost, function()
        Config[key] = math.clamp(
            tonumber(Box.Text) or Config[key],
            min,
            max
        )

        Box.Text = label .. ": " .. Config[key]
    end)
end

-- FARM

Toggle("Farm", "Auto Farm", "AutoFarm")
Toggle("Farm", "Auto Attack", "AutoAttack")
Toggle("Farm", "Auto Tame", "AutoTame")
Toggle("Farm", "Auto Boss", "AutoBoss")
Toggle("Farm", "Auto Dungeon", "AutoDungeon")
Toggle("Farm", "Auto Collect", "AutoCollect")
Toggle("Farm", "Auto Rewards", "AutoRewards")
Toggle("Farm", "Auto Quest", "AutoQuest")
Toggle("Farm", "Auto Upgrade", "AutoUpgrade")

-- ESP

Toggle("ESP", "Animal / Boss ESP", "ESP")

local function ClearESP()
    for object, highlight in pairs(Highlights) do
        highlight:Destroy()
        Highlights[object] = nil
    end
end

local function UpdateESP()
    if not Config.ESP then
        ClearESP()
        return
    end

    for _, tag in ipairs({"Animal", "Boss"}) do
        for _, object in ipairs(Tags:GetTagged(tag)) do
            if not Highlights[object] then
                local H = Instance.new("Highlight")
                H.Adornee = object
                H.FillTransparency = 0.75
                H.OutlineColor = Color3.fromRGB(255, 0, 0)
                H.FillColor = Color3.fromRGB(255, 0, 0)
                H.Parent = Gui

                Highlights[object] = H
            end
        end
    end

    for object, highlight in pairs(Highlights) do
        if not object:IsDescendantOf(workspace) then
            highlight:Destroy()
            Highlights[object] = nil
        end
    end
end

-- MOVIMENTACAO

Toggle("Movement", "Fly", "Fly")

NumberSetting("Movement", "Velocidade", "Speed", 16, 200)
NumberSetting("Movement", "Pulo", "Jump", 50, 200)
NumberSetting("Movement", "Velocidade Fly", "FlySpeed", 10, 200)

local function StopFly()
    if FlightVelocity then
        FlightVelocity:Destroy()
        FlightVelocity = nil
    end

    if FlightAttachment then
        FlightAttachment:Destroy()
        FlightAttachment = nil
    end
end

local function UpdateFly()
    local root = Root(Character())

    if not Config.Fly or not root then
        StopFly()
        return
    end

    if FlightAttachment and FlightAttachment.Parent ~= root then
        StopFly()
    end

    if not FlightVelocity then
        FlightAttachment = Instance.new("Attachment", root)

        FlightVelocity = Instance.new("LinearVelocity", root)
        FlightVelocity.Attachment0 = FlightAttachment
        FlightVelocity.MaxForce = math.huge
        FlightVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    end

    local camera = workspace.CurrentCamera
    local direction = Vector3.zero

    if Input:IsKeyDown(Enum.KeyCode.W) then
        direction += camera.CFrame.LookVector
    end

    if Input:IsKeyDown(Enum.KeyCode.S) then
        direction -= camera.CFrame.LookVector
    end

    if Input:IsKeyDown(Enum.KeyCode.A) then
        direction -= camera.CFrame.RightVector
    end

    if Input:IsKeyDown(Enum.KeyCode.D) then
        direction += camera.CFrame.RightVector
    end

    if Input:IsKeyDown(Enum.KeyCode.Space) then
        direction += Vector3.yAxis
    end

    if Input:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction -= Vector3.yAxis
    end

    FlightVelocity.VectorVelocity =
        direction.Magnitude > 0
        and direction.Unit * Config.FlySpeed
        or Vector3.zero
end

for _, tag in ipairs({"Animal", "Boss", "Dungeon", "Spawn"}) do
    local B = Button(Pages.Movement, "Teleport: " .. tag)

    Connect(B.Activated, function()
        local target = Nearest(tag)
        local character = Character()

        if target and character then
            character:PivotTo(
                CFrame.new(Position(target) + Vector3.new(0, 5, 0))
            )
        end
    end)
end

-- CONFIGURACOES

NumberSetting("Settings", "Distancia", "Distance", 10, 1000)
NumberSetting("Settings", "Intervalo", "Interval", 0.5, 10)

local function DisableAll()
    for key, value in pairs(Config) do
        if type(value) == "boolean" then
            Config[key] = false
        end
    end

    StopFly()
    ClearESP()

    local character = Character()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    Config.Speed = 16
    Config.Jump = 50

    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end

    for _, refresh in ipairs(RefreshButtons) do
        refresh()
    end
end

local Disable = Button(Pages.Settings, "DESATIVAR TUDO")
Disable.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
Connect(Disable.Activated, DisableAll)

-- STATUS

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 1, -28)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12

local Minimized = false

Connect(Minimize.Activated, function()
    Minimized = not Minimized

    Frame.Size = Minimized
        and UDim2.fromOffset(440, 45)
        or UDim2.fromOffset(440, 460)

    Frame.ClipsDescendants = Minimized
end)

local function Shutdown()
    if not Alive then return end

    Alive = false
    DisableAll()

    for _, connection in ipairs(Connections) do
        connection:Disconnect()
    end
end

Connect(Close.Activated, function()
    Shutdown()
    Gui:Destroy()
end)

Connect(Gui.Destroying, Shutdown)

-- LOOP PRINCIPAL

local FPS = 60
local LastUpdate = 0

Connect(RunService.RenderStepped, function(dt)
    if not Alive then return end

    UpdateFly()

    FPS = FPS * 0.9 + (1 / math.max(dt, 0.001)) * 0.1

    if os.clock() - LastUpdate > 0.5 then
        LastUpdate = os.clock()

        local connected = Storage:FindFirstChild("TameAnimalActions")

        Status.Text = "FPS: " .. math.floor(FPS)
            .. (connected and " | API encontrada" or " | API ausente")
    end
end)

task.spawn(function()
    while Alive do
        local character = Character()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = Config.Speed
            humanoid.JumpPower = Config.Jump

            local animal = Nearest("Animal")
            local boss = Nearest("Boss")

            if Config.AutoFarm and animal then
                humanoid:MoveTo(Position(animal))
            end

            if Config.AutoAttack and animal then
                Action("Attack", animal)
            end

            if Config.AutoTame and animal then
                Action("Tame", animal)
            end

            if Config.AutoBoss and boss then
                humanoid:MoveTo(Position(boss))
                Action("BossAttack", boss)
            end

            if Config.AutoDungeon then
                Action("Dungeon", Nearest("Dungeon"))
            end

            if Config.AutoCollect then
                Action("Collect", Nearest("Item"))
            end

            if Config.AutoRewards then
                Action("Reward")
            end

            if Config.AutoQuest then
                Action("Quest", Nearest("Quest"))
            end

            if Config.AutoUpgrade then
                Action("Upgrade")
            end
        end

        UpdateESP()
        task.wait(Config.Interval)
    end
end)

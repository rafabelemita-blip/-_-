--[[
    TAME ANIMAL HUB — ULTRA V1.0
    Script educacional para testes autorizados
    Requer um executor compatível (Solara V3, Krnl, etc.)
]]

-- ============================================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================================
local Config = {
    Settings = {
        Speed = 16,
        JumpPower = 50,
        Distance = 50,
        Interval = 0.5,
        FOV = 90,
        Smoothness = 0.2,
        TargetPart = "Head",
        ESPDistance = 200,
        ESPColor = Color3.fromRGB(255, 0, 0),
        AutoFarm = false,
        AutoAttack = false,
        AutoTame = false,
        AutoBoss = false,
        AutoDungeon = false,
        AutoCollect = false,
        AutoQuest = false,
        AutoUpgrade = false,
        ESPEnabled = false,
        AimbotEnabled = false,
        FlyEnabled = false,
        PriorityLegendary = true,
    }
}

-- ============================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local Utility = {}

function Utility.GetCharacter(Player)
    return Player.Character or Player.CharacterAdded:Wait()
end

function Utility.GetRootPart(Character)
    return Character:WaitForChild("HumanoidRootPart")
end

function Utility.GetHumanoid(Character)
    return Character:WaitForChild("Humanoid")
end

function Utility.GetNearestTarget(MaxDistance)
    local Nearest = nil
    local NearestDistance = MaxDistance or math.huge
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local Distance = (RootPart.Position - Camera:GetPivot().Position).Magnitude
                    if Distance < NearestDistance then
                        Nearest = Player
                        NearestDistance = Distance
                    end
                end
            end
        end
    end
    
    return Nearest, NearestDistance
end

function Utility.GetClosestAnimal()
    local Nearest = nil
    local NearestDistance = Config.Settings.Distance
    
    for _, Descendant in ipairs(Workspace:GetDescendants()) do
        if Descendant:IsA("Model") and Descendant:FindFirstChild("Humanoid") then
            local RootPart = Descendant:FindFirstChild("HumanoidRootPart")
            if RootPart and Descendant.Name:lower():match("animal") or Descendant:FindFirstChild("Tame") then
                local Distance = (RootPart.Position - Camera:GetPivot().Position).Magnitude
                if Distance < NearestDistance then
                    Nearest = Descendant
                    NearestDistance = Distance
                end
            end
        end
    end
    
    return Nearest
end

function Utility.GetClosestBoss()
    local Nearest = nil
    local NearestDistance = Config.Settings.Distance * 2
    
    for _, Descendant in ipairs(Workspace:GetDescendants()) do
        if Descendant:IsA("Model") and Descendant.Name:lower():match("boss") then
            local RootPart = Descendant:FindFirstChild("HumanoidRootPart")
            if RootPart then
                local Distance = (RootPart.Position - Camera:GetPivot().Position).Magnitude
                if Distance < NearestDistance then
                    Nearest = Descendant
                    NearestDistance = Distance
                end
            end
        end
    end
    
    return Nearest
end

-- ============================================================
-- SISTEMA DE FARM
-- ============================================================
local FarmSystem = {}

function FarmSystem.AutoFarm()
    local Character = Utility.GetCharacter(LocalPlayer)
    local RootPart = Utility.GetRootPart(Character)
    
    local Target = Utility.GetClosestAnimal()
    if Target then
        local TargetRoot = Target:FindFirstChild("HumanoidRootPart")
        if TargetRoot then
            -- Teleporta para o animal
            RootPart.CFrame = TargetRoot.CFrame * CFrame.new(0, 0, 5)
            
            -- Tenta domar
            if Config.Settings.AutoTame then
                local TameRemote = Target:FindFirstChild("Tame")
                if TameRemote and TameRemote:IsA("RemoteEvent") then
                    TameRemote:FireServer()
                end
            end
            
            -- Ataca se necessário
            if Config.Settings.AutoAttack then
                local Humanoid = Utility.GetHumanoid(Target)
                if Humanoid then
                    Humanoid:TakeDamage(10)
                end
            end
        end
    end
end

function FarmSystem.AutoBoss()
    local Character = Utility.GetCharacter(LocalPlayer)
    local RootPart = Utility.GetRootPart(Character)
    
    local Boss = Utility.GetClosestBoss()
    if Boss then
        local BossRoot = Boss:FindFirstChild("HumanoidRootPart")
        if BossRoot then
            RootPart.CFrame = BossRoot.CFrame * CFrame.new(0, 0, 10)
            
            -- Ataca o boss
            local Humanoid = Utility.GetHumanoid(Boss)
            if Humanoid then
                Humanoid:TakeDamage(25)
            end
        end
    end
end

function FarmSystem.AutoCollectItems()
    for _, Item in ipairs(Workspace:GetDescendants()) do
        if Item:IsA("BasePart") and Item:FindFirstChild("Collect") or Item.Name:lower():match("item") then
            local Character = Utility.GetCharacter(LocalPlayer)
            local RootPart = Utility.GetRootPart(Character)
            
            if (Item.Position - RootPart.Position).Magnitude < Config.Settings.Distance then
                -- Coleta o item
                local CollectRemote = Item:FindFirstChild("Collect")
                if CollectRemote and CollectRemote:IsA("RemoteEvent") then
                    CollectRemote:FireServer()
                end
            end
        end
    end
end

function FarmSystem.AutoQuest()
    -- Procura por NPCs de quest
    for _, NPC in ipairs(Workspace:GetDescendants()) do
        if NPC:IsA("Model") and NPC.Name:lower():match("quest") or NPC:FindFirstChild("Quest") then
            local QuestRemote = NPC:FindFirstChild("Quest")
            if QuestRemote and QuestRemote:IsA("RemoteEvent") then
                QuestRemote:FireServer()
                task.wait(Config.Settings.Interval)
            end
        end
    end
end

function FarmSystem.AutoUpgrade()
    -- Procura por NPCs de upgrade
    for _, NPC in ipairs(Workspace:GetDescendants()) do
        if NPC:IsA("Model") and NPC.Name:lower():match("upgrade") or NPC:FindFirstChild("Upgrade") then
            local UpgradeRemote = NPC:FindFirstChild("Upgrade")
            if UpgradeRemote and UpgradeRemote:IsA("RemoteEvent") then
                UpgradeRemote:FireServer()
                task.wait(Config.Settings.Interval)
            end
        end
    end
end

-- ============================================================
-- SISTEMA DE ESP
-- ============================================================
local ESPSystem = {}
local ESPObjects = {}

function ESPSystem.CreateESP(Target, Color)
    if not Target:FindFirstChild("HumanoidRootPart") then return end
    
    local RootPart = Target.HumanoidRootPart
    
    -- Box ESP
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = Vector3.new(4, 6, 4)
    Box.Adornee = RootPart
    Box.AlwaysOnTop = true
    Box.ZIndex = 5
    Box.Color3 = Color or Config.Settings.ESPColor
    Box.Transparency = 0.5
    Box.Parent = RootPart
    
    -- Name ESP
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.Adornee = RootPart
    Billboard.AlwaysOnTop = true
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Target.Name
    NameLabel.TextColor3 = Color or Config.Settings.ESPColor
    NameLabel.TextStrokeTransparency = 0
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 14
    NameLabel.Parent = Billboard
    
    -- Health ESP
    local HealthLabel = Instance.new("TextLabel")
    HealthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    HealthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    HealthLabel.BackgroundTransparency = 1
    HealthLabel.Text = "HP: 100%"
    HealthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    HealthLabel.TextStrokeTransparency = 0
    HealthLabel.Font = Enum.Font.Gotham
    HealthLabel.TextSize = 12
    HealthLabel.Parent = Billboard
    
    Billboard.Parent = RootPart
    
    table.insert(ESPObjects, {
        Target = Target,
        Box = Box,
        Billboard = Billboard,
        HealthLabel = HealthLabel
    })
end

function ESPSystem.UpdateESP()
    for i, ESP in ipairs(ESPObjects) do
        if not ESP.Target.Parent then
            ESP.Box:Destroy()
            ESP.Billboard:Destroy()
            table.remove(ESPObjects, i)
        else
            local Humanoid = ESP.Target:FindFirstChild("Humanoid")
            if Humanoid then
                local HealthPercent = math.floor((Humanoid.Health / Humanoid.MaxHealth) * 100)
                ESP.HealthLabel.Text = "HP: " .. HealthPercent .. "%"
            end
        end
    end
end

function ESPSystem.ClearESP()
    for _, ESP in ipairs(ESPObjects) do
        if ESP.Box then ESP.Box:Destroy() end
        if ESP.Billboard then ESP.Billboard:Destroy() end
    end
    table.clear(ESPObjects)
end

-- ============================================================
-- SISTEMA DE COMBATE (AIMBOT)
-- ============================================================
local CombatSystem = {}

function CombatSystem.Aimbot()
    local Target, Distance = Utility.GetNearestTarget(Config.Settings.FOV)
    
    if Target and Target.Character then
        local TargetPart = Target.Character:FindFirstChild(Config.Settings.TargetPart) or Target.Character:FindFirstChild("Head")
        
        if TargetPart then
            -- Verifica obstáculos
            local Ray = Ray.new(Camera:GetPivot().Position, (TargetPart.Position - Camera:GetPivot().Position).Unit * 500)
            local Hit = Workspace:FindPartOnRay(Ray, LocalPlayer.Character)
            
            if Hit and Hit:IsDescendantOf(Target.Character) then
                -- Suavização da mira
                local CurrentLook = Camera.CFrame.LookVector
                local TargetLook = (TargetPart.Position - Camera:GetPivot().Position).Unit
                local SmoothLook = CurrentLook:Lerp(TargetLook, Config.Settings.Smoothness)
                
                Camera.CFrame = CFrame.new(Camera:GetPivot().Position, Camera:GetPivot().Position + SmoothLook)
            end
        end
    end
end

function CombatSystem.AutoAttack()
    local Target = Utility.GetNearestTarget(Config.Settings.Distance)
    
    if Target and Target.Character then
        local Humanoid = Target.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid:TakeDamage(5)
        end
    end
end

-- ============================================================
-- SISTEMA DE MOVIMENTAÇÃO
-- ============================================================
local MovementSystem = {}

function MovementSystem.TeleportTo(Position)
    local Character = Utility.GetCharacter(LocalPlayer)
    local RootPart = Utility.GetRootPart(Character)
    
    RootPart.CFrame = CFrame.new(Position)
end

function MovementSystem.TeleportToAnimal()
    local Animal = Utility.GetClosestAnimal()
    if Animal and Animal:FindFirstChild("HumanoidRootPart") then
        MovementSystem.TeleportTo(Animal.HumanoidRootPart.Position)
    end
end

function MovementSystem.TeleportToBoss()
    local Boss = Utility.GetClosestBoss()
    if Boss and Boss:FindFirstChild("HumanoidRootPart") then
        MovementSystem.TeleportTo(Boss.HumanoidRootPart.Position)
    end
end

function MovementSystem.TeleportToSpawn()
    local Spawn = Workspace:FindFirstChild("SpawnLocation")
    if Spawn then
        MovementSystem.TeleportTo(Spawn.Position)
    end
end

function MovementSystem.SetSpeed(Speed)
    local Character = Utility.GetCharacter(LocalPlayer)
    local Humanoid = Utility.GetHumanoid(Character)
    Humanoid.WalkSpeed = Speed
end

function MovementSystem.SetJumpPower(JumpPower)
    local Character = Utility.GetCharacter(LocalPlayer)
    local Humanoid = Utility.GetHumanoid(Character)
    Humanoid.JumpPower = JumpPower
end

-- Sistema de Fly
local FlySystem = {}
local Flying = false
local BodyVelocity = nil
local BodyGyro = nil

function FlySystem.ToggleFly()
    Flying = not Flying
    
    local Character = Utility.GetCharacter(LocalPlayer)
    local Humanoid = Utility.GetHumanoid(Character)
    local RootPart = Utility.GetRootPart(Character)
    
    if Flying then
        Humanoid.PlatformStand = true
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10000
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart
        
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10000
        BodyGyro.DFrame = 1000
        BodyGyro.Parent = RootPart
    else
        Humanoid.PlatformStand = false
        
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        
        if BodyGyro then
            BodyGyro:Destroy()
            BodyGyro = nil
        end
    end
end

-- ============================================================
-- INTERFACE GRÁFICA (UI)
-- ============================================================
local UISystem = {}

function UISystem.CreateUI()
    -- ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TameAnimalHub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "TAME ANIMAL HUB — ULTRA V1.0"
    Title.TextColor3 = Color3.fromRGB(255, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = TitleBar
    
    -- Botão minimizar
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 16
    MinimizeButton.Parent = TitleBar
    
    -- Botão fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = TitleBar
    
    -- Abas
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local Tabs = {"Farm", "ESP", "Combat", "Movement"}
    local TabButtons = {}
    
    for i, TabName in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0.25, 0, 1, 0)
        TabButton.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Parent = TabFrame
        TabButtons[TabName] = TabButton
    end
    
    -- Container do conteúdo
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -100)
    ContentFrame.Position = UDim2.new(0, 10, 0, 90)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    -- Função para criar botões toggle
    local function CreateToggle(Parent, Text, Variable, Position)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
        ToggleButton.Position = UDim2.new(0.1, 0, Position, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ToggleButton.Text = Text .. " [OFF]"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.TextSize = 14
        ToggleButton.Parent = Parent
        
        ToggleButton.MouseButton1Click:Connect(function()
            Config.Settings[Variable] = not Config.Settings[Variable]
            ToggleButton.Text = Text .. (Config.Settings[Variable] and " [ON]" or " [OFF]")
            ToggleButton.BackgroundColor3 = Config.Settings[Variable] and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)
        end)
        
        return ToggleButton
    end
    
    -- Função para criar sliders
    local function CreateSlider(Parent, Text, Variable, Min, Max, Position)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(0.8, 0, 0, 50)
        SliderFrame.Position = UDim2.new(0.1, 0, Position, 0)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SliderFrame.Parent = Parent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0.5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text .. ": " .. Config.Settings[Variable]
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.Parent = SliderFrame
        
        local Slider = Instance.new("TextButton")
        Slider.Size = UDim2.new(1, -20, 0, 15)
        Slider.Position = UDim2.new(0, 10, 0.5, 5)
        Slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Slider.Text = ""
        Slider.Parent = SliderFrame
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = Slider
        
        local dragging = false
        
        Slider.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end))
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local RelativePosition = input.Position.X - Slider.AbsolutePosition.X
                local Percentage = math.clamp(RelativePosition / Slider.AbsoluteSize.X, 0, 1)
                local Value = Min + ((Max - Min) * Percentage)
                Config.Settings[Variable] = math.floor(Value * 10) / 10
                Label.Text = Text .. ": " .. Config.Settings[Variable]
                SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
            end
        end)
    end
    
    -- Aba Farm
    local FarmTab = Instance.new("ScrollingFrame")
    FarmTab.Size = UDim2.new(1, 0, 1, 0)
    FarmTab.BackgroundTransparency = 1
    FarmTab.ScrollBarThickness = 5
    FarmTab.Visible = false
    FarmTab.Parent = ContentFrame
    
    CreateToggle(FarmTab, "Auto Farm", "AutoFarm", 0)
    CreateToggle(FarmTab, "Auto Attack", "AutoAttack", 0.06)
    CreateToggle(FarmTab, "Auto Tame", "AutoTame", 0.12)
    CreateToggle(FarmTab, "Auto Boss", "AutoBoss", 0.18)
    CreateToggle(FarmTab, "Auto Dungeon", "AutoDungeon", 0.24)
    CreateToggle(FarmTab, "Auto Collect", "AutoCollect", 0.30)
    CreateToggle(FarmTab, "Auto Quest", "AutoQuest", 0.36)
    CreateToggle(FarmTab, "Auto Upgrade", "AutoUpgrade", 0.42)
    CreateToggle(FarmTab, "Priorizar Lendários", "PriorityLegendary", 0.48)
    
    CreateSlider(FarmTab, "Distância", "Distance", 10, 200, 0.54)
    CreateSlider(FarmTab, "Intervalo", "Interval", 0.1, 5, 0.66)
    
    -- Aba ESP
    local ESPTab = Instance.new("ScrollingFrame")
    ESPTab.Size = UDim2.new(1, 0, 1, 0)
    ESPTab.BackgroundTransparency = 1
    ESPTab.ScrollBarThickness = 5
    ESPTab.Visible = false
    ESPTab.Parent = ContentFrame
    
    CreateToggle(ESPTab, "ESP Ativo", "ESPEnabled", 0)
    CreateToggle(ESPTab, "Box ESP", "BoxESP", 0.06)
    CreateToggle(ESPTab, "Name ESP", "NameESP", 0.12)
    CreateToggle(ESPTab, "Health ESP", "HealthESP", 0.18)
    CreateToggle(ESPTab, "Distance ESP", "DistanceESP", 0.24)
    CreateToggle(ESPTab, "Animal ESP", "AnimalESP", 0.30)
    CreateToggle(ESPTab, "Boss ESP", "BossESP", 0.36)
    CreateToggle(ESPTab, "Item ESP", "ItemESP", 0.42)
    
    CreateSlider(ESPTab, "Distância ESP", "ESPDistance", 50, 500, 0.48)
    
    -- Aba Combat
    local CombatTab = Instance.new("ScrollingFrame")
    CombatTab.Size = UDim2.new(1, 0, 1, 0)
    CombatTab.BackgroundTransparency = 1
    CombatTab.ScrollBarThickness = 5
    CombatTab.Visible = false
    CombatTab.Parent = ContentFrame
    
    CreateToggle(CombatTab, "Aimbot", "AimbotEnabled", 0)
    CreateToggle(CombatTab, "Auto Attack", "AutoAttack", 0.06)
    
    CreateSlider(CombatTab, "FOV", "FOV", 30, 180, 0.12)
    CreateSlider(CombatTab, "Suavização", "Smoothness", 0.05, 1, 0.24)
    
    -- Aba Movement
    local MovementTab = Instance.new("ScrollingFrame")
    MovementTab.Size = UDim2.new(1, 0, 1, 0)
    MovementTab.BackgroundTransparency = 1
    MovementTab.ScrollBarThickness = 5
    MovementTab.Visible = false
    MovementTab.Parent = ContentFrame
    
    CreateToggle(MovementTab, "Fly", "FlyEnabled", 0)
    CreateSlider(MovementTab, "Velocidade", "Speed", 16, 200, 0.06)
    CreateSlider(MovementTab, "Pulo", "JumpPower", 50, 200, 0.18)
    
    -- Botões de teleporte
    local TeleportButtons = {"Animal", "Boss", "Spawn"}
    for i, ButtonName in ipairs(TeleportButtons) do
        local TeleportButton = Instance.new("TextButton")
        TeleportButton.Size = UDim2.new(0.8, 0, 0, 35)
        TeleportButton.Position = UDim2.new(0.1, 0, 0.30 + (i *

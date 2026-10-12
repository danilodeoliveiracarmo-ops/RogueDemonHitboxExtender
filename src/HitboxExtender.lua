--[[
    ROGUE DEMON HITBOX EXTENDER
    Sistema completo de ajuste de hitbox com hub in-game movável
    
    Como usar:
    1. Coloque este script em StarterPlayer > StarterPlayerScripts
    2. Execute o jogo
    3. Use o hub flutuante para ajustar tamanho e distância
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- ESTADO E CONFIGURAÇÃO
-- ============================================

local hitboxState = {
    active = true,
    sizeX = 4,
    sizeY = 6,
    sizeZ = 4,
    distanceX = 0,
    distanceY = 2,
    distanceZ = 0,
    transparency = 0.45,
    color = Color3.fromRGB(80, 200, 255),
}

-- ============================================
-- CRIAR HITBOX DE DEBUG
-- ============================================

local function createDebugHitbox()
    local model = Instance.new("Model")
    model.Name = "RogueDemonHitbox"
    model.Parent = workspace

    local box = Instance.new("Part")
    box.Name = "HitboxPart"
    box.Anchored = true
    box.CanCollide = false
    box.Material = Enum.Material.Neon
    box.TopSurface = Enum.SurfaceType.Smooth
    box.BottomSurface = Enum.SurfaceType.Smooth
    box.Transparency = hitboxState.transparency
    box.Color = hitboxState.color
    box.Size = Vector3.new(hitboxState.sizeX, hitboxState.sizeY, hitboxState.sizeZ)
    box.CFrame = humanoidRootPart.CFrame + Vector3.new(hitboxState.distanceX, hitboxState.distanceY, hitboxState.distanceZ)
    box.Parent = model

    -- Highlight para melhor visualização
    local highlight = Instance.new("Highlight")
    highlight.Adornee = box
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.15
    highlight.FillColor = box.Color
    highlight.OutlineColor = box.Color
    highlight.Parent = box

    return {
        model = model,
        box = box,
        highlight = highlight,
    }
end

local debugHitbox = createDebugHitbox()

-- ============================================
-- CRIAR GUI MOVÁVEL
-- ============================================

local gui = Instance.new("ScreenGui")
gui.Name = "HitboxExtenderGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 340)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Thickness = 2
shadow.Transparency = 0.7
shadow.Parent = mainFrame

-- ============================================
-- HEADER DO HUB
-- ============================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(60, 150, 220)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "⚔️ Hitbox Extender"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ============================================
-- BOTÃO ON/OFF
-- ============================================

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 60, 0, 28)
toggleBtn.Position = UDim2.new(1, -70, 0.5, -14)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
toggleBtn.Text = "ON"
toggleBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = header

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- ============================================
-- CRIAR SLIDER
-- ============================================

local function createSlider(parent, labelText, minValue, maxValue, defaultValue, key, yPosition)
    local container = Instance.new("Frame")
    container.Name = "SliderContainer_" .. key
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = parent

    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    -- Valor exibido
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, 16)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(math.round(defaultValue * 10) / 10)
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    -- Track do slider
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0.5, 5)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    -- Preenchimento do slider
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 150, 220)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    -- Botão interativo
    local slider = Instance.new("TextButton")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, 0, 1, 0)
    slider.BackgroundTransparency = 1
    slider.Text = ""
    slider.Parent = track

    local function updateValue(xPos)
        local percent = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = minValue + (maxValue - minValue) * percent
        value = math.round(value * 10) / 10

        hitboxState[key] = value
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(percent, 0, 1, 0)
    end

    slider.MouseButton1Down:Connect(function()
        updateValue(UserInputService:GetMouseLocation().X)
        
        local inputConn
        inputConn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(UserInputService:GetMouseLocation().X)
            end
        end)

        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)

    -- Inicializar
    local initialPercent = (defaultValue - minValue) / (maxValue - minValue)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
end

-- ============================================
-- CONTEÚDO DO HUB
-- ============================================

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 0)
padding.PaddingRight = UDim.new(0, 0)
padding.Parent = content

-- Seção de Tamanho
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -20, 0, 18)
sizeLabel.Position = UDim2.new(0, 10, 0, 5)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.Text = "📏 TAMANHO"
sizeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
sizeLabel.TextSize = 11
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = content

-- Sliders de Tamanho
createSlider(content, "Largura (X)", 0.5, 20, hitboxState.sizeX, "sizeX", 25)
createSlider(content, "Altura (Y)", 0.5, 20, hitboxState.sizeY, "sizeY", 75)
createSlider(content, "Profundidade (Z)", 0.5, 20, hitboxState.sizeZ, "sizeZ", 125)

-- Seção de Distância
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -20, 0, 18)
distanceLabel.Position = UDim2.new(0, 10, 0, 175)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Font = Enum.Font.GothamBold
distanceLabel.Text = "📍 DISTÂNCIA"
distanceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
distanceLabel.TextSize = 11
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = content

-- Sliders de Distância
createSlider(content, "Distância X", -15, 15, hitboxState.distanceX, "distanceX", 195)
createSlider(content, "Distância Y", -15, 15, hitboxState.distanceY, "distanceY", 245)
createSlider(content, "Distância Z", -15, 15, hitboxState.distanceZ, "distanceZ", 295)

-- ============================================
-- LÓGICA DE ATUALIZAÇÃO
-- ============================================

local function updateHitbox()
    if not hitboxState.active then
        debugHitbox.box.Transparency = 1
        return
    end

    debugHitbox.box.Transparency = hitboxState.transparency
    debugHitbox.box.Size = Vector3.new(hitboxState.sizeX, hitboxState.sizeY, hitboxState.sizeZ)
    debugHitbox.box.Color = hitboxState.color
    
    local offset = Vector3.new(hitboxState.distanceX, hitboxState.distanceY, hitboxState.distanceZ)
    debugHitbox.box.CFrame = humanoidRootPart.CFrame * CFrame.new(offset)
end

-- Toggle ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    hitboxState.active = not hitboxState.active
    toggleBtn.Text = hitboxState.active and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = hitboxState.active and Color3.fromRGB(80, 200, 255) or Color3.fromRGB(255, 100, 100)
    updateHitbox()
end)

-- Atualizar continuamente
RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart = player.Character.HumanoidRootPart
        updateHitbox()
    end
end)

-- Atualizar ao respawnar
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    updateHitbox()
end)

updateHitbox()

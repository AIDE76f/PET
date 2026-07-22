local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local SavedCFrame = nil

Player.CharacterAdded:Connect(function(Char)
	Character = Char
	HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
end)

-- 1. إنشاء الشاشة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI_Pro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- 2. زر الفتح العائم (عند إغلاق الواجهة)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
OpenButton.Text = "📍"
OpenButton.TextSize = 24
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(90, 170, 255)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

-- 3. إطار الواجهة الرئيسي
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 180)
Frame.Position = UDim2.new(0.5, -140, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true -- مهم لحصر الرموز المتساقطة داخل الإطار
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 170, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Frame

-- 4. خلفية الرموز المتساقطة (Matrix Effect)
local MatrixContainer = Instance.new("Frame")
MatrixContainer.Size = UDim2.new(1, 0, 1, 0)
MatrixContainer.BackgroundTransparency = 1
MatrixContainer.Parent = Frame

local Symbols = {"0", "1", "📍", "💾", "⚡", "✨", "x", "y", "z"}
local isSpawningSymbols = true

task.spawn(function()
	while true do
		if isSpawningSymbols and Frame.Visible then
			local symbol = Instance.new("TextLabel")
			symbol.Text = Symbols[math.random(1, #Symbols)]
			symbol.TextSize = math.random(12, 18)
			symbol.TextColor3 = Color3.fromRGB(90, 170, 255)
			symbol.TextTransparency = 0.5
			symbol.BackgroundTransparency = 1
			symbol.Font = Enum.Font.Code
			symbol.Position = UDim2.new(math.random(), 0, -0.1, 0)
			symbol.Parent = MatrixContainer

			local fallSpeed = math.random(2, 4)
			local tween = TweenService:Create(symbol, TweenInfo.new(fallSpeed, Enum.EasingStyle.Linear), {
				Position = UDim2.new(symbol.Position.X.Scale, 0, 1.1, 0),
				TextTransparency = 1
			})
			tween:Play()
			tween.Completed:Connect(function()
				symbol:Destroy()
			end)
		end
		task.wait(0.3)
	end
end)

-- 5. شريط العنوان (Top Bar) للسحب
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Coordinate Saver"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.Parent = TopBar

-- 6. الأزرار الرئيسية
local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.88, 0, 0, 42)
SaveButton.Position = UDim2.new(0.06, 0, 0.3, 0)
SaveButton.Text = "💾 حفظ الإحداثيات"
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 15
SaveButton.TextColor3 = Color3.new(1, 1, 1)
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 120)
SaveButton.BorderSizePixel = 0
SaveButton.Parent = Frame

local C1 = Instance.new("UICorner")
C1.CornerRadius = UDim.new(0, 10)
C1.Parent = SaveButton

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.88, 0, 0, 42)
TeleportButton.Position = UDim2.new(0.06, 0, 0.62, 0)
TeleportButton.Text = "📍 الانتقال إلى الحفظ"
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextSize = 15
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TeleportButton.BorderSizePixel = 0
TeleportButton.Parent = Frame

local C2 = Instance.new("UICorner")
C2.CornerRadius = UDim.new(0, 10)
C2.Parent = TeleportButton

-- 7. ميزة سحب الواجهة (Smooth Dragging System)
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	}):Play()
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- 8. حركات الفتح والأغلاق والتمرير (Animations)
local originalSize = Frame.Size

local function ToggleGUI(show)
	if show then
		Frame.Visible = true
		isSpawningSymbols = true
		TweenService:Create(OpenButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.1)
		OpenButton.Visible = false

		Frame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize}):Play()
	else
		isSpawningSymbols = false
		TweenService:Create(Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.2)
		Frame.Visible = false

		OpenButton.Visible = true
		OpenButton.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(OpenButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
	end
end

CloseButton.MouseButton1Click:Connect(function() ToggleGUI(false) end)
OpenButton.MouseButton1Click:Connect(function() ToggleGUI(true) end)

local function AddButtonEffects(button, baseColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = baseColor:Lerp(Color3.new(1, 1, 1), 0.15)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
	end)
end

AddButtonEffects(SaveButton, Color3.fromRGB(0, 170, 120))
AddButtonEffects(TeleportButton, Color3.fromRGB(0, 120, 255))

-- 9. وظائف الأزرار
local function AnimateClick(Button)
	local t1 = TweenService:Create(Button, TweenInfo.new(0.08), {Size = Button.Size - UDim2.new(0, 4, 0, 4)})
	local t2 = TweenService:Create(Button, TweenInfo.new(0.08), {Size = Button.Size})
	t1:Play()
	t1.Completed:Wait()
	t2:Play()
end

SaveButton.MouseButton1Click:Connect(function()
	AnimateClick(SaveButton)
	SavedCFrame = HumanoidRootPart.CFrame
	SaveButton.Text = "✔ تم الحفظ"
	task.wait(1)
	SaveButton.Text = "💾 حفظ الإحداثيات"
end)

TeleportButton.MouseButton1Click:Connect(function()
	AnimateClick(TeleportButton)
	if SavedCFrame then
		HumanoidRootPart.CFrame = SavedCFrame
	end
end)

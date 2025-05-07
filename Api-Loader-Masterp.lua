repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players")

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--// Player & GUI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Config
if not _G.Configs then 
    _G.Configs = {
        server_port = 5000,
    }
end

--// Data
local data = {
    username = player.Name
}

--// Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

--// Status Frame
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 220, 0, 70)
statusFrame.Position = UDim2.new(1, -230, 1, -90)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = screenGui

local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 8)
cornerRadius.Parent = statusFrame

--// Player Name
local playerNameLabel = Instance.new("TextLabel")
playerNameLabel.Size = UDim2.new(1, -20, 0, 25)
playerNameLabel.Position = UDim2.new(0, 10, 0, 10)
playerNameLabel.BackgroundTransparency = 1
playerNameLabel.Font = Enum.Font.GothamBold
playerNameLabel.TextSize = 18
playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
playerNameLabel.Text = player.Name
playerNameLabel.Parent = statusFrame

--// Status Title
local statusTitleLabel = Instance.new("TextLabel")
statusTitleLabel.Size = UDim2.new(0, 60, 0, 24)
statusTitleLabel.Position = UDim2.new(0, 10, 0, 40)
statusTitleLabel.BackgroundTransparency = 1
statusTitleLabel.Font = Enum.Font.Gotham
statusTitleLabel.TextSize = 16
statusTitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
statusTitleLabel.Text = "Status:"
statusTitleLabel.Parent = statusFrame

--// Status Value
local statusValueLabel = Instance.new("TextLabel")
statusValueLabel.Size = UDim2.new(0, 120, 0, 24)
statusValueLabel.Position = UDim2.new(0, 75, 0, 40)
statusValueLabel.BackgroundTransparency = 1
statusValueLabel.Font = Enum.Font.GothamBold
statusValueLabel.TextSize = 16
statusValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusValueLabel.TextXAlignment = Enum.TextXAlignment.Left
statusValueLabel.Text = "Connecting..."
statusValueLabel.Parent = statusFrame

--// Status Indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 10, 0, 10)
statusIndicator.Position = UDim2.new(0, 180, 0, 47)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusFrame

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = statusIndicator

local indicatorGlow = Instance.new("ImageLabel")
indicatorGlow.Size = UDim2.new(2, 0, 2, 0)
indicatorGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
indicatorGlow.BackgroundTransparency = 1
indicatorGlow.Image = "rbxassetid://5028857084"
indicatorGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
indicatorGlow.ImageTransparency = 0.6
indicatorGlow.Parent = statusIndicator

--// Update Connection GUI
local function updateConnectionStatus(connected: boolean)
	local newText = connected and "Connected" or "Disconnected"
	local newColor = connected and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80)

	statusValueLabel.Text = newText
	statusValueLabel.TextTransparency = 0.5
	statusValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(statusValueLabel, tweenInfo, {
		TextColor3 = newColor,
		TextTransparency = 0
	}):Play()

	TweenService:Create(statusIndicator, tweenInfo, {
		BackgroundColor3 = newColor
	}):Play()

	TweenService:Create(indicatorGlow, tweenInfo, {
		ImageColor3 = newColor
	}):Play()
end

--// Adjust GUI on screen resize
local function adjustToScreenSize()
	local function updatePosition()
		statusFrame.Position = UDim2.new(1, -230, 1, -90)
	end
	player:GetPropertyChangedSignal("CameraMode"):Connect(updatePosition)
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePosition)
	updatePosition()
end
adjustToScreenSize()

--// Disconnection watcher
local isDisconnected = false
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
		isDisconnected = true
		updateConnectionStatus(false)
		warn("ErrorPrompt detected.")
	end
end)

--// Loop to check server connectivity
task.spawn(function()
	while true do
		if not isDisconnected then

			local success, result = pcall(function()
				local response = request({
					Url = string.format("http://127.0.0.1:%d/api/update", _G.Configs.server_port),
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json"
					},
					Body = HttpService:JSONEncode(data)
				})
				return HttpService:JSONDecode(response.Body)
			end)

			if success then
				warn("Request success for:", player.Name)
				updateConnectionStatus(true)
			else
				updateConnectionStatus(false)
				warn("Request failed:", result)
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Masterp Services v2.3",
					Text = "Server disconnected",
				})
			end

			task.wait(3)
		else
			updateConnectionStatus(false)
			break
		end
	end
end)

--// Initial Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Masterp Services v2.3",
	Text = "Connected: " .. player.Name,
})
warn("Masterp Client Connected on port: " .. tostring(_G.Configs.server_port))

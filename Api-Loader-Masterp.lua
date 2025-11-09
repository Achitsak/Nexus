repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

-- Services
local Players        = game:GetService("Players")
local LocalPlayer    = Players.LocalPlayer
local HttpService    = game:GetService("HttpService")
local GuiService     = game:GetService("GuiService")
local StarterGui     = game:GetService("StarterGui")
local RunService     = game:GetService("RunService")
local PromptOverlay  = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
local Request        = http_request or request
local isDisconnected = false


if not _G.MasterpConfigs then 
    _G.MasterpConfigs = {
        server_port = 2124,
    }
end

local data = {
	username = LocalPlayer.Name
}

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        isDisconnected = true
    end
end)

Players.LocalPlayer.AncestryChanged:Connect(function()
    if not Players.LocalPlayer:IsDescendantOf(Players) then
        isDisconnected = true
    end
end)

local function CheckErrorPrompt(v)
	if v.Name == "ErrorPrompt" then
		local function LogError()
			local title = "Unknown"
			local message = "Unknown"

			local titleFrame = v:FindFirstChild("TitleFrame")
			local titleLabel = titleFrame and titleFrame:FindFirstChild("ErrorTitle")
			if titleLabel and titleLabel.Text and titleLabel.Text ~= "" then
				title = titleLabel.Text
			end

			local msg = v:FindFirstChildWhichIsA("TextLabel", true)
			if msg and msg.Text and msg.Text ~= "" then
				message = msg.Text
			end

			if title ~= "Unknown" or message ~= "Unknown" then
				isDisconnected = true
			end
		end

		if v.Visible then
			LogError()
		end

		v:GetPropertyChangedSignal("Visible"):Connect(function()
			if v.Visible then
				LogError()
			end
		end)
	end
end

game:GetService("NetworkClient").ChildRemoved:Connect(function(child)
	isDisconnected = true
end)

Overlay.ChildAdded:Connect(CheckErrorPrompt)

task.spawn(function()
	while true do
		print(isDisconnected)
		if not isDisconnected then
			local success, result = pcall(function()
				return HttpService:JSONDecode(Request({
					Url = ("http://127.0.0.1:%d/api/update"):format(_G.MasterpConfigs.server_port),
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = HttpService:JSONEncode(data)
				}).Body)
			end)
		end
		task.wait(math.random(3, 6))
	end
end)

-- Load remote scripts
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/scripts/main/ui/v3.lua"))()
end)

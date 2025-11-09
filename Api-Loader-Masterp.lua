repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players 		 = game:GetService("Players")
local LocalPlayer 	 = Players.LocalPlayer
local HttpService 	 = game:GetService("HttpService")
local GuiService 	 = game:GetService("GuiService")
local StarterGui 	 = game:GetService("StarterGui")
local RunService 	 = game:GetService("RunService")
local PromptOverlay  = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
local Request 		 = http_request or request
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

PromptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" then
		task.defer(function()
			local title, message = "Unknown", "Unknown"
			local titleFrame = child:FindFirstChild("TitleFrame")
			local titleLabel = titleFrame and titleFrame:FindFirstChild("ErrorTitle")
			if titleLabel and titleLabel.Text and titleLabel.Text ~= "" then
				title = titleLabel.Text
			end
			local msg = child:FindFirstChildWhichIsA("TextLabel", true)
			if msg and msg.Text and msg.Text ~= "" then
				message = msg.Text
			end

			pcall(function()
				local code = GuiService:GetErrorCode()
				if code > 0 then
					isDisconnected = true
				end
			end)

			if title:find("Disconnected") or title:find("Teleport Failed") then
				isDisconnected = true
			end
		end)
	end
end)

game:GetService("NetworkClient").ChildRemoved:Connect(function(child)
	isDisconnected = true
end)

-- Update status to server
task.spawn(function()
	while true do
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

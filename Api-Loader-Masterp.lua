repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request)

if not _G.Configs then 
    _G.Configs = {
        server_port = 5000,
    }
end

local data = {
	username = LocalPlayer.Name
}

local isDisconnected = false

local function handleDisconnection(reason)
	if not isDisconnected then
		isDisconnected = true
		warn("Disconnected: " .. reason)

		task.delay(35, function()
			isDisconnected = false
			warn("Reconnected after 35s (" .. reason .. ")")
		end)
	end
end

-- Detect ErrorPrompt
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
		handleDisconnection("ErrorPrompt")
	end
end)

-- Detect Teleport
LocalPlayer.OnTeleport:Connect(function(State)
	if State == Enum.TeleportState.Started then
		handleDisconnection("Teleport")
	end
end)

-- Detect if Player is removed from game
LocalPlayer.AncestryChanged:Connect(function(_, parent)
	if not parent then
		handleDisconnection("Player removed (AncestryChanged)")
	end
end)

-- Detect PlayerRemoving
Players.PlayerRemoving:Connect(function(player)
	if player == LocalPlayer then
		handleDisconnection("PlayerRemoving")
	end
end)

-- Update status to server
task.spawn(function()
	while true do
		if not isDisconnected then
			local success, result = pcall(function()
				return HttpService:JSONDecode(Request({
					Url = ("http://127.0.0.1:%d/api/update"):format(_G.Configs.server_port),
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = HttpService:JSONEncode(data)
				}).Body)
			end)

			if not success then
				pcall(function()
					StarterGui:SetCore("SendNotification", {
						Title = "Masterp Services v2.4",
						Text = "Client Not Connected!",
					})
				end)
			end
		end
		task.wait(math.random(3, 6))
	end
end)

-- Notify when fully connected
StarterGui:SetCore("SendNotification", {
    Title = "Masterp Services v2.4",
    Text = "Connected: " .. LocalPlayer.Name,
})
warn("Masterp Client Connected: " .. tostring(_G.Configs.server_port))

-- Load remote scripts
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/scripts/main/ui/v3.lua"))()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/Nexus/main/services/callback_base_on.lua"))()
end)
if not success then
	warn("Failed to load remote scripts:", err)
end

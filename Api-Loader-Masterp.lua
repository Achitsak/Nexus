repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players")

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request)

--// Player
local player = Players.LocalPlayer

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

--// Disconnection watcher
local isDisconnected = false
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
		isDisconnected = true
		warn("ErrorPrompt detected.")
	end
end)

--// Loop to check server connectivity
task.spawn(function()
	while true do
		if not isDisconnected then

			local success, result = pcall(function()
				local response = Request({
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
				--warn("Request success for:", player.Name)
			else
				--warn("Request failed:", result)
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Masterp Services v2.3",
					Text = "Server disconnected",
				})
			end

			task.wait(math.random(3, 6))
		else
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

repeat task.wait() until game:IsLoaded()

if not game:IsLoaded() then
    task.delay(60, function()
        if NoShutdown then return end
        if not game:IsLoaded() then
            return game:Shutdown()
        end
        local Code = game:GetService'GuiService':GetErrorCode().Value
        if Code >= Enum.ConnectionError.DisconnectErrors.Value then
            return game:Shutdown()
        end
    end)
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request)
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
local isDisconnected = false

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started and Nexus.IsConnected then
        isDisconnected = true
    end
end)

if not _G.Configs then 
    _G.Configs = {
        server_port = 5000,
    }
end

local data = {
	username = LocalPlayer.Name
}

promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
		local code = game:GetService("GuiService"):GetErrorCode().Value
		if code > 0 then
			isDisconnected = true
			warn("Disconnected with error code:", code)
		end
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

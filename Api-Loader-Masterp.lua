repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

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
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
		isDisconnected = true
		warn("ErrorPrompt disconnected.")
	end
end)

LocalPlayer.OnTeleport:Connect(function(State)
	if State == Enum.TeleportState.Started and not isDisconnected then
		isDisconnected = true
		warn("Teleport disconnected.")
	end
end)

task.spawn(function()
	while not isDisconnected do
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
					Title = "Masterp Services v2.3",
					Text = "Client Not Connected!",
				})
			end)
		end

		task.wait(math.random(3, 6))
	end
end)

GuiService.ErrorMessageChanged:Connect(function()
    if NoShutdown then return end
    local Code = GuiService:GetErrorCode().Value
    if Code >= Enum.ConnectionError.DisconnectErrors.Value then
        if Code > Enum.ConnectionError.PlacelaunchOtherError.Value then
            return
        end
        isDisconnected = true
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Masterp Services v2.4",
    Text = "Connected: " .. LocalPlayer.Name,
})

warn("Masterp Client Connected: " .. tostring(_G.Configs.server_port))

x, p = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/scripts/main/ui/v3.lua"))()
end)

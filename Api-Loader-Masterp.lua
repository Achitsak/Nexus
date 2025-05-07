repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players")

if not _G.Configs then 
    _G.Configs = {
        server_port = 5000,
    }
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local promptOverlay = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

local isDisconnected = false
local data = {
    username = Players.LocalPlayer.Name
}

promptOverlay.ChildAdded:Connect(function(child)
    if ((child.Name == "ErrorPrompt") and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame")) then
        isDisconnected = true
        warn("ErrorPrompt detected.")
    end
end)

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
                warn("Request success for:", Players.LocalPlayer.Name)
            else
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title = "Masterp Services v2.2", -- Required
                    Text = "Error Pls Check Console", -- Required
                })
                warn("Request failed:", result)
            end
            task.wait(3)
        else
            warn("Disconnected Client: " .. Players.LocalPlayer.Name)
            break
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Masterp Services v2.2", -- Required
    Text = "Connected: "..tostring(game.Players.LocalPlayer.Name), -- Required
})
warn('Masterp Client Connected: '..tostring(_G.Configs.server_port))

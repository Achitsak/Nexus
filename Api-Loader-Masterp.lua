repeat task.wait() until game:IsLoaded()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local data = {
    username = tostring(Players.LocalPlayer.Name)
}
_G.Connected = true
local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')
po.ChildAdded:connect(function(a)
    if a.Name == 'ErrorPrompt' then
        _G.Connected = false
    end
end)
task.spawn(function()
    while true do
        local success, result = pcall(function()
            if _G.Connected then
                local response = request(
                    {
                        ["Url"] = 'http://127.0.0.1:5000/api/update',
                        ["Method"] = "POST",
                        ["Body"] = HttpService:JSONEncode(data),
                        ["Headers"] = {
                            ["Content-Type"] = "application/json"
                        }
                    }
                )
            end
            if response and response.Body then
                return HttpService:JSONDecode(response.Body)
            end
            return response
        end)
        task.wait(5)
    end
end)
task.spawn(function()
    print("Services | Extensions Is Loaded!")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/Nexus/refs/heads/main/services/callback.lua"))()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/webhook/refs/heads/main/Moon_"))()
    end)
end)
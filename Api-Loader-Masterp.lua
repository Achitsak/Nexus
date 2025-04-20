repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp, po, ts = Players.LocalPlayer, game.CoreGui.RobloxPromptGui.promptOverlay, game:GetService('TeleportService')

_G.Disconnected = false

local data = {
    username = tostring(Players.LocalPlayer.Name)
}

po.ChildAdded:Connect(function(text_error)
    if text_error.Name == 'ErrorPrompt' then
        _G.Disconnected = true
        warn("Connection lost: ErrorPrompt detected.")
    end
end)


task.spawn(function()
    while true do
        local success, result = pcall(function()
            if not _G.Disconnected then
                local response = request(
                    {
                        ["Url"] = 'http://127.0.0.1:5000/api/update',
                        ["Method"] = "POST",
                        ["Body"] = HttpService:JSONEncode(data),
                        ["Headers"] = { ["Content-Type"] = "application/json" }
                    }
                )
            else
                print("Disconnected From Server! Client: "..Players.LocalPlayer.Name)
                task.wait(5)
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
    local urls = {
        "https://raw.githubusercontent.com/Achitsak/Nexus/refs/heads/main/services/callback.lua",
        "https://raw.githubusercontent.com/Achitsak/Nexus/refs/heads/main/services/callback_base_on.lua",
        "https://raw.githubusercontent.com/Achitsak/webhook/refs/heads/main/Moon_",
        "https://raw.githubusercontent.com/Achitsak/webhook/refs/heads/main/Mirage_"
    }

    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            local code = game:HttpGet(url)
            if code then
                local func = loadstring(code)
                if func then
                    func()
                    print("Loaded script: ".. _)
                else
                    warn("Failed to load script from: " .. _)
                end
            end
        end)
        if not success then
            warn("Error loading script from: " .. _ .. ": " .. tostring(result))
        end
    end
    print("Services | Extensions Is Loaded! v2.0")
end)
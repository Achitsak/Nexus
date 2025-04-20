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
    local creatorIds = {
        Moon = 4372130,  
        Mirage = 4372130 
    }

    local urls = {
        { url = "https://raw.githubusercontent.com/Achitsak/Nexus/refs/heads/main/services/callback.lua", alwaysLoad = true },
        { url = "https://raw.githubusercontent.com/Achitsak/Nexus/refs/heads/main/services/callback_base_on.lua", alwaysLoad = true },
        { url = "https://raw.githubusercontent.com/Achitsak/webhook/refs/heads/main/Moon_", creatorId = creatorIds.Moon },
        { url = "https://raw.githubusercontent.com/Achitsak/webhook/refs/heads/main/Mirage_", creatorId = creatorIds.Mirage }
    }

    local currentCreatorId = game.CreatorId

    for _, entry in ipairs(urls) do
        if entry.alwaysLoad or (entry.creatorId and entry.creatorId == currentCreatorId) then
            local success, result = pcall(function()
                local code = game:HttpGet(entry.url)
                if code then
                    local func = loadstring(code)
                    if func then
                        func()
                        print("Loaded script: " .. _)
                    else
                        warn("Failed to load script: " .. _)
                    end
                end
            end)
            if not success then
                warn("Error loading script: " .. _ .. ": " .. tostring(result))
            end
        else
            print("Skipping " .. _ .. " (CreatorId does not match)")
        end
    end
    print("Services | Extensions Is Loaded! v2.0")
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Masterp Services v2.0", -- Required
        Text = "Connected: "..tostring(game.Players.LocalPlayer.Name), -- Required
    })
end)
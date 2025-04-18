repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local data = {
    username = tostring(Players.LocalPlayer.Name)
}

task.spawn(function()
    while true do
        local success, result = pcall(function()
            local response = request(
                {
                    ["Url"] = 'https://66521a66-ce71-440d-a511-d707d7d941d3-00-30jg5qgxjr16o.pike.replit.dev/submit',
                    ["Method"] = "POST",
                    ["Body"] = HttpService:JSONEncode(data),
                    ["Headers"] = {
                        ["Content-Type"] = "application/json"
                    }
                }
            )
            if response and response.Body then
                return HttpService:JSONDecode(response.Body)
            end
            return response
        end)
        task.wait(10)
    end
end)

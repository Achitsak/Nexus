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
                    ["Url"] = 'http://sudo.pylex.xyz:11473/submit',
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

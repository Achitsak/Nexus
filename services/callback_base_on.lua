repeat task.wait(5) until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request)
local Executor = identifyexecutor()

local data = {
	username = game.Players.LocalPlayer.Name,
	placeid = game.PlaceId,
	jobid = game.JobId,
	gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)["Name"]
	executor = Executor
}

local jsonBody = HttpService:JSONEncode(data)

task.spawn(function()
    while true do task.wait()
        local success, result = pcall(function()
            return Request({
                Url = "https://backend-p5i9.onrender.com/api/tracker",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonBody
            })
        end)
        task.wait(15)
    end
end)

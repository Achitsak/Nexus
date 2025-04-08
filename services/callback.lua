repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Executor = identifyexecutor and identifyexecutor() or "Unknown"
local Request = http_request or request or HttpPost or (syn and syn.request)

local sendback = function()
    local data = {
        content = nil,
        embeds = {
            {
                title = "Executor Log",
                color = 65372,
                fields = {
                    { name = "👤 Username",  value = "```Thailand```",   inline = true },
                    { name = "🛠 Executor",  value = "```"..Executor.."```", inline = true },
                    { name = "🌐 PlaceID",  value = "```"..tostring(game.PlaceId).."```",      inline = true },
                },
                thumbnail = {
                    url = "https://img5.pic.in.th/file/secure-sv1/7da92b9d-7aa8-48d2-8d22-4abfc00e6b94.png"
                },
                footer = {
                    text = "Masterp Services",
                }
            }
        },
        attachments = {}
    }

    local jsonPayload = HttpService:JSONEncode(data)

    local response = Request({
        Url = 'https://discord.com/api/webhooks/1359070485433815191/1u-oxih_W6KYCi8ecMS_0UMT1muKCMQNNf2lpaenKmKU2BSSAL4liExFtLPqO7ZGkC34',
        Body = jsonPayload,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })
end

task.spawn(function()
    sendback()
end)
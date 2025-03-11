if XusMasterp then XusMasterp:Stop() end
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

local XusMasterp = {}
local WSConnect = syn and syn.websocket.connect or
    (Krnl and (function() repeat task.wait() until Krnl.WebSocket and Krnl.WebSocket.connect return Krnl.WebSocket.connect end)()) or
    WebSocket and WebSocket.connect

if not WSConnect then
    if messagebox then
        messagebox(('XusMasterp encountered an error while launching!\n\n%s'):format('Your exploit (' .. (identifyexecutor and identifyexecutor() or 'UNKNOWN') .. ') is not supported'), 'Roblox Account Manager', 0)
    end
    
    return
end

local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')

po.ChildAdded:connect(function(a)
    if a.Name == 'ErrorPrompt' then
        repeat
            XusMasterp:Stop()
            wait(2)
        until false
    end
end)

local TeleportService = game:GetService'TeleportService'
local InputService = game:GetService'UserInputService'
local HttpService = game:GetService'HttpService'
local RunService = game:GetService'RunService'
local GuiService = game:GetService'GuiService'
local Players = game:GetService'Players'
local LocalPlayer = Players.LocalPlayer if not LocalPlayer then repeat LocalPlayer = Players.LocalPlayer task.wait() until LocalPlayer end task.wait(0.5)

local UGS = UserSettings():GetService'UserGameSettings'
local OldVolume = UGS.MasterVolume

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started and XusMasterp.IsConnected then
        XusMasterp:Stop() -- Apparently doesn't disconnect websockets on teleport so this has to be here
    end
end)

local Signal = {} do
    Signal.__index = Signal

    function Signal.new()
        local self = setmetatable({ _BindableEvent = Instance.new'BindableEvent' }, Signal)
        
        return self
    end

    function Signal:Connect(Callback)
        assert(typeof(Callback) == 'function', 'function expected, got ' .. typeof(Callback))

        return self._BindableEvent.Event:Connect(Callback)
    end

    function Signal:Fire(...)
        self._BindableEvent:Fire(...)
    end

    function Signal:Wait()
        return self._BindableEvent.Event:Wait()
    end

    function Signal:Disconnect()
        if self._BindableEvent then
            self._BindableEvent:Destroy()
        end
    end
end

do -- XusMasterp
    local BTN_CLICK = 'ButtonClicked:'

    XusMasterp.Connected = Signal.new()
    XusMasterp.Disconnected = Signal.new()
    XusMasterp.MessageReceived = Signal.new()

    XusMasterp.Commands = {}
    XusMasterp.Connections = {}

    XusMasterp.ShutdownTime = 45
    XusMasterp.ShutdownOnTeleportError = true

    function XusMasterp:Send(Command, Payload)
        assert(self.Socket ~= nil, 'websocket is nil')
        assert(self.IsConnected, 'websocket not connected')
        assert(typeof(Command) == 'string', 'Command must be a string, got ' .. typeof(Command))

        if Payload then
            assert(typeof(Payload) == 'table', 'Payload must be a table, got ' .. typeof(Payload))
        end

        local Message = HttpService:JSONEncode {
            Name = Command,
            Payload = Payload
        }

        self.Socket:Send(Message)
    end

    function XusMasterp:Log(...)
        local T = {}

        for Index, Value in pairs{ ... } do
            table.insert(T, tostring(Value))
        end

        self:Send('Log', {
            Content = table.concat(T, ' ')
        })
    end

    function XusMasterp:CreateElement(ElementType, Name, Content, Size, Margins, Table)
        assert(typeof(Name) == 'string', 'string expected on argument #1, got ' .. typeof(Name))
        assert(typeof(Content) == 'string', 'string expected on argument #2, got ' .. typeof(Content))

        assert(Name:find'%W' == nil, 'argument #1 cannot contain whitespace')

        if Size then assert(typeof(Size) == 'table' and #Size == 2, 'table with 2 arguments expected on argument #3, got ' .. typeof(Size)) end
        if Margins then assert(typeof(Margins) == 'table' and #Margins == 4, 'table with 4 arguments expected on argument #4, got ' .. typeof(Margins)) end
        
        local Payload = {
            Name = Name,
            Content = Content,
            Size = Size and table.concat(Size, ','),
            Margin = Margins and table.concat(Margins, ',')
        }

        if Table then
            for Index, Value in pairs(Table) do
                Payload[Index] = Value
            end
        end

        self:Send(ElementType, Payload)
    end

    function XusMasterp:Connect(Host, Bypass)
        if not Bypass and self.IsConnected then return 'Ignoring connection request, XusMasterp is already connected' end

        while true do
            for Index, Connection in pairs(self.Connections) do
                Connection:Disconnect()
            end
        
            table.clear(self.Connections)

            if self.IsConnected then
                self.IsConnected = false
                self.Socket = nil
                self.Disconnected:Fire()
            end

            if self.Terminated then break end

            if not Host then
                Host = 'localhost:5000'
            end

            local Success, Socket = pcall(WSConnect, ('ws://localhost:5000/XusMasterp/%s'):format(LocalPlayer.Name))

            if not Success then task.wait(12) continue end

            self.Socket = Socket
            self.IsConnected = true

            table.insert(self.Connections, Socket.OnMessage:Connect(function(Message)
                self.MessageReceived:Fire(Message)
            end))

            table.insert(self.Connections, Socket.OnClose:Connect(function()
                self.IsConnected = false
                self.Disconnected:Fire()
            end))

            self.Connected:Fire()

            while self.IsConnected do
                local Success, Error = pcall(self.Send, self, 'ping')

                if not Success or self.Terminated then
                    break
                end

                task.wait(10)
            end
            while self.IsConnected do
                local Success, Error = pcall(self.Send, self, 'ping')
    
                if not Success or self.Terminated then
                    break
                end
    
                task.wait(1)
            end
        end
    end

    function XusMasterp:Stop()
        self.IsConnected = false
        self.Terminated = true
        self.Disconnected:Fire()

        if self.Socket then
            pcall(function() self.Socket:Close() end)
        end
    end
end

do -- Connections
    GuiService.ErrorMessageChanged:Connect(function()
        if NoShutdown then return end

        local Code = GuiService:GetErrorCode().Value

        if Code >= Enum.ConnectionError.DisconnectErrors.Value then
            if not XusMasterp.ShutdownOnTeleportError and Code > Enum.ConnectionError.PlacelaunchOtherError.Value then
                print("Errorroro")
                return
            end
            
            task.delay(XusMasterp.ShutdownTime, game.Shutdown, game)
        end
    end)
end

local GEnv = getgenv()
GEnv.XusMasterp = XusMasterp
GEnv.performance = XusMasterp.Commands.performance

if not XusMasterp_Version then
    XusMasterp:Connect()
end

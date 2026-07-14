local g = getgenv()
local x = setmetatable({}, {__index = function(_, y) return cloneref(game:GetService(y)) end})

g.players = x.Players
g.coreGui = x.CoreGui
g.guiService = x.GuiService
g.runService = x.RunService
g.httpService = x.HttpService
g.virtualUser = x.VirtualUser
g.tweenService = x.TweenService
g.teleportService = x.TeleportService
g.userInputService = x.UserInputService
g.collectionService = x.CollectionService
g.replicatedStorage = x.ReplicatedStorage
g.experienceService = x.ExperienceService
g.pathfindingService = x.PathfindingService
g.marketplaceService = x.MarketplaceService
g.virtualInputManager = x.VirtualInputManager

g.player = players.LocalPlayer

g.getCharacter = function()
    return player.Character
end

g.getHumanoid = function()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

g.getHumanoidRootPart = function()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

g.teleport = function(cframe)
    local char = getCharacter()
    return char and char:PivotTo(cframe)
end

g.getDistance = function(position)
    return getCharacter() and player:DistanceFromCharacter(position) or math.huge
end

g.noClip = function()
    local char = getCharacter()
    if not char then return end

    for i, v in char:GetDescendants() do
        if v:IsA("BasePart") and v.CanCollide then
            v.CanCollide = false
        end
    end
end

g.float = function(bool)
    local humanoidRootPart = getHumanoidRootPart()
    local humanoid = getHumanoid()
    local bodyVelocity = humanoidRootPart and humanoidRootPart:FindFirstChild("BodyVelocity")

    if not bool and bodyVelocity then
        humanoid.PlatformStand = false
        bodyVelocity:Destroy()
        return 
    end

    if not bool or not humanoidRootPart or not humanoid then return end
    if bodyVelocity then return end

    humanoid.PlatformStand = true
    local bodyVelocityInstance = Instance.new("BodyVelocity")
    bodyVelocityInstance.Parent = humanoidRootPart
    bodyVelocityInstance.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocityInstance.P = 1250
    bodyVelocityInstance.Velocity = Vector3.zero
end

g.tween = function(cframe, speed, wait)
    local humanoidRootPart = getHumanoidRootPart()
    if not humanoidRootPart then return end
    local time = (humanoidRootPart.CFrame.p - cframe.p).Magnitude / speed
    local tween = tweenService:Create(humanoidRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cframe})
    tween:Play()

    if wait then
        task.wait(time)
    end
end

g.useTool = function(name)
    local character = getCharacter()
    local humanoid = getHumanoid()
    if not humanoid then return end
    local tool = player.Backpack:FindFirstChild(name) or character:FindFirstChild(name)
    
    if tool then
        if not character:FindFirstChild(tool.Name) then
            humanoid:EquipTool(tool)
        end
        --tool:Activate()
        return true
    end
    return false
end

g.moveTo = function(position)
    local humanoid = getHumanoid()
    return humanoid and humanoid:MoveTo(position)
end

g.dex = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end

g.rejoin = function(placeId, jobId)
    placeId = placeId or game.PlaceId
    jobId = jobId or game.JobId

    if not jobId then
        teleportService:Teleport(placeId, player)
        return
    end

    if #players:GetPlayers() <= 1 then
        --player:Kick("restarting")
        teleportService:Teleport(placeId, player)
        --experienceService:LaunchExperience({placeId = placeId, gameInstanceId = jobId})
        return
    end
    
    teleportService:Teleport(placeId, player)
    -- experienceService:LaunchExperience({placeId = placeId, gameInstanceId = jobId})
end

g.face = function(position)
    local humanoidRootPart = getHumanoidRootPart()
    if not humanoidRootPart then return end
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, position)
end

g.faceCamera = function(pos)
    local cam = workspace.CurrentCamera
    if not cam then return end
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
end

g.afkMode = function(bool, fps)
    setfpscap(fps or 60)
    runService:Set3dRenderingEnabled(not bool)

    if afkScreenGui then afkScreenGui:Destroy() end
    if afkFrame then afkFrame:Destroy() end

    g.afkScreenGui = Instance.new("ScreenGui")
    afkScreenGui.Parent = coreGui
    afkScreenGui.IgnoreGuiInset = true

    g.afkFrame = Instance.new("Frame")
    afkFrame.Parent = afkScreenGui
    afkFrame.Size = UDim2.new(1, 0, 1, 0)
    afkFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    afkFrame.Visible = bool
end

g.sendWebhook = function(url, text, embed)
    return request({
        Url = ("%*?wait=true"):format(url),
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = httpService:JSONEncode({embeds = {embed}, content = text})
    })    
end

g.mouse1Click = function(x, y)
    virtualInputManager:SendMouseButtonEvent(x or 0, y or 0, 0, true, game, false)
    task.wait()
    virtualInputManager:SendMouseButtonEvent(x or 0, y or 0, 0, false, game, false)
end

g.fireProximityPrompt = function(prompt)
    prompt.HoldDuration = 0
    prompt:InputHoldBegin()
    prompt:InputHoldEnd()
end

g.pressKey = function(key)
    virtualInputManager:SendKeyEvent(true, key, false, game) 
    virtualInputManager:SendKeyEvent(false, key, false, game) 
end

g.navigation = function(ui)
    local function isActuallyVisible(guiObject)
        local current = guiObject
        
        if not guiObject:IsA("GuiObject") then
            return false
        end
    
        while current do
            if current:IsA("GuiObject") and not current.Visible then
                return false
            end
            current = current.Parent
        end
    
        if guiObject.AbsoluteSize.X <= 0 or guiObject.AbsoluteSize.Y <= 0 then
            return false
        end
    
        local pos = guiObject.AbsolutePosition
        local size = guiObject.AbsoluteSize
        local screen = workspace.CurrentCamera.ViewportSize
    
        return pos.X < screen.X and pos.Y < screen.Y and pos.X + size.X > 0 and pos.Y + size.Y > 0
    end

    if not isActuallyVisible(ui) then return end
    assert(ui, tostring(ui) .. " is nil")
    assert(ui:IsA("TextButton") or ui:IsA("ImageButton"), tostring(ui) .. " is not a button")
    
    guiService.GuiNavigationEnabled = ui.Visible
    guiService.SelectedObject = ui.Visible and ui or nil
    if not ui.Visible then return end 

    pressKey("Return")
    task.wait(.1)
    guiService.SelectedObject = nil
end

g.copyPos = function()
    setclipboard(tostring(getCharacter():GetPivot().p))
end

g.autoRejoin = function(place)
    place = place or game.PlaceId

    for i, v in coreGui.RobloxPromptGui.promptOverlay:GetChildren() do
        if v.Name == "ErrorPrompt" then
            serverHop()
        end
    end
    
    coreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
        if v.Name == "ErrorPrompt" then
            serverHop()
        end
    end)
end

g.canRun = (function()
    local cache = {}
    return function(t, key)
        local now = os.clock()
        local last = cache[key]

        if not last or (now - last) >= t then
            cache[key] = now
            return true
        end
    end
end)()

g.tpWalk = function(enabled, speed)
    g.tpWalkRunning = enabled
    speed = shared.speed or speed or 1

    while tpWalkRunning do
        local char = getCharacter()
        local humanoid = getHumanoid()    
		local delta = runService.Heartbeat:Wait()

		if humanoid.MoveDirection.Magnitude > 0 then
            char:TranslateBy(humanoid.MoveDirection * (speed or 1) * delta * 10)
		end
	end
end

g.serverHop = function()
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    local cacheFile = ("serverCache_%s.json"):format(placeId)
    
    local refreshRate = 90
    local resetJoinedRate = 300

    local cachedData = {
        updated = 0,
        servers = {},
        joined = {}
    }
    
    if isfile(cacheFile) then
        local success, result = pcall(function()
            return httpService:JSONDecode(readfile(cacheFile))
        end)
    
        if success and type(result) == "table" then
            cachedData = result
        end
    end
    
    cachedData.joined[jobId] = true
    
    local function saveCache()
        writefile(
            cacheFile,
            httpService:JSONEncode(cachedData)
        )
    end
    
    local function resetJoined()
        cachedData.joined = {}
        cachedData.joined[jobId] = true
        cachedData.joinedUpdated = os.time()
        saveCache()
    end
    
    local function refreshServers()
        cachedData.updated = os.time()
        cachedData.servers = {}
    
        local cursor = ""
    
        repeat
            local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s"):format(game.PlaceId, cursor ~= "" and "&cursor=" .. cursor or "")
            local response = game:HttpGet(url)
            local data = httpService:JSONDecode(response)
    
            for _, server in ipairs(data.data) do
                if
                    server.playing < server.maxPlayers
                    and not cachedData.joined[server.id]
                then
                    cachedData.servers[#cachedData.servers + 1] = server.id
                end
            end
    
            cursor = data.nextPageCursor or ""
        until cursor == ""
    
        saveCache()
    end
    
    if os.time() - (cachedData.joinedUpdated or 0) >= resetJoinedRate then
        resetJoined()
    end
    
    if (os.time() - cachedData.updated) >= refreshRate then
        pcall(refreshServers)
    end
    
    while #cachedData.servers > 0 do
        local serverId = table.remove(cachedData.servers, 1)
    
        cachedData.joined[serverId] = true
    
        saveCache()
        pcall(teleportService.TeleportToPlaceInstance, teleportService, placeId, serverId, player)
        --experienceService:LaunchExperience({placeId = placeId, gameInstanceId = serverId})

        task.wait(3)
        --break
    end
end

g.antiMods = function(groupId)
    groupId = groupId or 75550158
    
    local function antiStaff(v)
        if v:GetRankInGroup(groupId) > 1 then
            player:Kick(("staff: %*"):format(v.Name))
        end
    end

    for i, v in players:GetPlayers() do
        antiStaff(v)
    end

    if playerAddedConn then playerAddedConn:Disconnect() end
    getgenv().playerAddedConn = players.PlayerAdded:Connect(function(v)
        antiStaff(v)
    end)

    print("antiMods loaded for:", groupId)
end

g.rspy = function()
    getGithubFile("tool/rspy/script.lua")
end

g.autoAdd = function()
    local sent = {}
    if game:GetService("RobloxReplicatedStorage").GetServerType:InvokeServer() ~= "VIPServer" and true or false then return end
    print("auto add enabled")

    local function addPlayer(v)
        if v ~= player and not sent[v.UserId] then
            task.spawn(function()
                task.wait(5)
                sent[v.UserId] = true
                print("added", v)
                player:RequestFriendship(v)
            end)
        end
    end
    
    for i, v in players:GetPlayers() do
        addPlayer(v)
    end
    
    players.PlayerAdded:Connect(addPlayer)
end

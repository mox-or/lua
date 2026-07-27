if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(3)
print("loaded")

getgenv().getGithubFile = function(file)
    print(file)
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/mox-or/lua/refs/heads/main/" .. file))()
end

getGithubFile("global.lua")

player.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end)

local list = {
    [10200395747] = "gag2",
}

local name = list[game.GameId]
if not name then return end

local file = ("list/%s/script.lua"):format(name)
getGithubFile(file)
getgenv().uzuLoaded = true

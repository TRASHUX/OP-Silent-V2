local Section = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Section/master/lib.lua"))()

local UserSettings = {
    Enabled = false,
    Hitbox = "Head",
    FOVRadius = 10000,
    Prediction = 0.1377
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Client = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 1

local ToggleKey = Enum.KeyCode.C

local function ToggleEnabled()
    UserSettings.Enabled = not UserSettings.Enabled
    FOVCircle.Visible = UserSettings.Enabled
    FOVCircle.Position = UserSettings.Enabled and Mouse.Position or Vector2.new(UserInputService:GetMouseLocation().X, 0)
    if not UserSettings.Enabled then
        Namecall:Disconnect()
    end
end

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == ToggleKey then
        ToggleEnabled()
    end
end)

RunService.PostSimulation:Connect(function()
    if not UserSettings.Enabled then
        return
    end

    local MousePosition = UserInputService:GetMouseLocation()

    FOVCircle.Radius = UserSettings.FOVRadius
    FOVCircle.Position = MousePosition

    Client.Target = nil
    Client.TargetDistance = UserSettings.FOVRadius

    for _, Player in pairs(Players:GetChildren()) do
        local HumanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid")

        if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
            local ScreenPosition, ScreenVisible = CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            ScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            local MouseDistance = (ScreenPosition - MousePosition).magnitude

            if ScreenVisible and MouseDistance < Client.TargetDistance then
                Client.Target = Player
                Client.TargetDistance = MouseDistance
            end
        end
    end
end)

local Namecall
Namecall = hookmetamethod(game, "__namecall", function(Object, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if Method == "FireServer" and Object.Name == "RemoteEvent" and Args[1] == "shoot" and UserSettings.Enabled and Client.Target and Client.Target.Character[UserSettings.Hitbox] then
        Args[2][1] = Client.Target.Character[UserSettings.Hitbox].Position + Client.Target.Character.HumanoidRootPart.Velocity * UserSettings.Prediction
    end

    return Namecall(Object, unpack(Args))
end)

local Toggle = Section.Component("Toggle", "OP Silent Aim", function(bool)
    ToggleEnabled()
end, false)

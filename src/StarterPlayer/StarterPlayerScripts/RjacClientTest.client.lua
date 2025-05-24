local RjacRemote = game.ReplicatedStorage:WaitForChild("RjacRemote")
game:GetService("RunService").RenderStepped:Connect(function()
    RjacRemote:FireServer(game.Workspace.CurrentCamera.CFrame)
end)

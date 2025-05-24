local PlayerService = game:GetService("Players")

local Rjac = require(game.ReplicatedStorage:WaitForChild("Rjac2"))
local RjacProfiles = {}
local RjacRemote = game.ReplicatedStorage:WaitForChild("RjacRemote")

local PlayerConnections = {}

PlayerService.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Wait()
    local Humanoid = Player.Character:WaitForChild("Humanoid")

    local Configurations

    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        local scaleNames = {
            "HumanoidDescription",
            "BodyDepthScale",
            "BodyHeightScale",
            "BodyProportionScale",
            "BodyTypeScale",
            "BodyWidthScale",
            "HeadScale",
            "Status",
            "Animator"
        }
        for _, scaleName in ipairs(scaleNames) do
            while not Humanoid:FindFirstChild(scaleName) do
                Humanoid.ChildAdded:Wait()
            end
        end

        Configurations = {
            {
                BodyPart = "Head",
                BodyJoint = "Neck",
                MultiplierVector = Vector3.new(0.8, -0.8, 0),
                LookVectorAxes = {"Y", "X", "Z"}
            },
            {
                BodyPart = "UpperTorso",
                BodyJoint = "Waist",
                MultiplierVector = Vector3.new(0.2, -0.2, 0),
                LookVectorAxes = {"Y", "X", "Z"}
            },
            -- {
            --     BodyPart = "RightUpperArm",
            --     BodyJoint = "RightShoulder",
            --     MultiplierVector = Vector3.new(1, 0, 0),
            --     LookVectorAxes = {"Y", "X", "Z"}
            -- },
            -- {
            --     BodyPart = "LeftUpperArm",
            --     BodyJoint = "LeftShoulder",
            --     MultiplierVector = Vector3.new(1, 0, 0),
            --     LookVectorAxes = {"Y", "X", "Z"}
            -- },
        }
    elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
        local scaleNames = {
            "HumanoidDescription",
            "Status",
            "Animator"
        }
        for _, scaleName in ipairs(scaleNames) do
            while not Humanoid:FindFirstChild(scaleName) do
                Humanoid.ChildAdded:Wait()
            end
        end

        Configurations = {
            {
                BodyPart = "Torso",
                BodyJoint = "Neck",
                MultiplierVector = Vector3.new(-1, 0, -1),
                LookVectorAxes = {"Y", "X", "X"}
            },
            -- {
            --     BodyPart = "Torso",
            --     BodyJoint = "Right Shoulder",
            --     MultiplierVector = Vector3.new(0, 0, 1),
            --     LookVectorAxes = {"Y", "X", "Y"}
            -- },
            -- {
            --     BodyPart = "Torso",
            --     BodyJoint = "Left Shoulder",
            --     MultiplierVector = Vector3.new(0, 0, -1),
            --     LookVectorAxes = {"Y", "X", "Y"}
            -- },
        }
    else
        Player:Kick("HumanoidRigType is neither R6 or R15")
    end

    local Profile = Rjac.new({Player = Player})
    RjacProfiles[Player.UserId] = Profile
    Profile:Initiate()

    for _,v in pairs(Configurations) do
        Profile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector, v.LookVectorAxes)
    end

    local Tool = Player:WaitForChild("Backpack"):WaitForChild("Gun")

    PlayerConnections[Player.UserId] = {
        Equipped = nil,
        Unequipped = nil
    }

    local function HumanoidDied()
        PlayerConnections[Player.UserId].Equipped:Disconnect()
        PlayerConnections[Player.UserId].Unequipped:Disconnect()
        PlayerConnections[Player.UserId].HumanoidDied:Disconnect()

        if Humanoid.RigType == Enum.HumanoidRigType.R15 then
            Profile:RemoveBodyJoint("RightUpperArm", "RightShoulder")
        elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
            Profile:RemoveBodyJoint("Torso", "Right Shoulder")
        end

        Player.CharacterAdded:Wait()
        Humanoid = Player.Character:WaitForChild("Humanoid")
        Tool = Player:WaitForChild("Backpack"):WaitForChild("Gun")

        PlayerConnections[Player.UserId].Equipped = Tool.Equipped:Connect(function()
            if Humanoid.RigType == Enum.HumanoidRigType.R15 then
                Profile:AddBodyJoint("RightUpperArm", "RightShoulder", Vector3.new(1, 0, 0), {"Y", "X", "Z"})
            elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
                Profile:AddBodyJoint("Torso", "Right Shoulder", Vector3.new(0, 0, 1), {"Y", "X", "Y"})
            end
        end)

        PlayerConnections[Player.UserId].Unequipped = Tool.Unequipped:Connect(function()
            if Humanoid.RigType == Enum.HumanoidRigType.R15 then
                Profile:RemoveBodyJoint("RightUpperArm", "RightShoulder")
            elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
                Profile:RemoveBodyJoint("Torso", "Right Shoulder")
            end
        end)

        PlayerConnections[Player.UserId].HumanoidDied = Humanoid.Died:Connect(HumanoidDied)
    end

    PlayerConnections[Player.UserId].Equipped = Tool.Equipped:Connect(function()
        if Humanoid.RigType == Enum.HumanoidRigType.R15 then
            Profile:AddBodyJoint("RightUpperArm", "RightShoulder", Vector3.new(1, 0, 0), {"Y", "X", "Z"})
        elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
            Profile:AddBodyJoint("Torso", "Right Shoulder", Vector3.new(0, 0, 1), {"Y", "X", "Y"})
        end
    end)

    PlayerConnections[Player.UserId].Unequipped = Tool.Unequipped:Connect(function()
        if Humanoid.RigType == Enum.HumanoidRigType.R15 then
            Profile:RemoveBodyJoint("RightUpperArm", "RightShoulder")
        elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
            Profile:RemoveBodyJoint("Torso", "Right Shoulder")
        end
    end)

    PlayerConnections[Player.UserId].HumanoidDied = Humanoid.Died:Connect(HumanoidDied)

    Profile:ResetJointOffsets(Humanoid.Parent)
    Profile.Enabled = true
end)

PlayerService.PlayerRemoving:Connect(function(Player)
    PlayerConnections[Player.UserId].Equipped:Disconnect()
    PlayerConnections[Player.UserId].Unequipped:Disconnect()
    PlayerConnections[Player.UserId].HumanoidDied:Disconnect()
    RjacProfiles[Player.UserId]:Destroy()
end)

RjacRemote.OnServerEvent:Connect(function(Player, CameraCFrame)
    if not RjacProfiles[Player.UserId] then return end
    RjacProfiles[Player.UserId]:Update(CameraCFrame)
end)

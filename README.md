[Website](https://SohamBorate.github.io/Rjac-2/) built using [Moonwave](https://eryn.io/moonwave/docs/intro/)

# <center> Rjac 2 </center>
<center> Rotating Joints According to Camera </center>

## What is Rjac?

Rjac (pronounced as "r-jack") is an object-oriented module used to rotate character body parts according to camera direction.

For example:

![Clip 1](https://raw.githubusercontent.com/SohamBorate/Rjac-2/refs/heads/main/Clips/Clip1.gif)

![Clip 2](https://raw.githubusercontent.com/SohamBorate/Rjac-2/refs/heads/main/Clips/Clip2.gif)

![Clip 3](https://raw.githubusercontent.com/SohamBorate/Rjac-2/refs/heads/main/Clips/Clip3.gif)

![Clip 4](https://raw.githubusercontent.com/SohamBorate/Rjac-2/refs/heads/main/Clips/Clip4.gif)

The mechanic is used in a lot of games and module is easy to use with simplicity, flexibilty, and customization.

## What's changed from Rjac 1?
- **Support for R6 using `LookVectorAxes`**
- Better design
- Cleaner code

## Demo

Try it for yourself as a player. Run around looking in different directions and your avatar's head will turn as well. Equip the gun and then even the right arm starts rotating.

Game is open for both R6 and R15 **at the same time**.

The `.rbxl` file can be downloaded from the Github repository.

[https://www.roblox.com/games/124920330844766/Rjac-2-Demo](https://www.roblox.com/games/124920330844766/Rjac-2-Demo)

## How to use it?

As I said it's pretty simple to use but not very small, a basic example:

```lua
local Player = game:GetService("Players").LocalPlayer
local Rjac = require(game.ReplicatedStorage:WaitForChild("Rjac2"))

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
Profile:Initiate()

for _,v in pairs(Configurations) do
    Profile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector, v.LookVectorAxes)
end

local Tool = Player:WaitForChild("Backpack"):WaitForChild("Gun")

PlayerConnections[Player.UserId] = {
    Equipped = nil,
    Unequipped = nil
}

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

Profile.Enabled = true

game:GetService("RunService").RenderStepped:Connect(function()
    Profile:Update(game.Workspace.CurrentCamera.CFrame)
end)
```

## Configuration Format

```lua
{
    BodyPart = "Head",
    BodyJoint = "Neck",
    MultiplierVector = Vector3.new(0.8, -0.8, 0),
    LookVectorAxes = {"Y", "X", "Z"}
}
```
Now let's break this down a bit and see what it means

- `BodyPart` i.e `"Head"` is the name of the [`BasePart`](https://create.roblox.com/docs/reference/engine/classes/BasePart) in the `Character`
- where Rjac will find a [`Motor6D`](https://create.roblox.com/docs/reference/engine/classes/Motor6D), named the value of `BodyJoint` i.e `"Neck"`.
- `MultiplierVector` is the [`Vector3`](https://create.roblox.com/docs/reference/engine/datatypes/Vector3), which determines by what value the joint will be rotated.
- `LookVectorAxes` specifies which axis of `CameraCFrame.LookVector` affects the joint rotations

There is only one way of fully understanding how to use this, which is by experimenting with the module itself.

## Documentation

Taking a look at the [Documentation](https://SohamBorate.github.io/Rjac-2/api/Rjac) is **heavily** encouraged to use the module to its full potential.

## Some Sample Configurations
To help developers better familiarise themselves with Rjac.

- **R6 Sample**
  
These configurations rotate the head, arms
```lua
local Configurations = {
    {
        BodyPart = "Torso",
        BodyJoint = "Neck",
        MultiplierVector = Vector3.new(-1, 0, -1),
        LookVectorAxes = {"Y", "X", "X"}
    },
    {
        BodyPart = "Torso",
        BodyJoint = "Right Shoulder",
        MultiplierVector = Vector3.new(0, 0, 1),
        LookVectorAxes = {"Y", "X", "Y"}
    },
    {
        BodyPart = "Torso",
        BodyJoint = "Left Shoulder",
        MultiplierVector = Vector3.new(0, 0, -1),
        LookVectorAxes = {"Y", "X", "Y"}
    }
}
```

- **R15 Sample**

These configurations rotate the head, arms, lower back
```lua
local Configurations = {
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
    {
        BodyPart = "RightUpperArm",
        BodyJoint = "RightShoulder",
        MultiplierVector = Vector3.new(1, 0, 0),
        LookVectorAxes = {"Y", "X", "Z"}
    },
    {
        BodyPart = "LeftUpperArm",
        BodyJoint = "LeftShoulder",
        MultiplierVector = Vector3.new(1, 0, 0),
        LookVectorAxes = {"Y", "X", "Z"}
    }
}
```

## License 

**Mozilla Public License 2.0**

Permissions of this weak copyleft license are conditioned on making available source code of licensed files and modifications of those files under the same license (or in certain cases, one of the GNU licenses). Copyright and license notices must be preserved. Contributors provide an express grant of patent rights. However, a larger work using the licensed work may be distributed under different terms and without source code for files added in the larger work.

Read the full document [here](https://github.com/SohamBorate/Rjac-2/blob/main/LICENSE).

## Installation

- Roblox model (recommended): [https://create.roblox.com/store/asset/90943490052798/Rjac2](https://create.roblox.com/store/asset/90943490052798/Rjac2)
- Github Repository: [https://github.com/SohamBorate/Rjac-2/releases](https://github.com/SohamBorate/Rjac-2/releases)

--[[
    Made by: GiantDefender427

    Github: https://github.com/SohamBorate/Rjac-2
]]

--[=[
    @class Rjac

    Rjac is an object used to rotate the character body parts according to camera direction.
]=]
local Rjac = {}

--[=[
    @prop CameraCFrame CFrame
    @within Rjac
    The last known Camera CFrame of the Player.
]=]
Rjac.CameraCFrame = nil

--[=[
    @prop Character Model
    @within Rjac
    A Model controlled by the Player that contains a Humanoid, body parts, scripts and other objects.
]=]
Rjac.Character = nil

--[=[
    @prop Connections table
    @within Rjac
    Table that stores the connections used by Rjac.
]=]
Rjac.Connections = {}

--[=[
    @prop Enabled bool
    @within Rjac
    Determines whether body parts will be rotated.
]=]
Rjac.Enabled = false

--[=[
    @prop JointConfigurations table
    @within Rjac
    Joint configurations for rotating, joint offsets, multipliers, rotation axes.
]=]
Rjac.JointConfigurations = {}

--[=[
    @prop Player Player
    @within Rjac
    Player/owner of the Rjac object.
]=]
Rjac.Player = nil

--[=[
    Add body joint to the list of joints which are to be rotated.

    @param BodyPart string -- Name of the body part.
    @param BodyJoint string -- Name of the body joint.
    @param MultiplierVector Vector3 -- Vector by which the rotation angle will be multiplied.
    @param LookVectorAxes table -- CameraCFrame.LookVector axes which will be used to rotate the joint axes
]=]
function Rjac:AddBodyJoint(BodyPart, BodyJoint, MultiplierVector, LookVectorAxes)
    for _,v in pairs(self.JointConfigurations) do
        if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
            return
        end
    end
    local Configuration = {
        BodyPart = BodyPart,
        BodyJoint = BodyJoint,
        JointOffset = CFrame.identity,
        MultiplierVector = MultiplierVector,
        LookVectorAxes = LookVectorAxes
    }
    table.insert(self.JointConfigurations, Configuration)
    if self.Character then
        local CharacterBodyPart = self.Character:FindFirstChild(Configuration.BodyPart)
        if CharacterBodyPart then
            local CharacterBodyJoint = CharacterBodyPart:FindFirstChild(Configuration.BodyJoint)
            if CharacterBodyJoint then
                self:UpdateBodyJointOffset(Configuration.BodyPart, Configuration.BodyJoint, CharacterBodyJoint.C0)
            end
        end
    end
end

--[=[
    Disconnects all connections, sets the joint offsets back to defauly, deletes everything.
]=]
function Rjac:Destroy()
    self.Enabled = false
    for _,v in pairs(self.JointConfigurations) do
        self:RemoveBodyJoint(v.BodyPart, v.BodyJoint)
    end
    table.clear(self.JointConfigurations)
    for _,v in pairs(self.Connections) do
        v:Disconnect()
    end
    for i,_ in pairs(self) do
        self[i] = nil
    end
    setmetatable(self, nil)
end

--[=[
    A wrapper function for the default `error`, adds some stuff at the start

    @param arg1 any
    @param arg2 any
    @param arg3 any
    @param arg4 any
]=]
function Rjac:error(arg1, arg2, arg3, arg4)
    error(`Rjac2 => {self.Player.DisplayName} (@{self.Player.Name}) => {arg1} {arg2} {arg3} {arg4}`)
end

--[=[
    Creates and stores the connection to listen for `Player.CharacterAdded` event
]=]
function Rjac:Initiate()
    self.Character = self.Player.Character
    self.Connections.CharacterAdded = self.Player.CharacterAdded:Connect(function(Character)
        self:OnCharacterAdded(Character)
    end)
end

--[=[
    Function to be run when the Player gets a new Character. Waits for the avatar to be fully loaded, then calls `:ResetJointOffsets(Character)`.

    @param Character model -- The Player Character
]=]
function Rjac:OnCharacterAdded(Character)
    while not (Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")) do
        Character.ChildAdded:Wait()
    end

    local Humanoid = Character:FindFirstChild("Humanoid")

    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        local scaleNames = {
            "HumanoidDescription",
            "BodyDepthScale",
            "BodyHeightScale",
            "BodyProportionScale",
            "BodyTypeScale",
            "BodyWidthScale",
            "HeadScale"
        }
        for _, scaleName in ipairs(scaleNames) do
            while not Humanoid:FindFirstChild(scaleName) do
                Humanoid.ChildAdded:Wait()
            end
        end
    elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
        local scaleNames = {
            "HumanoidDescription"
        }
        for _, scaleName in ipairs(scaleNames) do
            while not Humanoid:FindFirstChild(scaleName) do
                Humanoid.ChildAdded:Wait()
            end
        end
    end

    task.wait(0.1)

    self:ResetJointOffsets(Character)
    self.Character = Character
end

--[=[
    A wrapper function for the default `print`, adds some stuff at the start

    @param arg1 any
    @param arg2 any
    @param arg3 any
    @param arg4 any
]=]
function Rjac:print(arg1, arg2, arg3, arg4)
    print(`Rjac2 => {self.Player.DisplayName} (@{self.Player.Name}) => {arg1} {arg2} {arg3} {arg4}`)
end

--[=[
    Remove a specific body joint from the `Rjac.JointConfigurations`

    @param BodyPart string -- Name of the body part.
    @param BodyJoint string -- Name of the body joint.
]=]
function Rjac:RemoveBodyJoint(BodyPart, BodyJoint)
    local JointConfiguration
    for i,v in pairs(self.JointConfigurations) do
        if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
            JointConfiguration = v
            table.remove(self.JointConfigurations, i)
            break
        end
    end
    if not JointConfiguration then return end
    if not self.Character then return end
    local CharacterBodyPart = self.Character:FindFirstChild(JointConfiguration.BodyPart)
    if CharacterBodyPart then
        local CharacterBodyJoint = CharacterBodyPart:FindFirstChild(JointConfiguration.BodyJoint)
        if CharacterBodyJoint then
            CharacterBodyJoint.C0 = JointConfiguration.JointOffset
        end
    end
end

--[=[
    Reads and stores the `Motor6D.C0` into `JointConfigurations[].JointOffset`. Not meant to be used every single time.

    @param Character Model -- The target Character to read from
]=]
function Rjac:ResetJointOffsets(Character)
    for _,v in pairs(self.JointConfigurations) do
        local BodyPart = Character:FindFirstChild(v.BodyPart)
        local BodyJoint
        if BodyPart then
            BodyJoint = BodyPart:FindFirstChild(v.BodyJoint)
            if BodyJoint then
                v.JointOffset = BodyJoint.C0
            end
        end
    end
end

--[=[
    Updates the CameraCFrame and then rotates the body joints accordingly

    @param CameraCFrame CFrame -- The Player's Camera.CFrame
]=]
function Rjac:Update(CameraCFrame)
    if typeof(CameraCFrame) ~= "CFrame" then return end
    self.CameraCFrame = CameraCFrame

    if not self.Enabled then return end
    if not self.Character then
        self:warn("Character does not exist")
        return
    end

    for _,v in pairs(self.JointConfigurations) do
        -- Drops unnecesarry errors when character is being removed or player is leaving, kind of stupid to add "if"s every now and then, "pcall" is better
        local BodyPart = self.Player.Character:FindFirstChild(v.BodyPart)
        local BodyJoint
        if BodyPart then
            BodyJoint = BodyPart:FindFirstChild(v.BodyJoint)
            if BodyJoint then
                local TiltDirection = self.Character.HumanoidRootPart.CFrame:toObjectSpace(CameraCFrame).LookVector.Unit

                -- R15
                -- local Angle = CFrame.Angles(
                --     math.asin(TiltDirection.Y) * v.MultiplierVector.X,
                --     -math.asin(TiltDirection.X) * v.MultiplierVector.Y,
                --     math.asin(TiltDirection.Z) * v.MultiplierVector.Z
                -- )

                --  R6
                local Angle = CFrame.Angles(
                    math.asin(TiltDirection[v.LookVectorAxes[1]]) * v.MultiplierVector.X,
                    math.asin(TiltDirection[v.LookVectorAxes[2]]) * v.MultiplierVector.Y,
                    math.asin(TiltDirection[v.LookVectorAxes[3]]) * v.MultiplierVector.Z
                )

                BodyJoint.C0 = v.JointOffset * Angle
            end
        end
    end
end

--[=[
    Update body joint multiplier vector for a specific joint.

    @param BodyPart string -- Name of the body part.
    @param BodyJoint string -- Name of the body joint.
    @param MultiplierVector Vector3 -- Vector by which the rotation angle will be multiplied.
]=]
function Rjac:UpdateBodyJointMultiplierVector(BodyPart, BodyJoint, MultiplierVector)
    for _,v in pairs(self.JointConfigurations) do
        if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
            v.MultiplierVector = MultiplierVector
            break
        end
    end
end

--[=[
    Update body joint offset for a specific joint.

    @param BodyPart string -- Name of the body part.
    @param BodyJoint string -- Name of the body joint.
    @param JointOffset CFrame -- CFrame by which the rotations are offset.
]=]
function Rjac:UpdateBodyJointOffset(BodyPart, BodyJoint, JointOffset)
    for _,v in pairs(self.JointConfigurations) do
        if v.BodyPart == BodyPart and v.BodyJoint == BodyJoint then
            v.JointOffset = JointOffset
            break
        end
    end
end

--[=[
    A wrapper function for the default `warn`, adds some stuff at the start

    @param arg1 any
    @param arg2 any
    @param arg3 any
    @param arg4 any
]=]
function Rjac:warn(arg1, arg2, arg3, arg4)
    warn(`Rjac2 => {self.Player.DisplayName} (@{self.Player.Name}) => {arg1} {arg2} {arg3} {arg4}`)
end

--[=[
    Creates a new `Rjac` Object.

    @param RjacInfo table -- Table of stuff to overwrite default Rjac stuff with
]=]
function Rjac.new(RjacInfo)
    if not RjacInfo["Player"] then return end
    RjacInfo = RjacInfo or {}
    setmetatable(RjacInfo, Rjac)
    Rjac.__index = Rjac
    return RjacInfo
end

return Rjac

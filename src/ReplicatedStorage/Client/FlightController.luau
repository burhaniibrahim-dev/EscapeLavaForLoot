local ContextAction = game:GetService("ContextActionService")
local Networker = require(game.ReplicatedStorage.Shared.Networker.Client)
local RunService = game:GetService("RunService")

local HOLDING_THRUST, HOLDING_DESCEND = false, false
local airborn = false

local FlightController = {}

local function RequestThrust(_actionName, state, _input)
    local result = Networker.ThrustRequest.Invoke(state == Enum.UserInputState.Begin and airborn == true and HOLDING_THRUST == false)
    HOLDING_THRUST = result
    end

local function RequestDescent(_actionName, state, _input)
    local result = Networker.DescentRequest.Invoke(state == Enum.UserInputState.Begin and HOLDING_THRUST == false and airborn == true)  -- Thrusting takes priority
    HOLDING_DESCEND = result
end

function FlightController:Init()
    ContextAction:BindAction("RequestThrust", RequestThrust, true, Enum.KeyCode.Q)
    ContextAction:BindAction("RequestDecent", RequestDescent, true, Enum.KeyCode.E)

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local hum = character:WaitForChild("Humanoid")

    player.CharacterAdded:Connect(function(char) character = char end) --reassign new character after death

    RunService.Heartbeat:Connect(function(dt)
        airborn = hum.FloorMaterial == Enum.Material.Air

        if airborn then
            if HOLDING_THRUST then
                -- Thrust upward if request is successful
                root.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
            elseif HOLDING_DESCEND then
                -- Slow down descend
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        
    end)
end


return FlightController
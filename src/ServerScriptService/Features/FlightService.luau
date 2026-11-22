--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Networker = require(game.ServerScriptService.Networker.Server)
local FlightState = require(game.ServerScriptService.Features.FlightState)
-----------------------------------------------------

local FlightService = {} 

function FlightService:Init()

    local states = {} --Holds players states

    local function add(player) 
        states[player.UserId] = FlightState.new(player)
    end
    local function remove(player) 
        states[player.UserId]:End()
        states[player.UserId] = nil
    end

    Players.PlayerAdded:Connect(add)
      for _, p in Players:GetPlayers() do add(p) end   -- players who joined before Init
    Players.PlayerRemoving:Connect(remove)

    ---------------------------------------------
    local function HandleThrustRequest(player, request)
        if request ~= true then return false end
        print("Thrust Request Received")
        local state = states[player.UserId]

        if state:CanUseCharges() == true then
            state:AdjustCharges(-1) --remove a charge
            return true
        end

        return false
    end

    local function HandleDescendRequest(player, request)
        if request ~= true then return false end
        print("Descend Request Received")
        return true
    end
    ---------------------------------------------

    Networker.ThrustRequest.On(HandleThrustRequest)
    Networker.DescentRequest.On(HandleDescendRequest)

    RunService.Heartbeat:Connect(function(dt)
        for _, state in states do 
            state:TryRegen(dt) 
            state:TickCooldowns(dt)
        end
    end)

end

return FlightService
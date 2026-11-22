--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Configs = require(ServerScriptService.Configs.Flight)

local MAX_CHARGES, AIR_REGEN, GROUND_REGEN = Configs.MAX_CHARGES,Configs.AIR_REGEN,Configs.GROUND_REGEN
local DEBOUNCE = Configs.THURST_DEBOUNCE

local FlightState  = {}
FlightState .__index = FlightState

function FlightState.new(player)    --Given to each player on join
    local self = setmetatable({}, FlightState)

    self.player = player
    self.weight = 0
    self.charges = 0

    self.progress = 0 -- Toward a new regen
    self.cooldown = 0 -- Toward next move

    self.State = "Idle"

    return self
end

function FlightState:AdjustCharges(amt : number)
    local projectedAmount = amt + self.charges
    if projectedAmount > MAX_CHARGES or projectedAmount < 0 then return end
    self.charges += amt

    if amt < 0 then -- charges were used
        self.progress = 0 -- resets any regen progress
        -- apply a cooldown amount
        self.cooldown = DEBOUNCE
    end

    self.player.Character:SetAttribute("Charges", self.charges)
end

function FlightState:CanUseCharges()
    if self.charges > 0 and self.cooldown <= 0 then return true end
    return false
end

function FlightState:TryRegen(dt : number)
    if self.charges >= MAX_CHARGES then self.progress = 0; return end
    local char = self.player.Character or self.player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    local isGrounded = hum and hum.FloorMaterial ~= Enum.Material.Air
    self.progress += dt / ((isGrounded and GROUND_REGEN) or AIR_REGEN)

   if self.progress >= 1 then
        self:AdjustCharges(1)
        self.progress -= 1
   end
end

function FlightState:TickCooldowns(dt : number)
    if self.cooldown > 0 then
        self.cooldown -= dt / DEBOUNCE
    end
end

function FlightState:End()
end



return FlightState
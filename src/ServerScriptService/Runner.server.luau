--!strict
-- Server entry point. The only Script on the server; everything else is a ModuleScript.
--
-- Each service in SERVICES is a module that may export:
--   Init()  -- runs first, in list order. Set up state; do not yield or call other services.
--   Start() -- runs after every Init, in list order, each in its own thread.

-- Add services here in the order they should initialize, e.g.
--   ServerScriptService.Features.Data.PlayerDataService

local Features = game.ServerScriptService.Features

local SERVICES: { ModuleScript } = {Features.FlightService}

type Service = {
	Init: (() -> ())?,
	Start: (() -> ())?,
}

local loaded: { Service } = {}

for _, moduleScript in SERVICES do
	table.insert(loaded, require(moduleScript) :: any)
end

for _, service in loaded do
	if service.Init then
		service.Init()
	end
end

for _, service in loaded do
	if service.Start then
		task.spawn(service.Start)
	end
end

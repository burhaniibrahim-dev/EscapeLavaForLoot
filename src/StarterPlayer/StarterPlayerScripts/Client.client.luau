--!strict
-- Client entry point. The only LocalScript; everything else is a ModuleScript.
--
-- Each controller in CONTROLLERS is a module that may export:
--   Init()  -- runs first, in list order. Set up state; do not yield or call other controllers.
--   Start() -- runs after every Init, in list order, each in its own thread.

-- Add controllers here in the order they should initialize, e.g.
--   ReplicatedStorage.Client.UI.UIController
local CONTROLLERS: { ModuleScript } = {}

type Controller = {
	Init: (() -> ())?,
	Start: (() -> ())?,
}

local loaded: { Controller } = {}

for _, moduleScript in CONTROLLERS do
	table.insert(loaded, require(moduleScript) :: any)
end

for _, controller in loaded do
	if controller.Init then
		controller.Init()
	end
end

for _, controller in loaded do
	if controller.Start then
		task.spawn(controller.Start)
	end
end

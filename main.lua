-- The main engine reference
engine = {}
serialize = serialize or require("Engine.Libs.ser")
engine.quitReady = false
engine.libs = engine.libs or {}
love.filesystem.setIdentity("RexEngine")

local intro = false
local BUILD_MODE = false

function love.load()
	-- ---------------------------------- Utils --------------------------------- --
	require("Engine/utils")

	-- --------------------------------- Modules -------------------------------- --
	require("Engine/logging")
	engine.Log("[Core] " .. os.date("Logging started for: %d/%m/%y"))
	require("Engine/hooks")
	engine.Log("[Core] " .. "Loaded hook module.")
	require("Engine/cvars")
	engine.Log("[Core] " .. "Loaded cvar module.")
	require("Engine/time")
	engine.Log("[Core] " .. "Loaded time module.")
	require("Engine/files")
	engine.Log("[Core] " .. "Loaded file module.")
	require("Engine/routines")
	engine.Log("[Core] " .. "Loaded routines module.")

	love.filesystem.setSymlinksEnabled(true)
	engine.Log("[Core] Symbolic Links Enabled")

	if (BUILD_MODE) then
		engine.Log("[Core] BUILD MODE IS ACTIVE. ENGINE BOOT HALTED AND MINIMUM SETUP ACHIEVED.")
		engine.quitReady = true
		last_key = nil
		engine.Log([[Engine is now in commandline mode. Quit protection aborted.
Press Q to quit.
Press C to clear all logs.
Press R to reset all configuration.
		]])

		engine.Log("Build finished.")
		return
	end

	-- ! DISABLED ! --
	-- The live-updating is cool, but it isn't perfect, and it might create a multitude of issues
	-- that i'm not willing to fix, or maintain.
	-- It will be disabled until further notice.
	--require("Engine/refresh")
	--engine.Log("[Core] " .. "Loaded lua dynamic refresh module.")

	require("Engine/entities")
	engine.Log("[Core] " .. "Loaded entities module.")
	require("Engine/rendering")
	engine.Log("[Core] " .. "Loaded rendering module.")
	require("Engine/audio")
	engine.Log("[Core] " .. "Loaded audio module.")

	if (intro) then
		require("Engine/Intro/intro")
		engine.Log("[Core] " .. "Loaded intro module.")
	end

	--engine.libs.loveframes = require("Engine.Libs.loveframes")
	--loveframes = engine.libs.loveframes
	--engine.Log("[Core] " .. "Loaded external libraries.")

	engine.Log("[Core] " .. "Finished loading engine modules.")

	--love.math.setRandomSeed( CurTime() )
	math.randomseed(CurTime())

	---@diagnostic disable-next-line: param-type-mismatch
	engine.Log("[Core] " .. "Applied seed to random generator: " .. os.time(os.date("!*t")))
	-- ---------------------------------- Setup --------------------------------- --
	engine.Log("[Core] " .. "Setting up CVars...")
	hooks.Fire("OnSetupCVars")
	hooks.Fire("PostSetupCVars")

	engine.Log("[Core] " .. "Engine loaded!")
	hooks.Fire("PostEngineLoad")
	engine.quitReady = true

	if (engine.GetCVar("debug_cvars", false)) then
		engine.PrintCVars()
	end

	if (not intro) then
		engine.Log("[Core] " .. "Loading game...")
		hooks.Fire("PreGameLoad")
		require("Game/game")
		hooks.Fire("OnGameLoad")
		hooks.Fire("PostGameLoad")
	end
end

function love.keypressed(key, scancode, isrepeat)
	if (BUILD_MODE) then
		if (scancode == "r" and last_key ~= "r") then
			last_key = scancode
			engine.Log("Please confirm that you want to reset all configuration by pressing R again.")
			return
		end
		if (scancode == "c" and last_key ~= "c") then
			last_key = scancode
			engine.Log("Please confirm that you want to clear all the logs by pressing C again.")
			return
		end

		if (scancode == "c" and last_key == "c") then
			engine.Log("Clearing logs...")
			local files = love.filesystem.getDirectoryItems("Engine/Logs/")

			for _, file in ipairs(files) do
				if file:match("%.log$") then
					if (file ~= engine.GetLogFile()) then
						local r = love.filesystem.remove("Engine/Logs/" .. file)
						if (r) then print("Deleted: " .. file) else print("Failed to remove " .. file) end
					end
				end
			end
			engine.Log("Logs cleared.")
		end

		if (scancode == "q") then
			love.event.quit()
		end

		hooks.Fire("OnKeyPressed", key, scancode, isrepeat)
		return
	end

	if (scancode == "f12" and not isrepeat) then
		local v = engine.GetCVar("debug_hooks", false)
		engine.SetCVar("debug_hooks", not v)
		engine.SetCVar("debug_cvars", not v)
		return
	end

	if (scancode == "f6" and not isrepeat) then
		local v = engine.GetCVar("debug_rendering", false)
		engine.SetCVar("debug_rendering", not v)
		return
	end

	if (scancode == "f3" and not isrepeat) then
		local v = engine.GetCVar("debug_entities", false)
		engine.SetCVar("debug_entities", not v)
		return
	end

	if (scancode == "f2" and not isrepeat) then
		local v = engine.GetCVar("debug_physics", false)
		engine.SetCVar("debug_physics", not v)
		return
	end

	hooks.Fire("OnKeyPressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
	hooks.Fire("OnKeyReleased", key, scancode, isrepeat)
end

function love.textinput(text)
	hooks.Fire("OnTextInput", text)
end

function love.mousepressed(x, y, button)
	hooks.Fire("OnMousePress", x, y, button)
end

function love.mousereleased(x, y, button)
	hooks.Fire("OnMouseRelease", x, y, button)
end

function love.update(deltaTime)
	hooks.Fire("PreEngineUpdate", deltaTime)
	hooks.Fire("OnEngineUpdate", deltaTime)
	hooks.Fire("PostEngineUpdate", deltaTime)

	hooks.Fire("PreGameUpdate", deltaTime)
	hooks.Fire("OnGameUpdate", deltaTime)
	hooks.Fire("PostGameUpdate", deltaTime)
end

function love.wheelmoved(x, y)
	hooks.Fire("OnMouseWheel", x, y)
	if y > 0 then
		-- mouse wheel moved up
		hooks.Fire("OnMouseWheelUp", y)
	elseif y < 0 then
		-- mouse wheel moved down
		hooks.Fire("OnMouseWheelDown", y)
	end
end

function love.draw()
	hooks.Fire("PreDraw")

	hooks.Fire("OnCameraAttach")
	hooks.Fire("PreGameDraw")
	hooks.Fire("OnGameDraw")
	hooks.Fire("PostGameDraw")
	hooks.Fire("OnCameraDetach")

	hooks.Fire("PreInterfaceDraw")
	hooks.Fire("OnInterfaceDraw")
	hooks.Fire("PostInterfaceDraw")

	hooks.Fire("PreEngineDraw")
	hooks.Fire("OnEngineDraw")
	hooks.Fire("PostEngineDraw")

	hooks.Fire("PostDraw")
end

function love.quit()
	if (not engine.quitReady) then
		engine.Log("[Core] " ..
		"An attempt was made to shutdown, but the engine isn't ready to shutdown yet. Ignoring...")
		return true
	else
		engine.Log("[Core] " .. "Preparing for shutdown...")
		hooks.Fire("OnEngineShutdown")
		engine.Log("[Core] " .. "Shutting down...")
		return false
	end
end

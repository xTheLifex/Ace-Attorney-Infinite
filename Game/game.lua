game = game or {}
game.Log = function(text) 
	engine.Log("[GAME] " .. text)
end

game.LoadTracks = function ()
	local musicPath = "Game/Assets/Music"
	local musicFiles = love.filesystem.getDirectoryItems(musicPath)
	local count = 0
	for _, file in ipairs(musicFiles) do
		if file:match("%.ogg$") then
			count = count + 1
			engine.audio.ImportMusic(musicPath, file)
		end
	end
	game.Log("Imported " .. count .. " music files.")
end

hooks.Add("OnGameLoad", function() 
	local musicPath = "Game/Assets/Music"
	local music = engine.audio.ImportMusic(musicPath, "[AA] Trial" .. ".ogg") or {name = "ERROR"}
	local secondmusic = engine.audio.ImportMusic(musicPath, "[AAI] Shi-Long Lang - Speak Up, Pup!" .. ".ogg") or {name = "ERROR"}
	engine.audio.PlayMusic(music.name)

	Delay(20, function ()
		engine.audio.PlayMusic(secondmusic.name)
	end)
end)

hooks.Add("OnGameDraw", function ()	
	
end)
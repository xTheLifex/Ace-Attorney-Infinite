engine = engine or {}
engine.assets = engine.assets or {}
engine.assets.music = {}
engine.assets.sounds = {}

-- ------------------------------------ - ----------------------------------- ---- ------------------------------------ - ----------------------------------- --
-- LÖVE supports a lot of audio formats, thanks to the love.sound module, which handles all the decoding. 
-- Supported formats include:
--     MP3
--     Ogg Vorbis
--     WAVE
--     and just about every tracker format you can think of - XM, MOD, and over twenty others.
-- Ogg Vorbis and 16-bit WAVE are the recommended formats. Others may have minor quirks. 
-- For example, the MP3 decoder may pad a few samples depending on what encoder was used. 
-- These issues come from the libraries LÖVE uses to decode the audio files and can't be fixed in LÖVE directly
-- ------------------------------------ - ----------------------------------- ---- ------------------------------------ - ----------------------------------- --

engine.assets.acceptedAudioFormats = {".ogg"}



engine.assets.LoadAudio = function(id, path, type)
    assert(file.exists(path), "Cannot find music file: " .. path)
    -- TODO: Loading
    if (not utils.IsInAcceptedFormats(path, engine.assets.acceptedAudioFormats)) then
        engine.Log("[Assets] Attempt to load invalid music file: " .. path)
        return
    end

    engine.assets.music[id] = {
        id = id,
        name = utils.RemoveExtension(path),
        path = path
    }
end


engine.assets.LoadMusic = function(id, path)
    return engine.assets.LoadAudio(id, path, "stream")
end

engine.assets.LoadSound = function (id, path)
    return engine.assets.LoadAudio(id, path, "static")
end
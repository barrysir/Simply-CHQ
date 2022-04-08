-- if no audio files exist in GameOver music, return silent
NumSongs = #FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."/Sounds/GameOver music/", false, false)
if NumSongs < 1 then 
    local audio_file = "_silent"
    return THEME:GetPathS("", audio_file)
end

-- files exist, so get a listing of available GameOver music
SongList = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."/Sounds/GameOver music/", false, false)

-- pick a random one
local audio_file = "./GameOver music/"..SongList[math.random(NumSongs)]


return THEME:GetPathS("", audio_file)

-- local audio_file = "serenity in ruin.ogg"

-- local style = ThemePrefs.Get("VisualStyle")
-- if style == "SRPG5" then
	-- audio_file = "dreams of will arrange.ogg"
-- end

-- return THEME:GetPathS("", audio_file)

local songs = {
	Hearts = "Express 0805",
	Arrows = "cloud break",
	Bears  = "crystalis",
	Ducks  = "Xuxa fami VRC6",
	Cats   = "Beanmania IIDX",
	Spooky = "Spooky Scary Chiptunes",
	Gay    = "Mystical Wheelbarrow Journey",
	Stars  = "Shooting Star - faux VRC6 remix",
	Thonk  = "Da Box of Kardboard Too (feat Naoki vs ZigZag) - TaroNuke Remix",
	Technique = "Quaq",
	SRPG7  = "SRPG7"
}

-- retrieve the current VisualStyle from the ThemePrefs system
local style = ThemePrefs.Get("VisualStyle")

-- use the style to index the songs table (above)
-- and get the song associated with this VisualStyle
local file = songs[ style ]

-- if a song file wasn't defined in the songs table above
-- fall back on the song for Hearts as default music
-- (this sometimes happens when people are experimenting
-- with making their own custom VisualStyles)
if not file then file = songs.Hearts end

-- annnnnd some EasterEggs
if PREFSMAN:GetPreference("EasterEggs") and style ~= "Thonk" then
	--  41 days remain until the end of the year.
	if MonthOfYear()==10 and DayOfMonth()==20 then file = "20" end
	-- the best way to spread holiday cheer is singing loud for all to hear
	if MonthOfYear()==11 then file = "HolidayCheer" end
end

file = "Express 0805"

-- Friday...
local minuteOfDay = Hour()*60 + Minute()
local itIsFriday = true -- Weekday() == 5
local gamerTime = (minuteOfDay >= 12*60+6*60)
if itIsFriday and gamerTime then
	file = "FridayNight"
end

-- vocaloid appreciation day
if MonthOfYear()==2 and (DayOfMonth() >= 9 and DayOfMonth() <= 10) then 
	file = "Love is war verse"
end

-- osu day
if MonthOfYear()==6 and DayOfMonth()==27 then
	file = "zenith"
end

-- Monthly rotating music: September
if MonthOfYear()==8 then
	file = "souzou"

	-- 9/9 - Cirno Day
	if DayOfMonth()==9 then
		file = "japanese_goblin"
	end
end

-- Monthly rotating music: October
if MonthOfYear()==9 then
	file = "blue_archive"
end

-- Music for December
if MonthOfYear()==11 then
	if itIsFriday then
		if minuteOfDay >= 12*60+7*60 then
			file = "jingle_bells"
		elseif minuteOfDay >= 12*60+4*60 then
			file = "kyominai_chorus"
		end
	end
end

return THEME:GetPathS("", "_common menu music/" .. file)

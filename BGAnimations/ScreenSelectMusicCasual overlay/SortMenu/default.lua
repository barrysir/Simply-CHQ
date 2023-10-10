------------------------------------------------------------
-- set up the SortMenu's choices first, prior to Actor initialization
-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local sort_wheel = setmetatable({}, sick_wheel_mt)
-- the logic that handles navigating the SortMenu
-- (scrolling through choices, choosing one, canceling)
-- is large enough that I moved it to its own file
local sortmenu_input = LoadActor("SortMenu_InputHandler.lua", sort_wheel)
-- "MT" is my personal means of denoting that this thing (the file, the variable, whatever)
-- has something to do with a Lua metatable.
--
-- metatables in Lua are a useful construct when designing reusable components.
-- For example, I'm using them here to define a generic definition of any choice within the SortMenu.
-- The file WheelItemMT.lua contains a metatable definition; the "MT" is my own personal convention
-- in Simply Love.
--
-- Unfortunately, many online tutorials and guides on Lua metatables are
-- *incredibly* obtuse and unhelpful for non-computer-science people (like me).
-- https://lua.org/pil/13.html is just frustratingly scant.
--
-- http://phrogz.net/lua/LearningLua_ValuesAndMetatables.html is less bad than most.
-- I do get immediately lost in the criss-crossing diagrams, and I'll continue to
-- argue that naming things foo, bar, and baz "because we want to teach an idea, not a skill"
-- results in programming tutorials so abstract they don't seem applicable to this world,
-- but its prose was approachable enough for wastes-of-space like me, so I guess I'll
-- recommend it until I find a more helpful one.
--                                      -quietly
local wheel_item_mt = LoadActor("WheelItemMT.lua")
local sortmenu = { w=210, h=160 }

local hasSong = GAMESTATE:GetCurrentSong() and true or false

-- General purpose function to redirect input back to the engine.
-- "self" here should refer to the SortMenu ActorFrame.
local DirectInputToEngine = function(self)
	local screen = SCREENMAN:GetTopScreen()
	local overlay = self:GetParent()

	screen:RemoveInputCallback(sortmenu_input)

	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, false)
	end
	self:playcommand("HideSortMenu")
end

-- Grab language strings from the normal mode sort menu.
local myScreenString = function(s)
	return THEME:GetString("ScreenSelectMusic", s)
end

------------------------------------------------------------

local t = Def.ActorFrame {
	Name="SortMenu",
	-- Always ensure player input is directed back to the engine when initializing SelectMusic.
	InitCommand=function(self) self:visible(false):queuecommand("DirectInputToEngine") end,
	-- Always ensure player input is directed back to the engine when leaving SelectMusic.
	OffCommand=function(self) self:playcommand("DirectInputToEngine") end,
	-- Figure out which choices to put in the SortWheel based on various current conditions.
	OnCommand=function(self) self:playcommand("AssessAvailableChoices") end,
	-- We'll want to (re)assess available choices in the SortMenu if a player late-joins
	PlayerJoinedMessageCommand=function(self, params) self:queuecommand("AssessAvailableChoices") end,
	-- We'll also (re)asses if we want to display the leaderboard depending on if we're actually hovering over a song.
	CurrentSongChangedMessageCommand=function(self)
		if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
			local curSong = GAMESTATE:GetCurrentSong()
			-- Only reasses if we go from song->group or group->song
			if (curSong and not hasSong) or (not curSong and hasSong) then
				self:queuecommand("AssessAvailableChoices")
			end
			hasSong = curSong and true or false
		end
	end,
	ShowSortMenuCommand=function(self) self:visible(true) end,
	HideSortMenuCommand=function(self) self:visible(false) end,
	DirectInputToSortMenuCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()
		screen:AddInputCallback(sortmenu_input)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("ShowSortMenu")
	end,
	-- this returns input back to the engine and its ScreenSelectMusic
	DirectInputToEngineCommand=function(self)
		DirectInputToEngine(self)
	end,

	AssessAvailableChoicesCommand=function(self)
		-- normally I would give variables like these file scope, and not declare
		-- within OnCommand(), but if the player uses the SortMenu to switch from
		-- single to double, we'll need reassess which choices to present.
		-- a style like "single", "double", "versus", "solo", or "routine"
		-- remove the possible presence of an "8" in case we're in Techno game
		-- and the style is "single8", "double8", etc.
		local style = GAMESTATE:GetCurrentStyle():GetName():gsub("8", "")
		local wheel_options = {}

		-- Allow players to switch out to a different SL GameMode if no stages have been played yet,
		-- but don't add the current SL GameMode as a choice. If a player is already in FA+, don't
		-- present a choice that would allow them to switch to FA+.
		if SL.Global.Stages.PlayedThisGame == 0 then
			-- if SL.Global.GameMode ~= "ITG"      then table.insert(wheel_options, {"ChangeMode", "ITG"}) end
			table.insert(wheel_options, {"ChangeMode", "ITG"})
		end
		
		sort_wheel.focus_pos = 4
		sort_wheel:set_info_set(wheel_options, 1)
	end,
	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.8) end
	},
	-- OptionsList Header Quad
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w+2,22):xy(_screen.cx, _screen.cy-92) end
	},
	-- "Options" text
	Def.BitmapText{
		Font="Common Bold",
		Text=myScreenString("Options"),
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy-92):zoom(0.4)
				:diffuse( Color.Black )
		end
	},
	-- white border
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w+2,sortmenu.h+2) end
	},
	-- BG of the sortmenu box
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w,sortmenu.h):diffuse(Color.Black) end
	},
	-- top mask
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w,_screen.h/2):y(40):MaskSource() end
	},
	-- bottom mask
	Def.Quad {
		InitCommand=function(self) self:zoomto(sortmenu.w,_screen.h/2):xy(_screen.cx,_screen.cy+200):MaskSource() end
	},
	-- "Press SELECT To Cancel" text
	Def.BitmapText{
		Font="Common Bold",
		Text=myScreenString("Cancel"),
		InitCommand=function(self)
			if PREFSMAN:GetPreference("ThreeKeyNavigation") then
				self:visible(false)
			else
				self:xy(_screen.cx, _screen.cy+100):zoom(0.3):diffuse(0.7,0.7,0.7,1)
			end
		end
	},
	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "Sort Menu", 7, wheel_item_mt, _screen.cx, _screen.cy )
}
t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }
return t

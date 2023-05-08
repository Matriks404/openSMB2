local music = {}

music.m = {}

function music.load(directory)
	local directory = directory.."sound/music/"

	-- Optional
	music_title_file = directory.."title.ogg"
	music_char_select_file = directory.."charselect.ogg"
	music_overworld_file = directory.."overworld.ogg"
	music_underworld_file = directory.."underworld.ogg"
	music_boss_file = directory.."boss.ogg"

	local music_title = resources.loadSound(directory.."title.ogg", "stream")
	local music_char_select= resources.loadSound(directory.."charselect.ogg", "stream")
	local music_overworld = resources.loadSound(directory.."overworld.ogg", "stream")
	local music_underworld = resources.loadSound(directory.."underworld.ogg", "stream")
	local music_boss = resources.loadSound(directory.."boss.ogg", "stream")

	music.m = {
		["title"] = { short_name = "TITL", track = music_title },
		["character_select"] = { short_name = "CHA", track = music_char_select },
		["overworld"] = { short_name = "OVR", track = music_overworld },
		["underworld"] = { short_name = "UND", track = music_underworld },
		["boss"] = { short_name = "BOS", track = music_boss }
	}
end

function music.play(name)
	if not app.muted then
		if music.m[name].track then
			music.m[name].track:play()
		end

		music.stopAll(name) -- Stop all music except the current track.
	end
end

function music.playCurrent()
	local s = state.s[state.name]

	if s.music and not app.muted then
		if s.music ~= "LEVEL_SPECIFIC" then
			music.play(s.music)
		end
	else
		music.stopAll()
	end
end

function music.stop(name)
	if music.m[name].track then
		music.m[name].track:stop()
	end
end

function music.stopAll(except)
	for k in pairs(music.m) do
		if k ~= except then
			music.stop(k)
		end
	end
end

return music
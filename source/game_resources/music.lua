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

function music.restart()
	music.stop()
	music.play()
end

function music.setCurrent(name)
	music.old = music.current
	music.current = name
end

function music.play()
	if music.old then
		music.stop(music.old)
	end

	if not music.current then
		music.stop()
	end

	if music.m[music.current] and music.m[music.current].track then
		music.m[music.current].track:play()
	end
end

function music.stop(name)
	if not name then
		if music.current then
			name = music.current
		else
			return
		end
	end

	if music.m[name] and music.m[name].track and music.m[name].track:isPlaying() then
		music.m[name].track:stop()
	end
end

return music
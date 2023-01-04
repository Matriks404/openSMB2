local music = {}

music_dir = "resources/sound/music/"

mus = {}
mus["title"] = { short_name = "TITL" }
mus["character_select"] = { short_name = "CHAR" }
mus["overworld"] = { short_name = "OVER" }
mus["underworld"] = { short_name = "UNDR" }
mus["boss"] = { short_name = "BOSS" }

function music.load()
	music_title = love.audio.newSource(music_dir.."title.ogg", "stream")
	music_char_select = love.audio.newSource(music_dir.."charselect.ogg", "stream")
	music_overworld = love.audio.newSource(music_dir.."overworld.ogg", "stream")
	music_underworld = love.audio.newSource(music_dir.."underworld.ogg", "stream")
	music_boss = love.audio.newSource(music_dir.."boss.ogg", "stream")
end

function music.play()
	if debug.mute == false then
		if world.current_area.music == "overworld" then
			music_overworld:play()
		elseif world.current_area.music == "underworld" then
			music_underworld:play()
		elseif world.current_area.music == "boss" then
			music_boss:play()
		end

		if world.current_area.music ~= "overworld" then
			music_overworld:stop()
		end

		if world.current_area.music ~= "underworld" then
			music_underworld:stop()
		end

		if world.current_area.music ~= "boss" then
			music_boss:stop()
		end
	end
end

function music.stop()
	music_overworld:stop()
	music_underworld:stop()
	music_boss:stop()
end

return music
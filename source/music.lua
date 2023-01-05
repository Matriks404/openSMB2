local music = {}

music.mus = {}
music.mus["title"] = { short_name = "TITL" }
music.mus["character_select"] = { short_name = "CHAR" }
music.mus["overworld"] = { short_name = "OVER" }
music.mus["underworld"] = { short_name = "UNDR" }
music.mus["boss"] = { short_name = "BOSS" }

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
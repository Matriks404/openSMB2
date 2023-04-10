local music = {}

function music.init()
	music.m = {
		["title"] = { short_name = "TITL", track = snd.music_title },
		["character_select"] = { short_name = "CHA", track = snd.music_char_select },
		["overworld"] = { short_name = "OVR", track = snd.music_overworld },
		["underworld"] = { short_name = "UND", track = snd.music_underworld },
		["boss"] = { short_name = "BOS", track = snd.music_boss }
	}
end

function music.play(name)
	if not debugging.mute then
		if music.m[name] then
			music.m[name].track:play()
		end

		music.stopAll(name) -- Stop all music except the current track.
	end
end

function music.stopAll(except)
	for k in pairs(music.m) do
		if k ~= except then
			music.stop(k)
		end
	end
end

function music.stop(name)
	if not debugging.mute then
		music.m[name].track:stop()
	end
end

return music
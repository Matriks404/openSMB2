local music = {}

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

		return
	end

	local m = game_resources.music[music.current]

	if m and m.track then
		m.track:play()
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

	local m = game_resources.music[name]

	if m and m.track and m.track:isPlaying() then
		m.track:stop()
	end
end

return music
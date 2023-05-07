local music = {}

music.m = {}

function music.play(name)
	if not debugging.mute then
		if music.m[name].track then
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
	if not debugging.mute and music.m[name].track then
		music.m[name].track:stop()
	end
end

return music
local music = {}

music_dir = "resources/sound/music/"

function music.load()

	music_title = love.audio.newSource(music_dir.."title.ogg", "stream")
	music_char_select = love.audio.newSource(music_dir.."charselect.ogg", "stream")
	music_overworld = love.audio.newSource(music_dir.."overworld.ogg", "stream")
	music_underworld = love.audio.newSource(music_dir.."underworld.ogg", "stream")
	music_boss = love.audio.newSource(music_dir.."boss.ogg", "stream")
end

function music.play()
	if debug.mute == false then
		if world.current_area.music == 0 then
			music_overworld:play()

			music_underworld:stop()
			music_boss:stop()
		elseif world.current_area.music == 1 then
			music_underworld:play()

			music_overworld:stop()
			music_boss:stop()
		else
			music_boss:play()

			music_overworld:stop()
			music_underworld:stop()
		end
	end
end

function music.stop()
	music_overworld:stop()
	music_underworld:stop()
	music_boss:stop()
end

return music
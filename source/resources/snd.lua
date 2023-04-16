local snd = {}

function snd.load(directory)
	local directory = directory.."sound/"

	snd.loadSFX(directory)
	snd.loadMusic(directory)
end

function snd.tryToLoadOptionalFile(file, source_type)
	if love.filesystem.getInfo(file) then
		return love.audio.newSource(file, source_type)
	else
		return nil
	end
end

function snd.loadSFX(directory)
	local directory = directory.."effects/"

	-- Optional
	snd.sfx_fall = snd.tryToLoadOptionalFile(directory.."fall.ogg", "static")
	snd.sfx_pickup = snd.tryToLoadOptionalFile(directory.."pickup.ogg", "static")
	snd.sfx_death = snd.tryToLoadOptionalFile(directory.."death.ogg", "static")
	snd.sfx_game_over = snd.tryToLoadOptionalFile(directory.."gameover.ogg", "static")
end

function snd.loadMusic(directory)
	local directory = directory.."music/"

	-- Optional

	music_title_file = directory.."title.ogg"
	music_char_select_file = directory.."charselect.ogg"
	music_overworld_file = directory.."overworld.ogg"
	music_underworld_file = directory.."underworld.ogg"
	music_boss_file = directory.."boss.ogg"

	snd.music_title = snd.tryToLoadOptionalFile(directory.."title.ogg", "stream")
	snd.music_char_select= snd.tryToLoadOptionalFile(directory.."charselect.ogg", "stream")
	snd.music_overworld = snd.tryToLoadOptionalFile(directory.."overworld.ogg", "stream")
	snd.music_underworld = snd.tryToLoadOptionalFile(directory.."underworld.ogg", "stream")
	snd.music_boss = snd.tryToLoadOptionalFile(directory.."boss.ogg", "stream")
end

return snd
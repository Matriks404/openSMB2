local snd = {}

function snd.load()
	snd.loadSFX()
	snd.loadMusic()

end

function snd.loadSFX()
	sfx_directory = "resources/sound/effects/"

	sfx_fall = love.audio.newSource(sfx_directory.."fall.ogg", "static")
	sfx_cherry = love.audio.newSource(sfx_directory.."cherry.ogg", "static")
	sfx_death = love.audio.newSource(sfx_directory.."death.ogg", "static")
	sfx_game_over = love.audio.newSource(sfx_directory.."gameover.ogg", "static")
end

function snd.loadMusic()
	music_directory = "resources/sound/music/"

	music_title = love.audio.newSource(music_directory.."title.ogg", "stream")
	music_char_select = love.audio.newSource(music_directory.."charselect.ogg", "stream")
	music_overworld = love.audio.newSource(music_directory.."overworld.ogg", "stream")
	music_underworld = love.audio.newSource(music_directory.."underworld.ogg", "stream")
	music_boss = love.audio.newSource(music_directory.."boss.ogg", "stream")
end

return snd
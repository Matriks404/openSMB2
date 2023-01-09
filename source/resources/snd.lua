local snd = {}

function snd.load()
	snd.loadSFX()
	snd.loadMusic()
end

function snd.loadSFX()
	local directory = "resources/sound/effects/"

	snd.sfx_fall = love.audio.newSource(directory.."fall.ogg", "static")
	snd.sfx_cherry = love.audio.newSource(directory.."cherry.ogg", "static")
	snd.sfx_death = love.audio.newSource(directory.."death.ogg", "static")
	snd.sfx_game_over = love.audio.newSource(directory.."gameover.ogg", "static")
end

function snd.loadMusic()
	local directory = "resources/sound/music/"

	snd.music_title = love.audio.newSource(directory.."title.ogg", "stream")
	snd.music_char_select = love.audio.newSource(directory.."charselect.ogg", "stream")
	snd.music_overworld = love.audio.newSource(directory.."overworld.ogg", "stream")
	snd.music_underworld = love.audio.newSource(directory.."underworld.ogg", "stream")
	snd.music_boss = love.audio.newSource(directory.."boss.ogg", "stream")
end

return snd
local sfx = {}

function sfx.load()
	sfx_dir = "resources/sound/effects/" -- Sound effects folder

	sfx_fall = love.audio.newSource(sfx_dir.."fall.ogg", "static")
	sfx_cherry = love.audio.newSource(sfx_dir.."cherry.ogg", "static")
	sfx_death = love.audio.newSource(sfx_dir.."death.ogg", "static")
	sfx_game_over = love.audio.newSource(sfx_dir.."gameover.ogg", "static")
end

return sfx
local sound = {}

function sound.load(directory)
	local directory = directory.."sound/effects/"

	-- Optional
	sound.fall = resources.loadSound(directory.."fall.ogg", "static")
	sound.pickup = resources.loadSound(directory.."pickup.ogg", "static")
	sound.death = resources.loadSound(directory.."death.ogg", "static")
	sound.game_over = resources.loadSound(directory.."gameover.ogg", "static")
end

function sound.play(name)
	if not app.muted then
		sound[name]:play()
	end
end

return sound
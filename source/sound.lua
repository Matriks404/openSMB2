local sound = {}

function sound.play(name)
	if not app.muted then
		game_resources.sound[name]:play()
	end
end

return sound
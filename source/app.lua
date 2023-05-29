utils = require "source/utils"

local app = {}

app.muted = false

function app.setup()
	app.title = "openSMB2"
	app.full_title = app.title.." v"..app.getVersion()

	window.setup()
	graphics.init()
	filesystem.setup()
	launcher.load()
end

function app.update(dt)
	if state.name ~= "launcher" and not debugging.pause then
		state.delta = state.delta + dt

		while state.delta >= state.tick_rate do
			state.delta = state.delta - state.tick_rate
			state.timer = state.timer + 1

			game.update()
		end
	end
end

function app.draw()
	love.graphics.scale(graphics.scale)

	if state.name == "launcher" then
		launcher.draw()
	else
		game.draw()
	end

	debugging.drawInfo()
end

function app.switchMuteState()
	app.muted = not app.muted

	if app.muted then
		love.audio.setVolume(0)

		game_resources.music.old = nil
		game_resources.music.stop()
	else
		love.audio.setVolume(1)

		game_resources.music.play()
	end
end

function app.getVersion()
	local success, version = pcall(love.filesystem.read, "version")

	return (success and version) or "UNKNOWN"
end

return app
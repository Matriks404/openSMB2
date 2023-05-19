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
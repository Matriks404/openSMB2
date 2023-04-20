utils = require "source/utils"

local app = {}

function app.setup()
	app.title = "openSMB2"
	app.full_title = app.title.." v"..app.getVersion()

	window.setup()
	graphics.init()

	filesystem.setup()
	launcher.load()
end

function app.getVersion()
	return love.filesystem.read("version")
end

return app
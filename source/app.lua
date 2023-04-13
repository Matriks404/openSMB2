utils = require "source/utils"

local app = {}

app.title = "openSMB2"
app.full_title = app.title.." v"..utils.getVersion()

function app.setup()
	window.setup()
	graphics.init()

	filesystem.setup()
	launcher.load()
end

return app
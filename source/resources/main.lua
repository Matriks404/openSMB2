font = require "source/resources/font"
img = require "source/resources/img"
snd = require "source/resources/snd"
story = require "source/resources/story"

local resources = {}

function resources.load(directory)
	local app_directory = "/resources/"
	img.loadEditorImages(app_directory)

	local game_directory = directory.."/resources/"
	font.load(game_directory)
	img.loadGameImages(game_directory)
	snd.load(game_directory)
	story.load(game_directory)
end

return resources
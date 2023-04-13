font = require "source/resources/font"
img = require "source/resources/img"
snd = require "source/resources/snd"
story = require "source/resources/story"

local resources = {}

function resources.load(directory)
	local directory = directory.."/resources/"

	font.load(directory)
	img.loadForGame(directory)
	snd.load(directory)
	story.load(directory)
end

return resources
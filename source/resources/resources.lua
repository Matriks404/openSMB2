font = require "source/resources/font"
img = require "source/resources/img"
snd = require "source/resources/snd"
story = require "source/resources/story"

local resources = {}

function resources.load()
	font.load()
	img.load()
	snd.load()
end

return resources
font = require "source/resources/font"
graphics = require "source/resources/graphics"
music = require "source/resources/music"
sfx = require "source/resources/sfx"
story = require "source/resources/story"

local resources = {}

function resources.load()
	font.load()
	graphics.load()
	music.load()
	sfx.load()
end

return resources
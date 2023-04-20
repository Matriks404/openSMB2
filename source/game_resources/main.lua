local game_resources = {}

game_resources.images = require "source/game_resources/images"
game_resources.music = require "source/game_resources/music"
game_resources.sound = require "source/game_resources/sound"
game_resources.story = require "source/game_resources/story"

function game_resources.load(directory)
	local game_directory = directory.."/resources/"

	font.load(game_directory)

	game_resources.images.load(game_directory)
	game_resources.sound.load(game_directory)
	game_resources.story.load(game_directory)
end

return game_resources
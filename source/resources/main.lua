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

function resources.tryToLoadOptionalFile(f, file, source_type)
	if love.filesystem.getInfo(file) then
		return f(file, source_type)
	else
		return nil
	end
end

function resources.loadMandatoryFile(f, file, source_type)
	return f(file, source_type)
end

return resources
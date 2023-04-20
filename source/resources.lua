font = require "source/font"

local resources = {}

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

function resources.loadImage(file, is_mandatory)
	local f = love.graphics.newImage

	if is_mandatory then
		return resources.loadMandatoryFile(f, file)
	else
		return resources.tryToLoadOptionalFile(f, file)
	end
end

function resources.loadSound(file, source_type, is_mandatory)
	local f = love.audio.newSource

	if is_mandatory then
		return resources.loadMandatoryFile(f, file, source_type)
	else
		return resources.tryToLoadOptionalFile(f, file, source_type)
	end
end

return resources
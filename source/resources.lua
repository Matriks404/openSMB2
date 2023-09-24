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

function resources.loadImages(source, list)
	for key, values in pairs(list) do
		local filename = values[1]
		local mandatoriness = values[2]

		source[key] = resources.loadImage(filename, mandatoriness)
	end
end

function resources.loadMusic(source, list)
	for key, values in pairs(list) do
		local filename = values[1]
		local short_name = values[2]
		local mandatoriness = values[3]

		source[key] = {}
		source[key].track = resources.loadSound(filename, "stream", mandatoriness)
		source[key].short_name = short_name
	end
end

function resources.loadSoundEffects(source, list)
	for key, values in pairs(list) do
		local filename = values[1]
		local mandatoriness = values[2]

		source[key] = resources.loadSound(filename, "static", mandatoriness)
	end
end

return resources
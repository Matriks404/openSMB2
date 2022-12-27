local utils = {}

function utils.getVersion()
	version_file = love.filesystem.read("version")

	return version_file
end

return utils
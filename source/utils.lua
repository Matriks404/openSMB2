local utils = {}

function utils.getVersion()
	return love.filesystem.read("version")
end

return utils
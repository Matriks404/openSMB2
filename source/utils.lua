local utils = {}

function utils.stringEndsWith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

function utils.getVersion()
	return love.filesystem.read("version")
end

return utils
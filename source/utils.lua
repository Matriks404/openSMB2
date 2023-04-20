local utils = {}

function utils.stringEndsWith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

return utils
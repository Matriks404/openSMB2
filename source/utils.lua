local utils = {}

function utils.getVersion()
	version_file = love.filesystem.read("version")

	return version_file
end

function utils.setBackgroundColor(color)
	if color == "black" then
		love.graphics.setBackgroundColor(0, 0, 0)

	elseif color == "light_blue" then

		love.graphics.setBackgroundColor(0.24, 0.74, 0.99)
	elseif color == "blue" then

		love.graphics.setBackgroundColor(0.36, 0.58, 0.99)
	end
end

function utils.toPaddedString(number, digits)
	str = tostring(number)
	sum = number

	for i=1, digits - 1 do
		if sum < 10 then
			str = "0"..str
		end

		sum = sum / 10
	end

	return str
end

return utils
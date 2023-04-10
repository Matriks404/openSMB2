utils = require "source/utils"

local game = {}

game.title = "openSMB2"
game.full_title = game.title.." v"..utils.getVersion()

function game.getRemainingLives(lives)
	local str, letter

	local lives = lives - 1

	if lives < 10 then
		str = " "..tostring(lives)

	elseif lives < 100 then
		str = tostring(lives)

	elseif lives < 255 then
		local tens_digit = math.floor((lives - 100) / 10)
		local letter = string.char(tens_digit + 65)

		local digit = tostring((lives) % 10)

		str = letter..digit
	end

	return str
end

return game
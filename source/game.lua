utils = require "source/utils"

local game = {}

game.title = "openSMB2"
game.full_title = game.title.." v"..utils.getVersion()

function game.getRemainingLives(lives)
	local str, letter

	if lives < 10 + 1 then
		str = " "..tostring(lives - 1)

	elseif lives < 100 + 1 then
		str = tostring(lives - 1)

	elseif lives < 255 + 1 then
		if lives < 110 + 1 then     letter = "A"
		elseif lives < 120 + 1 then letter = "B"
		elseif lives < 130 + 1 then letter = "C"
		elseif lives < 140 + 1 then letter = "D"
		elseif lives < 150 + 1 then letter = "E"
		elseif lives < 160 + 1 then letter = "F"
		elseif lives < 170 + 1 then letter = "G"
		elseif lives < 180 + 1 then letter = "H"
		elseif lives < 190 + 1 then letter = "I"
		elseif lives < 200 + 1 then letter = "J"
		elseif lives < 210 + 1 then letter = "K"
		elseif lives < 220 + 1 then letter = "L"
		elseif lives < 230 + 1 then letter = "M"
		elseif lives < 240 + 1 then letter = "N"
		elseif lives < 250 + 1 then letter = "O"
		else                        letter = "P"
		end

		str = letter..tostring(math.floor((lives - 1) % 10))
	end

	return str
end

return game
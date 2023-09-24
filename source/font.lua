local font = {}

font.symbols = {}

function font.load(directory)
	local directory = directory.."images/font/"

	font.loadSymbols(directory, game.font1)

	if game.font2 and love.filesystem.getInfo(directory..game.font2..".png") then
		font.loadSymbols(directory, game.font2)
	else
		game.font2 = game.font1
	end
end

function font.loadSymbols(directory, name)
	font[name] = love.graphics.newImage(directory..name..".png")

	local font_width = font[name]:getWidth()
	local font_height = font[name]:getHeight()

	font.symbol_size = font_width / 32

	font.symbols[name] = {}

	for i = 0, 127 do
		local x = (i % 32) * font.symbol_size
		local y = math.floor(i / 32) * font.symbol_size

		local quad = love.graphics.newQuad(x, y, font.symbol_size, font.symbol_size, font_width, font_height)
		font.symbols[name][i] = quad
	end
end

return font
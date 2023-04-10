local font = {}

font.symbols = {}

function font.load()
	font.loadSymbols("white")
	font.loadSymbols("brown")

	print(font.symbols["white"][0])
end

function font.loadSymbols(color)
	local directory = "resources/images/font/"

	font[color] = love.graphics.newImage(directory..color..".png")

	local font_width = font[color]:getWidth()
	local font_height = font[color]:getHeight()

	font.symbol_size = font_width / 32

	font.symbols[color] = {}

	for i = 0, 255 do
		local x = (i % 32) * font.symbol_size
		local y = math.floor(i / 32) * font.symbol_size

		local quad = love.graphics.newQuad(x, y, font.symbol_size, font.symbol_size, font_width, font_height)
		font.symbols[color][i] = quad
	end
end

return font
local font = {}

font.directory = "resources/images/font/"

function font.load()
	font_white = love.graphics.newImage(font.directory.."white.png")
	font_brown = love.graphics.newImage(font.directory.."brown.png")
end

return font
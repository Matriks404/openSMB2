local font = {}

font_dir = "resources/images/font/" -- Fonts folder

function font.load()
	font_white = love.graphics.newImage(font_dir.."white.png")
	font_brown = love.graphics.newImage(font_dir.."brown.png")
end

return font
local font = {}

function font.load()
	local directory = "resources/images/font/"

	font["white"] = love.graphics.newImage(directory.."white.png")
	font["brown"] = love.graphics.newImage(directory.."brown.png")
end

return font
local window = {}

function window.setInitialScale()
	graphics.max_scale = 1
	graphics.scale = 1
end

function window.update()
	local screen_width, screen_height = love.graphics.getDimensions("top")

	local rendered_width = graphics.width * graphics.scale
	local rendered_height = graphics.height * graphics.scale

	graphics.x = (screen_width - rendered_width) / 2
	graphics.y = (screen_height - rendered_height) / 2
end

function window.setup()
	window.setInitialScale()
	window.update()
end

return window
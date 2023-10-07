local window = {}

--window.fullscreen = false
--window.resizable = false
--window.vsync = true

function window.setInitialScale()
	local screen_width, screen_height = love.graphics.getDimensions("top")

	--local max_width_scale = math.floor(love.window.fromPixels(screen_width) / graphics.width)
	--local max_height_scale = math.floor(love.window.fromPixels(screen_height) / graphics.height)

	--graphics.max_scale = math.min(max_width_scale, max_height_scale)
	--graphics.scale = graphics.max_scale - 1
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

	--love.window.setTitle(app.title)
end

--TODO: Do something on window resize, for level editor purposes.
--[[
function window.resize()
	local width, height, _ = love.window.getMode()

	-- ...
end
]]--

return window
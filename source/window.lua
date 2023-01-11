local window = {}

window.fullscreen = false
window.resizable = false

function window.calculateMaxSize()
	local _, _, flags = love.window.getMode()
	local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

	local max_width_scale = math.floor(love.window.fromPixels(desktop_width) / graphics.width)
	local max_height_scale = math.floor(love.window.fromPixels(desktop_height) / graphics.height)

	graphics.max_scale = math.min(max_width_scale, max_height_scale)
	graphics.scale = graphics.max_scale - 1
end

function window.update()
	local width = graphics.width
	local height = graphics.height

	if graphics.scale < 1 then
		graphics.scale = 0
	end

	love.window.setMode(width * graphics.scale, height * graphics.scale, {fullscreen = window.fullscreen, resizable = window.resizable, vsync = true})
end

function window.updateFullscreen()
	window.fullscreen = not window.fullscreen

	window.update()
end

function window.setup()
	window.calculateMaxSize()
	window.update()

	love.window.setTitle(game.title)
end

return window